
**********************************FIC 4ta versao********************************
use "${RAWDATA}guia_FIC_4.dta", clear

*rename variables 
#delimit;
renvars nomedocurso códigocurso códigoeixotecnologico eixo ch escolaridade tipo
\ no_curso co_curso co_eixo_tecnologico no_eixo_tecnologico carga_horaria_prevista 
escolaridade_curso tipo_curso
; #delimit cr 

*lowercase 
gen Z=ustrlower(no_curso)
drop no_curso
rename Z no_curso

*drop useless variables
drop d descrição ediçãodoguiafic tipo_curso idade

*level up
recast str89 no_curso 
format no_curso %40s

*order
order no_curso co_curso co_eixo_tecnologico no_eixo_tecnologico escolaridade_curso ///
carga_horaria_prevista 


*sort
sort no_curso co_curso co_eixo_tecnologico no_eixo_tecnologico escolaridade_curso ///
carga_horaria_prevista 

*duplicates 
duplicates tag no_curso, gen(new)

replace no_curso = "moldador de plástico por injeção" if co_curso==221262

drop new

saveold "${NEWDATA}guia_FIC_4.dta", replace

**********************************FIC 3ra versao********************************
use "${RAWDATA}guia_FIC_3.dta", clear

rename co_curso3ed co_curso

*lowercase 
gen Z=ustrlower(denominação3ed)
drop denominação3ed
rename Z no_curso

*level up
recast str89 no_curso 
format no_curso %40s

*order
order no_curso co_curso 

*sort
sort no_curso co_curso

*duplicates 
duplicates list no_curso
duplicates drop no_curso, force

saveold "${NEWDATA}guia_FIC_3.dta", replace
