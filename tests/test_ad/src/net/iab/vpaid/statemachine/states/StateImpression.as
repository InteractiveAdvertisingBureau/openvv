package net.iab.vpaid.statemachine.states 
{
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.creative.LinearCreative;
	import net.iab.vpaid.events.VPAIDEvent;
	/**
	 * StateImpression dispatches events through messanger instance on exit.
	 * 
     * @copy net.iab.vpaid.events.VPAIDEvent#AdSizeChange
     */
    [Event(name = "AdSizeChange", type = "net.iab.vpaid.events.VPAIDEvent")]
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>AdImpression</li>
	 * </ul>
	 * Sizes ad to the latest know dimensions and triggers ad progression.
	 * 
	 * @see net.iab.vpaid.statemachine.states.StateStarted
	 * 
	 * @author Andrei Andreev
	 */
	public class StateImpression extends VPAIDState
	{
		/**
		 * Actual creative visuals.
		 */
		private var ad:LinearCreative;
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateImpression(global:AdGlobal) 
		{
			super(global);
		}
		/**
		 * Resizes ad to the latest known dimensions and initializes ad progression.
		 */
		override public function enter():void 
		{
			ad = global.assetsLoader.content;
			ad.setSize(vpaidParams.adWidth, vpaidParams.adHeight);
			ad.startAd();
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#resizeAd()
		 */
		override public function resizeAd(width:Number, heigth:Number, viewMode:String = VIEWMODE_NORMAL):void 
		{
			super.resizeAd(width, heigth, viewMode);
			ad.setSize(vpaidParams.adWidth, vpaidParams.adHeight);
			messanger.dispatchEvent(new VPAIDEvent(VPAIDEvent.AdSizeChange));
			
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#pauseAd()
		 */
		override public function pauseAd():void 
		{
			ad.pauseAd();
		}
		/**
		 * @copy net.iab.vpaid.IVPAID#resumeAd()
		 */
		override public function resumeAd():void 
		{
			ad.resumeAd();
		}
	}
}