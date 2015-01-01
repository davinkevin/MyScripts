#!/bin/bash

#-- Parameters 
certificatName=$1;

#-- Configuration : 
OPEN_VPN_LOCATION=/etc/openvpn/;
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#-- Execution
cd $OPEN_VPN_LOCATION;
. ./easy-rsa/vars;

./easy-rsa/build-key $certificatName

cd ./easy-rsa/keys;
cp ${certificatName}.crt ${certificatName}.key ca.crt $DIR;

#-- Begin of certificat
cp ${OPEN_VPN_LOCATION}/klan.ovpn $DIR/klan-${certificatName}.ovpn;
cat >> $DIR/klan-${certificatName}.ovpn << EOF
<ca>
-----BEGIN CERTIFICATE-----
EOF
sed `cat $DIR/ca.crt |  grep -n "BEGIN CERTIFICATE" | cut -f1 -d: | sed -e 's@\(.*\)@1,\1d@g'` $DIR/ca.crt | head -n -1 >> $DIR/klan-${certificatName}.ovpn
cat >> $DIR/klan-${certificatName}.ovpn << EOF 
-----END CERTIFICATE-----
</ca>
<cert>
-----BEGIN CERTIFICATE-----
EOF
sed `cat $DIR/${certificatName}.crt |  grep -n "BEGIN CERTIFICATE" | cut -f1 -d: | sed -e 's@\(.*\)@1,\1d@g'` $DIR/${certificatName}.crt | head -n -1  >> $DIR/klan-${certificatName}.ovpn
cat >> $DIR/klan-${certificatName}.ovpn << EOF
-----END CERTIFICATE-----
</cert>
<key>
EOF
cat $DIR/${certificatName}.key >> $DIR/klan-${certificatName}.ovpn
cat >> $DIR/klan-${certificatName}.ovpn << EOF
</key>
EOF

cd $DIR;
rm ${certificatName}.crt ${certificatName}.key ca.crt;

cd $OPEN_VPN_LOCATION;
./easy-rsa/clean-all;
ln -s /etc/openvpn/easy-rsa/server-key/ca.{crt,key} /etc/openvpn/easy-rsa/keys/