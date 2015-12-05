package net.iab.vpaid.events 
{
	import flash.events.Event;
	/**
	 * Super class for evens that may contain data.
	 * 
	 * @author Andrei Andreev
	 */
	public class DataEvent extends Event
	{
		/**
		 * Object that contains additional event data.
		 * Can be set only on instantiation.
		 *
		 * Shouldn't be null or undefined to assure errorless processing.
		 */
		private var _data:Object = { };
		/**
		 * 
		 * @param	type 
		 * @param	data additional data Event instance contains
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function DataEvent(type:String, data:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{
			this.data = data;
			super(type, bubbles, cancelable);
		}
		/**
		 * Additional data Event may contain.
		 * <p>Value is always an Object instance.</p>
		 */
		public function get data():Object 
		{
			return _data;
		}
		
		public function set data(value:Object):void 
		{
			_data = value || _data;
		}
		/**
		 * Allows for direct Event re-dispatching without creating of a new Event instance.
		 * @return copy of Event instance.
		 */
		override public function clone():Event
		{
			return new DataEvent(type, _data, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return formatToString("DataEvent:", "type", "bubbles", "cancelable", "eventPhase");
		}
		
	}

}