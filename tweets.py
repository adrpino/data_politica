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

# Array que almacena ids de los últimos tweets
since_Id=[]
if os.path.isfile('since_id.txt')==True:
    f = open('since_id.txt','r')
    for line in f:
        since_Id.append(line.replace('\n',''))
        
else:
    since_Id = [0,0,0,0,0,0]


Id =[]
text=[]
date=[]
name=[]
retweet=[]   # if is a retweet
replyto=[]   # to which this tweet is replying
rtcount=[]
since_Id2=[]    # if 
#geo = []

n_tweets= 50

# Loopear por todos los partidos
for ind, item in enumerate(parties):
#    search = api.search(item, count=n_tweets,since_id =since_Id[ind] )
    search = api.search(item, count=n_tweets)    
    new_Id=[]
    new_text=[]
    new_date=[]
    new_name=[]
    new_retweet=[]
    new_replyto=[]
    new_rtcount=[]
    #new_geo =[]
    for i in range(0,len(search)):
        if (search[i].id>since_Id[ind]):    # Tweets is newer than last one stored
            new_Id.append( search[i].id )
            new_date.append( search[i].created_at )
            new_text.append( search[i].text.replace('\n', ' ' ).replace('\"','' ) )
            new_name.append( search[i].author.screen_name )
            new_replyto.append( search[i].in_reply_to_status_id )
            new_rtcount.append( search[i].retweet_count )
            #new_geo.append( search[i].geo )
            if hasattr(search[i],"retweeted_status"):
                new_retweet.append( str(search[i].retweeted_status.id) )
            else:
                new_retweet.append( '0' )


    print str(len(new_Id)) + " new tweets from " + item       
    Id = new_Id + Id
    date = new_date + date
    text = new_text + text
    name = new_name + name
    retweet = new_retweet + retweet
    replyto = new_replyto + replyto
    rtcount = new_rtcount + rtcount
    
    if len(new_Id)>0:                       # si hay tweets nuevos
        since_Id2.append(new_Id[0])
    else:                                   # si no
        since_Id2.append(since_Id[ind])
    
    
    #geo = new_geo + geo
#   del search

#    time.sleep(15)

# Actualizar
since_Id = since_Id2

f = open('since_id.txt','w')
for i in range(0,len(parties)):
    f.write( str(since_Id[i]) + '\n' )

f.close()


f = open('temp.txt', 'w')
for i in range(0,len(Id)):
    f.write(str(Id[i]) +',' 
    + str(date[i]) +',' 
    + name[i].encode('utf8') +','
    + retweet[i] + ',' 
    + str(replyto[i]) + ','
    + str(rtcount[i]) + ','
    +'\"'+ text[i].encode('utf8') + '\"' + '\n' )

f.close()

del search

