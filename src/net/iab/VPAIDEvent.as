package net.iab
{
	import flash.events.Event;
	
	/*
	* VPAID events that a VPAID SWF can dispatch.  This class does not need to be used for any VPAID SWFs,
	* but it can help make coding easier.  This source can be found in the VPAID specification:
	* http://www.iab.net/media/file/VPAID_2.0_Final_04-10-2012.pdf
	*/
	public class VPAIDEvent extends Event
	{
		public static const AdLoaded:String = "AdLoaded";
		public static const AdStarted:String = "AdStarted";
		public static const AdStopped:String = "AdStopped";
		public static const AdLinearChange:String = "AdLinearChange";
		public static const AdExpandedChange:String = "AdExpandedChange";
		public static const AdVolumeChange:String = "AdVolumeChange";
		public static const AdImpression:String = "AdImpression";
		public static const AdVideoStart:String = "AdVideoStart";
		public static const AdVideoFirstQuartile:String = "AdVideoFirstQuartile";
		public static const AdVideoMidpoint:String = "AdVideoMidpoint";
		public static const AdVideoThirdQuartile:String = "AdVideoThirdQuartile";
		public static const AdVideoComplete:String = "AdVideoComplete";
		public static const AdClickThru:String = "AdClickThru";
		public static const AdUserAcceptInvitation:String = "AdUserAcceptInvitation";
		public static const AdUserMinimize:String = "AdUserMinimize";
		public static const AdUserClose:String = "AdUserClose";
		public static const AdPaused:String = "AdPaused";
		public static const AdPlaying:String = "AdPlaying";
		public static const AdLog:String = "AdLog";
		public static const AdError:String = "AdError";
		public static const AdSkipped:String = "AdSkipped";
		public static const AdSkippableStateChange:String = "AdSkippableStateChange";
		public static const AdSizeChange:String = "AdSizeChange";
		public static const AdDurationChange:String = "AdDurationChange";
		public static const AdInteraction:String = "AdInteraction";
		
		
		private var _data:Object;
		
		public function VPAIDEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
	
}