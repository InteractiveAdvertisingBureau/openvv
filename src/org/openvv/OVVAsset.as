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
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.TimerEvent;
  import flash.external.ExternalInterface;
  import flash.utils.Timer;
  
  import org.openvv.events.OVVEvent;

  public class OVVAsset extends EventDispatcher
  {
	[Embed(source = "/../js/OVVAsset.js", mimeType = "application/octet-stream")]
    public static const OVVAssetJSSource:Class;
	
    private static const VIEWABLE_IMPRESSION_THRESHOLD:Number = 20;
    private static const DISCERNIBLE_IMPRESSION_THRESHOLD:Number = 4;
    private static const IMPRESSION_DELAY:Number = 250;
    private static const VIEWABLE_AREA_THRESHOLD:Number = 50;

    private var _id:String;
    private var _impressionTimer:Timer;
    private var _intervalsInView:Number;
    private var _hasDispatchedDImp:Boolean = false;
	private var _renderMeter:OVVRenderMeter;
	private var _throttleState:String;

	private var _sprite:Sprite;
	
    public function OVVAsset(beaconSwfUrl:String)
    {
	  if (!externalInterfaceIsAvailable())
	  {
		  dispatchEvent(new OVVEvent(OVVEvent.OVVError, {"message":"ExternalInterface unavailable"}));
		  return;
	  }
	  
	  _id = "ovv" + Math.floor(Math.random() * 1000000000).toString();
		  
	  ExternalInterface.addCallback(_id, flashProbe);
	  ExternalInterface.addCallback("ready", ready);
		  
	  _sprite = new Sprite();
	  _renderMeter = new OVVRenderMeter(_sprite);
	  _sprite.addEventListener("throttle", throttleHandler);
	  
	  var ovvAssetSource:String = new OVVAssetJSSource().toString();
	  ovvAssetSource = ovvAssetSource.replace(/OVVID/g, _id).replace(/BEACON_SWF_URL/g, beaconSwfUrl);
	  ExternalInterface.call("eval", ovvAssetSource);
    }
	
	public function ready():void
	{
		if (!_impressionTimer)
		{
			_intervalsInView = 0;
			
			_impressionTimer = new Timer(IMPRESSION_DELAY);
			_impressionTimer.addEventListener(TimerEvent.TIMER, timerHandler);
			_impressionTimer.start();	
		}
	}
	
	//Callback function attached to HTML Object to identify it:
	public function flashProbe( someData:* ):void 
	{
		return;
	}
	
	public function checkViewability():OVVCheck 
	{
		if (!externalInterfaceIsAvailable())
		{	
			return new OVVCheck({ "error": "ExternalInterface unavailable" });
		}
		
		var jsResults:Object = ExternalInterface.call("$ovv.getAdById('" + _id + "')" + ".checkViewability");
		var results:OVVCheck = new OVVCheck(jsResults);
		
		var visibles:Object = {};
		for (var index:int = 1; index <= 9; index++)
		{
			var js:String = "document.getElementById('OVVBeacon_" + index + "_" + _id + "').isVisible";
			visibles[String(index)] = ExternalInterface.call(js); 	
		}
		
		// error? all done
		if (results.error)
		{
			return results;
		}
		
		if (_throttleState != null)
		{
			results.focus =  _throttleState = OVVThrottleType.RESUME; 
		}
		else
		{
			results.focus = _renderMeter.fps > 8;
		}
		
		return results;
	}
	
	public static function externalInterfaceIsAvailable():Boolean
	{
		var isEIAvailable:Boolean = false;
		
		try
		{
			isEIAvailable = !!ExternalInterface.call("function() { return 1; }");
		}
		catch (e:SecurityError) 
		{
			// ignore
		}
		
		return isEIAvailable;
	}
	
	public function dispose():void
	{
		ExternalInterface.call("$ovv.getAdById('" + _id + "')" + ".dispose");
		
		if(_impressionTimer)
		{
			_impressionTimer.stop();
			_impressionTimer.removeEventListener(TimerEvent.TIMER, timerHandler);
			_impressionTimer = null;
		}

		if(_sprite)
		{
			_sprite.removeEventListener("throttle", throttleHandler);
			_sprite = null;	
		}
		
		if(_renderMeter)
		{
			_renderMeter = null; 
		}
	}

    // Every 250ms, check to see if asset is visible
    // Count consecutive viewable results.  If asset not visible, reset count
    // Once asset has been visible for 5s, raise impression
    private function timerHandler(e:TimerEvent):void
    {
		var results:Object = checkViewability();
		
		_intervalsInView = (results['viewabilityState'] == "viewable") ? _intervalsInView + 1 : 0;

  		if(_intervalsInView >= DISCERNIBLE_IMPRESSION_THRESHOLD && !_hasDispatchedDImp)
  		{
			_hasDispatchedDImp = true;
			dispatchEvent(new OVVEvent(OVVEvent.OVVDiscernibleImpression));
  		}
  		else if (_intervalsInView >= VIEWABLE_IMPRESSION_THRESHOLD)
  		{
  			dispatchEvent(new OVVEvent(OVVEvent.OVVImpression));
			_impressionTimer.stop();
		}
    }
	
	protected function throttleHandler(event:Event):void
	{
		if(event.hasOwnProperty('state'))
		{
			_throttleState = event['state'];
		}
	}
  }
}
