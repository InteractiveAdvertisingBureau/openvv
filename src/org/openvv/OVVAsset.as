/**
 * Copyright (c) 2013 Open VideoView
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 * to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of
 * the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package org.openvv 
{
  import flash.display.Sprite;
  import flash.events.EventDispatcher;
  import flash.events.TimerEvent;
  import flash.external.ExternalInterface;
  import flash.utils.ByteArray;
  import flash.utils.Timer;        
  import net.iab.VPAIDEvent;  
  import org.openvv.events.OVVEvent;    
  
  public class OVVAsset extends Sprite
  {
    private static const IMPRESSION_THRESHOLD:Number = 20;
    private static const IMPRESSION_DELAY:Number = 250;
    private static const VIEWABLE_AREA_THRESHOLD:Number = 50;
	private static const VPAID_EVENTS:Vector.<String> = Vector.<String>([VPAIDEvent.AdLoaded, VPAIDEvent.AdClickThru, VPAIDEvent.AdExpandedChange, 
		VPAIDEvent.AdImpression, VPAIDEvent.AdLinearChange, VPAIDEvent.AdLog, VPAIDEvent.AdPaused, VPAIDEvent.AdPlaying, 
		VPAIDEvent.AdStarted,VPAIDEvent.AdStopped, VPAIDEvent.AdUserAcceptInvitation,  VPAIDEvent.AdUserClose, VPAIDEvent.AdUserMinimize, VPAIDEvent.AdVideoComplete, 
		VPAIDEvent.AdVideoFirstQuartile, VPAIDEvent.AdVideoMidpoint, VPAIDEvent.AdVideoThirdQuartile, VPAIDEvent.AdVolumeChange, VPAIDEvent.AdSkipped,
	    VPAIDEvent.AdSkippableStateChange, VPAIDEvent.AdSizeChange, VPAIDEvent.AdDurationChange, VPAIDEvent.AdInteraction]);
	
	private static const OVV_EVENTS:Vector.<String> = Vector.<String>([OVVEvent.OVVError,OVVEvent.OVVLog, OVVEvent.OVVImpression]);	
		
    private var _initialized:Boolean = false;
    private var _id:String;
    private var _viewabilityCheck:OVVCheck;
    private var _impressionTimer:Timer;
    private var _intervalsInView:Number;
	private var _jsOVVTypeXML:XML;
	
	[Embed(source="embed/OVVType.js",mimeType="application/octet-stream")]
	private var _jsOVVType:Class;

    public function OVVAsset(id:String="")
    {
		var b:ByteArray = new _jsOVVType();
		var ovvTypeStr:String = b.readUTFBytes(b.length);
		_jsOVVTypeXML =  new XML("<script><![CDATA[" + ovvTypeStr + "]]></script>"); 			 
			
		_id = id;	
		if (!OVVCheck.externalInterfaceIsAvailable())
		{
		  raiseError("ExternalInterface unavailable");
		  return;
		}
		  
		_initialized = true;
		_viewabilityCheck = new OVVCheck(_id);
		
		_intervalsInView = 0;
		_impressionTimer = new Timer(IMPRESSION_DELAY);
		_impressionTimer.addEventListener(TimerEvent.TIMER, timerHandler);
		_impressionTimer.start();	  
    }

	public function initEventsWiring(vpaidEventsDispatcher:EventDispatcher): void 
	{	
		if (vpaidEventsDispatcher == null)
			throw "EventDispatcher is null";					
		registerEventHandler(vpaidEventsDispatcher);					
		ExternalInterface.call("function js_" + ( new Date().getTime() ) + "(){ " + _jsOVVTypeXML + " }");
	}
	
    public function checkViewability():Object
    {
      if (!_initialized)
        raiseError("ExternalInterface unavailable");

      return performCheck();
    }

    private function performCheck():Object
    {
      var results:Object = _viewabilityCheck.checkViewability(_id);
	
      if (results && !!results.error)
        raiseError(results);
	  
	    
      return results;
    }

    // Every 250ms, check to see if asset is visible
    // Count consecutive viewable results.  If asset not visible, reset count
    // Once asset has been visible for 5s, raise impression
    private function timerHandler(e:TimerEvent):void
    {
		var ovvData:* = checkViewability(); 
		raiseLog(ovvData);
		
      	if (ovvData >= VIEWABLE_AREA_THRESHOLD)		
			_intervalsInView++;				
      	else		
			_intervalsInView = 0;			
		
      	if (_intervalsInView >= IMPRESSION_THRESHOLD)
      	{
	        raiseImpression(ovvData);
        	_impressionTimer.stop();
      	}
    }

    private function raiseImpression(ovvData:*):void
    {
		dispatchEvent(new OVVEvent(OVVEvent.OVVImpression, ovvData));
    }

    private function raiseLog(ovvData:*):void
    {
		dispatchEvent(new OVVEvent(OVVEvent.OVVLog, ovvData));
    }

    private function raiseError(ovvData:*):void
    {
      	dispatchEvent(new OVVEvent(OVVEvent.OVVError, ovvData));
    }
	
	private function handleOVVEvent(event:OVVEvent):void 
	{		
		publishToJavascript(event.type, null, event.data);	
	}

	// Have a single method for publishing events
	public function handleVPaidEvent(event:VPAIDEvent):void
	{		
		var ovvData:* = checkViewability();
		
		switch(event.type){
			case VPAIDEvent.AdVideoComplete:
				// stop time on ad completion
				_impressionTimer.stop();
				_impressionTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
				_impressionTimer = null;
			default:
				// do nothing
		}
		
		publishToJavascript(event.type, event.data, ovvData);
	}		
	
	private function publishToJavascript(eventType:String, vpaidData:Object, ovvData:Object):void
	{	
		var publishedData:* = {"vpaidData":vpaidData, "ovvData":ovvData}
		
		var jsOvvPublish:XML = <script><![CDATA[
											function(event, id, args) { 
												setTimeout($ovv.publish(event,  id, args), 0);
											}
										]]></script>;	
		
		ExternalInterface.call(jsOvvPublish, eventType ,_id, publishedData);
	}
	
	private function registerEventHandler(vpaidEventsDispatcher:EventDispatcher):void
	{		
		// Register to VPAID events
		var eventType:String;
		
		for each (eventType in VPAID_EVENTS)
		{
			vpaidEventsDispatcher.addEventListener(eventType, handleVPaidEvent);
		}
		
		// Register to openvv events
		for each (eventType in OVV_EVENTS)
		{
			this.addEventListener(eventType, handleOVVEvent);
		}
	}	
  }
}
