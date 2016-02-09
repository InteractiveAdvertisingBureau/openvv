package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.creative.AdSprite;
	
	/**
	 * Supper class of ad contorls panels. 
	 * @author Andrei Andreev
	 */
	public class ButtonPanel extends AdSprite
	{
		private var _buttons:Vector.<AdButton>;
		private var _messanger:EventDispatcher;
		/**
		 * 
		 * @param	messanger global EventDispatcher used throughout the application
		 */
		public function ButtonPanel(messanger:EventDispatcher)
		{
			init(messanger);
		}
		
		private function init(messanger:EventDispatcher):void
		{
			_messanger = messanger;
			style = new Styles().buttonPanel;
			configureUI();
			draw();
		}
		
		/**
		 * Must be overridden by subclasses
		 */
		protected function configureUI():void
		{
			// UI elements must be instantiated here
		}
		
		private function draw():void
		{
			placeUI();
			drawBackground();
		}
		
		private function drawBackground():void
		{
			style.width = this.width + style.margin * 2;
			style.height = this.height + style.margin * 2;
			var background:RectangularShape = new RectangularShape(style);
			addChildAt(background, 0);
		}
		
		protected function placeUI():void
		{
			/**
			 * Button y
			 */
			var by:Number = style.margin;
			for each (var button:AdButton in _buttons)
			{
				button.x = style.margin;
				button.y = by;
				by += button.height + style.padding;
				addChild(button);
				button.addEventListener(MouseEvent.CLICK, onButtonClick);
			}
		}
		
		protected function onButtonClick(e:MouseEvent):void
		{
		/**
		 * Must be overridden by subclass
		 */
		}
		
		public function set buttons(value:Vector.<AdButton>):void
		{
			_buttons = value;
		}
		
		public function get messanger():EventDispatcher
		{
			return _messanger || new EventDispatcher();
		}
		
		override public function dispose():void
		{
			super.dispose();
			_messanger = null;
			for each (var button:AdButton in _buttons)
			{
				button.removeEventListener(MouseEvent.CLICK, onButtonClick);
				removeChild(button);
			}
		}
	
	}

}