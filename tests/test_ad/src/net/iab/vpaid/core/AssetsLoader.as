package net.iab.vpaid.core
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.creative.LinearCreative;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Emulates creative assets loading
	 * @author Andrei Andreev
	 */
	public class AssetsLoader extends EventDispatcher
	{
		private var _content:LinearCreative;
		private var adData:AdData;
		private var vpaidParams:VPAIDParams;
		private var messanger:EventDispatcher;
		private var timer:Timer;
		
		public function AssetsLoader(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher)
		{
			this.adData = adData;
			this.vpaidParams = vpaidParams;
			this.messanger = messanger;
		}
		
		/**
		 * Simulates latency.
		 */
		public function loadAssets():void
		{
			timer = new Timer(200, 1);
			timer.addEventListener(TimerEvent.TIMER, onLoad);
			timer.start();
		}
		
		private function onLoad(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER, onLoad);
			timer = null;
			_content = new LinearCreative(adData, vpaidParams, messanger);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Instance of ad visuals.
		 */
		public function get content():LinearCreative
		{
			return _content;
		}
		
		/**
		 * Used during application destruction phase.
		 */
		public function dispose():void
		{
			_content.dispose();
			adData = null;
			vpaidParams = null;
			messanger = null;
			_content = null;
		}
	
	}

}