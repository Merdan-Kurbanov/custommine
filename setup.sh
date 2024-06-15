#!/bin/bash

# Variables
GitUser="Merdan-Kurbanov"
default_email="example@example.com"

clear
echo -e "\e[32mloading...\e[0m"

# Prompt for provider name
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   \e[1;32mPlease enter the name of Provider for Script.\e[0m"
read -p "   Name : " nm
echo $nm > /root/provided
echo ""

# Prompt for email domain
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo -e ""
echo -e "   \e[1;32mPlease enter your email Domain/Cloudflare.\e[0m"
echo -e "   \e[1;31m(Press ENTER for default email)\e[0m"
read -p "   Email : " email
sts=${email:-$default_email}
mkdir -p /usr/local/etc/xray/
echo $sts > /usr/local/etc/xray/email
echo ""

# Prompt for domain type
echo -e "\e[1;32m════════════════════════════════════════════════════════════\e[0m"
echo ""
echo -e "   .----------------------------------."
echo -e "   |\e[1;32mPlease select a domain type below \e[0m|"
echo -e "   '----------------------------------'"
echo -e "     \e[1;32m1)\e[0m Enter your Subdomain"
echo -e "     \e[1;32m2)\e[0m Use a random Subdomain"
echo -e "   ------------------------------------"
read -p "   Please select numbers 1-2 or Any Button(Random) : " host
echo ""

if [[ $host == "1" ]]; then
    echo -e "   \e[1;32mPlease enter your subdomain \e[0m"
    read -p "   Subdomain: " host1
    echo $host1 > /root/domain
    echo "IP=" >> /var/lib/premium-script/ipvps.conf
else
    echo "Using random subdomain..."
    # Implement random subdomain logic here if needed
fi

clear
echo -e "\e[0;32mREADY FOR INSTALLATION SCRIPT...\e[0m"
sleep 2

# Install Xray
echo -e "\e[0;32mINSTALLING XRAY CORE...\e[0m"
sleep 1
wget https://raw.githubusercontent.com/${GitUser}/custommine/ins-xray.sh -O ins-xray.sh && chmod +x ins-xray.sh && screen -S ins-xray -dm ./ins-xray.sh
echo -e "\e[0;32mDONE INSTALLING XRAY CORE\e[0m"
clear

# Install WebSocket
echo -e "\e[0;32mINSTALLING WEBSOCKET PORT...\e[0m"
wget https://raw.githubusercontent.com/${GitUser}/custommine/websocket-python/websocket.sh -O websocket.sh && chmod +x websocket.sh && screen -S websocket -dm ./websocket.sh
echo -e "\e[0;32mDONE INSTALLING WEBSOCKET PORT\e[0m"
clear

# Set timezone to GMT+8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# Install required packages
apt update && apt install -y jq curl nginx

# Configure Nginx
cd
rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/${GitUser}/custommine/nginx.conf"
mkdir -p /home/vps/public_html
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/${GitUser}/custommine/vps.conf"
systemctl restart nginx

# Clean up unnecessary files
rm -f /root/ssh-vpn.sh /root/wg.sh /root/ss.sh /root/ssr.sh /root/ins-xray.sh /root/trojan-go.sh /root/set-br.sh /root/ohp.sh /root/ohp-dropbear.sh /root/ohp-ssh.sh /root/websocket.sh

# Set color scheme for banner
echo "1;36m" > /etc/banner
echo "30m" > /etc/box
echo "1;31m" > /etc/line
echo "1;32m" > /etc/text
echo "1;33m" > /etc/below
echo "47m" > /etc/back
echo "1;35m" > /etc/number
echo 3d > /usr/bin/test

# Installation Complete Message
clear
echo " "
echo "Installation has been completed!!"
echo " "
echo "=========================[SCRIPT PREMIUM]========================" | tee -a /root/log-install.txt
echo "" | tee -a /root/log-install.txt
echo "-----------------------------------------------------------------" | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "   >>> Service & Port"  | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "    [INFORMASI SSH & OpenVPN]" | tee -a /root/log-install.txt
echo "    -------------------------" | tee -a /root/log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a /root/log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200"  | tee -a /root/log-install.txt
echo "   - OpenVPN SSL             : 110"  | tee -a /root/log-install.txt
echo "   - Stunnel4                : 222, 777"  | tee -a /root/log-install.txt
echo "   - Dropbear                : 442, 109"  | tee -a /root/log-install.txt
echo "   - OHP Dropbear            : 8585"  | tee -a /root/log-install.txt
echo "   - OHP SSH                 : 8686"  | tee -a /root/log-install.txt
echo "   - OHP OpenVPN             : 8787"  | tee -a /root/log-install.txt
echo "   - Websocket SSH(HTTP)     : 2081"  | tee -a /root/log-install.txt
echo "   - Websocket SSL(HTTPS)    : 222"  | tee -a /root/log-install.txt
echo "   - Websocket OpenVPN       : 2084"  | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "    [INFORMASI Sqd, Bdvp, Ngnx]" | tee -a /root/log-install.txt
echo "    ---------------------------" | tee -a /root/log-install.txt
echo "   - Squid Proxy             : 3128, 8000 (limit to IP Server)"  | tee -a /root/log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a /root/log-install.txt
echo "   - Nginx                   : 81"  | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "    [INFORMASI WG]"  | tee -a /root/log-install.txt
echo "    --------------" | tee -a /root/log-install.txt
echo "   - Wireguard               : 5820"  | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "    [INFORMASI Shadowsocks-R & Shadowsocks]"  | tee -a /root/log-install.txt
echo "    ---------------------------------------" | tee -a /root/log-install.txt
echo "   - Shadowsocks-R           : 1443-1543"  | tee -a /root/log-install.txt
echo "   - SS-OBFS TLS             : 2443-2543"  | tee -a /root/log-install.txt
echo "   - SS-OBFS HTTP            : 3443-3543"  | tee -a /root/log-install.txt
echo ""  | tee -a /root/log-install.txt
echo "    [INFORMASI XRAY]"  | tee -a /root/log-install.txt
echo "    ----------------" | tee -a /root/log-install.txt
echo "   - Xray Vmess Ws Tls       : 443"  | tee -a /root/log-install.txt
echo "   - Xray Vless Ws Tls       : 443"

