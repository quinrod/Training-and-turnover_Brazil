* Objective - Creating the data of suppla of courses by firms
/*----------------		Supply (2014)	    ----------------*/

* Reading raw-data
import excel "${RAWDATA}/Demandas Homologadas MDIC 2014.xlsx", sheet("Planilha1") case(lower) firstrow clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomedaempresademandante 	no_empresa
rename cod_curso				co_curso
rename nomedocurso 				no_curso
rename uf 						no_uf_empresa
rename municipio 				no_municipio_curso
rename demanda 					vagas_demandadas_h
rename homologado				vagas_homologadas
rename setor					setor_empresa

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

* drop useless variables
drop if vagas_homologadas==0

* year
gen ano=2014

* Inserindo codigo do municipio
sort no_municipio
merge m:1 no_municipio using  "${NEWDATA}/municipios_teste.dta"
drop if _merge==2
drop _merge
drop no_municipio_curso

* collapse
collapse(sum) vagas_demandadas_h vagas_homologadas (first) setor_empresa, by (cnpj co_municipio_curso co_curso ano)

* Encoding
encode setor_empresa, gen(setor_aux)
drop setor_empresa
rename setor_aux setor_empresa


order cnpj co_municipio_curso setor_empresa co_curso vagas_demandadas_h vagas_homologadas ano

sort cnpj  co_curso ano co_municipio_curso

* compress
compress 

save "${NEWDATA}/homologada_2014.dta", replace

/*----------------		Supply (2015)	    ----------------*/
* That's a kind different because there is 3 datas
* Data v1, divided on 3 parts
forvalues i=1/3 {
	import excel "${RAWDATA}/MDIC ETANOL E CONSTRUCAO.xlsx", sheet("publicacaodia`i'") firstrow clear 
	if `i'>1 append using "${RAWDATA}/homologacao_empresas_2015v1.dta"
	save "${RAWDATA}/homologacao_empresas_2015v1.dta", replace
}

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomedaempresa 			no_empresa
rename iddocurso				co_curso
rename iddomunicipio 			co_municipio_curso
rename numerodevagas			vagas_demandadas_h

keep cnpj no_empresa co_curso co_municipio_curso vagas_demandadas_h

* Ajuste cnpj
tostring cnpj, replace format(%014.0f) 

validar_cnpj cnpj
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

*drop impossible variables
drop if vagas_demandadas_h==0

*collapse
collapse(sum) vagas_demandadas_h, by (cnpj co_municipio_curso co_curso)

* Var to help on the matching
gen 	 aux_merge=1

* Compressing and saving
compress
save "${NEWDATA}/homologada_2015v1.dta", replace

*Homologacao 2015
import excel "${RAWDATA}/DADOS DEMANDAS HOMOLOGADAS 2015.xlsx", sheet("DADOS DEMANDAS HOMOLOGADAS 2015") firstrow case(lower) clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename empresa 					no_empresa
rename cod_curso				co_curso
rename curso 					no_curso
rename uf 						no_uf_empresa
rename municipio 				no_municipio_curso
rename vagasdemandadas 			vagas_demandadas_h
rename vagashomologadas			vagas_homologadas
rename setor					setor_empresa

* CNPJ
replace cnpj=string(real(cnpj),"%014.0f")

validar_cnpj cnpj if length(cnpj)==14
replace cnpj= "" if cnpj_valido==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

*dropping
drop cnpj_ajustado _merge no_empresa

* Changing values of some var
replace_especific_values  setor_empresa

* drop useless variables
drop if vagas_homologadas==0

* Inserindo codigo do municipio
sort no_municipio
merge m:1 no_municipio using  "${NEWDATA}/municipios_teste.dta"
drop if _merge==2

*collapse
collapse (sum) vagas_demandadas_h vagas_homologadas (first) setor_empresa, by (cnpj co_municipio_curso co_curso)

* Encoding
encode setor_empresa, gen(setor_aux)
drop setor_empresa
rename setor_aux setor_empresa


gen 	 aux_merge=1 if cnpj==""
replace  aux_merge= _n+10 if aux_merge!=1

rename cnpj cnpj_old

* Compresing
compress
*append using  "${NEWDATA}/homologada_2015v1.dta"
merge 1:m  co_municipio_curso co_curso vagas_demandadas_h  aux_merge using  "${NEWDATA}/homologada_2015v1.dta", keepusing(cnpj)

replace cnpj_old=cnpj if _merge==3
drop cnpj
rename cnpj_old cnpj

* Eliminating merge==2
drop if _merge==2
drop _merge

* Eliminating cnpj missing
drop if cnpj ==""

duplicates drop cnpj co_municipio_curso co_curso, force

* Ordering to dropping the repeated data 
gsort  cnpj co_municipio_curso co_curso vagas_homologadas

* year
gen ano=2015

*Assumindo que quem nao tem informacao de homologacao e igual ao demandante
replace vagas_homologadas=vagas_demandadas_h if vagas_homologadas==.

* Compressing and saving
compress
save "${NEWDATA}/homologada_2015.dta", replace

/*----------------		Supply (2016)	    ----------------*/
*Homologacao 2016
import excel "${RAWDATA}/Demandas homologadas 2016.xlsx", sheet("Planilha1") firstrow case(lower) clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomedaempresa 				no_empresa
rename iddocurso 					co_curso
rename iddomunicipio 				co_municipio_curso
rename numerodevagassolicitadas		vagas_demandadas_h
rename numerodevagashomologadasfi	vagas_homologadas
rename setor						setor_empresa

* Ajuste cnpj
tostring cnpj, replace format(%014.0f) 

validar_cnpj cnpj if length(cnpj)==14
replace cnpj=""  if cnpj_valido==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

* dropping
drop cnpj_ajustado _merge no_empresa
drop if cnpj==""

* drop impossible variables
drop if vagas_homologadas==0

* year
gen ano=2016

* Changing values of some var
replace_especific_values  setor_empresa

*collapse
collapse (sum) vagas_demandadas_h vagas_homologadas (first) setor_empresa, by (cnpj co_municipio_curso co_curso ano)

* Encoding
encode setor_empresa, gen(setor_aux)
drop setor_empresa
rename setor_aux setor_empresa

* Compressing and saving
compress
save "${NEWDATA}/homologada_2016.dta", replace
