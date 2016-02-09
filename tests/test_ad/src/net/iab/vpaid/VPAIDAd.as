package net.iab.vpaid
{
	import flash.display.Sprite;
	import flash.system.Security;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.statemachine.VPAIDStateMachine;
	
	/**
	 * Document Class of the VPAID Ad.
	 * @author Andrei Andreev
	 */
	public class VPAIDAd extends Sprite
	{
		private var api:VPAIDAPI;
		
		public function VPAIDAd()
		{
			init();
		}
		
		private function init():void
		{
			Security.allowDomain("*");
			Security.allowInsecureDomain("*");
			var global:AdGlobal = new AdGlobal(this as Sprite);
			api = new VPAIDStateMachine(global);
		}
		/**
		 * VPAID 2.0 REQ 6.1
		 * <p>The video player accesses VPAID by calling getVPAID on the ad object. </p>
		 * @return
		 */
		public function getVPAID():IVPAID
		{
			return api;
		}
	}

}