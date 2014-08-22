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
package org.openvv.events {

    import flash.events.Event;

    /**
     * An Event dispatched from OVVAsset.
     *
     * @see org.openvv.OVVAsset
     */
    public class OVVEvent extends Event {

        ////////////////////////////////////////////////////////////
        //   CONSTANTS 
        ////////////////////////////////////////////////////////////
		/**
		 * Events of this type represent OVVAsset is ready and all beacons have loaded (if needed)
		 */
		public static const OVVReady: String = "OVVReady";
        /**
         * Events of this type represent an error that has occurred
         */
        public static const OVVError: String = "OVVError";

        /**
         * Events of this type represent 2 seconds of contiguous viewability have occurred
         */
        public static const OVVImpression: String = "OVVImpression";

        /**
         * Events of this type represent when viewability is unmeasurable
         */
        public static const OVVImpressionUnmeasurable: String = "OVVImpressionUnmeasurable";

        /**
         * Events of this type represent informational logging messages
         */
        public static const OVVLog: String = "OVVLog";

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES 
        ////////////////////////////////////////////////////////////

        /**
         * An optional object containing additional information
         */
        private var _data: Object;

        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR 
        ////////////////////////////////////////////////////////////

        /**
         * Creates an OVVEvent.
         *
         * @param type What this event represents
         * @param data Optional, additional data
         * @param bubbles Whether to bubble up the display list or not
         * @param cancelable Whether the event can be cancelled or not
         *
         */
        public function OVVEvent(type: String, data: Object = null, bubbles: Boolean = false, cancelable: Boolean = false) {
            super(type, bubbles, cancelable);
            _data = data;
        }

        ////////////////////////////////////////////////////////////
        //   GETTERS / SETTERS 
        ////////////////////////////////////////////////////////////

        /**
         * An optional object containing additional information
         *
         * @return A generic object, or null
         */
        public function get data(): Object {
            return _data;
        }
    }
}