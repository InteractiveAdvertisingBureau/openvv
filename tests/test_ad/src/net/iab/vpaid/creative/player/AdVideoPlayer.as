package net.iab.vpaid.creative.player
{
	import flash.events.EventDispatcher;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.creative.AdSprite;
	import net.iab.vpaid.creative.ui.RectangularShape;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Top level object that represents video player.
	 * @author Andrei Andreev
	 */
	public class AdVideoPlayer extends AdSprite
	{
		private var background:RectangularShape;
		private var video:AdVideo;
		/**
		 * 
		 * @param	adData global configuration data
		 * @param	vpaidParams instance that manages VPAIS properties
		 * @param	messanger global event dispatcher
		 */
		public function AdVideoPlayer(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher)
		{
			init(adData, vpaidParams, messanger);
		}
		
		private function init(adData:AdData, vpaidParams:VPAIDParams, messanger:EventDispatcher):void
		{
			style = new Styles().videoBackground;
			background = new RectangularShape();
			video = new AdVideo(adData, vpaidParams, messanger);
		}
		/**
		 * 
		 * Initiates video playback.
		 */
		public function startAd():void
		{
			video.play();
		}
		/**
		 * Resizes and repositions objects based on arguments values.
		 * @param	width
		 * @param	height
		 */
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
			addChild(background);
			addChild(video);
			style.width = width;
			style.height = height;
			background.style = style;
			video.setSize(width, height);
		}
		/**
		 * 
		 * Pauses video playback.
		 */
		public function pause():void
		{
			video.pause();
		}
		/**
		 * Resumes video playback.
		 */
		public function resume():void
		{
			video.resume();
		}
		/**
		 * 
		 * Mutes/unmutes video.
		 */
		public function set muted(value:Boolean):void
		{
			video.muted = value;
		}
		/**
		 *
		 * @copy net.iab.vpaid.creative.AdSprite#dispose()
		 */
		override public function dispose():void
		{
			if (video)
			{
				video.dispose();
				if (this.contains(video)) {
					removeChild(video);
					removeChild(background);
				}
				
			}
		}
	
	}

}