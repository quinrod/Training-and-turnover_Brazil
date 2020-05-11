clear all
set more off
********************************************************************************
********************************Demand (2014)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}demanda_empresas_2014.dta", clear

*1. drop useless variables ou string muito grandes
drop registro demandaprefencial vagasofertadasmdic ///
vagasofertadasmte vagasofertadasmds vagasaprovadasmecmdic vagasaprovadasmecmte ///
vagasaprovadasmecmds distribuidordevagasrepetidas ofertadomdic ofertadomte ///
ofertadomds aprovadomecpmdic aprovadomecpmte aprovadomecpmds ofertadomdicarred ///
aprovadomecpmdicarred totaldevagas

*2. rename variables 
#delimit;
renvars nomedaempresademandante nomedocurso uf município demanda setor
\ no_empresa no_curso no_uf_empresa no_municipio_empresa vagas_demandadas_d setor_empresa
; #delimit cr 

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
replace cbo="." if cbo==""
replace cbo = ustrrtrim(cbo)
replace cbo = ustrltrim(cbo)
replace cbo = subinstr(cbo,"-","",.)
replace cbo = subinstr(cbo,"NÃO ENCONTRADO","",.)
replace cbo = subinstr(cbo,"NÃO ENCONTREI","",.)
replace cbo = subinstr(cbo,"Não localizei","",.)
replace cbo = subinstr(cbo," ","",.)
replace cbo = subinstr(cbo,",","",.)
replace cbo = subinstr(cbo,"/","",.)
replace cbo = substr(cbo, 1, 6)

gen str6 cbo1 = string(real(cbo),"%06.0f")
replace cbo = cbo1
recast str6 cbo
drop cbo1
gen byte notnumeric = real(cbo)==.
drop notnumeric
destring cbo, replace

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

*replace setor
replace setor_empresa = "automotivo" if setor_empresa =="autopeças"
replace setor_empresa = "automotivo" if setor_empresa =="bicicletas"
replace setor_empresa = "automotivo" if setor_empresa =="brinquedos"
replace setor_empresa = "fármacos" if setor_empresa =="complexo da saúde"
replace setor_empresa = "confecções e têxtil" if setor_empresa =="confecção"
replace setor_empresa = "máquinas e equipamentos" if setor_empresa =="defesa"
replace setor_empresa = "comércio" if setor_empresa =="gemas e jóias"
replace setor_empresa = "higiene, perfumaria e cosméticos" if setor_empresa =="hppc"
replace setor_empresa = "metalurgia e siderurgia" if setor_empresa =="metalurgia"
replace setor_empresa = "máquinas e equipamentos" if setor_empresa =="naval"
replace setor_empresa = "celulose e papel" if setor_empresa =="papel e celulose"
replace setor_empresa = "celulose e papel" if setor_empresa =="pepel e celulose"
replace setor_empresa = "química" if setor_empresa =="químico"
replace setor_empresa = "logística portuária e aeroportuária" if setor_empresa =="serviços logísticos"
replace setor_empresa = "metalurgia e siderurgia" if setor_empresa =="siderurgia"
replace setor_empresa = "confecções e têxtil" if setor_empresa =="têxtil"
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

*replace municipios
replace no_municipio_empresa ="santa bárbara d'oeste" if no_municipio_empresa =="santa bárbara d´oeste"
replace no_municipio_empresa ="dias d'ávila" if no_municipio_empresa =="dias d´ávila"
replace no_municipio_empresa ="herval d'oeste" if no_municipio_empresa =="herval d´oeste"
replace no_municipio_empresa ="lambari d'oeste" if no_municipio_empresa =="lambari d´oeste"
replace no_municipio_empresa ="machadinho d'oeste" if no_municipio_empresa =="machadinho d´oeste"
replace no_municipio_empresa ="mirassol d'oeste" if no_municipio_empresa =="mirassol d´oeste"
replace no_municipio_empresa ="conquista d'oeste" if no_municipio_empresa =="conquista d´oeste"
replace no_municipio_empresa ="içara" if no_municipio_empresa =="balneário rincão"

*5. organize data
#delimit;
order cnpj no_empresa no_uf_empresa no_municipio_empresa setor_empresa no_curso 
cbo vagas_demandadas_d 
; #delimit cr 

*gen year
gen ano = 2014

*label variables
#delimit;
labvars no_empresa cnpj no_curso no_uf_empresa no_municipio_empresa setor_empresa 
vagas_demandadas_d cbo ano
\ "nome da empresa" "cnpj" "nome do curso" "nome uf da empresa" 
"nome municipio da empresa" "setor_empresa" "vagas solicitadas" "ocupacao" "ano"
; #delimit cr

*sort variables
sort cnpj no_uf_empresa no_curso cbo vagas_demandadas_d

*drop impossible values
drop if vagas_demandadas_d==0

*6. drop duplicates 
*drop duplicates if if vagas solicitadas is the same (y/n) *cbo vs nome_do_curso
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor no_uf_empresa no_municipio_empresa no_curso 
vagas_demandadas_d, gen(new`x')
; #delimit cr
}
drop new*

*drop duplicates if no_curso is the same (y/n) but vaga solicitada varia *cbo vs nome_do_curso 
*but which one you take as valid?
foreach x of varlist cnpj no_empresa {
#delimit;
duplicates tag `x' setor_empresa no_uf_empresa no_municipio_empresa no_curso, gen(new`x')
; #delimit cr
}
drop new*

*7. diminish size 
recast str14 cnpj
recast str2 no_uf_empresa
recast int vagas_demandadas_d 
format no_empresa no_municipio_empresa no_curso %20s

*8. merge 
*merge with municipios
merge m:1 no_municipio_empresa no_uf_empresa using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m

*merge with co_curso
merge m:1 no_curso using "${NEWDATA}guia_FIC_3.dta"
drop if _m==2
drop _m

order cnpj no_empresa no_uf_empresa co_municipio_empresa no_municipio_empresa ///
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

save "${NEWDATA}demanda_2014.dta", replace

********************************************************************************
********************************Supply (2014)***********************************
********************************************************************************
do "${DO}Validacao_cpf_pis_cnpj-v2.do"

use "${RAWDATA}homologacao_empresas_2014.dta", clear


*1. drop useless variables ou string muito grandes

*2. rename variables
#delimit;
renvars nomedaempresademandante cód_curso nomedocurso uf município demanda homologado setor
\ no_empresa co_curso no_curso no_uf_empresa no_municipio_empresa 
vagas_demandadas_h vagas_homologadas setor_empresa
; #delimit cr

*3. lowercase
foreach var of varlist no_empresa setor_empresa no_curso no_municipio_empresa {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

*4. remove special characters, destring and encode
replace cbo="." if cbo==""
replace cbo = ustrrtrim(cbo)
replace cbo = ustrltrim(cbo)
replace cbo = subinstr(cbo,"-","",.)
replace cbo = subinstr(cbo,"NÃO ENCONTRADO","",.)
replace cbo = subinstr(cbo,"NÃO ENCONTREI","",.)
replace cbo = subinstr(cbo,"Não localizei","",.)
replace cbo = subinstr(cbo," ","",.)
replace cbo = subinstr(cbo,",","",.)
replace cbo = subinstr(cbo,"/","",.)
replace cbo = substr(cbo, 1, 6)

gen str6 cbo1 = string(real(cbo),"%06.0f")
replace cbo = cbo1
recast str6 cbo
drop cbo1
gen byte notnumeric = real(cbo)==.
drop notnumeric
destring cbo, replace

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
replace no_municipio_empresa ="santa bárbara d'oeste" if no_municipio_empresa =="santa bárbara d´oeste"
replace no_municipio_empresa ="dias d'ávila" if no_municipio_empresa =="dias d´ávila"
replace no_municipio_empresa ="herval d'oeste" if no_municipio_empresa =="herval d´oeste"
replace no_municipio_empresa ="lambari d'oeste" if no_municipio_empresa =="lambari d´oeste"
replace no_municipio_empresa ="machadinho d'oeste" if no_municipio_empresa =="machadinho d´oeste"
replace no_municipio_empresa ="mirassol d'oeste" if no_municipio_empresa =="mirassol d´oeste"
replace no_municipio_empresa ="conquista d'oeste" if no_municipio_empresa =="conquista d´oeste"
replace no_municipio_empresa ="içara" if no_municipio_empresa =="balneário rincão"

*replace setor_empresa
replace setor_empresa = "automotivo" if setor_empresa =="autopeças"
replace setor_empresa = "automotivo" if setor_empresa =="bicicletas"
replace setor_empresa = "automotivo" if setor_empresa =="brinquedos"
replace setor_empresa = "fármacos" if setor_empresa =="complexo da saúde"
replace setor_empresa = "confecções e têxtil" if setor_empresa =="confecção"
replace setor_empresa = "máquinas e equipamentos" if setor_empresa =="defesa"
replace setor_empresa = "comércio" if setor_empresa =="gemas e jóias"
replace setor_empresa = "higiene, perfumaria e cosméticos" if setor_empresa =="hppc"
replace setor_empresa = "metalurgia e siderurgia" if setor_empresa =="metalurgia"
replace setor_empresa = "máquinas e equipamentos" if setor_empresa =="naval"
replace setor_empresa = "celulose e papel" if setor_empresa =="papel e celulose"
replace setor_empresa = "química" if setor_empresa =="químico"
replace setor_empresa = "logística portuária e aeroportuária" if setor_empresa =="serviços logísticos"
replace setor_empresa = "metalurgia e siderurgia" if setor_empresa =="siderurgia"
replace setor_empresa = "confecções e têxtil" if setor_empresa =="têxtil"
replace setor_empresa = "tic/complexo eletroeletrônico" if setor_empresa =="tic/complexo eletrônico"

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
order cnpj no_empresa no_uf_empresa no_municipio_empresa 
co_curso no_curso cbo vagas_demandadas_h vagas_homologadas 
; #delimit cr 

*drop useless variables
drop if vagas_demandadas_h==0

*gen year
gen ano = 2014

*label variables
#delimit;
labvars no_uf_empresa no_municipio_empresa co_curso
no_curso vagas_demandadas_h vagas_homologadas ano
\ "nome uf da empresa" "nome municipio da empresa" 
"codigo do curso" "nome do curso" "vagas solicitadas" "vagas homologadas" "ano"
; #delimit cr

*sort variables
#delimit;
sort cnpj no_uf_empresa co_curso cbo 
vagas_demandadas_h vagas_homologadas
; #delimit cr

*7. diminish size 
*level up
recast str14 cnpj
recast str2 no_uf_empresa
recast int vagas_demandadas_h 
format no_empresa no_municipio_empresa no_curso %20s

*8. merge 
*merge cursos
merge m:1 no_curso using "${NEWDATA}guia_FIC_3.dta"
drop if _m==2
drop _m

*merge with municipios
merge m:1 no_municipio_empresa no_uf_empresa using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m

order cnpj no_empresa no_uf_empresa co_municipio_empresa no_municipio_empresa ///
setor_empresa co_curso no_curso cbo vagas_demandadas_h vagas_homologadas 

sort cnpj no_empresa co_municipio_empresa setor_empresa co_curso

*collapse
collapse(sum) vagas_demandadas_h vagas_homologadas, by (cnpj no_empresa setor_empresa ///
co_municipio_empresa co_curso ano)

*6. drop duplicates 
duplicates tag cnpj no_empresa co_municipio_empresa ///
setor_empresa co_curso ano, gen(new)
drop new

order cnpj no_empresa co_municipio_empresa setor_empresa co_curso vagas_demandadas_h vagas_homologadas ano

*9. compress
compress 

save "${NEWDATA}homologada_2014.dta", replace

******************************************************************************
*********************************MERGE 2014***********************************
******************************************************************************

use "${NEWDATA}demanda_2014.dta", clear
#delimit;
merge m:1 cnpj no_empresa co_municipio_empresa setor_empresa co_curso 
using "${NEWDATA}homologada_2014.dta", force
; #delimit cr
sort _m

compress 

save "${NEWDATA}empresas_2014.dta", replace

*m_==1 -> matched on both
*m_==2 -> matched on demand (firms only in demand)
*m_==3 -> matched on supply (firms only in homologacao)

*Some m_3 and m_2 maybe the same, but vagas_demandadas vary

sort cnpj no_empresa co_municipio_empresa setor_empresa co_curso _m
br if _m==1 | _m==2
