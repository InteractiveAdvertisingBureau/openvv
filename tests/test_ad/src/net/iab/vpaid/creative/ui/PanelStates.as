package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.creative.player.AdVideoPlayer;
	import net.iab.vpaid.events.ControlEvent;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * Dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdUserClose
     */
    [Event(name = "AdUserClose", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdUserSkip
     */
    [Event(name = "AdUserSkip", type = "net.iab.vpaid.events.VPAIDEvent")]
	
	/**
	 * Contains UI that manages ad states including video playback progress, ad volume.
	 * @author Andrei Andreev
	 */
	public class PanelStates extends ButtonPanel
	{
		private var playPauseButton:ToggleButton;
		private var audioButton:ToggleButton;
		private var player:AdVideoPlayer;
		
		public function PanelStates(messanger:EventDispatcher, player:AdVideoPlayer)
		{
			super(messanger);
			this.player = player;
		}
		
		override protected function configureUI():void
		{
			playPauseButton = new ToggleButton("PAUSE AD", "RESUME AD", 120);
			audioButton = new ToggleButton("MUTE AD", "UNMUTE AD", 120);
			buttons = new <AdButton>[playPauseButton, audioButton];
			addListeners();
		}
		
		private function addListeners():void
		{
			for each (var type:String in ControlEvent.ControlTypes)
				messanger.addEventListener(type, onControlEvent);
		}
		
		private function onControlEvent(e:ControlEvent):void
		{ 
			switch (e.type)
			{
				case ControlEvent.PAUSE_AD: 
					playPauseButton.isActive = false;
					break;
				
				case ControlEvent.RESUME_AD: 
					playPauseButton.isActive = true;
					break;
				
				case ControlEvent.MUTE_AD: 
					audioButton.isActive = false;
					break;
				
				case ControlEvent.UNMUTE_AD: 
					audioButton.isActive = true;
					break;
				
				case ControlEvent.VIDEO_COMPLETE: 
					playPauseButton.isActive = false;
					playPauseButton.labelText = "REPLAY";
					break;
			}
		
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			switch (e.currentTarget)
			{
				case playPauseButton: 
					playPauseButton.isActive ? player.resume() : player.pause();
					break;
				
				case audioButton: 
					player.muted = !audioButton.isActive;
					break;
				
			}
		}
		
		override public function dispose():void
		{
			for each (var type:String in ControlEvent.ControlTypes)
				messanger.removeEventListener(type, onControlEvent);
			super.dispose();
		}
	
	}

}