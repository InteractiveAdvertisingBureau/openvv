package 
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.external.ExternalInterface;
    import flash.utils.getTimer;
    import flash.utils.Timer;
    import org.openvv.OVVAsset;
    import org.openvv.OVVCheck;
    
    /**
     * ...
     * @author 
     */
    public class Main extends Sprite 
    {
        private static const OVV_CHECK_INTERVAL:uint = 1000; // 1 sec
        private static const LOG:Boolean = true;

        private var id:String = new String(new Date().getTime() + Math.random()); 
        private var ovvCheck:OVVCheck;
        private var timer:Timer;
        
        public function Main():void 
        {
            if (stage) init();
            else addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        private function init(e:Event = null):void 
        {
            removeEventListener(Event.ADDED_TO_STAGE, init);
            // entry point
            
            ovvCheck = new OVVCheck(id);
            timer = new Timer(OVV_CHECK_INTERVAL, 0);
            timer.addEventListener(TimerEvent.TIMER, performCheck);
            timer.start();
        }
        
        private function performCheck(e:TimerEvent):void {
            var result:Object = ovvCheck.checkViewability(id);
            if (LOG) {
                ExternalInterface.call("console.log", result);
            }
        }
        
    }
    
}