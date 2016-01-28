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
    /**
     * OVVCheck is a container for properties about the current viewability
     * state of an OVVAsset. The fps and focus properties are determined by
     * ActionScript, and will be their default values in the Object
     * returned from JavaScript.
     */
    public class OVVCheck {

        ////////////////////////////////////////////////////////////
        //   CONSTANTS 
        ////////////////////////////////////////////////////////////

        /**
         * When OVVCheck.technique is set to BEACON, the beacon technique
         * was used to determine the viewabilityState
         */
        public static const BEACON: String = "beacon";

        /**
         * A string used to indicate that the viewabilityState reported
         * by JavaScript was overridden by ActionScript due to the
         * asset being in fullscreen
         *
         * @see #viewabilityStateOverrideReason
         */
        public static const FULLSCREEN:String = "fullscreen"

        /**
         * When OVVCheck.technique is set to GEOMETRY, the geometry technique
         * was used to determine the viewabilityState
         */
        public static const GEOMETRY: String = "geometry";

        /**
         * OVVCheck.technique is set to CSS_VISIBILITY when a property value of
         * 'visibility:hidden' or 'display:none' on the player's embed object,
         * or on any containing element in the same javascript domain (page or iframe)
         * is used to determine that viewability state is OVVCheck.UNVIEWABLE
         */
        public static const CSS_VISIBILITY: String = "css_visibility";

        /**
         * OpenVV was unable to determine whether the asset was viewable or not
         */
        public static const UNMEASURABLE: String = 'unmeasurable';

        /**
         * Less than 50% of the asset is viewable within the viewport
         */
        public static const UNVIEWABLE: String = 'unviewable';

        /**
         * At least 50% of the asset is viewable within the viewport
         */
        public static const VIEWABLE: String = 'viewable';

        // NEW : Reasons for instantaneous Unviewability or Unmeasurability (passed in viewabilityStateReason)

        public static const INIT_SUCCESS:String = "SUCCESS";

        // =============  Javascript Initialization Errors  =============

        /**
         * Unmeasurable : External Interface not available (not required in OVVCheck javascript class)
         */
        public static const NO_EXTERNAL_INTERFACE:String = 'EX';

        /**
         * Unmeasurable by reason of OVV Init unspecified javascript runtime error
         */
        public static const REASON_INIT_ERROR_OTHER:String = 'E0';

        /**
         * Unmeasurable by reason of OVV Init player not found
         */
        public static const REASON_PLAYER_NOT_FOUND:String = 'E1';

        /**
         * Unmeasurable by reason of OVV Init player javascript runtime error
         */
        public static const REASON_BAD_BEACON_SWF_URL:String = 'E2';

        /**
         * Unmeasurable by reason of neither geometry nor beacon measuring technique available in current browser
         */
        public static const REASON_NO_AVAILABLE_MEASURING_TECHNIQUE:String = 'E3';

        // =============  Not Viewable Reasons  =============
        /**
         * Not viewable by reason of too little area viewable measured by browser geometry (no iframe)
         */
        public static const REASON_AREA_GEOMETRY: String = 'N1';

        /**
         * Not viewable by reason of too little area viewable measured by browser geometry (in same domain iframe)
         */
        public static const REASON_AREA_IFRAME_GEOMETRY: String = 'N2';

        /**
         * Not viewable by reason of too little area viewable measured by Flash beacons
         */
        public static const REASON_AREA_FLASH_BEACONS: String = 'N3';

        /**
         * Not viewable by reason of too little area viewable measured by MozPaint beacons (in Firefox Browser)
         */
        public static const REASON_AREA_MOZPAINT_BEACONS: String = 'N4';

        /**
         * Not viewable by reason of inactive tab or minimized browser window
         */
        public static const REASON_INACTIVE_WINDOW: String = 'N5';

        /**
         * Not viewable by reason of player made invisible by manipulation of 'visibility' property
         */
        public static const REASON_PLAYER_INVISIBLE: String = 'N6';

        /**
         * Not viewable by reason of player containing element hidden by manipulation of 'display' property
         */
        public static const REASON_PLAYER_HIDDEN: String = 'N7';

        /**
         * Not viewable by reason of player obscured by another element in the DOM
         */
        public static const REASON_PLAYER_OBSCURED: String = 'N8';

        // =============  Unmeasurable Reasons  =============
        /**
         * Unmeasurable by reason of geometry not supported and can't use Flash beacons in current browser
         */
        public static const REASON_BEACONS_IN_IFRAME: String = 'U1';

        /**
         * Unmeasurable by reason of flash control beacon not ready
         */
        public static const REASON_FLASH_CONTROL_BEACON_NOT_READY: String = 'U2';

        /**
         * Unmeasurable by reason of mozpaint control beacon in view
         */
        public static const REASON_MOZPAINT_CONTROL_BEACON_NOT_READY: String = 'U3';

        /**
         * Unmeasurable by reason of flash control beacon in view
         */
        public static const REASON_FLASH_CONTROL_BEACON_IN_VIEW: String = 'U4';

        /**
         * Unmeasurable by reason of mozpaint control beacon in view
         */
        public static const REASON_MOZPAINT_CONTROL_BEACON_IN_VIEW: String = 'U5';

        /**
         * Unmeasurable by reason of flash beacons failed to initialize
         */
        public static const REASON_FLASH_ACTIVE_BEACONS_NOT_READY: String = 'U6';

        /**
         * Unmeasurable by reason of mozpaint beacons failed to initialize
         */
        public static const REASON_MOZPAINT_ACTIVE_BEACONS_NOT_READY: String = 'U7';

        /**
         * Unmeasurable by reason of flash beacons generated an invalid result
         * ('impossible' combination of viewable and unviewable beacons)
         * */
        public static const REASON_FLASH_BEACONS_INVALID_RESULT: String = 'U8';

        /**
         * Unmeasurable by reason of mozpaint beacons generated an invalid result
         * ('impossible' combination of viewable and unviewable beacons)
         * */
        public static const REASON_MOZPAINT_BEACONS_INVALID_RESULT: String = 'U9';


        /**
         * The value that {@link OVVCheck#viewabilityState} will be set to if the beacons
         * are not ready to determine the viewability state
         */
        public static const NOT_READY: String = "not_ready";

        ////////////////////////////////////////////////////////////
        //   ATTRIBUTES 
        ////////////////////////////////////////////////////////////

        /**
         * During debug mode, beaconViewabilityState is populated with the viewabilityState
         * determined by the beacon technique
         */
        public var beaconViewabilityState: String;

        /**
         * When using the beacon technique, this array will be populatd with
         * Booleans describing the viewability status of each beacon by its
         * index. True = viewable. False = unviewable. See the JavaScript
         * documentation for a description of the indices.
         */
        public var beacons: Array;

        /**
         * Whether OpenVV can use beacons to determine viewability
         */
        public var beaconsSupported: Boolean;

        /**
         * The height of the viewport currently being displayed
         */
        public var clientHeight: int = -1;

        /**
         * The width of the viewport currently being displayed
         */
        public var clientWidth: int = -1;

        /**
         * A description of an error that may have occurred
         */
        public var error: String;

        /**
         * If the tab is focused or not
         */
        public var focus: Boolean;

        /**
         * The current framerate of the asset (determined by ActionScript)
         */
        public var fps: Number = -1;

        /**
         * The display state of the asset's stage. i.e. normal or fullscreen
         * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/StageDisplayState.html
         */
        public var displayState:String;

        /**
         * Whether OpenVV can use JavaScript bounds to determine viewability
         */
        public var geometrySupported: Boolean;

        /**
         * During debug mode, geometryViewabilityState is populated with the viewabilityState
         * determined by the geometry technique
         */
        public var geometryViewabilityState: String;

        /**
         * The unique identifier of the asset
         */
        public var id: String;

        /**
         * Whether the asset is in an iframe or not
         */
        public var inIframe: Boolean = false;

        /**
         * The distance (in pixels) from the asset's bottom to the bottom of the viewport
         */
        public var objBottom: int = -1;

        /**
         * The distance (in pixels) from the asset's left side to the left side of the viewport
         */
        public var objLeft: int = -1;

        /**
         * The distance (in pixels) from the asset's right side to the right side of the viewport
         */
        public var objRight: int = -1;

        /**
         * The distance (in pixels) from the asset's top to the top of the viewport
         */
        public var objTop: int = -1;

        /**
         * How much of the asset is viewable within the viewport
         */
        public var percentViewable: int = -1;

        /**
         * The technique used to determine viewablity
         *
         * @see BEACON
         * @see GEOMETRY
         */
        public var technique: String;

        /**
         * Represents whether the asset was at least 50% viewable or if OpenVV
         * couldn't make a determination.
         *
         * @see #VIEWABLE
         * @see #UNVIEWABLE
         * @see #UNMEASURABLE
         */
        public var viewabilityState: String;

        /**
         * if viewabilityState is not VIEWABLE this property holds the
         * reason why it is either unviewable or unmeasurable
         *
         * @see #UNVIEWABLE
         * @see #UNMEASURABLE
         */
        public var viewabilityStateReason: String;

        /**
         * When the viewabilityState is changed by ActionScript detecting that
         * the asset is in fullscreen, this will be set to FULLSCREEN;
         *
         * @see #FULLSCREEN
         */
        public var viewabilityStateOverrideReason:String;

        /**
        * The asset volume
        */
        public var volume: Number = -1;

        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR 
        ////////////////////////////////////////////////////////////

        /**
         * Constructor. Takes in an Object created by JavaScript and assigns
         * its field to this object.
         *
         * @param jsCheck The OVVCheck object created by JavaScript
         *
         */
        public function OVVCheck(jsCheck: Object) {
            for (var field: String in jsCheck) {
                if (this.hasOwnProperty(field)) {
                    this[field] = jsCheck[field];
                }else{
                    trace("jsCheck property : '" + field + "' not found on OVVCheck : cannot transfer ")
                }
            }
        }
    }
}