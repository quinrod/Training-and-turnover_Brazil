* Teste 1- Chave primaria sendo matricula e cpf
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

****************************************************************************
***********************ajustando base do MEC********************************
****************************************************************************
use "${IBGE}alunos_MEC.dta", clear

*1. Eliminando variaveis string muito grandes
drop  no_mae* nu_telefone
drop  ds_tipo_beneficiario ds_email ds_tipo_beneficiario

foreach var of varlist no_unidade_* no_curso {
	rename `var' aux_`var'
	encode aux_`var',gen(`var')
	drop aux_`var'
}

*2. Elimiando variaveis zeradas
qui count
local total_linhas `=r(N)'
 
global delete_list ""
foreach var of varlist * {
	cap confirm string var `var'
	if _rc==0 {
		qui count if `var'==""
		if r(N)==`total_linhas' {
			di as white "Var sem informacao - `var'"
			global delete_list "${delete_list} `var'"
		}
	}
	else {
		qui count if `var'==.
		if r(N)==`total_linhas' {
			di as white "Var sem informacao - `var'"
			global delete_list "${delete_list} `var'"
		}
	}
}
drop ${delete_list}

*3. Transformando variaveis categoricas em numericas
replace ds_tipo_rede_ensino= lower(subinstr(ds_tipo_rede_ensino,"ú","u",1))
encode  ds_tipo_rede_ensino, gen(tipo_rede_ensino)

drop ds_tipo_rede_ensino co_tipo_rede_ensino
tab1 tipo_rede_ensino

label define yes_no  1 "sim" 0 "nao", replace
foreach var in  confirmacao_matricula matricula_ativa curso_experimental extemporaneo_matricula {
	rename st_`var' aux_`var'
	gen byte `var' =1 if aux_`var'=="SIM"
	replace	 `var' =0 if aux_`var'=="NÃO"
	drop aux_`var'
	
	*Transformando a variavel em fator
	label values `var' yes_no
}

*4. Transformando variaveis com data
gen fim_curso= mdy(real(substr(ds_periodo_curso,-7,2)),real(substr(ds_periodo_curso,-10,2)),real(substr(ds_periodo_curso,-4,4)))
format %td fim_curso

*Variavel de duracao em dias do curso baseada na variavel de periodo
gen duracao_curso_periodo= fim_curso- dt_inicio
replace duracao_curso_periodo=. if !inrange(duracao_curso_periodo,30,1500)
	label var duracao_curso_periodo "duracao do curso em dias"
	
*Elimando variaveis de data que nao serao mais utilizadas
drop ds_periodo_curso nu_mes_ano_inicio_curso fim_curso

order dt* duracao_curso_periodo

*5. Encontrar variaveis duplicadas
*Buscar correlacao 1
corr  dt* duracao_curso_periodo

* Variavei iguais dt_geracao dt_inicio_vigencia  
drop dt_geracao

*6. Ajustar variaveis que devem seguir parametros de digitos especificos 

*Acrescentar 0 if lenght matricula <7
tostring matricula, replace
replace matricula = (7-length(matricula))*"0" + matricula if length(matricula)<7

*Verificando validade dos cpf
replace cpf=""  if  length(cpf)<11 
validar_cpf cpf if length(cpf)==11
replace cpf=""  if cpf_valido==0
drop cpf_valido

*Eliminando informcaces duplicadas
duplicates tag cpf matricula, gen(tag_mat)
tab tag_mat
drop if tag_mat==1
drop tag_mat

tostring co_turma, generate(co_turma1)
tostring co_sisutec_turma, generate(co_sisutec_turma1)
replace co_turma1="" if co_turma1=="."
replace co_sisutec_turma1="" if co_sisutec_turma1=="."
gen co_turma2 = co_turma1 + co_sisutec_turma1
destring co_turma2, replace
drop co_turma co_turma1 co_sisutec_turma* 
rename co_turma2 co_turma

order co_turma cpf matricula 
sort  co_turma cpf matricula

compress

save  "${IBGE}alunos_mec_v2.dta",replace

****************************************************************************
***********************ajustando base do MDIC*******************************
****************************************************************************
use "${IBGE}alunos_MDIC.dta", clear

*1. Eliminando variaveis string muito grandes
drop 	nome_da_uer ds_tipo_beneficiario nome_da_ue no_programa  
drop 	populacao_campo  
drop	comunidade_quilombola  datadiplomacertificado	
drop  	transferencia_renda povo_indigena  
drop 	codigodiplomacertificado 

*2. Elimiando variaveis zeradas
foreach var of varlist no_eixo_tecnologico no_sistema_ensino ead unidade_demandante no_curso ///
						no_demandante turno municipio_do_local_da_oferta instituicao edicao_catalogo_guia ///
						 no_modalidade subdependencia_admin	{
	rename `var' aux_`var'
	encode aux_`var',gen(`var')
	drop aux_`var'
}
 
 qui count
 local total_linhas `=r(N)'
 
global delete_list ""
foreach var of varlist * {
	cap confirm string var `var'
	if _rc==0 {
		qui count if `var'==""
		if r(N)==`total_linhas' {
			di as white "Var sem informacao - `var'"
			global delete_list "${delete_list} `var'"
		}
	}
	else {
		qui count if `var'==.
		if r(N)==`total_linhas' {
			di as white "Var sem informacao - `var'"
			global delete_list "${delete_list} `var'"
		}
	}
}

cap noi drop $delete_list

*3. Ajustar variaveis que devem seguir parametros de digitos especificos
rename co_matricula_estudante 		matricula
tostring matricula, replace
replace matricula= (7-length(matricula))*"0" + matricula if length(matricula)<7
 
replace cpf=""  if  length(cpf)<11
validar_cpf cpf if length(cpf)==11
replace cpf="" if cpf_valido==0
drop cpf_valido

*4. Encontrar variaveis duplicadas
duplicates tag cpf matricula, gen(tag_mat)
tab tag_mat
drop if tag_mat==1

order cpf matricula dt* 
sort  cpf matricula
compress
save "${IBGE}alunos_mdic_v2.dta", replace


