#!/bin/bash
#
####################################### AFUMB ##########################################################################
#                                                                                                                      #
# Parámetros entrada:  (LISTA_ARCH_ACEP, MAE_COD_PAIS, MAE_COD_AREA_ARG, MAE_CENTRAL, MAE_AGENTES, TAB_TIPO_LLAMADAS,  #
#	                TAB_UMB_CONS)                                                                                  #
# Parámetros salida:   (ARCH_LLAM_SOSP, ARCH_PROC, ARCH_REG_RECH, ARCH_RECH, LOG_COMANDO                               # #	                                                                                                               #
# LISTA_ARCH_ACEP: Archivos de llamadas aceptadas                                                                      #
# MAE_COD_PAIS: Maestro de códigos de país.                                                                            #
# MAE_COD_AREA_ARG: Maestro de códigos de área de Argentina.                                                           #
# MAE_CENTRAL: Maestro de centrales.                                                                                   #
# MAE_AGENTES: Maestro de Agentes.                                                                                     #
# TAB_TIPO_LLAMADAS: Tabla de tipos de llamadas.                                                                       #
# TAB_UMB_CONS: Tabla de umbrales de consumo.                                                                          #
# ARCH_LLAM_SOS: Archivos de llamadas sospechosas.                                                                     #
# ARCH_PROC: Archivos procesados.                                                                                      #
# ARCH_REG_RECH: Archivos de registros rechazados.                                                                     #
# ARCH_RECH: Archivos rechazados.                                                                                      #
# LOG_COMANDO: Log del comando                                                                                         #
#                                                                                                                      #
########################################################################################################################


# Variables / Constantes
# ==============================================================================================
#NOVEDIR=$PWD/acep #Modificar por el valor correcto. 
MAEDIR=$PWD/master #Modificar por el valor correcto. 

source MoverA.sh
source GraLog.sh
LOGDIR="$PWD/log"
LOGSIZE=100
LOGEXT=log

#CONTADORES
CANT_ARCH_PROCESADOS=0
CANT_ARCH_RECHAZADOS=0	
CANT_LLAMADAS=0	
CANT_LLAM_CON_UMBRAL=0
CANT_LLAM_SIN_UMBRAL=0
CANT_LLAM_SOSPECHOSAS=0
CANT_LLAM_NO_SOSPECHOSAS=0	
CANT_LLAM_RECHAZADAS=0


#MAE_COD_PAIS=$2
MAE_COD_PAIS="../master/CdP" #TODO-BORRAR ES SOLO PARA PROBAR
#MAE_COD_AREA_ARG=$3
MAE_COD_AREA_ARG="../master/CdA"  #TODO-BORRAR ES SOLO PARA PROBAR
#MAE_CENTRAL=$4
MAE_CENTRAL="../master/CdC"  #TODO-BORRAR ES SOLO PARA PROBAR
#MAE_AGENTES=$5 
MAE_AGENTES="../master/agentes"  #TODO-BORRAR ES SOLO PARA PROBAR
TAB_TIPO_LLAMADAS=$6
TAB_UMB_CONS=$7

#DIRECTORIO_ACEP=$ACEPDIR #Obtengo el directorio donde se almacenan los archivos aceptados.
#DIRECTORIO_PROC=$PROCDIR #Obtengo el directorio donde se almacena los archivos procesados
#DIRECTORIO_RECH=$RECHDIR #Obtnego el directorio de archivos rechazados.
DIRECTORIO_ACEP="$PWD/acep" #TODO- borrar es solo para probar.
DIRECTORIO_PROC="$PWD/proc" #TODO- borrar es solo para probar.
DIRECTORIO_RECH="$PWD/rech" #TODO- borrar es solo para probar.

# Funciones
#=================================================================================================

validarAgente() {

	
	#buscar el agente en el maestro de agentes.
	existe=$(grep "$1" "$MAE_AGENTES") 
	agente_encontrado=$(echo "$existe" | cut -d ';' -f3)
	if [ "$agente" != "$agente_encontrado" ]
	then
		GraLog AFUMB INFO "Agente invalido: $agente"
		echo 1
		return
	fi
	#valido ok
	echo 0

}

validarArea() {

	#buscar area en el maestro de codigo de areas
	area=$1
	existe_area=$(grep -w "$area" "$MAE_COD_AREA_ARG") 
	area_encontrada=$(echo "$existe_area" | cut -d ';' -f2)
	if [ ! -z $area_encontrada ]
	then	
		if [ $area -ne $area_encontrada ]
		then
			echo 1 
			return
		fi
	else
		echo 1
		return
	fi
	#area valida
	echo 0
}

validarNumeroLineaA() {
	
	longArea=${#1}
	longlinea=${#2}
	linea_ok=$(validarLineaA $longArea $longlinea)
	if [ $linea_ok -ne 0 ]
	then 
		GraLog AFUMB INFO "Linea A invalido: $1"	
		echo 1
		return
	fi
	echo 0
}

validarNumeroLineaB() {
	
	#validar tipo de llamada
	TIPO_LLAMADA=$(determinarTipoLlamada "$1")
	NUMLINEA=$(echo "$1" | cut -d';' -f8)
	if [ "$TIPO_LLAMADA" = "DDI" ]
	then	
		COD_AREA_PAIS=$(echo "$1" | cut -d';' -f6)
		#GraLog AFUMB INFO "Codigo area pais: $COD_AREA_PAIS"
		if [ ! -z $COD_AREA_PAIS ]
		then
			COD_AREA_PAIS_OK=$(validarCodPais $COD_AREA_PAIS)
			if [ $COD_AREA_PAIS_OK -eq 0 ]
			then
				#Como la llamada es DDI no tiene codigo de area
				#valido la linea
				VALIDA_LINEA=$(echo "$NUMLINEA" | egrep '^[0-9]*')
				if [ $VALIDA_LINEA -eq $NUMLINEA ]
				then
					echo 0
					return
				else
					GraLog AFUMB INFO "Formato linea invalido: $NUMLINEA"
					echo 1
					return
				fi
			
			else
				GraLog AFUMB INFO "Codigo area pais invalido: $COD_AREA_PAIS"
				echo 1
				return
			fi
		fi
	else
		if [ "$TIPO_LLAMADA" = "DDN" ] || [ "$TIPO_LLAMADA" = "LOC" ]	
		then
			COD_AREA=$(echo "$1" | cut -d';' -f7)
			#GraLog AFUMB INFO "COD_AREA: $COD_AREA"
			#Valido el codigo de area
			COD_AREA_OK=$(validarArea $COD_AREA)
			if [ $COD_AREA_OK -eq 0 ] 
			then
				
				#Area valida		
				#Tipo de llamada LOCAL o DDN			
				AREA_LINEA=$COD_AREA$NUMLINEA
				#GraLog AFUMB INFO "AREA_LINEA: $AREA_LINEA"
				LONG_AREA_LINEA=${#AREA_LINEA}
				if [ $LONG_AREA_LINEA -eq 10 ]
				then
					#GraLog AFUMB INFO "Linea B VALIDA: $NUMLINEA"
					echo 0
					return
				else

					GraLog AFUMB INFO "Linea B invalido: $NUMLINEA"
					echo 1
					return
				fi
			else 

				GraLog AFUMB INFO "Codigo area invalido: $COD_AREA"
				echo 1
				return

			fi
		else
			GraLog AFUMB INFO "Linea B invalido: $NUMLINEA"
			echo 1
			return
		fi
	fi
}

validarCodPais() {
	
	EXISTE_COD_AREA_PAIS=$(grep -w "$1" "$MAE_COD_PAIS") 
	COD_AREA_PAIS_ENC=$(echo "$EXISTE_COD_AREA_PAIS" | cut -d ';' -f1)
	if [ $COD_AREA_PAIS -ne $COD_AREA_PAIS_ENC ] 
	then
		GraLog AFUMB INFO "Codigo pais invalido: $COD_AREA_PAIS"
		echo 1
		return
	fi
	echo 0
}

validarTiempoConversacion() {

	TIEMPO=$(echo "$1" | cut -d';' -f3)
	if [ $TIEMPO -lt 0 ]
	then
		GraLog AFUMB INFO "Tiempo de conversacion invalido: $TIEMPO"
		echo 1
		return
	fi
	echo 0
}

validarLineaA() {

#$1 longArea
#$2 longlinea

	if [ $1 -eq 2 ]
	then
		#linea 8 digitos
		if [ $2 -ne 8 ]
		then
			#linea invalida
			GraLog AFUMB INFO "linea invalida: $2"
			echo 1
			return
		fi
	else
		if [ $1 -eq 3 ]
		then
			#linea 7 digitos
			if [ $2 -ne 7 ]
			then
				#linea invalida
				GraLog AFUMB INFO "linea invalida: $2"
				echo 1
				return
			fi
		else
			#linea 6 digitos
			if [ $2 -ne 6 ]
			then
				#linea invalida
				GraLog AFUMB INFO "linea invalida: $2"
				echo 1
				return
			fi
		fi
	fi
	#linea valida
	echo 0
}

determinarTipoLlamada() {

	REGISTRO=$1
	COD_AREA_PAIS=$(echo "$REGISTRO" | cut -d';' -f6)
	if [ ! -z $COD_AREA_PAIS ]
	then
		#GraLog AFUMB INFO "EXISTE CODIGO AREA PAIS"		
		COD_AREA_PAIS_OK=$(validarCodPais $COD_AREA_PAIS)
		#GraLog AFUMB INFO "COD_AREA_PAIS: $COD_AREA_PAIS"
		LINEA_B=$(echo "$REGISTRO" | cut -d';' -f8)
		#GraLog AFUMB INFO "LINEA_B: $LINEA_B"
		#GraLog AFUMB INFO "COD_AREA_PAIS_OK: $COD_AREA_PAIS_OK"
		if [ $COD_AREA_PAIS_OK -eq  0 ]  &&  [ ! -z $LINEA_B ]
		then
			#tipo de llamada DDI
			#GraLog AFUMB INFO "TIPO DE LLAMADA DDI"	
			echo "DDI"
			return
		else
			echo "INV"
			return 
		fi
	else
		LINEA_A=$(echo "$REGISTRO" | cut -d';' -f5)
		COD_AREA_A=$(echo "$REGISTRO" | cut -d';' -f4)
		COD_AREA_B=$(echo "$REGISTRO" | cut -d';' -f7)
		LONG_AREA=${#COD_AREA_A}
		LONG_LINEA=${#LINEA_A}
		LINEA_A_OK=$(validarLineaA $LONG_AREA $LONG_LINEA)	
		if [ $COD_AREA_A -ne $COD_AREA_B ] && [ $LINEA_A_OK -eq 0 ]
		then
			#tipo de llamada DDN
			#GraLog AFUMB INFO "TIPO LLAMADA DDN"
			echo "DDN"
			return
		else
			if [ $COD_AREA_A -eq $COD_AREA_B ] && [ $LINEA_A_OK -eq 0 ]
			then
				#tipo de llamada local
				#GraLog AFUMB INFO "TIPO DE LLAMADA LOC"				
				echo "LOC"
				return
			else
				#tipo de llamada invalida
				GraLog AFUMB INFO "Tipo de llamada invalido"
				echo "INV"
				return
			fi
		fi
	
	fi
}

validarRegistro() {

	#valido agente
	reg=$1
	agente=$(echo "$reg" | cut -d';' -f1)	
	validaAgente=$(validarAgente $agente) 
	if [ $validaAgente -eq 0 ]
	then	
		#valido area
		area=$(echo "$reg" | cut -d';' -f4)
		validaArea=$(validarArea $area)
		if [ $validaArea -eq 0 ]
		then
			
			#valido numero linea A
			numerolinea=$(echo "$reg" | cut -d';' -f5)
			validaNumeroLineaA=$(validarNumeroLineaA $area $numerolinea)
			if [ $validaNumeroLineaA -eq 0 ]
			then
		
				#valido el numero linea B
				validaNumeroLineaB=$(validarNumeroLineaB "$reg")
				if [ $validaNumeroLineaB -eq 0 ]
				then	
					#valido el tiempo de conversacion
					validaTiempoConv=$(validarTiempoConversacion "$reg")	
					if [ $validaTiempoConv -eq 0 ]
					then
							
						echo 0
						return
					else
						GraLog AFUMB INFO "Registro invalido: $reg"
						echo 1
						return
					fi
				else
					GraLog AFUMB INFO "Regisro invalido: $reg"
					echo 1
					return
				fi 		
				
			else
				GraLog AFUMB INFO "Regisro invalido: $reg"
				echo 1
				return
			fi 		
		else
			GraLog AFUMB INFO "Regisro invalido: $reg"
			echo 1
			return
		fi
	else
		GraLog AFUMB INFO "Regisro invalido: $reg"
		echo 1
		return
	fi
}

rechazarRegistro() {

	#OBTENGO TODOS LOS DATOS A GRABAR EN EL ARCHIVO DE RECHAZOS
	REGISTRO=$1
	FUENTE=$2	
	MOTIVO=$3
	COD_CENTRAL=$(echo "$FUENTE" | cut -d '_' -f 1)
	NOMBRE_ARCHIVO=$COD_CENTRAL".rech"
	PATH_ARCH_RECHAZADOS=$DIRECTORIO_RECH"/Llamadas"

	#VALIDO QUE EL DIRECTORIO DE LLAMADAS RECHAZADAS EXISTA
	if [ ! -d "$PATH_ARCH_RECHAZADOS" ]
	then
		#SINO EXISTE CREO EL DIRECTORIO
		mkdir -p "$PATH_ARCH_RECHAZADOS"
	fi

	#VERIFICO SI EXISTE EL ARCHIVO DE LLAMADAS RECHAZADAS
	EXISTE_ARCH=`ls $PATH_ARCH_RECHAZADOS | grep "$NOMBRE_ARCHIVO"`
	if [ -z $EXISTE_ARCH ]
	then
		#CREO EL ARCHIVO
		>"$PATH_ARCH_RECHAZADOS/$NOMBRE_ARCHIVO"
	fi

	#GUARDO EL REGISTRO	
	echo $FUENTE";"$MOTIVO";"$REGISTRO>>"$PATH_ARCH_RECHAZADOS/$NOMBRE_ARCHIVO"
	
}


function determinarLlamadasSospechosas(){
	# Archivo con llamadas entrantes.	
	#ARCHIVO_DE_LLAMADAS=$1
	IFS_OLD=$IFS
	IFS=";"
	# Para generar un nombre de un archivo
	DATE=`date +%Y-%m-%d`

	# Notacion UM: umbral			
	#	   CO: codigo
	#	   TI: tipo
	#      NU: numero
	#      LL: llamada

	# Leo todos los archivos con llamadas entrantes.
	LLAMADA=$1 # Registro de una llamada.

	# Get campos de una llamada entrante.
	LL_ID_AGENTE=$(echo "$LLAMADA" | cut -d';' -f1) 
	LL_FECHA=$(echo "$LLAMADA" | cut -d';' -f2) 	
	LL_TIEMPO_CONVERSACION=$(echo "$LLAMADA" | cut -d';' -f3) 
	LL_NU_AREA=$(echo "$LLAMADA" | cut -d';' -f4) 
	LL_NU_LINEA_A=$(echo "$LLAMADA" | cut -d';' -f5) #parche
	LL_CO_PAIS_B=$(echo "$LLAMADA" | cut -d';' -f6) 
	LL_CO_AREA_B=$(echo "$LLAMADA" | cut -d';' -f7) 
	LL_NU_LINEA_B=$(echo "$LLAMADA" | cut -d';' -f8) 
	#echo "valores de una llamada: $LL_NU_AREA $LL_NU_LINEA_A $LL_CO_PAIS_B $LL_NU_LINEA_B"

	# Por cada llamada. Busco en el umbral y clasifico.
	#	
	# Cantidad de registros a procesar.
	CANT_REGISTROS=$(grep $LL_NU_LINEA_A $MAEDIR/umbral.tab | wc -l) 
	
	# Registros a procesar en un archivo temporal.
	grep $LL_NU_LINEA_A $MAEDIR/umbral.tab >> temporal_umbral #CAmbiar por la linea de arriba.
	#grep "4314928" $MAEDIR/umbral.tab >> temporal_umbral #TEMP: ELIMINAR.
	

	if [ $CANT_REGISTROS -eq 0  ] 
	then
		#echo "La llamada $LL_NU_LINEA_A no se encuentra en la lista de umbrales, contabilizar."
		CANT_LLAM_SIN_UMBRAL=$(($CANT_LLAM_SIN_UMBRAL+1))
	
	else
		CANT_LLAM_CON_UMBRAL=$(($CANT_LLAM_CON_UMBRAL+1))
		while read line
		do	

			UMBRAL=($line)
			UM_ID=${UMBRAL[0]}
			UM_CO_AREA_ORIGEN=${UMBRAL[1]}
			UM_NU_ORIGEN=${UMBRAL[2]}
			UM_TI_LLAMADA=${UMBRAL[3]}
			UM_CO_DESTINO=${UMBRAL[4]}
			UM_TOPE=${UMBRAL[5]}
			UM_ESTADO=${UMBRAL[6]}

			#echo "UM_CO_DESTINO= $UM_CO_DESTINO"
			if [ $UM_TI_LLAMADA = "DDI" ]
			then
				#echo " $UM_ESTADO = Inactivo  $UM_CO_AREA_ORIGEN = $LL_NU_AREA $UM_NU_ORIGEN = $LL_NU_LINEA_A $UM_CO_DESTINO = $LL_CO_PAIS_B  $UM_CO_DESTINO  $UM_TOPE <= $LL_TIEMPO_CONVERSACION "
				#if [ "$UM_ESTADO" = "Activo" ] && [ $UM_CO_AREA_ORIGEN = $LL_NU_AREA ] && [ $UM_NU_ORIGEN = $LL_NU_LINEA_A ] && [ -z $UM_CO_DESTINO  ] || [ $UM_CO_DESTINO = $LL_CO_PAIS_B ]  && [ $UM_TOPE -lt $LL_TIEMPO_CONVERSACION ]
				if [ "$UM_ESTADO" = "Activo" ] && [ $UM_CO_AREA_ORIGEN = $LL_NU_AREA ] && [ $UM_NU_ORIGEN = $LL_NU_LINEA_A ] && [ -z $UM_CO_DESTINO  ] && [ $UM_TOPE -lt $LL_TIEMPO_CONVERSACION ] #FIXME: Falta chequear cuando un valor es nulo $UM_CO_DESTINO
					then 												
					# Guardo la llamada como sospechosa.
					echo "$LL_ID_AGENTE;$LL_FECHA;$LL_TIEMPO_CONVERSACION;$LL_NU_AREA;$LL_NU_LINEA_A; ;$LL_CO_AREA_B;$LL_NU_LINEA_B" >> $DIRECTORIO_PROC/COS_${DATE}
					CANT_LLAM_SOSPECHOSAS=$(($CANT_LLAM_SOSPECHOSAS+1))

				else # No es una llamada sospechosa
					CANT_LLAM_NO_SOSPECHOSAS=$(($CANT_LLAM_NO_SOSPECHOSAS+1))		
				fi
			elif [ $UM_TI_LLAMADA = "DDN" ] || [ $UM_TI_LLAMADA = "LOC" ]
			then		
				#echo " $UM_ESTADO = Inactivo  $UM_CO_AREA_ORIGEN = $LL_NU_AREA $UM_NU_ORIGEN = $LL_NU_LINEA_A $UM_CO_DESTINO = $LL_CO_PAIS_B  $UM_CO_DESTINO  $UM_TOPE -lt $LL_TIEMPO_CONVERSACION "
				#if [ $UM_ESTADO = "Activo" ] && [ $UM_CO_AREA_ORIGEN = $LL_NU_AREA ] && [ $UM_NU_ORIGEN = $LL_NU_LINEA_A ] && [ $UM_CO_DESTINO = $LL_CO_PAIS_B ] && [ ! -z $UM_CO_DESTINO ] && [ $UM_TOPE -lt $LL_TIEMPO_CONVERSACION ]
				if [ $UM_ESTADO = "Activo" ] && [ $UM_CO_AREA_ORIGEN = $LL_NU_AREA ] && [ $UM_NU_ORIGEN = $LL_NU_LINEA_A ] && [ -z $UM_CO_DESTINO ] && [ $UM_TOPE -lt $LL_TIEMPO_CONVERSACION ] #FIXME: Como en el caso
					then
					# Guardo la llamada como sospechosa.
					echo "$LL_ID_AGENTE;$LL_FECHA;$LL_TIEMPO_CONVERSACION;$LL_NU_AREA;$LL_NU_LINEA_A;$LL_CO_PAIS_B; ;$LL_NU_LINEA_B" >> $DIRECTORIO_PROC/COS_${DATE}
					CANT_LLAM_SOSPECHOSAS=$(($CANT_LLAM_SOSPECHOSAS+1))
				else # No es una llamada sospechosa
					CANT_LLAM_NO_SOSPECHOSAS=$(($CANT_LLAM_NO_SOSPECHOSAS+1))	
				fi
			fi			
			#Si tengo mas de un umbral a comparar solo me quedo con el primero.			
			break						

		done < temporal_umbral
		rm temporal_umbral
	fi
}


###PRINCIPAL###

#CALCULO LA CANTIDAD DE ARCHIVOS A PROCESAR

CANT_TOTAL_ARCH=$(ls $DIRECTORIO_ACEP | wc -l)

#INICIALIZO EL LOG

GraLog AFUMB INFO "Inicio de AFUMB"
GraLog AFUMB INFO "Cantidad de archivos a procesar: $CANT_TOTAL_ARCH"


#1 - PROCESAR ARCHIVOS EN ORDEN CRONOLOGICO, DEL MAS ANTIGUO AL MAS NUEVO

for FILE in `ls $DIRECTORIO_ACEP | sort -t"_" -k1`
do
	path_origen=$DIRECTORIO_ACEP"/"$FILE
	#GraLog AFUMB INFO "Proceso: $FILE"
	arch=""
	
	#2 - Verifico que el archivo no este duplicado
	ls -1 $DIRECTORIO_PROC > "$DIRECTORIO_PROC/nombres_archivos.tmp"

	arch=`grep "$FILE" "$DIRECTORIO_PROC/nombres_archivos.tmp"`	

	path_destino_rech=$DIRECTORIO_RECH"/"$FILE
	
	if [ "$arch" = "$FILE" ]
	then
		#ARCHIVO DUPLICADO MOVER A RECHAZADOS
		MoverA $path_origen $path_destino_rech
		GraLog AFUMB INFO "Se rechaza el archivo por estar duplicado: $FILE"
		#INCREMENTO CONTADOR DE ARCHIVO RECHAZADO
		CANT_ARCH_RECHAZADOS=$(($CANT_ARCH_RECHAZADOS+1))
		exit 1
	fi
	
	#SE VERIFICA LA CANTIDAD DE CAMPOS DEL PRIMER REGISTRO
	linea=$(head -1 $path_origen)
	cant_de_campos=$((`echo "$linea" | grep -o ';' | wc -l` + 1))	
	
	if [ $cant_de_campos -ne 8 ]
	then
		#ARCHIVO CON FORMATO INVALIDO		
		MoverA $path_origen $path_destino_rech
		GraLog AFUMB INFO "Se rechaza el archivo porque su estrutura no se corresponde con el formato esperado: $FILE"
		#INCREMENTO CONTADOR DE ARCHIVO RECHAZADO
		CANT_ARCH_RECHAZADOS=$(($CANT_ARCH_RECHAZADOS+1))
		exit 1
	fi
	
	#3 - ARCHIVO A PROCESAR
	GraLog AFUMB INFO "Archivo a procesar: $FILE"
	
	#4 - PROCESAR UN REGISTRO
	while read linea
	do
		CANT_LLAMADAS=$(($CANT_LLAMADAS+1))
		#VALIDAR LOS CAMPOS DEL REGISTRO
		validaRegistro=$(validarRegistro "$linea")
		if [ $validaRegistro -eq  0 ]
		then
			#PROCESO PARA DETERMINAR SI LA LLAMADA ES SOSPECHOSA			
			determinarLlamadasSospechosas "$linea"

		else 
			#PROCESO PARA RECHAZAR REGISTRO
			rechazarRegistro "$linea" "$FILE" "REGISTRO INVALIDO"
			CANT_LLAM_RECHAZADAS=$(($CANT_LLAM_RECHAZADAS+1))
		fi	
				
	done < $path_origen

	#6 - FIN DEL ARCHIVO	
	path_destino_proc=$DIRECTORIO_PROC"/"$FILE
	MoverA $path_origen $path_destino_proc
	GraLog AFUMB INFO "Archivo procesado: $FILE"
	
	#TOTALES A GRABAR
	GraLog AFUMB INFO "Cantidad de llamadas= $CANT_LLAMADAS: Rechazadas= $CANT_LLAM_RECHAZADAS Con umbral= $CANT_LLAM_CON_UMBRAL Sin umbral= $CANT_LLAM_SIN_UMBRAL"
	GraLog AFUMB INFO "Cantidad de llamadas sospechosas= $CANT_LLAM_SOSPECHOSAS, No sospechosas= $CANT_LLAM_NO_SOSPECHOSAS"

	#INCREMENTO CONTADOR DE ARCHIVO PROCESADO
	CANT_ARCH_PROCESADOS=$(($CANT_ARCH_PROCESADOS+1))

	#7 - INICIALIAZAR CONTADORES DE REGISTROS
	CANT_LLAMADAS=0	
	CANT_LLAM_CON_UMBRAL=0
	CANT_LLAM_SIN_UMBRAL=0
	CANT_LLAM_SOSPECHOSAS=0
	CANT_LLAM_NO_SOSPECHOSAS=0	
	CANT_LLAM_RECHAZADAS=0
done

#10 - FIN DEL PROCESO
GraLog AFUMB INFO "Cantidad de archivos procesados: $CANT_ARCH_PROCESADOS"
GraLog AFUMB INFO "Cantidad de archivos rechazados: $CANT_ARCH_RECHAZADOS"
GraLog AFUMB INFO "Fin de AFUMB"




