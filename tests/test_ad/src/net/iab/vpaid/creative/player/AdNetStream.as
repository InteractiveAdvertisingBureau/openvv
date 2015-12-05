package net.iab.vpaid.creative.player
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	/**
	 * Extends and augments native NetStream functionality.
	 *
	 * @author Andrei Andreev
	 */
	public class AdNetStream extends NetStream
	{
		private static const IDLE:String = "idle";
		private static const PLAYING:String = "playing";
		private static const PAUSED:String = "paused";
		private static const COMPLETE:String = "playComplete";
		
		private var _state:String = IDLE;
		/**
		 * 
		 * @param	connection pass through to super class.
		 */
		public function AdNetStream(connection:NetConnection)
		{
			init();
			super(connection);
		}
		
		private function init():void
		{
			addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
		}
		/**
		 * Resumes or rewinds stream if playback is complete.
		 */
		override public function resume():void
		{
			if (_state === COMPLETE)
			{
				seek(0);
			}
			super.resume();
		}
		
		private function onNetStatus(e:NetStatusEvent):void
		{
			switch (e.info.code)
			{
				case "NetStream.Play.Complete": 
					_state = COMPLETE;
					break;
				
				case "NetStream.Pause.Notify": 
					_state = _state != COMPLETE ? PAUSED : COMPLETE;
					break;
				
				case "NetStream.Play.Start": 
				case "NetStream.Unpause.Notify": 
					_state = PLAYING;
					break;
			}
		}
		
		/**
		 * Method required by streaming client.
		 * Valid for streaming video
		 * @param	info
		 */
		public function onPlayStatus(info:Object):void
		{
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, info));
		}
		/**
		 * Method required by streaming client.
		 * @param	info
		 */
		public function onXMPData(info:Object):void
		{
		
		}
		/**
		 * Method required by streaming client.
		 * @param	info
		 */
		public function onMetaData(info:Object):void
		{
			info.code = "NetStream.MetaData";
			dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS, false, false, info));
		}
		/**
		 * Method required by streaming client.
		 * @param	info
		 */
		public function onCuePoint(info:Object):void
		{
		
		}
		
	}

}