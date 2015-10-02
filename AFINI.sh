#!/bin/bash

#retorno de valores
# 0: Inicialización OK
# 1: No existe archivo de configuración (AFINSTAL.cnfg)
# 2: El archivo de configuración AFINSTAL.cnfg no tiene permisos de lectura
# 3: El usuario cierra la sesión
# 4: El usuario continúa la sesión
function inicializarAmbiente {

	# CASO 1 : AMBIENTE NO INICIALIZADO
	if [ -z $MAEDIR ]; then
		# Si no existe el archivo de configuración, volver a instalar
		if [ ! -f "conf/AFINSTAL.cnfg" ]; then
			echo "No se encontro archivo de configuración AFINSTAL.cnfg"
			echo "Vuelva a realizar la instalación"
			bash ./GraLog.sh AFINI EF "No se encontró el archivo de configuración."
			return 1
		else
			# Si existe, verificar permisos de lectura
			if [ ! -r "conf/AFINSTAL.cnfg" ]; then
				chmod +r "conf/AFINSTAL.cnfg"
				if [ ! -r "conf/AFINSTAL.cnfg" ]; then
					echo "El archivo AFINSTAL.cnfg no tiene permisos de lectura."
					bash ./GraLog.sh AFINI E "El archivo de configuración no tiene permisos de lectura."
					return 2
				fi
			fi
		fi

		echo "Inicializando variables de ambiente..."
		oldIFS=$IFS
		IFS=$'\n'
		# Seteo de variables de ambiente
		for linea in $(< "conf/AFINSTAL.cnfg")
		do
			nombre_var=`echo $linea | cut -d "=" -f1`
			valor=`echo $linea | cut -d "=" -f2`
			export $nombre_var=$valor

			if [ "$nombre_var" == "BINDIR" ]; then
				PATH="$PATH:$valor"	
			fi	
		done
		IFS=$oldIFS
		sleep 1
		echo "Ambiente Inicializado : OK"
		bash ./GraLog.sh AFINI I "El ambiente ha sido inicializado correctamente."

	# CASO 2 : AMBIENTE INICIALIZADO
	else
		echo "Ambiente ya inicializado."
		echo "Para reiniciar, termine la sesión e ingrese nuevamente."
		bash ./GraLog.sh AFINI W "Se quiere inicializar ambiente ya inicializado."
		echo "¿Desea terminar la sesión? (s-n)"
		read terminar

		if [ $terminar == 's' ]; then
			echo "Cerrando Sesión"
			bash ./GraLog.sh AFINI I "Usuario cierra sesión."
			return 3
		else
			if [ $terminar == 'n' ]; then
				echo "Continua con la sesión"
				return 4
			else	
				echo "Opción ingresada inválida. Intente nuevamente"
				inicializarAmbiente # Llamada recursiva
			fi
		fi
	fi

	return 0
}

#retorno de valores
# 0: Instalación Completa
# 1: Faltante de Archivos (Scripts, Maestros, Tablas, etc.)
function instalacionCompleta {
	instalacionOk=0
	echo "Verificando Scripts..."
	sleep 1
	existenScripts
	ret=$?
	if [ $ret -ne 0 ]; then
		instalacionOk=1
	fi
	echo "Verificando Maestros y Tablas..."
	sleep 1
	existenMaestrosYTablas
	ret=$?
	if [ $ret -ne 0 ]; then
		instalacionOk=1
	fi

	if [ $instalacionOk -ne 0 ]; then
		echo "Instalación Incompleta. Por favor, vuelta a realizar la instalación e intente nuevamente."
		bash ./GraLog.sh AFINI EF "Instalacion incompleta."
		return 1
	fi

	return 0
}

#retorno de valores
# 0: Existen todos los scripts correspondientes
# 1: Faltante de algún script
function existenScripts {
	todoOk=0
	# chequeo si existe archivo ejecutable MoverA.sh
	if [ ! -f "$BINDIR/MoverA.sh" ]; then
		todoOk=1
		echo " Archivo Ejecutable MoverA: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo ejecutable MoverA."
	fi

	# chequeo si existe archivo ejecutable AFREC.sh
	if [ ! -f "$BINDIR/AFREC.sh" ]; then
		todoOk=1
		echo " Archivo Ejecutable AFREC: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo ejecutable AFREC."
	fi	

	# Agregar los ejecutables que falten
	return $todoOk	
}

#retorno de valores
# 0: Todos los archivos existen
# 1: Si falta algún archivo (Maestro o Tabla)
function existenMaestrosYTablas {
	todoOk=0
	# chequeo si existe archivo Maestro de Código de País
	if [ ! -f "$MAEDIR/CdP.mae" ]; then
		todoOk=1
		echo " Archivo Maestro de Código de País: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestro CdP.mae ."
	fi

	# chequeo si existe archivo Maestro de Código de Area de Argentina
	if [ ! -f "$MAEDIR/CdA.mae" ]; then
		todoOk=1
		echo " Archivo Maestro de Código de Area de Argentina: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestro CdA.mae ."
	fi

	# chequeo si existe archivo Maestro de Centrales
	if [ ! -f "$MAEDIR/CdC.mae" ]; then
		todoOk=1
		echo " Archivo Maestro de Código de Centrales: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestro CdC.mae ."
	fi

	# chequeo si existe archivo Maestro de Agentes
	if [ ! -f "$MAEDIR/agentes.mae" ]; then
		todoOk=1
		echo " Archivo Maestro de Código de Agentes: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestro agentes.mae ."
	fi

	# chequeo si existe tabla de Tipos de Llamadas
	if [ ! -f "$MAEDIR/tllama.tab" ]; then
		todoOk=1
		echo " Tabla de llamadas: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestr tllama.tab ."
	fi

	# chequeo si existe tabla de Umbrales de Consumo
	if [ ! -f "$MAEDIR/umbral.tab" ]; then
		todoOk=1
		echo " Tabla de Umbrales de Consumo: NO ENCONTRADO"
		bash ./GraLog.sh AFINI EF "No se encontró el archivo maestro ubral.tab ."
	fi

	return $todoOk
}

# recibe como parametro un directorio y lista todos los archivos que se encuentran en él
function listarArchivosDir {
	dir=$1
	if [ -d $dir ]; then
		cd $dir
		for file in *
		do
			if [ -f $file ]; then
				echo "  $file"
			fi
		done
		cd ..
	fi	
}


function verificarPermisos {
	dir=$MAEDIR
	echo "Verificando permisos..."
	sleep 1
	return 0
}

# Mostrar y grabar en el log las variables y contenidos
# si todo salió bien, retorna 0
function mostrarYgrabar {
	echo "Grabando variables y contenidos en log..."
	sleep 1
	echo

	echo "Directorio de Configuración: $CONFDIR"
	sleep 1
	listarArchivosDir $CONFDIR
	bash ./GraLog.sh AFINI I "CONFDIR = $CONFDIR"
	#Grabar en el log
	echo

	echo "Directorio de Ejecutables: $BINDIR"
	sleep 1
	listarArchivosDir $BINDIR
	bash ./GraLog.sh AFINI I "BINDIR = $BINDIR"
	#Grabar en el log
	echo

	echo "Directorio de Maestros y Tablas: $MAEDIR"
	sleep 1
	listarArchivosDir $MAEDIR
	bash ./GraLog.sh AFINI I "MAEDIR = $MAEDIR"
	#Grabar en el log
	echo

	echo "Directorio de recepción de archivos de llamadas: $NOVEDIR"
	sleep 1
	listarArchivosDir $NOVEDIR
	bash ./GraLog.sh AFINI I "NOVEDIR = $NOVEDIR"
	#Grabar en el log
	echo

	echo "Directorio de Archivos de llamadas Aceptadas: $ACEPDIR"
	sleep 1
	listarArchivosDir $ACEPDIR
	bash ./GraLog.sh AFINI I "ACEPDIR = $ACEPDIR"
	#Grabar en el log
	echo

	echo "Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
	sleep 1
	listarArchivosDir $PROCDIR
	bash ./GraLog.sh AFINI I "PROCDIR = $PROCDIR"
	#Grabar en el log
	echo

	echo "Directorio de Archivos de Reportes de llamadas: $REPODIR"
	sleep 1
	listarArchivosDir $REPODIR
	bash ./GraLog.sh AFINI I "REPODIR = $REPODIR"
	#Grabar en el log
	echo
	
	echo "Directorio de Archivos de Log: $LOGDIR"
	sleep 1
	listarArchivosDir $LOGDIR
	bash ./GraLog.sh AFINI I "LOGDIR = $LOGDIR"
	#Grabar en el log
	echo
	
	echo "Directorio de Archivos Rechazados: $RECHDIR"
	sleep 1
	listarArchivosDir $RECHDIR
	bash ./GraLog.sh AFINI I "RECHDIR = $RECHDIR"
	#Grabar en el log
	echo

	echo "Estado del Sistema: INICIALIZADO"
	bash ./GraLog.sh AFINI I "Grabación de variables correctamente."
	#Grabar en el log : OK
	sleep 1

	return 0
}


function arrancarAFREC {
	echo "¿Desea efectuar la activación de AFREC? (s-n):"
	read arrancar
	if [ $arrancar == 's' ]; then
		if [ -z $afrecActivado ]; then
			export afrecActivado=true
			echo "Iniciando AFREC..."
			sleep 1
			echo "AFREC corriendo bajo el no.: <Process Id de AFREC>"
			#TODO llamar a AFREC
			exit
		else
			echo "WARNING: Ya hay un proceso AFREC corriendo."
			bash ./GraLog.sh AFINI W "Ya hay un proceso AFREC corriendo."
			exit
		fi
	else
		if [ $arrancar == 'n' ]; then
			echo "El Usuario no desea arrancar AFREC."
			echo "Si desea arrancar AFREC, en otro momento, ejecute el siguiente comando: <comando_AFREC> "
			exit
		else
			echo "Opción ingresada inválida. Intente nuevamente (s-n)."
			arrancarAFREC
		fi
	fi
}

# PROGRAMA PRINCIPAL DE AFINI
inicializarAmbiente
ret=$? 
# Si el valor de retorno es cero, estado de inicialización: OK
if [ $ret -eq 0 ]; then  
	echo
	instalacionCompleta
	ret=$?
	# Si el valor de retorno es cero, instalación: OK
	if [ $ret -eq 0 ]; then
		echo
		verificarPermisos
		ret=$?
		# Si el valor de retorno es cero, los permisos de los archivos de lectura y ejecución
		# estan seteados correctamente
		if [ $ret -eq 0 ]; then
			echo
			mostrarYgrabar
			ret=$?
			if [ $ret -eq 0 ]; then
				echo
				arrancarAFREC
			fi
		fi
	fi	
fi