package net.iab.vpaid
{
	import flash.events.EventDispatcher;
	import net.iab.vpaid.core.AdGlobal;
	
	/**
	 * Super Class for objects that implement VPAID API.
	 * @author Andrei Andreev
	 */
	public class VPAIDAPI extends EventDispatcher implements IVPAID
	{
		/**
		 * @see handshakeVersion()
		 */
		private var vpaidAdVersion:String = "2.0.0";
		/**
		 * viewMode value constant.
		 *
		 * @see net.iab.vpaid.VPAIDAPI#initAd()
		 * @see net.iab.vpaid.VPAIDAPI#resizeAd()
		 */
		public static const VIEWMODE_THUMBNAIL:String = "thumbnail";
		/**
		 * viewMode value constant.
		 *
		 * @see net.iab.vpaid.VPAIDAPI#initAd()
		 * @see net.iab.vpaid.VPAIDAPI#resizeAd()
		 */
		public static const VIEWMODE_NORMAL:String = "normal";
		/**
		 * viewMode value constant.
		 *
		 * @see net.iab.vpaid.VPAIDAPI#initAd()
		 * @see net.iab.vpaid.VPAIDAPI#resizeAd()
		 */
		public static const VIEWMODE_FULLSCREEN:String = "fullscreen";
		
		private var _global:AdGlobal;
		private var _vpaidParams:VPAIDParams;
		private var _messanger:EventDispatcher;
		/**
		 * 
		 * @param	global object that encapsulates singleton instnaces injected throughout the framework.
		 */
		public function VPAIDAPI(global:AdGlobal)
		{
			this._global = global;
			_vpaidParams = _global.vpaidParams;
			_messanger = _global.messanger;
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#handshakeVersion()
		 */
		public function handshakeVersion(playerVPAIDVersion:String):String
		{
			return vpaidAdVersion;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#initAd()
		 */
		public function initAd(width:Number, height:Number, viewMode:String = VIEWMODE_NORMAL, desiredBitrate:Number = -1, creativeData:String = "", environmentVars:String = ""):void
		{
			vpaidParams.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#resizeAd()
		 */
		public function resizeAd(width:Number, heigth:Number, viewMode:String = VIEWMODE_NORMAL):void
		{
			vpaidParams.resizeAd(width, heigth, viewMode);
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#startAd()
		 */
		public function startAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#stopAd()
		 */
		public function stopAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#pauseAd()
		 */
		public function pauseAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#resumeAd()
		 */
		public function resumeAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#expandAd()
		 */
		public function expandAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#collapseAd()
		 */
		public function collapseAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#skipAd()
		 */
		public function skipAd():void
		{
		
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adLinear
		 */
		public function get adLinear():Boolean
		{
			return vpaidParams.adLinear;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adWidth
		 */
		public function get adWidth():Number
		{
			return vpaidParams.adWidth;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adHeight
		 */
		public function get adHeight():Number
		{
			return vpaidParams.adHeight;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adExpanded
		 */
		public function get adExpanded():Boolean
		{
			return vpaidParams.adExpanded;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adSkippableState
		 */
		public function get adSkippableState():Boolean
		{
			return vpaidParams.adSkippableState;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adRemainingTime
		 */
		public function get adRemainingTime():Number
		{
			return vpaidParams.adRemainingTime;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adDuration
		 */
		public function get adDuration():Number
		{
			return vpaidParams.adDuration;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adVolume
		 */
		public function get adVolume():Number
		{
			return vpaidParams.adVolume;
		}

		public function set adVolume(value:Number):void
		{
			vpaidParams.adVolume = value;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adCompanions
		 */
		public function get adCompanions():String
		{
			return vpaidParams.adCompanions;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adIcons
		 */
		public function get adIcons():Boolean
		{
			return vpaidParams.adIcons;
		}
		/**
		 * 
		 */
		protected function get global():AdGlobal
		{
			return _global;
		}
		
		protected function get vpaidParams():VPAIDParams
		{
			return _vpaidParams;
		}
	
		protected function get messanger():EventDispatcher
		{
			return _messanger;
		}
	
	}

}