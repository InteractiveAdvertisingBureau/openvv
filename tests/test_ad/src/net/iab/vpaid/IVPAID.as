package net.iab.vpaid
{
	
	/**
	 * Interface for the properties and methods that a VPAID SWF can implement.
	 * This source can be found in the VPAID specification: http://www.iab.net/media/file/VPAID_2.0_Final_04-10-2012.pdf
	 * @author Andrei Andreev
	 */
	public interface IVPAID
	{
		/**
		 * VPAID 2.0 REQ 3.2.1
		 *
		 * <p>The adLinear Boolean indicates whether the ad unit is in a linear (true) or non-linear (false)
		 * mode of operation. The adLinear property should only be accessed after the ad unit has
		 * dispatched the AdLoaded event or after an AdLinearChange event.</p>
		 *
		 * <p>The adLinear property affects the state of video content. When set to true, the video player
		 * pauses video content. If set to true initially and the ad unit is designated as a pre-roll (defined
		 * externally), the video player may choose to delay loading video content until ad playback is nearly complete.</p>
		 */
		function get adLinear():Boolean;
		/**
		 * VPAID 2.0 REQ 3.2.2
		 *
		 * <p>The adWidth property is new to VPAID 2.0.</p>
		 * 
		 * <p>The adWidth property provides the ad's width in pixels and is updated along with the
		 * adHeight property anytime the AdSizeChange event is sent to the video player, usually
		 * after the video player calls resizeAd(). The ad unit may change its size to width and
		 * height values equal to or less than the values provided by the video player in the Width and
		 * Height parameters of the resizeAd() method. If the ViewMode parameter in the
		 * resizeAd() call is set to "fullscreen," then the ad unit can ignore the Width and Height
		 * values of the video player and resize to any dimension. The video player may use adWidth
		 * and adHeight values to verify that the ad is appropriately sized.</p>
		 *
		 * <p>Note: adWidth value may be different than resizeAd() values
		 * The value for the adWidth property may be different from the width value that the video
		 * player supplies when it calls resizeAd(). The resizeAd() method provides the video
		 * player's maximum allowed value for width, but the adWidth property provides the ad's
		 * actual width, which must be equal to or less than the video player's supplied width.</p>
		 */
		function get adWidth():Number;
		/**
		 * VPAID 2.0 REQ 3.2.3
		 *
		 * <p>The adHeight property is new to VPAID 2.0.</p>
		 * 
		 * <p>The adHeight property provides the ad's height in pixels and is updated along with the
		 * adWidth property anytime the AdSizeChange event is sent to the video player, usually
		 * after the video player calls resizeAd(). The ad unit may change its size to width and
		 * height values equal to or less than the values provided by the video player in the Width and
		 * Height parameters of the resizeAd() method. If the ViewMode parameter in the
		 * resizeAd() call is set to "fullscreen," then the ad unit can ignore the Width and
		 * Height values of the video player and resize to any dimension. The video player may use
		 * adWidth and adHeight values to verify that the ad is appropriately sized.</p>
		 *
		 * <p>Note: adHeight values may be different than resizeAd() values
		 * The value for the adHeight property may be different from the height value that the video
		 * player supplies when it calls resizeAd(). The resizeAd() method provides the video
		 * player's maximum allowed value for height, but the adHeight property provides the ad's
		 * actual height, which must be equal to or less than the video player's supplied height.</p>
		 */
		function get adHeight():Number;
		
		/**
		 * VPAID 2.0 REQ 3.2.4
		 *
		 * <p>The adExpanded Boolean value indicates whether the ad unit is in a state where additional
		 * portions it occupies more UI area than its smallest area. If the ad unit has multiple collapsed
		 * states, all collapsed states show adExpanded being false. There can only be one expanded
		 * state for the creative, which for a non-linear ad is usually the largest possible size for the ad
		 * unit and may include a linear mode of operation (though setting adExpanded to true does
		 * NOT imply that the ad unit is in linear mode).</p>
		 * 
		 * <p>Specifically, a non-linear ad can support one or more collapsed sizes that allow users to view
		 * video content reasonably unimpeded. One example of a larger collapsed state is where a
		 * nonlinear overaly typically displays across the lower fifth of the video display area. A
		 * secondary, smaller collapsed state, often called a "pill" state, might display as a small overlay
		 * button with a visible call-to-action.</p>
		 * 
		 * <p>The video player can check the adExpanded property at any time. Use the
		 * AdExpandedChange event to indicate that the expanded state has changed. If ad is
		 * statically sized adExpanded is set to false.</p>
		 */
		function get adExpanded():Boolean;
		
		/**
		 * VPAID 2.0 REQ 3.2.6
		 *
		 * <p>The video player may use the adRemainingTime property to update player UI during ad
		 * playback, such as displaying a playback counter or other ad duration indicator. The
		 * adRemainingTime property is provided in seconds and is relative to the total duration
		 * value provided in the adDuration property.</p>
		 *
		 * <p>The video player may check the adRemainingTime property at any time, but should
		 * always check it when receiving an AdRemainingTimeChange (in VPAID 1.0) or
		 * adDurationChange event (in VPAID 2.0). The ad unit should update this property to be
		 * current within one second of actual remain time and can be updated once per second during
		 * normal playback or up to four times per second (to maintain optimum performance) so that the
		 * video player can keep its UI in synch with actual time remaining.</p>
		 *
		 * <p>If the property is not implemented, the ad unit returns a value of -1. A value of -2 is returned
		 * when time remaining is unknown. Unknown remaining time usually indicates that a user is
		 * actively engaged with the ad.</p>
		 */
		function get adRemainingTime():Number;
		/**
		 * VPAID 2.0 REQ 3.2.7
		 *
		 * <p>The adDuration property is new to VPAID 2.0.</p>
		 *
		 * <p>An ad unit may provide the adDuration property to indicate the total duration of the ad,
		 * relative to the current state of the ad unit. When user interaction changes the total duration of
		 * the ad, the ad unit should update this property and send the adDurationChange event.
		 * The initial value for adDuration is the expected duration before any user interaction.</p>
		 *
		 * <p>The video player may check the adDuration property at any time, but should always
		 * check it when receiving an adDurationChange event.</p>
		 *
		 * <p>If duration is not implemented, the ad unit returns a -1 value. If the duration is unknown, the ad
		 * unit returns a -2. Unknown duration is typical when the user has engaged the ad.</p>
		 */
		function get adDuration():Number;
		/**
		 * VPAID 2.0 REQ 3.2.9
		 * 
		 * <p>The adCompanions property is new to VPAID 2.0.</p>
		 * 
		 * <p>Companion banners are ads that display outside the video player area to reinforce the
		 * messaging provided in the video ad unit. In some cases, a VPAID ad unit may request ads
		 * from other ad servers after initAd()has been called, and makes a decision about which
		 * ad it will display, which may or may not include ad companions. For example, a client-side
		 * yield management SDK may wrap itself in a VPAID ad when a native SDK integration might
		 * be cumbersome. In this scenario, the ad server that served the initial VAST response may not
		 * know which ad will be displayed, and therefore the VAST response itself does not include ad
		 * companions.</p>
		 * 
		 * <p>VPAID 2.0 enables an ad server to serve a VAST response which has no companions, but
		 * which does have a VPAID ad unit that pulls in ad companions dynamically based on the adserving
		 * situation. The video player can then check the VPAID ad unit for ad companions when
		 * the VAST response has none.</p>
		 * 
		 * <p>The video player is not required to poll this property, and because ad companion information
		 * from the VAST response takes precedence over VPAID ad companions, the video player
		 * should only access this property when the VAST response is absent of any ad companions.</p>
		 * 
		 * <p>The value of this property is a String that provides ad companion details in VAST 3.0 format
		 * for the <CompanionAds/> element, and should contain all the media files and details for
		 * displaying the ad companions (i.e. the format should be of an InLine response and not in
		 * Wrapper format). Also, the value should only include details within the <CompanionAds/>
		 * element and not an entire VAST response. If any XML elements are included outside of the
		 * <CompanionAds/> element, they must be ignored, including any <Impression/>
		 * elements that might have been included. However, VAST companion ad
		 * <TrackingEvents/> elements for <Tracking event="creativeView"/> must
		 * be respected.</p>
		 * 
		 * <p>If the video player calls for adCompanions(), it must wait until after receiving the VPAID
		 * AdLoaded event, and any companions provided must not display until after the VPAID
		 * AdImpression event is received. Delaying companion display until after the
		 * AdImpression event prevents display of any companion banners in the case where the
		 * video ad fails to register an impression.</p>
		 * 
		 * <p>If this property is used but no Companions are available the property should return an empty
		 * string "".</p>
		 */
		function get adCompanions():String;
		/**
		 * VPAID 2.0 REQ 3.2.9
		 * 
		 * <p>The adIcon property is new to VPAID 2.0.</p>
		 * 
		 * <p>Several initiatives in the advertising industry involve using an icon that overlays on top of an ad
		 * creative to provide some extended functionality such as to communicate with consumers or
		 * otherwise fulfill requirements of a specific initiative. Often this icon and its functionality may be
		 * provided by a vendor, and is not necessarily served by the ad server or included in the
		 * creative itself.</p>
		 * 
		 * <p>One example of icon use is for compliance to certain Digital Advertising Alliance (DAA) selfregulatory
		 * principles for Online Behavioral Advertising (OBA). If you would like more
		 * information about the OBA Self Regulation program, please visit http://www.aboutads.info.</p>
		 * 
		 * <p>The video player can use the adIcons property to avoid displaying duplicate icons over any
		 * icons that might be provided in the ad unit. Until the industry provides more guidance on how
		 * to pass metadata using common ad-serving protocols, this property is limited to a Boolean
		 * response. The default value is False. If one or more ad icons are present within the ad, the
		 * value returned is True. When set to True, the video player should not display any ad icons
		 * of its own.</p>
		 */
		function get adIcons():Boolean;
		
		/**
		 * VPAID 2.0 REQ 3.2.8
		 *
		 * <p>The video player uses the adVolume property to either request the current value for ad
		 * volume (get) or change the value of the ad unit's volume (set). The adVolume value is
		 * between 0 and 1 and is linear, where 0 is mute and 1 is maximum volume. The video player is
		 * responsible for maintaining mute state and setting the ad volume accordingly. If volume is not
		 * implemented as part of the ad unit, -1 is returned as the value for adVolume when the video
		 * player attempts to get adVolume. If set is not implemented, the video player does nothing.</p>
		 */
		function get adVolume():Number;
		/**
		 *
		 * @param value
		 */
		function set adVolume(value:Number):void;
		/**
		 * VPAID 2.0 REQ 3.2.5
		 *
		 * <p>The adSkippableState property is new to VPAID 2.0.</p>
		 * 
		 * <p>Common to skippable ads is a timeframe for when they're allowed to be skipped. For
		 * example, some ads may only be skipped a few seconds after the ad has started or may not
		 * allow the ad to be skipped as it nears the end of playback.</p>
		 * 
		 * <p>The adSkippableState enables advertisers and publishers to align their metrics based
		 * on what can and cannot be skipped.</p>
		 * 
		 * <p>The default value for this property is false. When the ad reaches a point where it can be
		 * skipped, the ad unit updates this property to true and sends the
		 * AdSkippableStateChange event. The video player can check this property at any
		 * time, but should always check it when the AdSkippableStateChange event is received.</p>
		 */
		function get adSkippableState():Boolean;
		/**
		 * VPAID 2.0 REQ 3.1.1
		 * <p>The video player calls handshakeVersion immediately after loading the ad unit to indicate to
		 * the ad unit that VPAID will be used. The video player passes in its latest VPAID version string.
		 * The ad unit returns a version string minimally set to "1.0", and of the form "major.minor.patch"
		 * (i.e. "2.1.05"). The video player must verify that it supports the particular version of VPAID or
		 * cancel the ad.</p>
		 * 
		 * <p>In VPAID 2.0, updates were made with support of version 1.0 and later in mind. Video players
		 * of version 2.0 should correctly display ads of version 1.0 and later, and video players of 1.0
		 * and later should be able to display ads of version 2.0, but not all features will be supported.
		 * Testing should included ad play in different version environments to verify any compatibility
		 * issues.</p>
		 * 
		 * <p>Static interface definition implementations may require an external agreement for version
		 * matching, in which case the handshakeVersion method call isn't necessary. However, when
		 * dynamic languages are used, the ad unit or the video player can adapt to match the other's
		 * version if necessary. Dynamic implementations may use the handshakeVersion method call to
		 * determine if an ad unit supports VPAID. A good practice is to always call handshakeVersion
		 * even if the version has been coordinated externally.</p>
		 *
		 * @param	playerVPAIDVersion
		 * @return
		 */
		function handshakeVersion(playerVPAIDVersion:String):String;
		
		/**
		 * VPAID 2.0 REQ 3.1.2
		 *
		 * <p>After the ad unit is loaded and the video player calls handshakeVersion, the video player calls
		 * initAd() to initialize the ad experience. The video player may preload the ad unit and
		 * delay calling initAd() until nearing the ad playback time; however, the ad unit does not
		 * load its assets until initAd() is called. Once the ad unit's assets are loaded, the ad unit
		 * sends the AdLoaded event to notify the video player that it is ready for display. Receiving the
		 * AdLoaded response indicates that the ad unit has verified that all files are ready to execute.</p>
		 *
		 * @param	width: indicates the available ad display area width in pixels.
		 * @param	height: indicates the available ad display area height in pixels.
		 * @param	viewMode: indicates either "normal", "thumbnail", or "fullscreen" as the view mode for the video player as defined by the publisher. Default is "normal"
		 * @param	desiredBitrate: indicates the desired bitrate as number for kilobits per second(kbps). The ad unit may use this information to select appropriate bitrate for any streaming content.
		 * @param	creativeData: (optional) used for additional initialization data. In a VAST context, the ad unit should pass the value for either the Linear or Nonlinear AdParameter element specified in the VAST document
		 * @param	environmentVars: (optional) used for passing implementation-specific runtime variables. Refer to the language specific API description for more details.
		 */
		function initAd(width:Number, height:Number, viewMode:String = "normal", desiredBitrate:Number = -1, creativeData:String = "", environmentVars:String = ""):void;
		
		/**
		 * VPAID 2.0 REQ 3.1.3
		 * 
		 * <p>The resizeAd() method is only called when the video player changes the width and
		 * height of the video content container, which prompts the ad unit to scale or reposition. The ad
		 * unit then resizes itself to a width and height that is equal to or less than the width and height
		 * supplied by the video player. Once resized, the ad unit writes updated dimensions to the
		 * adWidth and adHeight properties and sends the AdSizeChange event to confirm that
		 * it has resized itself.</p>
		 *
		 * <p>Calling resizeAd() is solely for prompting the ad to scale or reposition. Use expandAd() to
		 * prompt the ad unit to extend additional creative space.</p>
		 *
		 * @param	width: The maximum display area allotted width for the ad. The ad unit must resize itself to a width and height that is within the values provided. The video player must always provide width and height unless it is in fullscreen mode. In fullscreen mode, the ad unit can ignore width/height parameters and resize to any dimension.
		 * @param	heigth:The maximum display area allotted height for the ad. The ad unit must resize itself to a width and height that is within the values provided. The video player must always provide width and height unless it is in fullscreen mode. In fullscreen mode, the ad unit can ignore width/height parameters and resize to any dimension.
		 * @param	viewMode: Can be one of "normal" "thumbnail" or "fullscreen" to indicate the mode to which the video player is resizing. Width and height are not required when viewmode is fullscreen.
		 */
		function resizeAd(width:Number, height:Number, viewMode:String = "normal"):void;
		
		/**
		 * VPAID 2.0 REQ 3.1.4
		 *
		 * <p>startAd() is called by the video player when the video player is ready for the ad to
		 * display. The ad unit responds by sending an AdStarted event that notifies the video player
		 * when the ad unit has started playing. Once started, the video player cannot restart the ad unit
		 * by calling startAd() and stopAd() multiple times.</p>
		 */
		function startAd():void;
		
		/**
		 * VPAID 2.0 REQ 3.1.5
		 *
		 * <p>The video player calls stopAd() when it will no longer display the ad or needs to cancel the ad unit. The ad unit responds by closing the ad, cleaning up its resources and then sending
		 * the AdStopped event. The process for stopping an ad may take time.</p>
		 */
		function stopAd():void;
		
		/**
		 * VPAID 2.0 REQ 3.1.6
		 *
		 * <p>The video player calls pauseAd() to prompt the ad unit to pause ad display. The ad unit
		 * responds by suspending any audio, animation or video and then sending the AdPaused
		 * event. Instead of simply stopping animation and perhaps dimming display brightness, the ad
		 * unit may choose to remove UI elements. Once AdPaused is sent, the video player may hide
		 * the ad by adjusting the visibility setting for the display container. If the video player does not
		 * receive the AdPaused event after a pauseAd() call, then either the ad unit cannot be
		 * paused or it failed to send the AdPaused event. In either case, the video player should treat
		 * the lack of response as a failed attempt to pause the ad.</p>
		 */
		function pauseAd():void;
		
		/**
		 * VPAID 2.0 REQ 3.1.7
		 *
		 * <p>Following a call to pauseAd(), the video player calls resumeAd() to continue ad
		 * playback. The ad unit responds by resuming playback and sending the AdPlaying event to
		 * confirm. If the video player does not receive the AdPlaying event after a resumeAd()
		 * call, then either the ad unit cannot resume play or it failed to send the AdPlaying event. In
		 * either case, the video player should treat the lack of response as a failed attempt to initiate
		 * resumed playback of the ad.</p>
		 */
		function resumeAd():void;
		
		/**
		 * VPAID 2.0 REQ 3.1.8
		 *
		 * <p>The video player calls expandAd() when the timing is appropriate for an expandable ad
		 * unit to play at additional interactive ad space, such as an expanding panel. The video player
		 * may use this call when it provides an "Expand" button that calls expandAd() when clicked.
		 * The ad unit responds by setting the adExpanded property to true and dispatching the
		 * AdExpandedChange event, to confirm that the expandAd() call caused a change in
		 * behavior or appearance of the ad.</p>
		 */
		function expandAd():void;
		
		/**
		 * VPAID 2.0 REQ 3.1.9
		 *
		 * <p>When the ad unit is in an expanded state, the video player may call collapseAd() to
		 * prompt the ad unit to retract any extended ad space. The ad unit responds by setting the
		 * adExpanded property to false and dispatching the AdExpandedChange event, to
		 * confirm that the collapseAd() call caused a change in behavior or appearance of then ad.
		 * The video player can verify that the ad unit is in an expanded state by checking the value of
		 * the adExpanded property at any time. The ad unit responds by restoring ad dimensions to
		 * its smallest width and height settings and setting its adExpanded property to "false."
		 * The expectation is that the smallest UI size should have the least visible impact on the user, for
		 * best user-experience. Therefore, if the ad unit has multiple collapsed states, such as a
		 * minimized "pill" and a larger click to video banner state (see expandAd() for more
		 * details), then the collapseAd() call should result in the minimized "pill" state. Ad
		 * designers should condider implementing both collapsed states in all of their video ads for best
		 * user-experience. However, only one collapsed state is required.</p>
		 *
		 * <p>Note: If the video player does not call collapseAd(), and the ad unit instead initiates a
		 * collapse on its own by setting adExpanded to false and sending the
		 * AdExpandedChange event, then the ad is free to choose any collapsed state it supports
		 * and not necessarily the smallest UI size.</p>
		 */
		function collapseAd():void;
		/**
		 * VPAID 2.0 REQ 3.1.10
		 *
		 * <p>The skipAd() method is new in VPAID 2.0.</p>
		 *
		 * <p>This method supports skip controls that the video player may implement. The video player calls
		 * skipAd() when a user activates a skip control implemented by the video player. When
		 * called, the ad unit responds by closing the ad, cleaning up its resources and sending the
		 * AdSkipped event.</p>
		 *
		 * <p>The player should check the ad property ‘adSkippableState' before calling
		 * adSkip(). adSkip() will only work if this property is set to true. If player calls
		 * adSkip() when the ‘adSkippableState' property is set to false, the ad can ignore
		 * the skip request.</p>
		 *
		 * <p>The process for stopping an ad may take time. Please see section 3.4 Error Handling and
		 * Timeouts for more information on error reporting and timeouts.</p>
		 *
		 * <p>An AdSkipped event can also be sent as a result of a skip control in the ad unit and the
		 * video player should handle it the same way it handles an AdStopped event. If a skip control
		 * in the ad unit triggers the AdSkipped event, the video player may also send an
		 * AdStopped event to support video players using an earlier version of VPAID. The
		 * AdStopped event sent right after an AdSkipped event can be ignored in video players
		 * using VPAID 2.0 or later.</p>
		 *
		 * <p>Also, if the VPAID version for the ad unit precedes version 2.0, the ad unit will not
		 * acknowledge a skipAd() method call. Skip controls in the video player should use the
		 * stopAd() method to close skipped ads that use earlier versions of VPAID.</p>
		 */
		function skipAd():void;
	}

}