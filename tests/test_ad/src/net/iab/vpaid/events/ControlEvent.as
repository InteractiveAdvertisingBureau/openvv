package net.iab.vpaid.events
{
	import flash.events.Event;
	
	/**
	 * Event used for internal ad communications.
	 * 
	 * @author Andrei Andreev
	 */
	public class ControlEvent extends DataEvent
	{
		public static const SHOW_GRID:String = "showGrid";
		public static const HIDE_GRID:String = "hideGrid";
		public static const PAUSE_AD:String = "pauseAd";
		public static const RESUME_AD:String = "resumeAd";
		public static const VIDEO_COMPLETE:String = "videoComplete";
		public static const VIDEO_PROGRESS:String = "videoProgress";
		public static const MUTE_AD:String = "muteAd";
		public static const UNMUTE_AD:String = "unmuteAd";
		public static const STOP_AD:String = "stopAd";
		public static const SKIP_AD:String = "skipAd";
		public static const USER_ENGAGED:String = "userEngaged";
		
		public static const ControlTypes:Array = [SHOW_GRID, HIDE_GRID, PAUSE_AD, RESUME_AD, MUTE_AD, UNMUTE_AD, STOP_AD, SKIP_AD, VIDEO_COMPLETE];
		/**
		 *
		 * @copy net.iab.vpaid.events.DataEvent#DataEvent()
		 */
		public function ControlEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, data, bubbles, cancelable);
		}
		/**
		 *
		 * @copy net.iab.vpaid.events.DataEvent#clone()
		 */
		override public function clone():Event
		{
			return new ControlEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("ControlEvent:", "type", "data_to_string", "bubbles", "cancelable", "eventPhase");
		}
	
	}

}