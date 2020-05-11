***************************MERGE CURSOS DEMANDA -> OFERTA***********************
use "${IBGE}demanda_empresas.dta", clear

#delimit;
merge m:1 cnpj co_municipio_empresa co_curso ano
using "${IBGE}homologada_empresas.dta", force
; #delimit cr

drop if _m!=3
drop _m check nome10 cnpj_valido
format no_empresa %20s
order cnpj no_empresa setor_empresa co_municipio_empresa co_curso vagas_demandadas_d ///
vagas_demandadas_h vagas_homologadas

saveold "${IBGE}empresas.dta", replace version(11)

*****************************MERGE ALUNOS - > EMPRESAS**************************
use "${IBGE}alunos_MDIC_MEC.dta", clear
drop _m

merge m:1 co_turma ano using "${IBGE}demandante.dta"
drop if _m!=3
drop _m

destring municipio_ue_mec cnpj, replace

renvars municipio_ue_mec co_curso_mdic/ co_municipio_empresa co_curso

duplicates drop cnpj co_municipio_empresa co_curso ano, force

save "${IBGE}alunos_cnpj.dta", replace 

********************MERGE CURSOS DEMANDA-OFERTA -> ALUNOS***********************
use "${IBGE}empresas.dta", clear
destring cnpj, replace

merge m:1 cnpj co_municipio_empresa co_curso ano using "${IBGE}alunos_cnpj.dta"

drop if _m!=3
drop no_demandante_mdic no_demandante_mec 
drop _m
save "${IBGE}merge.dta", replace
