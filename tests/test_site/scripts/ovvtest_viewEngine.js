"use strict";

/*-------------------------------------------------------------------------------
# * Copyright (c) 2015, Interactive Advertising Bureau
# * All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------*/

(function(win){
	var ovvtest = win.ovvtest || {};
	
	// Default viewability engine parameters
	var VIEWABLE_MUST_FOCUS = true;
	var VIEWABLE_PERCENT = 50;
	var VIEWABLE_SEC = 6;
	
	var noop = function(){};
	var isfunc = function(fn){
		if(typeof(fn) === 'function'){
			return true;
		}
		return false;
	}
	

	/**
	* @class
	* Viewability calculation engine for window.ovvtest code
	*/
	function engine(opts){
		var me = this;
		
		var viewableCounterStart = 0;
		
		/**
		* Internal object to hold event listeners
		*/
		var eventListeners = {
			viewabilityReached: []
		}
		
		
		/**
		* Parameters required for viewability
		*/
		this.viewableParams = {
			seconds: 		VIEWABLE_SEC,
			percent: 		VIEWABLE_PERCENT,
			requireFocus: 	VIEWABLE_MUST_FOCUS
		}
	
		
		
		function trigger(eventName, params){
			var i, fn, 
				el = eventListeners,
				list = el[eventName];
			
			if(list == null || list.length == 0){
				return;
			}
			
			
			for(i=0;i<list.length;i++){
				fn = list[i];
				if(isfunc(fn)){
					try{
						fn(params);
					}
					catch(ex){
						console.error('[ovvtest ViewEngine] ' + ex.message, ex);
					}
				}
			}			
		}
		
		/**
		* Tests to see if the data params state that the ad is in view
		*/
		function eventInView(data){
			var vp = me.viewableParams;
			var pctVal, inFocus = true;
			if(!data){
				return false;
			}
			
			pctVal = data.percentViewable || 0;
			if(data.focus === false){
				inFocus = false;
			}
			else{
				inFocus = true;
			}
			
			if(pctVal >= vp.percent){
				if(inFocus || vp.requireFocus == false){
					return true;
				}
			}
			
			return false;			
		}
		
		function testViewabilityLimits(ticks){
			var vp = me.viewableParams;
			var tm = me.tickMeasure;
			var ms;
			var limMs = vp.seconds * 1000;
			
			if(tm.viewableMsSum == 0){
				return false;
			}
			
			if(tm.viewableMsSum >= (limMs)){
				return true;
			}			
		}
		
		this.viewabilityReached = false;
		this.previouslyInView = false;
		this.currentViewTickStart
		this.startTicks = 0;
		this.ovvTime = {
			start: 0,
			end: 0
		}
		
		this.tickMeasure = {
			currentViewTickStart : 0,
			lastMeasureTicks: 0,
			viewableMsSum: 0
		}
		
		this.addEventListener = function(eventName, func){
			if(!isfunc(func)){
				return;
			}
			
			if(eventListeners[eventName] == null){
				eventListeners[eventName] = [];
			}
			
			eventListeners[eventName].push(func);
		}
		
		/**
		* Process the OVV event and calculate how it affects the state of the view engine
		*/
		this.processEvent = function(eventName, ovvtime, data){
			var inView;
			var ticks = Date.now();
			var isStart = false;
			var viewResult, ltm = me.tickMeasure.lastMeasureTicks;
			if(me.startTicks == 0){
				isStart = true;
				me.startTicks = ticks;
			}
			
			if(this.ovvTime.start === 0){
				this.ovvTime.start = ovvtime;				
			}
			
			inView = eventInView(data);
			if(inView == true){
			
				if(!me.previouslyInView){
					me.previouslyInView = true;
					me.tickMeasure.currentViewTickStart = ticks;
				}
				else{
					if(ltm > 0){
						me.tickMeasure.viewableMsSum += (ticks - ltm);
					}
				}
				
				// look for our thresholds
				if(!me.viewabilityReached){
					viewResult = testViewabilityLimits(ticks);
					if(viewResult){
						me.viewabilityReached = true;
						trigger('viewabilityReached', {  viewabilityReached: true, viewTime: me.tickMeasure.viewableMsSum});
					}
				}
				
				me.tickMeasure.lastMeasureTicks = ticks;
			}
			else{
				if(me.previouslyInView){
					me.previouslyInView = false;
					me.tickMeasure.currentViewTickStart = 0;
					if(ltm > 0){
						me.tickMeasure.viewableMsSum += (ticks - ltm);
					}
				}
			}
		}		
	}
	

	ovvtest.ViewEngine = engine;
	win['ovvtest'] = ovvtest;

})(window);
