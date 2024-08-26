/********************************************************************************
Sesion 1	: Margins
Autor		: Marving Bustinza Ambrosio
Institucion : Qori Capital
F. de creac : 27-05-2021
Producto	: Modelos Ordinarios (Logit y Probit)
********************************************************************************/

********************************************************************************
*********************¡**Modelos de resuesta ordenada*****¡**********************
********************************************************************************
								*Conociendolo un poquito mas
/*La variable dependiente toma un numero de valores finitos y discretos que contienen
informacion ordinal (valores que se pueden ordenar)
Ejm: Estratos socieconomicos: a) Alto (A y B)
							  b) Medio (C)
							  c) Bajo (D y E)
			 Nivel Educativo: a) Superior
							  b) Secundaria
							  c) Primaria*/
/*1	Asimismo, se asume que el intervalo entre cada categoria son iguales, hecho que no es cierto
*/

/*2	OLS no funciona porque Yt no tiene sentido cardinal.
*/

/*3 	Los modelos estandar para tratar con variables dependientes ordinales son:
*		Probit Ordenados (Asume una funcion de distribucion acumulada normal estandar)
*		Logit Ordenados	 (Asume una funcion de distribucion acumulada logistica)*/

/*4	El punto de partida de los modelos multinomiales ordenados es el modelo de 
variables latentes (no observables) , que a diferencia de nuestras variables 
dependiente real, es continua: 
Yt* (Dependiente real) <- No observada 
Yt <- continua, categorica y ordenada*/

/*5 	La estimacion de modelos de respuesta ordenada se realiza mediante Maxima Verosimilitud
*	donde se estiman los betas y los j-1 umbrales que definen el ordenamiento.
*	Asi definimos la función de probablidides condicionales (Producto de las probablidides asociadas con cada categoria)*/

/*6 Supuesto de Paralelismo
	Esta ecuacion muestra que el modelo ordenado es equivalente a j-1 regresiones
	binarias, con el supuesto que los coeficientes sean identicos a lo largo de la regresion
	ESTO IMPLICA QUE PARA CADA BETAi se asume parametros muy cercanos entre si*/
/* 	Sus coeficientes no son directamente interpretables, sin embargo sus simbolos 
	nos indican la relacion con la probabilidad de estar en la categoria mas alta 
	y la inversa de la misma en el caso de las categorias mas baja.
	ES DECIR; Si un coeficiente es positivo, entonces tiene una relacion pos con las categorias 
	mas altas y negativa con la mas baja*/

/*7	Donde los coeficientes estimados deben sumar 0, ya que consiste en un juego de suma
	cero, en lo que refiere el impacto final sobre dichas probabilidades.*/

/*8 Finalmente la interpretacion se hará a niveles de efectos marginales donde
	eligirimos hacerlos en EMM, EMP y EMEVP*/

/*9 Finalmente por finalizado debemos estimar los modelos de respuesta ordinaria 
	a través de las funciones:	ologit 	depvar [indepvars] [if] [in] [weight] [,options]
								oprobit depvar [indepvars] [if] [in] [weight] [,options]
	Donde las options mas importantes son: vce(type): Mismo que corrige los errores estandares ROBUST.*/

**Puntos Importante
* 1) El orden es importantes, el orden intrinsico es importante para la estimacion
* 2) No se puede estimar por MCO ya que este modelo no asume que la depvar pueda ser cardinal
* 3) El metodo de estimacion es a través de maxima verosimilitud(umbrales( categorias de la vardep) - betas )
* 4) Supuesto de paralelismo <- asumen intervalos iguales * Se puede estimar con j-1 modelos logit
* 5) los coeficients dependen de las x, no son directamente interpretables * pero si atraves de efectos marginales
* 6) Fucniones para estimar en stata es ologit y oprobit

							*********************
							*****Aplicación******
							*********************
*Nos interesa conocer que caracteristicas determina que un hogar pertenezca
*a cierta categoria socieconomica, a través de la siguiente ecuacion:
* Yt= miembros + sexo + edad + edad^2 + income + nededuc
/* Donde Yt son los niveles socieconomicos <- (A,B,C,D,E)
   Y los regresores (Xt) son:
	1 N* de miembros (personas) en el hogar (miembros)
	2 Edad del jefe del hogar (edad y edad^2)
	3 Ingreso mensual del hogar (S/) (Income)
	4 Sexo
	5 Nivel educativo (Primaria, Secundaria y Superior) (nededuc)*/

cls
global Datasets "E:\Sesión 1\Datasets"
global Output "E:\Sesión 1\Output"
***Modulo Sumaria
use "${Datasets}/sumaria-2017.dta", replace
							
//Factor Socieconomico
gen s_social=.
replace s_social=1 if estrsocial==5 //Siempre el valor de 1 toma la categoria de interes
replace s_social=2 if estrsocial==4
replace s_social=3 if estrsocial==3
replace s_social=4 if estrsocial==2 | estrsocial==1							
lab var s_social "Estrato Social"
lab define s_social 1 "Estrato E" 2 "Estrato D" 3 "Estrato C" 4 "Estrato A y B"	
lab values  s_social s_social							
tab s_social //Basado en la muestra
tab s_social [iw=factor07]

//Ingreso del Hogar <- inghog2d --- Ingreso neto total
gen income = inghog2d/1000 //Para expresarla en miles de soles
lab var income "Ingreso"
							
//Miembros del hogar	
clonevar miembros = mieperho						
lab var mieperho "Miembros del hogar"

keep conglome vivienda hogar ubigeo dominio estrato s_social income mieperho							
tempfile b1					
save `b1', replace		

***Modulo 200
use "${Datasets}/enaho01-2017-200.dta", replace

//Sexo
gen sexo=.
replace sexo=0 if p207==2
replace sexo=1 if p207==1
lab var sexo "Sexo"
lab define sexo 0 "Mujer" 1 "Hombre"
lab values sexo sexo
tab sexo

//Edad
rename p208a edad
lab var edad "Edad"
tab edad
keep if p203==1
keep conglome vivienda hogar sexo edad
tempfile b2
save `b2', replace

****Modulo 300
use "${Datasets}/enaho01a-2017-300.dta", replace
//Educacion
gen neduc=.
replace neduc=0 if p301a<=4 | p301a==12
replace neduc=1 if p301a==5 | p301a==6
replace neduc=2 if p301a>=7 & p301a<=11
lab var neduc "Nivel educativo"
lab define neduc2 0 "Primaria" 1 "Secundaria" 2 "Superior"
lab values neduc neduc2
tab neduc
fre p301a
keep if p203==1
keep conglome vivienda hogar neduc
tempfile b3
save `b3', replace
****UNION DE BASE DE DATOS****
use `b1'
merge 1:1 conglome vivienda hogar using `b2', keep(match) nogen
merge 1:1 conglome vivienda hogar using `b3', keep(match) nogen
 
							
									***Analisis Descriptivo***
gen muestra = 1 if (s_social!=. & mieperho!=. & sexo!=. & edad!=. & neduc!=. & income!=.)
tabstat mieperho sexo edad neduc income if muestra==1, by(s_social) stat(mean sd min max)
//Tabstat te permite sacar datos estadisticos importantes rey, donde by es un condicional y stat indicamos que tipo de variables queremos tener

** Decimos que queremos la media, sd min max segun el estrato social (en la col)
tab s_social if muestra==1
tab s_social neduc if muestra==1, nof row //Nof <- decimos que no queremos las freq sino %			
tab s_social sexo if muestra==1, nof row
table s_social if muestra==1, c(mean income)
//Para usar estpost debemos installar el paquete y establecer la ruta de saluda
findit estpost
estpost tabstat mieperho sexo edad neduc income if muestra==1, by(s_social) stat(mean sd min max) c(stat)

esttab using "${Output}/Estadisticos.csv", delimiter (",") cells ("n mean sd min max") label replace //Exporta el comando para exportar tablas, resultados, regresiones, etc.

**Aqui mario comparte la pagina de Ben Jan http://repec.sowi.unibe.ch/stata/* Trucazo csmre

				****************************************************
				*****************Analisis Econometrico**************
				****************************************************
global x c.mieperho ib0.sexo c.edad c.income ib0.neduc
ologit s_social $x if muestra==1
***Muestra viene de la linea 158, misma que dice que tomara las variables diferentes de cero

	*Los coefcientes no son directamente interpretables, donde necesitamos utilizar merge
	*Los coef nos dan una idea a través de los signos de la relacion con la variable dependiente

//Ahora compararemos los modelos
ologit s_social $x if muestra==1	//<- Estima un ologit
estimates store model_logit 		// <- Almacena la informacion de la estimacion previa "estimates store"
oprobit s_social $x if muestra==1 	//<- Estima un oprobit
estimates store model_probit 		// <- Almacena la informacion de la estimacion previa "estimates store"
estimates table model_logit model_probit, b(%6.3f) varlabel varwidth(30) modelwidth(15) star
								// <- b(%6.3f) 			---->Pone 3 decimales a los betas
								// <- varlabel			---->Pone la etiqueta de las variables
								// <- varwidth(30) 		----> La columna de las etiquetas sea mas amplia
								// <- modelwidth(15)	---->La columna de las coeficientes sea amplia
								// <- star				----> Pone las estrellas de signifi. a los resultados

						****Eleccion del modelo****
ologit s_social $x if muestra==1
fitstat, saving(mod1)
oprobit s_social $x if muestra==1
fitstat, using(mod1)
*Donde el current  es el oprobit y el saved es el ologit
*Asimismo utilizaremos el que tiene el estadisticos de AIC más bajo, eligirimos el ologit


****Supuesto de paralelismo
findit oparallel 
ologit s_social $x if muestra==1
oparallel //Tests of the parallel regression assumption
**Donde la Ho es que se cumple el supuesto de paralelismo (betas iguales)
brant, detail

*******************************+**Efectos marginales****************************
quietly ologit s_social $x if muestra==1

//Efectos Marginales Promedio
margins, dydx(*)
margins, dydx(*) predict(outcome(4))
mchange income 		//Funcion creada por usuarios de Stata que brinda mucha mas informacion

/**Para usar el mchange
ado uninstall spost9_ado //Desinstalar el spost9_ado
ado uninstall spost13_ado
search spost9_legacy 	// Descargar el legacy
search spost13_ado	//Instalado el spost13_ado */

quietly ologit s_social $x if muestra==1
margins, dydx(*)
mchange //Ahora si corre, cuando corremos desde el global de x y reinicamos stata, raro
summ income if muestra ==1
mchange income, delta(25) amount(delta)
mchange income edad, amount(sd) //Tener mucha cautela para explicar los resultados a traves del "convergeria"
mchangeplot income edad, symbols (D C B A) sig(0.1) leftmargin(10)

//Efectos marginales evaluados en la media
margins, dydx(*) predict(outcome(4)) atmeans //Solo del 4 estrato
margins, dydx(*) atmeans //Para todos los outcomes pero en medias
mchange, atmeans //mchange para todo raaa
//Efectos marginales evaluados en valores relevantes
margins, dydx(*) at(sexo==1 mieperho==3 neduc==2 edad==30) predict(outcome(4)) 
mchange, at(sexo==1 mieperho==3 neduc==2 edad==30)

***Predicciones****
*¿Cual es la proyeccion de pertener a un estrato siguiendo algunas caracteristicas?
/* 	Tener mucho cuidado con la interpretacion ya que no es un efecto causal, es por
	ello que debemos usar verbos como "esta asociado a" "podría tener un efecto en" tener mucho cuidado*/

quietly ologit s_social $x if muestra==1 
predict prD prC prB prA
lab var prD "Pr(Estrato D)"
lab var prC "Pr(Estrato C)"
lab var prB "Pr(Estrato B)"
lab var prA "Pr(Estrato A)"
dotplot prD prC prB prA, ytitle("Probabilidades") //Plotea un grafico de las prob por estrato
/**+cual es la diferencia de pedir predicciones y efectos marginales con margins?
	Pues es el uso de dydx ya que este es de efectos marginales si no pongo
	nada stata asume que estoy pidiendo predicciones*/
margins
margins, predict(outcome(1)) //Predicciones para el outcome 1
margins, at(sexo==1 neduc==2 ) atmeans
margins, at(sexo==0 neduc==2 ) atmeans //Predicciones para todos los outcomes cuando el jege de h. es mujer y tiee un nviel de educacion superior
margins, at(edad=(20(20)80)) atmeans //Predicciones en todos los outcomes cuando la edad del jefe de h. es de 20, 40,60 y 80 y las demas variables estan en su media
*Los resultados que te da es para los 4 outcomes y lo combina con los 4 posibles resultados de la edad(20,40,60 y 80)*
marginsplot


***Modelo de conteo <- Toman valores un numero limitado de valores (toma valores no negativo )				 							 