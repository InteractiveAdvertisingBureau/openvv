package org.openvv
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.system.Security;

	[SWF(height="1", width="1", frameRate="24")]
	public final class OVVBeacon extends Sprite
	{
		public var throttleCallback:String;

		private var _throttleState:String;
		private var _renderMeter:OVVRenderMeter;
		private var _index:int;
		private var _id:String;

		public function OVVBeacon()
		{
			super();

			Security.allowDomain("*");

			_id=loaderInfo.parameters.id;
			_index=loaderInfo.parameters.index;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener("throttle", onThrottle);
		}

		protected function onAddedToStage(event:Event):void
		{
			_renderMeter=new OVVRenderMeter(this);

			ExternalInterface.addCallback("isVisible", isVisible);
			ExternalInterface.addCallback("getThrottleState", getThrottleState);
			ExternalInterface.addCallback("getFrameRate", getFrameRate);

			if (_id && _index)
			{
				ExternalInterface.call("OpenVV_" + _id + ".beaconStarted", _index);
			}

			var bg:Sprite=new Sprite();
			var g:Graphics=bg.graphics;

			g.beginFill(0xFF0000, 1.0);
			g.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			g.endFill();

			addChild(bg);
		}

		public function isVisible(data:*=null):Boolean
		{
			if (_throttleState != null)
			{
				return _throttleState == OVVThrottleType.RESUME;
			}

			return _renderMeter.fps > 8;
		}

		protected function onThrottle(event:Event):void
		{
			_throttleState=event['state'];
			ExternalInterface.call(throttleCallback, event['state'], event['targetFrameRate']);
		}

		public function getThrottleState():String
		{
			return _throttleState;
		}

		public function getFrameRate():int
		{
			return _renderMeter.fps;
		}

	}
}
