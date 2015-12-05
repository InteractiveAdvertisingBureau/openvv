package net.iab.vpaid.statemachine.transitions
{
	import flash.events.EventDispatcher;
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.statemachine.states.StateFinal;
	import net.iab.vpaid.statemachine.states.VPAIDState;
	import net.iab.vpaid.statemachine.VPAIDStateMachine;
	
	/**
	 * State machine transisions manager.
	 * 
	 * <p>Accepts transition triggers and implements transision guards.</p>
	 * 
	 * @author Andrei Andreev
	 */
	public class Transitions extends EventDispatcher
	{
		private var stateMachine:VPAIDStateMachine;
		private var messanger:EventDispatcher;
		private var transitionsDictionary:TransitionsDictionary;
		private var currentState:VPAIDState;
		/**
		 * 
		 * @param	stateMachine state machine instance that relies on transitions.
		 * @param	global collection of global objects that are used throughout application.
		 */
		public function Transitions(stateMachine:VPAIDStateMachine, global:AdGlobal)
		{
			init(stateMachine, global);
		}
		
		private function init(stateMachine:VPAIDStateMachine, global:AdGlobal):void
		{
			this.stateMachine = stateMachine;
			transitionsDictionary = new TransitionsDictionary(global);
			setTrigger(VPAIDTriggers.initial);
		}
		/**
		 * Validates trigger against guards. Once transision is validated - set corresponding target state on the state machine.
		 * @param	trigger name of transision trigger
		 */
		public function setTrigger(trigger:String):void
		{
			/**
			 * Only if current state is not final transitions are possible
			 */
			if (currentState is StateFinal)
				return;
			var transition:Transition = transitionsDictionary.getTransition(trigger);
			if (!transition)
				return;
			/**
			 * Transition execution cannot be called twice.
			 */
			var state:VPAIDState = transition.execute(currentState);
			if (state)
				stateMachine.currentState = currentState = state;
		}
	
	}

}