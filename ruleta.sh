#!/bin/bash

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
  echo -e "\n\n${redColour}[!]Saliendo del programa ${endColour}"
  tput cnorm && exit 1
}

trap cntrl_c INT


function HelPanel(){

  echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Forma de uso${endColour} ${purpleColour}$0${endColour}\n"
  echo -e "\t${blueColour}m)${endColour} ${grayColour}Cantidad de dinero con la que jugar${endColour}"
  echo -e "\t${blueColour}t)${endColour} ${grayColour}Técnica de juego que emplear ${endColour}${yellowColour}Martingala${endColour}${grayColour}/${endColour}${yellowColour}ReverseLabouchere${endColour}"
  exit 1
}


function Martingala(){

  money="$1"
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Tu saldo inicial es ${endColour}${yellowColour}$money€${endColour}"
  echo -ne "${yellowColour}[+]${endColour}${grayColour} Cuanto dinero deseas apostar -->${endColour}" && read initial_bet
  echo -ne "${yellowColour}[+]${endColour} ${grayColour}A que deseas apostar (par/impar) -->${endColour}" && read par_impar
#  echo -e "\n ${grayColour}Vamos a apostar${endColour} ${yellowColour}$initial_bet${endColour} ${grayColour}a${endColour} ${yellowColour}$par_impar${endColour}"

  first_bet=$initial_bet
  jugadas_realizadas=0
  jugadas_malas=""
  dinero_maximo=$money


  while true; do
  money=$(($money - $initial_bet))
  echo -e "${yellowColour}[+]${endColour}${grayColour} Apostando${endColour} ${yellowColour}$initial_bet€${endColour} ${grayColour}tu saldo es${endColour} ${yellowColour}$money€${endColour}"
  random_number="$(($RANDOM % 37))"
#    echo -e "${grayColour} ha salido el número${endColour}${blueColour} $random_number${endColour}"
   
   if [ ! "$money" -lt 0 ]; then 
    echo -e "${yellowColour}[+]${endColour}${grayColour} Apostando${endColour} ${yellowColour}$initial_bet€${endColour} ${grayColour}tu saldo es${endColour} ${yellowColour}$money€${endColour}"

      if [ "$par_impar" == "par" ]; then
        if [ "$(($random_number % 2))" -eq 0 ] ; then
          if [ "$random_number" -eq 0 ]; then
#            echo -e "${redColour}[!] Ha salido 0 gana la banca${endColour}"
#            echo -e "${grayColour}tienes${endColour} ${yellowColour}$money€${endColour}\n"
            initial_bet=$(($initial_bet * 2))
            jugadas_malas+="$random_number " #con esto vamos añadiendo a la variable predefinida los valores de las partidas perdidas
           else
#            echo -e "${greenColour}[+] El número que ha salido es par, ¡Has ganado!${endColour}"
            reward=$(($initial_bet * 2))
            money=$(($money + $reward))
#            echo -e "${grayColour}tienes ${yellowColour}$money€${endColour}\n"
            initial_bet=$first_bet
            jugadas_malas=""
           fi
        else
          echo -e "${redColour}[+] El número que ha salido es impar ¡Has Perdido${endColour}"
          echo -e "${grayColour}tienes${endColour} ${yellowColour}$money€${endColour}\n"
          jugadas_malas+="$random_number "
          initial_bet=$(($initial_bet * 2))
        fi
    else
      if [ "$(($random_number % 2))" -eq 1 ] ; then
           echo -e "${greenColour}[+] El número que ha salido es impar, ¡Has ganado!${endColour}"
            reward=$(($initial_bet * 2))
            money=$(($money + $reward))
           echo -e "${grayColour}tienes${endColour} ${yellowColour}$money€${endColour}\n"
            initial_bet=$first_bet
            jugadas_malas=""
        else
         echo -e "${redColour}[+] El número que ha salido es par ¡Has Perdido${endColour}"
         echo -e "${grayColour}tienes${endColour} ${yellowColour}$money€${endColour}\n"
          jugadas_malas+="$random_number "
          initial_bet=$(($initial_bet * 2))
        fi
    fi
  else
    echo -e "\n${redColour} Te has quedado sin dinero${endColour}"
    echo -e "${grayColour}Han habído un total de ${endColour}${purpleColour}$jugadas_realizadas${endColour} ${grayColour}jugadas${endColour}"
    echo -e "${grayColour}La cantidad máxima ganada en el juego ha sido: ${endColour}${yellowColour}$dinero_maximo€${endColour} "
    echo -e "${grayColour}Los números de las partidas malas conscutivas han sido:${endColour}\n${blueColour}[ $jugadas_malas]${endColour}"
    tput cnorm; exit 0
  fi

  let jugadas_realizadas+=1
  if [ "$money" -ge "$dinero_maximo" ]; then
   dinero_maximo=$money
  fi
  done
  
}

function ReverseLabouchere(){

  money="$1"

  echo -e "\n${grayColour}Tu saldo inicial es${endColour} ${yellowColour}$money${endColour}${grayColour}€"
  echo -ne "A que desea apostar (par/impar) -->" && read par_impar 

  declare -a array=(1 2 3 4)
  declare -i longitud=${#array[@]}
  declare -i apuesta=$((${array[0]} + ${array[-1]}))
  declare -a chivato=(${array[@]})
  declare -i dinero_maximo=$money
  jugadas_malas=""
  
 echo -e "${grayColour}se va a proceder a apostar con el patron${endColour} ${purpleColour}[${array[@]}]${endColour} ${grayColour}con${endColour} ${yellowColour}$money€${endColour}:\n"

 while true; do 
  #sleep 3
  tput civis

  if [ ! $longitud -gt 1 ]; then
        array=(${chivato[@]})
        array=(${array[@]})
        #echo -e "${blueColour}SE ESTA EJECUTANDO CHIVATO${endColour}"
  fi
 
  apuesta=$((${array[0]} + ${array[-1]}))
  money=$(($money - $apuesta))

  #echo -e "\n ${array[@]}"
  #echo -e "la longitud de la array es de $longitud"
  

  random_number="$(($RANDOM % 37))"

   if [ ! "$money" -lt 0 ]; then

     #echo -e "\n${grayColour}Tienes${endColour} ${yellowColour}$money€${endColour}${grayColour} y se va a apostar${endColour} ${yellowColour}$apuesta€${endColour}"

    if [ "$par_impar" == "par" ]; then 
      if [ "$(($random_number % 2))" -eq 0 ] ; then
        if [ "$random_number" -eq 0 ]; then
          #echo -e "\nHa salido 0 has perdido"
          unset array[0]
          unset array[-1]
          array=(${array[@]})
          jugadas_malas+="$random_number "
         # apuesta=$((${array[0]} + ${array[-1]}))
         # longitud=${#array[@]}
        else
          #echo -e "\nHa salido par has ganado"
          reward=$(($apuesta * 2))
          let money+=$reward
          array+=($apuesta)
          array=(${array[@]})
          jugadas_malas=""
        #  apuesta=$((${array[0]} + ${array[-1]}))
        #  longitud=${#array[@]}
        fi
      else
          #echo -e "\nHa salido impar has perdido"
          #echo -e "\n ${array[@]}"
          unset array[0]
          unset array[-1]
          array=(${array[@]})
          jugadas_malas+="$random_number "
          #apuesta=$((${array[0]} + ${array[-1]}))
         # longitud=${#array[@]}
      fi
    else
      if [ "$(($random_number % 2))" -eq 1 ] ; then
          #echo -e "\Ha salido impar has ganado"
          reward=$(($apuesta * 2))
          let money+=$reward
          array+=($apuesta)
          array=(${array[@]})
        #  apuesta=$((${array[0]} + ${array[-1]}))
        #  longitud=${#array[@]}
      else
        #echo -e "\nHa salido par has perdido"
        #echo -e "\n ${array[@]}"
        unset array[0]
        unset array[-1]
        array=(${array[@]})
        jugadas_malas+="$random_number "
        #apuesta=$((${array[0]} + ${array[-1]}))
       # longitud=${#array[@]}
      fi
    fi
  else
      echo -e "\n${grayColour}Te has quedado sin dinero, has alcanzado un máximo de${endColour} ${yellowColour}$dinero_maximo€${endColour} ${grayColour}con un total de${endColour} ${blueColour}$jugadas_realizadas${endColour} ${grayColour}jugadas.${endColour}"
      echo -e "${blueColour}[ $jugadas_malas]${endColour}"
tput cnorm; exit 0
  fi

  let jugadas_realizadas+=1
  if [ "$money" -ge "$dinero_maximo" ]; then
   dinero_maximo=$money
  fi
    longitud=${#array[@]}
done

}


while getopts "m:t:h" arg; do
  case $arg in
    m) money=$OPTARG;;  
    t) technique=$OPTARG;;
    h) HelPanel;;
  esac
done

if [ $money ] && [ $technique ]; then
  if [ "$technique" == "Martingala" ]; then
    Martingala $money $technique
  elif [ "$technique" == "ReverseLabouchere" ]; then
    ReverseLabouchere $money $technique
  else
    echo -e "\n${redColour}[!]El metodo de juego seleccionado no existe${endColour}"
    HelPanel
  fi
else
  HelPanel
fi
