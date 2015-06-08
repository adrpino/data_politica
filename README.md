# data_politica
Data Política es un programa dedicado a medir las menciones que tiene cada partido político en twitter, y analizar resultados.
Está escrito mayormente en el lenguaje estadístico R, y la comunicación con la API de twitter con Python.

Consiste en dos procesos:
"store_tweets.R" que escucha la API constantemente pidiéndole tweets que mencionen directamente a los 6 principales partidos políticos españoles:
- PP: @PPopular
- PSOE: @PSOE
- Podemos: @ahorapodemos
- Ciudadanos: @ciudadanosCs
- IU: @iunida
- UPyD: @UPyD

El texto del tweet, id, usuario y hora de creación son almacenados en una base de datos relacional, para su posterior análisis.