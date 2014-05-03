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
package org.openvv
{

	/**
	 * This class mirrors ThrottleEvent's constants. In scenarios where
	 * OpenVV is loaded in SWFs compiled for less than Flash Player 11,
	 * using ThrottleEvent throws a VerifyError. However, we can still
	 * use these constants regardless of player environment.
	 *
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/ThrottleEvent.html flash.events.ThrottleEvent
	 */
	public final class OVVThrottleType
	{

		////////////////////////////////////////////////////////////
		//   CONSTANTS 
		////////////////////////////////////////////////////////////

		/**
		 * Events of this type represent the SWF being throttled due to being
		 * off screen
		 */
		public static const PAUSE:String = "pause";

		/**
		 * Events of this type represent the SWF being revealed
		 */
		public static const RESUME:String = "resume";

		/**
		 * Events of this type represent the SWF being throttled due to being off screen
		 */
		public static const THROTTLE:String = "throttle";
	}
}
