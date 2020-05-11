use "${IBGE}/deflator_mult_ipca_mensal.dta", clear

format mes_ano %10.0g
gen date = dofm(mes_ano)
format date %d
gen mes=month(date)
gen ano=year(date)
keep if mes==12
rename ano ano_rais
tempfile deflator_anual
save `deflator_anual', replace

*log using descriptives, replace
use "${BASE_TEMP}/Pronatec_data_strategy6_com_filtro_descritivas.dta"

*labor and wages (mes ano base 12/2016)
renvars sal_med_r \ wage_m 
sort ano_rais
merge m:1 ano_rais using `deflator_anual'
keep if _merge==3
drop _merge mes_ano date mes
replace wage_m	  = d_ipca*wage_m
gen	log_wage_m    =log(wage_m)

********************************************************************************
**********************************CONTROL GROUPS********************************
********************************************************************************

********************************************************************************
*Tratamento - Firma que demandou cursos X firma que não demandou cursos 
********************************************************************************
gen registration_rate = n_registrations_year/total_employment //taxa de inscrição entre os empregados da empresa
gen enrollment_rate = n_enrollments_year/total_employment

global controle_psm age male non_white ///
north north_east south_east south center_west ///
agro industry commerce construction service others ///
registration_rate ///
job_tenure_workers log_wage_m

*psmatch2 pronatec_firm $controle_psm, qui kernel logit common 
logit pronatec_firm $controle_psm, technique(bhhh 20 nr 10 dfp 10 bfgs 10) iterate(100)
predict pscore, pr

*sorting randomly
gen x=uniform()
sort x
drop x

psmatch2 pronatec_firm, pscore(pscore) out(r1) 
pstest age male non_white north north_east south_east south center_west agro industry commerce construction service others job_tenure_workers log_wage_m, both
tab pronatec_firm 
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
grc1leg before after, ycommon title("Firm: Propensity scores before vs. after matching")
 graph save "/Users/quinrod/Dropbox/Technical education and labor market/results/figures/firm_psm.gph", replace

sort cnpj ano_rais 

save "${IBGE}/Pronatec_data_strategy7_com_filtro_descritivas.dta", replace
 
*******************************************************************************
********************************Diff-in-Diff***********************************
*******************************************************************************
foreach r in r1 r2{
use "${IBGE}/Pronatec_data_strategy7_com_filtro_descritivas.dta", clear
destring cnpj, gen(cnpj1)
tempfile cnpj_controle
save `cnpj_controle', replace
duplicates drop cnpj1 ano_rais, force
tsset cnpj1 ano_rais

gen time = ano_rais-first_demand 
gen post=0 if time<=0 
replace post=1 if time>0

br cnpj cnpj1 ano_rais first_demand first_homologa time post `r'_before `r'_after `r' _treated pronatec_firm 

*******************************************************************************
********************************Diff-in-Diff***********************************
*******************************************************************************
global controle age male white non_white ///
north north_east south_east south center_west ///
agro industry commerce construction service others ///
registration_rate total_employment ///
job_tenure_workers log_wage_m

summ(`r'_before) if _treated==1 
summ(`r'_before) if _treated==0
summ(`r'_after)  if _treated==1
summ(`r'_after)  if _treated==0

summ(`r'_before) if pronatec_firm==1 
summ(`r'_before) if pronatec_firm==0
summ(`r'_after)  if pronatec_firm==1
summ(`r'_after)  if pronatec_firm==0

*911 entender se pode usar post ou time
gen pronatec_post = _treated*post
xtreg `r' _treated post pronatec_post, vce(robust)
xtreg `r' _treated post pronatec_post $controle, vce(robust)

gen pronatec_time = _treated*time
xtreg `r' _treated time pronatec_time, vce(robust)
xtreg `r' _treated time pronatec_time $controle, vce(robust)
}

*log close
