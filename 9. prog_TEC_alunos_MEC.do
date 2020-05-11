clear all
set more off
use "${RAWDATA}alunos_MEC.dta", clear

*******************************************************************************
****************************RENAME VARIABLES***********************************
*******************************************************************************

*rename variables 
#delimit;
renvars nu_cpf co_municipio_unidade_ensino no_municipio_unidade_ensino 
dt_inicio_curso dt_previsao_termino_curso sg_sexo dt_cadastro_aluno dt_conclusao_curso
ds_situacao_matricula qt_vagas_ofertadas ds_tipo_curso ds_situacao_oferta
co_curso_sistec ds_tipo_programa co_oferta_turma ds_identificador_turma
no_turno ds_modalidade_ensino ds_sistema_ensino no_dependencia_admin
ds_eixo_tecnologico ds_iniciativa ds_raca_cor dt_deferimento_curso
sg_uf_unidade_ensino co_unidade_ensino no_unidade_ensino co_matricula
ds_escolaridade ds_nivel_ensino st_pcd ds_categoria_situacao nu_carga_horaria
\ cpf co_municipio_ue no_municipio_ue dt_inicio dt_conclusao_prevista sexo 
dt_prematricula dt_conclusao_real st_matricula_aluno vagas_homologadas 
tipo_curso st_turma co_curso programa co_turma no_turma turno modalidade 
rede_ensino dependencia_admin no_eixo_tecnologico iniciativa raca
dt_publicacao no_uf_ue co_ue no_ue matricula escolaridade_aluno 
escolaridade_curso pcd st_matricula_aluno_categoria ch_prevista
; #delimit cr 

*******************************************************************************
*****************************************FORMAT********************************
*******************************************************************************

*format ids
format cpf %11.0f
tostring cpf, gen(cpf1) format(%011.0f) force 
drop cpf
rename cpf1 cpf
recast str11 cpf
gen byte notnumeric = real(cpf)==.
drop notnumeric

format co_aluno %7.0f
tostring co_aluno, gen(co_aluno1) format(%07.0f) force 
drop co_aluno
rename co_aluno1 co_aluno
recast str7 co_aluno
gen byte notnumeric = real(co_aluno)==.
drop notnumeric

format co_municipio_ue %7.0f
tostring co_municipio_ue, gen(co_municipio_ue1) format(%07.0f) force 
drop co_municipio_ue
rename co_municipio_ue1 co_municipio_ue
recast str7 co_municipio_ue
gen byte notnumeric = real(co_municipio_ue)==.
drop notnumeric

* format dates
foreach var of varlist dt_geracao dt_matricula {
split `var', parse (" ")
drop `var' `var'2 `var'3
rename `var'1 `var'
} 

gen Z = date(dt_nascimento, "DMY", 2010)
format Z %td 
drop dt_nascimento
rename Z dt_nascimento

foreach var of varlist dt_inicio dt_conclusao_prevista ///
dt_conclusao_real dt_geracao dt_prematricula dt_matricula dt_inicio_vigencia {
gen Z = date(`var', "DMY", 2018)
format Z %td 
drop `var'
rename Z `var'
}

*format o resto
format no_aluno %35s
format ds_email %30s
format co_situacao_matricula %22.0f
format st_matricula_aluno %25s
format co_tipo_curso %13.0f
format tipo_curso %7s
format co_eixo_tecnologico %20.0f
format co_curso %15.0f
format vagas_homologadas %20.0f
format ds_tipo_oferta %14s
format st_matricula_aluno_categoria %21s 
format ds_grupo_tipo_matricula %23s
format co_status_oferta_turma %23.0f
format ds_rotulo_situacao_matricula %30s
format programa %16s
format st_turma %18s
format ds_tipo_beneficiario %20s
format ds_tipo_publico_prioritario %27s

*format os codigos das variaves categoricas

*************** CORRESPONDENCIAS CERTAS***************

***** co_tipo_curso	tipo_curso *****
	br co_tipo_curso tipo_curso 
	tab co_tipo_curso tipo_curso
	* nesse caso o match é perfeito 
	* tem que ter certeza que é assim na base inteira também
	encode tipo_curso, gen(novo) label(tipo_curso)
	drop tipo_curso co_tipo_curso
	rename novo tipo_curso

***** co_grupo_tipo_matricula ds_grupo_tipo_matricula
	br co_grupo_tipo_matricula ds_grupo_tipo_matricula
	tab co_grupo_tipo_matricula
	tab ds_grupo_tipo_matricula
	tab co_grupo_tipo_matricula ds_grupo_tipo_matricula
	* nesse caso o match é perfeito 
	* tem que ter certeza que é assim na base inteira também
	encode ds_grupo_tipo_matricula, gen(novo) label(grupo_tipo_matricula)
	drop ds_grupo_tipo_matricula co_grupo_tipo_matricula
	rename novo grupo_tipo_matricula
	
*************** QUANDO CO ESTA MISSING ***************

***** co_modalidade_ensino	modalidade *****
	br co_modalidade_ensino modalidade
	tab co_modalidade_ensino 
	tab modalidade
	* variável co_modalidade_ensino está missing 
	* vamos manter essa variavel mas encode a outra 
	encode modalidade, gen(novo) label(modalidade)
	drop modalidade co_modalidade_ensino
	rename novo modalidade

***** co_sistema_ensino rede_ensino *****
	br co_sistema_ensino rede_ensino
	tab co_sistema_ensino 
	tab rede_ensino
	* variável co_sistema_ensino está missing 
	* vamos manter essa variavel mas encode a outra 
	encode rede_ensino, gen(novo) label(rede_ensino)
	drop rede_ensino
	rename novo rede_ensino

***** co_dependencia_admin dependencia_admin *****
	br co_dependencia_admin dependencia_admin
	tab co_dependencia_admin 
	tab dependencia_admin
	* variável co_dependencia_admin está toda missing 
	* vamos manter essa variavel mas encode a outra 
	encode dependencia_admin, gen(novo) label(dependencia_admin)
	drop dependencia_admin
	rename novo dependencia_admin
	
*************** QUANDO DS ESTA MISSING ***************
	
***** co_tipo_instituicao ds_tipo_instituicao
	br co_tipo_instituicao ds_tipo_instituicao
	tab co_tipo_instituicao
	tab ds_tipo_instituicao
	* ds está vazia, vamos deixar tudo do jeito que está
	* esse par de variáveis fica sem interpretação 

***** co_municipio_ue no_municipio_ue
	br  co_municipio_ue no_municipio_ue
	tab co_municipio_ue 
	tab no_municipio_ue
	* ds está vazia, vamos deixar tudo do jeito que está
	* esse par de variáveis fica sem interpretação 

*************** QUANDO AS DUAS ESTAO MISSING ***************

*****co_nivel_ensino escolaridade_curso *****
	br co_nivel_ensino escolaridade_curso
	tab co_nivel_ensino
	tab escolaridade_curso
	* essas duas variáveis estão missing
	* as duas foram mantidas 

*****co_modalidade_pagamento ds_modalidade_pagamento *****
	br co_modalidade_pagamento ds_modalidade_pagamento
	tab co_modalidade_pagamento
	tab ds_modalidade_pagamento
	* essas duas variáveis estão missing
	* as duas foram mantidas 

*****co_tipo_cota ds_tipo_cota*****
	br co_tipo_cota ds_tipo_cota
	tab co_tipo_cota 
	tab ds_tipo_cota
	* essas duas variáveis estão missing
	* as duas foram mantidas 

*************** CORRESPONDENCIAS LOUCAS ***************

***** co_eixo_tecnologico no_eixo_tecnologico *****
br co_eixo_tecnologico no_eixo_tecnologico
tab co_eixo_tecnologico no_eixo_tecnologico
* essa variável tem mais de 1 code pra cada ds 
* vamos encode a variavel ds e manter a variável de código
encode no_eixo_tecnologico, gen(novo) label(no_eixo_tecnologico)
drop no_eixo_tecnologico co_eixo_tecnologico
rename novo no_eixo_tecnologico

***** st_matricula_aluno e ds_rotulo_situacao_matricula *****
br st_matricula_aluno ds_rotulo_situacao_matricula
gen check = 0
replace check = 1 if st_matricula_aluno == ds_rotulo_situacao_matricula
tab check
* 911 2% dos valores não batem
br st_matricula_aluno ds_rotulo_situacao_matricula if check == 0
tab st_matricula_aluno if check == 0
tab ds_rotulo_situacao_matricula if check == 0
* 911 st_matricula_aluno parece estar mais completo, vamos manter essa 
* 911 precisa ver se essa análise se mantém na base completa
drop ds_rotulo_situacao_matricula 
* agora vamos criar os códigos 
br st_matricula_aluno
*sort st_matricula_aluno
tab st_matricula_aluno
* esse aqui é que é o comando que gera os numeros "por baixo"
encode st_matricula_aluno, gen(novo) label(st_matricula_aluno)
drop st_matricula_aluno
rename novo st_matricula_aluno

br co_situacao_matricula st_matricula_aluno 
tab co_situacao_matricula
tab st_matricula_aluno
drop co_situacao_matricula

***** co_tipo_oferta, co_tipo_oferta_curso e ds_tipo_oferta *****
tab co_tipo_oferta 
tab co_tipo_oferta_curso
tab ds_tipo_oferta 
encode ds_tipo_oferta, gen(novo) label(tipo_oferta)
drop ds_tipo_oferta 
rename novo tipo_oferta 
label list tipo_oferta 

***** co_categoria_situacao, st_matricula_aluno_categoria e st_turma *****
*ds vs o co_categoria_situacao (so o 0 nao tem correspondencia)
* MAT_NÃO_CONFIRMADA = 1
* EM CURSO    		 = 3
* CANCELAMENTO 	 	 = 4
* CONCLUSÃO   	 	 = 5
* ABANDONO  	     = 6
* INTERRUPÇÃO 		 = 7

tab co_categoria_situacao
tab st_matricula_aluno_categoria
encode st_matricula_aluno_categoria, gen(novo) label(st_matricula_aluno_categoria)
drop st_matricula_aluno_categoria co_categoria_situacao
rename novo st_matricula_aluno_categoria
label list st_matricula_aluno_categoria

*************** QUANDO CODIGO É COMPLEXO ***************
/*
* ainda nao foi modificada
	br co_ue no_ue
	tab co_ue
	tab no_ue

* ainda nao foi modificada
	co_curso
	no_curso

* ainda nao foi modificada
	co_unidade_ensino_simec
	co_unidade_ensino_remota
	no_unidade_ensino_remota

*/

***** ds_tipo_publico_prioritario *****
	br ds_tipo_publico_prioritario 
	tab ds_tipo_publico_prioritario 
	encode ds_tipo_publico_prioritario, gen(novo) label(tipo_publico_prioritario)
	drop ds_tipo_publico_prioritario
	rename novo tipo_publico_prioritario
	label list tipo_publico_prioritario
	
***** iniciativa *****
	br iniciativa 
	tab iniciativa
	encode iniciativa, gen(novo) label(iniciativa)
	drop iniciativa
	rename novo iniciativa
	label list iniciativa

***** no_demandante *****
	br no_demandante 
	tab no_demandante 
	encode no_demandante, gen(novo) label(no_demandante)
	drop no_demandante
	rename novo no_demandante
	label list no_demandante
	
***** programa *****
	br programa 
	tab programa 
	encode programa, gen(novo) label(programa)
	drop programa 
	rename novo programa 
	label list programa 
	
***** programa  *****
	br no_programa_associado 
	tab no_programa_associado 
	encode no_programa_associado, gen(novo) label(programa_associado)
	drop no_programa_associado
	rename novo programa_associado
	label list programa_associado
	
***** no_subdependencia_admin *****
	br no_subdependencia_admin 
	tab no_subdependencia_admin
	encode no_subdependencia_admin, gen(novo) label(subdependencia_admin)
	drop no_subdependencia_admin
	rename novo subdependencia_admin
	label list subdependencia_admin
	
***** turno *****
	br turno
	tab turno
	encode turno, gen(novo) label(turno)
	drop turno
	rename novo turno
	label list turno
	
***** raca *****
	br raca
	tab raca
	encode raca, gen(novo) label(raca)
	drop raca
	rename novo raca
	label list raca
	
***** escolaridade_aluno *****
	br escolaridade_aluno
	tab escolaridade_aluno
	encode escolaridade_aluno, gen(novo) label(escolaridade_aluno)
	drop escolaridade_aluno
	rename novo escolaridade_aluno
	label list escolaridade_aluno

***** st_turma *****
	br st_turma
	tab st_turma
	encode st_turma, gen(novo) label(st_turma)
	drop st_turma
	rename novo st_turma
	label list st_turma
	
order no_demandante programa tipo_publico_prioritario programa_associado ///
ds_tipo_beneficiario co_tipo_oferta iniciativa co_dependencia_admin dependencia_admin ///
subdependencia_admin co_sistema_ensino rede_ensino ds_regiao_unidade_ensino ///
no_uf_ue co_municipio_ue no_municipio_ue ///
co_tipo_instituicao ds_tipo_instituicao no_unidade_matriz co_ue ///
no_ue co_unidade_ensino_simec co_unidade_ensino_remota  ///
no_unidade_ensino_remota co_modalidade_pagamento ds_modalidade_pagamento ///
co_tipo_curso tipo_curso co_tipo_oferta_curso tipo_oferta ///
modalidade no_eixo_tecnologico co_nivel_ensino ///
escolaridade_curso co_curso no_curso co_catalogo ch_prevista vl_mensalidade_curso ///
qt_meses_curso vl_total_curso co_turma no_turma co_sisutec_turma ///
turno co_far_pronatec matricula co_aluno no_aluno cpf dt_nascimento sexo ///
ds_email no_mae nu_telefone nu_telefone_celular st_contrato_aprendizagem raca ///
escolaridade_aluno st_baixa_renda pcd grupo_tipo_matricula ///
st_turma st_confirmacao_matricula st_matricula_aluno_categoria ///
st_matricula_aluno st_matricula_ativa ///
dt_publicacao dt_deferimento_ue dt_prematricula dt_matricula dt_inicio ///
dt_conclusao_prevista dt_conclusao_real ds_periodo_curso nu_mes_ano_inicio_curso ///
dt_geracao dt_ultima_alteracao

save "${IBGE}alunos_MEC.dta", replace


