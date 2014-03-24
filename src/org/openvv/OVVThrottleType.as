package org.openvv
{
	/**
	 * This class mirrors ThrottleEvent's constants. In scenarios where
	 * OpenVV is loaded in SWFs compiled for less than Flash Player 11,
	 * using ThrottleEvent throws a VerifyError. However, we can still
	 * use these constants regardless of player environment.
	 *
	 * @see flash.events.ThrottleType
	 */	
	public final class OVVThrottleType
	{
		public static const PAUSE:String = "pause";
		
		public static const RESUME:String = "resume";
		
		public static const THROTTLE:String = "throttle";
	}
}