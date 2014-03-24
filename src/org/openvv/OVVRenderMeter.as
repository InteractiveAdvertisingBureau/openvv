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
  import flash.display.DisplayObject;
  import flash.events.Event;
  import flash.utils.getTimer;

  public class OVVRenderMeter
  {
    private static const MIN_FPS_THRESHOLD:Number = 12;

    private var _displayedObject:DisplayObject;
    private var _startTime:Number = -1;
    private var _fps:Number = 0;
    private var _visibility:Boolean = false;

    public function OVVRenderMeter(displayedObject:DisplayObject)
    {
      _displayedObject = displayedObject;
      _displayedObject.addEventListener(Event.ENTER_FRAME, handleFrame);
    }

    public function get isVisible():Boolean
    {
      return _visibility;
    }

    public function get fps():Number
    {
      return _fps;
    }

    private function handleFrame(event:Event):void
    {
      if (_startTime == -1)
      {
        _startTime = getTimer();
        return;
      }

      var elapsedTime:Number = getTimer() - _startTime;
      _fps = (1/(elapsedTime/1000));
      _startTime = getTimer();

      _visibility = _fps > MIN_FPS_THRESHOLD;
    }
  }
}
