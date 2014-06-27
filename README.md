openvv
======

# Getting Started
* Clone the repository and cd into the root directory of it.
* Modify the `FLEX_HOME` property of `build.xml` to point to the local directory of your Flex SDK. For example:
```xml
<property name="FLEX_HOME" value="/Applications/Adobe Flash Builder 4.7/sdks/4.6.0"/>
```
* You need Apache ANT to go forward. If you don't have it, you can install it from [the official website](http://ant.apache.org/)

## Build the SWC
* Run this from the root directory of OpenVV. It will create a new file at `bin/openvv.swc`:
```    
ant swc
```
* Incorporate the SWC into your project

## Build the Beacons
* Run this from the root directory of OpenVV. It will create a new file at `bin/OVVBeacon.swf`:
```
ant compileBeacon
```
* Move the newly created `bin/Beacon.swf` to a publicly accessible web location.

## Initialize OpenVV 
* Instantiate `OVVAsset` and pass the URL of your Beacon in:
```actionscript
var asset:OVVAsset = new OVVAsset('http://localhost/OVVBeacon.swf');
```
* Get viewability data at any time by calling `OVVAsset.checkViewability()`.
```actionscript
var check:OVVCheck = asset.checkViewability();
```
* Query the properties of the `OVVCheck` object to report on your player's viewability. 
