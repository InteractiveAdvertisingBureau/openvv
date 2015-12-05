package net.iab.vpaid.creative.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	
	/**
	 * Input TextField container with user entry validation.
	 * 
	 * @author Andrei Andreev
	 */
	public class LabeledInput extends Sprite
	{
		private var labelText:String = "label";
		private var defaultInput:String = "default input";
		private var label:TextField;
		private var input:TextField;
		private var style:Style;
		/**
		 * 
		 * @param	labelText label text
		 * @param	defaultInput default text of input text field
		 */
		public function LabeledInput(labelText:String = "label", defaultInput:String = "default input")
		{
			init(labelText, defaultInput);
		}
		
		private function init(labelText:String = "label", defaultInput:String = "default input"):void
		{
			style = new Styles().labledInput;
			this.labelText = labelText;
			this.defaultInput = defaultInput;
			drawLabel();
			drawInput();
			placeUI();
		}
		
		private function placeUI():void
		{
			label.x = label.y = input.y = style.margin;
			input.x = label.x + label.width + style.margin;
			addChild(label);
			addChild(input);
			
			drawBackground();
			activateInput();
		}
		
		public function get text():String
		{
			return input.text;
		}
		
		private function activateInput():void
		{
			input.addEventListener(FocusEvent.FOCUS_IN, onInputChange);
			input.addEventListener(FocusEvent.FOCUS_OUT, onInputChange);
		}
		
		private function onInputChange(e:Event):void
		{
			switch (e.type)
			{
				case FocusEvent.FOCUS_IN: 
					input.text = "";
					break;
				
				case FocusEvent.FOCUS_OUT: 
					if (input.text.replace(/\s/g, "") === "")
						input.text = defaultInput;
					break;
			}
		}
		
		private function drawBackground():void
		{
			style.width = this.width + style.margin * 2;
			style.height = this.height + style.margin * 2;
			var background:RectangularShape = new RectangularShape(style);
			addChildAt(background, 0);
		}
		
		private function drawInput():void
		{
			input = new TextField();
			input.type = TextFieldType.INPUT;
			input.defaultTextFormat = new TextFormat(style.fontName, style.fontSize, style.textColor);
			input.antiAliasType = AntiAliasType.ADVANCED;
			input.gridFitType = GridFitType.SUBPIXEL;
			input.embedFonts = true;
			input.sharpness = -200;
			label.thickness = -200;
			input.multiline = false;
			input.text = defaultInput;
			input.border = true;
			input.background = true;
			input.borderColor = style.lineColor;
			input.height = 18;
			input.width = 100;
		}
		
		private function drawLabel():void
		{
			var style:Style = new Styles().inputLabel;
			label = new TextField();
			label.defaultTextFormat = new TextFormat(style.fontName, style.fontSize, style.textColor);
			label.antiAliasType = AntiAliasType.ADVANCED;
			label.gridFitType = GridFitType.SUBPIXEL;
			label.embedFonts = true;
			label.sharpness = 0;
			label.thickness = 200;
			label.multiline = false;
			label.autoSize = TextFieldAutoSize.LEFT;
			label.text = labelText;
		}
		
	}

}