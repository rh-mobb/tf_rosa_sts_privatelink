#!/bin/bash
set -e -x

sudo dnf install -y wget curl python36 python36-devel net-tools gcc libffi-devel openssl-devel jq bind-utils podman squid

mkdir -p /etc/squid/certs

cat << EOF | sudo tee /etc/squid/certs/squid-ca-cert-key.pem
-----BEGIN CERTIFICATE-----
MIIDZTCCAk2gAwIBAgIUTRG1CidAFp/9vtSmZhtR2uALc0EwDQYJKoZIhvcNAQEL
BQAwQjELMAkGA1UEBhMCWFgxFTATBgNVBAcMDERlZmF1bHQgQ2l0eTEcMBoGA1UE
CgwTRGVmYXVsdCBDb21wYW55IEx0ZDAeFw0yMjAzMTYxODE3NDRaFw0yMzAzMTYx
ODE3NDRaMEIxCzAJBgNVBAYTAlhYMRUwEwYDVQQHDAxEZWZhdWx0IENpdHkxHDAa
BgNVBAoME0RlZmF1bHQgQ29tcGFueSBMdGQwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQDUkFiWv8eicsm5jIMAAtTqX2vW6lr8oQHbsOpMWk9LE4YFLMf/
ePEbthdYmMsP+vWAqqvCMoflez+tGTkv8820Vs7b0pB54M7/iONHYGcYy4YwxHTW
fYWmkgAEHLuMyfUBBjAlUuvzbaZlowmejxAPFfd2A6Hbh9+wSU+Lk1Tw9YrQFSyb
drBwdnidK01QNSu3QOhPFls5WGi6fuoke6tCgDxm+X2ULIbihw26dovaIsFBnhot
+NSr9DuEwD/knVwbmw8QAVJCx3tfGoilB8kbxvbgLFIp6DMKAXlrNNFfDThjY8KD
fBOR+7t+hgY2fB+oCPqW0vAubd+cNunHB0i7AgMBAAGjUzBRMB0GA1UdDgQWBBRH
btbhfPaGFwr+1nsOZ1qwqIwmqjAfBgNVHSMEGDAWgBRHbtbhfPaGFwr+1nsOZ1qw
qIwmqjAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQBNmYxoqaRT
QfhrtuikzOev1mWqm+PN3EmzkE2DpELp/lAIr3lhxE6zNS8v+kaxQ8FuZ1Kio8Yr
7o24+i4bA3W1XzdgU1mhld6A+ERatDwij7Rh0xHaAi+9fLNj5YNG6Gih70xMsj/Z
1rtKBTn0T7Wqu9aWl8Ajsj6kRMse5jGA01XBjq3OwqcQCvWLye3WFbRdFd7xbNrJ
Df147B1Z8Ogq2s5yJdzNkJEYgYMUPYrRUrySkaArUTteMc6V5WKCxTKYGbfYcJvd
yo/b88M7LLXrHBDZqTPFE4sb1xZjuoTko1ma3Dhqk76LPfWCGR1sxmOdM6Uc+VcD
M4GkueWbio3A
-----END CERTIFICATE-----
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDUkFiWv8eicsm5
jIMAAtTqX2vW6lr8oQHbsOpMWk9LE4YFLMf/ePEbthdYmMsP+vWAqqvCMoflez+t
GTkv8820Vs7b0pB54M7/iONHYGcYy4YwxHTWfYWmkgAEHLuMyfUBBjAlUuvzbaZl
owmejxAPFfd2A6Hbh9+wSU+Lk1Tw9YrQFSybdrBwdnidK01QNSu3QOhPFls5WGi6
fuoke6tCgDxm+X2ULIbihw26dovaIsFBnhot+NSr9DuEwD/knVwbmw8QAVJCx3tf
GoilB8kbxvbgLFIp6DMKAXlrNNFfDThjY8KDfBOR+7t+hgY2fB+oCPqW0vAubd+c
NunHB0i7AgMBAAECggEAbUfMk6wDGYxEE2Wez7mk9t2Z1oLjxi+MggLBYgGn9GQU
KcLtC3WFF4cVF5JuC0gtQTn9Vbiezyb/BKIMGZAROF7MuIzXhCFEqnEYz9BLEJ9J
3PaTTtZ3iLxUz8hpz6bgk+c3h2jLL3o26tfYETFhwy+66mxRoUiIgtwdzhcvuzTB
TPgOLv7akkMS6Ot5RssRPH7bNBeoeLqZXMpGRLpoKqoI/mEdEcaUtWBVQNgQQZHv
EDnEljOVSTPFLyN4R0+ea55nKyVsZXTdxV1iQWiMFJr4Yuujxq1XidnkRtXw6R54
uQwzD3w3v9D+7uyRmW5D1rMv60lpeePWjLojgFFNqQKBgQD0RjKtqp1bxGbGOaXz
Dzx8X++GsQZNR+U4wwLwDDUZibWbm5bKFGO01nZLhPnnH2YUUGIehX6q9aaslnuT
nIxG53pDLiUKuNshmDYj13D64eottEnXgQ5EtnYh1JNrawt2Yx7iAvWakB0X2s9e
sRnuXeiJn2a4kyOytTZZMaIAjQKBgQDexHhpQ2awA7zPCnoRaNnObYqYv8DdF7Kl
M4D36BV6ryIF6dCWf5T7r0FfoYNaDSLVbGBsr7tlU+pyZK2qs+nsuDagi+4T1c16
bIFF3ZOp87HCIP8cW7FJm4JrzRtJnqPmlOEXZHyKULlN8SvlOXr7mivwoeOq3cE7
pVPKrqFQZwKBgAMUJ2tc7SLM9Oamr1rC5GZE50XxUT0EHPV8L7tKzBiITcuqSFo/
q4oJ8e+9u1CYarby1GnCEPiio/kk5GXV4Ua7gCT8nebmsYxY2MXW30uqMUNmNFAN
BlsDWbXPchQ2gyx4z1jV5LaP/m3giiCNZuBEOrwRUEAfSqHj+s1g/MO5AoGAKjQO
m+KpEa+jlZXmimXS3cji+Q1a/IgA0Etxo4XUi+miCHzDh7+j+gq51+RBfk3+y3A8
1Fp2pju/ruxj+nMbXj2IG+JmuFtJEmh8FUBlOU1x39Vgf37fl5Jeow24nbnwUz7h
Zg0jixDACoQmTMcXBZOvv2bsOvLIKQSpWzy6UwECgYBl4IKmBdxJeE+eQlmle2PA
HMxe7YgmMzsPOSD4aPqSAvVttKoTS/PntNLAINl9elFmBRsUVtzQw8AAGjMn6Wg7
fLLrDV7+Sx1ZF2EfoKBILN2FSSVc0SX9NwLbFj4+lTHPHPoDZ7HvpY4TxasrQUCx
n8E3XriCx6Vyo9t3tOP94A==
-----END PRIVATE KEY-----
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
ec2.{{ rosa_region }}.amazonaws.com
elasticloadbalancing.{{ rosa_region }}.amazonaws.com
*.s3.dualstack.{{ rosa_region }}.amazonaws.com
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

