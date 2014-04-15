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
package org.openvv {
import flash.display.Sprite;
import flash.events.Event;
import flash.external.ExternalInterface;

public class OVVCheck {
	
	[Embed(source = "/../js/OVVCheck.js", mimeType = "application/octet-stream")]
	public static const OpenVVJS:Class;
	
	private var _results:Object;
	private var _renderMeter:OVVRenderMeter;
	private var _throttleState:String;
	private var _id:String;
	private var _js:String;

	public function OVVCheck(uniqueId:String) 
	{
		_id = uniqueId;
		
	    if (OVVCheck.externalInterfaceIsAvailable())
	    {
			  ExternalInterface.addCallback(uniqueId, flashProbe);
			  
			  var sprite:Sprite = new Sprite();
			  _renderMeter = new OVVRenderMeter(sprite);
			  sprite.addEventListener("throttle", onThrottle);
			  
			  _js = String(new OpenVVJS());
			  
			  _results = checkViewability(uniqueId);
	    }
	    else
	    {
	      _results = { "error": "ExternalInterface not available" };
	    }
	}
	
	protected function onThrottle(event:Event):void
	{
		if(event.hasOwnProperty('state'))
		{
			_throttleState = event['state'];
		}
	}
	
	public function get results():Object
	{
		return _results;
	}

	//Callback function attached to HTML Object to identify it:
	public function flashProbe( someData:* ):void {
		return;
	}
	
	public function checkViewability( uniqueId:String ):Object {
    	if (!OVVCheck.externalInterfaceIsAvailable())
		{	
      		return { "error": "ExternalInterface not available" };
		}

		var results:Object = ExternalInterface.call(_js, uniqueId ) as Object;
    	_results = finalizeResults(results);

    	return _results;
	}

  // Based on data, determine whether unit is invi
  private function finalizeResults(results:Object):Object
  {
    results['viewabilityState'] = "unmeasurable"

    // error? all done
    if (results['error'])
      return results;
	
	if(_throttleState != null)
	{
		results['focus'] =  _throttleState = OVVThrottleType.RESUME; 
	}
	else
	{
		results['focus'] = _renderMeter.fps > 8;
	}

	var isReady:Boolean = ExternalInterface.call("$ovv.ovvAsset.isReady", _id);
	if (isReady)
	{
		var viewable:Boolean = ExternalInterface.call("$ovv.ovvAsset.isPlayerViewable");
		results['viewabilityState'] = viewable ? "viewable" : "notViewable";	
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
    catch (e:SecurityError) { }

    return isEIAvailable;
  }
}
}
