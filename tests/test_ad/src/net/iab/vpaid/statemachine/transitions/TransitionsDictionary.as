package net.iab.vpaid.statemachine.transitions
{
	import net.iab.vpaid.core.AdGlobal;
	import net.iab.vpaid.statemachine.states.StateError;
	import net.iab.vpaid.statemachine.states.StateFinal;
	import net.iab.vpaid.statemachine.states.StateImpression;
	import net.iab.vpaid.statemachine.states.StateInitial;
	import net.iab.vpaid.statemachine.states.StateInitiating;
	import net.iab.vpaid.statemachine.states.StateLoaded;
	import net.iab.vpaid.statemachine.states.StateSkipping;
	import net.iab.vpaid.statemachine.states.StateStarted;
	import net.iab.vpaid.statemachine.states.StateStarting;
	import net.iab.vpaid.statemachine.states.StateStopping;
	import net.iab.vpaid.statemachine.transitions.Transition;
	
	/**
	 * Collection of concrete state transisions.
	 * @author Andrei Andreev
	 */
	public class TransitionsDictionary extends Object
	{
		private var initAd:Transition;
		private var adLoaded:Transition;
		private var startAd:Transition;
		private var adStarted:Transition;
		private var adImpression:Transition;
		private var stopAd:Transition;
		private var skipAd:Transition;
		private var adUserClose:Transition;
		private var adStopped:Transition;
		private var adError:Transition;
		private var global:AdGlobal;
		private var initial:Transition;
		private var transitions:Object;
		private var blank:Transition;
		public function TransitionsDictionary(global:AdGlobal)
		{
			this.global = global;
			init();
		}
		
		private function init():void
		{
			blank = new Transition();
			var stateInitial:StateInitial = new StateInitial(global);
			var stateInitiating:StateInitiating = new StateInitiating(global);
			var stateLoaded:StateLoaded = new StateLoaded(global);
			var stateStarting:StateStarting = new StateStarting(global);
			var stateStarted:StateStarted = new StateStarted(global);
			var stateImpression:StateImpression = new StateImpression(global);
			var stateSkipping:StateSkipping = new StateSkipping(global);
			var stateFinal:StateFinal = new StateFinal(global);
			var stateStopping:StateStopping = new StateStopping(global);
			var stateError:StateError = new StateError(global);
			
			initial = new Transition(stateInitial);
			initAd = new Transition(stateInitiating, stateInitial);
			adLoaded = new Transition(stateLoaded, stateInitiating);
			startAd = new Transition(stateStarting, stateLoaded);
			adStarted = new Transition(stateStarted, stateStarting);
			adImpression = new Transition(stateImpression, stateStarted);
			/**
			 * adUserClose has a specific transition to stateStopping
			 * to enforce guard where transition cannot happen from any other 
			 * state but stateImpression
			 */
			adUserClose = new Transition(stateStopping, stateImpression);
			skipAd = new Transition(stateSkipping, stateImpression);
			adStopped = new Transition(stateFinal, stateStopping);
			stopAd = new Transition(stateStopping);
			adError = new Transition(stateError);
		}
		/**
		 * Returns Transition instance associated with trigger. 
		 * <p>If there is no concrete transision linked to a trigger - generic abstract transition is returned. Abstract transision blocks transision by default. </p>
		 * 
		 * @see net.iab.vpaid.statemachine.transitions.VPAIDTriggers
		 * @see net.iab.vpaid.statemachine.transitions.Transition
		 * 
		 * @param	trigger descriptor that has specific transition linked to it
		 * @return instance of transition associated with trigger
		 */
		public function getTransition(trigger:String):Transition
		{
			switch (trigger)
			{
				case VPAIDTriggers.initial: 
					return initial;
					break;
				case VPAIDTriggers.initAd: 
					return initAd;
					break;
				case VPAIDTriggers.AdLoaded: 
					return adLoaded;
					break;
				case VPAIDTriggers.startAd: 
					return startAd;
					break;
				case VPAIDTriggers.AdStarted: 
					return adStarted;
					break;
				case VPAIDTriggers.AdImpression: 
					return adImpression;
					break;
				case VPAIDTriggers.stopAd: 
				case VPAIDTriggers.AdAutoStop: 
					return stopAd;
					break;
				case VPAIDTriggers.skipAd: 
				case VPAIDTriggers.AdUserSkip: 
					return skipAd;
					break;
				case VPAIDTriggers.AdUserClose: 
					return adUserClose;
					break;
				case VPAIDTriggers.AdStopped: 
					return adStopped;
					break;
				case VPAIDTriggers.AdError: 
					return adError;
					break;
				default: 
					return blank;
					break;
			}
			return null;
		}
	
	}

}