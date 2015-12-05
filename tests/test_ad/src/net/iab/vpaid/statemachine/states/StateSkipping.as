package net.iab.vpaid.statemachine.states 
{
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * StateSkipping dispatches events through messanger instance on exit.
	 * 
     * @copy net.iab.vpaid.events.VPAIDEvent#AdSkipped
     */
    [Event(name = "AdSkipped", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>skipAd</li>
	 * <li>AdUserSkip</li>
	 * </ul>
	 * By virtue of extending StateStopping state it accomplishes internal destruction processes that are folloed by dispatching of AdStopped event. 
	 * In addition it reports AdSkipped event.
	 * @author Andrei Andreev
	 */
	public class StateSkipping extends StateStopping
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateSkipping(global:AdGlobal) 
		{
			super(global);
		}
		/**
		 * Override to dispatch AdSkipped event before AdStopped event is reported.
		 * @see net.iab.vpaid.events.VPAIDEvent#AdSkipped
		 * @see net.iab.vpaid.events.VPAIDEvent#AdStopped
		 */
		override protected function exit():void 
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSkipped));
			super.exit();
		}
		
	}

}