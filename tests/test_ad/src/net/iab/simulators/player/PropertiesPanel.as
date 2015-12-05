package net.iab.simulators.player
{
	import flash.display.Sprite;
	import net.iab.vpaid.events.VPAIDEvent;
	
	/**
	 * Container of elements that display and manipulate VPAID properties.
	 * @author Andrei Andreev
	 */
	public class PropertiesPanel extends ControlPanel
	{
		private var elements:Array;
		private var handshakeVersion:PropertyElement;
		private var adLinear:PropertyElement;
		private var adWidth:PropertyElement;
		private var adHeight:PropertyElement;
		private var adExpanded:PropertyElement;
		private var adSkippableState:PropertyElement;
		private var adRemainingTime:PropertyElement;
		private var adDuration:PropertyElement;
		private var getAdVolume:PropertyElement;
		private var setAdVolume:PropertyElement;
		private var adCompanions:PropertyElement;
		private var adIcons:PropertyElement;
		private var getVPAID:PropertyElement;
		
		public function PropertiesPanel()
		{
		
		}
		
		override protected function init():void
		{
			getVPAID = new PropertyElement("getVPAID()");
			handshakeVersion = new PropertyElement("handshakeVersion()");
			adLinear = new PropertyElement("adLinear");
			adWidth = new PropertyElement("adWidth");
			adHeight = new PropertyElement("adHeight");
			adExpanded = new PropertyElement("adExpanded");
			adSkippableState = new PropertyElement("adSkippableState");
			adRemainingTime = new PropertyElement("adRemainingTime");
			adDuration = new PropertyElement("adDuration");
			getAdVolume = new PropertyElement("get adVolume");
			setAdVolume = new PropertyElement("set adVolume", "1");
			adCompanions = new PropertyElement("adCompanions");
			adIcons = new PropertyElement("adIcons");
			elements = [getVPAID, handshakeVersion, adLinear, adWidth, adHeight, adExpanded, adSkippableState, adRemainingTime, adDuration, getAdVolume, setAdVolume, adCompanions, adIcons];
			
			placeElements();
			drawBackground();
		}
		
		private function placeElements():void
		{
			var by:Number = padding;
			for each (var element:Sprite in elements)
			{
				addChild(element);
				element.x = padding;
				element.y = by;
				by += element.height + padding;
				element.addEventListener(PlayerEvent.COMMAND, onCommand);
			}
		}
		
		private function onCommand(e:PlayerEvent):void
		{
			switch (e.currentTarget)
			{
				case getVPAID: 
					dispatchEvent(new PlayerEvent(PlayerEvent.GET_VPAID));
					break;
				case handshakeVersion: 
					dispatchEvent(new PlayerEvent(PlayerEvent.HANDSHAKE_VERSION));
					break;
				case adLinear: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_LINEAR));
					break;
				case adWidth: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_WIDTH));
					break;
				case adHeight: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_HEIGHT));
					break;
				case adExpanded: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_EXPANDED));
					break;
				case adSkippableState: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_SKIPPABLE_STATE));
					break;
				case adRemainingTime: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_REMAINING_TIME));
					break;
				case adDuration: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_DURATION));
					break;
				case getAdVolume: 
					dispatchEvent(new PlayerEvent(PlayerEvent.GET_AD_VOLUME));
					break;
				case setAdVolume: 
					dispatchEvent(new PlayerEvent(PlayerEvent.SET_AD_VOLUME, { value: Number(setAdVolume.text) } ));
					break;
				case adCompanions: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_COMPANIONS));
					break;
				case adIcons: 
					dispatchEvent(new PlayerEvent(PlayerEvent.AD_ICONS));
					break;
			
			}
		}
		
		public function setHandshakeVersion(value:String):void {
			handshakeVersion.text = value;
		}
		
		public function set property(value:Object):void {
			if (this[value.key]) {
				PropertyElement(this[value.key]).text = String(value.value);
			}
		}
		
		 
	
	}

}