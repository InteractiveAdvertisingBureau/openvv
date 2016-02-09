package net.iab.vpaid.creative.player
{
	import flash.events.EventDispatcher;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.core.VideoTracker;
	import net.iab.vpaid.events.VPAIDEvent;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Ad video instance.
	 *
	 * <p>Present implementation handles progressive video playback only.</p>
	 * @author Andrei Andreev
	 */
	public class AdVideo extends Video
	{
		private var url:String;
		private var stream:AdNetStream;
		private var connection:AdNetConnection;
		private var soundTransform:SoundTransform;
		/**
		 * User preferred volume.
		 * Does not change when video muted.
		 *
		 */
		private var _volume:Number = 1;
		private var vpaidParams:VPAIDParams;
		private var videoTracker:VideoTracker;
		private var adData:AdData;
		private var messanger:EventDispatcher;
		
		/**
		 *
		 * @param	adData global ad data
		 * @param	vpaidParams global instance that manages and provides VPAID parameters
		 * @param	messanger global event dispatcher
		 */
		public function AdVideo(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher)
		{
			init(adData, vpaidParams, messanger);
		}
		
		private function init(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher):void
		{
			this.adData = adData;
			this.vpaidParams = vpaidParams;
			this.messanger = messanger;
			videoTracker = new VideoTracker(adData, vpaidParams, messanger);
			this.messanger.addEventListener(VPAIDEvent.AdVolumeChange, onVolumeChange);
		}
		
		private function onVolumeChange(e:VPAIDEvent):void
		{
			if (vpaidParams.adVolume === 0)
				muted = true;
			else
				volume = vpaidParams.adVolume;
		}
		/**
		 * Resizes video based on arguments values.
		 * <p>In the current implementation width is the base of calculations where video is always assumed to have ration of 16:9.</p>
		 * @param	width
		 * @param	height
		 */
		public function setSize(width:Number, height:Number):void
		{
			this.width = int(width);
			/**
			 * All videos are treated as 16:9
			 */
			this.height = int(width * 9 / 16);
		}
		/**
		 * 
		 * Obtains video url and initiates video playback.
		 */
		public function play():void
		{
			this.url = String(adData.getParam("advideo"));
			connect();
		}
		/**
		 * 
		 * Pauses video plaback.
		 */
		public function pause():void
		{
			if (stream)
				stream.pause();
		}
		/**
		 * 
		 * Resumes video playback.
		 */
		public function resume():void
		{
			if (stream)
				stream.resume();
		}
		/**
		 * 
		 * Mutes/unmutes video. User volume preference is preserved - on unmute volume is set to user preferred value.
		 */
		public function set muted(value:Boolean):void
		{
			if (stream)
			{
				
				soundTransform.volume = value ? 0 : _volume;
				stream.soundTransform = soundTransform;
				vpaidParams.adVolume = soundTransform.volume;
			}
		}
		/**
		 * Manipulates video volume.
		 * <p>Value is normalized Number in the range from 0 to 1</p>
		 */
		public function set volume(value:Number):void
		{
			_volume = value;
			if (stream)
			{
				soundTransform.volume = _volume;
				stream.soundTransform = soundTransform;
				vpaidParams.adVolume = _volume;
			}
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetConnection.Connect.Success": 
					startStream();
					break;
			}
		}
		
		private function connect():void
		{
			connection = new AdNetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			connection.connect(url);
		}
		
		private function startStream():void
		{
			soundTransform = new SoundTransform(_volume);
			videoTracker.stream = stream = new AdNetStream(connection);
			stream.soundTransform = soundTransform;
			attachNetStream(stream);
			stream.play(url);
			this.smoothing = true;
		}
		/**
		 *
		 * @copy net.iab.vpaid.creative.AdSprite#dispose()
		 */
		public function dispose():void
		{
			if (messanger)
			{
				messanger.removeEventListener(VPAIDEvent.AdVolumeChange, onVolumeChange);
				videoTracker.dispose();
				
			}
			if (stream)
			{
				connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				stream.close();
				connection.close();
			}
			adData = null;
			vpaidParams = null;
			messanger = null;
			videoTracker = null;
			stream = null;
			connection = null;
		}
	
	}

}