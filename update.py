# coding= utf-8

# Upload graphs to @twt_partidos

import os
import tweepy
#import re     # for regular expressions
#from os import listdir
#from os.path import isfile, join
from datetime import date, timedelta      # dates
path = r'/path/to/directory'
os.chdir(path)
cons_key = '...'
cons_secret = '...'
access_token =  '...'
access_token_secret = '...'
auth = tweepy.OAuthHandler(cons_key, cons_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth, wait_on_rate_limit=True)

# Paths to files to upload
f1 = open("file_to_upload")
paths = f1.readlines()

# Statuses of top tweeters
f2 = open("status_top")
status_top = f2.readlines()

# Statuses of top concepts
f3=open("status_concepts_top")
status_concepts_top = f3.readlines()

# Remove EOL in paths (last char)
path_all         = paths[0][0:len(paths[0])-1]
path_time        = paths[1][0:len(paths[1])-1]
path_mean        = paths[2][0:len(paths[2])-1]

path_wc_pp       = paths[3][0:len(paths[3])-1]
path_wc_podemos  = paths[4][0:len(paths[4])-1]
path_wc_psoe     = paths[5][0:len(paths[5])-1]
path_wc_cs       = paths[6][0:len(paths[6])-1]
path_wc_iu       = paths[7][0:len(paths[7])-1]
path_wc_upyd     = paths[8][0:len(paths[8])-1]

path_top_pp      = paths[9][0:len(paths[9])-1]
path_top_podemos = paths[10][0:len(paths[10])-1]
path_top_psoe    = paths[11][0:len(paths[11])-1]
path_top_cs      = paths[12][0:len(paths[12])-1]
path_top_iu      = paths[13][0:len(paths[13])-1]
path_top_upyd    = paths[14][0:len(paths[14])-1]

path_inter       = paths[15][0:len(paths[15])-1]


# Case of week summary
if len(paths)==17:
	path_week = paths[16][0:len(paths[16])-1]

# Date
ystday = date.today()- timedelta(1)
date_ystday = '%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)

# Status
status_all= "Menciones por partidos: " + date_ystday + " #DataPolitica_resumen"
status_time = "Menciones por horas: " + date_ystday + " #DataPolitica_dia"
status_mean = "Promedio tweets por usuario: " + date_ystday + " #DataPolitica_media"
status_week = "Resumen de la semana política en twitter #DataPolitica_semana"

# Statuses of top concepts
status_concepts_top_pp      = status_concepts_top[0][0:len(status_concepts_top[0])-1]
status_concepts_top_podemos = status_concepts_top[1][1:len(status_concepts_top[1])-1]
status_concepts_top_psoe    = status_concepts_top[2][2:len(status_concepts_top[2])-1]
status_concepts_top_cs      = status_concepts_top[3][3:len(status_concepts_top[3])-1]
status_concepts_top_iu      = status_concepts_top[4][4:len(status_concepts_top[4])-1]
status_concepts_top_upyd    = status_concepts_top[5][5:len(status_concepts_top[5])-1]

# Paths to status
status_top_pp      = status_top[0][0:len(status_top[0])-1]
status_top_podemos = status_top[1][0:len(status_top[1])-1]
status_top_psoe    = status_top[2][0:len(status_top[2])-1]
status_top_cs      = status_top[3][0:len(status_top[3])-1]
status_top_iu      = status_top[4][0:len(status_top[4])-1]
status_top_upyd    = status_top[5][0:len(status_top[5])-1]

status_inter = "Interacciones entre tweets: " + date_ystday + " #DataPolitica_Interacciones"


# Update
# Wordclouds
api.update_with_media(path_wc_pp       , status = status_concepts_top_pp      )
api.update_with_media(path_wc_podemos  , status = status_concepts_top_podemos )
api.update_with_media(path_wc_psoe     , status = status_concepts_top_psoe    )
api.update_with_media(path_wc_cs       , status = status_concepts_top_cs      )
api.update_with_media(path_wc_iu       , status = status_concepts_top_iu      )
api.update_with_media(path_wc_upyd     , status = status_concepts_top_upyd    )

# Top tweeters
api.update_with_media(path_top_pp      , status = status_top_pp      )
api.update_with_media(path_top_podemos , status = status_top_podemos )
api.update_with_media(path_top_psoe    , status = status_top_psoe    )
api.update_with_media(path_top_cs      , status = status_top_cs      )
api.update_with_media(path_top_iu      , status = status_top_iu      )
api.update_with_media(path_top_upyd    , status = status_top_upyd    )

api.update_with_media(path_mean , status = status_mean  )
api.update_with_media(path_all  , status = status_all   )
api.update_with_media(path_time , status = status_time  )
api.update_with_media(path_inter, status = status_inter )

if len(paths)==17:
    api.update_with_media(path_week, status = status_week)


# Close connections
f1.close()
f2.close()
f3.close()
