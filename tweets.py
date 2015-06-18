# coding= utf-8

import os
import tweepy
import time

# Directorio de trabajo
os.chdir(r'/path/to/directory')

# Consumer keys y tokens para acceder a la REST API
consumer_key = "..."
consumer_secret = "..."
access_token ="..."
access_token_secret="..."

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)

api = tweepy.API(auth, wait_on_rate_limit=True)

# Nombres de los partidos
parties = ["@PPopular","@ahorapodemos","@PSOE","@ciudadanosCs","@iunida","@UPyD"]

#TODO para hacer búsquedas más generales en el futuro
parties_key = ["@PPopular OR \"Partido Popular\"",
"@ahorapodemos OR \"Podemos\"",
"@PSOE OR \"Partido Socialista\"",
"@ciudadanosCs OR \"Ciudadanos\"", 
"@iunida OR \"Izquierda Unida\"", 
"@UPyD OR '\"Union Progreso y Democracia\" "]

Id =[]
text=[]
time=[]
name=[]
retweet=[]   # if is a retweet
replyto=[]   # to which this tweet is replying
rtcount=[]
#geo = []

n_tweets= 50

# Loopear por todos los partidos
for item in parties:
    print 'Getting tweets from ' + item
    search = api.search(item, count=n_tweets)
    new_Id=[]
    new_text=[]
    new_time=[]
    new_name=[]
    new_retweet=[]
    new_replyto=[]
    new_rtcount=[]
    #new_geo =[]
    for i in range(0,len(search)):
        new_Id.append( search[i].id )
        new_time.append( search[i].created_at )
        new_text.append( search[i].text.replace('\n', ' ' ).replace('\"','' ) )
        new_name.append( search[i].author.screen_name )
        new_replyto.append( search[i].in_reply_to_status_id )
        new_rtcount.append( search[i].retweet_count )
        #new_geo.append( search[i].geo )
        if search[i].text[0:2]=="RT":
            new_retweet.append( str(search[i].retweeted_status.id) )
        else:
            new_retweet.append( '0' )
                  
    Id = new_Id + Id
    time = new_time + time
    text = new_text + text
    name = new_name + name
    retweet = new_retweet + retweet
    replyto = new_replyto + replyto
    rtcount = new_rtcount + rtcount


f = open('temp.txt', 'w')
for i in range(0,len(Id)):
    f.write(str(Id[i]) +',' 
    + str(time[i]) +',' 
    + name[i].encode('utf8') +','
    + retweet[i] + ',' 
    + str(replyto[i]) + ','
    + str(rtcount[i]) + ','
    +'\"'+ text[i].encode('utf8') + '\"' + '\n' )

f.close()

del search

