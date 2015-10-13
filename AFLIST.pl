#!/usr/bin/perl

use strict;
use warnings;
use Switch;
my $key = '';
my $file = 0;

#ARCHIVO=AFLIST.pl 
#USO: AFLIST.pl ARGUMENTO_1 [ARGUMENTO_2]"
#OBJETIVO=Visualizacion de informes y estadisticas para 
#         llamadas sospechosas.
#ARGUMENTO 1= -r /Consultas de llamadas sospechosas
#             -s /Ranking de llamadas sospechosas
#             -h /Muestra la ayuda por pantalla
#ARGUMENTO 2= -w /OPCIONAL. Si existe, escribe en un archivo el resultado
#USO: AFLIST.pl -r/s/h [-w]"

# obtiene los comandos desde los argumentos
my $arg_0=$ARGV[0];
my $arg_1=$ARGV[1];
my $uso_prog="USO: $0 -r|s|h [-w]";
# valida la cantidad de argumentos recibidos por linea de comando
my $num_args = $#ARGV + 1;

#valida que haya al menos un argumento
if ($num_args == 0) 
{
    print "\nDebe pasar al menos un argumento. ".$uso_prog."\n";
    exit;
}
#valida que la cantidad de argumentos no sea mayor a 2
if ($num_args > 2) 
{
    print "\nMas argumentos [$num_args] de los permitidos. ".$uso_prog."\n";
    exit;
}

#valida que el 2do argumento sea -w
if ($num_args == 2) 
{
	if ($arg_1 ne "-w")
	{
	   print "\nArgumento invalido [$arg_1]. ".$uso_prog."\n";
	   exit;	
	}
	else
	{
	   $file = 1;
	}
}

# muestra el menu
    switch ($arg_0)
    {
        case "-r" 
        {
			print "ejecutando opcion -r...\n";
			#valida que el segundo argumento no sea distinto a -w
			menu_r();
	}
	case "-s"
	{
			print "ejecutando opcion -s...\n";	
			menu_s();
	}
	case "-h"
	{
			print 
			       "#AYUDA $0 \n".
			       "#OBJETIVO=Visualizacion de informes y estadisticas para llamadas sospechosas.\n".	      		
			       "#USO: $0 ARGUMENTO_1 [ARGUMENTO_2]\n".
			       "#ARGUMENTO 1= -r /Consultas de llamadas sospechosas\n".
			       "#             -s /Ranking de llamadas sospechosas\n".
			       "#             -h /Muestra ayuda por pantalla\n".
			       "#ARGUMENTO 2= -w /OPCIONAL. Si existe, escribe en un archivo el resultado\n".
			       "#".$uso_prog."\n"
			       
			       ;			
	}
	else{
			print "\nArgumento invalido. ".$uso_prog."\n";
			exit;
	}		
   }

exit(0);

#MENU PRINCIPAL opcion -r [consultas]
sub menu_r
{
my $input = '';
my $input_opt = '';
my $filename;
my $file_reporte;
my $informe;
clear_screen();
print "Bienvenido al generador de informes de llamadas.\n\n";
while ($input ne 0)
{
	$informe = "Prueba\n";
	print "\n";
	print "Ingrese sobre que informacion desea generar informes:\n";
	print "1.Sobre los archivos de llamadas sospechosas.\n";
	print "2.Sobre los informes previos.\n";
	print "0.Salir\n";

	print "Ingresar una opcion: ";
	$input = <STDIN>;
	chomp($input);
	
	if (($input < 0) || ($input > 2))
	{
		next;
	}

	if ($input == 1)
	{
		realizar_informe_sobre_llamadas();
	}
	if ($input == 2)
	{
		realizar_informe_sobre_subllamadas();
	}

	if ($input != 0)
	{
		if ($file)
		{
			print "Estadisticas del informe\n";
			print "Exportando a archivo...\n";
			$filename = 'subllamada.' . $file;
			open($file_reporte, '>>', $filename) or die "No se pudo generar el archivo: '$filename' $!" ;
			print $file_reporte $informe;
			close $file_reporte;
			$file += 1;
			print "Exportado con exito\n";
		}
		else
		{
			print "Estadisticas y header del informe\n";
			print $informe;
		}
	}
}
} #end menu_r

sub realizar_informe_sobre_llamadas
{
}

sub realizar_informe_sobre_subllamadas
{
}


#MENU PRINCIPAL opcion -s [estadisticas]
sub menu_s
{
my $input = '';
my $input_opt = '';

while ($input ne '0')
{
    clear_screen();

    print  "Ingrese la opcion que desea conocer:\n". 
	   "1.Cuál es la central con mayor cantidad de llamadas sospechosas?\n".
           "2.Cuál es la oficina con mayor cantidad de llamadas sospechosas?\n". 
           "3.Cuál es el agente con mayor cantidad de llamadas sospechosas?\n". 
           "4.Cuál es el destino con mayor cantidad de llamadas sospechosas?\n". 
           "5.Cuál es el ranking de umbrales?\n".
           "0.Salir\n";

    print "Ingresar una opcion: ";
    $input = <STDIN>;
    chomp($input);

    switch ($input)
    {
		#opciones 1,2,3 filtro por llamadas o por segundos
        case ["1","2","3"] 
        {
            $input_opt = '';

            while ($input_opt ne "3")
            {
                clear_screen();

                print "Seleccione un filtro\n".
                      "1.Por cantidad de llamadas\n".
                      "2.Por cantidad de segundos\n".
                      "3.Volver al menu principal\n";

                print "Seleccionar filtro: ";
                $input_opt = <STDIN>;
                chomp($input_opt);   
            
                if ($input_opt ne "3") {
	                if ($input=="1") {
						f_1_central_cantidad_llam_sosp($input_opt);
	                    print "Presione una tecla para continuar...\n";
	                    $input_opt = <STDIN>;  
	                    chomp($input_opt);					
					}elsif ($input=="2") {
						f_2_ofi_cantidad_llam_sosp($input_opt);
						print "Presione una tecla para continuar...\n";
	                    $input_opt = <STDIN>;  
	                    chomp($input_opt);
					}elsif ($input=="3") {
						f_3_agente_cantidad_llam_sosp($input_opt);
					    print "Presione una tecla para continuar...\n";
	                    $input_opt = <STDIN>;  
	                    chomp($input_opt);				   				     
					} 
				}
						
            print "valor input $input input_opt $input_opt\n";
            #presione_tecla_para_continuar();
                       
            }
            $input = '';  
            $input_opt = '';
        }
        case "4"
        {
		f_4_destino_llam_sospechosa();
		
		$input = '';
		}
        case "5"
        {
		f_5_ranking_umbrales();		
		
		$input = '';
		}
    }
}

}#end menu_s



#subrutinas opcion -s [estadisticas]
sub f_1_central_cantidad_llam_sosp
{
	print "llamando..f_1_central_cantidad_llam_sosp\n";
	if ($_[0] == "1"){
	print "con filtro por cantidad de llamadas\n";	
	}
	if ($_[0] == "2"){
	print "con filtro por cantidad de segundos\n";	
	}
	
}

sub f_2_ofi_cantidad_llam_sosp
{
	print "llamando..f_2_ofi_cantidad_llam_sosp\n";
	if ($_[0] == "1"){
	print "con filtro por cantidad de llamadas\n";	
	}
	if ($_[0] == "2"){
	print "con filtro por cantidad de segundos\n";	
	}
}

sub f_3_agente_cantidad_llam_sosp
{
	print "llamando..f_3_agente_cantidad_llam_sosp\n";
	if ($_[0] == "1"){
	print "con filtro por cantidad de llamadas\n";	
	}
	if ($_[0] == "2"){
	print "con filtro por cantidad de segundos\n";	
	}
}


sub f_4_destino_llam_sospechosa
{
	print "llamando..f_4_destino_llam_sospechosa\n";
}

sub f_5_ranking_umbrales
{
	print "llamando..f_5_ranking_umbrales\n";
}

#subrutinas generales
sub clear_screen
{
    system("clear");
}

sub presione_tecla_para_continuar {
    print "Presione una tecla para continuar...\n";
    $key = <STDIN>;
    chomp($key);
}