*remove_special_caractere  x y z, name(1) label(1) value(1)

cap program drop remove_special_caractere
program define remove_special_caractere,
	syntax varlist [, name(string) label(string) value(string)] 
	
	cap des `varlist'
	if _rc!=0 {
		di as red "Theeee variables does not exist"
		error
	}
	
	if "`name'" =="" 	local name =0
	if "`label'"=="" 	local label=0
	if "`value'"=="" 	local value=0
	
	
	* Changing label
	if `label'==1 {
		foreach var of varlist  `varlist' {
			local new_label: var label `var'

			local new_label = trim(lower("`new_label'"))
			local new_label = subinstr("`new_label'","ü" ,"u" ,5)
			local new_label = subinstr("`new_label'","ú" ,"u" ,5)
			local new_label = subinstr("`new_label'","í" ,"i" ,5)
			local new_label = subinstr("`new_label'","ê" ,"e" ,5)
			local new_label = subinstr("`new_label'","é" ,"e" ,5)
			local new_label = subinstr("`new_label'","á" ,"a" ,5)
			local new_label = subinstr("`new_label'","â" ,"a" ,5)
			local new_label = subinstr("`new_label'","À" ,"a" ,5)
			local new_label = subinstr("`new_label'","ã" ,"a" ,5)
			local new_label = subinstr("`new_label'","ç" ,"c" ,5)
			local new_label = subinstr("`new_label'","õ" ,"o" ,5)
			local new_label = subinstr("`new_label'","ô" ,"o" ,5)
			local new_label = subinstr("`new_label'","ó" ,"o" ,5)
			local new_label = subinstr("`new_label'","º" ,""  ,5)
			local new_label = subinstr("`new_label'","n°","no",5)
			local new_label = subinstr("`new_label'","Á" ,"a" ,5)
			local new_label = subinstr("`new_label'","É" ,"e" ,5)
			local new_label = subinstr("`new_label'","Í" ,"i" ,5)
			local new_label = subinstr("`new_label'","Ó" ,"o" ,5)
			local new_label = subinstr("`new_label'","Ú" ,"u" ,5)
			local new_label = subinstr("`new_label'","Â" ,"a" ,5)
			local new_label = subinstr("`new_label'","Ê" ,"e" ,5)
			local new_label = subinstr("`new_label'","Î" ,"i" ,5)
			local new_label = subinstr("`new_label'","Ô" ,"o" ,5)
			local new_label = subinstr("`new_label'","Û" ,"u" ,5)
			local new_label = subinstr("`new_label'","Ã" ,"a" ,5)
			local new_label = subinstr("`new_label'","Õ" ,"o" ,5)
			local new_label = subinstr("`new_label'","Ç" ,"c" ,5)
			local new_label = subinstr("`new_label'","´" ,"'" ,5)
			
			* Changing label
			label var `var' "`new_label'"
		}
	}
	
	* Changing Value
	if `value'==1 {
		foreach var of varlist  `varlist' {
			capture confirm string var `var'
			if _rc==0 {
				replace `var' = trim(lower(`var'))
				replace `var' = subinstr(`var',"ü" ,"u" ,5)
				replace `var' = subinstr(`var',"ú" ,"u" ,5)
				replace `var' = subinstr(`var',"í" ,"i" ,5)
				replace `var' = subinstr(`var',"ê" ,"e" ,5)
				replace `var' = subinstr(`var',"é" ,"e" ,5)
				replace `var' = subinstr(`var',"á" ,"a" ,5)
				replace `var' = subinstr(`var',"ã" ,"a" ,5)
				replace `var' = subinstr(`var',"â" ,"a" ,5)
				replace `var' = subinstr(`var',"À" ,"a" ,5)
				replace `var' = subinstr(`var',"ç" ,"c" ,5)
				replace `var' = subinstr(`var',"õ" ,"o" ,5)
				replace `var' = subinstr(`var',"ô" ,"o" ,5)
				replace `var' = subinstr(`var',"ó" ,"o" ,5)
				replace `var' = subinstr(`var',"º" ,""  ,5)
				replace `var' = subinstr(`var',"n°","no",5)
				replace `var' = subinstr(`var',"Á" ,"a" ,5)
				replace `var' = subinstr(`var',"É" ,"e" ,5)
				replace `var' = subinstr(`var',"Í" ,"i" ,5)
				replace `var' = subinstr(`var',"Ó" ,"o" ,5)
				replace `var' = subinstr(`var',"Ú" ,"u" ,5)
				replace `var' = subinstr(`var',"Â" ,"a" ,5)
				replace `var' = subinstr(`var',"Ê" ,"e" ,5)
				replace `var' = subinstr(`var',"Î" ,"i" ,5)
				replace `var' = subinstr(`var',"Ô" ,"o" ,5)
				replace `var' = subinstr(`var',"Û" ,"u" ,5)
				replace `var' = subinstr(`var',"Ã" ,"a" ,5)
				replace `var' = subinstr(`var',"Õ" ,"o" ,5)
				replace `var' = subinstr(`var',"Ç" ,"c" ,5)
				replace `var' = subinstr(`var',"´" ,"'" ,5)				
			}
			else {
				di as yellow "Warning-`var' is not string. Nothing to change"
			}
		}
	}
	
	* Changing Name
	if `name'==1 {
		foreach var of varlist `varlist' {			
			local new_name = trim(lower("`var'"))
			local new_name = subinstr("`new_name'","ü" ,"u" ,5)
			local new_name = subinstr("`new_name'","ú" ,"u" ,5)
			local new_name = subinstr("`new_name'","í" ,"i" ,5)
			local new_name = subinstr("`new_name'","ê" ,"e" ,5)
			local new_name = subinstr("`new_name'","é" ,"e" ,5)
			local new_name = subinstr("`new_name'","á" ,"a" ,5)
			local new_name = subinstr("`new_name'","ã" ,"a" ,5)
			local new_name = subinstr("`new_name'","â" ,"a" ,5)
			local new_name = subinstr("`new_name'","À" ,"a" ,5)
			local new_name = subinstr("`new_name'","ç" ,"c" ,5)
			local new_name = subinstr("`new_name'","õ" ,"o" ,5)
			local new_name = subinstr("`new_name'","ô" ,"o" ,5)
			local new_name = subinstr("`new_name'","ó" ,"o" ,5)
			local new_name = subinstr("`new_name'","º" ,""  ,5)
			local new_name = subinstr("`new_name'","n°","no",5)
			local new_name = subinstr("`new_name'","Á" ,"a" ,5)
			local new_name = subinstr("`new_name'","É" ,"e" ,5)
			local new_name = subinstr("`new_name'","Í" ,"i" ,5)
			local new_name = subinstr("`new_name'","Ó" ,"o" ,5)
			local new_name = subinstr("`new_name'","Ú" ,"u" ,5)
			local new_name = subinstr("`new_name'","Â" ,"a" ,5)
			local new_name = subinstr("`new_name'","Ê" ,"e" ,5)
			local new_name = subinstr("`new_name'","Î" ,"i" ,5)
			local new_name = subinstr("`new_name'","Ô" ,"o" ,5)
			local new_name = subinstr("`new_name'","Û" ,"u" ,5)
			local new_name = subinstr("`new_name'","Ã" ,"a" ,5)
			local new_name = subinstr("`new_name'","Õ" ,"o" ,5)
			local new_name = subinstr("`new_name'","Ç" ,"c" ,5)
			local new_name = subinstr("`new_name'","´" ,"'" ,5)	
			
			*Renaming
			rename  `var' `new_name'
		}
	}
	

end program



* Replacing vars 
cap program drop replace_especific_values
program define replace_especific_values,
	syntax varlist 

	* Changing Name
		foreach var of varlist  `varlist' {
			capture confirm string var `var'
			if _rc==0 {		
				*replace municipios
				replace `var' ="icara" 									if `var' =="balneario rincao"
				replace `var' ="taquaral de goiás" 		if `var' =="taquaral"
				
				*replace `var'	
				replace `var' = "automotivo" 							if `var' =="autopecas"
				replace `var' = "automotivo" 							if `var' =="bicicletas"
				replace `var' = "automotivo" 							if `var' =="brinquedos"
				replace `var' = "farmacos" 								if `var' =="complexo da saude"
				replace `var' = "confeccoes e textil" 					if `var' =="confeccao"
				replace `var' = "maquinas e equipamentos" 				if `var' =="defesa"
				replace `var' = "comercio" 								if `var' =="gemas e joias"
				replace `var' = "higiene, perfumaria e cosmeticos" 		if `var' =="hppc"
				replace `var' = "metalurgia e siderurgia" 				if `var' =="metalurgia"
				replace `var' = "maquinas e equipamentos" 				if `var' =="naval"
				replace `var' = "celulose e papel" 						if `var' =="papel e celulose"
				replace `var' = "quimica" 								if `var' =="quimico"
				replace `var' = "logistica portuaria e aeroportuaria" 	if `var' =="serviços logisticos"
				replace `var' = "metalurgia e siderurgia" 				if `var' =="siderurgia"
				replace `var' = "confeccoes e textil" 					if `var' =="textil"
				replace `var' = "tic/complexo eletroeletronico"			if `var' =="tic/complexo eletronico"
				*replace setor_empresa
				replace `var' = "construcao" 							if `var' =="construcao civil"
				replace `var' = "construcao" 							if `var' =="construcao civil e pesada"
				replace `var' = "construcao" 							if `var' =="construcao pesada"
				replace `var' = "confeccoes e textil"	 				if `var' =="couro"
				replace `var' = "agronegocios" 							if `var' =="producao"
				replace `var' = "sucroalcooleiro" 						if `var' =="sucroenergetico"				
				
				*replace no_curso
				replace `var' ="agente de coleta e entrega no transporte de pequenas cargas" 	if `var' =="agente de coleta e entrega no transporte pequenas cargas"
				replace `var' ="agente de regularizacao ambiental rural" 						if `var' =="agente de regularizacao ambiental"
				replace `var' ="agente de recepcao e reservas em meios de hospedagem" 			if `var' =="agente de reservas em meios de hospedagem"
				replace `var' ="confeiteiro" 													if `var' =="auxiliar de confeitaria"
				replace `var' ="padeiro" 														if `var' =="auxiliar de padeiro"
				replace `var' ="pedreiro de refratario" 										if `var' =="auxiliar em fabricacao de refratarios"
				replace `var' ="reciclador" 													if `var' =="catador de material reciclavel"
				replace `var' ="gestor de microempresa" 										if `var' =="empresario de micro empresa"
				replace `var' ="pescador profissional-pop" 										if `var' =="pescador" 
				replace `var' ="agente de recepcao e reservas em meios de hospedagem" 			if `var' =="recepcionista em meios de hospedagem"
                        
		}
	}
	

end program



* Replacing vars 
cap program drop labels_vars
program define labels_vars
		foreach var of varlist * {	
				if "`var'"=="no_empresa" 			label var no_empresa 				"nome da empresa"
				if "`var'"=="cnpj"					label var cnpj 						"cnpj"
				if "`var'"=="no_curso" 				label var no_curso					"nome do curso"
				if "`var'"=="no_uf_empresa" 		label var no_uf_empresa				"nome uf da empresa" 
				if "`var'"=="no_municipio_empresa" 	label var no_municipio_empresa		"nome municipio da empresa"
				if "`var'"=="setor_empresa" 		label var setor_empresa				"setor_empresa" 
				if "`var'"=="vagas_demandadas_d" 	label var vagas_demandadas_d		"vagas solicitadas"
				if "`var'"=="cbo" 					label var cbo						"ocupacao"
				if "`var'"=="ano" 					label var ano   					"ano" 
				if "`var'"=="no_curso" 				label var no_curso					"nome do curso"
				if "`var'"=="no_uf_empresa" 		label var no_uf_empresa				"nome uf da empresa" 
				if "`var'"=="no_municipio_empresa" 	label var no_municipio_empresa		"nome municipio da empresa"
				if "`var'"=="empregados_empresa"	label var empregados_empresa		"empregados_empresa"
				if "`var'"=="n_empregados_empresa"	label var n_empregados_empresa		"nao empregados na empresa"
				if "`var'"=="semestre"				label var semestre					"semestre solicitacao"
		}
end program


