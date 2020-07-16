* Objective - Creating the data of demand of courses by firms
/*----------------		Demand (2014)	    ----------------*/

* Reading raw-data
import excel "${RAWDATA}/Cruzamento Demanda 2014 - Oferta SISTEC V.2 - BID.xlsx", sheet("Dados arredondados") case(lower) firstrow clear

* Dropping useless variables ou string muito grandes
drop registro demandaprefencial vagasofertadasmdic 								///
vagasofertadasmte vagasofertadasmds vagasaprovadasmecmdic vagasaprovadasmecmte 	///
vagasaprovadasmecmds distribuidordevagasrepetidas ofertadomdic ofertadomte 		///
ofertadomds aprovadomecpmdic aprovadomecpmte aprovadomecpmds ofertadomdicarred 	///
aprovadomecpmdicarred totaldevagas

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomedaempresademandante 	no_empresa
rename nomedocurso 				no_curso
rename codigodocurso			co_curso
rename uf 						no_uf_empresa
rename municipio 				no_municipio_curso
rename demanda 					vagas_demandadas_d
rename setor					setor_empresa
rename codigodomunicipio		co_municipio_curso

* Ajuste co_municipio
replace co_municipio_curso=4207007 if no_municipio_curso=="icara"

* Ajuste cbo
rename  cbo aux_cbo
gen cbo		 = real(substr(subinstr(aux_cbo, "-","",100),-6,6))
drop aux_cbo

* Adjusting CNPJ
replace cnpj = subinstr(cnpj,"/","",.)
replace cnpj = subinstr(cnpj,"-","",.)
replace cnpj = subinstr(cnpj,",","",.)
replace cnpj = subinstr(cnpj,".","",.)
replace cnpj = string(real(cnpj),"%014.0f")
replace cnpj = "" if cnpj=="."

* Validating code
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

*dropping
drop cnpj_ajustado _merge no_empresa
drop if cnpj==""

* Changing values of some var
replace_especific_values  no_municipio_curso setor_empresa

* year var
gen int ano = 2014

* drop impossible values
drop if vagas_demandadas_d==0

* diminish size 
compress

*collapse
collapse (sum) vagas_demandadas_d (first) setor_empresa, by(cnpj co_municipio_curso co_curso ano)

* Encoding
encode setor_empresa, gen(setor_aux)
drop setor_empresa
rename setor_aux setor_empresa


* Labeling vars
labels_vars

* Ordering
order cnpj co_municipio_curso setor_empresa co_curso vagas_demandadas_d ano

* Saving
saveold "${NEWDATA}/demanda_2014.dta", replace v(11)

/*----------------		Demand (2015)	    ----------------*/
import excel "${RAWDATA}/MAPA DE DEMANDA 2015.xlsx", sheet("demanda") firstrow case(lower) clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomedaempresademandante			no_empresa 
rename cnpjdaempresa 					cnpj
rename nomedocurso 						no_curso
rename uf 								no_uf_empresa
rename municipio 						no_municipio_curso
rename trabalhadorestotais 				vagas_demandadas_d
rename numerodetrabalhadoresquenece 	n_empregados_empresa
rename numerodetrabalhadoresquetrab 	empregados_empresa
rename codigodocurso 					co_curso
rename codigodomunicipio 				co_municipio_curso
rename setor 							setor_empresa       

* Destring
destring co_municipio_curso n_empregados_empresa, replace force

* Ajuste co_municipio
replace co_municipio_curso=4207007 if no_municipio_curso=="icara"

* Ajuste cbo
rename  cbo aux_cbo
gen cbo		 = real(substr(subinstr(aux_cbo, "-","",100),-6,6))
drop aux_cbo

* Adjusting CNPJ
replace cnpj = subinstr(cnpj,"/","",.)
replace cnpj = subinstr(cnpj,"-","",.)
replace cnpj = subinstr(cnpj,",","",.)
replace cnpj = subinstr(cnpj,".","",.)
replace cnpj = string(real(cnpj),"%014.0f")
replace cnpj = "" if cnpj=="."

* Validating code
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

*dropping
drop cnpj_ajustado _merge no_empresa
drop if cnpj==""

*gen year
gen ano = 2015

*label variables
labels_vars

*drop impossible values
drop if vagas_demandadas_d==0
drop if vagas_demandadas_d < empregados_empresa & empregados_empresa!=.
drop if vagas_demandadas_d < n_empregados_empresa & n_empregados_empresa!=.
gen vagas_demandadas_d1 = empregados_empresa+n_empregados_empresa
drop if vagas_demandadas_d1!=vagas_demandadas_d & vagas_demandadas_d1!=.
drop vagas_demandadas_d1

* Changing values of some var
replace_especific_values  setor_empresa

*collapse
collapse (sum) vagas_demandadas_d (first) setor_empresa , by(cnpj co_municipio_curso co_curso ano)

* Encoding
encode setor_empresa, gen(setor_aux)
drop setor_empresa
rename setor_aux setor_empresa


*Ordering
order cnpj co_municipio_curso setor_empresa co_curso vagas_demandadas_d ano

keep  cnpj co_municipio_curso setor_empresa co_curso vagas_demandadas_d ano

*9. compress
compress 

save "${NEWDATA}/demanda_2015.dta", replace

/*----------------		Demand (2016)	    ----------------*/
import excel "${RAWDATA}/1 - DEMANDA FIC 2016.xlsx", sheet("Demanda_geral_1e2_semestres") firstrow case(lower) clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename empresa          no_empresa 
rename nomecurso        no_curso 
rename uf               no_uf_empresa 
rename municipio        no_municipio_curso
rename trabtotais       vagas_demandadas_d
rename trabexternos     n_empregados_empresa
rename trabempresa      empregados_empresa 
rename setor            setor_empresa     

destring prioridade, replace force

* Adjusting CNPJ
replace cnpj = string(real(cnpj),"%014.0f")
replace cnpj = "" if cnpj=="."

* Validating code
validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

*dropping
drop cnpj_ajustado _merge no_empresa
drop if cnpj==""  

* Changing values of some var
replace_especific_values  setor_empresa no_curso

* gen year
gen ano = 2016

* drop impossible values
drop if vagas_demandadas_d==0

*collapse
collapse(sum) vagas_demandadas_d (first) setor_empresa, by (cnpj  no_curso ano no_municipio_curso)

*label variables
labels_vars

*Compressing datas
compress

* Changing values of some var
foreach var in setor_empresa{
	encode `var', gen(`var'_aux)
	drop `var'
	rename `var'_aux `var'
}

* Inserindo dado de codigo de municipio
sort no_curso
merge m:1 no_curso using  "${NEWDATA}/guia_cursos.dta", keepusing(co_curso)
drop if _merge==2
drop _merge

* Inserindo dado de codigo de Curso
sort no_municipio_curso
merge m:1 no_municipio_curso using  "${NEWDATA}/municipios_teste.dta"
drop if _merge==2
drop _merge

drop no_municipio_curso

sort cnpj  no_curso ano co_municipio_curso
save "${NEWDATA}/demanda_2016.dta", replace
