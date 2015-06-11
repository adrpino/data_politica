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


f=open("file_to_upload")
paths = f.readlines()

# Remove EOL in paths (last char)
path_all  = paths[0][0:len(paths[0])-1]
path_time = paths[1][0:len(paths[1])-1]
path_mean = paths[2][0:len(paths[2])-1]

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


# Case of week summary
if len(paths)==16:
	path_week       = paths[15][0:len(paths[15])-1]


# Date
ystday = date.today()- timedelta(1)

# Status
status_all= "Menciones por partidos: " + '%s/%s/%s' % ( ystday.day, ystday.month, ystday.year) + " #DataPolitica_resumen"

status_time = "Menciones por horas : " + '%s/%s/%s' % ( ystday.day, ystday.month, ystday.year) + " #DataPolitica_dia"

status_mean = "Promedio tweets por usuario: " + '%s/%s/%s' % ( ystday.day, ystday.month, ystday.year) + " #DataPolitica_media"

status_week = "Resumen de la semana política en twitter"

status_wc_pp = "Qué dice la gente sobre el #PP: " + '%s/%s/%s'% ( ystday.day, ystday.month, ystday.year)
status_wc_podemos = "Qué dice la gente sobre #Podemos: "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_wc_psoe = "Qué dice la gente sobre el #PSOE: "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_wc_cs = "Qué dice la gente sobre #Ciudadanos: "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_wc_iu = "Qué dice la gente sobre #IU: " +'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_wc_upyd = "Qué dice la gente sobre #UPyD: " +'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)

status_top_pp = "Top 10 tuiteros del #PP #DataPolitica_TopPP " + '%s/%s/%s'% ( ystday.day, ystday.month, ystday.year)
status_top_podemos ="Top 10 tuiteros de #Podemos #DataPolitica_TopPodemos "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_top_psoe = "Top 10 tuiteros del #PSOE #DataPolitica_TopPSOE "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_top_cs = "Top 10 tuiteros de #Ciudadanos #DataPolitica_TopCs "+'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_top_iu = "Top 10 tuiteros de #IU #DataPolitica_TopIU " +'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)
status_top_upyd ="Top 10 tuiteros de #UPyD #DataPolitica_TopUPyD " +'%s/%s/%s' % ( ystday.day, ystday.month, ystday.year)



# Update
api.update_with_media(path_wc_pp       , status = status_wc_pp)
api.update_with_media(path_wc_podemos  , status = status_wc_podemos)
api.update_with_media(path_wc_psoe     , status = status_wc_psoe)
api.update_with_media(path_wc_cs       , status = status_wc_cs)
api.update_with_media(path_wc_iu       , status = status_wc_iu)
api.update_with_media(path_wc_upyd     , status = status_wc_upyd)

api.update_with_media(path_top_pp      , status = status_top_pp)
api.update_with_media(path_top_podemos , status = status_top_podemos)
api.update_with_media(path_top_psoe    , status = status_top_psoe)
api.update_with_media(path_top_cs      , status = status_top_cs)
api.update_with_media(path_top_iu      , status = status_top_iu)
api.update_with_media(path_top_upyd    , status = status_top_upyd)


api.update_with_media(path_mean, status = status_mean)
api.update_with_media(path_all , status = status_all)
api.update_with_media(path_time, status = status_time)

if len(paths)==16:
    api.update_with_media(path_week, status = status_week)


f.close()