package net.iab.vpaid.creative
{
	import flash.events.EventDispatcher;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	import net.iab.vpaid.creative.player.AdVideoPlayer;
	import net.iab.vpaid.creative.ui.ButtonPanel;
	import net.iab.vpaid.creative.ui.PanelAdEnd;
	import net.iab.vpaid.creative.ui.PanelClickthrough;
	import net.iab.vpaid.creative.ui.PanelCountdown;
	import net.iab.vpaid.creative.ui.PanelError;
	import net.iab.vpaid.creative.ui.PanelGrid;
	import net.iab.vpaid.creative.ui.PanelInteraction;
	import net.iab.vpaid.creative.ui.PanelStates;
	
	/**
	 * Draws controls, couples them with objects controls manage.
	 * 
	 * @author Andrei Andreev
	 */
	public class AdControls extends AdSprite
	{
		/**
		 * Panel that manages grid.
		 */
		private var gridPanel:PanelGrid;
		/**
		 * Panel that manages ad states.
		 */
		private var statePanel:PanelStates;
		/**
		 * Panel that manages ad end calls.
		 */
		private var adEndPanel:PanelAdEnd;
		/**
		 * Panel that manages Clickthrough user directives.
		 */
		private var clickthroughPanel:PanelClickthrough;
		/**
		 * Panel that manager user Ad Interaction dirctives.
		 */
		private var interactionPanel:PanelInteraction;
		/**
		 * Panel that manages ad erro user directives.
		 */
		private var errorPanel:PanelError;
		/**
		 * Displays ad coundown.
		 */
		private var countdown:PanelCountdown;
		/**
		 * Collection of all panels for bulk processing.
		 */
		private var panels:Vector.<ButtonPanel>
		/**
		 * 
		 * @param	messanger global EventDispatcher instance
		 * @param	player video player instance
		 * @param	grid grid overlay instance
		 */
		public function AdControls(messanger:EventDispatcher, player:AdVideoPlayer, grid:Grid)
		{
			init(messanger, player, grid);
		}
		
		private function init(messanger:EventDispatcher, player:AdVideoPlayer, grid:Grid):void
		{
			gridPanel = new PanelGrid(grid);
			statePanel = new PanelStates(messanger, player);
			adEndPanel = new PanelAdEnd(messanger);
			errorPanel = new PanelError(messanger);
			clickthroughPanel = new PanelClickthrough(messanger);
			interactionPanel = new PanelInteraction(messanger);
			countdown = new PanelCountdown(messanger);
			panels = new <ButtonPanel>[gridPanel, statePanel, adEndPanel, errorPanel, clickthroughPanel, interactionPanel, countdown];
		}
		
		/**
		 *
		 * @copy net.iab.vpaid.creative.AdSprite#setSize()
		 */
		override public function setSize(width:Number, height:Number):void
		{
			super.setSize(width, height);
			style = new Styles().adControls;
			placePanels();
		}
		
		private function placePanels():void
		{
			/**
			 * panle y position
			 */
			var py:Number = style.margin;
			for each (var panel:ButtonPanel in panels)
			{
				panel.x = style.margin;
				panel.y = py;
				/**
				 * Adjust y
				 */
				py += panel.height + style.margin;
				addChild(panel);
			}
			/**
			 * Calculate y for the remaining panels
			 * that are positioned at the bottom
			 */
			interactionPanel.y = clickthroughPanel.y = errorPanel.y = Math.max(_height - Math.max(errorPanel.height, clickthroughPanel.height, interactionPanel.height) - style.margin, adEndPanel.y + adEndPanel.height + style.margin);
			interactionPanel.x = clickthroughPanel.x + clickthroughPanel.width + style.margin;
			errorPanel.x = interactionPanel.x + interactionPanel.width + style.margin;
			
			countdown.x = _width - countdown.width - style.margin;
			countdown.y = _height - countdown.height - style.margin;
		}
		/**
		 *
		 * @copy net.iab.vpaid.creative.AdSprite#dispose()
		 */
		override public function dispose():void
		{
			super.dispose();
			for each (var panel:ButtonPanel in panels)
			{
				panel.dispose();
				removeChild(panel);
			}
		}
	
	}

}