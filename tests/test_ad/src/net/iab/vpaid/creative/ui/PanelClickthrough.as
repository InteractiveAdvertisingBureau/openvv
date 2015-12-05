package net.iab.vpaid.creative.ui
{
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * Dispatches events through the global messanger instance.
     * @copy net.iab.vpaid.events.VPAIDEvent#AdClickThru
     */
    [Event(name = "AdClickThru", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * Allows to emulate Clickthrough and report AdClickThru event with url, Id, and playerHandles values. 
	 * 
	 * <p>Does not trigger actual Clickthrough user redirect.</p>
	 * 
	 * @author Andrei Andreev
	 */
	public class PanelClickthrough extends ButtonPanel
	{
		private var button:AdButton;
		private var idInput:LabeledInput;
		private var urlInput:LabeledInput;
		private var playerHandlesInput:LabeledInput;
		public function PanelClickthrough(messanger:EventDispatcher)
		{
			super(messanger);
		}
		
		override protected function configureUI():void
		{
			button = new AdButton("CLICKTHROUGH", 120);
			idInput = new LabeledInput("Id:", "ClickthroughID");
			urlInput = new LabeledInput("url:", "http://subdomain.domain.com/analytics");
			playerHandlesInput = new LabeledInput("playerHandles:", "false");
			buttons = new <AdButton>[button];
		}
		
		override protected function placeUI():void
		{
			super.placeUI();
			var style:Style = new Styles().buttonPanel;
			urlInput.x = idInput.x = playerHandlesInput.x = style.margin;
			urlInput.y = button.y + button.height + style.padding;
			idInput.y = urlInput.y + urlInput.height + style.padding;
			playerHandlesInput.y = idInput.y + idInput.height + style.padding;
			addChild(urlInput);
			addChild(idInput);
			addChild(playerHandlesInput);
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdClickThru, {url: urlInput.text, Id: idInput.text, playerHandles: playerHandlesInput.text}));
		}
	
	}

}