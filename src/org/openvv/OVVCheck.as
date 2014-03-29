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
	private var _results:Object;
	private var _renderMeter:OVVRenderMeter;
	private var _throttleState:String;

	public function OVVCheck(uniqueId:String) 
	{
	    if (OVVCheck.externalInterfaceIsAvailable())
	    {
			  ExternalInterface.addCallback(uniqueId, flashProbe);
			  
			  var sprite:Sprite = new Sprite();
			  _renderMeter = new OVVRenderMeter(sprite);
			  sprite.addEventListener("throttle", onThrottle);
			  
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
      return { "error": "ExternalInterface not available" };

	
	var visible:String = ExternalInterface.call("document.getElementById('OVVBeacon1').isVisible()");
	
		var js:XML = <script><![CDATA[
				function a( obfuFn ) {
					var results = {};
					if ( window.self === window.top ) { //Check for iFrames
						//Find Object by looking for obfuFn (Obfuscated Function set by Flash)
						var myObj = null;
						//When IE is detected, some pages only use an embed:
						var embeds = document.getElementsByTagName("embed");
						for (var i = 0; i < embeds.length; i++) {
							if ( !!embeds[i][ obfuFn ] ) {
								myObj = embeds[i];
							}
						}
						if ( myObj == null ) {
							var objs = document.getElementsByTagName("object");
							for (var i = 0; i < objs.length; i++) {
								if ( !!objs[i][ obfuFn ] ) {
									myObj = objs[i];
								}
							}
						}
						if ( myObj == null ) {
							//report object not found
							results = { "error": "Object not found" };
						} else {
							//Capture the player id for reporting (not necessary to check viewability):
							results[ 'id' ] = myObj.id;
							//Avoid including scrollbars in viewport size by taking the smallest dimensions (also
							//ensures ad object is not obscured)
							results[ 'clientWidth' ] = Infinity;
							results[ 'clientHeight' ] = Infinity;
							//document.body  - Handling case where viewport is represented by documentBody
							//.width
							if ( !isNaN( document.body.clientWidth ) && document.body.clientWidth > 0 ) {
								results[ 'clientWidth' ] = document.body.clientWidth;
							}
							//.height
							if ( !isNaN( document.body.clientHeight ) && document.body.clientHeight > 0 ) {
								results[ 'clientHeight' ] = document.body.clientHeight;
							}
							//document.documentElement - Handling case where viewport is represented by documentElement
							//.width
							if ( !!document.documentElement && !!document.documentElement.clientWidth &&
								!isNaN( document.documentElement.clientWidth ) ) {
								results[ 'clientWidth' ] = document.documentElement.clientWidth;
							}
							//.height
							if ( !!document.documentElement && !!document.documentElement.clientHeight &&
								!isNaN( document.documentElement.clientHeight ) ) {
								results[ 'clientHeight' ] = document.documentElement.clientHeight;
							}
							//window.innerWidth/Height - Handling case where viewport is represented by window.innerH/W
							//.innerWidth
							if ( !!window.innerWidth && !isNaN( window.innerWidth ) ) {
								results[ 'clientWidth' ] = Math.min ( results[ 'clientWidth' ],
									window.innerWidth );

							}
							//.innerHeight
							if ( !!window.innerHeight && !isNaN( window.innerHeight ) ) {
								results[ 'clientHeight' ] = Math.min( results[ 'clientHeight' ],
									window.innerHeight );
							}
							if ( results[ 'clientHeight' ] == Infinity || results[ 'clientWidth' ] == Infinity ) {
								results = { "error": "Failed to determine viewport" };
							} else {
								//Get player dimensions:
								var rects = myObj.getClientRects();
								objRect = rects[0];
								results[ 'objTop' ] = objRect.top;
								results[ 'objBottom' ] = objRect.bottom;
								results[ 'objLeft' ] = objRect.left;
								results[ 'objRight' ] = objRect.right;

								if ( objRect.bottom < 0 || objRect.right < 0 ||
									objRect.top > results.clientHeight || objRect.left > results.clientWidth ) {
									//Entire object is out of viewport
									results[ 'percentViewable' ] = 0;
								} else {
									var totalObjectArea = ( objRect.right - objRect.left ) *
										( objRect.bottom - objRect.top );
									var xMin = Math.ceil( Math.max( 0, objRect.left ) );
									var xMax = Math.floor( Math.min( results.clientWidth, objRect.right ) );
									var yMin = Math.ceil( Math.max( 0, objRect.top ) );
									var yMax = Math.floor( Math.min( results.clientHeight, objRect.bottom ) );
									var visibleObjectArea = ( xMax - xMin + 1 ) * ( yMax - yMin + 1 );
									results[ 'percentViewable' ] = Math.round( visibleObjectArea / totalObjectArea * 100 );
								}
							}
						}
					} else {
						results = { "error": "Ad in iFrame" };
					}
					return results;
				}
			]]></script>;
		var results:Object = ExternalInterface.call(js, uniqueId ) as Object;
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

	var viewable:Boolean = ExternalInterface.call("isPlayerVisible");
	
	// viewable if in view relative to window and flash is rendering the player.
    if (results['percentViewable'] != null)
    {
      results['viewabilityState'] = (results['percentViewable'] >= 50 && results['focus']) ? "viewable" : "notViewable";
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
