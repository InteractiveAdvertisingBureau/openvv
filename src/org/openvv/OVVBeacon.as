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
    import flash.system.Security;

    /**
     * <p>
     * OVVBeacon is a SWF which sits on top of an asset and measures whether
     * the asset is viewable to the user at that particular location. In
     * production mode (when OVV.DEBUG is false in JavaScript), beacons are
     * invisible 1x1 pixels. In debug mode, they are 20x20 and color coded
     * to show their status.
     * </p><p>
     * Viewability of a beacon is determined by querying the latest
     * ThrottleEvent received by the beacon, or if no ThrottleEvents have been
     * received, the frame rate of the beacon is used.
     * </p>
     *
     * @see org.openvv.OVVRenderMeter
     * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/ThrottleEvent.html flash.events.ThrottleEvent
     */
    [SWF(height = "1", width = "1", frameRate = "24")]
    public final class OVVBeacon extends Sprite {

        ////////////////////////////////////////////////////////////
        //   CONSTANTS 
        ////////////////////////////////////////////////////////////

        /**
         * The background color when the beacon is visible
         */
        public static const GREEN: uint = 0x00FF00;

        /**
         * The background color when the beacon isn't visible
         */
        public static const RED: uint = 0xFF0000;

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES 
        ////////////////////////////////////////////////////////////

        /**
         * Set by JavaScript, determines whether to draw a colored background
         * or not
         */
        private var _debug: Boolean = false;

        /**
         * The unique ID of the asset that the beacon is associated with
         */
        private var _id: String;

        /**
         * The beacon's index within the set of beacons associated with
         * the beacon's asset
         */
        private var _index: int;

        /**
         * A class that measures the latest frame rate of the beacon
         */
        private var _renderMeter: OVVRenderMeter;

        /**
         * The state of the last ThrottleEvent received by the beacon
         */
        private var _throttleState: String;

        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR 
        ////////////////////////////////////////////////////////////

        /**
         * Stores values from FlashVars and sets up event listeners.
         */
        public function OVVBeacon() {
            super();

            Security.allowDomain("*");

            _id = loaderInfo.parameters.id;
            _index = loaderInfo.parameters.index;

            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            addEventListener("throttle", onThrottle);
        }

        ////////////////////////////////////////////////////////////
        //   PUBLIC API 
        ////////////////////////////////////////////////////////////

        /**
         * By setting OVV.DEBUG to true in JavaScript, JavaScript will call
         * this function which enables coloring of the beacon's
         * background according to viewability status
         */
        public function debug(): void {
            _debug = true;
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        /**
         * Returns the frame rate of the beacon
         * @return The frame rate of the beacon
         */
        public function getFrameRate(): int {
            return _renderMeter.fps;
        }

        /**
         * Returns the throttle state of the beacon
         * @return The throttle state of the beacon
         */
        public function getThrottleState(): String {
            return _throttleState;
        }

        /**
         * Returns whether the beacon is viewable or not
         * @return whether the beacon is viewable or not
         */
        public function isViewable(): Boolean {
            var viewable: Boolean;

            if (_throttleState != null) {
                viewable = (_throttleState == OVVThrottleType.RESUME);
            } else {
                viewable = _renderMeter.fps > 8
            }

            return viewable;
        }

        ////////////////////////////////////////////////////////////
        //   EVENT HANDLERS 
        ////////////////////////////////////////////////////////////

        /**
         * Starts the RenderMeter, which won't be ready until the next
         * ENTER_FRAME event
         * @param event an ADDED_TO_STAGE event
         *
         */
        protected function onAddedToStage(event: Event): void {
            addEventListener(Event.ENTER_FRAME, onFirstFrame);
            _renderMeter = new OVVRenderMeter(this);
        }

        /**
         * When in debug mode, redraws the background each frame
         *
         * @param event an ENTER_FRAME event
         *
         */
        protected function onEnterFrame(event: Event): void {
            drawBackground();
        }

        /**
         ** Sets up JavaScript callbacks and lets the JavaScript portion of OVV
         * know that this beacon is ready
         * @param event an ENTER_FRAME event
         */
        protected function onFirstFrame(event: Event): void {
            removeEventListener(Event.ENTER_FRAME, onFirstFrame);

            ExternalInterface.addCallback("isViewable", isViewable);
            ExternalInterface.addCallback("debug", debug);
            ExternalInterface.addCallback("getThrottleState", getThrottleState);
            ExternalInterface.addCallback("getFrameRate", getFrameRate);

            if (_id && _index) {
                ExternalInterface.call("$ovv.getAssetById('" + _id + "')" + ".beaconStarted", _index);
            }
        }

        /**
         * Updates the throttle state of the beacon
         * @param event The ThrottleEvent received. Note that this event is
         * untyped to prevent VerifyErrors when compiled into assets targeting
         * less than Flash Player 11.
         */
        protected function onThrottle(event: Event): void {
            _throttleState = event['state'];
        }

        ////////////////////////////////////////////////////////////
        //   PRIVATE METHODS 
        ////////////////////////////////////////////////////////////

        /**
         * When debug is enabled, colors the background of the beacon
         * according to it's last known status
         *
         * @see RED
         * @see GREEN
         */
        private function drawBackground(): void {
            var color: uint = isViewable() ? GREEN : RED;
            graphics.clear();
            graphics.beginFill(color, 1.0);
            graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
            graphics.endFill();
        }
    }
}