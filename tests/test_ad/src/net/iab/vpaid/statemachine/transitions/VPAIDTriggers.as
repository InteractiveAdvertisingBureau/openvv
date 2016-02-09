package net.iab.vpaid.statemachine.transitions
{
	
	/**
	 * Collection of constants used as state transisions triggers.
	 * @see net.iab.vpaid.statemachine.transitions.TransitionsDictionary
	 * @author Andrei Andreev
	 */
	public class VPAIDTriggers
	{
		public static const AdError:String = "AdError";
		public static const AdImpression:String = "AdImpression";
		public static const AdLoaded:String = "AdLoaded";
		public static const AdSkipped:String = "AdSkipped";
		public static const AdStarted:String = "AdStarted";
		public static const AdStopped:String = "AdStopped";
		public static const AdUserClose:String = "AdUserClose";
		public static const AdAutoStop:String = "AdAutoStop";
		public static const AdUserSkip:String = "AdUserSkip";
		public static const initAd:String = "initAd";
		public static const initial:String = "initial";
		public static const skipAd:String = "skipAd";
		public static const startAd:String = "startAd";
		public static const stopAd:String = "stopAd";
		
	}

}