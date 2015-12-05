package net.iab.simulators.player
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import net.iab.vpaid.events.VPAIDEvent;
	import net.iab.vpaid.IVPAID;
	
	/**
	 * Document class of the ad player simulator that allows for manual ad unit testing.
	 * @author Andrei Andreev
	 */
	public class VPAIDPlayer extends Sprite
	{
		private var controls:VPAIDControls;
		private var adContainer:AdContainer;
		private var vpaid:IVPAID;
		private var adWidth:Number = 0;
		private var adHeight:Number = 0;
		
		public function VPAIDPlayer()
		{
			init();
		}
		
		private function init():void
		{
			var padding:Number = 10;
			configureStage();
			controls = new VPAIDControls();
			controls.x = controls.y = padding;
			adWidth = stage.stageWidth - controls.width - padding * 3;
			adHeight = stage.stageHeight - padding * 2;
			adContainer = new AdContainer(adWidth, adHeight);
			adContainer.x = controls.x + controls.width + padding;
			adContainer.y = padding;
			addChild(adContainer);
			addChild(controls);
			addListeners();
		}
		
		private function addListeners():void
		{
			for each (var type:String in PlayerEvent.TypesList)
			{
				controls.addEventListener(type, onControlEvent);
				adContainer.addEventListener(type, onAdFeedback);
			}
		}
		
		private function onAdFeedback(e:Event):void
		{
			trace(this, "onAdFeedback", e.type);
			switch (e.type)
			{
				case PlayerEvent.AD_LOADED:
					
					break;
			}
		}
		
		private function onVPAIDEvent(e:VPAIDEvent):void
		{
			trace(this, "onVPAIDEvent", e.type);
			controls.vpaidEvent = e;
		}
		
		private function onControlEvent(e:PlayerEvent):void
		{
			trace(this, "onControlEvent", e.type);
			switch (e.type)
			{
				case PlayerEvent.LOAD_AD: 
					adContainer.loadAd();
					break;
				
				case PlayerEvent.GET_VPAID: 
					getVPAID();
					break;
				
				case PlayerEvent.HANDSHAKE_VERSION: 
					controls.handshakeVersion = vpaid.handshakeVersion("2.1.1");
					break;
				
				case PlayerEvent.INIT_AD: 
					vpaid.initAd(400, 400);
					break;
				
				case PlayerEvent.START_AD: 
					vpaid.startAd();
					break;
				
				case PlayerEvent.RESIZE_AD: 
					vpaid.resizeAd(adWidth, adHeight);
					break;
				
				case PlayerEvent.AD_WIDTH: 
					controls.property = {key: "adWidth", value: vpaid.adWidth};
					break;
				
				case PlayerEvent.AD_HEIGHT: 
					controls.property = {key: "adHeight", value: vpaid.adHeight};
					break;
				
				case PlayerEvent.AD_REMAINING_TIME: 
					controls.property = {key: "adRemainingTime", value: vpaid.adRemainingTime};
					break;
				
				case PlayerEvent.AD_DURATION: 
					controls.property = {key: "adDuration", value: vpaid.adDuration};
					break;
				
				case PlayerEvent.AD_LINEAR: 
					controls.property = {key: "adLinear", value: vpaid.adLinear};
					break;
				
				case PlayerEvent.AD_EXPANDED: 
					controls.property = {key: "adExpanded", value: vpaid.adExpanded};
					break;
				
				case PlayerEvent.AD_SKIPPABLE_STATE: 
					controls.property = {key: "adSkippableState", value: vpaid.adSkippableState};
					break;
				
				case PlayerEvent.GET_AD_VOLUME: 
					controls.property = {key: "getAdVolume", value: vpaid.adVolume};
					break;
				
				case PlayerEvent.AD_COMPANIONS: 
					controls.property = {key: "adCompanions", value: vpaid.adCompanions};
					break;
				
				case PlayerEvent.AD_ICONS: 
					controls.property = {key: "adIcons", value: vpaid.adIcons};
					break;
				
				case PlayerEvent.SET_AD_VOLUME: 
					vpaid.adVolume = Number(e.data.value);
					break;
				
				case PlayerEvent.PAUSE_AD: 
					vpaid.pauseAd();
					break;
				case PlayerEvent.RESUME_AD: 
					vpaid.resumeAd();
					break;
				
				case PlayerEvent.STOP_AD: 
					vpaid.stopAd();
					break;
				
				case PlayerEvent.SKIP_AD: 
					vpaid.skipAd();
					break;
			}
		}
		
		private function getVPAID():void
		{
			vpaid = adContainer.getVPAID();
			for each (var type:String in VPAIDEvent.VPAIDTypes)
			{
				EventDispatcher(vpaid).addEventListener(type, onVPAIDEvent);
			}
		}
		
		private function configureStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
	
	}

}