package net.iab.simulators.player
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.iab.vpaid.creative.ui.AdButton;
	
	/**
	 * Container of elements that allow for tester manual calls to VPAID API.
	 * @author Andrei Andreev
	 */
	public class MethodsPanel extends ControlPanel
	{
		private var elements:Array;
		private var loadAd:AdButton;
		private var initAd:AdButton;
		private var resizeAd:AdButton;
		private var startAd:AdButton;
		private var stopAd:AdButton;
		private var pauseAd:AdButton;
		private var resumeAd:AdButton;
		private var expandAd:AdButton;
		private var collapseAd:AdButton;
		private var skipAd:AdButton;
		
		public function MethodsPanel()
		{
		
		}
		
		override protected function init():void
		{
			var bw:Number = 150;
			loadAd = new AdButton("loadAd", bw);
			initAd = new AdButton("initAd()", bw);
			resizeAd = new AdButton("resizeAd()", bw);
			startAd = new AdButton("startAd()", bw);
			stopAd = new AdButton("stopAd()", bw);
			pauseAd = new AdButton("pauseAd()", bw);
			resumeAd = new AdButton("resumeAd()", bw);
			expandAd = new AdButton("expandAd()", bw);
			collapseAd = new AdButton("collapseAd()", bw);
			skipAd = new AdButton("skipAd()", bw);
			elements = [loadAd, initAd, resizeAd, startAd, stopAd, pauseAd, resumeAd, expandAd, collapseAd, skipAd];
			
			placeElements();
			drawBackground();
		}
		
		private function placeElements():void
		{
			var by:Number = padding;
			for each (var element:DisplayObject in elements)
			{
				addChild(element);
				element.x = padding;
				element.y = by;
				by += element.height + padding;
				AdButton(element).addEventListener(MouseEvent.CLICK, onButtonCLick);
			}
		}
		
		private function onButtonCLick(e:MouseEvent):void
		{
			
			switch (e.currentTarget)
			{
				case loadAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.LOAD_AD));
					break;
				case initAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.INIT_AD));
					break;
				case resizeAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.RESIZE_AD));
					break;
				case startAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.START_AD));
					break;
				case stopAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.STOP_AD));
					break;
				case pauseAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.PAUSE_AD));
					break;
				case resumeAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.RESUME_AD));
					break;
				case expandAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.EXPAND_AD));
					break;
				case collapseAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.COLLAPSE_AD));
					break;
				case skipAd: 
					dispatchEvent(new PlayerEvent(PlayerEvent.SKIP_AD));
					break;
			
			}
		}
	}

}