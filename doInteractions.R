require("ggplot2")
require("reshape2")

doInteractions <- function(data_ind,path) {

parties <- c("PPopular","ahorapodemos","PSOE","ciudadanosCs","iunida","UPyD")
df_mentions <- data.frame(replicate(6,rep(0,6)),row.names=parties)
colnames(df_mentions) <- parties
df_mentions2 <- df_mentions

	for (i in 1:length(parties)) {
		mentions_i <- mentions_ind[ complete.cases(mentions_ind[parties[i]] ), ]
		parties_others <- parties[-i]

		for (j in 1:length(parties_others)) {
        		df_mentions[i,parties_others[j]] = sum( mentions_i[parties_others[j]] , na.rm=T)
    		}

		# No mencionan a otro partido
		df_mentions[i,i] = dim(mentions_i)[1] - sum(df_mentions[i,])

	}

	# Get rid of lower triangular part of the matrix (symmetric):
	for (i in 1:length(parties)) {
    		for (j in 1:length(parties)) {
	    		if (i > j) { 
        	    		df_mentions2[i,j] = NA
			} else {
				df_mentions2[i,j] = df_mentions[i,j]
			}
    
	    	}
	}

	# Translate matrix to long dataset
	df_mentions3 <- melt( as.matrix(df_mentions2),na.rm=T)

	# Get rid of the count of those who only mention themselves
	df_mentions4 <- df_mentions3
	index <- which(df_mentions4$Var1==df_mentions4$Var2)
	df_mentions4 <- df_mentions4[-index,]

	interaction <- ggplot(df_mentions4, aes(Var1,Var2)) + geom_tile(aes(fill=value))+
		scale_fill_gradient(low = "white", high = "#339966") +
		scale_x_discrete(name="") + 
		scale_y_discrete(name="") +
		theme(axis.text.x=element_text(angle=90,hjust=1), 
		plot.title = element_text(size = 16, colour = "black", vjust = 1) ,
		legend.title = element_blank() ) +
		ggtitle(paste0("Interacciones entre partidos" ) ) 

	ggsave(plot=interaction,filename=paste0(path,"/data/heat_", 
		gsub("-","_",Sys.Date()-1), ".png"),width=4.5,height=4)

}
