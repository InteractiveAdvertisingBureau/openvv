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
    import flash.events.Event;
    import flash.utils.getTimer;

    /**
     * OVVRenderMeter measures the difference between ENTER_FRAME events to
     * determine the frame rate of the asset being measured.
     */
    public class OVVRenderMeter {

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES 
        ////////////////////////////////////////////////////////////

        /**
         * A DisplayObject to listen for ENTER_FRAME events on
         */
        private var _displayObject: DisplayObject;

        /**
         * The most recent frame rate of the asset
         */
        private var _fps: Number = 0;

        /**
         * The time that the last ENTER_FRAME event occurred
         * @see flash.utils.getTimer() [http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/utils/package.html#getTimer()]
         */
        private var _lastFrameTime: Number = -1;

        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR 
        ////////////////////////////////////////////////////////////

        /**
         * Sets up the ENTER_FRAME event listener on the DisplayObject passed
         * in.
         *
         * @param displayObject A DisplayObject to listen for ENTER_FRAME
         * events on
         */
        public function OVVRenderMeter(displayObject: DisplayObject) {
            _displayObject = displayObject;
            _displayObject.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }

        ////////////////////////////////////////////////////////////
        //   PUBLIC API 
        ////////////////////////////////////////////////////////////

        /**
         * Frees resources used by this class
         */
        public function dispose(): void {
            if (_displayObject) {
                _displayObject.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                _displayObject = null;
            }
        }

        ////////////////////////////////////////////////////////////
        //   EVENT HANDLERS 
        ////////////////////////////////////////////////////////////

        /**
         * Measures the time between the last two ENTER_FRAME events to
         * determine a frame rate
         *
         * @param event The latest ENTER_FRAME event
         */
        private function onEnterFrame(event: Event): void {
            if (_lastFrameTime == -1) {
                _lastFrameTime = getTimer();
                return;
            }

            var elapsedTime: Number = getTimer() - _lastFrameTime;
            _fps = (1 / (elapsedTime / 1000));
            _lastFrameTime = getTimer();
        }

        ////////////////////////////////////////////////////////////
        //   GETTERS / SETTERS 
        ////////////////////////////////////////////////////////////

        /**
         * The most recent frame rate of the asset
         */
        public function get fps(): Number {
            return _fps;
        }
    }
}