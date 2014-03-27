package org.openvv
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	[SWF(height="1", width="1", frameRate="24")]
	public final class OVVBeacon extends Sprite
	{
		public var throttleCallback:String;
		
		private var _throttleState:String;
		private var _renderMeter:OVVRenderMeter;
		
		public function OVVBeacon()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);			
			
			addEventListener("throttle", onThrottle);
			_renderMeter = new OVVRenderMeter(this);
			
			if (OVVCheck.externalInterfaceIsAvailable())
			{
				ExternalInterface.addCallback("isVisible", isVisible);
			}
			
			ExternalInterface.call("console.error", "Beacon on page!");
		}
		
		protected function onAddedToStage(event:Event):void
		{
			var bg:Sprite = new Sprite();
			var g:Graphics = bg.graphics;
			
			g.beginFill(0xFF0000, 1.0);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();
			
			addChild(bg);
		}
		
		public function isVisible():Boolean
		{
			if (_throttleState != null)
			{
				return _throttleState == OVVThrottleType.RESUME;
			}
			
			return _renderMeter.fps > 8;
		}
		
		protected function onThrottle(event:Event):void
		{
			_throttleState = event['state'];
			ExternalInterface.call(throttleCallback, event['state'], event['stageFrameRate'], event['targetFrameRate']); 
		}
	}
}