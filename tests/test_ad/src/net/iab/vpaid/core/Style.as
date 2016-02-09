package net.iab.vpaid.core 
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * Default styling values.
	 * 
	 * @author Andrei Andreev
	 */
	public class Style extends Object
	{
		public var width:Number = 0;
		public var height:Number = 0;
		public var color:uint = 0x000000;
		public var alpha:Number = 1;
		public var lineColor:uint = 0x000000;
		public var lineThickness:Number = 0;
		public var lineAlpha:Number = 1;
		public var cornerRadius:Number = 0;
		public var registrationPoint:Point = new Point(0, 0);
		public var bitmapData:BitmapData = null;
		public var fontName:String = "Arial";
		public var fontSize:Number = 12;
		public var fontWeight:String = "normal";
		public var backgroundColor:uint = 0xFFFFFF;
		public var textColor:uint = 0xFFFFFF;
		public var gradientColors:Array;
		public var gradientAlphas:Array;
		public var gradientRatios:Array;
		public var margin:Number = 0;
		public var padding:Number = 0;
		public function Style() 
		{
			
		}
		
	}

}