clear all
set more off

******************************* Rodrigo MAC ************************************
global DROPBOX "/Users/quinrod/Dropbox"

******************************* Rodrigo PC *************************************
*global DROPBOX "C:\Users\rodrigoq\Dropbox\"

******************************* LMK ****************************************
*global DROPBOX "C:\Users\Adm\Dropbox\"

******************************* Leandro ****************************************
*global DROPBOX 	"C:\Users\Leandro-ASUS\Dropbox\rawdata"
*global DO 		"C:\Users\Adm\Dropbox\do files\programs-2018-01\secundar programs"
*global RAWDATA 	"C:\Users\Leandro-ASUS\Dropbox\rawdata"
*global NEWDATA	"C:\Users\Leandro-ASUS\Dropbox\rawdata\newdata"

*************************** Directory globals***********************************
global PAPERS 		"Background_papers"	
global DATA 		"Background_papers_data"
global TEC 			"Technical education and labor market"
global RAWDATA 		"${DROPBOX}/${DATA}/${TEC}/rawdata"
global NEWDATA 		"${DROPBOX}/${DATA}/${TEC}/newdata"
global IBGE 		"${NEWDATA}/IBGE"
global DO 			"${DROPBOX}/${DATA}/${TEC}/do files"
global RESULTS 		"${TEC}/results"
global FIGURES 		"${RESULTS}/figures"
global TABLES 		"${RESULTS}/tables"
global BASE_TEMP 	"${IBGE}/base_temp"
global LIVRO - LMK 	"${DROPBOX}/Lirvo - LMK"
global RODRIGO 		"${LIVRO - LMK}/Rodrigo"
global DESCRITIVAS 	"${RODRIGO}/descritivas"

**********************************DO FILES*************************************

/*- 0  - Defining function to validate codes 							-*/
	do "${DO}/00. prog_cpf_pis_cnpj-v2.do"
	
/*- 1  - Auxiliar function to simplify the code 						-*/
	do "${DO}/01. Functions.do"

/*- 2  - Datas to correct lack of variable 	 							-*/
	do "${DO}/02. Bases de ajuste-CNPJ_Municipio_curso.do"

/*- 3  - Courses data 													-*/
	do "${DO}/03. Prog_TEC_dados_FIC_TEC.do"
	
/*- 4  - Debug of demand`s data 										-*/
	do "${DO}/04. prog_TEC_Demandantes_v2.do"

/*- 5  - Debug of approval`s data  (Homolocagao) 						-*/
	do "${DO}/05. prog_TEC_Homologacao.do"

/*- 6  - Appending demand`s data	and approval`s data   (separeted)	-*/
	do "${DO}/06. prog_TEC_empresas_append.do"

/*- 7  - Preparing a base of registry students MDIC 					-*/
	do "${DO}/07. prog_TEC_alunos_MDIC.do"

/*- 8  - Preparing a base of registry students MEC 						-*/
	do "${DO}/08. prog_TEC_alunos_MEC.do"

/*- 09 - Preparing a base of registry students MEC 						-*/
	do "${DO}/09. prog_TEC_depuracao_MDIC_MEC.do"

/*- 10 - Studying situation and datas data of MDIC and MEC student		-*/
	do "${DO}/10. prog_TEC_avaliando_datas_e_situacoes_MDIC_MEC.do"

/*- 11 - Merging data of student 										-*/		
	do "${DO}/11. prog_TEC_merge_MDIC_MEC_v2.do"
	
/*- 12 - Preparing a base of course with CNPJ							-*/
	do "${DO}/12. prog_TEC_demandante.do"

/*- 13 - Preparing data of RAIS to merge								-*/
	do "${DO}/13. prog_TEC_Preparing_RAIS"	
	
/*- 14 - Merging all data on a single base								-*/
	do "${DO}/14. prog_TEC_nova_estrategia_merge"


/*- Notes -*/
	
* 1- As empresas podem solicitar mais de uma turma com o mesmo numero de vagas.

* 2- Em alguns casos as empresas solicitam mais de 1 curso igual para aumentar a chance
*	 de sua aprovacao

* 3- O municipio de içara está com o código errado. 

* 4- Todos os codigos de curso de fato existem.

* 5- Em 2016, o MDIC pediu as firmas demandantes repeter duas vezes (semestre 1 e 2) 
* a solicitacao das demandas dos cursos, criando assim entradas duplicadas desnecessarias na base 

* 6- As datas referentes a trabalhador sao :dt_nascimento, dt_matricula, dt_prematricula e dt_cadastro sao referentes ao 

* 7- AS datas referentes a Turma sao:  dt_matricula dt_inicio  dt_conclusao_prevista dt_conclusao_real 

* 8- O identifador da base de alunos e matricula, co_turma e co_curso (Podemos usar cpf)

* 9- Datas principais dt_nascimento < dt_prematricula <= dt_inicio < dt_conclusao_prevista ~ dt_conclusao_real
