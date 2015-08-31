/*
*/
package org.openvv {
    public class OVVConfig {

        /**
         * A dictionary of all currently supported Video Viewability Standards and their
         * associated viewability measuring and impression firing criteria:
         */
        public static const viewability:Object = {
            "GROUPM": {min_viewable_area_pc: 100, volume_required: true,  poll_interval_ms: 200, viewable_polls_consecutive: false, min_viewable_time_sec: null, min_viewable_time_pc: 50  },
            "MRC":    {min_viewable_area_pc: 50,  volume_required: false, poll_interval_ms: 200, viewable_polls_consecutive: true,  min_viewable_time_sec: 2,    min_viewable_time_pc: null }
        };

        /* The default Viewability Standard to be used if no viewability_standard
         * argument is passed in the OVVAsset constructor or if the argument passed is null.
         */
        public static const default_standard:String = "MRC";
    }
}
