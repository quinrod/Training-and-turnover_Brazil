clear all
set more off

******************************************************************************
**************************DEMANDANTES*****************************************
******************************************************************************

do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}demandante_cnpj_turma.dta", clear

*1. drop useless variables ou string muito grandes
drop no_contato nu_telefone ds_observacao text no_pessoa_juridica 

*2. rename variables 
#delimit;
renvars co_oferta_turma ds_identificador_turma nu_cnpj co_pessoa_juridica  
ano_cadastro_turma 
\ co_turma no_turma cnpj co_demandante ano
; #delimit cr 

*3. lowercase
foreach var of varlist no_turma no_empresa {
gen Z=lower(`var')
drop `var'
rename Z `var'
}

*3. Organize the data
keep if co_demandante==48932
drop co_demandante 

order cnpj no_empresa co_turma no_turma ano
sort cnpj co_turma ano

destring ano, replace

*4. Recover and validate cnpj

/*
split cnpj, p(.)
gen cnpj2= trim(cnpj1)
replace cnpj2 = "0"*(14-length(cnpj2))+cnpj2 if length(cnpj2)<=13 & !inlist(cnpj2,"",".")
validar_cnpj cnpj2 if length(cnpj2)==14
tab cnpj_valido
gen teste= substr(cnpj,-6,6)=="000000"
*/

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
drop cnpj_input check

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

drop cnpj_valido nome10

*5. diminish size 
recast str14 cnpj
format no_empresa no_turma %20s

*6. merge
sort cnpj co_turma ano
duplicates drop cnpj no_empresa co_turma ano, force

save "${IBGE}demandante.dta", replace
