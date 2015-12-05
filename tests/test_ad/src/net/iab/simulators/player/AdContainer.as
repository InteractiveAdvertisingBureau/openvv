package net.iab.simulators.player 
{
	import flash.display.Sprite;
	import net.iab.vpaid.creative.ui.Textures;
	import net.iab.vpaid.IVPAID;
	import net.iab.vpaid.VPAIDAd;
	/**
	 * Conteiner of actual ad loaded by the player simulator.
	 * @author Andrei Andreev
	 */
	public class AdContainer extends Sprite
	{
		private var _width:Number = 0;
		private var _height:Number = 0;
		private var ad:Sprite;
		public function AdContainer(width:Number, height:Number) 
		{
			resizeAd(width, height);
		}
		
		public function resizeAd(width:Number, height:Number):void 
		{
			_width = width;
			_height = height;
			drawBackground();
			
		}
		
		private function drawBackground():void 
		{
			graphics.beginBitmapFill(Textures.mesh());
			graphics.drawRect(0, 0, _width, _height);
		}
		
		public function loadAd():void {
			ad = new VPAIDAd();
			addChild(ad);
			dispatchEvent(new PlayerEvent(PlayerEvent.AD_LOADED));
		}
		
		public function getVPAID():* {
			var vpaidAd:VPAIDAd = new VPAIDAd();
			return Object(ad).getVPAID();
		}
		
		
		
	}

}