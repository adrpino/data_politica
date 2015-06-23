doHeatmap <- function(data_ind,path) {

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

	interaction <- ggplot(df_mentions3, aes(Var1,Var2)) + geom_tile(aes(fill=value))+
    		scale_fill_gradient(low = "white", high = "steelblue") +
    		guides(fill=FALSE) +
		scale_x_discrete(name="") + 
		scale_y_discrete(name="") +
		theme(axis.text.x=element_text(angle=90,hjust=1) ) +
		ggtitle(paste0("Interacciones entre partidos" ) )

	ggsave(plot=interaction,filename=paste0(path,"/heat.png"),width=5,height=5)
	
}
