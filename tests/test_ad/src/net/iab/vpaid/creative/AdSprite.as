package net.iab.vpaid.creative
{
	import flash.display.Sprite;
	import net.iab.vpaid.core.Style;
	
	/**
	 * Base class for resizable and stylable Sprite instances.
	 * @author Andrei Andreev
	 */
	public class AdSprite extends Sprite
	{
		protected var _width:Number = 0;
		protected var _height:Number = 0;
		private var _style:Style;
		
		public function AdSprite()
		{
		
		}
		/**
		 * Repositions and reasizes elements to fit visuals into provided dimensions.
		 * @param	width desired width
		 * @param	height desired height
		 */
		public function setSize(width:Number, height:Number):void
		{
			_width = width;
			_height = height;
		}
		/**
		 * Object containing styling properties.
		 * 
		 * @see net.iab.vpaid.core.Style
		 * @see net.iab.vpaid.core.Styles
		 */
		public function get style():Style
		{
			return _style;
		}
		
		public function set style(value:Style):void
		{
			_style = value;
		}
		/**
		 * Initializes destruction routines. 
		 */
		public function dispose():void
		{
		
		}
	
	}

}