cd "${IBGE}"

do "${DO}Validacao_cpf_pis_cnpj-v2.do"

/*-1. Juntar as bases-*/

**********Base mdic***********
use "alunos_mdic_v2", clear

*corregir variaveis faltantes
#delimit;
renvars valor_hora_aula_proposto tipo_da_oferta 
no_sistema_ensino no_modalidade
\ valor_hora_curso modalidade rede_ensino
programa
; #delimit cr

*Acrescentando prefixo para identificar base de origem da var
#delimit;
drop desempregado ch_min_financiavel ch_max_financiavel total_conf_freq_aluno 
total_freq_aluno tipo_do_local_da_oferta cod_ibge_do_local_da_oferta 
seguro_desenprego st_financiavel oferta_cadastro_online 
ead unidade_demandante instituicao tag_mat
; #delimit cr

rename municipio_do_local_da_oferta municipio_da_oferta
rename * *_mdic

*Padronizar variavel de merge
rename cpf_mdic 		cpf
rename matricula_mdic	matricula

sort co_turma_mdic cpf matricula

save "${BASE_TEMP}mdic.dta", replace

************Base mec*************
use "alunos_mec_v2", clear

*corregir variaveis faltantes
#delimit;
renvars nu_carga_horaria vl_mensalidade_curso vl_total_curso \ ch_real 
valor_mes_curso valor_total_curso
; #delimit cr

*Acrescentando prefixo para identificar base de origem da var
#delimit;
drop co_adesao_sisu_tecnico_edital dt_inicio_vigencia duracao_curso_periodo
tipo_publico_prioritario co_tipo_instituicao co_unidade_ensino_simec 
co_unidade_ensino_remota co_tipo_oferta_curso modalidade nu_telefone_celular
co_status_oferta_turma co_etapa co_versao_registro st_registro_atual check 
no_unidade_matriz no_unidade_ensino_remota tipo_rede_ensino curso_experimental 
extemporaneo_matricula
; #delimit cr

rename * *_mec

*Padronizar variavel de merge
rename cpf_mec 			cpf
rename matricula_mec	matricula

sort co_turma_mec cpf matricula 

save "${BASE_TEMP}mec.dta", replace

*********Merging datas**********
merge 1:1 cpf matricula using "${BASE_TEMP}mdic.dta"

********************************************************************************
***********************************TESTES***************************************
********************************************************************************

/*
* A sencacao que da e que nao e a mesma variavel. Eu arriscaria dizer
* que dt_cadastro_aluno_mec seria a data de matricula do aluno. Essa
*/

/*---- 1. Testar se as variaveis coincidem. ----*/
* Variaveis de teste:
* nome, idade, data_cadastro, data_inicio, mun

gen byte D_teste_nome= no_aluno_mec==no_aluno_mdic
tab D_teste_nome _merge // O nome bate 99.999%% do caso

gen byte D_teste_no_turma= no_turma_mec==no_turma_mdic
tab D_teste_no_turma _merge // A variavel e 77% igual

gen byte D_teste_co_turma= co_turma_mec==co_turma_mdic
tab D_teste_co_turma _merge // A variavel e 99.997% igual

gen byte D_teste_no_curso= no_curso_mec==no_curso_mdic
tab D_teste_no_curso _merge // A variavel e 3.70% igual

gen byte D_teste_co_curso= co_curso_mec==co_curso_mdic
tab D_teste_co_curso _merge // MAS o codigo do curso e 99.99% igual

gen byte D_teste_esc= escolaridade_aluno_mec==escolaridade_aluno_mdic
tab D_teste_esc _merge // A variavel e 100% igual, mas o encode e diferente

gen byte D_teste_no_demandante= no_demandante_mec==no_demandante_mdic
tab D_teste_no_demandante _merge // A variavel e 40.07% igual
//os demandantes do MDIC parecem estar errados, filtrar por cnpj do MDIC

gen byte D_teste_qt_vagas= vagas_homologadas_mec==vagas_homologadas_mdic
tab D_teste_qt_vagas _merge // A data de vagas oferecidas  99.999% bate	

gen byte D_teste_dt_nasc= dt_nascimento_mec==dt_nascimento_mdic
tab D_teste_dt_nasc _merge // O nome bate 99.999% do caso

gen byte D_teste_dt_premat= dt_prematricula_mdic==dt_prematricula_mec
tab D_teste_dt_premat _merge // A data de premat bate 100% do caso

gen byte D_teste_dt_mat= dt_matricula_mdic==dt_matricula_mec
tab D_teste_dt_mat _merge // A data de premat e igual 27.14% do caso
// as datas do MEC parece estar errada antes de 2011

* data diff tem concentracao em 50,000.
gen n_dias_diff= dt_matricula_mdic-dt_matricula_mec
count 
count if n_dias_diff<0
count if n_dias_diff>=0 & n_dias_diff!=.
count if inrange(n_dias_diff,0,50)
count if inrange(n_dias_diff,0,500)
count if inrange(n_dias_diff,0,5000)
count if inrange(n_dias_diff,0,50000)

drop n_dias_diff

gen byte D_teste_dt_ini= dt_inicio_mdic==dt_inicio_mec
tab D_teste_dt_ini _merge // A data de inicio  99.25% bate

gen byte D_teste_dt_conclusao_real= dt_conclusao_real_mdic==dt_conclusao_real_mec
tab D_teste_dt_conclusao_real _merge // A data de conclusao 96.435% bate

drop D_test*

/*---- 2. Descobrir padrao de datas entre os cursos nas bases ----*/
*Cursos FIC comecam antes do que cursos TEC
tab tipo_curso_mec // 66.77 FIC e 33.23 TEC
tab tipo_curso_mdic // 70.30 FIC e 29.70 TEC
// todos os cursos demandados pelo MDIC na base das empresas sao FIC

label drop _merge

foreach var of varlist *_mec  {
	di as white "`var'"
	*cap noi tab `var' 	_merge, m
	*qui sleep 5000 
}	

cls
cap drop *1

foreach var of varlist dt*_mec  {
	di as white "`var'"
	gen `var'1=year(`var')
	tab `var'1	_merge if tipo_curso_mec==1, m
	tab `var'1	_merge if tipo_curso_mec==2, m
	qui sleep 5000 
}	

*dt_nac: alunos FIC sao mais velhos
*dt_premat: ninguem pre-matriculado em 2017
*dt_mat: datas mat para cursos FIC so tem 1920, esta errado. Usar dt_mat do MDIC
*dt_inicio: nao tem alunos do TEC comecando em 2016/17
*dt_conculusao: alunos FIC acabam antes

* * * * * * * * * * * * * * * * * * * 
*Nao iniciam cursos TEC a partir de 2016 na base do MDIC e so iniciam cursos FIC antes de 2/4 de 2016
*Ou seja, cursos TEC e FIC na base MEC nao tem match a partir dessas datas
gen comp_inicio_mec=ym(year(dt_inicio_mec),month(dt_inicio_mec))
format %tm comp_inicio_mec
tab comp_inicio_mec _merge if tipo_curso_mec==1
tab comp_inicio_mec _merge if tipo_curso_mec==2

gen comp_inicio_mdic=ym(year(dt_inicio_mdic),month(dt_inicio_mdic))
format %tm comp_inicio_mdic
tab comp_inicio_mdic _merge if tipo_curso_mdic=="fic"
tab comp_inicio_mdic _merge if tipo_curso_mdic=="técnico concomitante" | tipo_curso_mdic=="técnico subsequente"

drop comp_inicio*

#delimit;

order co_turma_mec cpf matricula no_aluno_mec

dt_nascimento_mec dt_prematricula_mec dt_prematricula_mec1 dt_matricula_mec dt_inicio_mec 
dt_conclusao_prevista_mec dt_conclusao_real_mec 

no_demandante_mec programa_mec iniciativa_mec dependencia_admin_mec 
subdependencia_admin_mec rede_ensino_mec tipo_curso_mec tipo_oferta_mec 
no_eixo_tecnologico_mec co_curso_mec valor_mes_curso_mec qt_meses_curso_mec 
valor_total_curso_mec turno_mec no_aluno_mec sexo_mec  raca_mec escolaridade_aluno_mec 
grupo_tipo_matricula_mec st_turma_mec st_matricula_aluno_categoria_mec 
st_matricula_aluno_mec vagas_homologadas_mec sg_chamada_mec nu_aula_semana_mec 
no_ue_mec no_curso_mec pcd_mec confirmacao_matricula_mec matricula_ativa_mec 

dt_nascimento_mdic dt_publicacao_mdic dt_inicio_mdic dt_conclusao_prevista_mdic 
dt_cadastro_mdic dt_prematricula_mdic dt_matricula_mdic 
co_curso_mdic no_aluno_mdic dependencia_admin_mdic st_turma_mdic ch_prevista_mdic 
ch_real_mdic vagas_homologadas_mdic sexo_mdic desempregado_mdic pcd_mdic 
escolaridade_aluno_mdic escolaridade_curso_mdic raca_mdic 
st_matricula_aluno_mdic co_ue_mdic valor_hora_aula_proposto_mdic 
total_conf_freq_aluno_mdic total_freq_aluno_mdic 
tipo_do_local_da_oferta_mdic cod_ibge_do_local_da_oferta_mdic 
cod_da_unidade_de_ensino_mdic seguro_desenprego_mdic no_eixo_tecnologico_mdic 
ead_mdic no_curso_mdic edicao_catalogo_guia_mdic tipo_da_oferta_mdic 
tag_mat_mdic _merge no_demandante_mdic

; #delimit cr

* Ready to merge

drop if _m!=3 

replace cpf=""  if  length(cpf)<11
validar_cpf cpf if length(cpf)==11
replace cpf=""  if cpf_valido==0
drop if cpf_valido==0
drop if tipo_curso_mec==2

order no_demandante_mdic no_demandante_mec tipo_da_oferta_mdic programa_mec ///
co_uf_empresa_mdic no_uf_empresa_mdic no_municipio_empresa_mdic ///
co_curso_mdic no_curso_mec no_curso_mdic tipo_curso_mec no_eixo_tecnologico_mec ///
escolaridade_curso_mdic ch_prevista_mdic ch_real_mdic vagas_homologadas_mdic ///
iniciativa_mec dependencia_admin_mec subdependencia_admin_mdic rede_ensino_mec ///
uf_do_local_da_oferta_mdic cod_da_unidade_de_ensino_mdic co_turma_mec ///
turno_mdic cpf no_aluno_mdic matricula ///
dt_nascimento_mdic sexo_mdic raca_mdic pcd_mec escolaridade_aluno_mdic ///
dt_publicacao_mdic dt_cadastro_mdic dt_prematricula_mdic dt_matricula_mdic ///
dt_inicio_mdic dt_conclusao_prevista_mdic dt_conclusao_real_mec st_turma_mdic ///
st_matricula_aluno_categoria_mec st_matricula_aluno_mdic 

drop cpf_valido 
g ano = year(dt_inicio_mdic)
rename co_turma_mec co_turma
destring cpf, replace
sort cpf co_turma ano


save "${IBGE}alunos_MDIC_MEC.dta", replace

/*

/*---- 4. Testar variaveis pedidos pelo Rodrigo. ----*/

*4.1 verificar se o valor 2 só existe if iniciativa =="SISUTEC" e o 3 if iniciativa =="Bolsa Formação" 
tab dependencia_admin_mec 
tab dependencia_admin_mec iniciativa_mec //Verificado
* Tudo que é Privado é sisutec
* 92.4% do que é Publico é bolsa formacao 

*4.2 verificar se os valores só existem if no_dependencia_admin=="Artigo 240  SISTEMA S" 
tab subdependencia_admin_mec dependencia_admin_mec, m

*4.3 verificar se os valores só existem if no_dependencia_admin=="Pública"
tab sistema_ensino dependencia_admin_mec

*4.3 verificar se os valores só existem if no_dependencia_admin=="Pública"
tab sistema_ensino dependencia_admin_mec, m



*4.4 verificar que tem sao menos de 5570 municipios
unique municipio_unidade_ensino_mec // 4613

*gerando mapa por municipio do Brasil
qui {
	preserve
	global mapa "C:\Users\Leandro-ASUS\Dropbox\Trabalhos Profissionais\Projeto BID\Livro - LMK\Rodrigo\municipios"
	
	gen ano=year(dt_inicio_curso_mec)
	keep municipio_unidade_ensino_mec  ano
	
	keep if inrange(ano,2011,2017)
	
	rename municipio_unidade_ensino_mec municipio
	gen one=1
	tempfile base_aux
	save `base_aux', replace
	
	foreach ano of numlist 2015/2015 {
		use `base_aux',clear
		keep if ano==`ano'
		collapse (count) one , by(municipio)
		
		sort municipio
		merge 1:1 municipio using "$mapa/correspondencia.dta"
		keep if _merge==2 | _merge==3
		
		qui count if _merge==3
		local N_munic = `=r(N)'
		
		drop _merge
		
		replace one=0 if one==.
		
		spmap one using "$mapa/municipios_coor" , id(_ID) saving("${output}/graficos/N_cursos_`ano'.gph", replace)  legtitle("N_cursos-`ano' (`N_munic' municipios)")  clnumber(6) 
		graph export  "${output}/graficos/N_cursos_`ano'.pdf", replace as(pdf)
	}

	use `base_aux',clear
	collapse (count) one , by(municipio)
	sort municipio
	merge 1:1 municipio using "$mapa/correspondencia.dta"
	keep if _merge==2 | _merge==3
	
	qui count if _merge==3
	local N_munic = `=r(N)'
	
	drop _merge
	replace one=0 if one==.
	
	spmap one using "$mapa/municipios_coor" , id(_ID) saving("${output}/graficos/N_cursos_all_period.gph", replace)  legtitle("N_cursos- 2011-2017 (`N_munic' municipios)")  clnumber(6) 
	graph export  "${output}/graficos/N_cursos_all_period.pdf", replace as(pdf)
	
	restore
}


* 4.5 Pode ser temporaria, movél (checar se variável é vinculada com no_unidade_ensino
unique unidade_ensino_remota_mec
* Existem 20365 codigos de unidades de ensino remota e 68% da variavel e missing

* 4.6 verificar se os valores só existem if if co_tipo_curso=="Técnico"
tab tipo_oferta_mec tipo_curso_mec, m


* 4.7 confirmar que todos os co_tipo_curso=="FIC" tem o formato XXXXX
gen Formato_var_curso= length(string(curso_sistec_mec))
tab  Formato_var_curso tipo_curso_mec
table  curso_sistec_mec  tipo_curso_mec

* 4.8 verificar se os codigos sao unicos para cada valor de variavel 'iniciativa'
 duplicates tag oferta_turma 				, gen(Tag1)
 duplicates tag oferta_turma iniciativa_mec , gen(Tag2)
 
 gen teste_igual = Tag1==Tag2
 
 tab teste_igual
 tab oferta_turma if teste_igual==0

* 4.9 confirmar se valor só existe if ds_iniciativa=="SISUTEC"
tab sisutec_turma if iniciativa_mec==1,m


* 4.10 verificar se a distribuicao é mais ou menos normal. Verificar que todos os dias existem
* Fixando idade
gen idade_inicio= (dt_inicio_curso_mec- dt_nascimento_mec)/365 
gen ano_diff=year(dt_inicio_curso_mec)-year(dt_nascimento_mec)
replace idade_inicio=. if !inrange(ano_diff,10,90)
hist idade_inicio, bin(100)
tabstat idade_inicio, stat( mean sd sk p1 p5 p10 p25 p50 p75 p90 p95 p99)

gen log_idade_inicio= log(idade_inicio)

gen oferta_aux=tipo_oferta_mec
replace oferta_aux=0 if oferta_aux==.
replace oferta_aux= 4 if oferta_aux==2 | turno_mec==.

gen turno_aux= turno_mec
replace turno_aux=4 if turno_aux==.
replace turno_aux=4 if  oferta_aux==4 | turno_mec==3

tab oferta_aux turno_aux,m

cap mkdir "${output}/histograma"
hist idade_inicio
graph export  "${output}/histograma/Hist_idade_inicio.pdf", replace as(pdf)
hist idade_inicio , bin(100) by(turno_aux)
graph export  "${output}/histograma/Hist_idade_inicio_turno.pdf", replace as(pdf)
hist idade_inicio , bin(100) by(oferta_aux)
graph export  "${output}/histograma/Hist_idade_inicio_oferta.pdf", replace as(pdf)
hist idade_inicio , bin(100) by(oferta_aux turno_aux)
graph export  "${output}/histograma/Hist_idade_inicio_turno_oferta.pdf", replace as(pdf)

* 4.11 existe também sexo = X. Entender se faz sentido ou se é um erro
tab sg_sexo , m
bys cpf (sg_sexo): gen  sexo_indefinido=sg_sexo[_N]

* 4.12 confirmar se valor só existe if co_grupo_tipo_matricula=="PREMATRICULA"
tab grupo_tipo_matricula situacao_oferta

* 4.13 confirmar as equivalencias entre ds_situacao_oferta, ds_categoria_situacao e 
* ds_situacao_matricula sao as certas. As que estão em vermelho foram reconhecidas usando intuicao. 
* O resto vem da equivalencia segundo documento 2013-11-18 SISTEC-Status de Matriculas-v14

gen sit_mat=situacao_matricula

*Checando se os codigos estao corretos. O encode trabalha com ordem alfabetica
tab sit_mat situacao_matricula

tab sit_mat categoria_situacao

qui {
	levelsof categoria_situacao, local( values)
	foreach i of local values {
		levelsof sit_mat if categoria_situacao==`i', local(lista)
		di as white "categoria_situacao=`i' em {`lista'}"
	}
}

* 4.14 verificar se a distribuicao é mais ou menos normal. Verificar que todos os dias existem

*

*
gen dia_cadastro=day(dt_cadastro_aluno_mec)
tab dia_cadastro
hist dia_cadastro


gen dia_inicio=day(dt_inicio_curso_mec)
tab dia_inicio
hist dia_inicio


log close

