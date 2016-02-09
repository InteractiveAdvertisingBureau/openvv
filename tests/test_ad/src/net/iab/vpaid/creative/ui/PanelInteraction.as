package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * Dispatches events through messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdInteraction
     */
    [Event(name = "AdInteraction", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Alows to report custrom AdInteraction with custom Id.
	 * 
	 * @author Andrei Andreev
	 */
	public class PanelInteraction extends ButtonPanel
	{
		private var button:AdButton;
		private var input:LabeledInput;
		
		public function PanelInteraction(messanger:EventDispatcher)
		{
			super(messanger);
		}
		
		override protected function configureUI():void
		{
			button = new AdButton("INTERACTION", 120);
			input = new LabeledInput("Id:", "InteractionID");
			buttons = new <AdButton>[button];
		}
		
		override protected function placeUI():void
		{
			super.placeUI();
			var style:Style = new Styles().buttonPanel;
			input.x = style.margin;
			input.y = button.y + button.height + style.padding;
			addChild(input);
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdInteraction, {Id: input.text}));
		}
	
	}

}