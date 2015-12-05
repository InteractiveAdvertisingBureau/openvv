package net.iab.vpaid.statemachine.states 
{
	import net.iab.vpaid.core.AdGlobal;
	/**
	 * Marker class that describes that state is final and further transitions are not possible.
	 * Serves as a transition guard.
	 * @author Andrei Andreev
	 */
	public class StateFinal extends VPAIDState
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateFinal(global:AdGlobal) 
		{
			super(global);
		}
		
	}

}