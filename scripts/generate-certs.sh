#!/bin/bash
CERT_DIR="$(dirname "$(cd "$(dirname "$0")" && pwd)")/docker/certs"
mkdir -p "$CERT_DIR"
openssl req -x509 -newkey rsa:4096 -keyout "$CERT_DIR/server.key" -out "$CERT_DIR/server.crt" -days 365 -nodes -subj "/C=NL/ST=Amsterdam/L=Amsterdam/O=Security Lab/CN=localhost"
chmod 600 "$CERT_DIR/server.key"
chmod 644 "$CERT_DIR/server.crt"
echo "Certificates generated in $CERT_DIR"
