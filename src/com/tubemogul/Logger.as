/**
 * Copyright (c) 2013 TubeMogul
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
package com.tubemogul {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

public class Logger {
	/**
	 * This is a non-functional example of how data can be reported.
	 */
	public function Logger() {
	}
	public function sendEvent( jsonData:String ):void {
		var url:String = "http://your.logging.system.com/";
		var request:URLRequest = new URLRequest( url );
		request.method = URLRequestMethod.POST;
		request.data = jsonData;
		var requestor:URLLoader = new URLLoader();
		requestor.addEventListener( Event.COMPLETE, httpComplete );
		requestor.addEventListener( IOErrorEvent.IO_ERROR, httpFail );
		requestor.addEventListener( SecurityErrorEvent.SECURITY_ERROR, httpFail );
		requestor.load( request );
	}
	private function httpComplete( event:Event ):void {
		trace("Completed: " + event);
	}

	private function httpFail( error:ErrorEvent ):void {
		trace("FAILED: " + error);
	}

}
}
