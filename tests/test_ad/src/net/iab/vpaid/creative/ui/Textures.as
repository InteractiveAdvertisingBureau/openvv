package net.iab.vpaid.creative.ui
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	/**
	 * Draws BitmapData for checkers mash.
	 * @author Andrei Andreev
	 */
	public class Textures
	{
		public static function mesh(light:uint = 0xFFFFFF, dark:uint = 0x000000, opacity:Number = .5):BitmapData
		{
			var shape:Shape = new Shape();
			var g:Graphics = shape.graphics;
			g.beginFill(light, opacity);
			g.drawRect(0, 0, 1, 1);
			g.drawRect(1, 1, 1, 1);
			g.endFill();
			g.beginFill(dark, opacity);
			g.drawRect(1, 0, 1, 1);
			g.drawRect(0, 1, 1, 1);
			g.endFill();
			
			var bitmapData:BitmapData = new BitmapData(2, 2, true, 0x00000000);
			bitmapData.draw(shape);
			return bitmapData
		}
	
	}

}