*Demanda 2016
import excel "${RAWDATA}1 - DEMANDA FIC 2016.xlsx", sheet("Demanda_geral_1e2_semestres") firstrow case(lower) clear
save "${RAWDATA}demanda_empresas_2016.dta", replace 

*Homologacao 2016
import excel "${RAWDATA}Demandas homologadas 2016.xlsx", sheet("Planilha1") firstrow case(lower) clear
save "${RAWDATA}homologacao_empresas_2016.dta", replace 

*Demanda 2015
import excel "${RAWDATA}MAPA DE DEMANDA 2015.xlsx", sheet("demanda") firstrow case(lower) clear
save "${RAWDATA}demanda_empresas_2015.dta", replace 

*Homologacao 2015
import excel "${RAWDATA}DADOS DEMANDAS HOMOLOGADAS 2015.xlsx", sheet("DADOS DEMANDAS HOMOLOGADAS 2015") firstrow case(lower) clear
save "${RAWDATA}homologacao_empresas_2015.dta", replace

forvalues i=1/3 {
import excel "${RAWDATA}MDIC ETANOL E CONSTRUCAO.xlsx", sheet("publicacaodia`i'") firstrow clear 
	if `i'>1 append using "${RAWDATA}homologacao_empresas_2015v1.dta"
	save "${RAWDATA}homologacao_empresas_2015v1.dta", replace
}

save "${RAWDATA}homologacao_empresas_2015v1.dta", replace 

/*
import excel "${RAWDATA}MDIC ETANOL E CONSTRUCAO.xlsx", sheet("publicacaodia3") firstrow clear 
save "${RAWDATA}homologacao_empresas_2015v1.dta", replace
*/

*Demanda 2014
import excel "${RAWDATA}Cruzamento Demanda 2014 - Oferta SISTEC V.2 - BID.xlsx", sheet("Dados arredondados") case(lower) firstrow clear
save "${RAWDATA}demanda_empresas_2014.dta", replace

forvalues i=1/2 {
import delimited "{RAWDATA}relatorio_de_homologacao_sistec_csv `i'_semestre_2014.csv", delimiter(";") varnames(3) clear
	if `i'>1 append using "{RAWDATA}demanda_empresas_2014_MEC.dta", force
	save "{RAWDATA}demanda_empresas_2014_MEC.dta", replace
}

*Homologacao 2014
import excel "${RAWDATA}Demandas Homologadas MDIC 2014.xlsx", sheet("Planilha1") firstrow case(lower) clear 
save "${RAWDATA}homologacao_empresas_2014.dta", replace 

*Alunos MEC
import delimited "${RAWDATA}bid.csv", clear delim(";") 
*gen aux=uniform()
*sort aux
*keep if aux<=0.05
save "${RAWDATA}alunos_MEC.dta", replace 

*Alunos MDIC
import delimited "${RAWDATA}20160412_relatorio_matriculas_bf.csv", clear delim("|") encoding(utf-8)
save "${RAWDATA}alunos_MDIC.dta", replace 

*CNPJ MEC
import excel "${RAWDATA}relatorio_sisutec.xlsx", case(lower) firstrow clear
save "${RAWDATA}demandante_cnpj_turma.dta", replace

***********************************diccionario**********************************

*Guia FIC - 3ra
import excel "${RAWDATA}DADOS DEMANDAS HOMOLOGADAS 2015.xlsx", sheet("GUIA FIC 3ª ED") firstrow case(lower) clear
save "${RAWDATA}guia_FIC_3.dta", replace 

*Guia FIC - 4ta
import excel "${RAWDATA}DADOS DEMANDAS HOMOLOGADAS 2015.xlsx", sheet("GUIA FIC 4ª ED") firstrow case(lower) clear
save "${RAWDATA}guia_FIC_4.dta", replace 

*Municipios 
import excel "${RAWDATA}municipios_2016.xls", sheet("municipios") firstrow case(lower) clear
save "${RAWDATA}municipios.dta", replace
