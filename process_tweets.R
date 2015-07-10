rm(list=ls())

library("RMySQL")
library("zoo") 					# for time series
library("tm")
library("wordcloud")
library("RColorBrewer")			# color of wordclouds
library("ggplot2")
source("doInteractions.R")			# Interactions between mentions

path <- "/home/adrian/Documentos/v3/data"

parties <- c("PPopular","ahorapodemos","PSOE","ciudadanosCs","iunida","UPyD")
parties_short <-c("PP","Podemos","PSOE","Cs","IU","UPyD")

parties_name <- c("Partido Popular", "Podemos", "Partido Socialista",
"Ciudadanos", "Izquierda Unida", "Union Progreso y Democracia")

parties_long <- c("l PP", " Podemos", "l PSOE", " Ciudadanos", " IU", " UPyD")
parties_color <- c( colors()[124], colors()[98], colors()[553], colors()[90], 
	colors()[555], colors()[118])

parties_ggcolor = c("#0066FF","#993399","#FF0000","#FF9900","#CC0000","#FF33CC")


# Window for selecting tweets (in seconds)
window = 60*10

# Window of days maintaining the data in the database:
db_window = 10

while (1<2) {

# Run calculations at given hour
time_calc = 11

# Variable indicating whether calculations have been done today
calc_done <- 0

# Yesterday's date (used in DB queries)
timestart <- as.POSIXct(paste0(Sys.Date()-1, " 00:00:00"))

# Today's date (used in day loop)
today <- as.POSIXct(paste0(Sys.Date(), " 00:00:00"))

# Exit the loop tomorrow
while (Sys.time() < today+60*60*24) {

# Do calculations 
if ( (Sys.time() > today + 60*60*time_calc) && ( calc_done==0 ) ) {

con <- dbConnect(MySQL(),
	user="root", password="...",
	dbname="twt_partidos",host="localhost")

	# Trick so that the 00:00:00 appear in the date
	time1 = timestart +0.000001
	
	time_vec <- vector(mode="character")
	
	# Data frame counting mentions
	mentions <- data.frame()
	
	# Create vectors that will store unique users
	for (i in 1:length(parties)) {
		assign( paste0( "tweeters_", parties[i] ) , vector(mode="character"))
		assign( paste0( "origtweeters_", parties[i] ) , vector(mode="character"))
		assign( paste0( "retweeters_", parties[i] ) , vector(mode="character"))
		assign( paste0( "tf_"  , parties[i] ) , vector(mode="character")) 
	}

	# Counter of the while loop
	data_iter = 1
	

	# Loop til the end of the day
	while (time1 < timestart + 60*60*24) {
		
		time2 = time1+window
		
		txtquery = paste0("SELECT * FROM tweets WHERE date >= ", "'", 
        		as.POSIXct(time1), "'", " AND date <= ", "'", as.POSIXct(time2) , "'" )
	
		cat(paste0("Querying for tweets between ", as.POSIXct(time1), " and ",as.POSIXct(time2)),"\n")
	
		query <- dbSendQuery(con, txtquery ) 
		data <- fetch(query,n=-1)
		dbClearResult(query)

		data$id <- as.numeric(data$id)

		# If there is data in the query
		if (dim(data)[1] > 0) {

			# Check possible duplicates
			index <- which(duplicated(data$id))	

			# Remove duplicates
			if (length(index) > 0) {
				data=data[-index,]
			}
		
	        	cat(paste0("Tweets: ", dim(data)[1], " duplicated: ",length(index)),"\n")

			# Loop sobre partidos
			for (ind in 1:length(parties)) {

				# Indicador si partido[ind] fue mencionado en el tuit
				data[ grep(parties[ind],data$text,ignore.case=TRUE) , as.character(parties[ind]) ] <-1

				# Sumar menciones de de cada partido
	       			mentions[data_iter,ind] <- 
            				sum( data[ grep(parties[ind],data$text,ignore.case=TRUE) ,
            				as.character(parties[ind]) ] , na.rm=T )
				
				# Tuits que mencionan dicho partido
				dataparty_i <- subset(data, get( as.character(parties[ind]) )==1 )$text 

				# .. si existen datos de dicho partido
				if ( length(dataparty_i)>0 ) { 

				# Poner texto junto
				corpus_i <-VCorpus( VectorSource( paste(dataparty_i,collapse=" ") ) )

				# Manipulations of the corpus of party i (put in function)
				# This erases @ and #
				#corpus_i <- tm_map(corpus_i, removePunctuation)
				
				corpus_i <- tm_map(corpus_i, tolower)
				corpus_i <- tm_map(corpus_i, function(x) removeWords(x,stopwords("spanish")))

				# Transform again to corpus (some words may become the same and otherwise doesn't work)
				corpus_i <- tm_map(corpus_i, PlainTextDocument)
				
				# Term Frequency Matrix (TDM). Hacer data frame
				tfparty_i <- as.data.frame( termFreq(corpus_i[[1]]) )
				tfparty_i <- cbind(rownames(tfparty_i), tfparty_i)
				tfparty_i[,1] <- as.character(tfparty_i[,1])
				rownames(tfparty_i) <- NULL

				# Quitar URLs
				rm_ind <- grep("http*", tfparty_i[,1])
				if (length(rm_ind)>0) {	tfparty_i <- tfparty_i[-rm_ind,] }
			
				# Eliminar nombre del partido
				rm_ind <- grep(parties[ind], tfparty_i[,1],ignore.case=T) 
				if (length(rm_ind)>0) {tfparty_i <- tfparty_i[-rm_ind,] }

				if (dim(tfparty_i)[1]>0) {
				
				# Sustituir tildes
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("á","a",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("é","e",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("í","i",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("ó","o",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("ú","u",x))
				
				# Eliminar emojis (por diferentes rangos)
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("[\U0001F300-\U0001F64F]","",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("[\U0001F680-\U0001F6FF]","",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("[\u2600-\u26FF]","",x))
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("[\u2700-\u27BF]","",x))
				
				# Eliminar las entradas vacías de estos emojis (si existen)
				index <- which( nchar(as.character(tfparty_i[,1]))==0 )
				if (length(index)>0) {
					tfparty_i <- tfparty_i[-index,]
				}
				
				# Eliminar símbolos (respetando @ y #)
				tfparty_i[,1] <- sapply(tfparty_i[,1], function(x) gsub("[-:;,.\'\"\\(\\)¿?¡!]","",x))
				
				}    # dim tfparty_i
			
				# Concatenar TDM
				assign( paste0("tf_",parties[ind]) , 
					rbind(tfparty_i, get( paste0("tf_",parties[ind] ) ) ) )
					
				}  # empty dataparty_i
            	
			}

			# Indicator of of mentioned parties:
			if (exists(data_ind)) {
				data_ind <- rbind( data[c(2,9:14)] , data_ind )
			} else {
				data_ind <- data[c(2,9:14)]
			}

			# Take the users that mentions a certain party
			for (i in 1:length(parties)) {
				tmp_1 <- data[complete.cases(data[parties[i]]),"name"]
				tmp_2 <- data[complete.cases(data[parties[i]]) & data$retweet==0 ,"name"] # origtweeters
				tmp_3 <- data[complete.cases(data[parties[i]]) & data$retweet!=0 ,"name"] # retweeters

				# Concatenate previous users and store them
				assign( paste0( "tweeters_",parties[i]), 
					 c( tmp_1,get( paste0("tweeters_",parties[i]) ) ) )
					 
				assign( paste0( "origtweeters_",parties[i]), 
					 c( tmp_2,get( paste0("origtweeters_",parties[i]) ) ) )

				assign( paste0( "retweeters_",parties[i]), 
					 c( tmp_3,get( paste0("retweeters_",parties[i]) ) ) )					 
			}
			
			

			# No data
		} else {	
			 mentions[data_iter,] <- 0
		}
	
		cat(paste0("Iteration ", data_iter, " in the db"),"\n")

    	# Take indicator of time the lower bound of the interval:
    	time_vec[data_iter] <- as.character(time1)

    	# Update index
    	data_iter = data_iter+1
	
		# Update
		time1 = time2

	}	# end of day queries

	# Process data for mention interactions:
	index <- which(duplicated(data_ind$id))
	if (length(index)>0) {
		data_ind <- data_ind[-index,]
	}
	
	# Graph of interactions
	doInteractions(data_ind,path)
	
	# Collapse term frequency data by parties:
	for (i in 1:length(parties)) {
		tmp <- get( paste0("tf_", parties[i]) )
		tmp1 <- tapply( tmp[,2], tmp[,1], sum )
		
		# Get it back to a data frame (ordered and with colnames as another column)
		tmp <- as.data.frame(sort(tmp1,decreasing=T))
		tmp <- cbind(rownames(tmp), tmp)
		
		# A little bit of makeup
		rownames(tmp) <- NULL
		colnames(tmp) <- c("word", "frequency")
		
		# Store and save
		assign( paste0("tf_", parties[i]), tmp )
		save( tmp , file = paste0("./data/frequent_",gsub("-","_",Sys.Date()-1),"_",parties[i],".RData") )

		cat("Doing wordclouds...","\n")
		
		# If too many mentions, take only the top 200:
		if (dim(tmp)[1]>150) {
			tmp2 = tmp[1:150,]
		} else {
			tmp2 = tmp
		}
		
		# Word cloud
		title1 = paste0("Términos asociados con ", "@",parties[i],"\n")
		title2 = paste0("Frecuencias entre ",as.character(tmp2[dim(tmp2)[1],2]),
		" y ",as.character(tmp2[1,2]),"\n")
		title3 = "@twt_partidos"
		
		png(paste0("./data/cloud_", gsub("-","_",Sys.Date()-1), "_", parties[i],".png"),520,520)
			layout(matrix(c(1,2),nrow=2),heights=c(1,5))
			par(mar=rep(0,4))
			plot.new()
			col = brewer.pal(8,"BrBG")
			text(x=0.5,y=0.5,paste0(title1,title2,title3),cex=1.5)
		
		wordcloud( tmp2[,1], tmp2[,2], 
			scale=c(4,0.8),
			random.order=F, 
			color = col, 
			main="Title",sub="Subtitle")

		dev.off()
   
	}    # loop parties

	
	# Sum unique tweets by parties:
	unique <- vector(mode="numeric")
	
	for (i in 1:length(parties)) {
		unique[i] = length( unique( get( paste0( "tweeters_",parties[i]) ) ) )
	}	
	
	# Count tweets, original tweets and retweets by users
	for (i in 1:length(parties)) {
		assign( paste0("count_tweeters_",parties[i]) , 
		  sort( table( get( paste0("tweeters_",parties[i]) ) ), decreasing=T ) )

		assign( paste0("count_origtweeters_",parties[i]) , 
		  sort( table( get( paste0("origtweeters_",parties[i]) ) ), decreasing=T ) )

		assign( paste0("count_retweeters_",parties[i]) , 
		  sort( table( get( paste0("retweeters_",parties[i]) ) ), decreasing=T ) )
		  
	}
	
    # Elaborar gráfico de top tuiteros
    # eliminar fichero con el texto de los tuits
    unlink("status_top")
	for (i in 1:length(parties)) {
		top_tweeters <- as.data.frame( head( get( paste0("count_tweeters_", parties[i]) ) ,10 ) )
		top_tweeters <- cbind(rownames(top_tweeters),top_tweeters)
		rownames(top_tweeters) <- NULL
		top_tweeters[,3]<- factor(top_tweeters[,1],as.character(top_tweeters[,1]))

  		top_origtweeters <- as.data.frame( head( get( paste0("count_origtweeters_", parties[i]) ) ,10 ) )
		top_origtweeters <- cbind(rownames(top_origtweeters),top_origtweeters)
		rownames(top_origtweeters) <- NULL
		colnames(top_origtweeters) <- c("nombre","n. tweets")
		top_origtweeters[,1]<- factor(top_origtweeters[,1],as.character(top_origtweeters[,1]))
		top_origtweeters[,3] <- factor("tweets originales"); colnames(top_origtweeters)[3] <-"tipo"
		
  		top_retweeters <- as.data.frame( head( get( paste0("count_retweeters_", parties[i]) ) ,10 ) )
		top_retweeters <- cbind(rownames(top_retweeters),top_retweeters)
		rownames(top_retweeters) <- NULL
		colnames(top_retweeters) <- c("nombre","n. tweets")
		top_retweeters[,1]<- factor(top_retweeters[,1],as.character(top_retweeters[,1]))		
		top_retweeters[,3] <- factor("retweets"); colnames(top_retweeters)[3] <-"tipo"

        fecha <- format(Sys.Date()-1,format="%d de %B")
        if (substring(fecha,1,1)=="0") {
            fecha <- substring(fecha,2)
        }

		status_top <- paste( paste0("Top tuiteros de", parties_long[i],", ",fecha,":" ), 
			paste0("@",top_tweeters[1:5,1],collapse=" ") )
	
		# Path del fichero
		path_status_top <- paste0(path,"/status_top")
		
		# Escribir el texto del tweet en el fichero
		write.table( path_status_top, file="status_top", row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)

		graf <- ggplot(top, aes(x = top[,1], y = top[,2])) +
		     geom_bar(stat = "identity",fill=parties_colorhex[i],position="dodge") +
		     theme(axis.text.x=element_text(angle=90,hjust=1) ) +
		     scale_x_discrete(name="") + 
		     ggtitle(paste0("Top 10 tuiteros de @",parties[i] ) ) +
		     theme(
		        axis.text = element_text(size =13) ,
		        plot.title = element_text(size = 15, colour = "black") , 
		        panel.grid.major = element_line(colour = "lightgray", size=0.4, linetype = "solid") ,
		        panel.grid.minor = element_line(colour="white") , 
		        panel.background = element_rect(fill = "white") ,
		        strip.background = element_rect( fill="#E6E6E6") )  + 
		     facet_wrap( ~tipo,ncol=1 ) +
		     scale_y_continuous(name="")

		# Antiguo gráfico
#		graf <- ggplot(top_tweeters, aes(x = top_tweeters[,3], y = top_tweeters[,2])) +
#		     geom_bar(stat = "identity",fill=parties_ggcolor[i],position="dodge") +
#		     theme(axis.text.x=element_text(angle=90,hjust=1) ) +
#		     scale_x_discrete(name="") + 
#		     ggtitle(paste0("Top 10 tuiteros de @",parties[i] ) ) +
#		     theme(plot.title =element_text( size=24) ) +
#		     theme(axis.text = element_text(size =16) ) +
#		     scale_y_continuous(name="")
		
		ggsave(plot=graf, 
			filename=paste0("./data/top_", gsub("-","_",Sys.Date()-1), "_", parties[i],".png"),
			width=5, height=5)
	}
	
	
	# D. frame to be stored
	data_mentions<-cbind(time_vec,mentions)
	colnames(data_mentions) <- c("time", parties_short)
	
	# Save it
	save(data_mentions, file= paste0("./data/data_",gsub("-","_",Sys.Date() - 1 ),".RData") )

	#TODO save mentions in a MySQL table:
	dbWriteTable( con, "mentions", data_mentions, append=TRUE)

	# Vector of times (text vector used for barplot only, not for time series)
	time_plot <- strftime(as.POSIXct(data_mentions[,1]), format="%H:%M")

    
	# Weekly summary (on monday)
	if (weekdays(Sys.Date()) == "lunes" ) {
	
		week1 <- as.POSIXct(paste0(Sys.Date()-7, " 00:00:00"))
		week2 <- as.POSIXct(paste0(Sys.Date(), " 00:00:00"))
		week_q <- paste0("SELECT * FROM mentions WHERE time >= ", 
		"'",as.POSIXct(week1), "'", " AND time <= ", "'", as.POSIXct(week2) , "'")
		week_res <- dbSendQuery(con,week_q)
		data_week <- fetch(week_res,-1)
		dbClearResult(week_res)

		# First column not used
		data_week[,1] <- NULL
    	
		# Get rid of duplicates
		ind_dup <- which(duplicated(as.character(data_week[,1])) )
	
		if (length(ind_dup)>0) {
			data_week <- data_week[-ind_dup,] 
		}
		
		# zoo object (we lose the datetime dimension!
		data_weekz <- zoo(data_week[,2:7],order.by=as.POSIXct(data_week[,1]) )

		# aggregate data (daily). Second columns are dates
		data_aggr <- aggregate(data_weekz,as.Date(data_week[,1]) )
    
		# Maximum of the week
		max_week <- max(data_aggr,na.rm=T)
		min_week <- min(data_aggr,na.rm=T)
		
        	png(paste0("./data/graph_",
        		gsub("-","_",Sys.Date()-1), "_all_week" ,".png"), width=900, height=600)
	
		plot(data_aggr, main= paste0("Menciones de la semana","     @twt_partidos"),
			cex.main=2.8, cex.lab = 2, cex.axis=1.8, lwd=6, 
			ylim=c(0,max_week),
    			col = parties_color,
    			xlab=NULL )
    	
    		dev.off()
    	}
    	
	# Time series of all at the same time
	cat("Doing graphs...","\n")
    
    	max_global <- max(data_mentions[,2:7],na.rm=T)
	ts_tweets <- zoo(data_mentions[,2:dim(data_mentions)[2]], order.by = as.POSIXct(data_mentions[,1]) )
    
    	png(paste0("./data/graph_",gsub("-","_",Sys.Date()-1), "_all_time" ,".png"), width=900, height=600)
    	
    	plot(ts_tweets,
	main= paste0("Menciones:   ", format(Sys.Date()-1,"%d de %B" ),"     @twt_partidos"),
    	cex.main=2.8,
    	cex.lab = 2,
	cex.axis=1.8, 
	lwd=2.3, 
	ylim=c(0,max_global),
	col = parties_color,
	xlab=NULL )
	
	dev.off()
    
	# Day count mentions
	mentions_day <- apply(data_mentions[,2:dim(data_mentions)[2]],2,function(x) {sum(x,na.rm=T)})
	file_all <- paste0("graph_",gsub("-","_",Sys.Date()-1),"_all",".png")
	path_all <- paste0(path,"/",file_all)
    
	# Paths to time series
	file_time <- paste0("graph_",gsub("-","_",Sys.Date()-1), "_all_time" ,".png")
	path_time <- paste0(path, "/", file_time)
    
	# Paths to average tweets per party
	file_mean <- paste0("graph_",gsub("-","_",Sys.Date()-1), "_mean" ,".png")
	path_mean <- paste0(path, "/", file_mean)
 
	# Paths to graph to upload (each one in a line)
	write.table(path_all, file="file_to_upload", row.names=F,col.names=F, eol="\n", quote=F)
	write.table(path_time,file="file_to_upload", row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)
	write.table(path_mean,file="file_to_upload", row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)
    
	# Paths to word clouds
	for (i in 1:length(parties)) {
		file_cloud <- paste0("cloud_", gsub("-","_",Sys.Date()-1), "_", parties[i],".png")
		path_cloud <- paste0(path, "/", file_cloud)
		write.table(path_cloud,file="file_to_upload", 
			row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)
	}

	# Paths to top tweeters
	for (i in 1:length(parties)) {
		file_top <- paste0("top_", gsub("-","_",Sys.Date()-1), "_", parties[i],".png")
		path_top <- paste0(path, "/", file_top)
		write.table(path_top,file="file_to_upload", 
		row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)
	}

	# Path to interactions
	file_inter <- paste0("inter_", gsub("-","_",Sys.Date()-1), ".png")
	path_inter <- paste0(path, "/", file_inter)
	write.table(path_inter,file="file_to_upload", row.names=F,col.names=F,append=TRUE, eol="\n", quote=F)
	
	if (weekdays(Sys.Date()) == "lunes" ) {
		file_week <- paste0("graph_",gsub("-","_",Sys.Date()-1), "_all_week" ,".png")
		path_week <- paste0(path, "/", file_week)
		write.table(path_week,file="file_to_upload", 
		row.names=F,col.names=F,append=TRUE, eol="\n",quote=F)
	}
    
	# Barplot of unique tweeters
	png( paste0("./data/graph_", gsub("-","_",Sys.Date()-1),"_mean",".png"))
	barplot(mentions_day/unique,names.arg=parties_short,
	main= paste0("Promedio tweets por usuario ",Sys.Date()-1),
	ylim=c(0,max(mentions_day/unique,na.rm=T)*1.3 ),col = parties_color )
	dev.off()
    
	# Barplot of total mentions
	png(paste0("./data/graph_",gsub("-","_",Sys.Date()-1),"_all",".png"))
	barplot(mentions_day,names.arg=parties_short,
	main= paste0("Menciones por partidos ",Sys.Date()-1),
	ylim=c(0,max(mentions_day,na.rm=T)*1.3 ),col = parties_color )
	dev.off()

	col_parties <- dim(data_mentions)[2]

  
	# Erase older entries in the database:
	txtquery2 <- paste0("DELETE FROM tweets WHERE date < NOW() - INTERVAL ", db_window, " DAY")
	cat("Borrando tweets antiguos...","\n")
	rm_query <- dbSendQuery(con, txtquery2)
	dbClearResult(rm_query)
	
	
	# Update twitter
	cat("Updating twitter account...",as.character(Sys.Date()),"\n")
	system('python update.py')
	cat("updated.","\n")

	# Remove variables:
	rm(tmp)
	rm(tmp1)
	for (i in 1:length(parties)) {
		rm(list=paste0("tf_", parties[i]))
	}
	rm(tfparty_i)
	rm(data_ind)
	
	# Mark calculations as done
	calc_done <- 1
	
	# Disconnect from database
	dbDisconnect(con)
	
	cat("Waiting til update...","\n")
	
# Not the time of calculations, wait
} else {
	Sys.sleep(60*15)
}

} # end of day
	
}    # endless loop
