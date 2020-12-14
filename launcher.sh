#!/bin/bash
rm -rf ~/Downloads/keystore.xml
#chmod -x write.sh
/usr/local/bin/adb pull /data/data/com.whatsapp/shared_prefs/keystore.xml ~/Downloads/keystore.xml
cat ~/Downloads/keystore.xml

