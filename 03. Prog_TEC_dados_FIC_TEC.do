
**********************************FIC 4ta versao********************************
use "${RAWDATA}/guia_FIC_4.dta", clear

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

*rename variables
rename nomedocurso 				no_curso
rename codigocurso				co_curso_fic4
rename codigoeixotecnologico	co_eixo_tecnologico
rename eixo						no_eixo_tecnologico
rename ch						carga_horaria_prevista
rename escolaridade				escolaridade_curso
rename tipo						tipo_curso

*drop useless variables
drop d descricao edicaodoguiafic tipo_curso idade

*order
order no_curso co_curso co_eixo_tecnologico no_eixo_tecnologico escolaridade_curso ///
carga_horaria_prevista 


*sort
sort no_curso co_curso co_eixo_tecnologico no_eixo_tecnologico escolaridade_curso ///
carga_horaria_prevista 

*duplicates 
duplicates drop co_curso, force

rename co_curso_fic4 co_curso

replace no_curso = "moldador de plastico por injecao" if co_curso==221262

saveold "${NEWDATA}/guia_FIC_4.dta", replace


import excel "${RAWDATA}/Cruzamento Demanda 2014 - Oferta SISTEC V.2 - BID.xlsx", sheet("Dados arredondados") case(lower) firstrow clear
keep códigodocurso nomedocurso
remove_special_caractere * , name(1) label(1) value(1)
rename codigodocurso 	co_curso
rename nomedocurso		no_curso
duplicates drop co_curso no_curso,force

tempfile dem_2014
save `dem_2014',replace

import excel "${RAWDATA}/MAPA DE DEMANDA 2015.xlsx", sheet("demanda") firstrow case(lower) clear
keep  cÓdigodocurso nomedocurso
remove_special_caractere * , name(1) label(1) value(1)
rename codigodocurso 	co_curso
rename nomedocurso		no_curso
duplicates drop co_curso no_curso,force

tempfile dem_2015
save `dem_2015',replace

*Homologacao 2016
import excel "${RAWDATA}/Demandas homologadas 2016.xlsx", sheet("Planilha1") firstrow case(lower) clear
keep iddocurso nomecurso
* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming vars
rename nomecurso 	no_curso
rename iddocurso 	co_curso

duplicates drop co_curso no_curso,force

tempfile hom_2016
save `hom_2016',replace



use `hom_2016', clear
append using  `dem_2014'
append using  `dem_2015'
append using  "${NEWDATA}/guia_FIC_4.dta"



duplicates drop no_curso,force

sort no_curso
saveold "${NEWDATA}/guia_cursos.dta", replace



