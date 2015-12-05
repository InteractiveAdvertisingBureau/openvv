package net.iab.vpaid.statemachine.states 
{
	import net.iab.vpaid.core.AdGlobal;
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>AdLoaded</li>
	 * </ul>
	 * At present implementation StateLoaded is an idle state that VPAID remains in until startAd() method is called.
	 * <p>Data type serves as a marker in present implementation.</p>
	 * @author Andrei Andreev
	 */
	public class StateLoaded extends VPAIDState
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateLoaded(global:AdGlobal) 
		{
			super(global);
		}
		
	}

}