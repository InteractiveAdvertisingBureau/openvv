package net.iab.simulators.player
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import net.iab.vpaid.creative.ui.AdButton;
	
	/**
	 * Allow for setting and reading of individual VPAID properties.
	 * @author Andrei Andreev
	 */
	public class PropertyElement extends Sprite
	{
		private var label:String = "lebel";
		private var valueText:TextField;
		private var defaultValue:String;
		/**
		 * 
		 * @param	label name that appears as a label
		 * @param	defaultValue default input text field value
		 */
		public function PropertyElement(label:String, defaultValue:String = "value")
		{
			this.label = label || this.label;
			this.defaultValue = defaultValue;
			init();
		}
		
		private function init():void
		{
			var button:AdButton = new AdButton(label, 120);
			button.addEventListener(MouseEvent.CLICK, onClick);
			valueText = textField;
			addChild(button);
			addChild(valueText);
			valueText.x = button.x + button.width + 4;
		}
		
		private function onClick(e:MouseEvent):void
		{
			dispatchEvent(new PlayerEvent(PlayerEvent.COMMAND));
		}
		
		private function get textField():TextField
		{
			var field:TextField = new TextField();
			field.defaultTextFormat = new TextFormat("Arial", 12, 0xF1C40F);
			field.wordWrap = false;
			field.type = TextFieldType.INPUT;
			field.multiline = false;
			field.width = 80;
			field.height = 22;
			field.background = true;
			field.border = true;
			field.borderColor = 0xF1C40F;
			field.text = defaultValue;
			
			return field;
		}
		
		public function set text(value:String):void
		{
			valueText.text = value;
		}
		
		public function get text():String
		{
			return valueText.text;
		}
	}

}