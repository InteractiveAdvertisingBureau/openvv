package net.iab.vpaid.core
{
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.creative.ui.Textures;
	
	/**
	 * Collection of styles used throught the application.
	 * @author Andrei Andreev
	 */
	public class Styles extends Object
	{
		
		public function get blackBackground():Style
		{
			var style:Style = new Style();
			return style;
		}
		
		public function get videoBackground():Style
		{
			var style:Style = new Style();
			style.color = 0x000000;
			return style;
		}
		
		public function get buttonPanel():Style
		{
			var style:Style = new Style();
			style.margin = 6;
			style.padding = 6;
			style.bitmapData = Textures.mesh();
			style.cornerRadius = 10;
			return style;
		}
		
		public function get countdown():Style
		{
			var style:Style = buttonPanel;
			style.fontName = "OCR";
			style.backgroundColor = 0x000000;
			style.fontSize = 12;
			style.textColor = 0xFFFFFF;
			return style;
		}
		
		public function get buttonUp():Style
		{
			var style:Style = new Style()
			style.lineThickness = 1;
			style.height = 22;
			style.cornerRadius = 7;
			style.lineAlpha = 1;
			style.alpha = 1;
			style.gradientColors = [0xF8E085, 0xF1C40F];
			style.gradientAlphas = [1, 1];
			style.gradientRatios = [0x00, 0xFF];
			style.textColor = 0xFFFFFF;
			style.fontSize = 10;
			style.fontName = "ArialBold";
			
			return style;
		}
		
		public function get buttonOver():Style
		{
			var style:Style = buttonUp;
			style.gradientColors = [0xF1C40F, 0xF8E085];
			return style;
		}
		
		public function get adControls():Style
		{
			var style:Style = new Style();
			style.margin = 10;
			style.padding = 6;
			return style;
		}
		
		public function get gridLabel():Style
		{
			var style:Style = new Style();
			style.fontName = "OCR";
			style.fontSize = 9;
			style.fontWeight = "bold";
			style.backgroundColor = 0xF1C40F;
			return style;
		}
		
		public function get inputLabel():Style
		{
			var style:Style = new Style();
			style.fontSize = 11;
			style.fontName = "ArialBold";
			style.textColor = 0x000000;
			return style;
		}
		
		public function get labledInput():Style
		{
			var style:Style = new Style();
			style.margin = 4;
			style.lineColor = 0xF1C40F;
			style.color = 0xEBEBEB;
			style.lineThickness = 0;
			style.fontSize = 11;
			style.textColor = 0x000000;
			style.fontName = "ArialNormal";
			return style;
		}
	
	}

}