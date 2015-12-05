package net.iab.simulators.player 
{
	import flash.display.Sprite;
	import net.iab.vpaid.creative.ui.Textures;
	/**
	 * Super class for player simulator control panels.
	 * @author Andrei Andreev
	 */
	public class ControlPanel extends Sprite 
	{
		protected var padding:Number = 4;
		public function ControlPanel() 
		{
			init();
		}
		
		protected function init():void 
		{
			
		}
		
		protected function drawBackground():void {
			graphics.beginBitmapFill(Textures.mesh());
			graphics.drawRect(0, 0, width + padding * 2, height + padding * 2);
		}
		
	}

}