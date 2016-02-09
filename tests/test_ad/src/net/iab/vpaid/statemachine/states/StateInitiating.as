package net.iab.vpaid.statemachine.states 
{
	import flash.events.Event;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.core.AssetsLoader;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * StateInitiating dispatches events through messanger instance on exit.
	 * <p>AdLoaded event serves as a transition trigger.</p>
     * @copy net.iab.vpaid.events.VPAIDEvent#AdLoaded
     */
    [Event(name = "AdLoaded", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>initAd</li>
	 * </ul>
	 * @see net.iab.vpaid.IVPAID#initAd()
	 * @author Andrei Andreev
	 */
	public class StateInitiating extends VPAIDState
	{
		private var loader:AssetsLoader;
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateInitiating(global:AdGlobal) 
		{
			super(global);
		}
		
		override public function enter():void 
		{
			global.viewabilityManager.init();
			loader = global.assetsLoader;
			loader.addEventListener(Event.COMPLETE, onLoad);
			loader.loadAssets();
		}
		
		private function onLoad(e:Event):void 
		{
			loader.removeEventListener(Event.COMPLETE, onLoad);
			loader = null;
			exit();
		}
		
		override protected function exit():void 
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdLoaded));
		}
		
	}

}