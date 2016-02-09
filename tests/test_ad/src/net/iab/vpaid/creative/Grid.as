package net.iab.vpaid.creative
{
	import flash.display.Shape;
	import flash.text.TextField;
	import net.iab.vpaid.creative.ui.GridLabel;
	import net.iab.vpaid.creative.ui.GridMark;
	
	/**
	 * Visual that draws grid overlay.
	 * @author Andrei Andreev
	 */
	public class Grid extends AdSprite
	{
		private var dimensionsLabel:TextField;
		private var gridSize:int = 8;
		private var smallMarkSize:int = 9;
		private var largeMarkSize:int = 40;
		private var marks:Vector.<Shape>;
		
		public function Grid()
		{
			init();
		}
		
		private function init():void
		{
			drawMarks();
			drawLabel();
		}
		/**
		 * 
		 * @copy net.iab.vpaid.creative.AdSprite#setSize()
		 */
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
			update();
		}
		/**
		 * Repositions element to fit current dimensions.
		 */
		private function update():void
		{
			updateGrid();
			var padding:int = 10;
			dimensionsLabel.text = ["unit:", int(_width / gridSize), "x", int(_height / gridSize), "\nwidth:", _width, "\nheight:", _height].join("");
			dimensionsLabel.x = _width - (dimensionsLabel.width + padding);
			dimensionsLabel.y = padding;
		}
		/**
		 * Draws individual mark elements.
		 */
		private function drawMarks():void
		{
			marks = new Vector.<Shape>();
			var divider:Number = gridSize + 1;
			var numElements:int = divider * divider;
			for (var i:int = 0; i < numElements; i++)
			{
				switch (i)
				{
					case 4: 
					case 36: 
					case 40: 
					case 44: 
					case 76: 
						marks.push(new GridMark(largeMarkSize, true));
						break;
					
					default: 
						marks.push(new GridMark(smallMarkSize));
						break;
				}
			}
		
		}
		/**
		 * Draws grid label that describes grid paramters.
		 */
		private function drawLabel():void
		{
			dimensionsLabel = new GridLabel();
			addChild(dimensionsLabel);
		}
		/**
		 * Repositions grid marks to accommodate current dimensions.
		 */
		private function updateGrid():void
		{
			var divider:Number = gridSize + 1;
			var numElements:int = divider * divider;
			var sectionWidth:Number = (_width - 2) / gridSize;
			var sectionHeight:Number = (_height - 2) / gridSize;
			
			for (var i:int = 0; i < numElements; i++)
			{
				var mark:Shape = marks[i];
				addChild(mark);
				mark.x = sectionWidth * (i % divider);
				mark.y = sectionHeight * int(i / divider);
			}
		}
	
	}

}