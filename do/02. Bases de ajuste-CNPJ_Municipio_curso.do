/*--------------- LISTA DE CNPJ ---------------------*/

*Demanda 2014
import excel "${RAWDATA}/Cruzamento Demanda 2014 - Oferta SISTEC V.2 - BID.xlsx", sheet("Dados arredondados") case(lower) firstrow clear
keep cnpj 			nomedaempresademandante setor cÓdigodomunic  códigodocurso
remove_special_caractere * , name(1) label(1) value(1)
rename codigodomunic 			co_municipio
rename nomedaempresademandante 	no_empresa
rename codigodocurso			co_curso
tostring co_municipio, replace
tempfile demanda_2014
save `demanda_2014', replace

*Demanda 2015
import excel "${RAWDATA}/MAPA DE DEMANDA 2015.xlsx", sheet("demanda") firstrow case(lower) clear
keep cnpjdaempresa  nomedaempresademandante setor cÓdigodomunic cÓdigodocurso 
remove_special_caractere * , name(1) label(1) value(1)
rename cnpjdaempresa			cnpj
rename codigodomunic 			co_municipio
rename nomedaempresademandante 	no_empresa
rename codigodocurso			co_curso
tempfile demanda_2015
save `demanda_2015', replace

*Demanda 2016
import excel "${RAWDATA}/1 - DEMANDA FIC 2016.xlsx", sheet("Demanda_geral_1e2_semestres") firstrow case(lower) clear
keep cnpj  			empresa  				setor  
remove_special_caractere * , name(1) label(1) value(1)
rename empresa				 	no_empresa
tempfile demanda_2016
save `demanda_2016', replace

*Homologacao 2014
import excel "${RAWDATA}/Demandas Homologadas MDIC 2014.xlsx", sheet("Planilha1") firstrow case(lower) clear 
keep cnpj 			nomedaempresademandante setor cÓd_curso
remove_special_caractere * , name(1) label(1) value(1)
rename cod_curso				co_curso
rename nomedaempresademandante	no_empresa
tempfile homologacao_2014
save `homologacao_2014', replace

*Homologacao 2015
import excel "${RAWDATA}/DADOS DEMANDAS HOMOLOGADAS 2015.xlsx", sheet("DADOS DEMANDAS HOMOLOGADAS 2015") firstrow case(lower) clear
keep cnpj 			empresa setor cod_curso
remove_special_caractere * , name(1) label(1) value(1)
rename cod_curso			co_curso
rename empresa				no_empresa
tempfile homologacao_2015
save `homologacao_2015', replace

*Homologacao 2016
import excel "${RAWDATA}/Demandas homologadas 2016.xlsx", sheet("Planilha1") firstrow case(lower) clear
keep cnpj  			nomedaempresa  				setor  iddocurso  iddomunicípio
remove_special_caractere * , name(1) label(1) value(1)
rename nomedaempresa			no_empresa
rename iddomunicipio 			co_municipio
rename iddocurso				co_curso
tostring co_municipio, replace
tempfile homologacao_2016
save `homologacao_2016', replace

* Turmas
import excel "${RAWDATA}/relatorio_sisutec.xlsx", case(lower) firstrow clear
keep nu_cnpj   			no_empresa 
remove_special_caractere * , name(1) label(1) value(1)
rename nu_cnpj					cnpj
tempfile turma
save `turma', replace


clear 
foreach data in demanda_2014 demanda_2015 demanda_2016 homologacao_2014 homologacao_2015 homologacao_2016 turma{
	di as white "`data'"
	append using ``data''
}


***
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

duplicates tag  cnpj no_empresa, gen(N_times)
replace N_times=N_times+1
duplicates drop cnpj no_empresa, force

compress

* Changing values of some var
replace_especific_values  setor

*
drop if no_empresa=="" & cnpj==""

*  0 - First correction
gen D_cnpj_vazio=cnpj==""
gsort no_empresa D_cnpj_vazio -N_times
bys no_empresa : replace cnpj=cnpj[1] if cnpj==""

*  1 - Mesmo CNPJ nomes diferendes abreviados
sort 		no_empresa 
gen 		D_mesma_empresa = subinstr(no_empresa,no_empresa[_n-1],"",1)!=no_empresa if length(no_empresa)>=10
gen 		mesma_empresa =_n*D_mesma_empresa
replace 	mesma_empresa =mesma_empresa[_n+1] 		if mesma_empresa==0
replace 	mesma_empresa =mesma_empresa[_n-1] 		if D_mesma_empresa[_n-1]==1 & D_mesma_empresa==1


sort mesma_empresa cnpj
bys mesma_empresa: replace cnpj=cnpj[_N] if cnpj=="" & mesma_empresa!=0


* 2- CNPJ diferente por 1 caracter 
strgroup no_empresa, gen(id_aproximado) threshold(0.1) first force

sort id_aproximado  cnpj
bys  id_aproximado: replace cnpj=cnpj[_N] if cnpj==""

* Vendo o tamanho do problem
replace D_cnpj_vazio=cnpj==""
tab D_cnpj_vazio

* Salvando lista
sort no_empresa -N_times
duplicates drop no_empresa, force

drop if cnpj=="" | no_empresa==""
keep no_empresa cnpj

rename cnpj cnpj_ajustado

sort no_empresa
compress
saveold "${NEWDATA}/Lista_cnpj_e_nome.dta", replace v(11)


************************************************************
/*--------------- LISTA DE Municipio ---------------------*/
 
*Demanda 2014
import excel "${RAWDATA}/Cruzamento Demanda 2014 - Oferta SISTEC V.2 - BID.xlsx", sheet("Dados arredondados") case(lower) firstrow clear

remove_special_caractere *mu* , name(1) label(1) value(1)
rename codigodomunic 			co_municipio_curso
rename municipio	 			no_municipio_curso

keep co_municipio_curso no_municipio_curso

tempfile demanda_2014
save `demanda_2014', replace

*Demanda 2015
import excel "${RAWDATA}/MAPA DE DEMANDA 2015.xlsx", sheet("demanda") firstrow case(lower) clear 
remove_special_caractere *mu* , name(1) label(1) value(1)
rename codigodomunic 			co_municipio_curso
rename municipio	 			no_municipio_curso
destring co_municipio_curso, replace force

keep co_municipio_curso no_municipio_curso

tempfile demanda_2015
save `demanda_2015', replace

*Homologacao 2016
import excel "${RAWDATA}/Demandas homologadas 2016.xlsx", sheet("Planilha1") firstrow case(lower) clear
remove_special_caractere *, name(1) label(1) value(1)
rename iddomunicipio 			co_municipio_curso
rename municipio	 			no_municipio_curso

keep co_municipio_curso no_municipio_curso

tempfile homologacao_2016
save `homologacao_2016', replace

* Dados municipio IBGE 2016
use "${RAWDATA}/Codigo_municipis_IBGE",clear
remove_special_caractere *, name(1) label(1) value(1)
rename municipio	 			no_municipio_curso
drop uf

tempfile IBGE_munic
save `IBGE_munic', replace

clear
* Append
append using `demanda_2014'
append using `demanda_2015'
append using `homologacao_2016'
append using `IBGE_munic'

duplicates drop no_municipio_curso,force
sort no_municipio_curso

save "${NEWDATA}/municipios_teste.dta", replace
 
