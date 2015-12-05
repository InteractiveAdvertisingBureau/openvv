package net.iab.vpaid.core
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.net.NetStream;
	import flash.utils.Timer;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.events.ControlEvent;
	import net.iab.vpaid.events.VPAIDEvent;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Video progress monitoring and reporting engine.
	 *
	 * @author Andrei Andreev
	 */
	public class VideoTracker extends Object
	{
		private var _stream:NetStream;
		private var messanger:EventDispatcher;
		private var vpaidParams:VPAIDParams;
		/**
		 * Initial adDuration - used for countdown.
		 * Is not affected by VPAID adDuration changes after initial value is set.
		 */
		private var adDuration:int = -1;
		private var timer:Timer;
		private var delay:Number = 250;
		/**
		 * Array of VPAID video events to be reported.
		 * @see reportVideoEvent()
		 */
		private var quartiles:Array = [VPAIDEvent.AdVideoComplete, VPAIDEvent.AdVideoThirdQuartile, VPAIDEvent.AdVideoMidpoint, VPAIDEvent.AdVideoFirstQuartile, VPAIDEvent.AdVideoStart];
		/**
		 * Length of video quarter in milliseconds
		 */
		private var quarter:int = -1;
		private var skipOffset:Number = Infinity;
		private var adRemainingTime:int = -1;
		
		/**
		 *
		 * @param	adData global ad configuration parameters
		 * @param	vpaidParams global VPAID parameters handler and provider
		 * @param	messanger global EventDispatcher utilized throughout the framework
		 */
		public function VideoTracker(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher)
		{
			init(adData, vpaidParams, messanger);
		}
		
		private function init(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher):void
		{
			this.messanger = messanger;
			this.vpaidParams = vpaidParams;
			skipOffset = Number(adData.getParam("skipOffset")) || skipOffset;
			timer = new Timer(delay);
			timer.addEventListener(TimerEvent.TIMER, readPlayhead);
		}
		
		/**
		 * Read playhead position and addresses the logic related to video progress.
		 * @param	e
		 */
		private function readPlayhead(e:TimerEvent):void
		{
			adRemainingTime = adDuration - _stream.time * 1000;
			messanger.dispatchEvent(new ControlEvent(ControlEvent.VIDEO_PROGRESS, {time: adRemainingTime, duration: adDuration}));
			vpaidParams.adRemainingTime = adRemainingTime / 1000;
			reportVideoEvent(int(adRemainingTime / quarter) + 1);
			/**
			 * Assures that the moment of skippability change is reported.
			 */
			vpaidParams.adSkippableState = skipOffset < _stream.time;
		}
		
		/**
		 * Reports quartiles. Quartiles are reported once per ad instance.
		 * @param	index
		 */
		private function reportVideoEvent(index:int):void
		{
			if (quartiles[index])
			{
				messanger.dispatchEvent(new VPAIDEvent(quartiles[index]));
				/**
				 * Remove reported event from the list of events to be reported.
				 */
				quartiles[index] = null;
			}
		}
		
		/**
		 * Instance of NetStream used for monitoring playback progress.
		 */
		public function set stream(value:NetStream):void
		{
			removeListeners(_stream);
			_stream = value;
			addListeners(_stream);
		}
		
		private function addListeners(dispatcher:NetStream):void
		{
			dispatcher.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			/**
			 * Code NetStream.MetaData is custom -
			 * it does not exist in the default list of NetStatusEvent.info codes.
			 *
			 * @see AdNetStream.onMetaData()
			 */
			switch (e.info.code)
			{
				
				case "NetStream.MetaData": 
					/**
					 * Internally used in milliseconds
					 * to deal with Number rounding error
					 */
					adDuration = e.info.duration * 1000;
					quarter = adDuration * .25;
					vpaidParams.adDuration = adDuration / 1000;
					timer.start();
					break;
				
				case "NetStream.Play.Start": 
					reportVideoEvent(4);
					break;
				
				case "NetStream.Pause.Notify": 
					messanger.dispatchEvent(new ControlEvent(ControlEvent.PAUSE_AD));
					messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPaused));
					timer.stop();
					break;
				
				case "NetStream.Unpause.Notify": 
					messanger.dispatchEvent(new ControlEvent(ControlEvent.RESUME_AD));
					messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdPlaying));
					timer.start();
					break;
				
				case "NetStream.Play.Complete": 
				case "NetStream.Play.Stop": 
					messanger.dispatchEvent(new ControlEvent(ControlEvent.VIDEO_PROGRESS, {time: 0, duration: adDuration}));
					messanger.dispatchEvent(new ControlEvent(ControlEvent.VIDEO_COMPLETE));
					reportVideoEvent(0);
					vpaidParams.adRemainingTime = adRemainingTime = 0;
					timer.reset();
					/**
					 * If adDuration is -2 - this means that user has engaged and
					 * must click close button to unload the ad
					 * Otherwise ad must be automatically stopped
					 */
					if (vpaidParams.adDuration != -2)
						messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdAutoStop));
					break;
			}
		}
		
		private function removeListeners(dispatcher:NetStream):void
		{
			if (dispatcher)
				dispatcher.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		
		public function dispose():void
		{
			if (_stream)
				removeListeners(_stream);
			timer.reset();
			timer.removeEventListener(TimerEvent.TIMER, readPlayhead);
			timer = null;
			messanger = null;
			vpaidParams = null;
			_stream = null;
		}
	
	}

}