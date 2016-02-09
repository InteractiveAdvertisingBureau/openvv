package net.iab.vpaid.creative.ui
{
	import flash.events.MouseEvent;
	import net.iab.vpaid.creative.Grid;
	
	/**
	 * Manipulates grid visibility.
	 *
	 * @author Andrei Andreev
	 */
	public class PanelGrid extends ButtonPanel
	{
		private var button:ToggleButton;
		private var activeLabel:String = "HIDE GRID";
		private var inactiveLabel:String = "SHOW GRID";
		private var grid:Grid;
		
		/**
		 *
		 * @param	grid instance of Grid
		 */
		public function PanelGrid(grid:Grid)
		{
			super(null);
			this.grid = grid;
		}
		
		override protected function configureUI():void
		{
			button = new ToggleButton("HIDE GRID", "SHOW GRID", 120);
			buttons = new <AdButton>[button];
		}
		
		override protected function onButtonClick(e:MouseEvent):void
		{
			grid.visible = button.isActive;
		}
	
	}

}