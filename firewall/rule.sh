# Nous nous sommes inspirés de ce tutoriel : https://openclassrooms.com/fr/courses/1197906-securiser-son-serveur-linux

# Effacer les régles précédentes
iptables -F
iptables -X

# Bloque tout
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Permet le forward vers WAN
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

######### PING #########

# DMZ -> LAN
iptables -A FORWARD -p icmp --icmp-type 8 -i eth2 -o eth1 -s 192.168.200.0/24 -d 192.168.100.0/24 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth1 -o eth2 -s 192.168.100.0/24 -d 192.168.200.0/24 -j ACCEPT

# LAN -> DMZ
iptables -A FORWARD -p icmp --icmp-type 8 -i eth1 -o eth2 -s 192.168.100.0/24 -d 192.168.200.0/24 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth2 -o eth1 -s 192.168.200.0/24 -d 192.168.100.0/24 -j ACCEPT

# LAN -> WAN
iptables -A FORWARD -p icmp --icmp-type 8 -i eth1 -o eth0 -s 192.168.100.0/24 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth0 -o eth1 -d 192.168.100.0/24 -j ACCEPT

######### DNS #########

# UDP
iptables -A FORWARD -p udp --dport 53 -i eth1 -o eth0 -s 192.168.100.0/24 -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -i eth0 -o eth1 -d 192.168.100.0/24 -j ACCEPT

# TCP
iptables -A FORWARD -p tcp --dport 53 -i eth1 -o eth0 -s 192.168.100.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -i eth0 -o eth1 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### HTTP #########

iptables -A FORWARD -p tcp --dport 80 -i eth1 -o eth0 -s 192.168.100.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -i eth0 -o eth1 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 8080 -i eth1 -o eth0 -s 192.168.100.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 8080 -i eth0 -o eth1 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### HTTPS #########

iptables -A FORWARD -p tcp --dport 443 -i eth1 -o eth0 -s 192.168.100.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 443 -i eth0 -o eth1 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### Serveur WEB #########

# LAN -> WEB DMZ
iptables -A FORWARD -p tcp --dport 80 -i eth1 -s 192.168.100.0/24 -d 192.168.200.2 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -s 192.168.200.2 -d 192.168.100.0/24 -o eth1 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# WAN -> WEB DMZ
iptables -A FORWARD -p tcp --dport 80 -i eth0 -d 192.168.200.2 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -s 192.168.200.2 -o eth0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### SSH #########

# LAN -> DMZ
iptables -A FORWARD -p tcp --dport 22 -i eth1 -o eth2 -s 192.168.100.0/24 -d 192.168.200.2 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 22 -i eth2 -o eth1 -s 192.168.200.2 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# LAN -> FIREWALL
iptables -A INPUT -p tcp --dport 22 -i eth1 -s 192.168.100.0/24 -d 192.168.100.3 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -o eth1 -s 192.168.100.3 -d 192.168.100.0/24 -m conntrack --ctstate ESTABLISHED -j ACCEPT