	for (i in 1:length(parties)) {
		mentions_i <- mentions_ind[ complete.cases(mentions_ind[parties[i]] ), ]
		parties_others <- parties[-i]

		for (j in 1:length(parties_others)) {
        		df_mentions[i,parties_others[j]] = sum( mentions_i[parties_others[j]] , na.rm=T)
    		}

		# No mencionan a otro partido
		df_mentions[i,i] = dim(mentions_i)[1] - sum(df_mentions[i,])

	}

# Eliminar entradas diagonal inferior (matriz simétrica):
for (i in 1:length(parties)) {
    for (j in 1:length(parties)) {
    
        if (i > j ) { 
            df_mentions2[i,j] = NA
        
        } else {
            df_mentions2[i,j] = df_mentions[i,j]
        }
    
    }


}

# Translate matrix to long dataset
df_mentions3 <- melt( as.matrix(df_mentions2),na.rm=T)
