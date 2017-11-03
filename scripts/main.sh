#!/bin/bash

installer_script="sudo bash ./openvpn-install.sh"

filesBefore=() 
filesAfter=()
filesNew=()


storeExistingFilesBefore() {
	i=0
	for f in *.ovpn
	do
		if [ "$f" = "*.ovpn" ]
		then
			break
		fi
		filesBefore[ $i ]=$f
		(( i++ ))
	done
}
storeExistingFilesAfter() {
	i=0
	for f in *.ovpn
	do
		if [ "$f" = "*.ovpn" ]
		then
			break
		fi
		filesAfter[ $i ]=$f
		(( i++ ))
	done
}

storeNewFiles() {
	for i in "${filesAfter[@]}"; do
		skip=
	    	for j in "${filesBefore[@]}"; do
         		[[ $i == $j ]] && { skip=1; break; }
     		done
     		[[ -n $skip ]] || filesNew+=("$i")
	done
}
# echo storeExistingFilesBefore
storeExistingFilesBefore
# echo ${filesBefore[*]}

$installer_script

# echo storeExistingFilesAfter
storeExistingFilesAfter
# echo ${filesAfter[*]}


# echo storeNewFiles
storeNewFiles
# echo ${filesNew[*]}

for j in "${filesNew[@]}"; do
    echo $j >> toBeDownloaded.txt
done

