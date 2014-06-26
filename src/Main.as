package 
{
	import flash.display.Sprite;
	import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.Timer;
    import org.openvv.OVVAsset;
    import org.openvv.OVVCheck;
	
	/**
	 * ...
	 * @author 
	 */
	public class Main extends Sprite 
	{
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
            
            var asset:OVVAsset = new OVVAsset("../bin/OVVBeacon.swf");
            var check:OVVCheck = null;
            var timer:Timer = new Timer(1000);  // call once per second to keep the output reasonable
            timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
                check = asset.checkViewability();
               ExternalInterface.call("console.log", "== Viewability Check ==\n",
                check,
                "\n\tcheck.id="+check.id,
                "\n\tcheck.viewabilityState=" + check.viewabilityState,
                "\n\tcheck.percentViewable=" + check.percentViewable,
                "\n\tcheck.focus=" + check.focus, 
                "\n\tcheck.inIframe=" + check.inIframe, 
                "\n\tcheck.clientWidth="+check.clientWidth,
                "\n\tcheck.clientHeight=" + check.clientHeight
                );
            });
            timer.start();
            trace("OVV Demo started");
		}
		
	}
	
}