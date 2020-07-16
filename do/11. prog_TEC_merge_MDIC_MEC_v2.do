
* Juntando bases

***********************Avaliacao da base MDIC e MEC  ********************************
foreach base in mdic mec {
	di as white "Working whith data <`base'>"
	
	* Global of datas with correct logic ordem
	global datas_mdic dt_nascimento dt_cadastro dt_prematricula dt_matricula dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real        
	global datas_mec  dt_nascimento 			dt_prematricula  			  			   dt_inicio dt_conclusao_prevista dt_conclusao_real dt_inicio_vigencia

	use "${IBGE}/alunos_`base'_v2.dta", clear
	
	if "`base'"=="mec" drop dt_matricula
	*Cleaning datas (removing impossible values)
	local aux_local ${datas_`base'}
	foreach var of varlist `aux_local' {
		cap drop D_impossible_year
		display as yellow "`var'"
		qui if "`var'"=="dt_nascimento" {
			* Considerando valores absurdos <1918 (100 anos)
			gen D_impossible_year 	= !inrange(year(`var'),1918,2003) & year(`var')!=.
			
			* Counting impossible values
			qui count 					if D_impossible_year
			display as white "	`r(N)' valores impossiveis	"
			
			* Replacing impossible values
			replace dt_nascimento=. 	if D_impossible_year
		}
		qui else {
			* valores fora da politica absurdos intervalo do prontatec
			gen D_impossible_year	= !inrange(year(`var')	,2011,2018) & year(`var')!=. 
			
			* Counting impossible values
			count 					if D_impossible_year
			display as white "	`r(N)' valores impossiveis"
			
			* Replacing impossible values
			replace `var'	=. 		if D_impossible_year
		}
	}

	qui count
	display as yellow "Original data has `r(N)' observation"

	* Testando se alguma variavel e estritamente maior que a outra
	foreach i of numlist 1/`=wordcount("`aux_local'")' {
		foreach j of numlist 1/`=wordcount("`aux_local'")' {
			if `i'< `j' {

				local data_1 "`=word("${datas_`base'}",`i')'"
				local data_2 "`=word("${datas_`base'}",`j')'"
				di as yellow "`data_1' >= `data_2'"
				
				qui {
					cap drop aux_var
					gen  aux_var= (`data_1'-`data_2')>0 if `data_1'!=. & `data_2'!=.
					sum aux_var
					local mean=round(r(mean),0.001)
					count if `data_1'!=.
					local N_1 =r(N)		
					count if `data_2'!=.
					local N_2 = r(N)
					count if aux_var!=.
					local N_diff = r(N)
				}
				di as white  "	P=`mean'  [N_1=`N_1'; N_2=`N_2'; N_3=`N_diff']"
				
				* Dropping observation ( criterio se a relacao for menor que 0.1% entao missing)
				if `mean' <=0.001 drop if aux_var==1
			}
		}
	}
	qui count
	display as yellow "Filtered data has `r(N)' observation"

	qui drop aux*
	
	*Ajuste situacao do aluno
	cap drop st_registro_atual

	foreach var of varlist st_matricula_aluno st_turma {
		cap drop aux_var
		decode  `var' , gen(aux_var)
		drop 	`var'
		rename aux_var `var'
	}

	* Removing especial caractere, acento, "ç"
	remove_special_caractere st_matricula_aluno st_turma , name(1) label(1) value(1)

	rename st_turma aux_st_turma

	* Criando st turma numerico
	gen 	st_turma = 1  if aux_st_turma == "cancelada"
	replace st_turma = 2  if aux_st_turma == "concluida"
	replace st_turma = 3  if aux_st_turma == "confirmada"
	replace st_turma = 4  if aux_st_turma == "criada"
	replace st_turma = 5  if aux_st_turma == "iniciada"
	replace st_turma = 6  if aux_st_turma == "publicada"

	* Ajuste da situacao do aluno
	gen 	st_aluno = 1  if st_matricula_aluno == "abandono"
	replace st_aluno = 2  if st_matricula_aluno == "aguard_conf"
	replace st_aluno = 3  if st_matricula_aluno == "canc_desistente"
	replace st_aluno = 4  if st_matricula_aluno == "canc_mat_prim_opcao"
	replace st_aluno = 5  if st_matricula_aluno == "canc_sancao"
	replace st_aluno = 6  if st_matricula_aluno == "canc_sem_freq_inicial"
	replace st_aluno = 7  if st_matricula_aluno == "canc_turma"
	replace st_aluno = 8  if st_matricula_aluno == "can_por_nao_confirmacao_frequencia_3_meses"
	replace st_aluno = 9  if st_matricula_aluno == "concluida"
	replace st_aluno = 10 if st_matricula_aluno == "confirmada"
	replace st_aluno = 11 if st_matricula_aluno == "doc_insufic"
	replace st_aluno = 12 if st_matricula_aluno == "em_curso"
	replace st_aluno = 13 if st_matricula_aluno == "em_dependencia"
	replace st_aluno = 14 if st_matricula_aluno == "escol_insufic"
	replace st_aluno = 15 if st_matricula_aluno == "freq_inic_insuf"
	replace st_aluno = 16 if st_matricula_aluno == "inc _itinerario"
	replace st_aluno = 17 if st_matricula_aluno == "insc_canc"
	replace st_aluno = 18 if st_matricula_aluno == "integralizada"
	replace st_aluno = 19 if st_matricula_aluno == "nao_compareceu"
	replace st_aluno = 20 if st_matricula_aluno == "nao matriculado"
	replace st_aluno = 21 if st_matricula_aluno == "prioritario"
	replace st_aluno = 22 if st_matricula_aluno == "reprovada"
	replace st_aluno = 23 if st_matricula_aluno == "trancada"
	replace st_aluno = 24 if st_matricula_aluno == "transf_ext"
	replace st_aluno = 25 if st_matricula_aluno == "transf_int"
	replace st_aluno = 26 if st_matricula_aluno == "turma_canc"
	replace st_aluno = 27 if st_matricula_aluno == "vagas_insufic"

	gen 	st_aluno_cat = 1 if inlist(st_aluno,1 , 5 , 15)
	replace st_aluno_cat = 2 if inlist(st_aluno,3 , 6 , 7 , 8 , 21)
	replace st_aluno_cat = 3 if inlist(st_aluno,9 , 18, 22)
	replace st_aluno_cat = 4 if inlist(st_aluno,10, 12)
	replace st_aluno_cat = 5 if inlist(st_aluno,4 , 13, 23, 24, 25)
	replace st_aluno_cat = 6 if inlist(st_aluno,2 , 11, 14, 16, 17, 19, 26, 27)
	replace st_aluno_cat = 7 if inlist(st_aluno,20)

	drop if st_aluno ==.
			
	*Preparing to merge
	cap rename municipio_do_local_da_oferta 	municipio_oferta
	cap rename co_adesao_sisu_tecnico_edital	co_adesao_sisu_edital
	cap rename st_matricula_aluno_categoria		st_matricula_aluno_cat
	* Preparing to merge
	*rename * *_`base'
	*rename cpf_`base'			cpf
	*rename matricula_`base'	matricula
	
	sort cpf matricula
	
	compress
	save "${BASE_TEMP}/aluno_`base'_filter_data.dta",replace
}

*** Step 2 (getting the most import var on each data) ***

* Preparing base mdic to merge
use "${BASE_TEMP}/aluno_mec_filter_data.dta",clear

* Dummy deficiencia
gen byte D_pcd=pcd=="SIM"
	label var D_pcd "dummy se o trabalhador possui deficiencia"

* Variaveis menos relevantes 
drop  no_aluno no_aluno check st_matricula_aluno st_matricula_aluno_cat  aux_st_turma  D_impossible_year  pcd

* Variaveis escolhidas do MDIC
drop  co_ue 

* Removing especial caractere, acento, "ç"
remove_special_caractere *, name(1) label(1) value(1)

foreach var of varlist no_ue no_turma {
	cap drop aux_var
	rename `var' aux_var
	encode aux_var, gen(`var') 
	drop aux_var
}

* Renaming to merge
rename * *_mec
rename cpf_mec 	  cpf
rename matricula_mec matricula

compress

* Eliminating missing cpf
drop if cpf==""
sort cpf matricula 

save "${BASE_TEMP}/aluno_mec_to_merge.dta",replace

* Preparing base mdic to merge
use "${BASE_TEMP}/aluno_mdic_filter_data.dta",clear

drop no_turma no_aluno no_municipio_ue edital no_municipio_ue aux_st_turma st_matricula_aluno D_impossible_year tag_mat

* Variaveis escolhidas do MEC
drop co_curso co_municipio_ue co_turma co_uf_ue dependencia_admin escolaridade_aluno no_curso 				
drop no_demandante no_eixo_tecnologico  no_uf_ue raca sexo subdependencia_admin turno  vagas_homologadas
* Removing especial caractere, acento, "ç"
remove_special_caractere *, name(1) label(1) value(1)

* Renaming to merge
rename * *_mdic
rename cpf_mdic 	  cpf
rename matricula_mdic matricula

compress

* Eliminating missing cpf
drop if cpf==""
sort cpf matricula 

merge 1:1 cpf matricula using "${BASE_TEMP}/aluno_mec_to_merge.dta"
drop if _merge==1

* MEC tem 650 mil a mais apenas... Nao deve ser so mdic
count if _merge==3

corr dt*
corr dt_nascimento* dt_prematricula* dt_inicio* dt_conclusao_prevista* dt_conclusao*

* Apos reduzir as duplas de analise. vou decidir olhando uma a uma qual data e melhor
count if dt_nascimento_mec!=dt_nascimento_mdic & _merge==3
*bro dt_nascimento_mec dt_nascimento_mdic  	 if dt_nascimento_mec!=dt_nascimento_mdic & _merge==3

* O preenchimento da variavel do MEC e um pouco melhor
gen 		dt_nascimento = dt_nascimento_mec
replace		dt_nascimento = dt_nascimento_mdic if dt_nascimento==.

/*- dt_prematricula- */
count if dt_prematricula_mec!=dt_prematricula_mdic & _merge==3
*bro dt_prematricula_mec dt_prematricula_mdic  	 if dt_prematricula_mec!=dt_prematricula_mdic & _merge==3

gen dt_prematricula=dt_prematricula_mec

/*- dt_prematricula- */
count if dt_inicio_mec!=dt_inicio_mdic & _merge==3
gen  diff_inicio=dt_inicio_mec-dt_inicio_mdic if dt_inicio_mec!=dt_inicio_mdic & _merge==3

gen 	dt_inicio=dt_inicio_mec
replace dt_inicio=dt_inicio_mec if !inrange(dt_inicio_mec ,dt_prematricula_mec ,dt_conclusao_prevista_mec ) & diff_inicio!=. & inrange(dt_inicio_mdic,dt_cadastro_mdic,dt_conclusao_prevista_mdic)

/*- dt_conclusao real -*/
gen 	dt_conclusao_real = dt_conclusao_real_mec
replace dt_conclusao_real = dt_conclusao_real_mdic  if dt_conclusao_real		==.

/*- dt_conclusao_prevista -*/
count 		 if dt_conclusao_prevista_mec!=dt_conclusao_prevista_mdic & _merge==3
bro dt_conclusao* dt_conclusao_prevista_mdic 	 if dt_conclusao_prevista_mec!=dt_conclusao_prevista_mdic & _merge==3

gen 	dt_conclusao_prevista = dt_conclusao_prevista_mec
gen aux_mod1=abs(dt_conclusao_prevista_mdic	-dt_conclusao_real)
gen aux_mod2=abs(dt_conclusao_prevista_mec	-dt_conclusao_real)

replace dt_conclusao_prevista = dt_conclusao_prevista_mdic  	if aux_mod1<aux_mod2 & (aux_mod1!=. & aux_mod2!=.)
replace dt_conclusao_prevista = dt_conclusao_prevista_mdic   	if dt_conclusao_prevista==.

/* Datas que tem apenas em uma base -*/
gen dt_cadastro			= dt_cadastro_mdic
gen dt_matricula		= dt_matricula_mdic
gen dt_inicio_vigencia	= dt_inicio_vigencia_mec
gen dt_publicacao		= dt_publicacao_mdic

* Check final
drop dt*mec dt*_mdic aux*

global datas_final dt_nascimento dt_cadastro dt_prematricula dt_matricula dt_publicacao dt_inicio dt_conclusao_prevista dt_conclusao_real  dt_inicio_vigencia

format %td $datas_final
order 	   $datas_final, after(st_aluno_mec)

* Testando se alguma variavel e estritamente maior que a outra
foreach i of numlist 1/`=wordcount("$datas_final")' {
	foreach j of numlist 1/`=wordcount("$datas_final")' {
		if `i'< `j' {

			local data_1 "`=word("${datas_final}",`i')'"
			local data_2 "`=word("${datas_final}",`j')'"
			di as yellow "`data_1' >= `data_2'"
			
			qui {
				cap drop aux_var
				gen  aux_var= (`data_1'-`data_2')>0 if `data_1'!=. & `data_2'!=.
				sum aux_var
				local mean=round(r(mean),0.001)
				count if `data_1'!=.
				local N_1 =r(N)		
				count if `data_2'!=.
				local N_2 = r(N)
				count if aux_var!=.
				local N_diff = r(N)
			}
			di as white  "	P=`mean'  [N_1=`N_1'; N_2=`N_2'; N_3=`N_diff']"
			
			* Dropping observation ( criterio se a relacao for menor que 0.1% entao missing)
			if `mean' <=0.001 drop if aux_var==1
		}
	}
}

* Acho que as datas mais importantes sao
* dt_nascimento> dt_prematricula > dt_inicio > dt_conclusao_prevista
count if dt_nascimento < dt_prematricula <= dt_inicio < dt_conclusao_prevista & ( dt_nascimento!=. & dt_prematricula!=. & dt_inicio!=. & dt_conclusao_prevista!=.)
   
keep  if dt_nascimento < dt_prematricula <= dt_inicio < dt_conclusao_prevista & ( dt_nascimento!=. & dt_prematricula!=. & dt_inicio!=. & dt_conclusao_prevista!=.)
  

* Eliminating mistakes.
gsort cpf co_turma_mec co_curso_mec -dt_matricula -dt_prematricula -dt_cadastro
duplicates drop cpf co_turma_mec co_curso_mec, force

* Dropping unuselles information
drop if cpf==""
drop if vagas_homologadas==0

*  Extra vars
cap drop diff_inicio _merge aux_var

**** Gerando novos indicadores ****
egen N_matriculados_tentativas = sum(1)				 	, by(co_turma co_curso)
egen N_matriculados_feitas 	   = sum(dt_matricula!=.)	, by(co_turma co_curso)

* Auxiliar Dummies
gen D_vagas_esgotadas		=N_matriculados_feitas>=vagas_homologadas & vagas_homologadas!=.
gen D_vagas_sem_deman		=N_matriculados_feitas==0 & dt_conclusao_real==.
gen D_comecou_e_abandonou	=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec !=3
gen D_concluiu				=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec ==3

* Compressing
compress

save "${BASE_TEMP}/aluno_mec_mdic_data.dta",replace

* st_turma 						>>> ds_situacao_oferta
* st_matricula_aluno_categoria	>>> ds_categoria_situacao
* st_matricula_aluno			>>> ds_situacao_matricula
   