# Nous nous sommes inspirés de ce tutorial : https://openclassrooms.com/fr/courses/1197906-securiser-son-serveur-linux

# Effacer les régles précédentes
iptables -F
iptables -X

# Bloque tout
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Permet le forward vers WAN
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

#iptables -t nat -A PREROUTING -p tcp -d 172.17.0.2 -i eth0 --dport 80 -j DNAT --to-destination 192.168.200.2

######### PING #########

# Client peut pinger DMZ et WEB (-i = venant de cette interface là, -o sortant de cette interface là)
# DMZ -> LAN
iptables -A FORWARD -p icmp --icmp-type 8 -i eth2 -o eth1 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth1 -o eth2 -j ACCEPT

# LAN -> DMZ
iptables -A FORWARD -p icmp --icmp-type 8 -i eth1 -o eth2 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth2 -o eth1 -j ACCEPT

# LAN -> WAN
iptables -A FORWARD -p icmp --icmp-type 8 -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type 0 -i eth0 -o eth1 -j ACCEPT

######### DNS #########

# UDP
iptables -A FORWARD -p udp --dport 53 -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -p udp --sport 53 -i eth0 -o eth1 -j ACCEPT

# TCP
iptables -A FORWARD -p tcp --dport 53 -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -p tcp --sport 53 -i eth0 -o eth1 -j ACCEPT

######### HTTP #########
iptables -A FORWARD -p tcp --dport 80 -i eth1 -o eth0 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED -j ACCEPT

iptables -A FORWARD -p tcp --dport 8080 -i eth1 -o eth0 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 8080 -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### HTTPS #########
iptables -A FORWARD -p tcp --dport 443 -i eth1 -o eth0 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 443 -i eth0 -o eth1 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### Serveur WEB #########
# LAN -> WEB DMZ
iptables -A FORWARD -p tcp --dport 80 -i eth1 -d 192.168.200.2 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -s 192.168.200.2 -o eth1 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# WAN -> WEB DMZ
iptables -A FORWARD -p tcp --dport 80 -i eth0 -d 192.168.200.2 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A FORWARD -p tcp --sport 80 -s 192.168.200.2 -o eth0 -m conntrack --ctstate ESTABLISHED -j ACCEPT

######### SSH #########


