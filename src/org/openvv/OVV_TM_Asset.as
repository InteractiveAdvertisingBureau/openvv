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

    import flash.external.ExternalInterface;

    import org.openvv.OVVAsset;

    public class OVV_TM_Asset extends OVVAsset {
        ////////////////////////////////////////////////////////////
        //   CONSTRUCTOR
        ////////////////////////////////////////////////////////////

        public function OVV_TM_Asset(beaconSwfUrl:String = null, id:String = null,  adRef:* = null) {
            super();
            /*
            // Disable javascript "eval" function to give us opportunity to make further string
            // replacements in the javascripts embedded from OVVAsset.js before evaluating it.
            ExternalInterface.call("function(){var tm_js_eval = eval}");
            super(beaconSwfUrl, id, adRef );
            this.ovvAssetSource = this.ovvAssetSource
                    .replace(/OVVAsset/g, "OVV_TM_Asset")
                    .replace(/OVVGeometryViewabilityCalculator/g, "OVV_TM_GeometryViewabilityCalculator");
            // Reset javascript "eval" function
            ExternalInterface.call("function(){eval = tm_js_eval; tm_js_eval = null;}");
            ExternalInterface.call("eval", this.ovvAssetSource);
            */
        }
    }
}

