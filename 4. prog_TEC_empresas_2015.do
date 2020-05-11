clear all
set more off

********************************************************************************
********************************Demand (2015)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}demanda_empresas_2015.dta", clear

*1. drop useless variables ou string muito grandes
drop nomedaescolaofertante

*2. rename variables 
#delimit;
renvars nomedaempresademandante cnpjdaempresa nomedocurso uf município 
trabalhadorestotais númerodetrabalhadoresquenece númerodetrabalhadoresquetrab 
códigodocurso códigodomunicípio setor \ no_empresa cnpj no_curso no_uf_empresa
no_municipio_empresa vagas_demandadas_d n_empregados_empresa empregados_empresa
co_curso co_municipio_empresa setor_empresa
; #delimit cr 

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
foreach x of varlist cnpj co_municipio_empresa cbo n_empregados_empresa {
replace `x' = "." if `x'==""
}

replace no_empresa = ustrrtrim(no_empresa)
replace no_empresa = ustrltrim(no_empresa)
replace co_municipio_empresa = subinstr(co_municipio_empresa,"natal","",.)

replace cbo = subinstr(cbo,"Não informado","",.)
replace cbo = subinstr(cbo,"CBO/2002","",.)
replace cbo = subinstr(cbo,"NÃO EXISTE","",.)
replace cbo = subinstr(cbo,"Não encontrado","",.)
replace cbo = subinstr(cbo,"não encontrado","",.)
replace cbo = subinstr(cbo,"NÃO ENCONTRADO","",.)
replace cbo = subinstr(cbo,"NÃO encontrei","",.)
replace cbo = subinstr(cbo,"não encontrei","",.)
replace cbo = subinstr(cbo,"Não encontrei","",.)
replace cbo = subinstr(cbo,"VARIOS","",.)
replace cbo = subinstr(cbo,"DIVERSOS","",.)
replace cbo = subinstr(cbo,"Diversos","",.)
replace cbo = subinstr(cbo,"Não achei","",.)
replace cbo = subinstr(cbo,"CBO","",.)
replace cbo = subinstr(cbo,"desconhecido","",.)
replace cbo = subinstr(cbo,"não possui","",.)
replace cbo = subinstr(cbo,"FIC","",.)
replace cbo = subinstr(cbo,"ENTRE OUTRAS AREAS","",.)
replace cbo = subinstr(cbo," ","",.)
replace cbo = subinstr(cbo,",","",.)
replace cbo = subinstr(cbo,"*","",.)
replace cbo = subinstr(cbo,"-","",.)
replace cbo = subinstr(cbo,"–","",.)
replace cbo = subinstr(cbo,".","",.)
replace cbo = subinstr(cbo,"?","",.)
replace cbo = subinstr(cbo,"N/A","",.)
replace cbo = subinstr(cbo,"\","",.)
replace cbo = subinstr(cbo,"/","",.)
replace cbo = subinstr(cbo,"não","",.)
replace cbo = subinstr(cbo,"2002","",.)

replace cbo = ustrtrim(cbo)
replace cbo = substr(cbo, 1, 6)
gen str6 cbo1 = string(real(cbo),"%06.0f")
replace cbo = cbo1
recast str6 cbo
drop cbo1
gen byte notnumeric = real(cbo)==.

destring co_municipio_empresa n_empregados_empresa, replace 
drop notnumeric

gen str14 cnpj1 = string(real(cnpj),"%014.0f")
replace cnpj = cnpj1
recast str14 cnpj
drop cnpj1
gen byte notnumeric = real(cnpj)==.
drop notnumeric

replace cnpj=""  if  length(cnpj)<14 
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

*replace municipios
replace no_municipio_empresa ="taquaral de goiás" if no_municipio_empresa =="taquaral"
replace no_municipio_empresa ="piraju" if no_municipio_empresa =="pirajú"
replace no_municipio_empresa ="herval d'oeste" if no_municipio_empresa =="herval d´oeste"
replace no_municipio_empresa ="lambari d'oeste" if no_municipio_empresa =="lambari d´oeste"
replace no_municipio_empresa ="mirassol d'oeste" if no_municipio_empresa =="mirassol d´oeste"
replace no_municipio_empresa ="dias d'ávila" if no_municipio_empresa =="dias d´ávila"
replace no_municipio_empresa ="olho-d'água do borges" if no_municipio_empresa =="olho-d´água do borges"
replace no_municipio_empresa ="são luís" if no_municipio_empresa =="são luis"
replace no_municipio_empresa ="marabá" if no_municipio_empresa =="maraba"
replace no_municipio_empresa ="santa bárbara d'oeste" if no_municipio_empresa =="santa bárbara d´oeste"
replace no_uf_empresa ="MS" if no_uf_empresa =="MS "

*remove setores
replace setor_empresa= lower(subinstr(setor_empresa,"á","a",1))
replace setor_empresa= lower(subinstr(setor_empresa,"é","e",1))
replace setor_empresa= lower(subinstr(setor_empresa,"í","i",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ó","o",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ã","a",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ê","e",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ô","o",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ç","c",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ç","c",1))
encode setor_empresa, gen(setor_empresa1)
drop setor_empresa
rename setor_empresa1 setor_empresa

*5. organize data

*order variables
#delimit;
order cnpj no_empresa no_uf_empresa co_municipio_empresa
no_municipio_empresa setor_empresa co_curso no_curso cbo vagas_demandadas_d 
empregados_empresa n_empregados_empresa
; #delimit cr 

*gen year
gen ano = 2015

*label variables
#delimit;
labvars no_empresa cnpj no_uf_empresa co_municipio_empresa
no_municipio_empresa setor_empresa co_curso no_curso cbo vagas_demandadas_d 
empregados_empresa n_empregados_empresa ano
\ "nome da empresa" "cnpj" "nome uf da empresa" "codigo municipio da empresa"
"nome municipio da empresa" "setor empresa" "codigo do curso" "nome do curso" "occupacao" 
"vagas demandadas" "empregados na empresa" "não empregados na empresa" "ano"
; #delimit cr

*sort variables
#delimit;
sort cnpj no_uf_empresa co_curso cbo vagas_demandadas_d
empregados_empresa n_empregados_empresa
; #delimit cr

*drop impossible values
drop if vagas_demandadas_d==0
drop if vagas_demandadas_d < empregados_empresa & empregados_empresa!=.
drop if vagas_demandadas_d < n_empregados_empresa & n_empregados_empresa!=.
gen vagas_demandadas_d1 = empregados_empresa+n_empregados_empresa
drop if vagas_demandadas_d1!=vagas_demandadas_d & vagas_demandadas_d1!=.
drop vagas_demandadas_d1

*6. drop duplicates 
*drop duplicates if n_empregados nao varia (y/n) *no_curso vs co_curso
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa co_curso cbo co_municipio_empresa 
vagas_demandadas_d empregados_empresa n_empregados_empresa, gen(new`x')
; #delimit cr
}
drop new*

*drop duplicates if n_empregados varia (y/n) *no_curso vs co_curso
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa co_curso cbo co_municipio_empresa 
vagas_demandadas_d empregados_empresa, gen(new`x')
; #delimit cr
}
drop new*

*drop duplicates if vagas solicitadas is the same (y/n) *no_curso vs co_curso but which one you take as valid?
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa co_curso cbo co_municipio_empresa 
vagas_demandadas_d
, gen(new`x')
; #delimit cr
}
drop new*

*7. diminish size 
*Level up
recast str14 cnpj
recast str2 no_uf_empresa
recast int vagas_demandadas_d

format no_empresa no_municipio_empresa no_curso %20s

*8. merge 
*merge with municipios
merge m:1 no_municipio_empresa no_uf_empresa using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m

order cnpj no_empresa co_municipio_empresa setor_empresa co_curso vagas_demandadas_d ano

drop no_uf_empresa no_municipio_empresa no_curso cbo empregados_empresa n_empregados_empresa join f co_uf_empresa

*9. compress
compress 

save "${NEWDATA}demanda_2015.dta", replace

********************************************************************************
********************************Supply (2015)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}homologacao_empresas_2015.dta", clear

*1. drop useless variables ou string muito grandes
*drop useless variables
drop escola

*2. rename variables
#delimit;
renvars empresa curso cod_curso uf município vagasdemandadas vagashomologadas setor
\ no_empresa no_curso co_curso no_uf_empresa no_municipio_empresa 
vagas_demandadas_h vagas_homologadas setor_empresa
; #delimit cr

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
*destring
gen str14 cnpj1 = string(real(cnpj),"%014.0f")
replace cnpj = cnpj1
recast str14 cnpj
drop cnpj1
gen byte notnumeric = real(cnpj)==.
drop notnumeric

replace cnpj=""  if  length(cnpj)<14 
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

*replace municipios
replace no_municipio_empresa ="lambari d'oeste" if no_municipio_empresa =="lambari d´oeste"
replace no_municipio_empresa ="santana do livramento" if no_municipio_empresa =="sant'ana do livramento"

*remove setores
replace setor_empresa= lower(subinstr(setor_empresa,"á","a",1))
replace setor_empresa= lower(subinstr(setor_empresa,"é","e",1))
replace setor_empresa= lower(subinstr(setor_empresa,"í","i",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ó","o",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ã","a",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ê","e",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ô","o",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ç","c",1))
replace setor_empresa= lower(subinstr(setor_empresa,"ç","c",1))
encode setor_empresa, gen(setor_empresa1)
drop setor_empresa
rename setor_empresa1 setor_empresa

*5. organize data

*order variables
#delimit;
order cnpj no_empresa no_uf_empresa no_municipio_empresa setor_empresa co_curso 
no_curso vagas_demandadas_h vagas_homologadas
; #delimit cr

*gen year
gen ano = 2015

*label variables
#delimit;
labvars no_empresa cnpj no_uf_empresa no_municipio_empresa setor_empresa co_curso 
no_curso vagas_demandadas_h vagas_homologadas ano
\ "nome da empresa" "cnpj" "nome uf da empresa" "nome municipio da empresa" 
"setor empresa" "codigo do curso" "nome do curso" "vagas solicitadas" "vagas homologadas" "ano"
; #delimit cr

*sort variables
sort cnpj no_uf_empresa co_curso vagas_demandadas_h vagas_homologadas

drop if vagas_demandadas_h==0
*drop if vagas_demandadas_h =< empregados_empresa
*drop if vagas_demandadas_h =< n_empregados_empresa

*6. drop duplicates 

*drop duplicates if entries are entirely the same (y/n)
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa no_curso co_curso vagas_demandadas_h 
vagas_homologadas, gen(new`x')
; #delimit cr
*drop if new`x'==1 
}
drop new*

*drop duplicates if vagas solicitadas são as mesmas mas as homologadas não (y/n)
*but which one to choose? . or 20?
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa no_curso co_curso vagas_demandadas_h,
gen(new`x')
; #delimit cr
*drop if new`x'==1 & vagas_homologadas==0
}
drop new*

*7. diminish size 
*Level up
recast str14 cnpj
recast str2 no_uf_empresa
recast int vagas_demandadas_h 

format no_empresa no_municipio_empresa no_curso %20s

*8. merge 
*merge with municipios
merge m:1 no_municipio_empresa no_uf_empresa using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m

*sort variables
order cnpj no_empresa co_municipio_empresa co_curso vagas_demandadas_h vagas_homologadas

sort cnpj co_municipio_empresa co_curso vagas_demandadas_h vagas_homologadas

*collapse
collapse(sum) vagas_demandadas_h vagas_homologadas, by (cnpj no_empresa setor_empresa co_municipio_empresa co_curso ano)

*9. compress
compress 

save "${NEWDATA}homologada_2015v2.dta", replace

********************************MERGE****************************************
use "${NEWDATA}homologada_2015v2.dta", replace

*merge with other vagas 2015v1
keep if cnpj=="." & no_empresa==""
drop cnpj no_empresa

/*
duplicates tag co_municipio_empresa co_curso vagas_demandadas_h ano, gen(new)
drop new
*/

merge 1:1 co_municipio_empresa co_curso vagas_demandadas_h ///
using "${NEWDATA}homologada_2015v1.dta"

order cnpj no_empresa co_municipio_empresa co_curso vagas_demandadas_h vagas_homologadas ano

save "${NEWDATA}homologada_2015v3.dta", replace

*********************************APPEND*****************************************
use "${NEWDATA}homologada_2015v2.dta", replace

drop if cnpj=="." & no_empresa==""

order cnpj no_empresa co_municipio_empresa co_curso vagas_demandadas_h vagas_homologadas ano

append using "${NEWDATA}homologada_2015v3.dta"

drop _m

save "${NEWDATA}homologada_2015.dta", replace

******************************************************************************
*********************************MERGE 2015***********************************
******************************************************************************
use "${NEWDATA}demanda_2015.dta", clear
#delimit;
merge m:1 cnpj no_empresa co_municipio_empresa setor_empresa ///
co_curso using "${NEWDATA}homologada_2015.dta", force
; #delimit cr
sort _m
save "${NEWDATA}empresas_2016.dta", replace


*m_==1 -> matched on both
*m_==2 -> matched on demand (firms only in demand)
*m_==3 -> matched on supply (firms only in homologacao)

*Some m_3 and m_2 maybe the same, but vagas_demandadas vary
