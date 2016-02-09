package net.iab.vpaid.statemachine.states
{
	import flash.display.Sprite;
	import net.iab.vpaid.core.AdGlobal;
	
	/**
	 * 
	 * State that VPAID state machine enters in responce to the following triggers:
	 * <ul>
	 * <li>AdError</li>
	 * </ul>
	 * Initiates internal destruction proccesses.
	 * 
	 * <p>This is a final state. Ad does not respond to any API calls, events or transitions once this state is entered. </p>
	 * 
	 * @see net.iab.vpaid.events.VPAIDEvent#AdError
	 * 
	 * @author Andrei Andreev
	 */
	public class StateError extends StateFinal
	{
		/**
		 * 
		 * @copy net.iab.vpaid.VPAIDAPI#VPAIDAPI()
		 */
		public function StateError(global:AdGlobal)
		{
			super(global);
		}
		/**
		 * Initializes destruction processes.
		 */
		override public function enter():void
		{
			var root:Sprite = global.root;
			var content:Sprite = global.assetsLoader.content;
			if (root.contains(content))
				root.removeChild(content);
			global.dispose();
			exit();
		}
	
	}

}