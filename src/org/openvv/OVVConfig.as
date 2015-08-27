/*
*/
package org.openvv {
    public class OVVConfig {

        /**
         * A dictionary of all currently supported Video Viewability Standards and their
         * associated viewability measuring and impression firing criteria:
         */
        public static const viewability:Object = {
            "GROUPM": {min_viewable_area_pc: 100, volume_required: true, poll_interval_ms: 200, viewable_polls_consecutive: false, min_viewable_time_sec: null, min_viewable_time_pc: 50  },
            "MRC": {min_viewable_area_pc: 50, volume_required: false, poll_interval_ms: 200, viewable_polls_consecutive: true, min_viewable_time_sec: 2, min_viewable_time_pc: null }
        };

        /* The default Viewability Standard to use is no viewability_standard
         * argument is passed in the OVVAsset constructor.
         */
        private static const default_standard:String = "MRC";

        // Variables that will be set from the selected (or default) Viewability Standard parameters in :

        /**
         * Instantaneous Viewability Polling Interval in ms
         */
        public static var POLL_INTERVAL:int = 200;

        /**
         * Viewability State Measurement parameters
         * Minimum requirements for a single poll of checkViewability() to return a viewabilityState of "VIEWABLE"
         */
        public static var MIN_VIEWABLE_AREA_PC:int = 50;
        public static var VOLUME_REQUIRED:Boolean = false;

        /**
         * Viewable Impression Criteria
         *
         */
        public static var MIN_VIEWABLE_POLLS:int = 10;
        public static var VIEWABLE_POLLS_CONSECUTIVE:Boolean = true;
        /**
         * The number of consecutive intervals of unmeasurability required before
         * the UNMEASURABLE_IMPRESSION_ event will be fired (1 second)
         */
        public static const UNMEASURABLE_IMPRESSION_THRESHOLD:Number = 5;

        // Constructor
        /*
        public function OVVConfig(standard:String, duration:int){
            var std:String = standard || default_standard;
            var min_time:int = viewability[standard].min_viewable_time_sec ||
                               Math.floor(duration * viewability[standard].min_viewable_time_pc / 100);
            MIN_VIEWABLE_AREA_PC       = viewability[standard].min_viewable_area_pc;

            POLL_INTERVAL              = viewability[standard].poll_interval_ms;
            VIEWABLE_POLLS_CONSECUTIVE = viewability[standard].viewable_polls_consecutive;
            VOLUME_REQUIRED            = viewability[standard].volume_required;
            MIN_VIEWABLE_POLLS         = Math.floor( min_time * 1000 / POLL_INTERVAL);
        }
        */

    }
}
