openvv
======

# Getting Started
1. Clone the repository and cd into the root directory of it.
2. Modify the FLEX_HOME property of build.xml to point to the local directory of your Flex SDK. For example:
```xml
<property name="FLEX_HOME" value="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"/>
```
3. Build the SWC by running:
        ant swc
4. Incorporate the SWC into your project
5. Build the Beacons by running
        ant compileBeacon
6. Host the newly compiled bin/Beacon.swf in a public location of your choice.
7. Initialize OpenVV by passing the URL of your Beacon to `OVVAsset`:
```actionscript
var asset:OVVAsset = new OVVAsset('http://localhost/Beacon.swf');
```
8. Get viewability data at any time by calling `OVVAsset.checkViewability()`.
```actionscript
var check:OVVCheck = asset.checkViewability();
9. Query the properties of the `OVVCheck` object to report on your player's viewability.

    
