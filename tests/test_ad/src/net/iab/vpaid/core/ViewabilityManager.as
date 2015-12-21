package net.iab.vpaid.core
{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import org.openvv.events.OVVEvent;
	import org.openvv.OVVAsset;
	import org.openvv.OVVCheck;
	import net.iab.VPAIDEvent;
	
	/**
	 * Handles OpenVV.
	 * @author Andrei Andreev
	 */
	public class ViewabilityManager extends Object
	{
		private var messanger:EventDispatcher;
		private var ovv:OVVAsset;
		private var adData:AdData;
		
		/**
		 *
		 * @param	adData ad configuration data
		 * @param	messanger
		 */
		public function ViewabilityManager(adData:AdData, messanger:EventDispatcher)
		{
			this.messanger = messanger;
			this.adData = adData;
		}
		/**
		 * Instantiates OVVAsset and adds OVVEvent handlers.
		 */
		public function init():void
		{
			/**
			 * Ad can load beacons from any fully qualified url
			 */
			ovv = new OVVAsset(unescape(String(adData.getParam("ovvBeaconURL"))), 'my_ovv_test_ad_id');
			ovv.initEventsWiring(messanger);
			addListeners();
		}
		/**
		 * Adds OVV event listeners
		 */
		private function addListeners():void
		{
			ovv.addEventListener(OVVEvent.OVVError, onOVVEvent);
			ovv.addEventListener(OVVEvent.OVVImpression, onOVVEvent);
			ovv.addEventListener(OVVEvent.OVVImpressionUnmeasurable, onOVVEvent);
			// ovv.addEventListener(OVVEvent.OVVLog, onOVVEvent);
			ovv.addEventListener(OVVEvent.OVVReady, onOVVEvent);
			
			// Add VPAID event listeners
			ovv.addEventListener(VPAIDEvent.AdLoaded, onVPAIDEvent);
		}
		/**
		 * Removes OVV event listeners.
		 */
		private function removeListeners():void
		{
			if (ovv)
			{
				ovv.removeEventListener(OVVEvent.OVVError, onOVVEvent);
				ovv.removeEventListener(OVVEvent.OVVImpression, onOVVEvent);
				ovv.removeEventListener(OVVEvent.OVVImpressionUnmeasurable, onOVVEvent);
				// ovv.removeEventListener(OVVEvent.OVVLog, onOVVEvent);
				ovv.removeEventListener(OVVEvent.OVVReady, onOVVEvent);
				ovv.addEventListener(VPAIDEvent.AdLoaded, onVPAIDEvent);
			}
		}
		/**
		 * VPAIDEvent handler
		 * @param	e
		 */
		private function onVPAIDEvent(e:OVVEvent):void
		{
			var data:Object = e.data || { };
			var prefix:String = "\n\t";
			var log:Array = ["event =", e.type];
			
			consoleLog('VPAID EVENT CALL IN FLASH');
			
			/*
			try {
				var eventObj:Object = {
					currentTarget: "IAB_FLASH_AD"
				};
				ExternalInterface.call("ovvtest.handleOvvEvent", eventObj, data);
			}
			catch (ex:Error) {
				consoleLog(ex.message)
			}
			*/

		}
		
		/**
		 * OVVEvent handler
		 * @param	e
		 */
		private function onOVVEvent(e:OVVEvent):void
		{
			var data:Object = e.data || { };
			var prefix:String = "\n\t";
			var log:Array = ["event =", e.type];
			if (data is OVVCheck) {
				log.push(prefix, "beaconsSupported =", OVVCheck(data).beaconsSupported);
				log.push(prefix, "beaconViewabilityState =", OVVCheck(data).beaconViewabilityState);
				log.push(prefix, "clientHeight =", OVVCheck(data).clientHeight);
				log.push(prefix, "clientWidth =", OVVCheck(data).clientWidth);
				log.push(prefix, "displayState =", OVVCheck(data).displayState);
				log.push(prefix, "error =", OVVCheck(data).error);
				log.push(prefix, "focus =", OVVCheck(data).focus);
				log.push(prefix, "geometrySupported =", OVVCheck(data).geometrySupported);
				log.push(prefix, "geometryViewabilityState =", OVVCheck(data).geometryViewabilityState);
				log.push(prefix, "id =", OVVCheck(data).id);
				log.push(prefix, "inIframe =", OVVCheck(data).inIframe);
				log.push(prefix, "objBottom =", OVVCheck(data).objBottom);
				log.push(prefix, "objLeft =", OVVCheck(data).objLeft);
				log.push(prefix, "objRight =", OVVCheck(data).objRight);
				log.push(prefix, "objTop =", OVVCheck(data).objTop);
				log.push(prefix, "technique =", OVVCheck(data).technique);
				log.push(prefix, "viewabilityState =", OVVCheck(data).viewabilityState);
				log.push(prefix, "viewabilityStateOverrideReason =", OVVCheck(data).viewabilityStateOverrideReason);
				log.push(prefix, "volume =", OVVCheck(data).volume);
			}
			/**
			 * For the cases dta properties are enumerable.
			 */
			for each (var prop:String in data)
			{
				log.push(prefix, prop, "=", data[prop]);
			}
			consoleLog(log.join(" "));
			
			try {
				var eventObj:Object = {
					currentTarget: "IAB_FLASH_AD"
				};
				ExternalInterface.call("ovvtest.handleFlashOvvEventCall", eventObj, data);
			}
			catch (ex:Error) {
				consoleLog(ex.message)
			}
		}
		
		private function consoleLog(params:String):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call("console.log", ["[OVV]", params].join(" "));
			}
		}
		/**
		 * Calls OVVAsset dispose method, nullifies external references. 
		 */
		public function dispose():void
		{
			removeListeners();
			ovv.dispose();
			ovv = null;
		}
	
	}

}