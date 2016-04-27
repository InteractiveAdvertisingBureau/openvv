export TEST_LIB_DIR=/Users/steve.thorpe/Sites/localhost/test-ovv
export DEBUG_OVV=true
# rm -f $AD_LIB_DIR/openvv.swc
chmod 777 ./build.sh
source ./build.sh
cp $OVV_DEBUG $AD_OVV_DEBUG
cp $OVV_DEBUG $TEST_LIB_DIR
timestamp() {
   date +"%T"
}
echo "at $(timestamp)"
