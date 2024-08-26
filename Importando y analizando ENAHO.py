import os 
import pandas as pd
    #Cambiando de directorio
os.chdir('F:/00000db')

main='F:/00000db'
'''mportando bases de datos'''


    #ENAHO
Sumaria=(main+'/sumaria-2023.dta')
Sumaria_db=pd.read_stata(Sumaria)
Educacion=(main+'/enaho01a-2023-300.dta')
Educacion_db=pd.read_stata(Educacion,convert_categoricals=False)

#Determinar la clase, dimensiones y nombres de las variables de las bases de datos

Sumaria_db.head() #Ver los primeros datos
print(Sumaria_db.columns) #Ver el nombre de las columnas
Educacion_db.tail() #Ver los ultimos datos


'''Saber la clase del tipo de variable'''
Sumaria_db.__class__
Sumaria_db.shape #Te dice la forma de la base de datos -El Tamaño-

'''Union de bases de datos'''

    #MERGE
    #Hogar a Personas                   on=['conglome','vivienda','hogar']         
    #Personas a personas                on=['conglome','vivienda','hogar','codpersona']

data= pd.merge(Sumaria_db,Educacion_db,
               how='outer',
               on=['conglome','vivienda','hogar']
    )


'''ANALISIS DESCRIPTIVO'''

#Como hacemos resumenes en Python
'''Variables Cuantitativas'''
resumen= data.describe() #Muestra mean, std,min, max, percentiles, etc.
'''Variables Cualitativas'''
resumen2= data.groupby(['pobreza']).count()
resumen3= data.groupby(['pobreza']).sum()



#Ejercicio - CREA UNA LISTA CON VAIRABLES

list=[ 'conglome', 'vivienda', 'hogar', 'mes_x', 'dominio_x', 
'estrato_x', 'mieperho', 'inghog2d', 'gashog2d', 'linpe', 'linea', 'pobreza', 'estrsocial', 
'codperso', 'codinfor', 'p300a', 'p301a', 'p301d', 'p207', 'p208a', 'p209']

#Seleccionando las variables de la lista y creamos un nuevo dataframe con esta info
df=data[list] #Nos quedamos con las variables que nos interesa nda más

'''Generar tablas para las variables domino,nivel de pobreza y sexo'''
df['dominio_x'].describe() #Te da info de la variable estadisticamente


'''CREA UNA TABLA'''
    #Hazlo con listas siempre
'''ONE WAY'''
df.groupby(['dominio_x',]).count()
'''ONE WAY W/ 2 VARIABLES'''
df.groupby(['dominio_x','pobreza']).count()
'''ONE WAY W/ +2 VARIABLES'''
df.groupby(['dominio_x','pobreza','estrato_x']).count()

'''TWO WAY'''
tway=pd.crosstab(df['dominio_x'],df['pobreza'] )
tway.to_excel('resultado_crosstab.xlsx')
 

'''Separar una base de datos en 2'''
#Indexacion Natural
df1=df[0:55000][['dominio_x','pobreza']]
df2=df[55000:][['dominio_x','pobreza']]

#Indexacion por enteros
df21=df.iloc[0      :55000  ,[4,8]]
df22=df.iloc[55000  :       ,[4,9]]

#Indexacion por labels
df31=df.loc[0       :55000  ,['dominio_x','pobreza']]
df32=df.loc[55001   :       ,['dominio_x','pobreza']]

''''Extra algunas filas y las columnas que te interesa'''
dfga= df[0:100][['dominio_x','pobreza']]


'''VOLVER A UNIR DOS BASES DE DATOS SEPARADAS'''
df1_r= pd.concat([df1,df2])

'''Filtrar una base de datos en las que codperso=01'''
df_h = df[df['codperso']=='01']
df_h2= df[df.codperso=='01']

'''GENERAR UNA NUEVA VARIABLE'''
#Creando una nueva columna con el n° de filas que tiene por defecto
df_h.loc[:,'gasto_mensual']=df_h.loc[:,'gashog2d']/12








