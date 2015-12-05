package net.iab.vpaid.creative.ui
{
	import flash.events.MouseEvent;
	
	/**
	 * Button that changes its label depending on state.
	 * @author Andrei Andreev
	 */
	public class ToggleButton extends AdButton
	{
		private var labelActive:String;
		private var labelIdle:String;
		private var _isActive:Boolean = true;
		
		public function ToggleButton(labelActive:String, labelIdle:String, width:Number)
		{
			this.labelActive = labelActive;
			this.labelIdle = labelIdle;
			activate();
			super(labelActive, width);
		
		}
		
		private function activate():void
		{
			addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			isActive = !_isActive;
		}
		/**
		 * Manipulating of isActive prperty changes button label.
		 */
		public function get isActive():Boolean
		{
			return _isActive
		}
		
		public function set isActive(value:Boolean):void {
			if (value === _isActive) return;
			_isActive = value;
			this.labelText = _isActive ? labelActive : labelIdle;
		}
		
		 
	
	}

}