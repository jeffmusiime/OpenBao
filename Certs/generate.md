## Generate Private Key
openssl genrsa -des3 -out myCA.key 2048

## Geberate Root Certificate
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -out myCA.pem

## Adding the root certifcate
