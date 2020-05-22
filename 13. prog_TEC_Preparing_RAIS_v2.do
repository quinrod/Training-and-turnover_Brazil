***************************MERGE CURSOS DEMANDA -> OFERTA***********************
global RAIS "C:\data-ready_to_use\rais\trabalhador"

global vars_rais cnpj_cei tipo_estab cpf ind_defic cnae20 municipio_estab tamanho_estab 		///
				 cbo_2002 sexo tipo* mes_admissao mes_desligamento peso tempo_emprego	///
				 grau_instr natureza_juridica idade_trab sal_med_r sal_dez_r sal_ultimo sal_contrat motivo* cor

foreach ano of numlist  2012/2016 {
	use $vars_rais using  "${RAIS}/Rais_trabalhador_`ano'.dta"  if tipo_estab=="1" ,clear
	drop tipo_estab
	gen int ano_rais=`ano'
	tempfile rais`ano'
	save `rais`ano'',replace
}

clear
foreach ano of numlist  2012/2016 {
	append using `rais`ano''
}

save "${BASE_TEMP}/rais_to_merge", replace





* Estrategia discutida em 26/01/2018 - Passos:
* 1-Tornar as bases de Demanda e homologacao a nivel de CNPJ
* 2-Juntar base de alunos com demanda(cnpj/co_curso)
* 3-Colocar a base a nivel de CPF
* 4-Juntar com a RAIS
*************** Etapa 1 - DEMANDA e HOMOLOGACAO ***********************

*global IBGE "C:\Users\Adm\Dropbox\Technical education and labor market\newdata\IBGE"
*global BASE_TEMP "C:\data-ready_to_use\BASE PRONATEC"
use "${IBGE}/demanda_empresas.dta", clear

*Dropping cnpj invalido 
drop if cnpj=="00000000000000"

* Sort to get the firt year
gsort cnpj ano

* Auxiliar variables to sum
gen n_cursos_demandados=1
bys cnpj ano :gen n_anos_demandados=_n==1

* Dropping vagas homologadas ==0
drop if vagas_demandadas_d==0

* Collapsing
collapse (sum) vagas_demandadas_d (sum) n_cursos_demandados n_anos_demandados (first) first_demand=ano , by(cnpj)

* Saving data to merge
sort cnpj
tempfile vagas_demandadas_to_merge
save `vagas_demandadas_to_merge', replace

/*- Vagas homologadas -*/
use "${IBGE}/homologada_empresas.dta", clear

*Dropping cnpj invalido 
drop if cnpj=="00000000000000"

* Sort to get the firt year
gsort cnpj ano

* Auxiliar variables to sum
gen n_cursos_homologados=1
bys cnpj ano :gen n_anos_homologados=_n==1

* Dropping vagas homologadas ==0
drop if vagas_homologadas==0

* Collapsing
collapse (sum) vagas_homologadas (sum) n_cursos_homologados n_anos_homologados (first) first_homologa=ano , by(cnpj)

* Merging with demand data
merge 1:1 cnpj using `vagas_demandadas_to_merge'

* Removendo empresas que homologaram sem demandar.
drop if _merge==1
drop _merge

* Replacing cases without homologacao
replace vagas_homologadas		=0 if vagas_homologadas		==.
replace n_cursos_homologados	=0 if n_cursos_homologados	==.
replace n_anos_homologados		=0 if n_anos_homologados	==.

* Ordering
order cnpj first_demand first_homologa  n_anos_demandados n_anos_homologados  vagas_demandadas_d vagas_homologadas  n_cursos_demandados n_cursos_homologados
 
* compressing
compress

* Saving
sort cnpj
save "${BASE_TEMP}/Demandas_homologacoes_to_merge",replace

*************** Etapa 2 - alunos e demandante ***********************
use  "${IBGE}/demandante.dta",clear

* Removendo duplicacoes ( existe alguns caos de dois demandantes pedirem o mesmo curso, vou ignorar)
duplicates drop co_turma , force

* Renaming
rename cnpj cnpj_demandante_turma
rename ano ano_demanda_turma
rename co_turma co_turma_mec

* sort to merge
sort co_turma_mec

* Base de alunos
merge 1:m co_turma_mec using "${BASE_TEMP}/aluno_mec_mdic_data.dta"
drop if _merge==1
drop _merge

*************** Etapa 3 - Colocar a base de alunos a nivel de cpf ***********************

* Transforming to cpf level.
gsort cpf -D_concluiu dt_conclusao_real -D_comecou_e_abandonou dt_matricula -D_vagas_esgotadas dt_prematricula

* Elimiando double information
duplicates drop cpf, force

*
encode tipo_curso_mdic		, gen(tipo_curso)
drop tipo_curso

encode tipo_da_oferta_mdic	,  gen(tipo_da_oferta)
drop tipo_da_oferta_mdic

* Eliminating vars
drop ch_max_financiavel_mdic ch_min_financiavel_mdic co_adesao_sisu_edital_mec co_aluno_mec co_etapa_mec co_far_pronatec_mec
drop dt_inicio_vigencia edicao_catalogo_guia_mdic extemporaneo_matricula_mec

* Compressing
compress

sort cpf
save  "${BASE_TEMP}/Alunos_to_merge.dta", replace 

*************** Etapa 4 - Juntar a RAIS ***********************
*Reading
use "${BASE_TEMP}/rais_to_merge" , clear

* Merging by cnpj with demand/supplay data
rename cnpj_cei cnpj
sort cnpj

* Merging (cnpj)
merge m:1 cnpj using "${BASE_TEMP}/Demandas_homologacoes_to_merge", gen(merge_cnpj)
drop if merge_cnpj==2

* Preparing to merge by cpf with data of student
sort cpf

* Merging (cpf)
merge m:1 cpf using "${BASE_TEMP}/Alunos_to_merge", gen(merge_cpf)
drop if merge_cnpj==2

* Identifying at least one pronatec student.
bys cnpj (merge_cpf): gen byte D_firm_prona=merge_cpf[_N]==3
	label var D_firm_prona "firm at least one pronatec student-hired before or after course"

* Keepping enterprise with at lest one pronatec student or cnpj
keep if merge_cnpj==3 | D_firm_prona==1

* works pronatec
egen N_works_pronatec=sum(merge_cnpj==3)
	label var N_works_pronatec "Number of works pronatec-anytime"

* Dummie to identify firms which demands
gen D_demandante=vagas_demandadas_d>=1 & vagas_demandadas_d!=.
gen D_homologado=vagas_homologadas >=1 & vagas_homologadas !=.
	
* compressing and saving
compress

save "C:\data-ready_to_use\BASE PRONATEC/Pronatec_data_estrategy_1_full",replace

do "C:\Users\Adm\Dropbox\do files\programs-2018-01\secundar programs/15. prog_TEC_filtros_rogrigo.do"

save "C:\data-ready_to_use\BASE PRONATEC/Pronatec_data_estrategy_1",replace

* Preparing sample (1 percent sample)
sample 1

save "C:\data-ready_to_use\BASE PRONATEC/Pronatec_data_estrategy_1_sample",replace

* Separing by year RAIS

foreach ano of numlist  2012/2016 {
	use "C:\data-ready_to_use\BASE PRONATEC/Pronatec_data_estrategy_1.dta"  if ano_rais==`ano' ,clear
	save "C:\data-ready_to_use\BASE PRONATEC/Pronatec_data_estrategy_1_`ano'",replace
}


