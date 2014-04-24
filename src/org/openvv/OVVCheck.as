package org.openvv
{
	public class OVVCheck
	{
		public var clientHeight:int = -1;
		
		public var clientWidth:int = -1;
		
		public var error:String;
		
		public var focus:Boolean;
		
		public var fps:Number = -1;
		
		public var id:String;
		
		public var in_iframe:Boolean = false;
		
		public var objBottom:int = -1;
		
		public var objLeft:int = -1;
		
		public var objRight:int = -1;
		
		public var objTop:int = -1;
		
		public var percentViewable:int = -1;
		
		public var viewabilityState:String;
		
		public var viewable:Boolean = false;
		
		public function OVVCheck(jsCheck:Object)
		{
			for (var field:String in jsCheck)
			{
				if(this.hasOwnProperty(field))
				{
					this[field] = jsCheck[field];
				}
			}
		}
	}
}