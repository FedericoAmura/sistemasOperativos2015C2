#!/bin/bash
#
#----------------  AFINSTALL.sh  ----------------
#	
# Script encargado de la instalacion del sistema AFRA-j
# Lista de comandos:
#	*-start:  Inicia la instalacion.
#



#########################  Notas generales  #########################

#Return Values
#0: Todo ok
#1: Paquete ya instalado
#2: Instalacion abortada por el usuario
#3: No hay suficiente espacio en disco para completar la instalacion

############################# sources ###############################

source bin/MoverA.sh
source bin/GraLog.sh


###################### variables de entorno ##########################

# Direcorio donde se va a instalar el sistema AFRA-J
GRUPO="$PWD"
CMD_INSTALL=$1

# Variables por Default

DEFAULT_CONFDIR="$GRUPO/conf" #aca van el log AFINSTAL.lg y el de configuracion AFINSTAL.cnfg
DEFAULT_BINDIR="$GRUPO/bin"
DEFAULT_MAEDIR="$GRUPO/mae"
DEFAULT_NOVEDIR="$GRUPO/novedades"
DEFAULT_ACEPDIR="$GRUPO/aceptadas"
DEFAULT_PROCDIR="$GRUPO/sospechosas"
DEFAULT_REPODIR="$GRUPO/reportes"
DEFAULT_LOGDIR="$GRUPO/log"
DEFAULT_RECHDIR="$GRUPO/rechazadas"


#GRUPO=$(pwd) #Esto estaria hardcodeado, seria la ruta donde esta mi local, asi uso eso directamente, hay que ver como seria en caso de una maquina distinta
#TODO estas variables habria que levantarlas desde el archivo cnfg para ver instalaciones a medias
CONFDIR="$GRUPO/conf" #aca van el log AFINSTAL.lg y el de configuracion AFINSTAL.cnfg
BINDIR="$GRUPO/bin"
MAEDIR="$GRUPO/mae"
NOVEDIR="$GRUPO/novedades"
ACEPDIR="$GRUPO/aceptadas"
PROCDIR="$GRUPO/sospechosas"
REPODIR="$GRUPO/reportes"
LOGDIR="$GRUPO/log"
RECHDIR="$GRUPO/rechazadas"



# Variables para interactuar con el Usuario
#INPUT_USUARIO no se tienen que declarar las variables, directamente se asignan

#Verificamos si perl 5 al menos esta instalado y guardo en una variable si estaba o no (0 si esta, 1 si no segun dpkg)
#TODO en vez de usar el installed tengo que quedarme con la version y verificar que esta sea igual o mayor a 5
PERL_VERSION="$(dpkg --status perl | grep ^Version)"
PERL_INSTALLED=$?
SWITCH_VERSION="$(dpkg --status libswitch-perl | grep ^Version)"
SWITCH_INSTALLED=$?

###############################################################################
#					INICIO FUNCIONES AUX
###############################################################################

# Se encarga de crear el arbol de directorios.
# Existe un arbol de direcorio por defecto, pero el usuario 
# tiene la posibilidad de modificar cada uno.
# 
# $GRUPO/bin
# $GRUPO/mae
# $GRUPO/novedades
# $GRUPO/aceptadas
# $GRUPO/sospechosas
# $GRUPO/reportes
# $GRUPO/log
# $GRUPO/rechazadas
#
function setPath(){

	echo "(logInfo) step 6: Definir el direcorio de los ejecutables"
	echo "Defina el directorio de instalación de los ejecutables ($GRUPO/bin):"
	read BINDIR
	echo "Defina directorio para maestros y tablas ($GRUPO/mae):"
	read MAEDIR
	echo "Defina el Directorio de recepción de archivos de llamadas ($GRUPO/novedades):"
	read NOVEDIR
	echo "Defina el directorio de grabación de los archivos de llamadas aceptadas ($GRUPO/aceptadas):"
	read ACEPDIR
	echo "Defina el directorio de grabación de los registros de llamadas sospechosas ($GRUPO/sospechosas):"
	read PROCDIR
	echo "Defina el directorio de grabación de los reportes ($GRUPO/reportes):"
	read REPODIR
	echo "Defina el directorio para los archivos de log ($GRUPO/log):"
	read LOGDIR
	echo "Defina el directorio de grabación de Archivos rechazados ($GRUPO/rechazadas):"
	read RECHDIR
	echo "Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100):"
	read DATASIZE
	verificarEspacioEnDisco
	echo "Defina el tamaño máximo para cada archivo de log en Kbytes (400):"
	read LOGSIZE
	echo "Defina el nombre para la extensión de los archivos de log (lg):"
	read LOGEXT
}

# Crea las estructuras de directorio requeridas
#
function instalacion(){ 
	echo "Iniciando instalacion..."
	echo -e "\t $CONFDIR"
	echo -e "\t $BINDIR"
	echo -e "\t $MAEDIR"
	echo -e "\t $NOVEDIR"
	echo -e "\t $ACEPDIR"
	echo -e "\t $PROCDIR"
	echo -e "\t $REPODIR"
	echo -e "\t $LOGDIR"
	echo -e "\t $RECHDIR"

	echo "-Creacion de los directorios..."
	# $CONFDIR se crea por defecto al descomprimir el paquete de instalacion.
	# $BINDIR  por el momento dejo que se cree por defecto este direcorio.
	mkdir --parents "$BINDIR" "$MAEDIR" "$NOVEDIR" "$ACEPDIR" "$PROCDIR" "$REPODIR" "$LOGDIR" "$RECHDIR"	
	generateFileConfiguracion
	moverFiles
}

function generateFileConfiguracion(){
	echo "-Guardando configuracion del sistema..."
	echo "GRUPO=$GRUPO=$USER=$(date '+%d/%m/%Y %H:%M:%S')" > $CONFDIR/AFINSTALL.cnfg
	echo "BINDIR=$BINDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "MAEDIR=$MAEDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "NOVEDIR=$NOVEDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "ACEPDIR=$ACEPDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "PROCDIR=$PROCDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "REPODIR=$REPODIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "LOGDIR=$LOGDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "RECHDIR=$RECHDIR=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "DATASIZE=$DATASIZE=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "LOGSIZE=$LOGSIZE=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "LOGEXT=$LOGEXT=$USER=$(date '+%d/%m/%Y %H:%M:%S')" >> $CONFDIR/AFINSTALL.cnfg
	echo "-Configuracion guardada."
}

function moverFiles(){
	echo "-Moviendo archivos..."
	echo "-Archivos todavia no movidos" #TODO eso, lo del comentario, mover todo a donde corresponde
}

function usuarioContinuar(){
	INPUT_USUARIO=$1	
	MSJ_AL_USUARIO=$2
	case $INPUT_USUARIO in
		$(echo $INPUT_USUARIO | grep "^[Nn][Oo]*$") ) # "No" "no" "NO" "nO" "n"  
			echo "Exit "	
			exit 1
		;;
		$(echo $INPUT_USUARIO | grep "^[Ss][Ii]*$") ) # "Si" "si" "sI" "SI" "s"
			echo $MSJ_AL_USUARIO
		;;
 		*)
			echo "Opcion Incorrecta.FIN"
			exit 1
		;;
	esac	
}

# Esta Funcion se encarga de interactuar con el usuario.
# Pide al usuario que ingrese un valor, este no pued ser vacio.
#
function inputBoxString(){

	MSJ_AL_USUARIO=$1
	for i in `seq 1 3`;
    do
        echo $MSJ_AL_USUARIO
        read INPUT_USUARIO
		
		case $INPUT_USUARIO in
		$(echo $INPUT_USUARIO | grep "[a-zA-Z0-9\s]")) #Falta filtrar los \n o cualquier cosa nula.		
			exit
		;;
		$(echo $INPUT_USUARIO | grep "[^a-zA-Z0-9]") ) 
			echo "Valor invalido."
		;;
		esac	
    done  
    VALUE=$INPUT_USUARIO
    
}


###############################################################################
#					FIN FUNCIONES AUX
###############################################################################


###############################################################################
#					INICIO STEPS DE INSATALACION
###############################################################################
# Pasos de instalacion.
# cada step, refleja un paso de instalacion (detallado en el enunciado del tp)


# Detectar si el paquete AFRA-J o algunos de sus componentes ya esta instalado.
#
function detectarInstalacion(){

	#Verifico si el paquete ya esta instalado
	if [ -e "$CONFDIR/AFINSTAL.cnfg" ]
	then
		#echo "Existe una version instalada de AFRA-J."
		verificarInstalacionCompleta		
	fi
	#Chequear que Perl este instalado.
	verificarPerl
}

# verificar si la instalacion esta completa.
# 
function verificarInstalacionCompleta(){

	imprimirConfiguracion
	echo "Desea completar la instalacion? (Si/No)"
	read INPUT_USUARIO	

	if [ "$INPUT_USUARIO" == "n" ]
	then
		#echo "Fin de la instalacion"
		exit 1
	fi
}

#verificar si hay suficiente espacio en disco para las novedades
#
function verificarEspacioEnDisco(){
	ESPACIO_NOVEDIR="$(df -h -k --block-size=MB $NOVEDIR | awk 'NR==2{print$4}' | sed s/MB$//)"
	if [ $ESPACIO_NOVEDIR -lt $DATASIZE ]
	then
		echo "No hay suficiente espacio en disco para poder completar la instalacion con esa configuracion"
		echo "Libere espacio en el disco y vuelva a intentarlo"
		exit 3
	fi
}

# verificar si Perl esta instaldo en el SO.
# 
function verificarPerl(){

	#echo "(logInfo) step 4: Verificando que Perl este instaldo."
	#Hacemos instalar perl si no estaba
	if [ $PERL_INSTALLED != 0 -o $SWITCH_INSTALLED != 0 ]
	then
		echo "El programa necesita de Perl y sus librerias para poder generar reportes, se va a proceder a instalarlo. Por favor ingrese la contrasena cuando se le solicite"
		echo "De no instalarlo no podra generar los reportes. Sin embargo, puede instalarlo por su cuenta cuando desee mas tarde."
		sudo apt-get --force-yes --yes install perl
		sudo apt-get --force-yes --yes install libswitch-perl
	fi
}

# Aceptacion de terminos y condiciones. 
#
function terminosYCondiciones(){
	echo "***************************************************************"
	echo "*"
	echo "*			Proceso de Instalacion \"AFRA-J\" 		 "
	echo "*"
	echo "* 	Tema: J Copyright Grupo 3 - Segundo Cuatrimestre 2015 "
	echo "*"
	echo "***************************************************************"

	echo -e "A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones del
	\"ACUERDO DE LICENCIA DE SOFTWARE\" incluido en este paquete.\n"
}

# Mostrar los valores de los parametros configurados y preguntar para continuar o voler atrás. 
#
function imprimirConfiguracion(){
	#echo "(logInfo) step 18: Parametros configurados."

	echo "Detalles de instalacion:"
	echo -e "\t Directorio de Ejecutables: $BINDIR"
	echo -e "\t Directorio de Maestros y Tablas: $MAEDIR"
	echo -e "\t Directorio de recepcion de archivos de llamadas: $NOVEDIR"	
	echo -e "\t Espacio minimo libre para aribos: $DATASIZE mb" 
	echo -e "\t Directorio de Archivos de llamadas Aceptadas: $ACEPDIR"
	echo -e "\t Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
	echo -e "\t Directorio de Archivos de Reportes de llamadas: $REPODIR"
	echo -e "\t Directorio de Archivos de Log: $LOGDIR"	
	echo -e "\t Extensión para los archivos de log: $LOGEXT"
	echo -e "\t Tamaño máximo para los archivos de log: $LOGSIZE kb"	
	echo -e "\t Direcorio de Archivos Rechazados: $RECHDIR"
	echo -e "\t Estado de la instalacion: $LISTA"

}

###############################################################################
#					FIN STEPS DE INSTALACION
###############################################################################

#Inicio de la instalacion.
if [ "$CMD_INSTALL" == "-start" ]
then	
	# Confirmo si el paquete ya esta instalado.
	detectarInstalacion
	
	# Aceptar terminos y condiciones.
	terminosYCondiciones

	# Interaccion con el usuario.	
	echo "Acepta? Si - No (Si/No)"	
	read INPUT_USUARIO
	
	# Validar Si el usuario desea continuar. 
	usuarioContinuar $INPUT_USUARIO "Siguiente..."

	# Definir el arbol de directorios
	setPath

	# Mostrar como quedo configurada la instalacion.
	imprimirConfiguracion

	# Interaccion con el usuario.	
	echo "Desea continuar con la instalación? (Si-No)"
	read INPUT_USUARIO		
	
	# Validar Si el Usuario desea continuar
	usuarioContinuar $INPUT_USUARIO "Siguiente..."
	
	#Confirmar inicio de instalacion
	echo "Iniciando Instalacion. Esta Ud. seguro? (Si-No)"
	read INPUT_USUARIO 

	# Validar Si el Usuario desea continuar
	usuarioContinuar $INPUT_USUARIO "Iniciando instalacion del sistema AFRA-J"
	
	# Instalacion
	instalacion 
	
	exit 1
else
	echo "Ingrese el parametro \"-start\" para inicializar la instalacion"
fi






