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

    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.display.StageDisplayState;
    import flash.events.Event;
	import flash.events.IEventDispatcher
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;
    import flash.utils.setTimeout;
    import org.openvv.OVVConfig;
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
        //   CONSTANTS NOT COVERED IN OVVConfig
        ////////////////////////////////////////////////////////////
        /**
         * Hold OVV version. Will pass to JavaScript as well as $ovv.version
         */
        public static const RELEASE_VERSION: String = "1.3.9";
        /** Changes in v1.3.9 :
         * ADS-655 : Round top/left position of Flash beacons, continually update background of MozPaintBeacons
         */
       /** Changes in v1.3.8 :
         * Fixed geometry-breaking bug introduced in AD-1854 : StickyAds solution
         * Added more functionality to build.xml to facilitate debugging OVVAsset.js in browser Developer Tools
        /** Changes in v1.3.7 :
         * AD-1912 : Merged and enhanced functionality of AD-1832 & AD-1802
         */
        /** Changes in v1.3.6 :
         * AD-1832 : try / catch javascript 'eval'
         */
        /** Changes in v1.3.5 :
         - AD-1854 : StickyAds solution
         */
        /** Changes in v1.3.4 :
         - AD-1786 : Firefox Browser detection was failing : Test for valid window.mozPaintCount instead of Browser ID
         */
        /** Changes in v1.3.3 :
         -  Support VPAID 1.x (use first valid value of 'adRemainingTime' instead of adDuration
            to calculate minimum viewable time as a percentage of total ad duration.)
         -  Added workaround for 3rd party proxied VPAID ads that do not implement VPAID.adVolume correctly (eg Innovid)
         -  Initialized check.percentObscured to 0 for use in check.percentViewable calculation, if no obscuring element
            is detected.

        /**
         * The Viewability Standard to be applied. Currently only "MRC" and "GROUPM" supported.
         */
        private static var standard:String = "MRC"; // initialize to default standard

        /**
         * The number of 'checkViewability()' polls, returning a result with viewableState == VIEWABLE
         * required before the 'OVVImpression' event will be dispatched (varies depending on standard)
         */
        public static var VIEWABLE_IMPRESSION_THRESHOLD: Number = NaN; // initialize to NaN so standards requiring a percentage of duration can adjust when duration is reported.

        /**
         * The number of consecutive intervals of unmeasurability required before
         * the 'OVVImpressionUnmeasurable' event will be fired (1 second)
         */
        public static const UNMEASURABLE_IMPRESSION_THRESHOLD: Number = 5;

        // Moved declaration out of constructor and made 'protected'
        // to allow access by subclass, if required.
        protected var ovvAssetSource: String = "{{OVVAssetJS}}";

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES
        ////////////////////////////////////////////////////////////

        /**
         * Holds repository latest commit number
         */
        public static var _buildVersion: String = OVVVersion.getVersion();

		/**
         * Whether the asset has dispatched the DISCERNABLE_IMPRESSION event
         */
        private var _hasDispatchedDImp: Boolean = false;

        /**
         * Variable to flag when a valid duration has been reported and used in the calculation of
         * VIEWABLE_IMPRESSION_THRESHOLD, when the viewability standard specifies minimum viewable
         * time as a percentage of the ad duration.
         * */
        private var _validDurationReported:Boolean = false;

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
         * The number of consecutive intervals in which the asset has been
         * unmeasurable. Reset to 0 when the asset is found to be measurable.
         */
        private var _intervalsUnMeasurable: Number;

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
		* Indicate whether the ImpressionUnmeasurable event was raised
		*/
		private var _impressionUnmeasurableEventRaised: Boolean = false;

		/**
		* Flag to record javascript  initialization error
		*/
		private var _jsInitError: String = null;

		/**
		 * A array of all VPAID events
		 */
		private static const VPAID_EVENTS:Array = ([VPAIDEvent.AdLoaded, VPAIDEvent.AdClickThru, VPAIDEvent.AdExpandedChange,
			VPAIDEvent.AdImpression, VPAIDEvent.AdLinearChange, VPAIDEvent.AdLog, VPAIDEvent.AdPaused, VPAIDEvent.AdPlaying,
			VPAIDEvent.AdStarted,VPAIDEvent.AdStopped, VPAIDEvent.AdUserAcceptInvitation,  VPAIDEvent.AdUserClose, VPAIDEvent.AdUserMinimize, VPAIDEvent.AdVideoComplete,
			VPAIDEvent.AdVideoFirstQuartile, VPAIDEvent.AdVideoMidpoint, VPAIDEvent.AdVideoThirdQuartile, VPAIDEvent.AdVolumeChange, VPAIDEvent.AdSkipped,
			VPAIDEvent.AdSkippableStateChange, VPAIDEvent.AdSizeChange, VPAIDEvent.AdDurationChange,
			VPAIDEvent.AdInteraction, VPAIDEvent.AdVideoStart]);

		/**
		 * A vector of all OVV events that may be published to javascript.
         * (Do not include OVVJsInitError as the 'publish()' method will likely not be
         * available in the javascript if this Event is dispatched.
		 */
		private static const OVV_EVENTS:Array = ([OVVEvent.OVVError,OVVEvent.OVVLog, OVVEvent.OVVImpression,
			OVVEvent.OVVImpressionUnmeasurable, OVVEvent.OVVReady]);

		private var _vpaidEventsDispatcher:IEventDispatcher = null;
		/**
	     * Reference to the ad
         */
	    private var _ad:*;
        /**
         * Reference to the vpaid ad
         */
        private var _vpaidAd:*;

        private var _isPaused: Boolean = false;
		/**
		 * True if VPAID AdImpression event has been received
		 */
		private var adStarted:Boolean;
		/**
		 * True if JS is ready, and beacons are loaded if needed.
		 */
		private var jsReady:Boolean;


       private var initErrorReason:String = null;

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
         * @param adRef A reference to the top DisplayObject of the ad; used
         * to determine full-screen status when player's stage is not available.
         * Optional only for backwards compatibility.
         * @param viewabilityStandard /the viewability Standard to be applied to
         * determine if a Viewable Impression should be fired.
         * (Currently only 'MRC' and 'GROUPM' supported).
         */
        public function OVVAsset( beaconSwfUrl:String = null, id:String = null, adRef:* = null, viewabilityStandard:String = null) {
            if (!externalInterfaceIsAvailable()) {
                _jsInitError = OVVCheck.NO_EXTERNAL_INTERFACE;
                raiseError({error:OVVCheck.NO_EXTERNAL_INTERFACE}, true); // delay dispatch for ad unit to add listener
                return;
            }
            if (viewabilityStandard == null) {
                standard = OVVConfig.default_standard;
            }else{
                standard = viewabilityStandard;
            }

            _id = (id !== null) ? "ovv" + id.replace(/([^a-z0-9]+)/gi, '') : "ovv" + Math.floor(Math.random() * 1000000000).toString();
            ////////  ????  ///////////////
            if ( !!adRef ) {
                _ad = adRef as DisplayObject;
            }
            setStage();
            ////////  ????  ///////////////

            ExternalInterface.addCallback(_id, flashProbe);
            ExternalInterface.addCallback("onJsReady" + _id, onJsReady);
            ExternalInterface.addCallback("trace", jsTrace);

            _sprite = new Sprite();
            _renderMeter = new OVVRenderMeter(_sprite);
            _sprite.addEventListener(OVVThrottleType.THROTTLE, onThrottleEvent);

            ovvAssetSource = ovvAssetSource
                                .replace(/OVVID/g, _id)
                                .replace(/INTERVAL/g, OVVConfig.viewability[standard].poll_interval_ms)
                                .replace(/MIN_VIEW_AREA_PC/g, OVVConfig.viewability[standard].min_viewable_area_pc)
                                .replace(/OVVBUILDVERSION/g, _buildVersion)
								.replace(/OVVRELEASEVERSION/g, RELEASE_VERSION);

		    if (beaconSwfUrl)
			{
				ovvAssetSource = ovvAssetSource.replace(/BEACON_SWF_URL/g, beaconSwfUrl);
			}

            var evalResult:String = String( ExternalInterface.call( "eval", ovvAssetSource ) );

            if ( evalResult == null || evalResult != OVVCheck.INIT_SUCCESS){
                 _jsInitError = evalResult || OVVCheck.REASON_INIT_ERROR_OTHER;
                 raiseError({error:_jsInitError}, true);
            }
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

        protected function get _ovvAssetSource():String {
            return "{{OVVAssetJS}}";
        }
	/**
	 * Register to the vpaidEventsDispatcher VPAID's events and allows 3rd parties to more easily provide video viewability measurement
	 * by exposing the VPAID data as well as the viewability data via a JavaScript API.
	 * @param	vpaidEventsDispatcher object that exposes VPAID events
	 */
	public function initEventsWiring(vpaidEventsDispatcher:IEventDispatcher): void {
		if (vpaidEventsDispatcher == null)
			throw "You must pass an EventDispatcher to init event wiring";
		registerEventHandler(vpaidEventsDispatcher);
		_vpaidEventsDispatcher = vpaidEventsDispatcher;

        if ((Object)(vpaidEventsDispatcher).hasOwnProperty('getVPAID') && vpaidEventsDispatcher['getVPAID']  is Function) {
            _vpaidAd = (Object)(_vpaidEventsDispatcher).getVPAID();
        }else if ((Object)(vpaidEventsDispatcher).hasOwnProperty('handshakeVersion') && vpaidEventsDispatcher['handshakeVersion']  is Function) {
            _vpaidAd = _vpaidEventsDispatcher;
        }

        if ( OVVConfig.viewability[standard].min_viewable_time_sec != null ){
            VIEWABLE_IMPRESSION_THRESHOLD = Math.floor(1000 * OVVConfig.viewability[standard].min_viewable_time_sec / OVVConfig.viewability[standard].poll_interval_ms );
        }
	}

    private function updateThresholdByPercentDuration():void{
        // Called from onIntervalCheck(), when min viewable time is specified as
        // a percentage of ad duration, until a valid duration is calculated.

        var duration:int = 15; // Use a default value of 15s until the actual duration is determined.
        if (_vpaidAd.hasOwnProperty("adDuration") && _vpaidAd.adDuration != -2) {
            // vpaid 2.x
            if ( _vpaidAd.adDuration > 0 ) {
                duration = _vpaidAd.adDuration;
                _validDurationReported = true;
            }
        }else{
            //vpaid 1.x

            if ( _vpaidAd.adRemainingTime > 0 ){
                duration = _vpaidAd.adRemainingTime;
                _validDurationReported = true;
            }
        }
        var min_time_sec:int = Math.floor(duration * OVVConfig.viewability[standard].min_viewable_time_pc / 100);

        VIEWABLE_IMPRESSION_THRESHOLD = Math.floor(1000 * min_time_sec / OVVConfig.viewability[standard].poll_interval_ms);
    }


	/**
	 * Add a JavaScript resource upon receiving a given vpaidEvent
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
            if ( _jsInitError ) {
                return new OVVCheck(
                    {
                        viewabilityState: OVVCheck.UNMEASURABLE,
                        viewabilityStateReason:_jsInitError
                    }
                );
            }

            var jsResults: Object = ExternalInterface.call("$ovv.getAssetById('" + _id + "')" + ".checkViewability");
            var results: OVVCheck = new OVVCheck(jsResults);

            if (results && !!results.error)
                raiseError(results);

            results.volume = 1; // default to 1, in case not implemented or not available (eg in Innovid VPAID)
            if (_vpaidAd != null){
                if ( _vpaidAd.hasOwnProperty('adVolume') && !isNaN(_vpaidAd['adVolume']) ){
                    if (_vpaidAd['adVolume'] > -1){
                        results.volume = _vpaidAd['adVolume'];
                    }
                }
            }

            var displayState:String = getDisplayState(results);
            // StageDisplayState.FULL_SCREEN_INTERACTIVE is available >= Flash Player 11.3
            if (displayState == StageDisplayState.FULL_SCREEN || displayState == 'fullScreenInteractive') {
                results.displayState = displayState;
                results.viewabilityState = OVVCheck.VIEWABLE;
                results.viewabilityStateOverrideReason = OVVCheck.FULLSCREEN;

                if (results.technique == OVVCheck.GEOMETRY) {
                    results.percentViewable = 100;
                }
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
         * When the JavaScript portion of OpenVV is ready and the beacons have loaded (if needed),
         * this function is called so that the ad can wait for the beacons to load before dispatching AdLoaded
         */
        public function onJsReady(): void {
            trace("JS READY!")
            jsReady = true;
            if ( adStarted ) {
                startImpressionTimer();
            }
            raiseReady();
        }
        public function jsTrace(obj:Object): void {
            // Debug.traceObj(obj);
        }

        /**
		 * Ready state from the JS code, including beacons.
		 * @return
		 */
		public function get isJsReady():Boolean {
			return jsReady;
		}
		/**
         * When the VPAID AdImpression event is received, it triggers this function
         * to start the interval timer which does viewability checks every 200ms (POLL_INTERVAL)
         */
        public function startImpressionTimer(): void {
            if (!_intervalTimer) {
                _intervalsInView = 0;
                _intervalsUnMeasurable = 0;

                _intervalTimer = new Timer(OVVConfig.viewability[standard].poll_interval_ms);
                _intervalTimer.addEventListener(TimerEvent.TIMER, onIntervalCheck);
                _intervalTimer.start();
            }
        }

        public function stopImpressionTimer(): void {
            // stop time on ad completion
            if (_intervalTimer != null) {
                _intervalTimer.stop();
                _intervalTimer.removeEventListener(TimerEvent.TIMER, onIntervalCheck);
                _intervalTimer = null;
            }
        }

        private function setStage(evt:Event = null):void
        {

            if(!_ad) return;

            _ad.removeEventListener(Event.ADDED_TO_STAGE, setStage);
            try{
                _stage = _ad.stage;
            }
            catch(ignore:Error){
                //stage is inaccessible
            }
            if(!_stage)
                _ad.addEventListener(Event.ADDED_TO_STAGE, setStage);
        }

        private function getDisplayState(results:OVVCheck):String
        {
            var hasStageAccess:Boolean;
            var displayState:String = StageDisplayState.NORMAL;

            try{
                displayState   = _stage.displayState;
                hasStageAccess = true;
            }
            catch(ignore:Error){
                // Either stage was null or we can't access it due to security
                // restrictions, either way we can ignore this error
            }


            if(!hasStageAccess && _ad && (_ad is DisplayObject))
            {
                if ((_ad.width - (results.objRight - results.objLeft)) > 10 && (_ad.height - (results.objBottom - results.objTop)) > 10) {
                    displayState = StageDisplayState.FULL_SCREEN;
                }
            }
            return displayState;
        }

        ////////////////////////////////////////////////////////////
        //   EVENT HANDLERS
        ////////////////////////////////////////////////////////////

        /**
         * Every INTERVAL ms, check to see if asset is visible. If the asset
         * is viewable for VIEWABLE_IMPRESSION_THRESHOLD intervals, dispatch
         * the Viewable Impression Event.
         *
         * @param event The TimerEvent which signals the end of this interval
         *
         */
        private function onIntervalCheck(event: TimerEvent): void {
            var results: Object = checkViewability();

			raiseLog(results);

            if (_isPaused == false) {
                if ( OVVConfig.viewability[standard].min_viewable_time_pc != null && _validDurationReported == false ) {
                    // May change during the course of the ad so update with each poll.
                    updateThresholdByPercentDuration();
                }

                var unmeasurable:Boolean = results.viewabilityState == OVVCheck.UNMEASURABLE;

                var viewable:Boolean =  results.viewabilityState == OVVCheck.VIEWABLE &&
                                        volumeOk(results) &&
                                        focusOk(results);

                _intervalsUnMeasurable = unmeasurable ? _intervalsUnMeasurable + 1 : 0;
                if (viewable) {
                    _intervalsInView += 1;
                }else if (OVVConfig.viewability[standard].viewable_polls_consecutive){
                    _intervalsInView = 0;
                }

                if (_impressionEventRaised == false && _intervalsInView >= VIEWABLE_IMPRESSION_THRESHOLD) {
                    raiseImpression(results);
                }else if (_impressionUnmeasurableEventRaised == false &&
                            _intervalsUnMeasurable >= UNMEASURABLE_IMPRESSION_THRESHOLD) {
                    raiseImpressionUnmeasurable(results);
                }
            }
        }

        private function volumeOk(results:Object):Boolean {
            if (OVVConfig.viewability[standard].volume_required){
                return results.volume > 0;
            }else{
                return true;
            }
        }

        private function focusOk(results:Object):Boolean {
            if (results.viewabilityStateOverrideReason == OVVCheck.FULLSCREEN){
                return true;
            }else{
                return results.focus == true;
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
			 return function(event:Event):void {
				if (!externalInterfaceIsAvailable()) {
					return;
				}

				var injectTag:String =
					'function () {' +
					'var tag = document.createElement("script");' +
                    'tag.src = "' + tagUrl.replace(/"/g, '%22') + '";' +
					'tag.type="text/javascript";' +
					'document.getElementsByTagName("body")[0].appendChild(tag); }';
				ExternalInterface.call( injectTag );
			  };
		}

		/**
		 * Register to VPAID and OVV events
		 * @param	vpaidEventsDispatcher object that exposes VPAID events
		 */
		private function registerEventHandler(vpaidEventsDispatcher:IEventDispatcher):void
		{
			// Register to VPAID events
			var eventType:String;

			for each (eventType in VPAID_EVENTS)
			{
				vpaidEventsDispatcher.addEventListener(eventType, handleVpaidEvent);
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
		 * In case when the event is AdImpression the internal interval that measures the asset will be started
		 * In case when the event is AdVideoComplete the internal interval that measures the asset will be stopped
		 * @param	event the VPAID event to handle
		 */
		public function handleVpaidEvent(event:Event):void
		{
			var ovvData:OVVCheck = checkViewability();
			switch(event.type){
				case VPAIDEvent.AdVideoComplete:
                    stopImpressionTimer();
					break;
				case VPAIDEvent.AdImpression:
					adStarted = true;
					if ( jsReady  && !_jsInitError ) {
						startImpressionTimer();
					}
					break;
				case VPAIDEvent.AdPaused:
					_isPaused = true;
					break;
				case VPAIDEvent.AdPlaying:
					_isPaused = false;
					break;
				default:
					// do nothing
					break;
			}

			publishToJavascript(event.type, getEventData(event), ovvData);
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

		private function getEventData(event:Event):Object
		{
			var data:Object;

			try
			{
				data = event['data'];
			}
			catch (e:ReferenceError)
			{
				data = null;
			}

			return data;
		}
		private function raiseReady():void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVReady, null));
		}
		private function raiseImpression(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVImpression, ovvData));
			_impressionEventRaised = true;
		}

		private function raiseImpressionUnmeasurable(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVImpressionUnmeasurable, ovvData));
			_impressionUnmeasurableEventRaised = true;
		}

		private function raiseLog(ovvData:*):void
		{
			dispatchEvent(new OVVEvent(OVVEvent.OVVLog, ovvData));
		}

		private function raiseError(ovvData:*, delay:Boolean = false):void
		{
            setTimeout(function():void{
                dispatchEvent(new OVVEvent(OVVEvent.OVVError, ovvData));
            },delay?200:0);
        }
    }
}
