/**
 * Copyright (c) 2013 TubeMogul
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
package com.tubemogul{
import flash.display.MovieClip;
import flash.external.ExternalInterface;
import flash.system.Security;
import flash.utils.setTimeout;

public class ViewabilityAsset extends MovieClip {
	private const version:Number = 8;
	private var gateway:*;  //Proprietary; Communicates with ad unit
	private var psId:String; //Proprietary; Site ID
	private var logger:Logger;
	private var viewabilityCheck:ViewabilityCheck;
	private var quartilesReported:Array = new Array( false, false, false, false, false );
	private var isMuted:Boolean;
	private var wiggleRoom:Number = 0;
	public function ViewabilityAsset() {
		Security.allowDomain("*");
		//Example logger:
		logger = new Logger();
	}

	private function startSniffing( checkpoint:String ):void {
		if ( ExternalInterface.available ) {
			if ( checkpoint == 'view' ) {
				logger.sendEvent('{"version":"' + version + '","siteId":"' + psId +
						'","action":"Progress"}' );
			}
			viewabilityCheck = new ViewabilityCheck( 'fn' + gateway.videoId );
			var results:Object = viewabilityCheck.results;
			if ( !!results.error ) {
				//Report error message
				trace( 'Error: ' + results.error );
				logger.sendEvent( '{"version":"' + version + '","siteId":"' + psId +
						'","error":"' + results.error + '"}');
			} else {
				//This call is not necessary; it calls a redundant AS function (below) to validate JS data:
				var percentViewable:Number = getPercentInViewport( results );

				//Create data object to log (This is an example of how data from viewabilityCheck.results can be used):
				var jsonString:String = '{"version":"' + version + '","siteId":"' + psId +
						'","action":"Complete","viewable":{"AS":"' +
						percentViewable + '","JS":"' + results.percentViewable + '"},"viewport":{"viewportWidth":"'
						+ results.clientWidth +	'","viewportHeight":"' + results.clientHeight + '"}' +
						',"objBounds":{"objTop":"' + results.objTop + '","objBottom":"' + results.objBottom +
						'","objRight":"' + results.objRight + '","objLeft":"' + results.objLeft + '"},"id":"' +
						results.id + '","width":{"adWidth":"' + gateway.adWidth +
						'","objWidth":"' + ( results.objRight - results.objLeft ) + '"},"height":{"adHeight":"' +
						gateway.adHeight + '","objHeight":"' + ( results.objBottom - results.objTop ) +
						'"},"windowActive":"' + results.focus + '","checkpoint":"' + checkpoint + '","mute":"' +
						isMuted + '"}';
				logger.sendEvent( jsonString );

				ExternalInterface.call( 'TMViewableDetect', jsonString );//For demo page
			}
		} else {
			//No ExternalInterface support
			logger.sendEvent('{"version":"' + version + '","siteId":"' + psId +
					'","error":"noExternalInterface"}');
		}
	}
	//This function is redundant, for comparison; the JS code returns the same value (remove after testing)
	protected function getPercentInViewport( results:* ):Number {
		var visibleObjectArea:Number = 0;
		var totalObjectArea:Number = ( results.objRight - results.objLeft ) * ( results.objBottom - results.objTop );
		for ( var x:Number = 0; x <= results.clientWidth; x++ ) {
			if ( x >= results.objLeft && x <= results.objRight ) {
				for( var y:Number = 0; y <= results.clientHeight; y++ ) {
					if ( y >= results.objTop && y <= results.objBottom ) {
						visibleObjectArea++;
					}
				}
			}
		}
		return Math.round( visibleObjectArea / totalObjectArea * 100 );
	}

	/**
	 * Code below is proprietary for TubeMogul ad units.  When this asset is loaded by a TubeMogul ad, the ad unit will
	 * first call handshakeVersion() to initialize the overlay.  Once all assets are loaded, startAsset() will be
	 * called.  We add small delay before starting viewability detection.
	 *
	 */

	//TM proprietary; used to communicate with ad unit:
	public function handshakeVersion(adData:Object):String {
		gateway = adData.gateway;
		ExternalInterface.call( 'TMAdLoad' );//For demo page
		psId = adData.winplayData.psid ||= 'no_psId';
		//Log a Start event:
		logger.sendEvent('{"version":"' + version + '","siteId":"' + psId + '","action":"Start"}');
		return "1.0";
	}
	//TM proprietary; Called when asset is added to stage
	public function startAsset():void {
		//setTimeout( startSniffing, 1000, 'view' );
		gateway.addEventListener( InteractiveAssetGateway.IA_PLAYHEAD_CHANGED, handlePlayheadUpdate );
	}
	//TM proprietary; Required by TM ad unit
	public function pauseAsset():void {
	}
	//TM proprietary; Required by TM ad unit
	public function resumeAsset():void {
	}
	//TM proprietary; Required by TM ad unit
	public function stopAsset():void {
		gateway.removeEventListener( InteractiveAssetGateway.IA_PLAYHEAD_CHANGED, handlePlayheadUpdate );
	}
	//----------------------------
	/**
	* handlePlayheadUpdate() is triggered every ~200ms to allow stats data to be reported at each quartile.
	*
	* (It needs to access the current playhead position, the duration, and the current volume.)
	*
	*/
	public function handlePlayheadUpdate( e:Event ):void {
		var currentPos:Number = gateway.playheadPos;
		var duration:Number = gateway.duration;
		isMuted = ( gateway.volume <= 0 );
		var quartilesCompleted:Number = Math.floor( ( ( currentPos + wiggleRoom ) / duration ) / .25 );
		if ( quartilesReported[ quartilesCompleted ] == false ) {
			switch ( quartilesCompleted ) {
				case 0:
					startSniffing( 'view' );
					setTimeout( startSniffing, 1000, 'oneSecond' );
					break;
				case 1:
					startSniffing( 'pct25' );
					break;
				case 2:
					startSniffing( 'pct50' );
					break;
				case 3:
					startSniffing( 'pct75' );
					wiggleRoom = 1;
					break;
				case 4:
					startSniffing( 'pct100' );
			}
			quartilesReported[ quartilesCompleted ] = true;
		}
	}
}
}

