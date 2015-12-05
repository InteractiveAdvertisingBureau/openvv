package net.iab.simulators.player
{
	import flash.display.DisplayObject;
	import net.iab.vpaid.events.VPAIDEvent;
	
	/**
	 * Set of VPAID Event feedbacks used by the player simulator
	 * @author Andrei Andreev
	 */
	public class EventsPanel extends ControlPanel
	{
		private var elements:Array;
		private var AdLoaded:EventElement;
		private var AdStarted:EventElement;
		private var AdStopped:EventElement;
		private var AdSkipped:EventElement;
		private var AdSkippableStateChange:EventElement;
		private var AdSizeChange:EventElement;
		private var AdLinearChange:EventElement;
		private var AdDurationChange:EventElement;
		private var AdExpandedChange:EventElement;
		private var AdVolumeChange:EventElement;
		private var AdImpression:EventElement;
		private var AdVideoStart:EventElement;
		private var AdVideoFirstQuartile:EventElement;
		private var AdVideoMidpoint:EventElement;
		private var AdVideoThirdQuartile:EventElement;
		private var AdVideoComplete:EventElement;
		private var AdClickThru:EventElement;
		private var AdInteraction:EventElement;
		private var AdUserAcceptInvitation:EventElement;
		private var AdUserMinimize:EventElement;
		private var AdUserClose:EventElement;
		private var AdPaused:EventElement;
		private var AdPlaying:EventElement;
		private var AdLog:EventElement;
		private var AdError:EventElement;
		
		public function EventsPanel()
		{
		
		}
		
		override protected function init():void
		{
			AdLoaded = new EventElement("AdLoaded");
			AdStarted = new EventElement("AdStarted");
			AdStopped = new EventElement("AdStopped");
			AdSkipped = new EventElement("AdSkipped");
			AdSkippableStateChange = new EventElement("AdSkippableStateChange");
			AdSizeChange = new EventElement("AdSizeChange");
			AdLinearChange = new EventElement("AdLinearChange");
			AdDurationChange = new EventElement("AdDurationChange");
			AdExpandedChange = new EventElement("AdExpandedChange");
			AdVolumeChange = new EventElement("AdVolumeChange");
			AdImpression = new EventElement("AdImpression");
			AdVideoStart = new EventElement("AdVideoStart");
			AdVideoFirstQuartile = new EventElement("AdVideoFirstQuartile");
			AdVideoMidpoint = new EventElement("AdVideoMidpoint");
			AdVideoThirdQuartile = new EventElement("AdVideoThirdQuartile");
			AdVideoComplete = new EventElement("AdVideoComplete");
			AdClickThru = new EventElement("AdClickThru");
			AdInteraction = new EventElement("AdInteraction");
			AdUserAcceptInvitation = new EventElement("AdUserAcceptInvitation");
			AdUserMinimize = new EventElement("AdUserMinimize");
			AdUserClose = new EventElement("AdUserClose");
			AdPaused = new EventElement("AdPaused");
			AdPlaying = new EventElement("AdPlaying");
			AdLog = new EventElement("AdLog");
			AdError = new EventElement("AdError");
			elements = [AdLoaded, AdStarted, AdStopped, AdSkipped, AdSkippableStateChange, AdSizeChange, AdLinearChange, AdDurationChange, AdExpandedChange, AdVolumeChange, AdImpression, AdVideoStart, AdVideoFirstQuartile, AdVideoMidpoint, AdVideoThirdQuartile, AdVideoComplete, AdClickThru, AdInteraction, AdUserAcceptInvitation, AdUserMinimize, AdUserClose, AdPaused, AdPlaying, AdLog, AdError];
			placeElements();
			drawBackground();
		}
		
		private function placeElements():void
		{
			var by:Number = padding;
			var halfLength:int = Math.ceil(elements.length / 2);
			for (var i:int = 0; i < elements.length; i++)
			{
				var element:DisplayObject = elements[i];
				addChild(element);
				element.x = (element.width + padding) * int(i /  halfLength) + padding; 
				element.y = (element.height + padding) * (i % halfLength ) + padding;
			}
		}
		
		public function set vpaidEvent(e:VPAIDEvent):void {
			trace(this, "vpaidEvent", e.type);
			var type:String = e.type;
			if (type === VPAIDEvent.AdAutoStop) return;
			if (type === VPAIDEvent.AdUserSkip) {
				type = VPAIDEvent.AdSkipped;
			}
			if (this[type]) {
				EventElement(this[type]).increment();
			}
		}
	
	}

}