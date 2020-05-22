******************************************************************************
**************************DEMANDANTES*****************************************
******************************************************************************
import excel "${RAWDATA}/relatorio_sisutec.xlsx", case(lower) firstrow clear

* Drop useless variables ou string muito grandes
drop no_contato nu_telefone ds_observacao text no_pessoa_juridica  ds_identificador_turma 

* Removing especial caractere, acento, "ç"
remove_special_caractere * , name(1) label(1) value(1)

* Renaming
rename co_oferta_turma			co_turma
rename nu_cnpj					cnpj
rename ano_cadastro_turma		ano
rename co_pessoa_juridica		co_demandante

* ano should be real value
destring ano, replace

* Adjusting CNPJ
replace cnpj = string(real(cnpj),"%014.0f")

validar_cnpj cnpj if length(cnpj)==14
replace cnpj="" if cnpj_valido ==0

* Merging with lis of cnpj
sort no_empresa
merge m:1 no_empresa using "${NEWDATA}/Lista_cnpj_e_nome.dta" 
drop if _merge==2

* Adjusting cnpj var
replace cnpj=cnpj_ajustado if cnpj ==""

*observacoes sem nome da empresa e sem cnpj
drop if cnpj ==""

*3. Organize the data
*keep if co_demandante==48932
*drop co_demandante 
order cnpj ano co_turma

*6. merge
sort cnpj co_turma ano
duplicates drop cnpj co_turma ano, force

*Imporatant vars
keep cnpj ano co_turma co_demandante

compress

save "${IBGE}/demandante.dta", replace
