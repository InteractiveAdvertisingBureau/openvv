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

        // NEW : Reasons for instantaneous Unviewability or Unmeasurability (passed in viewabilityStateInfo)
        public static const INIT_SUCCESS:String = "SUCCESS";

        // Parts that the 'info' code, loaded into the viewabilityStateInfo property, are composed of.
        //
        // the viewabilityStateInfo property will be composed of the following parts, separated by underscores:
        // 'type' - a single digit code representing the type of the result :
        //      'V' : Viewable
        //      'N' : Not Viewable
        //      'U' : Unmeasureable
        //      'E' : Error
        //
        // 'method' - In the case of type 'V' or 'N' result : a 2-digit code representing he method used to measure the result:
        //      Methods that can measure Viewable or Not Viewable :
        //         'BG' : browser geometry
        //         'FB' : Flash Beacons
        //         'MB' : MozPaintCount beacons
        //      Methods that can only determine Not Viewable :
        //         'WI' : Window Inactive (minified browser window or inactive browser tab)
        //         'VS' : Visibility - player element has or inherits 'visibility' attribute set to 'hidden'
        //         'DS' : Display - player element has or inherits 'display' attribute set to 'none'
        //         'OB' : Obscured - player element is obscured by an other DOM element in the same Document
        //      Method that can only measure Viewable :
        //         'FS' : Overrides any Viewable / Not Viewable / Unmeasureable or Error result to return Viewable
        //
        // 'error' - In the case of 'E' or 'U' result : a 2-digit code representing the reason for the error or unmeasureabiliy.
        //         'XI' : No ExternalInterface available
        //         'JN' : Javascript Eval returned null
        //         'JE' : Javascript Eval error
        //         'NP' : No Player found
        //         'BU' : Bad Flash Beacon Url
        //         'NM' : No measurement method available
        //         'CN' : Control Beacon not ready
        //         'CV' : Control Beacon in view
        //         'BN' : Beacons not ready
        //         'BI' : Invalid combination of beacon viewable and notviewable results
        //         'IV' : Invalid Viewport
        //         'E?' : Init Error Other

        // Example 'info' codes:
        // 'E_BN'   : Beacons not ready
        // 'U_NM'   : Unmeasurable - No Measuring method available
        // 'V_BG'   : Measured Viewable, using Browser Geometry method
        // 'N_MB'   : Measured Not Viewable, using MozPaintCount Beacons method

        public static const INFO_TYPE_ERROR:String        = "E";
        public static const INFO_TYPE_VIEWABLE:String     = "V";
        public static const INFO_TYPE_NOT_VIEWABLE:String = "N";
        public static const INFO_TYPE_UNMEASURABLE:String = "U";

        public static const INFO_METHOD_BROWSER_GEOMETRY:String  = "BG";
        public static const INFO_METHOD_BEACON_FLASH:String      = "FB";
        public static const INFO_METHOD_BEACON_MOZPAINT:String   = "MB";
        public static const INFO_METHOD_ACTIVE_WINDOW:String     = "WI";
        public static const INFO_METHOD_PLAYER_VISIBILITY:String = "VS";
        public static const INFO_METHOD_PLAYER_DISPLAY:String    = "DS";
        public static const INFO_METHOD_PLAYER_OBSCURED:String   = "OB";
        public static const INFO_METHOD_FULL_SCREEN_OVERRIDE:String = "FS";

        public static const INFO_ERROR_NO_EXTERNAL_INTERFACE:String   = "XI";
        public static const INFO_ERROR_INIT_JS_EVAL_NULL:String       = "JN";
        public static const INFO_ERROR_INIT_JS_EVAL_ERROR:String      = "JE";
        public static const INFO_ERROR_PLAYER_NOT_FOUND:String        = "NP";
        public static const INFO_ERROR_BAD_BEACON_URL:String          = "BU";
        public static const INFO_ERROR_NO_MEASURING_METHOD:String     = "NM";
        public static const INFO_ERROR_CTRL_BEACON_NOT_READY:String   = "CN";
        public static const INFO_ERROR_CTRL_BEACON_IN_VIEW:String     = "CV";
        public static const INFO_ERROR_BEACONS_NOT_READY:String       = "BN";
        public static const INFO_ERROR_INVALID_BEACON_RESULT:String   = "BI";
        public static const INFO_ERROR_INVALID_VIEWPORT_RESULT:String = "IV";
        public static const INFO_ERROR_INIT_ERROR_OTHER:String        = "I?";
/*
        public static const INFO_OS_MAC:String = "OM";
        public static const INFO_OS_WIN:String = "OW";
        public static const INFO_OS_LIN:String = "OL";
        public static const INFO_OS_IOS:String = "OI";
        public static const INFO_OS_OTHER:String = "O?";

        public static const INFO_BROWSER_CHROME:String = "BC";
        public static const INFO_BROWSER_FIREFOX:String = "BF";
        public static const INFO_BROWSER_SAFARI:String = "BS";
        public static const INFO_BROWSER_IE:String = "BI";
        public static const INFO_BROWSER_OPERA:String = "BO";
        public static const INFO_BROWSER_OTHER:String = "B?";

        public static const INFO_IFRAME_NONE:String = "F0";
        public static const INFO_IFRAME_SD:String = "FS";
        public static const INFO_IFRAME_XD:String = "FX";
*/


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
        public var inIframe:   Boolean = false;
        public var inXDIframe: Boolean = false;
        public var frameEnv:   String;

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
        public var viewabilityStateInfo: String;

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

        public var obj:Object;
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
            obj = jsCheck;
            for (var field: String in jsCheck) {
                if (this.hasOwnProperty(field)) {
                    this[field] = jsCheck[field];
                }else{
                    trace("jsCheck property : '" + field + "' not found on OVVCheck : cannot transfer to ad unit")
                }
            }
        }
    }
}