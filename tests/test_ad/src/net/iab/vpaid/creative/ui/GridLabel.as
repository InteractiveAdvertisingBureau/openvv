package net.iab.vpaid.creative.ui
{
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flashx.textLayout.formats.TextAlign;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	
	/**
	 * Grid label.
	 * 
	 * @see net.iab.vpaid.creative.Grid
	 * 
	 * @author Andrei Andreev
	 */
	public class GridLabel extends TextField
	{
		
		public function GridLabel()
		{
			init();
		}
		
		private function init():void
		{
			var style:Style = new Styles().gridLabel
			defaultTextFormat = new TextFormat(style.fontName, style.fontSize, style.color, style.fontWeight, null, null, null, null, TextAlign.LEFT, 0, 2);
			autoSize = TextAlign.LEFT;
			embedFonts = true;
			gridFitType = GridFitType.PIXEL;
			antiAliasType = AntiAliasType.ADVANCED;
			sharpness = 100;
			thickness = 0;
			background = true;
			backgroundColor = style.backgroundColor;
			text = text;
		}
	
	}

}