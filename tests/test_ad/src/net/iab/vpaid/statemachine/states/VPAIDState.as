package net.iab.vpaid.statemachine.states
{
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.VPAIDAPI;
	
	/**
	 * Super Class of State Machine States/abstract state.
	 * @author Andrei Andreev
	 */
	public class VPAIDState extends VPAIDAPI
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function VPAIDState(global:AdGlobal)
		{
			super(global);
		}
		
		/**
		 * Parallels UML state machine enter function paradigm.
		 */
		public function enter():void
		{
		}
		
		/**
		 * Parallels UML state machine do function paradigm.
		 */
		protected function execute():void
		{
		}
		
		/**
		 * Parallels UML state machine exit function paradigm.
		 */
		protected function exit():void
		{
		
		}
		
		protected function dispose():void {
			
		}
	}

}