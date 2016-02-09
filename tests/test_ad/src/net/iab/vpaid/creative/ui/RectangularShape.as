package net.iab.vpaid.creative.ui
{
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.creative.AdSprite;
	
	/**
	 * Abstract stylable visual that takes rectangualr shape.
	 *
	 * @author Andrei Andreev
	 */
	public class RectangularShape extends AdSprite
	{
		public function RectangularShape(style:Style = null)
		{
			this.style = style;
		}
		
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
			style.width = width;
			style.height = height;
			draw();
		}
		
		private function draw():void
		{
			graphics.clear();
			if (style.lineThickness > 0)
				graphics.lineStyle(style.lineThickness, style.lineColor, style.lineAlpha, true);
			if (style.bitmapData)
				graphics.beginBitmapFill(style.bitmapData);
			else
				graphics.beginFill(style.color, style.alpha);
			
			graphics.drawRoundRect(style.registrationPoint.x, style.registrationPoint.y, style.width, style.height, style.cornerRadius, style.cornerRadius);
		}
		
		/**
		 * Setting of style trggers graphics re-draw.
		 */
		override public function set style(value:Style):void
		{
			super.style = value;
			if (style)
				draw();
		}
	
	}

}