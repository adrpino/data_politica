
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

idlist =[]
textlist=[]
timelist=[]
namelist=[]

n_tweets= 50

# Loopear por todos los partidos
for item in parties:
    print 'Getting tweets from ' + item
    search = api.search(item, count=n_tweets)
    new_idlist=[]
    new_textlist=[]
    new_timelist=[]
    new_namelist=[]
    for i in range(0,len(search)):
        new_idlist.append( search[i].id )
        new_timelist.append( search[i].created_at )
        new_textlist.append( search[i].text.replace('\n', ' ' ).replace('\"','' ) )
        new_namelist.append( search[i].author.screen_name )
        
    idlist = new_idlist + idlist
    timelist = new_timelist + timelist
    textlist = new_textlist + textlist
    namelist = new_namelist + namelist


f = open('temp.txt', 'w')
for i in range(0,len(idlist)):
    f.write(str(idlist[i]) +','+ str(timelist[i]) +',' + namelist[i].encode('utf8') +','+'\"'+ textlist[i].encode('utf8') + '\"' + '\n')

f.close()

del search

