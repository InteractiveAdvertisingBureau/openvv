package net.iab.vpaid.statemachine.states
{
	import flash.display.Sprite;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * StateStopping dispatches events through messanger instance on exit.
	 * <p>AdStarted event serves as a transition trigger.</p>
     * @copy net.iab.vpaid.events.VPAIDEvent#AdStopped
     */
    [Event(name = "AdStopped", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>stopAd</li>
	 * <li>AdUserClose</li>
	 * <li>AdAutoStop</li>
	 * </ul>
	 * @author Andrei Andreev
	 */
	public class StateStopping extends VPAIDState
	{
		
		public function StateStopping(global:AdGlobal)
		{
			super(global);
		}
		/**
		 * The mission:
		 * <ul>
		 * <li>Removes ad from display list.</li>
		 * <li>initiates destruction processes.</li>
		 * </ul>
		 * @copy net.iab.vpaid.statemachine.states.VPAIDState#enter()
		 */
		override public function enter():void
		{
			var root:Sprite = global.root;
			var content:Sprite = global.assetsLoader.content;
			if (root.contains(content))
				root.removeChild(content);
			global.dispose();
			exit();
		}
		/**
		 * @copy net.iab.vpaid.statemachine.states.VPAIDState#exit()
		 */
		override protected function exit():void
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStopped));
		}
	
	}

}