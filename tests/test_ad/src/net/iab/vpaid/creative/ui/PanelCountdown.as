package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.events.ControlEvent;
	
	/**
	 * Displays ad progress countdown.
	 * @author Andrei Andreev
	 */
	public class PanelCountdown extends ButtonPanel
	{
		private var textField:TextField;
		/**
		 * Time display fillers.
		 */
		private var prefices:Array = ["000", "00", "0", ""];
		private var date:Date = new Date();
		
		public function PanelCountdown(messanger:EventDispatcher)
		{
			super(messanger);
		}
		
		override protected function placeUI():void
		{
			super.placeUI();
			var style:Style = new Styles().countdown;
			textField = new TextField();
			var format:TextFormat = new TextFormat(style.fontName, style.fontSize, style.textColor, style.fontWeight);
			format.indent = 2;
			format.letterSpacing = 0;
			textField.defaultTextFormat = format;
			textField.embedFonts = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.gridFitType = GridFitType.SUBPIXEL;
			textField.sharpness = 0;
			textField.thickness = 0;
			textField.multiline = textField.wordWrap = false;
			textField.height = 17;
			textField.width = 104;
			textField.background = true;
			textField.backgroundColor = style.backgroundColor;
			textField.text = "00:000/00:000";
			textField.x = textField.y = style.margin;
			addChild(textField);
			messanger.addEventListener(ControlEvent.VIDEO_PROGRESS, update);
			messanger.addEventListener(ControlEvent.VIDEO_COMPLETE, onComplete);
		}
		
		private function onComplete(e:ControlEvent):void
		{
			messanger.removeEventListener(ControlEvent.VIDEO_PROGRESS, update);
			messanger.removeEventListener(ControlEvent.VIDEO_COMPLETE, onComplete);
		}
		
		private function update(e:ControlEvent):void
		{
			textField.text = [parseDate(Number(e.data.time)), "/", parseDate(Number(e.data.duration))].join("");
		}
		
		private function parseDate(time:Number):String
		{
			date.time = time;
			var value:String = String(date.getUTCMilliseconds());
			return [date.toTimeString().match(/\d\d/g)[2], ":", prefices[value.length], value].join("");
		}
	
	}

}