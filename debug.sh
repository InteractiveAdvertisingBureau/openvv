export FLEX_HOME=/Applications/Adobe\ Flash\ Builder\ 4.7/sdks/4.5.0
export ANT_HOME=/Applications/Ant
export OVV_LIB=/Users/steve.thorpe/Documents/git/sourcetree/openvv/bin/openvv_db.swc
export AD_LIB=/Users/steve.thorpe/Documents/git/sourcetree/adunit/src
export DEBUG_OVV=true
chmod 777 ./build.sh
./build.sh
cp $OVV_LIB $AD_LIB
timestamp() {
   date +"%T"
}
echo "at $(timestamp)"
