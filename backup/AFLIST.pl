#!/usr/bin/perl

use strict;
use warnings;
use Switch;
use Date::Parse;
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

#verifica si no hay otro AFLIST en ejecucion
#TODO

#verifica que la inicializacion de ambiente este realizada
#TODO

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

my $origen = "";
my @oficinas;
my @aniomes;
my $subllamadas = 0;
my @subllamadas;

clear_screen();
print "Bienvenido al generador de informes de llamadas.\n\n";
$origen = definir_origen();
print "Origen".$origen."\n";
@oficinas = definir_oficinas();
@aniomes = definir_aniomes();
@subllamadas = definir_subllamadas_origen();
#realizar_informe();

} #end menu_r

sub definir_origen
{
	my $input = '';

	while ($input ne '0')
	{
		print "\n";
		print "Ingrese sobre que informacion desea generar informes:\n";
		print "1.Sobre los archivos de llamadas sospechosas.\n";
		print "2.Sobre los informes previos.\n";
		print "0.Salir\n";

		print "Ingresar una opcion: ";
		$input = <STDIN>;
		chomp($input);

		switch($input)
		{
			case "1"
			{
				return($ENV{'PROCDIR'});
			}
			case "2"
			{
				return($ENV{'REPODIR'});
			}
			case "0"
			{
				exit;
			}
		}
	}
}

sub definir_oficinas
{	
	my @retval;
	my $input = '';
	print "Ingrese los codigos de oficina que quiere incluir en su reporte.\n";
	print "Si no ingresa ninguna, se incluiran todas.\n";
	print "Para terminar, ingrese 0.\n";
	while ($input ne "0")
	{
		$input = <STDIN>;
		chomp($input);
		push(@retval, $input);
	}
	return @retval;
}

sub definir_aniomes
{
	my @retval;
	my $input = '';
	print "Ingrese los aniomeses que quiere incluir en su reporte.\n";
	print "Si no ingresa ninguno, se incluiran todos.\n";
	print "Para terminar, ingrese 0.\n";
	while ($input ne "0")
	{
		$input = <STDIN>;
		chomp($input);
		push(@retval, $input);
	}
	pop (@retval);
	return @retval;
}

sub definir_subllamadas_origen
{
my @retval;
	my $input = '';
	print "Ingrese los reportes de origen que quiere incluir en su reporte.\n";
	print "Si no ingresa ninguno, se incluiran todos.\n";
	print "Para terminar, ingrese 0.\n";
	while ($input ne "0")
	{
		$input = <STDIN>;
		chomp($input);
		push(@retval, $input);
	}
	return @retval;
}

sub realizar_informe
{
	emitir_informe();
}

sub emitir_informe
{
	if ($file)
	{
		print "Estadisticas del informe\n";
		print "Exportando a archivo...\n";
		my $filename = 'subllamada.' . $file;
		open(my $file_reporte, '>>', $filename) or die "No se pudo generar el archivo: '$filename' $!" ;
		print $file_reporte "una cadena de prueba";
		close $file_reporte;
		$file += 1;
		print "Exportado con exito\n";
	}
	else
	{
		print "Estadisticas y header del informe\n";
		print "File vale: ".$file."\n";
		print "una cadena de prueba\n";
	}
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
	my $input_llam_seg = $_[0];
	my %centrales;
	print "\n";
	print "llamando..f_1_central_cantidad_llam_sosp\n";
	print "Centrales con mayor cantidad de llamadas sospechosas\n";
	if ($_[0] == "1"){
		print "con filtro por cantidad de llamadas\n";
	}
	if ($_[0] == "2"){
		print "con filtro por cantidad de segundos\n";
	}

	# El usuario puede ingresar uno ó  más períodos
	my @input_periodos = &definir_aniomes;
	my @input_periodos_validos;
	foreach (@input_periodos){
		if (&validarFecha($_) > 0){
			push (@input_periodos_validos, $_);
		}
	}
	my @archivos = &getArchivosDir("./proc/");

    foreach (@archivos){
	 	next if ( not &archivoCorrespondeAPeriodoIngresado($_, @input_periodos_validos));
	 	print "procesando...". $_ ."\n";

		open (ENT,"<./proc/".$_) || die "Error: No se pudo abrir ".$_ ."\n";
	    while (my $linea = <ENT>){
			chomp($linea);	
			@reg=split(";",$linea);
			if ($input_llam_seg == "1"){ #filtro por cantidad de llamadas
				$centrales{$reg[0]}+=1; 
			}
			if ($input_llam_seg == "2"){ # filtro por cantidad de segundos
				$centrales{$reg[0]}+=$reg[4];
			}
		}
        close (ENT);
    }#foreach

    my $fecha = &getDate;
    my @rank_centrales = sort { $centrales{$b} <=> $centrales{$a} } keys %centrales;
    my %id_centrales = cargarCodigosDeCentrales;

    # Se graba o se imprime
    if ($file eq 1){
 		open (SAL,">estad_".$fecha.".csv");

 		foreach (@rank_centrales){
 			print SAL $id_centrales{$_}.";".$centrales{$_}."\n";
 		}

 		print "se genero estad_".$fecha.".csv\n";
	    close (SAL);
    }else{
    	foreach (@rank_centrales){
			print $id_centrales{$_}.";".$centrales{$_} ."\n";
 		}
    }
	
}

sub f_2_ofi_cantidad_llam_sosp
{
	my $input_llam_seg = $_[0];
	my %oficinas;
	print "\n";
	print "llamando..f_2_ofi_cantidad_llam_sosp\n";
	print "Oficinas con mayor cantidad de llamadas sospechosas\n";
	if ($_[0] == "1"){
		print "con filtro por cantidad de llamadas\n";
	}
	if ($_[0] == "2"){
		print "con filtro por cantidad de segundos\n";
	}

	# El usuario puede ingresar uno ó  más períodos
	my @input_periodos = &definir_aniomes;
	my @input_periodos_validos;
	foreach (@input_periodos){
		if (&validarFecha($_) > 0){
			push @input_periodos_validos, $_;
		}
	}
	my @archivos = &getArchivosDir("./proc/");

    foreach (@archivos){
	 	next if ( not &archivoCorrespondeAPeriodoIngresado($_, @input_periodos_validos));
	 	print "procesando...". $_ ."\n";
		
		@info_oficina = split("_",$_);
	 	
	 	if ($input_llam_seg == "1"){ #filtro por cantidad de llamadas
			$oficinas{$info_oficina[0]}+=1; 
			next;
		}

		open (ENT,"<./proc/".$_) || die "Error: No se pudo abrir ".$_ ."\n";
	    while (my $linea = <ENT>){
			chomp($linea);	
			@reg=split(";",$linea);
			if ($input_llam_seg == "2"){ # filtro por cantidad de segundos
				$oficinas{$info_oficina[0]}+=$reg[4]; 	
			}
		}
        close (ENT);
    }#foreach

    my $fecha = getDate;
    my @rank_oficinas = sort { $oficinas{$b} <=> $oficinas{$a} } keys %oficinas;
    
    if ($file eq 1){
 		open (SAL,">estad_".$fecha.".csv");

 		foreach (@rank_oficinas){
 			print SAL $_.";".$oficinas{$_}."\n";
 		}

 		print "se genero estad_".$fecha.".csv\n";
	    close (SAL);
    }else{
    	 foreach (@rank_oficinas){
 			print $_.";".$oficinas{$_} ."\n";
 		}
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
	my %age;
	my @reg;
    my $sec;
    my $min;
    my $hora;
    my $dia;
    my $mes;
    my $anio;
	($sec,$min,$hora,$dia,$mes,$anio)=localtime;    
    $anio+=1900;
    $mes++;
	my $fecha = $anio.$mes.$dia."_".$hora.$min.$sec;
    my $input_periodo='';
    my $fecha_ok="N";	
	
	opendir (DIR,"./proc/") || die "Error el directorio no existe\n";
	my @indice = readdir(DIR);
	closedir(DIR);

    while ($input_periodo eq '' && $fecha_ok eq "N")
    {
    print "Ingrese el periodo a filtrar YYYY o YYYYMM: ";
    $input_periodo = <STDIN>;
    chomp($input_periodo);	
	    if ($input_periodo !~ /(\d{4})(\d\d)/  ||  $input_periodo !~ /(\d{4})/) {
	    print "Error al ingresar fecha: [YYYY] o [YYYYMM]\n";    
	    }
	    else { 
		$fecha_ok="S";
	    }
    }        
    
    foreach my $archivos (@indice)
	{
	 next unless ($archivos =~ /$input_periodo\.csv$/);
	 print "procesando...". $archivos ."\n";

		open (ENT,"<./proc/".$archivos) || die "Error: No se pudo abrir ".$archivos ."\n";
	    while (<ENT>)
	    {
		chomp($_);	
		@reg=split(";",$_);
		if ($_[0] == "1"){ #filtro por cantidad de llamadas
			$age{$reg[1]}+=1; 
		}
		if ($_[0] == "2"){ # filtro por cantidad de segundos
			$age{$reg[1]}+=$reg[5]; 	
		}
		}
        close (ENT);
    }#foreach
    
    
	if ( $file eq 1 ) #escribe en archivo?
	{
	open (SAL,">estad_".$fecha.".csv");
    }
	#foreach (keys (%age))
    #	my $linea;
    #   foreach $linea (sort { $age{$a} <=> $age{$b} } keys %age)
    foreach (sort { $age{$a} <=> $age{$b} } keys %age)	
	{
		if ( $file eq 1 )
		{
		print SAL $_.";".$age{$_} ."\n";
		#print SAL  $linea .";" . $age{$linea}."\n";
		} else 
		{
		print $_.";".$age{$_} ."\n";
		}
	};
    
    if ( $file eq 1 )
	{
	    print "se genero estad_".$fecha.".csv\n";
	    close (SAL);
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
####################################################
# campos: (código_país; nombre_país)
sub cargarCodigosDePais(){
	my (%hash_CdP);
	my (@registro);
	open(ENTRADA,"<master/CdP") || die "ERROR: No se encontró archivo maestro CdP.\n";

	while (my $linea = <ENTRADA>){
		chomp($linea);
		@registro = split(";",$linea); 
		$hash_CdP{$registro[0]} = $registro[1];
	}
	close(ENTRADA);
	return %hash_CdP;
}

# campos: (nombre_área; código_área)
sub cargarCodigosDeArea(){
	my (%hash_CdA);
	my (@registro);
	open(ENTRADA,"<master/CdA") || die "ERROR: No se encontró archivo maestro CdA.\n";

	while (my $linea = <ENTRADA>){
		chomp($linea);
		@registro = split(";",$linea); 
		$hash_CdA{$registro[1]} = $registro[0];
	}
	close(ENTRADA);
	return %hash_CdA;
}

# campos: (código_central; descripción)
sub cargarCodigosDeCentrales(){
	my (%hash_CdC);
	my (@registro);
	open(ENTRADA,"<master/CdC") || die "ERROR: No se encontró archivo maestro CdC.\n";

	while (my $linea = <ENTRADA>){
		chomp($linea);
		@registro = split(";",$linea); 
		$hash_CdC{$registro[0]} = $registro[1];
	}
	return %hash_CdC;
}

# campos: (id_agente; nombre_agente; apellido_agente; oficina; email)
sub cargarCodigosDeAgentes(){
	my (%hash_agentes);
	my (@info_agentes);
	open(ENTRADA,"<master/agentes") || die "ERROR: No se encontró archivo maestro agentes.\n";

	while (my $linea = <ENTRADA>){
		chomp($linea);
		@info_agentes = split(";",$linea); 
		$hash_agentes{$info_agentes[0]} = @info_agentes;
	}
	return %hash_agentes;
}

sub getDate(){
	my $sec;
    my $min;
    my $hora;
    my $dia;
    my $mes;
    my $anio;
	($sec,$min,$hora,$dia,$mes,$anio)=localtime;    
    $anio+=1900;
    $mes++;
	my $fecha = $anio.$mes.$dia."_".$hora.$min.$sec;
	return $fecha;
}

sub getArchivosDir(){
	my ($dir) = @_;

	opendir (DIR,"$dir") || die "Error el directorio no existe\n";
	my @files = readdir(DIR);
	closedir(DIR);
	return @files;
}

sub validarFecha(){
	my ($periodo) = @_;
	my ($fecha_ok) = 1;

    if ($periodo !~ /(\d{4})(\d\d)/  ||  $periodo !~ /(\d{4})/) {
	    print "Error al ingresar fecha: $periodo ([YYYY] ó [YYYYMM])\n"; 
	    $fecha_ok = 0;   
    }
    return $fecha_ok;
}

sub archivoCorrespondeAPeriodoIngresado(){
	my ($filename, @periodosIngresados) = @_;
	my $correspondeAPeriodo = 0;
	foreach (@periodosIngresados){
		if ($filename =~ /$_\.csv$/){
			$correspondeAPeriodo = 1;
		} 
	}
	return $correspondeAPeriodo;
}