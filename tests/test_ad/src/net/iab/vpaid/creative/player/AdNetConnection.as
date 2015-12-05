package net.iab.vpaid.creative.player
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	/**
	 * Placeholder for the future use with streaming media.
	 * In this iteration accespts progressive video only.
	 * @author Andrei Andreev
	 */
	public class AdNetConnection extends NetConnection
	{
		
		public function AdNetConnection()
		{
		
		}
		
		override public function connect(command:String, ... rest):void
		{
			super.connect(null);
		}
		
	
	}

}