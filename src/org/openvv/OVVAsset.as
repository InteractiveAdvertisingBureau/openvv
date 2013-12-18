/**
 * Copyright (c) 2013 Open VideoView
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
 * documentation files (the "Software"), to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
 * to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of
 * the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 * THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package org.openvv
{
  import flash.display.Sprite;
  import flash.events.EventDispatcher;
  import flash.events.TimerEvent;
  import flash.external.ExternalInterface;
  import flash.utils.Timer;
  import org.openvv.OVVCheck;
  import org.openvv.events.OVVEvent;

  public class OVVAsset extends EventDispatcher
  {
    private static const VIEWABLE_IMPRESSION_THRESHOLD:Number = 20;
    private static const DISCERNIBLE_IMPRESSION_THRESHOLD:Number = 4;
    private static const IMPRESSION_DELAY:Number = 250;
    private static const VIEWABLE_AREA_THRESHOLD:Number = 50;

    private var _id:String;
    private var _viewabilityCheck:OVVCheck;
    private var _impressionTimer:Timer;
    private var _intervalsInView:Number;
    private var _hasDispatchedDImp:Boolean = false;

    public function OVVAsset()
    {
      if (!ExternalInterface.available)
      {
        raiseError("ExternalInterface unavailable");
        return;
      }

      _id = generateId();
      _viewabilityCheck = new OVVCheck(_id);

      _intervalsInView = 0;
      _impressionTimer = new Timer(IMPRESSION_DELAY);
      _impressionTimer.addEventListener(TimerEvent.TIMER, timerHandler);
      _impressionTimer.start();
    }

    public function checkViewability():Object
    {
      return performCheck();
    }

    private function performCheck():Object
    {
      var results:Object = _viewabilityCheck.checkViewability(_id);

      if (!!results.error)
        raiseError(results.error);

      return results;
    }

    // Every 250ms, check to see if asset is visible
    // Count consecutive viewable results.  If asset not visible, reset count
    // Once asset has been visible for 5s, raise impression
    private function timerHandler(e:TimerEvent):void
    {
		var results:Object = checkViewability();
		
      if (results['viewabilityState'] == "viewable")
        _intervalsInView++;
      else
        _intervalsInView = 0;

      if(_intervalsInView >= DISCERNIBLE_IMPRESSION_THRESHOLD && !_hasDispatchedDImp)
      {
        _hasDispatchedDImp = true;
        dispatchEvent(new OVVEvent(OVVEvent.OVVDiscernibleImpression));
      }
      else if (_intervalsInView >= VIEWABLE_IMPRESSION_THRESHOLD)
      {
        raiseImpression();
        _impressionTimer.stop();
      }
    }

    private function generateId():String
    {
      return "ovv" + Math.floor(Math.random()*1000000000).toString();
    }

    private function raiseImpression():void
    {
      dispatchEvent(new OVVEvent(OVVEvent.OVVImpression));
    }

    private function raiseLog(msg:String):void
    {
      var d:* = {"message":msg};
      dispatchEvent(new OVVEvent(OVVEvent.OVVLog, d));
    }

    private function raiseError(msg:String):void
    {
      var d:* = {"message":msg};
      dispatchEvent(new OVVEvent(OVVEvent.OVVError, d));
    }
  }
}
