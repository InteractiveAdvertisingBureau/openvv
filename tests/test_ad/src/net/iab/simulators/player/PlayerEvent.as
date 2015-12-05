package net.iab.simulators.player
{
	import flash.events.Event;
	import net.iab.vpaid.events.DataEvent;
	
	/**
	 * Event utilized by the player simulator.
	 * @author Andrei Andreev
	 */
	public class PlayerEvent extends DataEvent
	{
		public static const LOAD_AD:String = "loadAd";
		public static const AD_LOADED:String = "creativeLoaded";
		public static const INIT_AD:String = "initAd";
		public static const RESIZE_AD:String = "resizeAd";
		public static const START_AD:String = "startAd";
		public static const STOP_AD:String = "stopAd";
		public static const PAUSE_AD:String = "pauseAd";
		public static const RESUME_AD:String = "resumeAd";
		public static const EXPAND_AD:String = "expandAd";
		public static const COLLAPSE_AD:String = "collapseAd";
		public static const SKIP_AD:String = "skipAd";
		public static const HANDSHAKE_VERSION:String = "handshakeVersion";
		public static const GET_VPAID:String = "getVPAID";
		public static const AD_LINEAR:String = "adLinear";
		public static const AD_WIDTH:String = "adWidth";
		public static const AD_HEIGHT:String = "adHeight";
		public static const AD_EXPANDED:String = "adExpanded";
		public static const AD_SKIPPABLE_STATE:String = "adSkippableState";
		public static const AD_REMAINING_TIME:String = "adRemainingTime";
		public static const AD_DURATION:String = "adDuration";
		public static const GET_AD_VOLUME:String = "get_adVolume";
		public static const SET_AD_VOLUME:String = "set_adVolume";
		public static const AD_COMPANIONS:String = "adCompanions";
		public static const AD_ICONS:String = "adIcons";
		public static const COMMAND:String = "command";
		
		public static const TypesList:Array = [GET_VPAID,LOAD_AD, AD_LOADED, INIT_AD, RESIZE_AD, START_AD, STOP_AD, PAUSE_AD, RESUME_AD, EXPAND_AD, COLLAPSE_AD, SKIP_AD, HANDSHAKE_VERSION, AD_LINEAR, AD_WIDTH, AD_HEIGHT, AD_EXPANDED, AD_SKIPPABLE_STATE, AD_REMAINING_TIME, AD_DURATION, GET_AD_VOLUME, SET_AD_VOLUME, AD_ICONS, AD_COMPANIONS,COMMAND];
		
		public function PlayerEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			
			super(type, data, bubbles, cancelable);
		
		}
		
		override public function clone():Event
		{
			return new PlayerEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("PlayerEvent:", "type", "data_to_string", "bubbles", "cancelable", "eventPhase");
		}
	
	}

}