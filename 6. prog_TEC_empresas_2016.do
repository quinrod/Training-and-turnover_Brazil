clear all
set more off

********************************************************************************
********************************Demand (2016)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}demanda_empresas_2016.dta", clear

*1. drop useless variables ou string muito grandes
drop jovem deficiencia país região mesorregião observação microrregião

*2. rename variables 
#delimit;
renvars empresa nomecurso uf municipio trabtotais trabexternos trabempresa setor 
\ no_empresa no_curso no_uf_empresa no_municipio_empresa vagas_demandadas_d
n_empregados_empresa empregados_empresa setor_empresa
; #delimit cr

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa{
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
foreach x of varlist cnpj prioridade {
replace `x' = "." if `x' ==""
}
replace cnpj = subinstr(cnpj,"–","",.)
gen str14 cnpj1 = string(real(cnpj),"%014.0f")
replace cnpj = cnpj1
recast str14 cnpj
drop cnpj1
replace prioridade = subinstr(prioridade,"NA","",.)
replace prioridade = subinstr(prioridade,"serr","",.)
destring prioridade, replace 

replace cnpj = ustrrtrim(cnpj)
replace cnpj = ustrltrim(cnpj)
replace cnpj = ustrtrim(cnpj)
replace cnpj = subinstr(cnpj,"/","",.)
replace cnpj = subinstr(cnpj,"-","",.)
replace cnpj = subinstr(cnpj,",","",.)
replace cnpj = subinstr(cnpj,".","",.)
replace cnpj="." if cnpj==""

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
replace no_municipio_empresa="lambari d'oeste" if no_municipio_empresa=="lambari d´oeste"
replace no_municipio_empresa="mirassol d'oeste" if no_municipio_empresa=="mirassol d´oeste"

*replace no_curso
replace no_curso ="agente de coleta e entrega no transporte de pequenas cargas" if no_curso =="agente de coleta e entrega no transporte pequenas cargas"
replace no_curso ="agente de regularização ambiental rural" if no_curso =="agente de regularização ambiental"
replace no_curso ="agente de recepção e reservas em meios de hospedagem" if no_curso =="agente de reservas em meios de hospedagem"
replace no_curso ="confeiteiro" if no_curso =="auxiliar de confeitaria"
replace no_curso ="padeiro" if no_curso =="auxiliar de padeiro"
replace no_curso ="pedreiro de refratário" if no_curso =="auxiliar em fabricação de refratários"
replace no_curso ="reciclador" if no_curso =="catador de material reciclável"
replace no_curso ="gestor de microempresa" if no_curso =="empresário de micro empresa"
replace no_curso ="pescador profissional-pop" if no_curso =="pescador" 
replace no_curso ="agente de recepção e reservas em meios de hospedagem" if no_curso =="recepcionista em meios de hospedagem"

*replace setor_empresa
replace setor_empresa = "automotivo" if setor_empresa =="autopeças"
replace setor_empresa = "fármacos" if setor_empresa =="complexo da saúde"
replace setor_empresa = "construção" if setor_empresa =="construção civil"
replace setor_empresa = "construção" if setor_empresa =="construção civil e pesada"
replace setor_empresa = "construção" if setor_empresa =="construção pesada"
replace setor_empresa = "confecções e têxtil" if setor_empresa =="couro"
replace setor_empresa = "comércio" if setor_empresa =="gemas e jóias"
replace setor_empresa = "máquinas e equipamentos" if setor_empresa =="naval"
replace setor_empresa = "agronegócios" if setor_empresa =="produção"
replace setor_empresa = "sucroalcooleiro" if setor_empresa =="sucroenergético"
replace setor_empresa = "agronegócios" if setor_empresa =="produção"
replace setor_empresa = "tic/complexo eletroeletrônico" if setor_empresa =="tic/complexo eletrônico"

*remove especial caracteres
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

*gen year
gen ano = 2016

*order variables
#delimit;
order cnpj no_empresa no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d empregados_empresa n_empregados_empresa prioridade semestre 
; #delimit cr 

*label variables
#delimit;
labvars cnpj no_empresa no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d empregados_empresa empregados_empresa prioridade ano semestre
\ "cnpj" "nome da empresa" "nome uf da empresa" "nome municipio da empresa" 
"setor empresa" "nome do curso" "vagas solicitadas" "empregados na empresa" 
"não empregados na empresa" "prioridade" "ano" "semestre solicitação"
; #delimit cr

*drop impossible values
drop if vagas_demandadas_d==0
drop if vagas_demandadas_d < empregados_empresa & empregados_empresa!=.
drop if vagas_demandadas_d < n_empregados_empresa & n_empregados_empresa!=.
gen vagas_demandadas_d1 = empregados_empresa+n_empregados_empresa
drop if vagas_demandadas_d1!=vagas_demandadas_d & vagas_demandadas_d1!=.
drop vagas_demandadas_d1

*6. drop duplicates 

*sort and drop variables
foreach x of varlist cnpj no_empresa {
#delimit;
sort `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso vagas_demandadas_d 
empregados_empresa n_empregados_empresa prioridade semestre
; #delimit cr

{
*drop duplicates if semestre nao varia (y/n) 
#delimit;
quietly by `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d empregados_empresa n_empregados_empresa prioridade semestre
: gen dup`x' = cond(_N==1,0,_n)
; #delimit cr

drop if dup`x'>1 & prioridade!=. & semestre!=.  
drop dup`x'
} 

{
*drop duplicates if prioridade nao varia (y/n) 
#delimit;
quietly by `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d empregados_empresa n_empregados_empresa prioridade
: gen dup`x' = cond(_N==1,0,_n)
; #delimit cr
drop if prioridade!=. & semestre!=. & (dup`x'>2 | dup`x'==1)
drop dup`x'
} 

{
*drop duplicates if n_empregados nao varia (y/n) 
#delimit;
quietly by `x' no_uf_empresa no_municipio_empresa setor no_curso 
vagas_demandadas_d empregados_empresa n_empregados_empresa
: gen dup`x' = cond(_N==1,0,_n)
; #delimit cr

br if prioridade!=. & semestre!=. & dup`x'>0

sort `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso ///
vagas_demandadas_d empregados_empresa n_empregados_empresa semestre

duplicates tag `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso ///
vagas_demandadas_d empregados_empresa n_empregados_empresa semestre, gen(new`x') 

drop if semestre==1 & new`x'==0
drop new`x'
drop dup`x'
} 
} 

*drop duplicates if empregados & prioridade nao varia (y/n)
foreach x of varlist cnpj no_empresa {
sort `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso ///
vagas_demandadas_d empregados_empresa prioridade 
#delimit;
quietly by `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d empregados_empresa prioridade
: gen dup`x' = cond(_N==1,0,_n)
; #delimit cr
drop if dup`x'>1 & prioridade!=. 
drop dup`x'
}

*drop duplicates if vagas solicitadas & prioridade nao varia (y/n)
foreach x of varlist cnpj no_empresa {
sort `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso ///
vagas_demandadas_d prioridade 
#delimit;
quietly by `x' no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d prioridade
: gen dup`x' = cond(_N==1,0,_n)
; #delimit cr
drop if dup`x'>1 & prioridade!=. 
drop dup`x'
}

sort cnpj no_uf_empresa no_municipio_empresa setor_empresa no_curso vagas_demandadas_d ///
empregados_empresa n_empregados_empresa prioridade semestre

*drop duplicates if vagas solicitadas is the same (y/n) but which one you take as valid?
#delimit;
duplicates tag cnpj no_uf_empresa no_municipio_empresa setor_empresa no_curso 
vagas_demandadas_d, gen(new)
; #delimit cr
drop new

*7. diminish size 

*Level up
recast str14 cnpj
recast str2 no_uf_empresa
recast int vagas_demandadas_d 

format no_empresa no_curso %20s

*8. merge 
*merge with municipios
merge m:1 no_municipio_empresa no_uf_empresa using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m

*merge with co_curso
merge m:1 no_curso using "${NEWDATA}guia_FIC_4.dta"
drop if _m==2
drop _m

order cnpj no_empresa co_municipio_empresa no_uf_empresa no_municipio_empresa ///
setor_empresa co_curso no_curso

sort cnpj no_empresa co_municipio_empresa setor_empresa co_curso 

*collapse
collapse(sum) vagas_demandadas_d, by (cnpj no_empresa setor_empresa ///
co_municipio_empresa co_curso ano)

duplicates tag cnpj no_empresa co_municipio_empresa ///
setor_empresa co_curso ano, gen(new)
drop if new>0
drop new

order cnpj no_empresa co_municipio_empresa setor_empresa co_curso vagas_demandadas_d ano

*9. compress
compress 

save "${NEWDATA}demanda_2016.dta", replace

********************************************************************************
********************************Supply (2016)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}homologacao_empresas_2016.dta", clear

*1. drop useless variables ou string muito grandes
drop iddamodalidade iddoproponente

*2. rename variables
#delimit;
renvars nomedaempresa nomecurso numerodevagassolicitadas iddocurso iddomunicípio
numerodevagashomologadasfi uf municipio setor 
\ 
no_empresa no_curso vagas_demandadas_h co_curso 
co_municipio_empresa vagas_homologadas no_uf_empresa no_municipio_empresa
setor_empresa
; #delimit cr

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
foreach x of varlist cnpj {
replace `x' = "." if `x' ==""
}
replace cnpj = subinstr(cnpj,"–","",.)
gen str14 cnpj1 = string(real(cnpj),"%014.0f")
replace cnpj = cnpj1
recast str14 cnpj
drop cnpj1

replace cnpj=""  if  length(cnpj)<14 
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

*replace no_curso
replace no_curso ="gestor de microempresa" if no_curso=="empresário de micro empresa"

*replace setor_empresa
replace setor_empresa = "construção" if setor_empresa =="construção civil"
replace setor_empresa = "construção" if setor_empresa =="construção pesada"

*remove especial caracteres
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

*gen year
gen ano = 2016

*order variables
#delimit;
order cnpj no_empresa no_uf_empresa co_municipio_empresa 
no_municipio_empresa setor_empresa co_curso no_curso vagas_demandadas_h 
vagas_homologadas
; #delimit cr

*label variables
#delimit;
labvars no_empresa cnpj no_uf_empresa co_municipio_empresa 
no_municipio_empresa setor_empresa co_curso no_curso vagas_demandadas_h 
vagas_homologadas ano
\ "nome da empresa" "cnpj" "nome uf da empresa" "codigo municipio da empresa"
"nome municipio da empresa" "setor" "codigo do curso" "nome do curso" 
"vagas solicitadas" "vagas homologadas" "ano"
; #delimit cr

*sort variables
#delimit;
sort cnpj no_empresa no_uf_empresa co_municipio_empresa setor_empresa co_curso 
vagas_demandadas_h vagas_homologadas 
; #delimit cr

*drop impossible values
drop if vagas_demandadas_h==0

*6. drop duplicates 
*drop duplicates if entries are entirely the same (y/n)
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates drop `x' setor_empresa no_uf_empresa co_municipio_empresa no_municipio_empresa 
co_curso no_curso vagas_demandadas_h vagas_homologadas 
vagas_homologadas, force
; #delimit cr
}

*drop duplicates if vagas solicitadas são as mesmas mas as homologadas não (y/n) but which one to choose?
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa co_municipio_empresa no_municipio_empresa 
co_curso no_curso vagas_demandadas_h, gen(new`x')
; #delimit cr
drop if new==1 & vagas_homologadas==0
drop new*
}

*drop duplicates if vagas solicitadas variam (y/n) but which one to choose?
foreach y in . 20 {
foreach x in cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa co_municipio_empresa no_municipio_empresa 
co_curso no_curso, gen(new`x')
; #delimit cr
drop if new==1 & vagas_demandadas_h==`y'
drop new`x'
}
}

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

*merge with co_curso
merge m:1 no_curso using "${NEWDATA}guia_FIC_4.dta"
drop if _m==1 | _m==2
drop _m

order cnpj no_empresa co_municipio_empresa no_uf_empresa ///
no_municipio_empresa setor_empresa co_curso no_curso

sort cnpj no_empresa co_municipio_empresa setor_empresa co_curso

*collapse
collapse(sum) vagas_demandadas_h vagas_homologadas, by (cnpj no_empresa setor_empresa ///
co_municipio_empresa co_curso ano)

duplicates tag cnpj no_empresa co_municipio_empresa ///
setor_empresa co_curso, gen(new)
drop new

order cnpj no_empresa co_municipio_empresa setor_empresa co_curso vagas_demandadas_h vagas_homologadas ano

*9. compress
compress 

save "${NEWDATA}homologada_2016.dta", replace

******************************************************************************
*********************************MERGE 2016***********************************
******************************************************************************
use "${NEWDATA}demanda_2016.dta", clear
#delimit;
merge m:1 cnpj no_empresa co_municipio_empresa setor_empresa ///
co_curso using "${NEWDATA}homologada_2016.dta", force
; #delimit cr
sort _m
save "${NEWDATA}empresas_2016.dta", replace

*m_==1 -> matched on demand (firms only in demand)
*m_==2 -> matched on supply (firms only in homologacao)
*m_==3 -> matched on both

