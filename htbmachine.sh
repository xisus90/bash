#!/bin/bash
#
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

function cntrl_c(){
  echo -e "\n\n${RedColour}[!]Saliendo del programa ${endColour}"
  tput cnorm && exit 1
}

#cntrl_c
trap cntrl_c INT

#variables globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n${yellowColour}[+]ayuda${endColour}"
  echo -e "\t${purpleColour}u)${endColour} ${grayColour}Actualizar listado máquinas${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Buscar por nombre de máquina${endColour}"
  echo -e "\t${purpleColour}i)${endColour} ${grayColour}Buscar por IP de máquina${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Buscar por dificultad de una máquina ${endColour}"
  echo -e "\t${purpleColour}o)${endColour} ${grayColour}Buscar por el sistema operativo de la máquina ${endColour}"
  echo -e "\t${purpleColour}y)${endColour} ${grayColour}Buscar por URL de la resolución de la máquina en Youtube ${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Buscar por la máquina por skills empleadas ${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda\n${endColour}"
  
}

function updateFiles(){
   
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\n${purpleColour}[!]${endColour} ${grayColour}Descargando archivos necesarios...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Todos los archivos han sido descargados${endColour}"
    tput cnorm
  else 
    tput civis
    echo -e "\n${yellowColour}[+]${endColour}${grayColour}Comprobando si hay actualizaciones pendientes${endColour}"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{prit $1}')
    md5_value=$(md5sum bundle.js | awk '{prit $1}')
    
    tput cnorm
      if [ "$md5_temp_value" == "$md5_value" ]; then
        echo -e "${yellowColour}[+]${endColour}${grayColour}No hay actualizaciones${endColour}"
        rm bundle_temp.js
      else
        echo -e "${yellowColour}[+]${endColour}${grayColour}El archivo ha sido actualizado${endColour}"
        rm bundle.js && mv bundle_temp.js bundle.js
      fi
  fi
}


function searchmachine(){
  machinename=$1
  echo -e "${yellowColour}[+]${endColour}${grayColour}Listando maquina y sus propiedades ${endColour}${blueColour}$machinename${endColour}${grayColour}:${endColour}\n"
# con tr quitamos -VE quitamos los valores que no queremos y con sed y la sintaxsis que tiene eliminamos los espacios hasta el primer caracter
findmachine="$(cat bundle.js | awk "/name: \"$machinename\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" |tr -d '"' | tr -d ',' | sed 's/^ *//')"
if [[ -z "$findmachine" ]]; then
  echo -e "${redColour}[!]${endColour}${grayColour}la maquina${endColour}${redColour} $machinename ${endColour}${grayColour}no existe${endColour}${redColour}[!]${endColour}"
else
  echo "$findmachine"
fi
}

function searchIp(){
  IpAdress="$1"
  
  machinename="$(cat bundle.js | grep "ip: \"$IpAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  if [[ -z $machinename ]]; then
    echo -e "\n${redColour}[!]${endColour} No existe maquina con la Ip $IpAdress"
    tput cnorm
  else  
    echo -e "${grayColour}La máquina corresponediente para la Ip${endColour}${blueColour} $IpAdress${endColour} ${grayColour}es${endColour}${purpleColour} $machinename${endColour}\n"
    tput cnorm
  fi
}

function getYoutubeLink(){

  nanemachine="$1"
  ylink="$(cat bundle.js | awk "/name: \"$machinename\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" |tr -d '"' | tr -d ',' | sed 's/^ *//'| grep youtube)"

  if [ "$ylink" ]; then
    echo -e "\n${grayColour}el enlace de youtube para la maquina${endColour}${purpleColour} $machinename${endColour}${grayColour} es${endColour} ${yellowColour}$ylink${endColour}\n"
  else
    echo -e "\n${redColour}[!]$ La máquina proporcionada no existe [!]${endColour}"
  fi
    
}

function getdifficult(){

  difficulty="$1"
  machinename="$(cat bundle.js | grep "$difficulty" -B 5 |tr -d '"' | tr -d ',' | sed 's/^ *//' | grep "name: " | awk NF'{print $NF}' | column)"
  
  if [ "$machinename" ]; then
    echo -e "\n${grayColour}Las maquinas con la dificultad ${blueColour}$difficulty${endColour} son:${endColour}\n${yellowColour}$machinename${endColour}"
  else
    echo -e "${redColour}[!]No existe ninguna máquina con esa dificultad[!]\n ${endColour}"
  fi
      
}

function getosmachine(){

  os="$1"
  machinename="$(cat bundle.js | grep "$os" -B4 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$machinename" ]; then
       echo -e "\n${grayColour}la maquina a la que pertenece el sistema operativo${endColour}${purpleColour} $os${endColour}${grayColour} es:${endColour}\n"
       if [ "$os" == "Linux" ]; then
        echo -e "${blueColour}$machinename${endColour}"
       elif [ "$os" == "Windows" ]; then
        echo -e "${RedColour} $machinename${endColour}" 
       fi
  else
        echo -e "\n[!] No existe ninguna máquina con ese sistema operativo"
  fi
  
}

function getOsDifficult(){

  os="$1"
  difficulty="$2"
  checkresult="$(cat bundle.js | grep "$os" -C4 | grep "$difficulty" -B5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$checkresult" ]; then
    echo -e "\n${grayColour}Listando las máquinas de dificultad ${endColour}${blueColour}$difficulty${endColour}${grayColour} que tengan el sistema operativo${endColour} ${purpleColour}$os${endColour}${grayColour}:${endColour}\n$checkresult "
  else
    echo -e "\n${redColour}[!] Se ha indicado una dificultad o sistema operativo incorrecto [!]${endColour}"
  fi
}

function getskills(){

  skill="$1"
  get_skills="$(cat bundle.js | grep "$skill" -B 6 -i | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
  
  if [ "$get_skills" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Se van a mostar las maquinas cuya skill es${endColour} ${blueColour}$skill${endColour}${grayColour}:${endColour}\n$get_skills"
  else
    echo -e "\n${redColour}[!] No se ha encontrado ninguna maquina con dicha skill [!]${endColour}"
  fi


}

#indicaciones1:
declare -i parameter_counter=0

#chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0


while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m)  machinename=$OPTARG; let parameter_counter+=1;;
    u)  let parameter_counter+=2;; 
    i)  ipname=$OPTARG; let parameter_counter+=3;;
    y)  machinename=$OPTARG; let parameter_counter+=4;;
    d)  difficulty=$OPTARG; chivato_difficulty=1; parameter_counter+=5;;
    o)  os=$OPTARG; chivato_os=1; parameter_counter+=6;;
    s)  skill=$OPTARG; parameter_counter+=7;;
    h);;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchmachine $machinename
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIp $ipname
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machinename
elif [ $parameter_counter -eq 5 ]; then
  getdifficult $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getosmachine $os
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOsDifficult $os $difficulty
elif [ $parameter_counter -eq 7 ]; then
  getskills "$skill"
else 
  helpPanel  
fi
