clear all
set more off
use "${RAWDATA}alunos_MDIC.dta", clear

*rename variables 
#delimit;
renvars uf_da_ue municipio_da_ue codigo_da_oferta codigo_do_curso nome_curso_catalogo_guia
cod_da_unidade_de_ensino eixo_tecnologico_catalogo_guia subtipo_curso no_dependencia_admin no_subdependencia_admin
data_da_publicacao data_de_inicio data_de_previsaode_termino data_de_conclusao
dataprématricula datadeconfirmacao situacao_da_turma ch_catalogo_guia ch_da_oferta
no_parceiro_demandante vagas cpfaluno datadenascimentoaluno nomealuno sexodoaluno
cordapele escolaridadedoaluno escolaridade_catalogo_guia nomedasitmatriculasituacaodetalh
ds_identificador_turma
\ no_uf_ue no_municipio_ue co_turma co_curso no_curso co_ue no_eixo_tecnologico tipo_curso
dependencia_admin subdependencia_admin dt_publicacao dt_inicio dt_conclusao_prevista
dt_conclusao_real dt_prematricula dt_matricula st_turma ch_prevista ch_real 
no_demandante vagas_homologadas cpf dt_nascimento no_aluno sexo raca escolaridade_aluno
escolaridade_curso st_matricula_aluno no_turma
; #delimit cr 

*organize logic
#delimit;
order no_uf_ue no_municipio_ue co_ue   
uf_do_local_da_oferta municipio_do_local_da_oferta co_turma no_turma co_curso
no_curso edicao_catalogo_guia no_eixo_tecnologico tipo_curso dependencia_admin 
subdependencia_admin dt_publicacao dt_inicio 
dt_conclusao_prevista dt_conclusao_real st_turma ch_prevista ch_min_financiavel 
ch_max_financiavel ch_real valor_hora_aula_proposto no_demandante 
vagas_homologadas forma_ingresso oferta_cadastro_online 
total_conf_freq_aluno total_freq_aluno cpf dt_nascimento no_aluno 
sexo desempregado pcd escolaridade_aluno escolaridade_curso
raca dt_cadastro dt_prematricula dt_matricula
st_matricula_aluno 
; #delimit cr

*label variables
#delimit;
labvars no_uf_ue no_municipio_ue co_ue   
uf_do_local_da_oferta municipio_do_local_da_oferta co_turma co_curso
no_curso no_eixo_tecnologico tipo_curso 
dependencia_admin subdependencia_admin dt_publicacao 
dt_inicio dt_conclusao_prevista dt_conclusao_real st_turma ch_prevista 
ch_min_financiavel ch_max_financiavel ch_real valor_hora_aula_proposto 
no_demandante vagas_homologadas forma_ingresso 
oferta_cadastro_online total_conf_freq_aluno cpf dt_nascimento 
no_aluno sexo desempregado 
pcd escolaridade_aluno raca
dt_cadastro dt_prematricula dt_matricula
st_matricula_aluno edicao_catalogo_guia  
\ "UF unidade ensino" "municipio unidade ensino" 
"codigo IBGE unidade ensino" "UF local curso" 
"municipio local curso" "codigo da aula" "codigo curso" "nome curso" "area curso" 
"tipo curso TEC" "tipo provedor" "provedor sistema S" "data lancamento curso" "data inicio curso" 
"data previsao termino curso" "data conclusao curso" "situacao curso" "hrs previstas curso" 
"hrs min curso" "hrs max curso" "hrs reales curso" "valor hora por aula"
"nome demandante" "no de vagas homologadas" 
"forma de ingresso" "cadastro online" "frequencia de assistencia" 
"cpf aluno" "data nascimento" "nome aluno" "sexo" "desempregado" "cadeirante"   
"escolaridade" "cor pele" "data cadastro" "data pre-matricula" "data confirmacao matricula" 
"situacao aluno" "edicao curso"
; #delimit cr

*change names for codes
*municipios

foreach var of varlist municipio_do_local_da_oferta no_curso no_eixo_tecnologico ///
tipo_curso dependencia_admin subdependencia_admin st_turma no_municipio_ue ///
no_demandante forma_ingresso oferta_cadastro_online ///
escolaridade_aluno escolaridade_curso raca st_matricula_aluno {
gen Z=ustrlower(`var')
drop `var'
rename Z `var'
}

foreach var of varlist municipio_do_local_da_oferta no_municipio_ue {
replace `var'="santa bárbara d'oeste" if `var'=="santa bárbara d´oeste"
replace `var'="lambari d'oeste" if `var'=="lambari d´oeste"
replace `var'="taquaral de goiás" if `var'=="taquaral"
replace `var'="piraju" if `var'=="pirajú"
replace `var'="herval d'oeste" if `var'=="herval d´oeste"
replace `var'="dias d'ávila" if `var'=="dias d´ávila"
replace `var'="olho-d'água do borges" if `var'=="olho-d´água do borges"
replace `var'="são luís" if `var'=="são luis"
replace `var'="marabá" if `var'=="maraba"
replace `var'="santana do livramento" if `var'=="sant'ana do livramento"
replace `var'="machadinho d'oeste" if `var'=="machadinho d´oeste"
replace `var'="conquista d'oeste" if `var'=="conquista d´oeste"
replace `var'="içara" if `var'=="balneário rincão"
replace `var'="alta floresta d'oeste" if `var'=="alta floresta d´oeste"
replace `var'="alvorada d'oeste" if `var'=="alvorada d´oeste"
replace `var'="diamante d'oeste" if `var'=="diamante d´oeste"
replace `var'="espigão d'oeste" if `var'=="espigão d´oeste"
replace `var'="glória d'oeste" if `var'=="glória d´oeste"
replace `var'="itapejara d'oeste" if `var'=="itapejara d´oeste"
replace `var'="itaporanga d'ajuda" if `var'=="itaporanga d´ajuda"
replace `var'="mãe d'água" if `var'=="mãe d´água"
replace `var'="nova brasilândia d'oeste" if `var'=="nova brasilândia d´oeste"
replace `var'="olho d'água" if `var'=="olho d´água"
replace `var'="olho d'água das cunhãs" if `var'=="olho d´água das cunhãs"
replace `var'="olho d'água das flores" if `var'=="olho d´água das flores"
replace `var'="olho d'água do piauí" if `var'=="olho d´água do piauí"
replace `var'="olhos-d'água" if `var'=="olhos-d´água"
replace `var'="pau d'arco" if `var'=="pau d´arco"
replace `var'="santa luzia d'oeste" if `var'=="santa luzia d´oeste"
replace `var'="são felipe d'oeste" if `var'=="são felipe d´oeste"
replace `var'="são jorge d'oeste" if `var'=="são jorge d´oeste"
replace `var'="pérola d'oeste" if `var'=="pérola d´oeste"
replace `var'="são joão d'aliança" if `var'=="são joão d´aliança"
replace `var'="sítio d'abadia" if `var'=="sítio d´abadia"
replace `var'="tanque d'arca" if `var'=="tanque d´arca"
replace `var'="mirassol d'oeste" if `var'=="mirassol d´oeste"
}

replace uf_do_local_da_oferta="MA" if uf_do_local_da_oferta=="MG" & municipio_do_local_da_oferta=="vargem grande"

*merge with municipios
gen no_municipio_ue1=lower(no_municipio_ue)
drop no_municipio_ue
rename no_municipio_ue1 no_municipio_ue

merge m:1 no_uf_ue no_municipio_ue using "${RAWDATA}municipios.dta"
drop if _m==1 | _m==2
drop _m join f ds_email nu_telefone nu_telefone_celular mantenedora  

*format & recast
*cpf
format cpf %11.0f
tostring cpf, gen(cpf1) format(%011.0f) force 
drop cpf
rename cpf1 cpf
recast str11 cpf
gen byte notnumeric = real(cpf)==.
drop notnumeric

format no_curso %40s
recast str10 dt_publicacao 

*dates
foreach var of varlist dt_publicacao dt_inicio dt_conclusao_prevista ///
dt_conclusao_real dt_nascimento dt_prematricula dt_matricula {
gen Z = date(`var', "DMY")
format Z %td 
drop `var'
rename Z `var'
}


*Create group codes
foreach var of varlist st_turma dependencia_admin forma_ingresso ///
sexo desempregado pcd escolaridade_aluno escolaridade_curso ///
raca st_matricula_aluno {
encode `var', generate(Z)
drop `var'
rename Z `var'
}

#delimit;
order co_municipio_ue 
co_turma no_turma co_curso no_curso edicao_catalogo_guia 
no_eixo_tecnologico dependencia_admin dt_publicacao dt_inicio
dt_conclusao_prevista dt_conclusao_real st_turma ch_prevista 
ch_real vagas_homologadas forma_ingresso cpf no_aluno dt_nascimento 
sexo desempregado pcd escolaridade_aluno escolaridade_curso
raca dt_cadastro dt_prematricula dt_matricula 
st_matricula_aluno 
; #delimit cr

sort co_uf_ue co_municipio_ue co_turma co_curso

*************************************************************************
*****************************DEPURACION**********************************
*************************************************************************

*2. there are a lot of alunos wo cpf and names 
*action: check if when you changed format of cpf, you changed cpf (no, drop)
sort cpf
drop if cpf=="." & no_aluno==""

*3. some people have same name but different cpf - but seem to be different people indeed
*action: check in excel if they are duplicates
order co_uf_ue co_municipio_ue co_curso cpf no_aluno dt_nascimento
sort no_aluno co_municipio_ue co_curso cpf
duplicates tag no_aluno dt_nascimento, gen(new)
drop new

*4. same municipio, course, cpf, dates and situations
*action: drop
sort co_municipio_ue co_curso cpf
duplicates drop co_municipio_ue co_curso cpf ///
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real ///
st_turma ///
dt_cadastro dt_prematricula dt_matricula ///
st_matricula_aluno if cpf!=".", force

*5. same municipio, course, cpf, situations, forma_ingresso but diff date of confirmation
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso dt_cadastro dt_prematricula st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso dt_cadastro dt_prematricula 
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_matricula
by group: gen diff_dt_matricula=dt_matricula-dt_matricula[_n-1] 
by group: gen id=1 if dt_matricula==.
drop if id==1 & dup>0
drop if diff_dt_matricula<120 & dup>0
drop dup group diff_dt_matricula id

*6. same municipio, course, cpf, situations, forma_ingresso but diff date of prematricula
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso dt_cadastro st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso dt_cadastro 
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_prematricula
by group: gen diff_dt_prematricula=dt_prematricula-dt_prematricula[_n-1] 
by group: gen id=1 if dt_prematricula==.
drop if id==1 & dup>0
drop if diff_dt_prematricula<120 & dup>0
drop dup group diff_dt_prematricula id

*7. same municipio, course, cpf, situations, forma_ingresso but diff date of cadastro
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma forma_ingresso  
st_matricula_aluno) if dup>0
; #delimit cr

split dt_cadastro, parse (" ")
drop dt_cadastro dt_cadastro2
rename dt_cadastro1 dt_cadastro 
gen Z=date(dt_cadastro, "YMD")
format Z %td 
drop dt_cadastro
rename Z dt_cadastro

sort group dt_cadastro
by group: gen diff_dt_cadastro=dt_cadastro-dt_cadastro[_n-1] 
by group: gen id=1 if dt_cadastro==.
drop if id==1 & dup>0
drop if diff_dt_cadastro<120 & dup>0
drop dup group diff_dt_cadastro id

*8. same municipio, course, cpf, situations but diff date of confirmation
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma dt_cadastro dt_prematricula st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma dt_cadastro dt_prematricula 
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_matricula
by group: gen diff_dt_matricula=dt_matricula-dt_matricula[_n-1] 
by group: gen id=1 if dt_matricula==.
drop if id==1 & dup>0
drop if diff_dt_matricula<120 & dup>0
drop dup group diff_dt_matricula id

*9. same municipio, course, cpf, situations but diff date of prematricula
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma dt_cadastro st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma dt_cadastro 
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_prematricula
by group: gen diff_dt_prematricula=dt_prematricula-dt_prematricula[_n-1] 
by group: gen id=1 if dt_prematricula==.
drop if id==1 & dup>0
drop if diff_dt_prematricula<120 & dup>0
drop dup group diff_dt_prematricula id

*10. same municipio, course, cpf, situations but diff date of data of cadastro
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real
st_turma   
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_cadastro
by group: gen diff_dt_cadastro=dt_cadastro-dt_cadastro[_n-1] 
by group: gen id=1 if dt_cadastro==.
drop if id==1 & dup>0
drop if diff_dt_cadastro<120 & dup>0
drop dup group diff_dt_cadastro id

*11. same municipio, course, cpf, situations, forma_ingresso but diff date of conclusao
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista 
st_turma forma_ingresso st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista 
st_turma forma_ingresso  
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_conclusao_real
by group: gen diff_dt_conclusao_real=dt_conclusao_real-dt_conclusao_real[_n-1] 
by group: gen id=1 if dt_conclusao_real==.
drop if id==1 & dup>0
drop if diff_dt_conclusao_real<120 & dup>0
drop dup group diff_dt_conclusao_real id

*12. same municipio, course, cpf, situations, forma_ingresso but diff dt_conclusao_prevista
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio  
st_turma forma_ingresso st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio  
st_turma forma_ingresso  
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_conclusao_prevista
by group: gen diff_dt_conclusao_prevista=dt_conclusao_prevista-dt_conclusao_prevista[_n-1] 
by group: gen id=1 if dt_conclusao_prevista==.
drop if id==1 & dup>0
drop if diff_dt_conclusao_prevista<120 & dup>0
drop dup group diff_dt_conclusao_prevista id

*13. same municipio, course, cpf, situations, forma_ingresso, but diff dt_inicio
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao   
st_turma forma_ingresso st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao   
st_turma forma_ingresso  
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_inicio
by group: gen diff_dt_inicio=dt_inicio-dt_inicio[_n-1] 
by group: gen id=1 if dt_inicio==.
drop if id==1 & dup>0
drop if diff_dt_inicio<120 & dup>0
drop dup group diff_dt_inicio id

*14 same municipio, course, cpf, situations but diff date of conclusao
*action:drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista 
st_turma st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio dt_conclusao_prevista
st_turma 
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_conclusao_real
by group: gen diff_dt_conclusao_real=dt_conclusao_real-dt_conclusao_real[_n-1] 
by group: gen id=1 if dt_conclusao_real==.
drop if id==1 & dup>0
drop if diff_dt_conclusao_real<120 & dup>0
drop dup group diff_dt_conclusao_real id

*15. same municipio, course, cpf, situations but diff dt_conclusao_prevista 
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao dt_inicio  
st_turma st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao dt_inicio  
st_turma   
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_conclusao_prevista
by group: gen diff_dt_conclusao_prevista=dt_conclusao_prevista-dt_conclusao_prevista[_n-1] 
by group: gen id=1 if dt_conclusao_prevista==.
drop if id==1 & dup>0
drop if diff_dt_conclusao_prevista<120 & dup>0
drop dup group diff_dt_conclusao_prevista id

*16. same municipio, course, cpf, situations, but diff dt_inicio
*action: drop
#delimit;
bysort co_municipio_ue co_curso cpf
dt_publicacao   
st_turma st_matricula_aluno
: gen dup = cond(_N==1,0,_n)
; #delimit cr

#delimit;
egen group=group(co_municipio_ue co_curso cpf
dt_publicacao   
st_turma   
st_matricula_aluno) if dup>0
; #delimit cr

sort group dt_inicio
by group: gen diff_dt_inicio=dt_inicio-dt_inicio[_n-1] 
by group: gen id=1 if dt_inicio==.
drop if id==1 & dup>0
drop if diff_dt_inicio<120 & dup>0
drop dup group diff_dt_inicio id

recast str244 ds_tipo_beneficiario, force
recast str244 nome_da_uer, force

saveold "${IBGE}alunos_MDIC.dta", replace version(11)

