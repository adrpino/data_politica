rm(list=ls())

library("RMySQL")
library("tm")


# Conectar a la db
con <- dbConnect(MySQL(),
    user="root", password="...",
		host="localhost")

# Create database "twt_partidos"
q_dbcreate <- "CREATE DATABASE IF NOT EXISTS twt_partidos"

dbSendQuery(con, q_dbcreate)

# Usar database:
dbSendQuery(con, "USE twt_partidos")

# Tablas ya existentes:
seetables <- dbSendQuery(con, "SHOW TABLES")
df_tables <- fetch(seetables)
dbClearResult(seetables)


# Create table to store tweets if it doesn't exists
if ( sum(grepl( "tweets", df_tables[,1]))==0 ) {
 
	q_tbltweets <- "CREATE TABLE `tweets` (`row_names` INT, `id` VARCHAR(18), `date` DATETIME NOT NULL,`name` VARCHAR(16), `text` VARCHAR(140) NOT NULL, `retweet` BIT, `reply_to` VARCHAR(18), `rt_count` SMALLINT)"
		
	dbSendQuery(con, q_tbltweets)
		cat("Created \"tweets\" table","\n")
	dbClearResult(q_tbltweets)
	
	# Add index to datetime variable if it didn't existed	
	dbSendQuery(con, "CREATE INDEX ind_date ON tweets (date)")
}


# Create table to store number of mentions (if it doesn't exist)
if ( sum( grepl( "mentions", df_tables[,1]) ) ==0 ) {
	q_tblmentions <- "CREATE TABLE `mentions`(`row_names` INT, `time` DATETIME, `PP` INT, `PODEMOS` INT,`PSOE` INT, `CS` INT, `IU` INT, `UPYD` INT )"
	dbSendQuery(con,q_tblmentions)
	cat("Created \"mentions\" table","\n")
}

# Directorio
path <- "/path/to/directory"

if (!file.exists("data")) {

	dir.create("data")

}


my_stopwords <- c("a","ante","bajo","con","contra","de","desde","en","entre",
"hacia","hasta", "por", "segun","sin","sobre","tras",
"el","la","los","las","un","una","unos","unas")


# Keyword search and complete name
parties <- c("PPopular","ahorapodemos","PSOE","ciudadanosCs","iunida","UPyD")
parties_short <-c("PP","Podemos","PSOE","Cs","IU","UPyD")

parties_name <- c("Partido Popular", "Podemos", "Partido Socialista",
"Ciudadanos", "Izquierda Unida", "Union Progreso y Democracia")

parties_long <- c("l PP", " Podemos", "l PSOE", " Ciudadanos", " IU", " UPyD")

# Colores
parties_color <- c( colors()[124], colors()[98], colors()[553], colors()[90], 
	colors()[555], colors()[118])

###########################################

# Used to see the execution time
t1<-proc.time()[3]

t_loop=0 	# Loop time

# Number of repetitions
rep=1


# Variable indicated that the firs

###########################################

# This is an endless loop
while (1 < 2) {

# Take current day at 00:00 to start the counting of time
#timestart <- as.POSIXct(Sys.Date())
timestart <- as.POSIXct(paste0(Sys.Date(), " 00:00:00"))


# Until next day
while (Sys.time() < timestart+60*60*24) {

  # Recolectar tweets
	system('python tweets.py')
	
	tmp <- read.csv('temp.txt',col.names=c("id","date","name","retweet", "reply_to","rt_count","text"), stringsAsFactors=F)

	tmp$id <- as.character(tmp$id)
	tmp$date <- as.POSIXct(tmp$date) + 60*60*2

	# Back again
	tmp$date <- as.character(tmp$date)
	
	# Search for duplicated
	index <- which(duplicated(tmp$id))
	
	if (length(index)>0) {
		cat(paste0(length(index), " duplicated tweets"),"\n")
		tmp <- tmp[-index,]
	}	

	# Save to MySQL
	if (dim(tmp)[1]>0) {
		dbWriteTable(con, "tweets", tmp , append = TRUE)	
	}
	# At night do longer pauses:
	if ( (Sys.time() > timestart + 60*60*2) && (Sys.time() < timestart + 60*60*5 ) ) {
	
		Sys.sleep(240)
		
	} else {
	
		Sys.sleep(55)
	}

	t_loop = proc.time()[3]-t1

	cat(paste0("Iteration no: ", rep, ", time: ", as.character(Sys.time()) ),"\n", "\n")

	rep = rep+1


	} # End of day loop
	
}	# endless loop
