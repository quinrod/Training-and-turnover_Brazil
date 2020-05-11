*Para montar uma lista unica de cnpjs e nomes de empresa, temos que entender os 
/* Casos possiveis 
		1. mesmo cnpj, nomes muito parecidos --> mesma empresa
		2. mesmo cnpj, nomes diferentes --> mesma empresa
		3. mesmo nome, cnpj diferente --> empresas diferentes */
		
/* strgroup
http://fmwww.bc.edu/RePEc/bocode/s/
ssc install strgroup
ado dir  */

********************************************************************************
********************************DEMANDA*****************************************
********************************************************************************
clear all
set more off

do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${NEWDATA}demanda_2014.dta", clear
append using "${NEWDATA}demanda_2015.dta"
append using "${NEWDATA}demanda_2016.dta"

saveold "${NEWDATA}demanda_empresas.dta", replace version(11)

use "${NEWDATA}demanda_empresas.dta", clear

* o siduscon irao confundir, melhor definir
replace no_empresa = "sinduscon piaui" if no_empresa == "sinduscon pi"
replace no_empresa = "sinduscon ceara" if no_empresa == "sinduscon ce"
replace no_empresa = "sinduscon parana" if no_empresa == "sinduscon pr"
replace no_empresa = "sinduscon rio de janeiro" if no_empresa == "sinduscon-rj"
replace no_empresa = "sinduscon rio de janeiro" if no_empresa == "sinduscon rj"
replace no_empresa = "sinduscon rio grande do sul" if no_empresa == "sinduscon rs"
replace no_empresa = "sinduscon rio grande do sul" if no_empresa == "sinduscon-rs"

*observacoes sem nome da empresa e sem cnpj
drop if cnpj =="" & no_empresa ==""

* strgroup usa distancia de levenshtein pra match 
* threshold de 10 = 90% de match
sort no_empresa cnpj
strgroup no_empresa, gen(nome10) threshold(0.1) first force

sort nome10 
order cnpj no_empresa nome10 

gen cnpj_input = cnpj
order cnpj cnpj_input
destring cnpj_input, replace
format %17.0g cnpj_input

gsort +nome10 -no_empresa +cnpj_input 
replace cnpj_input = cnpj_input[_n-1] if nome10 == nome10[_n-1]

gen temp = cnpj
destring temp, replace
format %17.0g temp

gen check = temp-cnpj_input
order cnpj cnpj_input temp check

replace check = 1 if check!=0 & check!=.
replace check = 2 if check == .
replace check = 3 if temp == . & cnpj_input != .

* check = 0 --> tudo parece certo 
* check = 1 --> alguma coisa de errado (ex. 2 cnpj, 1 nome)
* check = 2 --> precisa input o cnpj (ex. sem cnpj mas com nome)
* check = 3 --> parece estar inputando certo

tab check

sort check
drop temp
drop if check==2 & cnpj==""
destring cnpj, replace 
replace cnpj = cnpj_input if check==3
format %014.0f cnpj
drop cnpj_input

tostring cnpj, gen(cnpj1) format(%014.0f)
drop cnpj
rename cnpj1 cnpj
recast str14 cnpj
gen byte notnumeric = real(cnpj)==.
drop notnumeric

replace cnpj=""  if  length(cnpj)<14 
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0
drop if cnpj_valido==0

/* proximas etapas 
1. inspecao manual pra ver precisa juntar/separar 2 nome10 (check =1)
2. completar cnpjs que nao existem (check = 2) 
3. verificar quando check == 1  */

sort cnpj co_municipio_empresa co_curso ano

duplicates drop cnpj co_municipio_empresa co_curso ano, force

compress

saveold "${IBGE}demanda_empresas.dta", replace version(11)

********************************************************************************
**************************************HOMOLOGADA********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

clear all
set more off

use "${NEWDATA}homologada_2014.dta", clear
append using "${NEWDATA}homologada_2015.dta"
append using "${NEWDATA}homologada_2016.dta"

saveold "${NEWDATA}homologada_empresas.dta", replace version(11)

use "${NEWDATA}homologada_empresas.dta", clear

* o siduscon irao confundir. melhor definir
replace no_empresa = "sinduscon piaui" if no_empresa == "sinduscon pi"
replace no_empresa = "sinduscon ceara" if no_empresa == "sinduscon ce"
replace no_empresa = "sinduscon parana" if no_empresa == "sinduscon pr"
replace no_empresa = "sinduscon rio de janeiro" if no_empresa == "sinduscon-rj"
replace no_empresa = "sinduscon rio de janeiro" if no_empresa == "sinduscon rj"
replace no_empresa = "sinduscon rio grande do sul" if no_empresa == "sinduscon rs"
replace no_empresa = "sinduscon rio grande do sul" if no_empresa == "sinduscon-rs"

*observacoes sem nome da empresa e sem cnpj
drop if cnpj =="" & no_empresa ==""

* strgroup usa distancia de levenshtein pra match 
* threshold de 10 = 90% de match
sort no_empresa cnpj
strgroup no_empresa, gen(nome10) threshold(0.1) first force

sort nome10 
order cnpj no_empresa nome10 

gen cnpj_input = cnpj
order cnpj cnpj_input
destring cnpj_input, replace
format %17.0g cnpj_input

gsort +nome10 -no_empresa +cnpj_input 
replace cnpj_input = cnpj_input[_n-1] if nome10 == nome10[_n-1]

gen temp = cnpj
destring temp, replace
format %17.0g temp

gen check = temp-cnpj_input
order cnpj cnpj_input temp check

replace check = 1 if check!=0 & check!=.
replace check = 2 if check == .
replace check = 3 if temp == . & cnpj_input != .

* check = 0 --> tudo parece certo 
* check = 1 --> alguma coisa de errado (ex. 2 cnpj, 1 nome)
* check = 2 --> precisa input o cnpj (ex. sem cnpj mas com nome)
* check = 3 --> parece estar inputando certo

*cnpj com mesmo nome e 2 cnpjs diferentes
*simples: alcanca o limite e abre outra empresa

tab check

sort check
drop temp
drop if check==2 & cnpj==""
destring cnpj, replace 
replace cnpj = cnpj_input if check==3
format %014.0f cnpj
drop cnpj_input

tostring cnpj, gen(cnpj1) format(%014.0f)
drop cnpj
rename cnpj1 cnpj
recast str14 cnpj
gen byte notnumeric = real(cnpj)==.
drop notnumeric

replace cnpj=""  if  length(cnpj)<14 
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0
drop if cnpj_valido==0

/* proximas etapas 
1. inspecao manual pra ver precisa juntar/separar 2 nome10 (check =1)
2. completar cnpjs que nao existem (check = 2) 
3. verificar quando check == 1  */

sort cnpj co_municipio_empresa co_curso ano

duplicates drop cnpj co_municipio_empresa co_curso ano, force

compress

saveold "${IBGE}homologada_empresas.dta", replace version(11)


