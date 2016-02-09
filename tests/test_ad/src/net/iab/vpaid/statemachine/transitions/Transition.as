package net.iab.vpaid.statemachine.transitions
{
	import net.iab.vpaid.statemachine.states.VPAIDState;
	
	/**
	 * Individual abstract transition of a state machine. Once concrete target and source states are provided - becomes concrete transision.
	 * @author Andrei Andreev
	 */
	public class Transition extends Object
	{
		private var targetState:VPAIDState;
		private var sourceState:VPAIDState;
		private var executeGuard:Boolean = true;
		
		/**
		 *
		 * @param	targetState state to which transition leads
		 * @param	sourceState state from wich transition is triggered
		 */
		public function Transition(targetState:VPAIDState = null, sourceState:VPAIDState = null)
		{
			this.targetState = targetState;
			this.sourceState = sourceState;
			/**
			 * Transition cannot be accomplished if targetState does not exist.
			 * Transition with no targetState will not return any state effectively blocking transision.
			 */
			if (!targetState)
				executeGuard = false;
		}
		
		/**
		 *
		 * @param	sourceState state from which transition originates
		 * @return	target state if guards validate, null if transition is not valid
		 */
		public function execute(sourceState:VPAIDState):VPAIDState
		{
			if (validateGuards(sourceState))
			{
				/**
				 * Transision cannot be performed twice in VPAID state machine.
				 */
				executeGuard = false;
				return targetState;
			}
			return null;
		}
		
		private function validateGuards(sourceState:VPAIDState):Boolean
		{
			/**
			 * In VPAID there are two guards
			 * 1. Transition cannot be triggered twice.
			 * 2. If source state is set - transition can be only from the specified source state
			 */
			if (executeGuard)
			{
				if (this.sourceState)
				{
					return this.sourceState === sourceState;
				}
				return true;
			}
			return false;
		}
	
	}

}