package net.iab.vpaid
{
	import flash.events.EventDispatcher;
	import net.iab.vpaid.events.ControlEvent;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * VPAIDParams dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdLinearChange
     */
    [Event(name = "AdLinearChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * VPAIDParams dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdExpandedChange
     */
    [Event(name = "AdExpandedChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * VPAIDParams dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdSkippableStateChange
     */
    [Event(name = "AdSkippableStateChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * VPAIDParams dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdDurationChange
     */
    [Event(name = "AdDurationChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * VPAIDParams dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdVolumeChange
     */
    [Event(name = "AdVolumeChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	
	/**
	 * Designed to:
	 * <ol>
	 * <li>Hold latest VPAID properites values;</li>
	 * <li>Notify about values chages;</li>
	 * <li>Be distributed as a global dependency object among all VPAIDAPI instances.</li>
	 * </ol>
	 * VPAID properties values are processes, stored, and provided by a single instance of VPAIDParams Class.
	 * @author Andrei Andreev
	 */
	public class VPAIDParams extends Object
	{
		private var _adLinear:Boolean = true;
		private var _adWidth:Number = 0;
		private var _adHeight:Number = 0;
		private var _adExpanded:Boolean = false;
		private var _adSkippableState:Boolean = false;
		private var _adRemainingTime:Number = -1;
		private var _adDuration:Number = -1;
		private var _adVolume:Number = 1;
		private var _adCompanions:String = "";
		private var _adIcons:Boolean = false;
		private var _viewMode:String = VPAIDAPI.VIEWMODE_NORMAL;
		private var _desiredBitrate:Number = -1;
		private var _creativeData:String = "";
		private var _environmentVars:String = "";
		private var messanger:EventDispatcher;
		/**
		 * 
		 * @param	messanger global EventDispatcher used by entire framework
		 */
		public function VPAIDParams(messanger:EventDispatcher)
		{
			this.messanger = messanger;
		}
		/**
		 * <p>Stores values of the arguments.</p>
		 * @copy net.iab.vpaid.IVPAID#initAd()
		 */
		public function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, creativeData:String, environmentVars:String):void
		{
			_adWidth = width;
			_adHeight = height;
			_viewMode = viewMode || _viewMode;
			_desiredBitrate = desiredBitrate || _desiredBitrate;
			_creativeData = creativeData || _creativeData;
			_environmentVars = environmentVars || _environmentVars;
		}
		/**
		 * <p>Stores values of the arguments.</p>
		 * @copy net.iab.vpaid.IVPAID#resizeAd()
		 */
		public function resizeAd(width:Number, height:Number, viewMode:String):void
		{
			_adWidth = width;
			_adHeight = height;
			_viewMode = viewMode || _viewMode;
		}
		/**
		 * Unlike in VPAID API property adLiniear is read-write.
		 * Framework objects are allowed to set the value. 
		 * <p>VPAIDParams validates attempt to set value and, if successfull, dispatches VPAIDEvent.AdLinearChange Event.</p>
		 * @see net.iab.vpaid.IVPAID#adLinear
		 */
		public function get adLinear():Boolean
		{
			return _adLinear;
		}

		public function set adLinear(value:Boolean):void
		{
			if (_adLinear === value)
				return;
			_adLinear = value;
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLinearChange));
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adWidth
		 */
		public function get adWidth():Number
		{
			return _adWidth;
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adHeight
		 */
		public function get adHeight():Number
		{
			return _adHeight;
		}
		/**
		 * Unlike in VPAID API property adExpanded is read-write.
		 * Framework objects are allowed to set the value.
		 * <p>VPAIDParams validates attempt to set value and, if successfull, dispatches VPAIDEvent.AdExpandedChange Event.</p>
		 * @see net.iab.vpaid.IVPAID#adExpanded
		 */
		public function get adExpanded():Boolean
		{
			return _adExpanded;
		}
		
		public function set adExpanded(value:Boolean):void
		{
			if (_adExpanded === value)
				return;
			_adExpanded = value;
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdExpandedChange));
		}
		/**
		 * Unlike in VPAID API property adSkippableState is read-write.
		 * Framework objects are allowed to set the value.
		 * <p>VPAIDParams validates attempt to set value and, if successfull, dispatches VPAIDEvent.AdSkippableStateChange Event.</p>
		 * @see net.iab.vpaid.IVPAID#adSkippableState
		 */
		public function get adSkippableState():Boolean
		{
			return _adSkippableState;
		}
		
		public function set adSkippableState(value:Boolean):void
		{
			/**
			 * Skippable can change only once from false to true.
			 */
			if (!value || _adSkippableState === value)
				return;
			_adSkippableState = value;
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSkippableStateChange));
		}
		/**
		 * Unlike in VPAID API property adRemainingTime is read-write.
		 * Framework objects are allowed to set the value.
		 * <p>VPAIDParams validates attempt to set value.</p>
		 * @see net.iab.vpaid.IVPAID#adRemainingTime
		 */
		public function get adRemainingTime():Number
		{
			return _adRemainingTime;
		}
		
		public function set adRemainingTime(value:Number):void
		{
			
			if (value < 0)
			{
				if (value != -1 || value != -2)
					return;
			}
			/**
			 * Zero means ad has played already.
			 */
			if (_adRemainingTime === 0 || _adRemainingTime === value)
				return;
			_adRemainingTime = value;
		}
		/**
		 * Unlike in VPAID API property adDuration is read-write.
		 * Framework objects are allowed to set the value.
		 * <p>VPAIDParams validates attempt to set value and, if successfull, dispatches VPAIDEvent.AdDurationChange Event.</p>
		 * @see net.iab.vpaid.IVPAID#adSkippableState
		 */
		public function get adDuration():Number
		{
			return _adDuration;
		}
		
		public function set adDuration(value:Number):void
		{
			if (value < 0)
			{
				if (value != -2)
					return;
			}
			if (_adDuration === value)
				return;
			_adDuration = value;
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdDurationChange));
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#adVolume
		 */
		public function get adVolume():Number
		{
			return _adVolume;
		}
		
		public function set adVolume(value:Number):void
		{
			trace(this, "set adVolume", value);
			value = value > 1 ? 1 : value;
			value = value < 0 ? 0 : value;
			if (_adVolume === value)
				return;
			_adVolume = value;
			messanger.dispatchEvent(new ControlEvent(value === 0 ? ControlEvent.MUTE_AD : ControlEvent.UNMUTE_AD));
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdVolumeChange));
		}
		/**
		 * Unlike in VPAID API property adCompanions is read-write.
		 * Framework objects are allowed to set the value.
		 * @see net.iab.vpaid.IVPAID#adCompanions
		 */
		public function get adCompanions():String
		{
			return _adCompanions;
		}
		
		public function set adCompanions(value:String):void
		{
			_adCompanions = value;
		}
		/**
		 * Unlike in VPAID API property adIcons is read-write.
		 * Framework objects are allowed to set the value.
		 * @see net.iab.vpaid.IVPAID#adCompanions
		 */
		public function get adIcons():Boolean
		{
			return _adIcons;
		}
		
		public function set adIcons(value:Boolean):void
		{
			_adIcons = value;
		}
		/**
		 * Returns view mode set by the player when calling initAd() and resizeAd().
		 * 
		 * @see net.iab.vpaid.IVPAID#initAd()
		 * @see net.iab.vpaid.IVPAID#resizeAd()
		 */
		public function get viewMode():String
		{
			return _viewMode;
		}
		/**
		 * Returns desiredBitrate provided by the player when calling initAd().
		 * 
		 * @see net.iab.vpaid.IVPAID#initAd()
		 */
		public function get desiredBitrate():Number
		{
			return _desiredBitrate;
		}
		/**
		 * Returns creativeData provided by the player when calling initAd().
		 * 
		 * @see net.iab.vpaid.IVPAID#initAd()
		 */
		public function get creativeData():String
		{
			return _creativeData;
		}
		/**
		 * Returns environmentVars provided by the player when calling initAd().
		 * 
		 * @see net.iab.vpaid.IVPAID#initAd()
		 */
		public function get environmentVars():String
		{
			return _environmentVars;
		}
		/**
		 * Accomplishes internal destruction processes.
		 */
		public function dispose():void {
			
		}
	
	}

}