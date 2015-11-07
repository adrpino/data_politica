# data_politica
**Data Política** es un programa dedicado a medir las menciones que tiene cada partido político en Twitter, y analizar resultados.
Está escrito mayormente en el lenguaje estadístico *R*, y la comunicación con la API de Twitter con *Python*.

Consiste en dos procesos:
`store_tweets.R` que escucha la API constantemente pidiéndole tweets que mencionen directamente a los 6 principales partidos políticos españoles y sus líderes (por orden alfabético):

- Ciudadanos: **@CiudadanosCs** y **@Albert_Rivera**
- IU: **@iunida** y **@agarzon**
- Podemos: **@ahorapodemos** y **@Pablo_Iglesias_**
- PP: **@PPopular** y **@marianorajoy**
- PSOE: **@PSOE** y **@sanchezcastejon**
- UPyD: **@UPyD** y **@Herzogoff**

El texto del tweet, id, usuario y hora de creación, si es un retweet y la id del tweet retuiteado son almacenados en una base de datos *MySQL*, para su posterior análisis, por el script `process_tweets.R`

Los scripts producen los siguientes gráficos diariamente:
- Evolución temporal de las menciones diarias (datos agrupados cada 10 minuts)
- Barplots con el total de menciones de cada partido
- Promedio de menciones por usuario
- Nubes de conceptos asociadas a los tuits que mencionan a cada partido
- Top 10 usuarios que más mencionan cada partido, distinguiendo entre tweets originales y retweets.
- Interacciones (tweets que mencionan a dos partidos políticos)

Para usar los scripts se requiere acceso a la API de twitter, que puedes obtener [aquí](https://dev.twitter.com/oauth/overview).

El blog donde informamos sobre las actualizaciones y análisis no periódicos: [www.data-politica.blogspot.com.es](www.data-politica.blogspot.com.es).
