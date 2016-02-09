package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.events.VPAIDEvent;
	
	/**
	 * Dispatches events through global messanger instance.
	 *
	 * @copy net.iab.vpaid.events.VPAIDEvent#AdUserSkip
	 */
	[Event(name = "AdUserSkip", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Dispatches events through global messanger instance.
	 *
	 * @copy net.iab.vpaid.events.VPAIDEvent#AdUserClose
	 */
	[Event(name = "AdUserClose", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Allows to trigger user initiated ad closure and ad skip.
	 * @author Andrei Andreev
	 */
	public class PanelAdEnd extends ButtonPanel
	{
		private var skipButton:AdButton;
		private var stopButton:AdButton;
		
		public function PanelAdEnd(messanger:EventDispatcher)
		{
			super(messanger);
		}
		
		override protected function configureUI():void
		{
			skipButton = new AdButton("SKIP AD", 120);
			stopButton = new AdButton("CLOSE AD", 120);
			buttons = new <AdButton>[skipButton, stopButton];
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			switch (e.currentTarget)
			{
				case skipButton: 
					messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserSkip));
					break;
				
				case stopButton: 
					messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdUserClose));
					break;
			}
		}
	
	}

}