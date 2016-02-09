package net.iab.vpaid.statemachine.states 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * StateStarted dispatches events through messanger instance on exit.
	 * <p>AdImpression event serves as a transition trigger.</p>
	 * @copy net.iab.vpaid.events.VPAIDEvent#AdImpression
	 */
	[Event(name = "AdImpression", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>AdStarted</li>
	 * </ul>
	 * State adds creative to VPAID display list and reports AdImpression.
	 * @author Andrei Andreev
	 */
	public class StateStarted extends VPAIDState
	{
		private var timer:Timer;
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateStarted(global:AdGlobal) 
		{
			super(global);
		}
		
		override public function enter():void 
		{
			execute();
		}
		/**
		 * Simulate a short startup process
		 */
		override protected function execute():void 
		{
			timer = new Timer(200, 1);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
			timer.start();
		}
		
		private function onTimer(e:TimerEvent):void 
		{
			timer.removeEventListener(TimerEvent.TIMER, onTimer);
			timer = null;
			/**
			 * Add ad to display list.
			 */
			global.root.addChild(global.assetsLoader.content);
			exit();
		}
		
		override protected function exit():void 
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdImpression));
		}
		
	}

}