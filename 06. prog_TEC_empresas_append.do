************************* DEMANDA - APPEND ******************************
use 		 "${NEWDATA}/demanda_2014.dta", clear
append using "${NEWDATA}/demanda_2015.dta"
append using "${NEWDATA}/demanda_2016.dta"

* Litle tabulation
tab ano

*Compressing
compress

* sorting
sort cnpj co_municipio_curso co_curso ano


saveold "${IBGE}/demanda_empresas.dta", replace version(11)

************************* HOMOLOGADA - APPEND ******************************
use 		 "${NEWDATA}/homologada_2014.dta", clear
append using "${NEWDATA}/homologada_2015.dta"
append using "${NEWDATA}/homologada_2016.dta"

* Litle tabulation
tab ano

* Compressing
compress

* sorting
sort cnpj co_municipio_curso co_curso ano

* Saving
saveold "${IBGE}/homologada_empresas.dta", replace version(11)

