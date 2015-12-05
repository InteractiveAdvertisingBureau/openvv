
package net.iab.simulators.player 
{
	
	import flash.display.Sprite;
	import flash.events.Event;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.creative.ui.AdButton;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * Container of all player UI elements.
	 * @author Andrei Andreev
	 */
	
	public class VPAIDControls extends Sprite
	{
		
		private var methods:MethodsPanel;
		private var events:EventsPanel;
		private var properties:PropertiesPanel;
		public function VPAIDControls() 
		{
			init();
		}
		
		private function init():void 
		{
			methods = new MethodsPanel();
			properties = new PropertiesPanel();
			events = new EventsPanel();
			placePanels();
		}
		
		private function placePanels():void 
		{
			addChild(methods);
			addChild(properties);
			addChild(events);
			properties.x = methods.x + methods.width + 10;
			events.y = properties.y + properties.height + 10;
			addListeners();
			
		}
		
		private function addListeners():void 
		{
			for each(var type:String in PlayerEvent.TypesList) {
				properties.addEventListener(type, onPlayerEvent);
				methods.addEventListener(type, onPlayerEvent);
			}
		}
		
		private function onPlayerEvent(e:PlayerEvent):void 
		{
			dispatchEvent(e);
		}
		
		public function set handshakeVersion(value:String):void {
			properties.setHandshakeVersion(value);
		}
		
		public function set vpaidEvent(e:VPAIDEvent):void {
			trace(this, "vpaidEvent", e);
			events.vpaidEvent = e;
		}
		
		public function set property(value:Object):void {
			properties.property = value;
		}
		
		
		
	}

}