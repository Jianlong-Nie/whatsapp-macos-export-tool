#!/bin/bash
rm -rf ~/Downloads/keystore.xml
#chmod -x write.sh
#echo $1
/usr/local/bin/adb -s $1 pull /data/data/com.whatsapp/shared_prefs/keystore.xml ~/Downloads/keystore.xml
cat ~/Downloads/keystore.xml

