package net.iab.vpaid.creative
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.creative.player.AdVideoPlayer;
	import net.iab.vpaid.creative.ui.RectangularShape;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Top class that renders and manages linear ad's visuals.
	 * 
	 * @author Andrei Andreev
	 */
	public class LinearCreative extends AdSprite
	{
		private var background:RectangularShape;
		private var grid:Grid;
		private var player:AdVideoPlayer;
		private var adControls:AdControls;
		private var elements:Vector.<AdSprite>;
		private var vpaidParams:VPAIDParams;
		
		public function LinearCreative(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher)
		{
			init(adData, vpaidParams, messanger);
		}
		
		private function init(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher):void
		{
			this.vpaidParams = vpaidParams;
			background = new RectangularShape(new Styles().blackBackground);
			grid = new Grid();
			player = new AdVideoPlayer(adData, vpaidParams, messanger);
			adControls = new AdControls(messanger, player, grid);
			/**
			 * Indexes must be the same as display list depth values.
			 */
			elements = new <AdSprite>[background, player, grid, adControls];
			/**
			 * Any click on ad is considered active user enagement.
			 * Active engagement cancels ad auto stop
			 */
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			/**
			 * adDuration becomes unkown
			 */
			vpaidParams.adDuration = -2;
		}
		/**
		 * 
		 * @copy net.iab.vpaid.creative.AdSprite#setSize()
		 */
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
			for each (var element:AdSprite in elements)
			{
				addChild(element);
				element.setSize(width, height);
			}
		
		}
		/**
		 * Pauses video player.
		 */
		public function pauseAd():void
		{
			player.pause();
		}
		/**
		 * Resumes video player.
		 */
		public function resumeAd():void
		{
			player.resume();
		}
		/**
		 * Initiates video playback.
		 */
		public function startAd():void
		{
			player.startAd();
		}
		/**
		 * 
		 * @copy net.iab.vpaid.creative.AdSprite#dispose()
		 */
		override public function dispose():void
		{
			super.dispose();
			for each (var element:AdSprite in elements)
			{
				if (this.contains(element))
					removeChild(element);
				element.dispose();
			}
		}
	
	}

}