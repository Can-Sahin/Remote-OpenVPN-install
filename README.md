# Remote-OpenVPN-install
Automated OpenVPN installer for **non-Linux users** or **strangers to command-line-interface**.
It runs the necessary commands such as `ssh and scp` to run the [OpenVPN-install] script on a remote machine and downloads the new client files.


# Usage
Download the repository (autovpn.sh and scripts folder)
Put your SSH Key(keypair obtained from remote machine providers) in the same directory with autovpn.sh file
Run the autovpn script with IPADRESS, PRIVATE_KEY, REMOTE_MACHINE_USER_NAME
```shell
bash autovpn -r 'YOUR_IP_ADRESS' -k 'YOUR_PEM_FILE.pem' -u 'ubuntu'"
```
Follow the [OpenVPN-install] commands to complete the installation


[OpenVPN-install]: <https://github.com/Angristan/OpenVPN-install>

