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
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;
    
    import org.openvv.events.OVVEvent;

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
        [Embed(source = "/../js/OVVAsset.js", mimeType = "application/octet-stream")]
        public static const OVVAssetJSSource: Class;

        ////////////////////////////////////////////////////////////
        //   CONSTANTS 
        ////////////////////////////////////////////////////////////

        /**
         * The number of consecutive intervals of viewability required before
         * the VIEWABLE_IMPRESSION event will be fired (5 seconds)
         */
        public static const VIEWABLE_IMPRESSION_THRESHOLD: Number = 8;

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
         * The number of milliseconds between polling JavaScript for
         * viewability information
         */
        private var _interval:int;

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
         * The last recorded ThrottleState
         *
         * @see org.openvv.OVVThrottleType
         * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/ThrottleEvent.html
         */
        private var _throttleState: String;

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
        public function OVVAsset(beaconSwfUrl:String = null, id:String = null, interval:int = 250) {
            
			if (!externalInterfaceIsAvailable()) {
                dispatchEvent(new OVVEvent(OVVEvent.OVVError, {
                    "message": "ExternalInterface unavailable"
                }));
                return;
            }

            _id = (id !== null) ? id : "ovv" + Math.floor(Math.random() * 1000000000).toString();
            _interval = interval;

            ExternalInterface.addCallback(_id, flashProbe);
            ExternalInterface.addCallback("startImpressionTimer", startImpressionTimer);

            _sprite = new Sprite();
            _renderMeter = new OVVRenderMeter(_sprite);
            _sprite.addEventListener("throttle", onThrottleEvent);

            var ovvAssetSource: String = new OVVAssetJSSource().toString();
            ovvAssetSource = ovvAssetSource.replace(/OVVID/g, _id).replace(/INTERVAL/g, _interval);
			
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

            if (_throttleState != null) {
                results.focus = _throttleState == OVVThrottleType.RESUME;
            } else {
                results.focus = _renderMeter.fps > 8;
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

                _intervalTimer = new Timer(_interval);
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

            _intervalsInView = (results.viewabilityState == OVVCheck.VIEWABLE) ? _intervalsInView + 1 : 0;

            if (_intervalsInView >= VIEWABLE_IMPRESSION_THRESHOLD) {
                dispatchEvent(new OVVEvent(OVVEvent.OVVImpression));
                _intervalTimer.stop();
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
    }
}