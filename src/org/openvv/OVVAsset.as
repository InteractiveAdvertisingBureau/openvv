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
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;
    	
    import org.openvv.events.OVVEvent;
	import net.iab.VPAIDEvent;

    /**
     * The event dispatched when the asset has been viewable for 5 contiguous seconds
     */
    [Event(name = "OVVImpression", type = "org.openvv.events.OVVEvent")]
    /**
     * The Event dispatched when OVV emits information messages
     */
    [Event(name = "OVVLog", type = "org.openvv.events.OVVEvent")]
    /**
     * The event dispatched when OVV encounters an error
     */
    [Event(name = "OVVError", type = "org.openvv.events.OVVEvent")]
    /**
     * <p>
     * OVVAsset is the entry point into OVV. To use OVVV, create an instance of
     * this object and pass in the URL of a publicly available OVVBeacon.swf.
     * </p><p>
     * OVV will then attempt to determine the viewability of the SWF it's
     * compiled into using one of two techniques:
     * </p>
     * <ol>
     * <li>
     * The "geometry technique" uses JavaScript APIs such as
     * document.body.clientWidth/Height and getClientRects() to determine
     * how much of the SWF is within the viewport of the browser. It then sets
     * OVVCheck.viewabilityState to OVVCheck.VIEWABLE or OVVCheck.UNVIEWABLE.
     * </li>
     * <li>
     * When the asset determines that it is being viewed within an iframe,
     * it will then attempt to use the "beacon technique." This technique places
     * beacon SWFs on top of the asset and leverages the ThrottleEvent
     * introduced in FlashPlayer 11 to determine whether each beacon is within
     * the browser's viewport. If the Flash Player or the browser being used
     * don't support ThrottleEvent, OVVCheck.viewabilityState will be set to
     * OVVCheck.UNMEASURABLE.
     * </li>
     * </ol>
     * <p>
     * When OVV.DEBUG (in JavaScript) is set to true, OVV will enlarge and
     * display the beacons on the page and use both techniques. OVV will then
     * also populate the OVVCheck.beaconViewabilityState and
     * OVVCheck.geometryViewabilityState properties so that the end user can
     * compare the results of each techniques.
     * </p>
     */
    public class OVVAsset extends EventDispatcher {

        ////////////////////////////////////////////////////////////
        //EMBEDS 
        ////////////////////////////////////////////////////////////

        /**
         * The JavaScript source code
         */
        [Embed(source = "js/OVVAsset.js", mimeType = "application/octet-stream")]
        public static const OVVAssetJSSource: Class;

        ////////////////////////////////////////////////////////////
        //   CONSTANTS 
        ////////////////////////////////////////////////////////////

        /**
         * The number of consecutive intervals of viewability required before
         * the VIEWABLE_IMPRESSION event will be fired (2 seconds)
         */
        public static const VIEWABLE_IMPRESSION_THRESHOLD: Number = 10;				
        
        /**
         * The number of milliseconds between polling JavaScript for
         * viewability information
         */
        public static const POLL_INTERVAL:int = 200;

        /**
         * Hold OVV version. Will past to JavaScript as well $ovv.version
         */
        public static const VERSION: Number = 1;
        

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES 
        ////////////////////////////////////////////////////////////

        /**
         * Whether the asset has dispatched the DISCERNABLE_IMPRESSION event
         */
        private var _hasDispatchedDImp: Boolean = false;

        /**
         * The randomly generated unique identifier of this asset
         */
        private var _id: String;

        /**
         * The timer used to measure intervals
         */
        private var _intervalTimer: Timer;

        /**
         * The number of consecutive intervals in which the asset has been
         * viewable. Reset to 0 when the asset is found to be unviewable.
         */
        private var _intervalsInView: Number;

        /**
         * The RenderMeter which gauges the frame rate of the asset
         */
        private var _renderMeter: OVVRenderMeter;

        /**
         * A Sprite used for measuring frame rate and receiving ThrottlEvents
         */
        private var _sprite: Sprite;

        /**
         * A reference to the stage. Used for detecting full screen viewing.
         */
        private var _stage:Stage;

        /**
         * The last recorded ThrottleState
         *
         * @see org.openvv.OVVThrottleType
         * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/ThrottleEvent.html
         */
        private var _throttleState: String;		
		
		/**
		 * Indicate whether the Impression event was raised
		 */
		private var _impressionEventRaised: Boolean = false;
		
		/**
		 * A array of all VPAID events
		 */
		private static const VPAID_EVENTS:Array = ([VPAIDEvent.AdLoaded, VPAIDEvent.AdClickThru, VPAIDEvent.AdExpandedChange, 
			VPAIDEvent.AdImpression, VPAIDEvent.AdLinearChange, VPAIDEvent.AdLog, VPAIDEvent.AdPaused, VPAIDEvent.AdPlaying, 
			VPAIDEvent.AdStarted,VPAIDEvent.AdStopped, VPAIDEvent.AdUserAcceptInvitation,  VPAIDEvent.AdUserClose, VPAIDEvent.AdUserMinimize, VPAIDEvent.AdVideoComplete, 
			VPAIDEvent.AdVideoFirstQuartile, VPAIDEvent.AdVideoMidpoint, VPAIDEvent.AdVideoThirdQuartile, VPAIDEvent.AdVolumeChange, VPAIDEvent.AdSkipped,
			VPAIDEvent.AdSkippableStateChange, VPAIDEvent.AdSizeChange, VPAIDEvent.AdDurationChange, VPAIDEvent.AdInteraction]);
	
		/**
		 * A vector of all OVV events
		 */
		private static const OVV_EVENTS:Array = ([OVVEvent.OVVError,OVVEvent.OVVLog, OVVEvent.OVVImpression]);	
	
		private var _vpaidEventsDispatcher:EventDispatcher = null;

        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR 
        ////////////////////////////////////////////////////////////

        /**
         * Generates a random ID for this asset. Creates JavaScript
         * callbacks, starts the RenderMeter and sets up ThrottleEvent
         * listeners, and initializes the JavaScript portion of OpenVV.
         *
         * @param beaconSwfUrl The fully qualified URL of OVVBeacon.swf for
         * OpenVV to use. For example, "http://localhost/OVVBeacon.swf". If
         * not supplied, the "beacon" method for detecting viewability will
         * be unavailable.
         * @param id The unique identifier of this OVVAsset. If not supplied,
         * it will be randomly generated.
         * @param interval The number of milliseconds between polls to
         * JavaScript for viewability information. Defaults to 250.
         */
        public function OVVAsset(beaconSwfUrl:String = null, id:String = null, stage:Stage=null) {
            
            if (!externalInterfaceIsAvailable()) {
                dispatchEvent(new OVVEvent(OVVEvent.OVVError, {
                    "message": "ExternalInterface unavailable"
                }));
                return;
            }

            _id = (id !== null) ? id : "ovv" + Math.floor(Math.random() * 1000000000).toString();
            _stage = stage;

            ExternalInterface.addCallback(_id, flashProbe);
            ExternalInterface.addCallback("startImpressionTimer", startImpressionTimer);

            _sprite = new Sprite();
            _renderMeter = new OVVRenderMeter(_sprite);
            _sprite.addEventListener(OVVThrottleType.THROTTLE, onThrottleEvent);

            var ovvAssetSource: String = new OVVAssetJSSource().toString();
            ovvAssetSource = ovvAssetSource
                                .replace(/OVVID/g, _id)
                                .replace(/INTERVAL/g, POLL_INTERVAL)
                                .replace(/VERSION/g, VERSION);
			
			if (beaconSwfUrl)
			{
				ovvAssetSource = ovvAssetSource.replace(/BEACON_SWF_URL/g, beaconSwfUrl);
			}			            
            ExternalInterface.call("eval", ovvAssetSource);
        }

        ////////////////////////////////////////////////////////////
        //   CLASS METHODS 
        ////////////////////////////////////////////////////////////

        /**
         * @return A Boolean indicating whether JavaScript is available within
         * this container
         */
        public static function externalInterfaceIsAvailable(): Boolean {
            var isEIAvailable: Boolean = false;

            try {
                isEIAvailable = !! ExternalInterface.call("function() { return 1; }");
            } catch (e: SecurityError) {
                // ignore
            }

            return isEIAvailable;
        }
		
		/**
		 * Register to the vpaidEventsDispatcher VPAID's events and allows 3rd parties to more easily provide video viewability measurement 
		 * by exposing the VPAID data as well as the viewability data via a JavaScript API. 		 
		 * @param	vpaidEventsDispatcher object that exposes VPAID events
		 */
		public function initEventsWiring(vpaidEventsDispatcher:EventDispatcher): void {	
			if (vpaidEventsDispatcher == null)
				throw "You must pass an EventDispatcher to init event wiring";
			registerEventHandler(vpaidEventsDispatcher);
			_vpaidEventsDispatcher = vpaidEventsDispatcher;
		}
		
		/**
		 * Add a JavaScript resource upon reciveing a given vpaidEvent
		 * @param	vpaidEvent The name of the VPAID event to add the JavaScript resource upon recived
		 * @param	tagUrl The JavaScript tag url
		 */
		public function addJavaScriptResourceOnEvent(vpaidEvent:String, tagUrl:String): void {
			if (_vpaidEventsDispatcher == null)
				throw "initEventsWiring must be called first.";
			_vpaidEventsDispatcher.addEventListener(vpaidEvent, onInjectJavaScriptResource(tagUrl));
		}
		
        ////////////////////////////////////////////////////////////
        //   PUBLIC API 
        ////////////////////////////////////////////////////////////

        /**
         * Returns an OVVCheck object which contains information about the
         * current viewability state of the asset.
         *
         * @return OVVCheck An object containing all the properties OVV was
         * able to gather from the container
         *
         * @see org.openvv.OVVCheck
         */
        public function checkViewability(): OVVCheck {
            if (!externalInterfaceIsAvailable()) {
                return new OVVCheck({
                    "error": "ExternalInterface unavailable"
                });
            }

            var jsResults: Object = ExternalInterface.call("$ovv.getAssetById('" + _id + "')" + ".checkViewability");
            var results: OVVCheck = new OVVCheck(jsResults);
			
			if (results && !!results.error)
				raiseError(results);            

            if (!_stage)
            {
                return results;
            }

            try
            {
                results.displayState = _stage.displayState;

                switch (_stage.displayState)
                {
                    case StageDisplayState.FULL_SCREEN:
                    case "fullScreenInteractive": // StageDisplayState.FULL_SCREEN_INTERACTIVE is available >= Flash Player 11.3
                        results.viewabilityState = OVVCheck.VIEWABLE;
                        results.viewabilityStateOverrideReason = OVVCheck.FULLSCREEN;
                        break;

                    case StageDisplayState.NORMAL:
                        // can't be sure, have to rely on other techniques
                        break;
                }
            }
            catch(e:Error)
            {
                // Either stage was null or we can't access it due to security
                // restrictions, either way we can ignore this error
            }

            return results;
        }

        /**
         * Frees resources used by this asset. It is the responsibility of the
         * end user to call this function when they no longer need OpenVV.
         */
        public function dispose(): void {
            ExternalInterface.call("$ovv.getAssetById('" + _id + "')" + ".dispose");

            if (_intervalTimer) {
                _intervalTimer.stop();
                _intervalTimer.removeEventListener(TimerEvent.TIMER, onIntervalCheck);
                _intervalTimer = null;
            }

            if (_sprite) {
                _sprite.removeEventListener("throttle", onThrottleEvent);
                _sprite = null;
            }

            if (_renderMeter) {
                _renderMeter.dispose();
                _renderMeter = null;
            }
        }

        /**
         * Callback function attached to the assets DOM Element which allows
         * JavaScript to identify it.
         *
         * @param someData An optional parameter which is ignored
         */
        public function flashProbe(someData: * ): void {
            return;
        }

        /**
         * When the JavaScript portion of OpenVV is ready, it calls this function
         * to start the interval timer which does viewability checks every
         */
        public function startImpressionTimer(): void {
            if (!_intervalTimer) {
                _intervalsInView = 0;

                _intervalTimer = new Timer(POLL_INTERVAL);
                _intervalTimer.addEventListener(TimerEvent.TIMER, onIntervalCheck);
                _intervalTimer.start();
            }
        }

        ////////////////////////////////////////////////////////////
        //   EVENT HANDLERS 
        ////////////////////////////////////////////////////////////

        /**
         * Every INTERVAL ms, check to see if asset is visible. If the asset
         * is viewable for DISCERNIBLE_IMPRESSION_THRESHOLD or
         * VIEWABLE_IMPRESSION_THRESHOLD intervals, dispatch the associated
         * event.
         *
         * @param event The TimerEvent which signals the end of this interval
         *
         */
        private function onIntervalCheck(event: TimerEvent): void {
            var results: Object = checkViewability();
			raiseLog(results);

            _intervalsInView = (results.viewabilityState == OVVCheck.VIEWABLE && results.focus == true) ? _intervalsInView + 1 : 0;

            if (_impressionEventRaised == false && _intervalsInView >= VIEWABLE_IMPRESSION_THRESHOLD) {
                raiseImpression(results);
            }
        }

        /**
         * When the Flash Player comes into or goes out of view, a
         * ThrottleEvent is dispatched and the new throttle state is
         * recorded.
         *
         * @param event The ThrottleEvent which signals that the throttle
         * state has changed. Note that the ThrottleEvent is untyped to
         * preserve compatibility when OpenVV is operating with players
         * compiled for less than Flash Player 11.
         *
         */
        private function onThrottleEvent(event: Event): void {
            if (event.hasOwnProperty('state')) {
                _throttleState = event['state'];
            }
        }

        ////////////////////////////////////////////////////////////
        //   GETTERS / SETTERS 
        ////////////////////////////////////////////////////////////

        /**
         * Whether the asset has dispatched the DISCERNABLE_IMPRESSION event
         */
        public function get hasDispatchedDImp(): Boolean {
            return _hasDispatchedDImp;
        }

        /**
         * The randomly generated unique identifier of this asset
         */
        public function get id(): String {
            return _id;
        }

        /**
         * The last recorded ThrottleState
         * @see OVVThrottleType
         */
        public function get throttleState(): String {
            return _throttleState;
        }
		
		////////////////////////////////////////////////////////////
        //   PRIVATE METHODS
        ////////////////////////////////////////////////////////////
		
		/**
		 * Create a function for injecting the JavaScript resource
		 * @param	tagUrl The JavaScript tag url
		 * @return a Function for injection the JavaScript resource
		 */
		private function onInjectJavaScriptResource(tagUrl:String):Function  {
			 return function(event:VPAIDEvent):void {
				if (!externalInterfaceIsAvailable()) {					
					return;
				}
				
				var injectTag:String = 
					"var tag = document.createElement('script');"
					+ "tag.type = \"text/javascript\";" 
					+ "tag.src = \"" + tagUrl + "\";" 
					+ "document.body.insertBefore(tag, document.body.firstChild);";					
									
				ExternalInterface.call("eval", injectTag);				
			  };
		}

		/**
		 * Register to VPAID and OVV events
		 * @param	vpaidEventsDispatcher object that exposes VPAID events
		 */
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
		
		/**
		 * Handle an OVV event by publishing it to JavaScript
		 * @param	event the OVV event to handle
		 */
		private function handleOVVEvent(event:OVVEvent):void 
		{					
			publishToJavascript(event.type, null, event.data);	
		}

		/**
		 * Handle VPAID event by publishing it to JavaScript.
		 * In case when the event is AdVideoComplete the internal interval that measures the asset will be stopped
		 * @param	event the VPAID event to handle
		 */
		public function handleVPaidEvent(event:VPAIDEvent):void
		{					
			var ovvData:OVVCheck = checkViewability();
			
			switch(event.type){
				case VPAIDEvent.AdVideoComplete:
					// stop time on ad completion
					_intervalTimer.stop();
					_intervalTimer.removeEventListener(TimerEvent.TIMER, onIntervalCheck);
					_intervalTimer = null;
					break;
				default:
					// do nothing
			}
			
			publishToJavascript(event.type, event.data, ovvData);
		}		
		
		/**
		 * Publish the event to JavaScript using PubSub in $ovv
		 * @param	eventType
		 * @param	vpaidData
		 * @param	ovvData
		 */
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
		
		private function raiseImpression(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVImpression, ovvData));
			_impressionEventRaised = true;
		}

		private function raiseLog(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVLog, ovvData));
		}

		private function raiseError(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVError, ovvData));
		}
    }
}