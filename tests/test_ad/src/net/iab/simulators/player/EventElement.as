package net.iab.simulators.player
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flashx.textLayout.formats.TextAlign;
	
	/**
	 * Element that visualizes individual VPAID Event presence.
	 * @author Andrei Andreev
	 */
	public class EventElement extends Sprite
	{
		private var label:String = "label";
		private var counterText:TextField;
		private var counter:int = 0;
		
		public function EventElement(label:String)
		{
			this.label = label || this.label;
			init();
		}
		
		private function init():void
		{
			var eventType:TextField = drawTextField(label, 130, 11, 0xFFFFFF, false, TextAlign.RIGHT);
			counterText = drawTextField("0", 30, 12, 0xFFFFFF, true);
			addChild(eventType);
			addChild(counterText);
			counterText.x = eventType.x + eventType.width + 4;
			drawBackground();
		}
		
		private function drawBackground():void
		{
			graphics.beginFill(0xF1C40F);
			graphics.drawRect(0, 0, width, height);
		}
		
		private function drawTextField(text:String = "text", fieldWidth:Number = 120, size:Number = 11, color:uint = 0x000000, bold:Boolean = false, align:String = "left"):TextField
		{
			var textField:TextField = new TextField();
			textField.defaultTextFormat = new TextFormat("Arial", size, color, bold, null, null, null, null, align);
			textField.multiline = textField.wordWrap = false;
			textField.width = fieldWidth;
			textField.height = 20;
			textField.text = text;
			return textField;
		}
		
		public function increment():void
		{
			counterText.text = String(++counter);
		}
	
	}

}