package net.iab.vpaid.core
{
	
	/**
	 * Contains ad configuration parameters
	 * @author Andrei Andreev
	 */
	public class AdData extends Object
	{
		private var _params:Object = {};
		/**
		 * 
		 * @param	params at runtime typically LoaderInfo.parameters
		 */
		public function AdData(params:Object = null)
		{
			init(params);
		}
		
		private function init(params:Object = null):void
		{
			var url:String = escape("http://services.mediamind.com/instream/IAB/videos/ad-video-canal.mp4");
			_params.advideo = unescape(url);
			_params.skipOffset = 5;
			//_params.ovvBeaconURL = "http://localhost/iab/OVVBeacon.swf";
			_params.ovvBeaconURL = "/ad/OVVBeacon.swf";
			this.params = params;
		}
		
		/**
		 * Iterates through argument properties and stored key/value pairs. Passing of null does not nullify individual properties.
		 */
		public function set params(value:Object):void
		{
			for (var property:String in value)
				_params[property] = unescape(value[property]);
		}
		
		/**
		 * Looks up property by proeprty name and returns corresponding value as a primitive Object. It is consumer's responsibility to validate/cast to specific value data type.
		 * @param	property name of the key in key/value pair
		 * @return	primitive typeless Object
		 */
		public function getParam(property:String):Object
		{
			return _params[property];
		}
	
	}

}