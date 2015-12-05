package net.iab.vpaid.core
{
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import net.iab.vpaid.core.AdData;
	import net.iab.vpaid.VPAIDParams;
	
	/**
	 * Holds references to instances that are distributed/injected globally throughout the application.
	 * @author Andrei Andreev
	 */
	public class AdGlobal extends Object
	{
		private var _vpaidParams:VPAIDParams;
		private var _adData:AdData;
		private var _root:Sprite;
		private var params:Object = {};
		private var _assetsLoader:AssetsLoader;
		private var _messanger:EventDispatcher;
		private var _viewabilityManager:ViewabilityManager;
		/**
		 *
		 * @param	root reference to the top display list container.
		 */
		public function AdGlobal(root:Sprite)
		{
			init(root);
		}
		
		/**
		 *
		 * Instantiates global objects
		 */
		private function init(root:Sprite):void
		{
			this._root = root;
			params = root.loaderInfo ? root.loaderInfo.parameters : params;
			var fonts:Fonts = new Fonts();
			_messanger = new EventDispatcher();
			_vpaidParams = new VPAIDParams(_messanger);
			_adData = new AdData(params);
			_assetsLoader = new AssetsLoader(_adData, _vpaidParams, _messanger);
			_viewabilityManager = new ViewabilityManager(_adData, _messanger);
		}
		
		/**
		 * Initiates internal destruction processes.
		 */
		public function dispose():void
		{
			_vpaidParams.dispose();
			_assetsLoader.dispose();
			_viewabilityManager.dispose();
		}
		
		/**
		 * Instance of VPAID properties manager and provider.
		 */
		public function get vpaidParams():VPAIDParams
		{
			return _vpaidParams;
		}
		
		/**
		 * Instance of global ad configuration values provider.
		 */
		public function get adData():AdData
		{
			return _adData;
		}
		
		/**
		 * Reference to the top display list container.
		 */
		public function get root():Sprite
		{
			return _root;
		}
		
		/**
		 * Global EventDispatcher used to communicate events throughout the application.
		 */
		public function get messanger():EventDispatcher
		{
			return _messanger;
		}
		
		/**
		 * Object that initializes and provides references to ad's visuals.
		 */
		public function get assetsLoader():AssetsLoader
		{
			return _assetsLoader;
		}
		
		public function get viewabilityManager():ViewabilityManager 
		{
			return _viewabilityManager;
		}
	
	}

}