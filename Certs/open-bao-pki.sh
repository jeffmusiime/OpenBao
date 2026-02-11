#!/bin/bash
# OpenBao PKI Quick Reference

# 1. Enable PKI engine
bao secrets enable pki
bao secrets tune -path=pki max_lease_ttl=87600h

# 2. Generate Root CA
bao write pki/root/generate/internal \
  common_name="My Root CA" ttl=87600h

# 3. Generate Intermediate
bao secrets enable -path=pki_int pki
bao write -format=json pki_int/intermediate/generate/internal \
  common_name="My Intermediate CA" | jq -r '.data.csr' > intermediate.csr

# 4. Sign Intermediate
bao write pki/root/sign-intermediate \
  csr=@intermediate.csr format=pem_bundle | jq -r '.data.certificate' > signed.crt
bao write pki_int/intermediate/set-signed certificate=@signed.crt

# 5. Create Role
bao write pki_int/roles/web-server \
  allowed_domains="example.com" \
  allow_subdomains=true \
  max_ttl=720h

# 6. Issue Certificate
bao write pki_int/issue/web-server \
  common_name="www.example.com" ttl=24h

# 7. Revoke Certificate
bao write pki_int/revoke serial_number="00:00:00:00:00:00:00:00"

# 8. Check Certificate
bao read pki_int/cert/00:00:00:00:00:00:00:00

# 9. Generate CRL
bao read pki_int/crl/pem > ca.crl

# 10. Tidy expired certificates
bao write pki_int/tidy tidy_cert_store=true tidy_revoked_certs=true
