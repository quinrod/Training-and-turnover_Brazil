* criacao: 07/10/2017
* ultima alteracao: 07/10/2017
* stata Version: 14
* delimited space: 4
* Objetivo: Definir funcoes para validar os principais codigos de identificacao
*			e classificacao usados em no pais
/*=======================================================================*/
/*=======================================================================*/

* Programa para checar CPF
* validar_cpf cpf if length(cpf)==11

cap program drop validar_cpf
program define validar_cpf
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 11 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_11
		qui gen aux_diff_11=aux_tamanho!=11 `if'
		gsort -aux_diff_11

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 11 digits."  
			error
		}
		if `=aux_diff_11[1]'==1{
			di as red "There is cpf shorter/larger than 11 digits."  
			error
		}

		cap drop aux_diff_11
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cpf_valido
	cap drop aux_d_1
	cap drop aux_d_2
	cap drop fist_digit
	cap drop second_digit
	cap drop resto_divisao_11_first
	cap drop resto_divisao_11_second
	
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist',1,1)) * 10 + ///
							 real(substr(`varlist',2,1)) *  9 + ///
							 real(substr(`varlist',3,1)) *  8 + ///
							 real(substr(`varlist',4,1)) *  7 + ///
							 real(substr(`varlist',5,1)) *  6 + ///
							 real(substr(`varlist',6,1)) *  5 + ///
							 real(substr(`varlist',7,1)) *  4 + ///
							 real(substr(`varlist',8,1)) *  3 + ///
							 real(substr(`varlist',9,1)) *  2   `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int fist_digit=11-resto_divisao_11_first
		qui replace  fist_digit=0 							if resto_divisao_11_first<2

		qui drop resto_divisao_11_first
		* Calculo segundo digito verificador
		qui gen  int aux_d_2= 	 real(substr(`varlist',1,1)) 	* 11 + ///
								 real(substr(`varlist',2,1)) 	* 10 + ///
								 real(substr(`varlist',3,1)) 	*  9 + ///
								 real(substr(`varlist',4,1)) 	*  8 + ///
								 real(substr(`varlist',5,1)) 	*  7 + ///
								 real(substr(`varlist',6,1)) 	*  6 + ///
								 real(substr(`varlist',7,1)) 	*  5 + ///
								 real(substr(`varlist',8,1)) 	*  4 + ///
								 real(substr(`varlist',9,1)) 	*  3 + ///
											fist_digit	*  2	`if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_second= mod(aux_d_2,11)

		qui drop aux_d_2 
		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen   int second_digit=11-resto_divisao_11_second
		qui replace   second_digit=0 							if resto_divisao_11_second<2

		qui drop resto_divisao_11_second
		* Gerando digito verificador
		qui gen cpf_valido=substr(`varlist',10,2)==string(fist_digit) +string(second_digit)
		qui replace cpf_valido=0 if `varlist'=="0000000000"
		
		qui drop fist_digit second_digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values cpf_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called cpf_valido"
		di as white 	"This table used this filter => [`if']"
		tab cpf_valido `if'
		
		* Site reference
		* http://www.macoratti.net/alg_cpf.htm
		* http://www.geradorcpf.com/algoritmo_do_cpf.htm
end program


*************** Funcao validar PIS ****************************
* validar_pis pis if length(pis)==11

cap program drop validar_pis
program define validar_pis
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
		
		*Checando se o pis tem sempre 11 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho
		
		cap drop aux_diff_11
		qui gen aux_diff_11=aux_tamanho!=11 `if'
		gsort -aux_diff_11
		
		if r(r)!=1 {
			di as red "There is pis shorter/larger than 11 digits."  
			error
		}
		if `=aux_diff_11[1]'==1{
			di as red "There is pis shorter/larger than 11 digits."  
			error
		}
		
		cap drop aux_diff_11
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop pis_valido
	cap drop aux_d_1
	cap drop digit
	cap drop resto_divisao_11
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist', 1,1)) *  3 + ///
							 real(substr(`varlist', 2,1)) *  2 + ///
							 real(substr(`varlist', 3,1)) *  9 + ///
							 real(substr(`varlist', 4,1)) *  8 + ///
							 real(substr(`varlist', 5,1)) *  7 + ///
							 real(substr(`varlist', 6,1)) *  6 + ///
							 real(substr(`varlist', 7,1)) *  5 + ///
							 real(substr(`varlist', 8,1)) *  4 + ///
							 real(substr(`varlist', 9,1)) *  3 + ///
							 real(substr(`varlist',10,1)) *  2 `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11 = mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int digit=11-resto_divisao_11	
		qui replace  digit=0 				   if resto_divisao_11<2

		qui drop resto_divisao_11	
		
		* Gerando digito verificador
		qui gen pis_valido=substr(`varlist',11,1)==string(digit)
		qui replace pis_valido=0 if `varlist'=="0000000000"
		
		qui drop digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values pis_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called pis_valido"
		di as white 	"This table used this filter => [`if']"
		tab pis_valido `if'
		
		* Site reference
		* http://www.macoratti.net/alg_pis.htm
end program


*************** Funcao validar CNPJ ****************************
* validar_cnpj cnpj_cei if length(cnpj_cei)==14
* validar_cnpj cnpj_cei if length(cnpj_cei)==14

cap program drop validar_cnpj
program define validar_cnpj
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cnpj tem sempre 14 digitos
		*local varlist "cnpj"
		di "`varlist'"
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho
		tab aux_tamanho

		cap drop aux_diff_14
		qui gen aux_diff_14=aux_tamanho!=14 `if'
		gsort -aux_diff_14
		cap tab aux_diff_14
		if r(r)!=1 {
			di as red "There is cnpj shorter/larger than 14 digits."  
			error
		}
		if `=aux_diff_14[1]'==1{
			di as red "There is cnpj shorter/larger than 14 digits."  
			error
		}

		cap drop aux_diff_14
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cnpj_valido ***
	cap drop cnpj_valido
	cap drop aux_d_1
	cap drop aux_d_2
	cap drop fist_digit
	cap drop second_digit
	cap drop resto_divisao_11_first
	cap drop resto_divisao_11_second
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist', 1,1))  *  5 + ///
							 real(substr(`varlist', 2,1))  *  4 + ///
							 real(substr(`varlist', 3,1))  *  3 + ///
							 real(substr(`varlist', 4,1))  *  2 + ///
							 real(substr(`varlist', 5,1))  *  9 + ///
							 real(substr(`varlist', 6,1))  *  8 + ///
							 real(substr(`varlist', 7,1))  *  7 + ///
							 real(substr(`varlist', 8,1))  *  6 + ///
							 real(substr(`varlist', 9,1))  *  5 + ///
							 real(substr(`varlist', 10,1)) *  4 + ///
							 real(substr(`varlist', 11,1)) *  3 + ///
							 real(substr(`varlist', 12,1)) *  2 `if'	
 						 
		*Resto da divisao por 11
		qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int fist_digit=11-resto_divisao_11_first
		qui replace  fist_digit=0 							if resto_divisao_11_first<2

		qui drop resto_divisao_11_first
		* Calculo segundo digito verificador
		qui gen  int aux_d_2= 	 real(substr(`varlist', 1,1))  	*  6 + ///
								 real(substr(`varlist', 2,1))  	*  5 + ///
								 real(substr(`varlist', 3,1))  	*  4 + ///
								 real(substr(`varlist', 4,1))  	*  3 + ///
								 real(substr(`varlist', 5,1))  	*  2 + ///
								 real(substr(`varlist', 6,1))  	*  9 + ///
								 real(substr(`varlist', 7,1))  	*  8 + ///
								 real(substr(`varlist', 8,1))  	*  7 + ///
								 real(substr(`varlist', 9,1))  	*  6 + ///
								 real(substr(`varlist', 10,1)) 	*  5 + ///
								 real(substr(`varlist', 11,1)) 	*  4 + ///
								 real(substr(`varlist', 12,1)) 	*  3 + ///
												fist_digit		*  2  `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_second= mod(aux_d_2,11)

		qui drop aux_d_2 
		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen   int second_digit=11-resto_divisao_11_second
		qui replace   second_digit=0 							if resto_divisao_11_second<2

		qui drop resto_divisao_11_second
		* Gerando digito verificador
		qui gen cnpj_valido=substr(`varlist',13,2)==string(fist_digit) +string(second_digit)
		qui replace cnpj_valido=0 if `varlist'=="0000000000000"
		
		qui drop fist_digit second_digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values cnpj_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called cnpj_valido"
		di as white 	"This table used this filter => [`if']"
		tab cnpj_valido `if'
		
		* Site reference
		*http://www.macoratti.net/alg_cnpj.htm
end program

  
cap program drop validar_cnae10
program define validar_cnae10
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 5 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_5
		qui gen aux_diff_5=aux_tamanho!=5 `if'
		gsort -aux_diff_5

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}
		if `=aux_diff_5[1]'==1{
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}

		cap drop aux_diff_5
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cnae10_valido
	cap drop aux_d_1
	cap drop fist_digit
	cap drop resto_divisao_11_first
	
	* Begin algorithm
	qui gen int aux_d_1= real(substr(`varlist',1,1)) *  5 + ///
						 real(substr(`varlist',2,1)) *  4 + ///
						 real(substr(`varlist',3,1)) *  3 + ///
						 real(substr(`varlist',4,1)) *  2   `if'

	*Resto da divisao por 11
	qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
	qui drop aux_d_1

	* Se o resto da divisao for menor que 2, entao o digito e zero
	qui gen  int fist_digit=11-resto_divisao_11_first
	qui replace  fist_digit=0 							if resto_divisao_11_first<2

	qui drop resto_divisao_11_first
	
	* Gerando digito verificador
	qui gen cnae10_valido=substr(`varlist',5,1)==string(fist_digit)
	qui replace cnae10_valido=0 if `varlist'=="00000"
	
	qui drop fist_digit
	qui label define rotulo 1 "valido" 0 "invalido",replace
	qui label values cnae10_valido rotulo
	
	*Mesagem ao usuario
	di as yellow 	"The check is done. That was created a variable called cnae10_valido"
	di as white 	"This table used this filter => [`if']"
	tab cnae10_valido `if'
end program


cap program drop validar_cnae20
program define validar_cnae20
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 5 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_5
		qui gen aux_diff_5=aux_tamanho!=5 `if'
		gsort -aux_diff_5

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}
		if `=aux_diff_5[1]'==1{
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}

		cap drop aux_diff_5
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cnae20_valido
	cap drop aux_d_1
	cap drop fist_digit
	cap drop resto_divisao_11_first
	
	* Begin algorithm
	qui gen int aux_d_1= real(substr(`varlist',1,1)) *  5 + ///
						 real(substr(`varlist',2,1)) *  4 + ///
						 real(substr(`varlist',3,1)) *  3 + ///
						 real(substr(`varlist',4,1)) *  2   `if'

	*Resto da divisao por 11
	qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
	qui drop aux_d_1

	* Se o resto da divisao for menor que 2, entao o digito e zero
	qui gen  int fist_digit=11-resto_divisao_11_first
	qui replace  fist_digit=0 							if fist_digit>=10
	
	*Para a CNAE 2.0 é utilizado o módulo 11 + uma unidade.
	replace  fist_digit=fist_digit+1
	replace  fist_digit=0			if fist_digit==10
	
	*qui drop resto_divisao_11_first
	
	* Gerando digito verificador
	qui gen cnae20_valido=substr(`varlist',5,1)==string(fist_digit)
	qui replace cnae20_valido=0 if `varlist'=="00000"
	
	*qui drop fist_digit
	qui label define rotulo 1 "valido" 0 "invalido",replace
	qui label values cnae20_valido rotulo
	
	*Mesagem ao usuario
	di as yellow 	"The check is done. That was created a variable called cnae20_valido"
	di as white 	"This table used this filter => [`if']"
	tab cnae20_valido `if'
	
end program


/* Validar  codigo cnae-*/
 *cd "C:\Users\Leandro-ASUS\Dropbox\Trabalhos Profissionais\Rotinas de programacao relevantes\STATA\criacao de ado e funcao\Validacao de indentificadores"
* Base de teste
 *use estrutura_cnae10,clear
 
 *validar_cnae10 cnae10 if length(cnae10)==5
 *validar_cnae20 cnae10 if length(cnae10)==5
 
 *use estrutura_cnae20,clear
 
 *validar_cnae10 cnae20 if length(cnae20)==5
 *validar_cnae20 cnae20 if length(cnae20)==5
* autor: Leandro Justino
* email: leandrojpveloso@gmail.com
* criacao: 07/10/2017
* ultima alteracao: 07/10/2017
* stata Version: 14
* delimited space: 4
* Objetivo: Definir funcoes para validar os principais codigos de identificacao
*			e classificacao usados em no pais
/*=======================================================================*/
/*=======================================================================*/

* Link sobre digito verificador e prinpais algoritmos
* https://pt.wikipedia.org/wiki/D%C3%ADgito_verificador

* Programa para checar CPF
* validar_cpf cpf if length(cpf)==11

cap program drop validar_cpf
program define validar_cpf
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 11 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_11
		qui gen aux_diff_11=aux_tamanho!=11 `if'
		gsort -aux_diff_11

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 11 digits."  
			error
		}
		if `=aux_diff_11[1]'==1{
			di as red "There is cpf shorter/larger than 11 digits."  
			error
		}

		cap drop aux_diff_11
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cpf_valido
	cap drop aux_d_1
	cap drop aux_d_2
	cap drop fist_digit
	cap drop second_digit
	cap drop resto_divisao_11_first
	cap drop resto_divisao_11_second
	
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist',1,1)) * 10 + ///
							 real(substr(`varlist',2,1)) *  9 + ///
							 real(substr(`varlist',3,1)) *  8 + ///
							 real(substr(`varlist',4,1)) *  7 + ///
							 real(substr(`varlist',5,1)) *  6 + ///
							 real(substr(`varlist',6,1)) *  5 + ///
							 real(substr(`varlist',7,1)) *  4 + ///
							 real(substr(`varlist',8,1)) *  3 + ///
							 real(substr(`varlist',9,1)) *  2   `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int fist_digit=11-resto_divisao_11_first
		qui replace  fist_digit=0 							if resto_divisao_11_first<2

		qui drop resto_divisao_11_first
		* Calculo segundo digito verificador
		qui gen  int aux_d_2= 	 real(substr(`varlist',1,1)) 	* 11 + ///
								 real(substr(`varlist',2,1)) 	* 10 + ///
								 real(substr(`varlist',3,1)) 	*  9 + ///
								 real(substr(`varlist',4,1)) 	*  8 + ///
								 real(substr(`varlist',5,1)) 	*  7 + ///
								 real(substr(`varlist',6,1)) 	*  6 + ///
								 real(substr(`varlist',7,1)) 	*  5 + ///
								 real(substr(`varlist',8,1)) 	*  4 + ///
								 real(substr(`varlist',9,1)) 	*  3 + ///
											fist_digit	*  2	`if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_second= mod(aux_d_2,11)

		qui drop aux_d_2 
		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen   int second_digit=11-resto_divisao_11_second
		qui replace   second_digit=0 							if resto_divisao_11_second<2

		qui drop resto_divisao_11_second
		* Gerando digito verificador
		qui gen cpf_valido=substr(`varlist',10,2)==string(fist_digit) +string(second_digit)
		qui replace cpf_valido=0 if `varlist'=="0000000000"
		
		qui drop fist_digit second_digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values cpf_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called cpf_valido"
		di as white 	"This table used this filter => [`if']"
		tab cpf_valido `if'
		
		* Site reference
		* http://www.macoratti.net/alg_cpf.htm
		* http://www.geradorcpf.com/algoritmo_do_cpf.htm
end program


*************** Funcao validar PIS ****************************
* validar_pis pis if length(pis)==11

cap program drop validar_pis
program define validar_pis
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
		
		*Checando se o pis tem sempre 11 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho
		
		cap drop aux_diff_11
		qui gen aux_diff_11=aux_tamanho!=11 `if'
		gsort -aux_diff_11
		
		if r(r)!=1 {
			di as red "There is pis shorter/larger than 11 digits."  
			error
		}
		if `=aux_diff_11[1]'==1{
			di as red "There is pis shorter/larger than 11 digits."  
			error
		}
		
		cap drop aux_diff_11
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop pis_valido
	cap drop aux_d_1
	cap drop digit
	cap drop resto_divisao_11
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist', 1,1)) *  3 + ///
							 real(substr(`varlist', 2,1)) *  2 + ///
							 real(substr(`varlist', 3,1)) *  9 + ///
							 real(substr(`varlist', 4,1)) *  8 + ///
							 real(substr(`varlist', 5,1)) *  7 + ///
							 real(substr(`varlist', 6,1)) *  6 + ///
							 real(substr(`varlist', 7,1)) *  5 + ///
							 real(substr(`varlist', 8,1)) *  4 + ///
							 real(substr(`varlist', 9,1)) *  3 + ///
							 real(substr(`varlist',10,1)) *  2 `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11 = mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int digit=11-resto_divisao_11	
		qui replace  digit=0 				   if resto_divisao_11<2

		qui drop resto_divisao_11	
		
		* Gerando digito verificador
		qui gen pis_valido=substr(`varlist',11,1)==string(digit)
		qui replace pis_valido=0 if `varlist'=="0000000000"
		
		qui drop digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values pis_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called pis_valido"
		di as white 	"This table used this filter => [`if']"
		tab pis_valido `if'
		
		* Site reference
		* http://www.macoratti.net/alg_pis.htm
end program


*************** Funcao validar CNPJ ****************************
* validar_cnpj cnpj_cei if length(cnpj_cei)==14
* validar_cnpj cnpj_cei if length(cnpj_cei)==14

cap program drop validar_cnpj
program define validar_cnpj
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cnpj tem sempre 14 digitos
		*local varlist "cnpj"
		di "`varlist'"
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho
		tab aux_tamanho

		cap drop aux_diff_14
		qui gen aux_diff_14=aux_tamanho!=14 `if'
		gsort -aux_diff_14
		cap tab aux_diff_14
		if r(r)!=1 {
			di as red "There is cnpj shorter/larger than 14 digits."  
			error
		}
		if `=aux_diff_14[1]'==1{
			di as red "There is cnpj shorter/larger than 14 digits."  
			error
		}

		cap drop aux_diff_14
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cnpj_valido ***
	cap drop cnpj_valido
	cap drop aux_d_1
	cap drop aux_d_2
	cap drop fist_digit
	cap drop second_digit
	cap drop resto_divisao_11_first
	cap drop resto_divisao_11_second
	
	* Begin algorithm
		qui gen int aux_d_1= real(substr(`varlist', 1,1))  *  5 + ///
							 real(substr(`varlist', 2,1))  *  4 + ///
							 real(substr(`varlist', 3,1))  *  3 + ///
							 real(substr(`varlist', 4,1))  *  2 + ///
							 real(substr(`varlist', 5,1))  *  9 + ///
							 real(substr(`varlist', 6,1))  *  8 + ///
							 real(substr(`varlist', 7,1))  *  7 + ///
							 real(substr(`varlist', 8,1))  *  6 + ///
							 real(substr(`varlist', 9,1))  *  5 + ///
							 real(substr(`varlist', 10,1)) *  4 + ///
							 real(substr(`varlist', 11,1)) *  3 + ///
							 real(substr(`varlist', 12,1)) *  2 `if'	
 						 
		*Resto da divisao por 11
		qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
		qui drop aux_d_1

		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen  int fist_digit=11-resto_divisao_11_first
		qui replace  fist_digit=0 							if resto_divisao_11_first<2

		qui drop resto_divisao_11_first
		* Calculo segundo digito verificador
		qui gen  int aux_d_2= 	 real(substr(`varlist', 1,1))  	*  6 + ///
								 real(substr(`varlist', 2,1))  	*  5 + ///
								 real(substr(`varlist', 3,1))  	*  4 + ///
								 real(substr(`varlist', 4,1))  	*  3 + ///
								 real(substr(`varlist', 5,1))  	*  2 + ///
								 real(substr(`varlist', 6,1))  	*  9 + ///
								 real(substr(`varlist', 7,1))  	*  8 + ///
								 real(substr(`varlist', 8,1))  	*  7 + ///
								 real(substr(`varlist', 9,1))  	*  6 + ///
								 real(substr(`varlist', 10,1)) 	*  5 + ///
								 real(substr(`varlist', 11,1)) 	*  4 + ///
								 real(substr(`varlist', 12,1)) 	*  3 + ///
												fist_digit		*  2  `if'

		*Resto da divisao por 11
		qui gen  int resto_divisao_11_second= mod(aux_d_2,11)

		qui drop aux_d_2 
		* Se o resto da divisao for menor que 2, entao o digito e zero
		qui gen   int second_digit=11-resto_divisao_11_second
		qui replace   second_digit=0 							if resto_divisao_11_second<2

		qui drop resto_divisao_11_second
		* Gerando digito verificador
		qui gen cnpj_valido=substr(`varlist',13,2)==string(fist_digit) +string(second_digit)
		qui replace cnpj_valido=0 if `varlist'=="0000000000000"
		
		qui drop fist_digit second_digit
		qui label define rotulo 1 "valido" 0 "invalido",replace
		qui label values cnpj_valido rotulo
		
		*Mesagem ao usuario
		di as yellow 	"The check is done. That was created a variable called cnpj_valido"
		di as white 	"This table used this filter => [`if']"
		tab cnpj_valido `if'
		
		* Site reference
		*http://www.macoratti.net/alg_cnpj.htm
end program

  
cap program drop validar_cnae10
program define validar_cnae10
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 5 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_5
		qui gen aux_diff_5=aux_tamanho!=5 `if'
		gsort -aux_diff_5

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}
		if `=aux_diff_5[1]'==1{
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}

		cap drop aux_diff_5
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cnae10_valido
	cap drop aux_d_1
	cap drop fist_digit
	cap drop resto_divisao_11_first
	
	* Begin algorithm
	qui gen int aux_d_1= real(substr(`varlist',1,1)) *  5 + ///
						 real(substr(`varlist',2,1)) *  4 + ///
						 real(substr(`varlist',3,1)) *  3 + ///
						 real(substr(`varlist',4,1)) *  2   `if'

	*Resto da divisao por 11
	qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
	qui drop aux_d_1

	* Se o resto da divisao for menor que 2, entao o digito e zero
	qui gen  int fist_digit=11-resto_divisao_11_first
	qui replace  fist_digit=0 							if resto_divisao_11_first<2

	qui drop resto_divisao_11_first
	
	* Gerando digito verificador
	qui gen cnae10_valido=substr(`varlist',5,1)==string(fist_digit)
	qui replace cnae10_valido=0 if `varlist'=="00000"
	
	qui drop fist_digit
	qui label define rotulo 1 "valido" 0 "invalido",replace
	qui label values cnae10_valido rotulo
	
	*Mesagem ao usuario
	di as yellow 	"The check is done. That was created a variable called cnae10_valido"
	di as white 	"This table used this filter => [`if']"
	tab cnae10_valido `if'
end program


cap program drop validar_cnae20
program define validar_cnae20
	syntax varlist(string) [if] [in] 
	
	**** Check end ****
	* Verificando se apenas uma variavel esta no input
		qui local check_1=wordcount("`varlist'") 
		if `check_1'>1 {
			di as red "Varlist not allowed, use only one variable"
			error
		}
		
		cap confirm string var `varlist'
		if _rc!=0 {
			di as red "The variable must be string"
			error
		}
			
		*Checando se o cpf tem sempre 5 digitos
		cap drop aux_tamanho
		qui gen aux_tamanho= length(`varlist') `if'
		qui tab aux_tamanho

		cap drop aux_diff_5
		qui gen aux_diff_5=aux_tamanho!=5 `if'
		gsort -aux_diff_5

		if r(r)!=1 {
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}
		if `=aux_diff_5[1]'==1{
			di as red "There is cpf shorter/larger than 5 digits."  
			error
		}

		cap drop aux_diff_5
		cap drop aux_tamanho
	**** Check end ****
		
	*** Drop cpf_valido ***
	cap drop cnae20_valido
	cap drop aux_d_1
	cap drop fist_digit
	cap drop resto_divisao_11_first
	
	* Begin algorithm
	qui gen int aux_d_1= real(substr(`varlist',1,1)) *  5 + ///
						 real(substr(`varlist',2,1)) *  4 + ///
						 real(substr(`varlist',3,1)) *  3 + ///
						 real(substr(`varlist',4,1)) *  2   `if'

	*Resto da divisao por 11
	qui gen  int resto_divisao_11_first= mod(aux_d_1,11)
	qui drop aux_d_1

	* Se o resto da divisao for menor que 2, entao o digito e zero
	qui gen  int fist_digit=11-resto_divisao_11_first
	qui replace  fist_digit=0 							if fist_digit>=10
	
	*Para a CNAE 2.0 é utilizado o módulo 11 + uma unidade.
	replace  fist_digit=fist_digit+1
	replace  fist_digit=0			if fist_digit==10
	
	*qui drop resto_divisao_11_first
	
	* Gerando digito verificador
	qui gen cnae20_valido=substr(`varlist',5,1)==string(fist_digit)
	qui replace cnae20_valido=0 if `varlist'=="00000"
	
	*qui drop fist_digit
	qui label define rotulo 1 "valido" 0 "invalido",replace
	qui label values cnae20_valido rotulo
	
	*Mesagem ao usuario
	di as yellow 	"The check is done. That was created a variable called cnae20_valido"
	di as white 	"This table used this filter => [`if']"
	tab cnae20_valido `if'
	
end program


/* Validar  codigo cnae-*/
 *cd "C:\Users\Leandro-ASUS\Dropbox\Trabalhos Profissionais\Rotinas de programacao relevantes\STATA\criacao de ado e funcao\Validacao de indentificadores"
* Base de teste
 *use estrutura_cnae10,clear
 
 *validar_cnae10 cnae10 if length(cnae10)==5
 *validar_cnae20 cnae10 if length(cnae10)==5
 
 *use estrutura_cnae20,clear
 
 *validar_cnae10 cnae20 if length(cnae20)==5
 *validar_cnae20 cnae20 if length(cnae20)==5
