#!/bin/bash

# Set Variables
GitUser="Merdan-Kurbanov"
xray_version="1.7.5"

# Ensure the script is run as root
if [ "${EUID}" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

# Basic system update and package installation
apt-get update && apt-get install -y iptables iptables-persistent curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release cron bash-completion ntpdate chrony

# Time synchronization
ntpdate pool.ntp.org
timedatectl set-ntp true
systemctl enable chronyd && systemctl restart chronyd
systemctl enable chrony && systemctl restart chrony

# Set the timezone
timedatectl set-timezone Asia/Kuala_Lumpur

# Create necessary directories
mkdir -p /usr/local/etc/xray /var/log/xray /usr/bin/xray /etc/xray

# Download and install Xray
wget -O xray.zip "https://github.com/XTLS/Xray-core/releases/download/v${xray_version}/xray-linux-64.zip"
unzip xray.zip -d /usr/local/bin/
chmod +x /usr/local/bin/xray
rm xray.zip

# Fetch IP address and domain information
MYIP=$(curl -sS ipv4.icanhazip.com)
emailcf=$(cat /usr/local/etc/xray/email)
domain=$(cat /root/domain)

# Setup ACME for domain verification and certificates
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --server "https://acme.zerossl.com/v2/DV90" --register-account --accountemail "$emailcf"
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d "$domain" --fullchainpath /usr/local/etc/xray/xray.crt --keypath /usr/local/etc/xray/xray.key --ecc

# Generate UUIDs for clients
uuid1=$(uuidgen)
uuid2=$(uuidgen)
uuid3=$(uuidgen)
uuid4=$(uuidgen)
uuid5=$(uuidgen)
uuid6=$(uuidgen)

# Configuration files setup
cat > /usr/local/etc/xray/config.json << END
{
    "log": {
        "access": "/var/log/xray/access.log",
        "error": "/var/log/xray/error.log",
        "loglevel": "info"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "${uuid1}",
                        "flow": "xtls-rprx-direct",
                        "level": 0
                    }
                ],
                "decryption": "none",
                "fallbacks": [
                    {
                        "dest": 80
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "xtls",
                "xtlsSettings": {
                    "alpn": [
                        "http/1.1"
                    ],
                    "certificates": [
                        {
                            "certificateFile": "/usr/local/etc/xray/xray.crt",
                            "keyFile": "/usr/local/etc/xray/xray.key"
                        }
                    ]
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom",
            "settings": {}
        }
    ],
    "routing": {
        "rules": [
            {
                "type": "field",
                "ip": [
                    "0.0.0.0/8",
                    "10.0.0.0/8",
                    "100.64.0.0/10",
                    "169.254.0.0/16",
                    "172.16.0.0/12",
                    "192.0.0.0/24",
                    "192.0.2.0/24",
                    "192.168.0.0/16",
                    "198.18.0.0/15",
                    "198.51.100.0/24",
                    "203.0.113.0/24",
                    "::1/128",
                    "fc00::/7",
                    "fe80::/10"
                ],
                "outboundTag": "blocked"
            }
        ]
    }
}
END

# Setup system service for Xray
cat > /etc/systemd/system/xray.service << END
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /usr/local/etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
END

# Enable and start Xray service
systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service

# Download additional scripts and set permissions
cd /usr/bin
wget -O port-xray "https://raw.githubusercontent.com/Merdan-Kurbanov/ws/main/change-port/port-xray.sh"
wget -O certv2ray "https://raw.githubusercontent.com/Merdan-Kurbanov/ws/main/cert.sh"
wget -O trojaan "https://raw.githubusercontent.com/Merdan-Kurbanov/ws/main/menu/trojaan.sh"
chmod +x port-xray
chmod +x port-trojan
chmod +x certv2ray
chmod +x trojaan
chmod +x xraay

# Clean up and move domain file
cd
rm -f ins-xray.sh
mv /root/domain /usr/local/etc/xray/domain

echo "Xray installation and configuration complete."
