#!/bin/bash


installerScriptURL="https://raw.githubusercontent.com/Angristan/OpenVPN-install/master/openvpn-install.sh"
installerScriptFileName="openvpn-install.sh"

scp_options=(-o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=30 -o "UserKnownHostsFile /dev/null")
local_installer_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/scripts/openvpn-install.sh"
local_main_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/scripts/main.sh"
remote_main_script="\$HOME/main.sh"

remote_directory="\$HOME"
run_main_script="./main.sh"

remote_download_file_path="\$HOME/toBeDownloaded.txt" 
local_download_file_path="$(pwd)/toBeDownloaded.txt"

FILE="toBeDownloaded.txt"

red=`tput setaf 1`
green=`tput setaf 2`
magenta=`tput setaf 5`

resetColor(){
  tput sgr0
}

printErr ()
{
	echo "${red}Error Occured: $1"
  resetColor
	exit 
}
printInfo ()
{
  echo "Warning: $1"
  exit 
}
printSuccess ()
{
  echo "${green}$1"
  resetColor
}

function usage {
  echo "${magenta}"
  echo "*Description*"
  echo ""
  echo "Specify IP , KEYPAIR and REMOTE_MACHINE_USER_NAME to run"
  echo ""
  echo "Example -> ./autovpn -r 'YOUR_IP_ADRESS' -k 'YOUR_PEM_FILE.pem' -u 'ubuntu'"
  echo ""
  resetColor
}


if ( ! getopts "r:k:u:" opt); then
  printErr "Argument Parse Error"
	usage;
	exit 1;
fi

user='ubuntu'

while getopts ":r:k:u:" opt; do
  case $opt in
    r) rflag="defined"; instance_ip="$OPTARG" ;;
    k) kflag="defined"; pem_file="$OPTARG" ;;
    u) uflag="defined"; user="$OPTARG" ;;
    :) echo "Option -$OPTARG requires an argument." >&2 ; usage && exit 0 ;;    
  esac
done


sshcmd() {
  ssh -i $pem_file "${scp_options[@]}" -t -t $@
}

scpcmd() {
  scp -i $pem_file "${scp_options[@]}" $@
}

downloadInstallerScript() {
  curl "$installerScriptURL" -o "scripts/"$installerScriptFileName
  chmod +x "scripts/"$installerScriptFileName
}

# $ bash autovpn.sh -r "{_._._._}" -k "{vpnkeypair.pem}"
if [ -n "$rflag" ] && [ -n "$kflag" ]
then
  chmod 400 $pem_file

  downloadInstallerScript

  scpcmd "$local_installer_script" $user@$instance_ip:"$remote_directory" || printErr SCP_ERROR
  scpcmd "$local_main_script" $user@$instance_ip:"$remote_directory" || printErr SCP_ERROR
  sshcmd $user@$instance_ip "chmod +x $remote_main_script && $run_main_script" || printErr SSH_ERROR
  scpcmd $user@$instance_ip:"$remote_download_file_path" "$local_download_file_path" || printInfo "There is no download file found"
  sshcmd $user@$instance_ip "rm $FILE"

  if [ -f "$FILE" ]
  then
    while IFS='' read -r line || [[ -n "$line" ]]; do
      scpcmd $user@$instance_ip:$remote_directory"/$line" "$(pwd)/$line" || printErr "Cannot retrieve $line" 
      echo ""
      printSuccess "Downloaded the file : $line"
    done < $FILE
    rm $FILE
  else
    echo "No file needs to be downloaded"
  fi
else
  usage
  exit 0
fi 

