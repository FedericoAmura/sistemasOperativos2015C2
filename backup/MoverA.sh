#!/bin/bash
#Notas generales
#Para obtener las funciones en el ambiente "source MoverA.sh" y despues para usar la funcion "MoverA origen destino [comandollamador]"
#con "echo $?" veo el return value de la ultima llamada, util para testing
#si hay que distinguir los pipes y cosas asi que no son files realmente, cambiar los -e por -f

#Return values
#1: funcion mal llamada
#2: origen = destino
#3: origen no existe
#4: destino no existe

contador=0

function MoverA {
	origen=$1
	destino=$2
	dir_destino=${destino%/*}
	filename_destino=${destino##*/}
	llamador=$3
	#limpio e imprimo variables, mas amigable
	#clear
	#echo
	#echo "--------------------------------"
	#echo "Parametros"
	#echo "Origen: " $1
	#echo "Destino: " $2
	#echo "El directorio destino seria: " $dir_destino
	#echo "El filename destino seria: " $filename_destino
	#echo "Llamado por: " $3
	#echo

	#chequeo que hayan llamado bien a la funcion
	if [[ "$origen" == "" ]] || [[ "$destino" == "" ]]
	then
		#echo "Origen o destino sin especificar, aborto devolviendo 1"
		return 1
	fi

	#chequeo si el origen y el destino son iguales
	if [[ "$origen" == "$destino" ]]
	then
		#echo "Origen y destino son iguales, aborto devolviendo 2"
		return 2
	fi

	#chequeo si el file origen existe
	if [ ! -e "$origen" ]
	then
		#echo "No existe el origen, aborto con 3"
		return 3
	fi

	#chequeo que exista el directorio destino
	if [ ! -e "$dir_destino" ]
	then
		#echo "No existe el directorio destino, aborto con 4"
		return 4
	fi

	#chequeo si el file destino ya existe
	if [ ! -e "$destino" ]
	then
		#echo "No existe el file destino, se mueve ok"
		mv "$origen" "$destino"
	else
		#echo "Ya existe el file destino, moviendo a duplicados"
		mkdir -p "${dir_destino}/duplicados"
		if [ ! -e "${dir_destino}/duplicados/${filename_destino}" ]
		then
			mv "$origen" "${dir_destino}/duplicados/${filename_destino}"
		else
			contador=`expr $contador + 1`
			mv "$origen" "${dir_destino}/duplicados/${filename_destino}.${contador}"
		fi
	fi
}  
