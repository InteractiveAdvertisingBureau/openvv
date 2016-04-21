export FLEX_HOME=/Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.5.0
export ANT_HOME=/Applications/Ant
export OVV_LIB=/Users/steve.thorpe/Documents/git/sourcetree/openvv/bin/openvv_db.swc
export AD_LIB_DIR=/Users/steve.thorpe/Documents/git/sourcetree/adunit/src
export TEST_LIB_DIR=/Users/steve.thorpe/Sites/localhost/test-ovv
export DEBUG_OVV=true
# rm -f $AD_LIB_DIR/openvv.swc
chmod 777 ./build.sh
./build.sh
cp $OVV_LIB $AD_LIB_DIR
cp $OVV_LIB $TEST_LIB_DIR
timestamp() {
   date +"%T"
}
echo "at $(timestamp)"
