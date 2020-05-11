clear all
set more off

log using descriptives, replace

*In this database you have: 

*1. *Students that attempt registration at least once between 2011-2017 & (were hired by demanding 
	*firm or other firms at least once btw 2012-2016) 
		*keep if merge_cpf==3 & (merge_cnpj==3 | merge_cnpj==1)
		
*2. First attempt of students to Pronatec-course between 2014-2016
		*gsort cpf -tag_mdic dt_prematricula dt_matricula -D_comecou_e_abandonou -D_concluiu dt_conclusao_real 
		*duplicates drop cpf, force
		
***********************************************
use "${IBGE}/Pronatec_data_strategy2_com_filtro.dta", clear 

rename ano ano_rais
	*---------------------------------------------------------------------------
	 preserve
	*---------------------------------------------------------------------------
	
*Filter first observation of employment in rais (64.14% of obs dropped)
gsort cpf co_turma_mec co_curso_mec -dt_matricula -dt_prematricula -dt_cadastro
duplicates drop cpf, force
mata: 95667/149132

*Those who receive confirmation
gen register = dt_prematricula!=.
gen enroll = dt_matricula!=. if register==1

*Those who receive confirmation but dropout conditional on holding a prematricula
*gen D_comecou_e_abandonou	=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec!=3
gen dropout = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	(st_aluno_mec==1 | st_aluno_mec==3 | st_aluno_mec==8 | st_aluno_mec==15) & ///
    ((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

*Those who receive confirmation and graduate conditional on holding a prematricula
*gen D_concluiu=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec==3
gen graduate = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	st_aluno_cat_mec==3 & ///
	((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

label variable enroll "conf_matricula"
label variable dropout "drop out course"
label variable graduate "graduate course"

*Table 3. Students who register at least once for Pronatec-MDIC courses (2014 - 2016)
tabstat enroll dropout graduate, statistics(mean sd count) columns(statistics) varwidth(25)

*Table 4. Reasons for not receiving a confirmation (2014 - 2016)
tab st_aluno_cat_mec if enroll==0 & st_aluno_cat_mec != 3 & st_aluno_cat_mec !=4

********************************************************************************
******************************Table 5. Part I **********************************
********************************************************************************
	*---------------------------------------------------------------------------
	 restore
	*---------------------------------------------------------------------------

*condition only to those enrolled in courses demanded by firms in 2015-2016 (67.91% of obs dropped)
keep if cnpj_demandante_turma!="" 
mata: 101285/149132

*gen month and year of inicio and conclusao curso
foreach var of varlist dt_inicio dt_conclusao_real {
gen `var'_my=mofd(`var') 
format `var'_my %tm
}

*gen month and year of admissao and desligamento
foreach var in admissao desligamento {
destring mes_`var', replace
gen dt_`var'_my = ym(ano_rais, mes_`var')
format dt_`var'_my %tm 
}

*gen ano de inicio, conclusao e admissao
foreach var in inicio conclusao_real admissao {
gen ano_`var' = dofm(dt_`var'_my)
format ano_`var' %d
gen ano_`var'_y =year(ano_`var')
drop ano_`var'
}

*gen dummy employed at time of inicio curso (does not mean they were enrolled)
tempvar inicio_rais
gen `inicio_rais'=ano_inicio_y == ano_rais
gen D_empregado_inicio = inrange(dt_inicio_my,dt_admissao_my,dt_desligamento_my)  

*gen dummy of first time they are employed at time of inicio curso (does not mean they were enrolled)
bys cpf: gen byte first = 1 if (ano_inicio_y == ano_rais & D_empregado_inicio ==1) | (ano_inicio_y > ano_rais & ano_rais==2016 & D_empregado_inicio ==1)
replace first = 0 if first==.
bys cpf (`inicio_rais' ano_rais D_empregado_inicio): replace D_empregado_inicio=D_empregado_inicio[_N] 

*gen dummy employed at time of conclusao curso (does not mean they were enrolled)
tempvar conclusao_rais
gen `conclusao_rais'=ano_conclusao_real_y == ano_rais
gen D_empregado_conclusao = inrange(dt_conclusao_real_my,dt_admissao_my,dt_desligamento_my) 
bys cpf (`conclusao_rais' ano_rais D_empregado_conclusao): replace D_empregado_conclusao=D_empregado_conclusao[_N] 

/*
*gen dummy of first time they are employed at time of conclusao curso (does not mean they were enrolled)
bys cpf: gen byte first = 1 if (ano_conclusao_real_y == ano_rais & D_empregado_conclusao ==1) | (ano_conclusao_real_y > ano_rais & ano_rais==2016 & D_empregado_conclusao ==1)
replace first = 0 if first==.
bys cpf (`conclusao_rais' ano_rais D_empregado_conclusao): replace D_empregado_conclusao=D_empregado_conclusao[_N] 
*/

*gen dummy employed from inicio to conclusao
gen D_empregado_inicio_conclusao =  D_empregado_inicio == D_empregado_conclusao ///
if D_empregado_inicio!=0 | D_empregado_conclusao!=0

	*---------------------------------------------------------------------------
	 preserve
	*---------------------------------------------------------------------------

/*
*Filter first observation of employment at time of conclusao (80.47% of obs dropped)
keep if first==1
mata: 38507/47847
*/

*Filter first observation of employment in rais (68% of obs dropped)
gsort cpf co_turma_mec co_curso_mec -dt_matricula -dt_prematricula -dt_cadastro
duplicates drop cpf, force
mata: 41044/59706

*Those who receive confirmation
gen register = dt_prematricula!=.
gen enroll = dt_matricula!=. if register==1

*Those who receive confirmation but dropout conditional on holding a prematricula
*gen D_comecou_e_abandonou	=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec!=3
gen dropout = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	(st_aluno_mec==1 | st_aluno_mec==3 | st_aluno_mec==8 | st_aluno_mec==15) & ///
    ((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

*Those who receive confirmation and graduate conditional on holding a prematricula
*gen D_concluiu=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec==3
gen graduate = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	st_aluno_cat_mec==3 & ///
	((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

*gen dummy employed and enrolled during the course 
gen employed = D_empregado_inicio 
*gen employed = D_empregado_inicio == D_empregado_conclusao & (D_empregado_inicio !=0 | D_empregado_conclusao!=0)

*gen dummy employed by the same firm
gen employed_firm = employed==1 & cnpj==cnpj_demandante_turma

*gen dummy employed by the same firm and graduate
gen employed_firm_graduate = enroll==1 & employed_firm==1 & graduate==1

*gen dummy employed by the same firm but do not receive confirmation for admin reasons
gen employed_firm_admin = enroll==0 & employed_firm==1 & st_aluno_cat_mec==8 

label variable enroll "conf_matricula"
label variable dropout "drop out course"
label variable graduate "graduate course"
label variable employed "employed at course onset"
label variable employed_firm "employed by firm"
label variable employed_firm_graduate "employed and graduate"
label variable employed_firm_admin "employed but not enrolled for admin reasons"

*Table 5. Students registered in MDIC-requested courses (2015-2016)
tabstat employed employed_firm employed_firm_graduate employed_firm_admin, statistics(mean sd count) columns(statistics) varwidth(25)

	*---------------------------------------------------------------------------
	 restore
	*---------------------------------------------------------------------------

********************************************************************************
******************************Table 5. Part II **********************************
********************************************************************************
/*
*Filter first observation of employment in rais (68% of obs dropped)
gsort cpf co_turma_mec co_curso_mec -dt_matricula -dt_prematricula -dt_cadastro
duplicates drop cpf, force
mata: 41044/59706

*gen dummy of first time they are employed at time of conclusao curso (does not mean they were enrolled)
bys cpf: gen byte first = 1 if (ano_conclusao_real_y == ano_rais & D_empregado_conclusao ==1) | (ano_conclusao_real_y > ano_rais & ano_rais==2016 & D_empregado_conclusao ==1)
replace first = 0 if first==.
bys cpf (`conclusao_rais' ano_rais D_empregado_conclusao): replace D_empregado_conclusao=D_empregado_conclusao[_N] 
*/

*Filter first observation of employment at time of conclusao (80.47% of obs dropped)
keep if first==1
mata: 38507/47847


*Those who receive confirmation
gen register = dt_prematricula!=.
gen enroll = dt_matricula!=. if register==1

*Those who receive confirmation but dropout conditional on holding a prematricula
*gen D_comecou_e_abandonou	=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec!=3
gen dropout = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	(st_aluno_mec==1 | st_aluno_mec==3 | st_aluno_mec==8 | st_aluno_mec==15) & ///
    ((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

*Those who receive confirmation and graduate conditional on holding a prematricula
*gen D_concluiu=(dt_matricula!=. & dt_conclusao_real!=.) & st_aluno_cat_mec==3
gen graduate = (dt_matricula!=. & dt_conclusao_real!=.) & ///
	st_aluno_cat_mec==3 & ///
	((enroll==0 & register==0) | (enroll==1 & register==1)) if enroll==1

*gen dummy employed and enrolled during the course 
gen employed = D_empregado_inicio
*gen employed = D_empregado_inicio == D_empregado_conclusao & (D_empregado_inicio !=0 | D_empregado_conclusao!=0)

*gen dummy employed by the same firm
gen employed_firm = employed==1 & cnpj==cnpj_demandante_turma

*gen dummy employed by the same firm and graduate
gen employed_firm_graduate = enroll==1 & employed_firm==1 & graduate==1

*gen dummy employed by the same firm but do not receive confirmation for admin reasons
gen employed_firm_admin = enroll==0 & employed_firm==1 & st_aluno_cat_mec==8 

label variable enroll "conf_matricula"
label variable dropout "drop out course"
label variable graduate "graduate course"
label variable employed "employed at course onset"
label variable employed_firm "employed by firm"
label variable employed_firm_graduate "employed and graduate"
label variable employed_firm_admin "employed but not enrolled for admin reasons"

gen last_month = mdy(12, 31, 2017)
gen last_month1=mofd(last_month) 
format last_month1 %tm
gen employment_duration = dt_desligamento_my-dt_inicio_my
replace employment_duration = last_month1-dt_inicio_my if employment_duration==.

summ(employment_duration) if employed_firm_graduate==1 
summ(employment_duration) if employed_firm_admin==1 
log close 

save "${IBGE}/Pronatec_data_strategy1_com_filtro_descritivas.dta", replace 

********************************************************************************
******************************Table 6. Part I **********************************
********************************************************************************

/*
Variables included in PSM of SINE paper
the job tenure of the last employment link before treatment, race, age, 
education disaggregated in 11 categories, sector and occupation of last employment, 
type of registration or referral (regular or online), and state identifier.
*/

*Definir variaveis controle
foreach var in sexo cor grau_instr forma_ingresso_mdic {
destring `var', replace
}

*age
rename idade_trab age

*sex
tab sexo, gen(male)
renvars male1 male2 \ male female

*race
tab cor, gen(race)
renvars race1 race2 race3 race4 race5 race6 \ indigenous white dark yellow brown not_declared

*disabled
rename d_pcd_mec disabled

*location
gen uf=substr(co_municipio_ue_mec,1,2)

*education
gen byte unskilled 		= inlist(grau_inst,1,2,3,4)
gen byte semiskilled 	= inlist(grau_inst,5,6,7)
gen byte skilled 		= inlist(grau_inst,8,9,20,11)

tab grau_instr
replace grau_instr = 1 if inlist(grau_instr,1) 
replace grau_instr = 2 if inlist(grau_instr,2,3,4)
replace grau_instr = 3 if inlist(grau_instr,5) 
replace grau_instr = 4 if inlist(grau_instr,6) 
replace grau_instr = 5 if inlist(grau_instr,7) 
replace grau_instr = 6 if inlist(grau_instr,8) 
replace grau_instr = 7 if inlist(grau_instr,9) 
replace grau_instr = 8 if inlist(grau_instr,10)
replace grau_instr = 9 if inlist(grau_instr,11)

tab grau_instr, gen(educ)
renvars educ1 educ2 educ3 educ4 educ5 educ6 educ7 educ8 educ9 \ ///
illiterate MS_incomplete MS_complete HS_incomplete HS_complete college_incomplete college_complete master PhD

labvars illiterate MS_incomplete MS_complete HS_incomplete HS_complete college_incomplete college_complete master PhD \ ///
"Illiterate" "Middle school dropout/incomplete" "Middle school graduate" ///
"High school dropout/incomplete" "High school graduate" "College dropout/incomplete" ///
"College graduate" "Specialization" "PhD"

*occupation (a 2 digitos ou 1)
gen great_cbo 		= substr(cbo_2002,1,1)
label var great_cbo 	"Great group CBO [1 digit]"
gen sub_cbo_main	= substr(cbo_2002,1,2)
label var sub_cbo_main 	"Main subgroup CBO [2 digits]"
gen sub_cbo			= substr(cbo_2002,1,3)
label var sub_cbo 		"Subgroup CBO [3 digits]"
drop cbo_2002

*econ activity (a 2  digitos ou nivel sector)
gen cnae2d= substr(cnae20,1,2)

gen 	great_sectors="0" if inrange(real(cnae2d),1,3)
replace great_sectors="1" if inrange(real(cnae2d),5,33)
replace great_sectors="2" if inrange(real(cnae2d),41,43)
replace great_sectors="3" if inrange(real(cnae2d),45,47)
replace great_sectors="4" if 	inlist(cnae20,"01610","01628","01636","02306","37011","37029","38114","38122") | inlist(cnae20,"38211","38220") | ///
								inlist(cnae20,"38319","38327","38394","39005","45200","45439","49116","49124") | ///
								inlist(cnae20,"49213","49221","49230","49248","49299","49302","49400","49507") | ///
								inlist(cnae20,"50114","50122","50211","50220","50301","50912","50998","51111") | ///
								inlist(cnae20,"51129","51200","52117","52125","52214","52222","52231","52290") | ///
								inlist(cnae20,"52311","52320","52397","52401","52508","53105","53202","61418") | ///
								inlist(cnae20,"61426","61434","61906","62015","62023","62031","62040","62091") | ///
								inlist(cnae20,"63119","63194","63917","63992","66118","66126","66134","66193") | ///
								inlist(cnae20,"66215","66223","66291","66304","68102","68218","68226","69117") | ///
								inlist(cnae20,"69206","70204","71111","71120","71197","71201","73114","73122") | ///
								inlist(cnae20,"73190","73203","74102","74200","74901","77110","77195","77217") | ///
								inlist(cnae20,"77225","77233","77292","77314","77322","77331","77390","77403") | ///
								inlist(cnae20,"78108","78205","78302","79112","79121","79902","80111","80129") | ///
								inlist(cnae20,"80200","80307","81117","81214","81222","81290","81303","82113") | ///
								inlist(cnae20,"82199","82202","82300","82911","82920","82997","85503","85911") | ///
								inlist(cnae20,"85929","85937","85996","90019","90027","90035","92003","93115") | ///
								inlist(cnae20,"93123","93131","93191","93212","93298","95118","95126","95215") | ///
								inlist(cnae20,"95291","96017","96025","96033","96092","38211","38220")
replace great_sectors="5" if  great_sectors==""  
			
label define labels_sector 0 "Agro" 1 "Industry" 2 "Commerce" 3 "Construction" 4 "Service" 5 "Others"
label var  great_sectors "0-Agro;1-Industry;2-Commerce;3-Construction;4-Service;5-Others"

gen		secao_cnae= "A" if inrange(real(cnae2d),1,4)
replace secao_cnae= "B" if inrange(real(cnae2d),5,9)
replace secao_cnae= "C" if inrange(real(cnae2d),10,33)
replace secao_cnae= "D" if inrange(real(cnae2d),35,35)
replace secao_cnae= "E" if inrange(real(cnae2d),36,39)
replace secao_cnae= "F" if inrange(real(cnae2d),41,43)
replace secao_cnae= "G" if inrange(real(cnae2d),45,48)
replace secao_cnae= "H" if inrange(real(cnae2d),49,53)
replace secao_cnae= "I" if inrange(real(cnae2d),55,56)
replace secao_cnae= "J" if inrange(real(cnae2d),58,63)
replace secao_cnae= "K" if inrange(real(cnae2d),64,66)
replace secao_cnae= "L" if inrange(real(cnae2d),67,68)
replace secao_cnae= "M" if inrange(real(cnae2d),69,75)
replace secao_cnae= "N" if inrange(real(cnae2d),77,82)
replace secao_cnae= "O" if inrange(real(cnae2d),84,84)
replace secao_cnae= "P" if inrange(real(cnae2d),85,85)
replace secao_cnae= "Q" if inrange(real(cnae2d),86,88)
replace secao_cnae= "R" if inrange(real(cnae2d),90,93)
replace secao_cnae= "S" if inrange(real(cnae2d),94,96)
replace secao_cnae= "T" if inrange(real(cnae2d),97,97)
replace secao_cnae= "U" if inrange(real(cnae2d),99,99)

encode secao_cnae, gen(secao_setor)
encode great_cbo_last_job, gen(great_cbo)
gen region=real(substr(uf,1,1))	
drop cnae20 

*labor and wages (mes ano base 12/2016)
renvars tempo_emprego sal_med_r \ job_tenure wage_m 

gen mes_ano=dt_inicio_my
sort mes_ano
merge m:1 mes_ano using "${dir_input}/../base auxiliares - dta/deflator_mult_ipca_mensal"
keep if _merge==3
drop _merge mes_ano
rename d_ipca d_ipca_time_hired

gen mes_ano=dt_desligamento_my
sort mes_ano
merge m:1 mes_ano using "${dir_input}/../base auxiliares - dta/deflator_mult_ipca_mensal"
keep if _merge==3
drop _merge mes_ano
rename d_ipca d_ipca_time_fired

gen d_ipca_sal_med= (d_ipca_time_fired+d_ipca_time_hired)/2 
replace wage_m	  = d_ipca_sal_med 	* wage_m
gen	log_wage_m  =log(wage_m)

drop  d_ipca_sal_med d_ipca_time_hired d_ipca_time_fired

*course attempts
renvars N_matriculas_tentativas N_matriculas_feitas ///
\ n_registrations n_enrollments 

*type of registration
tab forma_ingresso_mdic, gen(reg) 
renvars reg1 reg2 reg3 \ online_self_reg online_ministry_reg offline_ministry_reg

************************************************************************
*******************************CONTROL GROUPS***************************
************************************************************************
global controle age male female indigenous white dark yellow brown ///
illiterate MS_incomplete MS_complete HS_incomplete HS_complete college_incomplete college_complete ///
job_tenure wage_m n_registrations n_enrollments ///
online_self_reg online_ministry_reg offline_ministry_reg ///

*trat_b: B. Segunda melhor opcao: rejected for admin and employed by (requesting) firm at the beginning
gen trat_b = 0 if employed_firm_admin== 1
replace trat_b = 1 if employed_firm_graduate==1
tab trat_b

**Teste de mÈdias para caracteristicas dos alunos prÈ-tratamento usando a estratÈgia B:
foreach var in $controle{
di "			t-test for  --`var'--		"
display _newline(3)
ttest `var', by(trat_b) unequal
}

*trat_c: C. Terceira melhor opÁ„o: rejected for admin and not employed by (requesting) firm 
gen employed_not_firm = employed==1 & cnpj!=cnpj_demandante_turma
gen trat_c = 0 if employed_not_firm==1 & st_aluno_cat_mec==8
replace trat_c = 1 if employed_firm_graduate==1
tab trat_c

**Teste de mÈdias para caracteristicas dos alunos prÈ-tratamento usando a estratÈgia C:
foreach var in $controle{
di "			t-test for  --`var'--		"
display _newline(3)
ttest `var', by(trat_c) unequal
}

*trat_d: D. Quarta melhor opÁ„o: rejected for admin and employed by either the firm or sb else
gen trat_d = 0 if employed==1 & st_aluno_cat_mec==8
replace trat_d = 1 if employed_firm_graduate==1
tab trat_d

**Teste de mÈdias para caracteristicas dos alunos prÈ-tratamento usando a estratÈgia D:
foreach var in $controle{
di "			t-test for  --`var'--		"
display _newline(3)
ttest `var', by(trat_d) unequal
di "_______p-value: `r(p)'_______"


}


*trat_e: Quinta melhor opÁ„o: just employed by the (requesting) firm at the beginning
gen trat_e = 0 if employed_firm==1 
replace trat_e = 1 if employed_firm_graduate==1
tab trat_e

**Teste de mÈdias para caracteristicas dos alunos prÈ-tratamento usando a estratÈgia E:
foreach var in $controle{
di "			t-test for  --`var'--		"
display _newline(3)
ttest `var', by(trat_d) unequal
}



*trat_f: Sexta melhor opÁ„o: just employed in RAIS at the beginning
gen trat_f = 0 if employed==1 
replace trat_f = 1 if employed_firm_graduate==1
tab trat_f

**Teste de mÈdias para caracteristicas dos alunos prÈ-tratamento usando a estratÈgia F:
foreach var in $controle{
di "			t-test for  --`var'--		"
display _newline(3)
ttest `var', by(trat_d) unequal
}

**Aqui n„o adianta fazer o loop pois cada estratÈgia requer um balanceamento diferente.

********************************************************************************
*Tratamento C - 3ra melhor opÁ„o: rejected for administrative reasons and not employed by requesting firm at course onset
********************************************************************************

global controle_c age male dark brown white MS_compl n_registrations online_ministry_reg
*Construindo o grupo de controle para estratÈgia C:

psmatch2 trat_c $controle_c, qui kernel logit common 
pstest, both 
tab trat_c 
tab _treated

*graficos - propensity score before/after matching
* before
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0, ///
lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) ) ///
xtitle("propensity scores BEFORE matching") name(before, replace)

* after
twoway (kdensity _pscore if _treated==1 [aweight=_weight]) ///
(kdensity _pscore if _treated==0 [aweight=_weight] ///
, lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" )) ///
xtitle("propensity scores AFTER matching") name(after, replace)
* combined
grc1leg before after, ycommon title("Propensity scores before vs. after matching")
 graph export trat_c.pdf, as(pdf) replace

********************************************************************************
*Tratamento D - 4ta melhor opÁ„o:  rejected for administrative reasons and employed at course onset
********************************************************************************


*global variables for balancing
global controle_d age male white brown college_complete online_self_reg 

*Construindo o grupo de controle para estratÈgia D:
psmatch2 trat_d $controle_d, qui kernel logit common 
pstest, both 
tab trat_d 
tab _treated

*graficos - propensity score before/after matching
* before
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0, ///
lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) ) ///
xtitle("Propensity scores BEFORE matching") name(before, replace)

* after
twoway (kdensity _pscore if _treated==1 [aweight=_weight]) ///
(kdensity _pscore if _treated==0 [aweight=_weight] ///
, lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" )) ///
xtitle("Propensity scores AFTER matching") name(after, replace)

* combined
grc1leg before after, ycommon title("Propensity scores before vs. after matching")
 graph export trat_d.pdf, as(pdf) replace

********************************************************************************
*Tratamento E - 5ta melhor opÁ„o: employed by requesting firm at course onset
********************************************************************************
*1. Wage drop salarios inferiores a 100 reais ou missing
*2. trabalhadores com apenas 1 vinculo 
*3. idade

*global variables for balancing
global controle_e age male female indigenous white dark yellow brown ///
illiterate MS_incomplete MS_complete HS_incomplete HS_complete college_incomplete college_complete ///
job_tenure wage_m n_registrations n_enrollments ///
online_self_reg online_ministry_reg offline_ministry_reg ///

/*
global controle_e age male brown white dark MS_complete college_complete job_tenure wage_m online_self_reg 
*/

psmatch2 trat_e $controle_e, qui kernel logit common 
pstest, both
tab trat_e 
tab _treated

*graficos - propensity score before/after matching
* before
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0, ///
lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) ) ///
xtitle("Propensity scores BEFORE matching") name(before, replace)

* after
twoway (kdensity _pscore if _treated==1 [aweight=_weight]) ///
(kdensity _pscore if _treated==0 [aweight=_weight] ///
, lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" )) ///
xtitle("Propensity scores AFTER matching") name(after, replace)

* combined
grc1leg before after, ycommon title("Propensity scores before vs. after matching")
 graph export trat_e.pdf, as(pdf) replace

********************************************************************************
*Tratamento F - 6ta melhor opÁ„o: employed in RAIS at course onset
********************************************************************************


global controle_f age male dark yellow brown ///
MS_complete HS_incomplete college_complete ///
job_tenure wage_m n_registrations n_enrollments ///
online_self_reg offline_ministry_reg ///

*Construindo o grupo de controle para cada estratÈgia:
psmatch2 trat_f $controle_f, qui kernel logit common
pstest, both
tab trat_f 
tab _treated

*graficos - propensity score before/after matching
* before
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0, ///
lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" ) ) ///
xtitle("Propensity scores BEFORE matching") name(before, replace)

* after
twoway (kdensity _pscore if _treated==1 [aweight=_weight]) ///
(kdensity _pscore if _treated==0 [aweight=_weight] ///
, lpattern(dash)), legend( label( 1 "Treated") label( 2 "Control" )) ///
xtitle("Propensity scores AFTER matching") name(after, replace)

* combined
grc1leg before after, ycommon title("Propensity scores before vs. after matching")
 graph export trat_f.pdf, as(pdf) replace

log close 
