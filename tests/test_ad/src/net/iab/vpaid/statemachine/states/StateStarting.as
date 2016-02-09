package net.iab.vpaid.statemachine.states
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.events.VPAIDEvent;
	
	/**
	 * StateStarting dispatches events through messanger instance on exit.
	 * <p>AdStarted event serves as a transition trigger.</p>
	 * @copy net.iab.vpaid.events.VPAIDEvent#AdStarted
	 */
	[Event(name = "AdStarted", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>startAd</li>
	 * </ul>
	 * Transition occurs when player calls IVPAID.startAd() method.
	 * @see net.iab.vpaid.IVPAID#startAd()
	 *
	 * @author Andrei Andreev
	 */
	public class StateStarting extends VPAIDState
	{
		private var timer:Timer;
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateStarting(global:AdGlobal)
		{
			super(global);
		}
		
		override public function enter():void
		{
			execute();
		}
		
		/**
		 * Simulates a short startup process
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
			exit();
		}
		
		override protected function exit():void
		{
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdStarted));
		}
	
	}

}