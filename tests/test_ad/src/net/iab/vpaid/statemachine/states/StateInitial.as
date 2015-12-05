package net.iab.vpaid.statemachine.states 
{
	import net.iab.vpaid.core.AdGlobal;
	/**
	 * Initial idle state. Is active until player calls IVPAID.initAd().
	 * <p>Data type serves as a marker in present implementation.</p>
	 * @see net.iab.vpaid.IVPAID#initAd()
	 * 
	 * @author Andrei Andreev
	 */
	public class StateInitial extends VPAIDState
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateInitial(global:AdGlobal) 
		{
			super(global);
		}
		
	}

}