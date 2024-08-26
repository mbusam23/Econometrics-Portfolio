import excel "C:\Users\User\Desktop\tesis2\Datos\Datos_tesis.xlsx", sheet("Hoja3") firstrow clear

//ssc install asdoc
gen pais=.
replace pais=1 if Country=="Peru"
replace pais=2 if Country=="Mexico"
replace pais=3 if Country=="Colombia"
replace pais=4 if Country=="Chile"

lab var pais "Pais"
lab define pais 1 "Peru" 2 "Mexico" 3 "Colombia" 4 "Chile"
lab values pais pais
tab pais

gen lpib=ln(pib)
gen lpib_sqrt= lpib^2
gen ifscode=.
replace ifscode=1 if pais==1
replace ifscode=2 if pais==2
replace ifscode=3 if pais==3
replace ifscode=4 if pais==4


						*** Preparacion de datos
xtset ifscode Year //Ponerlo como panel de datos
xtdescribe // Identifica los 4 paises en el perido de tiempo 27 años

gen ipc=ln(inflacion)

			***Generamos listas globales de variables para la regresion

//Con todos los datos de inflacion
global xlist3 tax_d lpib lpib_sqrt comercio desempleo inflacion ied transferencias gc_gobierno 

								*** Analisis Descriptivo
//Descriptivo
sum gini $xlist3
asdoc sum gini $xlist3, title(Analisis Descriptivo) 
//Correlacion
corr gini $xlist3
asdoc corr gini $xlist3, title(Analisis Correlacional) 
//asdoc corr gini $xlist3

corr gini $xlist3, c

								*** Analisis Correlacional
/*
scatter gini tax_d  if Country=="Chile" ||   scatter gini tax_d if Country == "Peru" || scatter gini tax_d if Country=="Mexico" ||   scatter gini tax_d if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Descentralización de Impuestos") xtitle("Tax Descentralización Subnacional (% G.Central)") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini tax_d.png", replace

scatter gini gc_gobierno  if Country=="Chile" ||   scatter gini gc_gobierno if Country == "Peru" || scatter gini gc_gobierno if Country=="Mexico" ||   scatter gini gc_gobierno if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Gasto del Gobierno Subnacional") xtitle("Gasto del Gobierno Subnacional (% del G. Central)") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini gc_gobierno.png", replace

scatter gini desempleo  if Country=="Chile" ||   scatter gini desempleo if Country == "Peru" || scatter gini desempleo if Country=="Mexico" ||   scatter gini desempleo if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Desempleo") xtitle("Desempleo, total (% de la población activa total)") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini desempleo.png", replace

scatter gini comercio  if Country=="Chile" ||   scatter gini comercio if Country == "Peru" || scatter gini comercio if Country=="Mexico" ||   scatter gini comercio if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Balanza Comercial") xtitle("Comercio (% del PIB)") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini comercio.png", replace

scatter gini transferencias  if Country=="Chile" ||   scatter gini transferencias if Country == "Peru" || scatter gini transferencias if Country=="Mexico" ||   scatter gini transferencias if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Transferencias") xtitle("Transferencias Netas") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini transferencias.png", replace

scatter gini lpib  if Country=="Chile" ||   scatter gini lpib if Country == "Peru" || scatter gini lpib if Country=="Mexico" ||   scatter gini lpib if Country == "Colombia" , legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y PIB") xtitle("PIB (US$ a precios actuales)") ytitle("Coeficiente de Gini (P.B.)")  
graph export "gini lpib.png", replace

scatter gini inflacion if Country=="Chile" ||   scatter gini inflacion if Country == "Peru" || scatter gini inflacion if Country=="Mexico" ||   scatter gini inflacion if Country == "Colombia", legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini e Inflación") xtitle("Inflación, precios al consumidor (% anual)") ytitle("Coeficiente de Gini (P.B.)")
graph export "gini inflacion.png", replace

scatter gini urban if Country=="Chile" ||   scatter gini urban if Country == "Peru" || scatter gini urban if Country=="Mexico" ||   scatter gini urban if Country == "Colombia", legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini y Tasa de urbanización (% Población)") xtitle("Población urbana (% del total)") ytitle("Coeficiente de Gini (P.B.)")
graph export "gini urban.png", replace

scatter gini ied if Country=="Chile" ||  scatter gini ied if Country == "Peru" ||  scatter gini ied if Country=="Mexico" ||   scatter gini ied if Country == "Colombia", legend(order(1 "Chile" 2 "Perú" 3 "Mexico" 4 "Colombia")) title("Coeficiente de Gini e Inversión Extranjera Directa") xtitle("Inversión extranjera directa, entrada neta de capital (% del PIB)") ytitle("Coeficiente de Gini (P.B.)")
graph export "gini IEB.png", replace
*/



								//Test de Raiz Unitaria - LLC
/*
En términos generales, una serie de tiempo se considera estacionaria si sus propiedades estadísticas, como la media y la varianza, son constantes a lo largo del tiempo. Esto implica que no hay tendencias sistemáticas ni patrones estacionales en los datos.

El objetivo principal de este test es determinar si una serie de tiempo es estacionaria o no, ya que la estacionaridad es un requisito fundamental

H0: Los paneles contienen una raíz unitaria (No estacionaria) 	Se rechaza si es <0.05
H1: Los paneles son estacionarios

*/


xtunitroot llc gini 
gen diff_gini= l.gini		
xtunitroot llc diff_gini								//Estacionaria

xtunitroot llc tax_d			
gen diff_tax_d = L.tax_d
xtunitroot llc diff_tax_d								//Estacionaria
		
xtunitroot llc lpib
gen diff_pib = L.lpib
xtunitroot llc diff_pib									//Estacionaria

xtunitroot llc lpib_sqrt
gen diff_lpib_sqrt =  L.lpib_sqrt
xtunitroot llc diff_lpib_sqrt							//Estacionaria

xtunitroot llc comercio
gen diff_comercio = L.comercio
xtunitroot llc diff_comercio							//Estacionaria

xtunitroot llc desempleo
gen diff_desempleo = L.desempleo
xtunitroot llc diff_desempleo							//Estacionaria

xtunitroot llc revenue_d
gen diff_revenue_d = L.revenue_d
xtunitroot llc diff_revenue_d	


xtunitroot llc gc_gobierno
gen diff_gc_gobierno = L.gc_gobierno
xtunitroot llc diff_gc_gobierno				//Creo que se saca

xtunitroot llc transferencias				//Estacionaria
xtunitroot llc inflacion 					//Estacionaria
xtunitroot llc ied							//Estacionaria
/*
xtunitroot llc urban
gen diff_urban=  L.urban
gen diff_urban2= L.diff_urban
xtunitroot llc diff_urban2					//Estacionaria
*/
/*
*/

						***Regresiones Preliminares
						
//regress 
regress gini $xlist3
asdoc regress gini $xlist3
estimates store  R_Pooled1

global xlist4 diff_tax_d transferencias diff_comercio diff_desempleo inflacion ied diff_gc_gobierno diff_pib diff_lpib_sqrt  


regress diff_gini $xlist4, cluster(ifscode) //Corrigiendo raices unitarias
asdoc regress diff_gini $xlist4, cluster(ifscode) title(Modelo corrigiendo errores)
estimates store  R_Pooled

/*
asdoc regress gini $xlist1
asdoc regress gini $xlist2
*/

						***Regresiones de Modelos de datos aninados
			
xtreg diff_gini $xlist4 , fe //El mejor a simple vista
asdoc xtreg diff_gini $xlist4 , fe  title(Modelo de Efectos Fijos)
estimates store  E_Fijos
xtreg diff_gini $xlist4 , re
asdoc xtreg diff_gini $xlist4 , re  title(Modelo de Efectis Aleatorios)
estimates store  E_Aleatorios


//Exportar Tabla	
estimates table E_Aleatorios E_Fijos R_Pooled, star
asdoc estimates table E_Aleatorios E_Fijos R_Pooled, star title(Comparando todos los modelos)



/*
*/
						***Pruebas de especificidad
						
	***Test de Breusch - Pagan (Lagrange Multiplier)* //Sacar del otro modelo
//ssc install xttest0	
//H0:  La varianza de u es cero (es fijo), por lo que es mejor realizar una estimación pool de datos
//H1:  La varianza de u no es cero (no es constante), por lo que es mejor realizar una estimación con RE
					
quietly xtreg diff_gini $xlist4 , re
xttest0		//Es mejor random Effects	
//Es mejor utilizar el test de pooled de datos ya que la Var de los residuos es 0


/*
Homocedasticidad perfecta: Un resultado de chi-cuadrado igual a 0 podría indicar que no hay heterocedasticidad en tus datos. En otras palabras, la varianza del error no cambia con las variables explicativas. Esto puede ser un resultado válido y no necesariamente problemático.
*/


*****************************************************************************
 	***Test de Hausman, especificidad

/* Test de Hausman perimte selecconar modelos entre EFECTOS FIJOS Y EFECTOS ALEATORIOS
H0:  The null hypothesis is that there're no correlation between the unique errors and the regressors in the mode (Random efeccts)
H1 :  there're correlation between the unique errors and the regressors in the mode (Fixed effects)
*/

//Se puede hacer con la version donde hay huecos para que caiga en FE			
quietly xtreg diff_gini $xlist4 , fe
estimates store  E_Fijos
quietly xtreg diff_gini $xlist4 , re 
estimates store  E_Aleatorios					

hausman E_Fijos E_Aleatorios
asdoc hausman E_Fijos E_Aleatorios
// El valor es 0.3693 > 0.05 no rechaza. En 4 paises con panel desbalanceado



//******************************************************************************
 						***Test de Wald Modificado - Test de heterocedasticidad en datos de panel 
/* Test de Wald Modificado
H0 : Homocedasticidad (Residuos esfericos- No hay Heterocedasticidad) 
H1 : Heterocedasticidad 
*/
quietly xtreg diff_gini $xlist4, fe 
xttest3  //Es Heterocedastico (por corregir)

//******************************************************************************
 						***Test de Wooldridge de autocorrelación
/* Test de Wooldridge
H0 : No Autocorrelacion de 1er orden
H1 : Autocorrelacion de 1er orden
*/

xtserial diff_gini $xlist4, output //Hay autocorrelación de 1er orden
asdoc xtserial diff_gini $xlist4, output title(Test de autocorrelación) //Hay autocorrelación de 1er orden


//Hallando el modelo de Estimadores de paneles corregido mediante errores estandares

xtpcse diff_gini $xlist4, corr(ar1) hetonly
asdoc xtpcse diff_gini $xlist4, corr(ar1) hetonly 

//Probar en la tesis normal hasta donde se puede llegar

//Probar sin argetina
//Probar con el otro indice de inflacion2 con el de precios del consumidor
//Probar sin argentina y sin precios de consumidor



