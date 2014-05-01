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
	public class OVVCheck
	{
		/**
		 * OpenVV was unable to determine whether the asset was viewable or not
		 */		
		public static const UNMEASURABLE:String = 'unmeasurable';
		
		/**
		 * At least 50% of the asset is viewable within the viewport
		 */		
		public static const VIEWABLE:String = 'viewable';
		
		public static const GEOMETRY:String = "geometry";
		
		public static const BEACON:String = "beacon";
		
		/**
		 * Less than 50% of the asset is viewable within the viewport
		 */		
		public static const UNVIEWABLE:String = 'unviewable';
		
		/**
		 * The height of the viewport currently being displayed  
		 */		
		public var clientHeight:int = -1;
		
		/**
		 * The width of the viewport currently being displayed  
		 */
		public var clientWidth:int = -1;
		
		/**
		 * The technique used to determine viewablity
		 * 
		 * @see BEACON
		 * @see GEOMETRY 
		 */		
		public var technique:String;
		
		/**
		 * A description of an error that may have occurred  
		 */
		public var error:String;
		
		/**
		 * If the tab is focused or not 
		 */		
		public var focus:Boolean;
		
		/**
		 * An array of beacon statuses. True = viewable. False = unviewable. 
		 */		
		public var beacons:Array;
		
		/**
		 * Whether OpenVV can use JavaScript bounds to determine viewability 
		 */		
		public var geometrySupported:Boolean;
		
		/**
		 * Whether OpenVV can use beacons to determine viewability 
		 */
		public var beaconsSupported:Boolean;
		
		/**
		 * The current framerate of the asset (determined by ActionScript)
		 */		
		public var fps:Number = -1;
		
		/**
		 * The unique identifier of the asset 
		 */
		public var id:String;
		
		/**
		 * Whether the asset is in an iframe or not 
		 */
		public var inIframe:Boolean = false;
		
		/**
		 * The distance (in pixels) from the asset's bottom to the bottom of the viewport  
		 */
		public var objBottom:int = -1;
		
		/**
		 * The distance (in pixels) from the asset's left side to the left side of the viewport  
		 */
		public var objLeft:int = -1;
		
		/**
		 * The distance (in pixels) from the asset's right side to the right side of the viewport  
		 */
		public var objRight:int = -1;
		
		/**
		 * The distance (in pixels) from the asset's top to the top of the viewport  
		 */
		public var objTop:int = -1;
		
		/**
		 * How much of the asset is viewable within the viewport  
		 */
		public var percentViewable:int = -1;
		
		/**
		 * Represents whether the asset was viewable, unviewable, or if OpenVV
		 * couldn't make a determination.
		 * 
		 * @see VIEWABLE
		 * @see UNVIEWABLE
		 * @see UNMEASURABLE
		 */
		public var viewabilityState:String;
		
		/**
		 * Constructor. Takes in an Object created by JavaScript and assigns 
		 * its field to this object.
		 *  
		 * @param jsCheck
		 * 
		 */		
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