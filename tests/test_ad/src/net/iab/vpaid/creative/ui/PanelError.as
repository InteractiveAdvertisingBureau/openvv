package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.events.VPAIDEvent;
	
	/**
	 * Dispatches events through global messanger instance.
	 * 
	 * @copy net.iab.vpaid.events.VPAIDEvent#AdError
	 */
	[Event(name = "AdError", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Allows for simulating internal ad error and error message.
	 * @author Andrei Andreev
	 */
	public class PanelError extends ButtonPanel
	{
		private var button:AdButton;
		private var input:LabeledInput;
		private var global:AdGlobal;
		
		public function PanelError(messanger:EventDispatcher)
		{
			super(messanger);
		}
		
		override protected function configureUI():void
		{
			style = new Styles().buttonPanel;
			button = new AdButton("AD ERROR", 120);
			input = new LabeledInput("message:", "Error Message");
			buttons = new <AdButton>[button];
		}
		
		override protected function placeUI():void
		{
			super.placeUI();
			input.x = style.margin;
			input.y = button.y + button.height + style.padding;
			addChild(input);
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdError, {message: input.text}));
		}
	
	}

}