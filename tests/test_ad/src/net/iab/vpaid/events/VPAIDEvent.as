package net.iab.vpaid.events
{
	import flash.events.Event;
	
	/**
	 * Event that participates in messaging of VPAID Events throughout the framework and to to publisher player.
	 * @author Andrei Andreev
	 */
	public class VPAIDEvent extends DataEvent
	{
		/**
		 * VPAID 2.0 REQ 3.3.1<br/>
		 *
		 * <p>When the video player calls the initAd() method, the ad unit can begin loading assets.</p>
		 *
		 * <p>Once loaded and ready for display, the ad dispatches the AdLoaded event. No UI elements
		 * should be visible before AdLoaded is sent, but sending AdLoaded indicates that the ad
		 * unit has verified that all files are ready to execute. Also, if initAd() was called, and the ad
		 * unit is unable to display and/or send AdLoaded, then AdError should be dispatched.</p>
		 * @see net.iab.vpaid.VPAIDAPI#initAd()
		 */
		public static const AdLoaded:String = "AdLoaded";
		/**
		 * VPAID 2.0 REQ 3.3.2
		 *
		 * <p>The AdStarted event is sent by the ad unit to notify the video player that the ad is
		 * displaying and is a response to the startAd() method.</p>
		 * @see net.iab.vpaid.VPAIDAPI#startAd()
		 */
		public static const AdStarted:String = "AdStarted";
		/**
		 * VPAID 2.0 REQ 3.3.3
		 *
		 * <p>The AdStopped event is sent by the ad unit to notify the video player that the ad has
		 * stopped displaying and all ad resources have been cleaned up. This event is only for
		 * responding the stopAd() method call made by the video player. It should never be used to
		 * initiate the ad unit’s end or used to inform the video player that it can now call stopAd().</p>
		 * @see net.iab.vpaid.VPAIDAPI#stopAd()
		 * @see net.iab.vpaid.VPAIDAPI#skipAd()
		 */
		public static const AdStopped:String = "AdStopped";
		/**
		 * VPAID 2.0 REQ 3.3.4
		 *
		 * <p>The AdSkipped event is sent by the ad unit to notify the video player that the ad has been
		 * skipped, stopped displaying and all ad resources have been cleaned up.</p>
		 *
		 * <p>The AdSkipped event can be sent in response to the skipAd() method call or as a result
		 * of a skip control activated within the ad unit (rather than in the video player).</p>
		 *
		 * <p>In response to a skipAd() method call, the ad unit must stop ad play, clean up all
		 * resources, and send the AdSkipped event. If a skip control is activated within the ad unit,
		 * the ad unit must stop ad play, clean up all resource, and send the AdSkipped event
		 * followed by the AdStopped event.</p>
		 *
		 * <p>Sending the AdStopped event for skip controls
		 * activated in the ad unit ensures that video players using earlier versions of VPAID receive
		 * notice that the ad has stopped playing.</p>
		 * @see net.iab.vpaid.VPAIDAPI#stopAd()
		 * @see net.iab.vpaid.VPAIDAPI#skipAd()
		 */
		public static const AdSkipped:String = "AdSkipped";
		/**
		 * VPAID 2.0 REQ 3.3.5
		 *
		 * <p>AdSkippableStateChange is new to VPAID 2.0.</p>
		 *
		 * <p>When an ad unit only allows its creative to be skipped within a specific time frame, it can use
		 * the AdSkippableStateChange event to prompt the video player to check the value of
		 * the adSkippableState property, which keeps the video player updated on when the ad
		 * can be skipped and when it cannot be skipped.</p>
		 * @see net.iab.vpaid.VPAIDAPI#skipAd()
		 * 
		 */
		public static const AdSkippableStateChange:String = "AdSkippableStateChange";
		/**
		 * VPAID 2.0 REQ 3.3.6
		 *
		 * <p>AdSizeChange is new to VPAID 2.0.</p>
		 *
		 * <p>The AdSizeChange event is sent in response to the resizeAd() method call. When the
		 * video player resizes, it notifies the ad unit so that the ad unit can also scale to maintain the
		 * same ad space ratio that it had relevant to the previous video player size.</p>
		 *
		 * <p>When the video player calls resizeAd(), the ad unit must scale its width and height value
		 * to equal or less than the width and height value supplied in the video player call. If the video
		 * player doesn’t provide width and height values (as in fullscreen mode), then the ad unit can
		 * resize to any dimension.</p>
		 *
		 * <p>Once the ad unit has resized itself, it writes width and height values to the adWidth and
		 * adHeight properties, respectively. The AdSizeChange event is then sent to confirm that
		 * the ad unit has resized itself.</p>
		 *
		 * @see net.iab.vpaid.VPAIDAPI#resizeAd()
		 * @see net.iab.vpaid.VPAIDAPI#adWidth
		 * @see net.iab.vpaid.VPAIDAPI#adHeight
		 */
		public static const AdSizeChange:String = "AdSizeChange";
		/**
		 * VPAID 2.0 REQ 3.3.7
		 *
		 * <p>The AdLinearChange event is sent by the ad unit to notify the video player that the ad unit
		 * has changed playback mode. To find out the current state of the ad unit’s linearity, the video
		 * player must use the get adLinear property and update its UI accordingly. See the adLinear
		 * property for more information.</p>
		 */
		public static const AdLinearChange:String = "AdLinearChange";
		/**
		 * VPAID 2.0 REQ 3.3.8
		 *
		 * <p>AdDurationChange is new to VPAID 2.0.</p>
		 *
		 * <p>The duration for some video ads can change in response to user interaction or other factors.
		 * When the ad duration changes, the ad unit updates the values of the adDuration and
		 * adRemainingTime properties and dispatches the AdDurationChange event,
		 * notifying the video player that duration has changed. The video player can then get
		 * adDuration and adRemainingTime to update its UI, such as the duration indicator, if
		 * applicable.</p>
		 *
		 * <p>During normal playback, adDurationChange should not be dispatched unless the total
		 * duration of the ad changes.</p>
		 * 
		 * @see net.iab.vpaid.VPAIDAPI#adDuration
		 * @see net.iab.vpaid.VPAIDAPI#adRemainingTime
		 */
		public static const AdDurationChange:String = "AdDurationChange";
		/**
		 * VPAID 2.0 REQ 3.3.9
		 *
		 * <p>When the expanded state of the ad changes, the ad unit must update the adExpanded
		 * property and dispatch the AdExpandedChange event to notify the video player of the
		 * change. The video player responds by using the get adExpanded property to update its UI
		 * accordingly. An AdExpandedChange event may be triggered by the expandAd() method.</p>
		 *
		 * <p>The AdExpandedChange event is only for notifying the player of a change in ad unit
		 * expansion, such as the expand or collapse of an interactive panel. To dispatch a change in
		 * standard display size, please use AdSizeChange.</p>
		 * @see net.iab.vpaid.VPAIDAPI#adExpanded
		 * 
		 */
		public static const AdExpandedChange:String = "AdExpandedChange";
		/**
		 * VPAID 2.0 REQ 3.3.10
		 *
		 * <p>The AdRemainingTimeChange event is still supported in order to accommodate ads
		 * and video players using VPAID 1.0; however, in 2.0 versions, please use
		 * AdDurationChange.</p>
		 *
		 * <p>The AdRemainingTimeChange event is sent by the ad unit to notify the video player that
		 * the ad’s remaining playback time has changed. The video player may get the
		 * adRemainingTime property and update its UI accordingly.
		 * Upon initial duration change, the ad unit should update the adRemainingTime property
		 * and send the AdRemainingTimeChange event at least once per second but no more
		 * than four times per second (to maintain optimum performance) so that the video player can
		 * keep its UI in synch with actual time remaining.</p>
		 * 
		 * @see net.iab.vpaid.VPAIDAPI#adRemainingTime
		 * @see net.iab.vpaid.VPAIDAPI#adDuration
		 */
		public static const AdRemainingTimeChange:String = "AdRemainingTimeChange";
		/**
		 * VPAID 2.0 REQ 3.3.11
		 *
		 * <p>If the ad unit supports volume, any volume changes are updated in the adVolume property
		 * and the AdVolumeChange event is dispatched to notify the video player of the change.
		 * The video player may then use the get adVolume property and update its UI accordingly.</p>
		 * 
		 * @see net.iab.vpaid.VPAIDAPI#adVolume
		 */
		public static const AdVolumeChange:String = "AdVolumeChange";
		/**
		 * VPAID 2.0 REQ 3.3.12
		 *
		 * <p>The AdImpression event is used to notify the video player that the user-visible phase of the
		 * ad has begun. The AdImpression event may be sent using different criteria depending on
		 * the type of ad format the ad unit is implementing.
		 * For a linear mid-roll ad, the impression should coincide with the AdStart event. However, for a
		 * non-linear overlay ad, the impression will occur when the invitation banner is displayed, which
		 * is normally before the ad video is shown. This event matches that of the same name in Digital
		 * Video In-Stream Ad Metrics Definitions, and must be implemented to be IAB compliant.</p>
		 * 
		 * @see net.iab.vpaid.VPAIDAPI#startAd()
		 */
		public static const AdImpression:String = "AdImpression";
		/**
		 * VPAID 2.0 REQ 3.3.13
		 *
		 * <p>Events AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, and AdVideoComplete are five events that sent by the ad unit to notify the video player of the ad unit’s video
		 * progress and are used in VAST under the same event names. Definitions can be found under
		 * “Percent complete” events in Digital Video In-Stream Ad Metrics Definitions. These events must
		 * be implemented for ads to be IAB compliant, but only apply to the video portion of the ad
		 * experience, if any.</p>
		 */
		public static const AdVideoStart:String = "AdVideoStart";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdVideoStart
		 */
		public static const AdVideoFirstQuartile:String = "AdVideoFirstQuartile";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdVideoStart
		 */
		public static const AdVideoMidpoint:String = "AdVideoMidpoint";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdVideoStart
		 */
		public static const AdVideoThirdQuartile:String = "AdVideoThirdQuartile";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdVideoStart
		 */
		public static const AdVideoComplete:String = "AdVideoComplete";
		/**
		 * VPAID 2.0 REQ 3.3.14
		 *
		 * <p>The AdClickThru event is sent by the ad unit when a clickthrough occurs. Three
		 * parameters can be included to give the video player the option for handling the event.</p>
		 *
		 * <p>Three parameters are available for the event:</p>
		 * <ul>
		 * <li><strong>String url</strong>: enables the ad unit to specify the clickthrough url</li>
		 * <li><strong>String Id</strong>: used for tracking purposes</li>
		 * <li><strong>Boolean playerHandles</strong>: indicates whether the video player or the ad unit handles
		 *   the event. Set to true, the video player opens the new browser window to the URL
		 * 	 provided. Set to false, the ad unit handles the event.</li>
		 * </ul>
		 * <p>The AdClickThru event is included under the same name in Digital Video In-Stream Ad
		 * Metrics Definitions and must be implemented to be IAB compliant.</p>
		 */
		public static const AdClickThru:String = "AdClickThru";
		/**
		 * VPAID 2.0 REQ 3.3.15
		 *
		 * <p>AdInteraction is new in VPAID 2.0.</p>
		 *
		 * <p>This event was introduced to capture all user interactions under one metric aside from any
		 * clicks that result in redirecting the user to specified site. AdInteraction events might
		 * include hover-overs, clicks that don’t result in a ClickThru, click-and-drag interactions, and
		 * the events described in section 3.3.16. While AdInteraction does not replace any other
		 * metrics, it can be used in addition to other metrics. Keep in mind that recording both an
		 * AdUserMinimize and an AdInteraction for the same event is just one event with
		 * two names. Other custom interactions, such as “Dealer Locator” for example don’t exist in any
		 * VPAID events, so it could be recorded under the AdInteraction event.</p>
		 *
		 * <p>The AdInteraction event is sent by the ad unit to indicate any interaction with the ad
		 * EXCEPT for ad clickthroughs. An ad clickthrough is indicated using the AdClickThru event
		 * described in section 3.3.14.</p>
		 *
		 * <p>One parameter is available for this event:</p>
		 * <ul>
		 * <li><strong>String Id</strong>: used for tracking purposes</li>
		 * </ul>
		 */
		public static const AdInteraction:String = "AdInteraction";
		/**
		 * VPAID 2.0 REQ 3.3.16
		 *
		 * <p>The AdUserAcceptInvitation, AdUserMinimize and AdUserClose events
		 * are sent by the ad unit when they meet requirements of the same names as set in Digital Video
		 * In-Stream Ad Metrics Definitions. Each of these events indicates user-initiated action that the ad
		 * unit dispatches to the video player. The video player may choose to report these events
		 * externally, but takes no other action.</p>
		 */
		public static const AdUserAcceptInvitation:String = "AdUserAcceptInvitation";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdUserAcceptInvitation
		 */
		public static const AdUserMinimize:String = "AdUserMinimize";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdUserAcceptInvitation
		 */
		public static const AdUserClose:String = "AdUserClose";
		/**
		 * VPAID 2.0 REQ 3.3.17
		 *
		 * <p>The AdPaused and AdPlaying events are sent in response to the pauseAd() and
		 * resumeAd() method calls, respectively, to confirm that the ad has either paused or is
		 * playing. Sending AdPaused indicates that the ad has stopped all audio and any animation
		 * in progress. Other settings, such as adjusting the ad’s visibility or removing ad elements from
		 * the UI, may be implemented until resumeAd() is called. Sending AdPlaying indicates
		 * that the ad unit has resumed playback from the point at which it was paused.</p>
		 * @see net.iab.vpaid.VPAIDAPI#pauseAd()
		 * @see net.iab.vpaid.VPAIDAPI#resumeAd()
		 */
		public static const AdPaused:String = "AdPaused";
		/**
		 * @copy net.iab.vpaid.events.VPAIDEvent#AdPaused
		 * @see net.iab.vpaid.VPAIDAPI#pauseAd()
		 * @see net.iab.vpaid.VPAIDAPI#resumeAd()
		 */
		public static const AdPlaying:String = "AdPlaying";
		
		/**
		 * VPAID 2.0 REQ 3.3.18
		 *
		 * <p>The AdLog event is optional and can be used to relay debugging information.</p>
		 *
		 * <p>One parameter is available for this event:</p>
		 * <ul>
		 * <li><strong>String Id</strong>: used for tracking purposes</li>
		 * </ul>
		 */
		public static const AdLog:String = "AdLog";
		/**
		 * VPAID 2.0 REQ 3.3.19
		 *
		 * <p>The AdError event is sent when the ad unit has experienced a fatal error. Before the ad unit
		 * sends AdError it must clean up all resources and cancel any pending ad playback. The
		 * video player must remove any ad UI, and recover to its regular content playback state.</p>
		 *
		 * <p>The <strong>String message</strong> parameter can be used to provide more specific information to the video
		 * player.</p>
		 */
		public static const AdError:String = "AdError";
		/**
		 * AdUserSkip is not a VPAID standard Event.
		 * Custom event that is dispatched when user skips ad from within creative -
		 * for example by clickin on ad's skip button.
		 */
		public static const AdUserSkip:String = "AdUserSkip";
		/**
		 * AdAutoStop is not a standard VPAID Event.
		 * Dispatched when ad countdown reaches zero and user is not engaged.
		 * Ad stop notification must arrive prior to VPAID reporting AdStopped event.
		 */
		public static const AdAutoStop:String = "AdAutoStop";
		
		/**
		 * List of all VPAID events.
		 */
		public static const VPAIDTypes:Array = [AdClickThru, AdDurationChange, AdError, AdExpandedChange, AdImpression, AdInteraction, AdLinearChange, AdLoaded, AdLog, AdPaused, AdPlaying, AdRemainingTimeChange, AdSizeChange, AdSkippableStateChange, AdSkipped, AdStarted, AdStopped, AdUserAcceptInvitation, AdUserClose, AdUserMinimize, AdVideoComplete, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoStart, AdVideoThirdQuartile, AdVolumeChange, AdUserSkip, AdAutoStop];
		
		/**
		 *
		 * @copy net.iab.vpaid.events.DataEvent#DataEvent()
		 */
		public function VPAIDEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, data, bubbles, cancelable);
		}
		/**
		 *
		 * @copy net.iab.vpaid.events.DataEvent#clone()
		 */
		override public function clone():Event
		{
			return new VPAIDEvent(type, data, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			
			return formatToString("VPAIDEvent:", "type", "bubbles", "cancelable", "eventPhase");
		}
	
	}

}