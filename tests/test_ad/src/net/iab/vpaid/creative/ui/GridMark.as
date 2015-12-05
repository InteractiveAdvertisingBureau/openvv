package net.iab.vpaid.creative.ui
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	
	/**
	 * Individual mark used by Grid.
	 * 
	 * @see net.iab.vpaid.creative.Grid
	 * 
	 * @author Andrei Andreev
	 */
	public class GridMark extends Shape
	{
		/**
		 * 
		 * @param	size mark width and height
		 * @param	drawCircle instructs to draw circle around mark's center point
		 */
		public function GridMark(size:int, drawCircle:Boolean = false)
		{
			draw(size, drawCircle);
		}
		
		private function draw(size:int, drawCircle:Boolean = false):void
		{
			var legThickness:Number = 1;
			var sizeHalf:Number = size * .5;
			var commands:Vector.<int> = new <int>[1, 2, 1, 2];
			var coordinates:Vector.<Number> = new <Number>[-sizeHalf, 0, sizeHalf, 0, 0, -sizeHalf, 0, sizeHalf];
			graphics.lineStyle(legThickness);
			graphics.lineBitmapStyle(bitmapData);
			if (drawCircle)
				graphics.drawCircle(0, 0, size * .25);
			
			graphics.drawPath(commands, coordinates);
		}
		
		private function get bitmapData():BitmapData
		{
			var light:uint = 0xFFFFFF;
			var dark:uint = 0x000000;
			var opacity:Number = .6;
			var markTemplate:Shape = new Shape();
			var g:Graphics = markTemplate.graphics;
			g.beginFill(dark, opacity);
			g.drawRect(0, 0, 1, 1);
			g.drawRect(1, 1, 1, 1);
			g.endFill();
			g.beginFill(light, opacity);
			g.drawRect(1, 0, 1, 1);
			g.drawRect(0, 1, 1, 1);
			
			var bitmapData:BitmapData = new BitmapData(2, 2, true, 0x00000000);
			bitmapData.draw(markTemplate);
			
			return bitmapData;
		}
	
	}

}