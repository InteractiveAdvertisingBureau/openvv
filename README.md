#openvv (with 3rd party integration)

This update to the OpenVV code base  allows 3rd parties to more easily provide video viewability measurement by exposing the VPAID data as well as the viewability data via a JavaScript API.  The release extends the functionality of OVVAsset.as for it to be used as the base class for integrating openvv into SWF Ads.

## Demo
A working demo based on the openvv demo is available here: http://video.doubleverify.com
## Overview
The addition to OVVAsset.as includes an **initEventsWiring** method which does the following:
1)  Registers OVVAsset.as as an event listener to VPAID events fired by the creative
2)    Registers itself as a listener to existing OVV events fired by the asset itself. 
3)	publishes JavaScript pub/sub ($ovv) to page. 
## Usage 
### ActionScript
1.	Instantiate an OVVAsset object and pass it a unique identifier (similar to OVVCheck). 
2.	Call initEventsWiring method and pass it the EventDispatcher that fires VPAID events. 

Code snippet:
<pre>
public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars:String):void 
{
   ...
  _viewabilityAsset = new OVVAsset(guid);  		
  // call initEventWiring with this to register asset as listener to VPAID events
  _viewabilityAsset.initEventsWiring(this); 						
  // Load 3rd party tags
  var tagSrc:String = "http://someUrl.com/3rdPartyTag.js?playerID=" + guid;			
  var func:String = "function createTag() {"										
			    + "var tag = document.createElement('script');"
			    + "tag.type = 'text/javascript';" 
			    + "tag.src = \"" + tagSrc + "\";" 
			    + "document.body.insertBefore(tag, document.body.firstChild);}";			
  var createTag:XML = new XML("<script><![CDATA[" + func + "]]></script>"); 				
  ExternalInterface.call(createTag);
  ...
}
</pre>

### JavaScript
1.	Subscribe to events on $ovv to receive viewability/VPAID data.

Code snippet:
<pre>
$ovv.subscribe('AdLoaded', playerID, function(event, id, args) {
  	...
});
</pre>

###Understanding the data
The javascript event will receive the args {"vpaidData":vpaidData, "ovvData":ovvData}
####vpaidData:
The vpaid event data if passed from the vpaid event otherwise null.
####ovvData: 
<code>viewabilityState</code>: String Indicates whether or not the asset is viewable. Possible values are "viewable", "notViewable", "unmeasurable"
<code>clientHeight</code>: int Current height of the client
<code>clientWidth</code>: int Current width of the client
<code>focus</code>: Bolean Whether or not the tab and browser are in focus
<code>objBottom</code>: int Y position of the bottom edge of the embed object
<code>objLeft</code>: int X position of the left edge of the embed object
<code>objRight</code>: int X position of the right edge of the embed object
<code>objTop</code>: intY position of the top edge of the embed object
<code>percentViewable</code>:int The percentage of the embed object's area that is calculated to be in view
