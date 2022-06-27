#!/bin/bash
set -e -x

sudo dnf install -y wget curl python36 python36-devel net-tools gcc libffi-devel openssl-devel jq bind-utils podman squid

mkdir -p /etc/squid/certs

cat << EOF | sudo tee /etc/squid/certs/squid-ca-cert-key.pem
${file("../modules/rosa_sts_prvlnk/files/squid-ca-cert.pem")}
${file("../modules/rosa_sts_prvlnk/files/squid-ca-key.pem")}
EOF


cat << EOF | sudo tee /etc/squid/allow-list.txt
# https://docs.openshift.com/rosa/rosa_install_access_delete_clusters/rosa_getting_started_iam/rosa-aws-prereqs.html#osd-aws-privatelink-firewall-prerequisites
# install
registry.redhat.io
quay.io
*.quay.io
sso.redhat.com
quay-registry.s3.amazonaws.com
cm-quay-production-s3.s3.amazonaws.com
cart-rhcos-ci.s3.amazonaws.com
openshift.org
registry.access.redhat.com
console.redhat.com
sso.redhat.com
pull.q1w2.quay.rhcloud.com
*.q1w2.quay.rhcloud.com
# telemetry
cert-api.access.redhat.com
api.access.redhat.com
infogw.api.openshift.com
console.redhat.com
observatorium.api.openshift.com
# aws
ec2.amazonaws.com
events.amazonaws.com
iam.amazonaws.com
route53.amazonaws.com
sts.amazonaws.com
tagging.us-east-1.amazonaws.com
ec2.${region}.amazonaws.com
elasticloadbalancing.${region}.amazonaws.com
*.s3.dualstack.${region}.amazonaws.com
# openshift
mirror.openshift.com
storage.googleapis.com/openshift-release
api.openshift.com
# red hat sre
api.pagerduty.com
events.pagerduty.com
api.deadmanssnitch.com
nosnch.in
*.osdsecuritylogs.splunkcloud.com
http-inputs-osdsecuritylogs.splunkcloud.com
sftp.access.redhat.com
EOF

cat << EOF | sudo tee /etc/squid/squid.conf
acl intermediate_fetching transaction_initiator certificate-fetching
acl localnet src 10.0.0.0/8	# RFC1918 possible internal network
acl localnet src 172.16.0.0/12	# RFC1918 possible internal network
acl localnet src 192.168.0.0/16	# RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines
acl whitelist dstdomain "/etc/squid/sites.whitelist.txt"
acl SSL_ports port 443
acl Safe_ports port 80		# http
acl Safe_ports port 21		# ftp
acl Safe_ports port 443		# https
acl Safe_ports port 22		# ssh
acl Safe_ports port 70		# gopher
acl Safe_ports port 210		# wais
acl Safe_ports port 1025-65535	# unregistered ports
acl Safe_ports port 280		# http-mgmt
acl Safe_ports port 488		# gss-http
acl Safe_ports port 591		# filemaker
acl Safe_ports port 777		# multiling http
acl CONNECT method CONNECT
http_access allow intermediate_fetching
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localnet
http_access allow localhost
http_access allow whitelist
http_access deny all
http_port 3128 \
  ssl-bump \
  generate-host-certificates=on \
  dynamic_cert_mem_cache_size=4MB \
  cert=/etc/squid/certs/squid-ca-cert-key.pem
sslproxy_cert_error allow all
ssl_bump stare all
acl step1 at_step SslBump1
ssl_bump peek step1
ssl_bump bump all
ssl_bump splice all
coredump_dir /var/spool/squid
refresh_pattern ^ftp:		1440	20%	10080
refresh_pattern ^gopher:	1440	0%	1440
refresh_pattern -i (/cgi-bin/|\?) 0	0%	0
refresh_pattern .		0	20%	4320
EOF

sudo /usr/lib64/squid/security_file_certgen -c -s /var/spool/squid/ssl_db -M 20MB
sudo chown squid:squid -R /var/spool/squid/ssl_db

sudo semanage permissive -a squid_t

sudo systemctl enable squid
sudo systemctl start squid

