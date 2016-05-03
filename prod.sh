chmod 777 ./build.sh
source ./build.sh
cp $OVV_PROD $AD_OVV_PROD
timestamp() {
   date +"%T"
}
echo "at $(timestamp)"
