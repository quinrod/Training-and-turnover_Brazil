# Training and turnover in Brazil
Propensity score matching and differences-in-differences

# Findings
- Difference-in-difference estimates find that workers who enroll in the courses demanded by their employers increase their job tenure by 8.89 months compared to non-enrolled nominees. 
- However, those who complete the training stay in the job 3.36 months less, on average, than those who do not. 
- At firm level, results show that having a course approved is associated with higher turnover in the short run when considering subgroups of workers who participate in Pronatec-MDIC. The effect dissipates in the third year.

# Data

Clean and merge large datasets from technical education and labor registry:

00. prog_cpf_pis_cnpj-v2.do -> Defining function to validate codes 		
01. Functions.do -> Auxiliar function to simplify the code
02. Bases de ajuste-CNPJ_Municipio_curso.do -> Data to correct lack of variable
03. Prog_TEC_dados_FIC_TEC.do -> Course data
04. prog_TEC_Demandantes_v2.do -> Debug firm demand
05. prog_TEC_Homologacao.do -> Debug of firm approval
06. prog_TEC_empresas_append.do -> Appending demand	and approval data
07. prog_TEC_alunos_MDIC.do -> Preparing a database for registered students using MDIC source
08. prog_TEC_alunos_MEC.do -> Preparing a database for registered students using MEC source
09. prog_TEC_depuracao_MDIC_MEC.do -> Compare joint database for registered students
10. prog_TEC_juncao_MDIC_MEC.do -> Analyzing joint database for registered students
11. prog_TEC_merge_MDIC_MEC_v2.do -> Merging data of students
12. prog_TEC_demandante.do -> Preparing a database linking course ID with firm ID
13. prog_TEC_Preparing_RAIS_v2.do -> Preparing database of labor registry to merge	
14. prog_TEC_nova_estrategia_merge_v1.do -> Merging course demand and approval with students as well as firms and worker data
