package net.iab.vpaid.statemachine
{
	import flash.events.Event;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.events.VPAIDEvent;
	import net.iab.vpaid.statemachine.states.VPAIDState;
	import net.iab.vpaid.statemachine.transitions.Transitions;
	import net.iab.vpaid.statemachine.transitions.VPAIDTriggers;
	import net.iab.vpaid.VPAIDAPI;
	
	/**
	 * Player facing VPAID API - an instance that is returned to the player in responce to getVPAID() call.
	 * <p>The class is a top object that accomplishes UML 2 type of finite state machine.</p>
	 * @see net.iab.vpaid.statemachine.transitions.Transitions
	 * @author Andrei Andreev
	 */
	public class VPAIDStateMachine extends VPAIDAPI
	{
		private var _currentState:VPAIDState;
		private var transitions:Transitions;
		/**
		 * 
		 * @param	global container of the instances that are injected and consumed throughout the framework.
		 * @see net.iab.vpaid.core.AdGlobal
		 */
		public function VPAIDStateMachine(global:AdGlobal)
		{
			super(global);
			init();
		}
		
		private function init():void
		{
			transitions = new Transitions(this, global);
			/**
			 * Listed to all VPAID events.
			 */
			for each (var type:String in VPAIDEvent.VPAIDTypes)
				messanger.addEventListener(type, onVPAIDEvent, false);
		}
		
		private function onVPAIDEvent(e:VPAIDEvent):void
		{
			/**
			 * First attempt to trigger transition.
			 */
			transitions.setTrigger(e.type);
			/**
			 * Redispatch event.
			 */
			dispatchEvent(e);
		}
		/**
		 * Invokes transition associated with iniAd() call and store arguments values.
		 * @copy net.iab.vpaid.IVPAID#initAd()
		 */
		override public function initAd(width:Number, height:Number, viewMode:String = VIEWMODE_NORMAL, desiredBitrate:Number = -1, creativeData:String = "", environmentVars:String = ""):void
		{
			transitions.setTrigger(VPAIDTriggers.initAd);
			_currentState.initAd(width, height, viewMode, desiredBitrate, creativeData, environmentVars);
		}
		/**
		 * Invokes transition associated with startAd().
		 * @copy net.iab.vpaid.IVPAID#startAd()
		 */
		override public function startAd():void
		{
			transitions.setTrigger(VPAIDTriggers.startAd);
		}
		/**
		 * Retransmits pauseAd() call to the current state.
		 * @copy net.iab.vpaid.IVPAID#pauseAd()
		 */
		override public function pauseAd():void
		{
			_currentState.pauseAd();
		}
		/**
		 * Retransmits resumeAd() call to the current state.
		 * @copy net.iab.vpaid.IVPAID#resumeAd()
		 */
		override public function resumeAd():void
		{
			_currentState.resumeAd();
		}
		/**
		 * Retransmits collapseAd() call to the current state.
		 * @copy net.iab.vpaid.IVPAID#collapseAd()
		 */
		override public function collapseAd():void
		{
			_currentState.collapseAd();
		}
		/**
		 * Retransmits expandAd() call to the current state.
		 * @copy net.iab.vpaid.IVPAID#expandAd()
		 */
		override public function expandAd():void 
		{
			_currentState.expandAd();
		}
		/**
		 * Retransmits resizeAd() call to the current state.
		 * @copy net.iab.vpaid.IVPAID#resizeAd()
		 */
		override public function resizeAd(width:Number, heigth:Number, viewMode:String = VIEWMODE_NORMAL):void
		{
			_currentState.resizeAd(width, heigth, viewMode);
		}
		/**
		 * Invokes transition associated with skipAd().
		 * @copy net.iab.vpaid.IVPAID#skipAd()
		 */
		override public function skipAd():void
		{
			transitions.setTrigger(VPAIDTriggers.skipAd);
		}
		/**
		 * Invokes transition associated with stopAd().
		 * @copy net.iab.vpaid.IVPAID#stopAd()
		 */
		override public function stopAd():void
		{
			transitions.setTrigger(VPAIDTriggers.stopAd);
		}
		/**
		 * Receives new state instance and enters the state.
		 */
		public function set currentState(value:VPAIDState):void
		{
			if (value)
			{
				_currentState = value;
				_currentState.enter();
			}
		}
	
	}

}