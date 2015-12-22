"use strict";

/*-------------------------------------------------------------------------------
# * Copyright (c) 2015, Interactive Advertising Bureau
# * All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------*/

(function(win){

	var doc = win.document;
	var noop = function(){}
	
	var isFunc = function(fn){
		if(typeof(fn) == 'function'){
			return true;
		}
	}
	
	var isArray = function(ar){
		if(ar == null || typeof(ar) === 'string'){
			return false;
		}
		if(typeof(ar) === 'object' && ar.length != null){
			return true;
		}
		return false;		
	}
		
	var valOutput = [
	{ key: 'adHeight', type: 'calc', prop : 'objBottom - objTop'},
	{ key: 'adWidth', type: 'calc', prop : 'objRight - objLeft'},
	{ key: 'viewportHeight', type: 'val', prop : 'clientHeight'},
	{ key: 'viewportWidth', type: 'val', prop : 'clientWidth'},
	{ key: 'adTop', type: 'val', prop : 'objTop'},
	{ key: 'adLeft', type: 'val', prop : 'objLeft'},
	{ key: 'adRight', type: 'val', prop : 'objRight'},
	{ key: 'adBottom', type: 'val', prop : 'objBottom'},
	{ key: 'inIframe', type: 'val', prop : 'inIframe'},
	{ key: 'windowActive', type: 'val', prop : 'focus'},
	{ key: 'measureTechnique', type: 'val', prop : 'technique'},
	{ key: 'viewabilityState', type: 'val', prop : 'viewabilityState'},
	{ key: 'percentViewable', type: 'val', prop : 'percentViewable', format: '{0}%'}
	];
	
	/**
	* Information window about current viewability
	// id="ovvParamValues" 
	*/
	var infoBox = {
		viewabilityInfoMarkup :
'<div class="chip chip_shadow ovvParamBox dragbox"> \
<button type="button" class="close">&times;</button> \
<div class="title">\
<h3>OVV Viewability data</h3> \
</div>\
###DETAILS### \
<hr class="light" /> \
###SUMMARY### \
</div> ',

		lineMarkup: '<div><label>##label##</label> <span data-ovv="##ovv##"></span></div>',

		detailDef: [
			{label: 'Ad Width', ovv: 'adWidth'},
			{label: 'Ad Height', ovv: 'adHeight'},
			{label: 'Viewport Width', ovv: 'viewportWidth'},
			{label: 'Viewport Height', ovv: 'viewportHeight'},
			{label: 'Viewable', ovv: 'percentViewable'},
			{label: 'Window Focus', ovv: 'windowActive'}
		],
			
		summaryDef: [
			{label: 'IFramed', ovv: 'inIframe'},
			{label: 'Measurement By', ovv: 'measureTechnique'},
			{label: 'OVV State', ovv: 'viewabilityState'}
		]
	}

	
	// Options
	var opts = {
		debug: true,
		adId : 'my_ovv_test_ad_id', // default ID compiled into test ad swf
		logListener: noop,
		displayOvvValues: true,
		valuesOutputElem: null,
		quartileValuesOutputElem: null,
		enableViewEngine: false
	};
	
	var quartileChipTemplate = '<div class="quartileViewData" >##name## FOO </div>'
	
	/**
	* Mixin utility to merge objects
	*/
	function mixin(objA, objB){
		var k, v;
		var targ = {};
		
		if(objA && typeof(objA) === 'object'){
			for(k in objA){
				if(objA.hasOwnProperty(k)){
					targ[k] = objA[k];
				}
			}
		}
		if(objB && typeof(objB) === 'object'){
			for(k in objB){
				if(objB.hasOwnProperty(k)){
					targ[k] = objB[k];
				}
			}
		}
		
		return targ;
	}
	
	function displayQuartileViewability(eventName, data){
		var el = opts.quartileValuesOutputElem;
		var id, nd;
		var k, val, i;
		var buf = [];
		var css = '';
		if(typeof(el) === 'string'){
			id = el;
			el = doc.getElementById(id);
			if(el == null){
				el = doc.querySelector(id);
			}
		}
		
		if(el == null || data == null){
			return;			
		}
		
		buf.push('<div class="eventName">', eventName, '</div>');
		buf.push('<div class="viewabilityState">Viewable State: ', data.viewabilityState, '</div>');
		buf.push(' <span class="ivpct">In View: ', data.percentViewable, '%</span>');
		buf.push(' <span class="infocus">Focus: ');
		if(data.focus === true){
			buf.push('true');
		}
		else{
			buf.push('false');
		}
		buf.push('</span>');
		
		
		if(data.percentViewable >= 50){
			css = 'inView'
			if(data.focus === false){
				css += ' noFocus';
			}
		}
		else{
			css = 'notInView'
		}
		
		nd = document.createElement('div');
		nd.className = 'quartileViewData ' + css;
		
		nd.innerHTML = buf.join('');
		
		el.appendChild(nd);		
	}
	
	/**
	* Displays ovv data object values in given DOM element.
	*/
	function displayViewableData(data){
		var el = opts.valuesOutputElem;
		var id, arr;
		var k, val, i;
		
		if(el == null){
			return;
		}
		
		if(data == null){
			return;			
		}
		// check for empty object
		var keyCount = 0;
		if(typeof(data) === 'object'){
			for(k in data){
				if(data.hasOwnProperty(k)){
					keyCount++;
					if(keyCount > 10){
						break;
					}
				}
			}			
		}
		if(keyCount == 0){
			impl.log('[ovvtest] - No data to show');
			return;
		}
		else if(keyCount == 2){
			if(data['ovvData'] == null){
				impl.log('[ovvtest] - No data to show');
				return;
			}				
		}		
		
		if(typeof(el) === 'string'){
			id = el;
			el = doc.getElementById(id);
			if(el == null){
				el = doc.querySelector(id);
			}
			
			_displayViewableDataImpl(data, el);
		}
		else if(isArray(el)){
			arr = el;
			for(i=0;i<arr.length;i++){
				el = arr[i];
				_displayViewableDataImpl(data, el);
			}			
		}		
	}
	
	/**
	* Displays ovv data object values in given DOM element.
	*/
	function _displayViewableDataImpl(data, el){
		var id;
		var k, val, i;
		if(el == null){
			return;
		}
		
		if(typeof(el) === 'string'){
			id = el;
			el = doc.getElementById(id);
			if(el == null){
				el = doc.querySelector(id);
			}
			
			_displayViewableDataImpl(data, el);
		}
		
			
		for(i=0;i<valOutput.length;i++){
			showData(data, valOutput[i], el);
		}
	}
	
	/**
	* Embedded function to display the value
	*/
	var showData = function(obj, valKey, rootEl){
		var valEl, val, parts;
		var attr = '[data-ovv=' + valKey.key + ']';
		valEl = rootEl.querySelector(attr);
		if(valEl == null){
			valEl = rootEl.querySelector('.' + valKey.key);
		}
		if(valEl == null){
			return;
		}
		if(valKey.type == 'val'){
			val = obj[valKey.prop];
		}
		else if(valKey.type == 'calc'){
			parts = valKey.prop.split(' ');
			if(parts.length != 3){
				ovvtest.logError('invalid valOutput prop ' + valKey.prop);
				return;
			}
			val = '';
			if(parts[1] == '-'){
				val = obj[parts[0]] - obj[parts[2]]; 
			}				
		}
		
		if(val && valKey.format != null){
			val = valKey.format.replace("{0}", val)
		}
		
		valEl.innerHTML = val
		
	}
	
	/**
	* openvvtest.util object definition
	*/
	var util = {
		getEl: function(elemOrId, doc){
			var id, el;
			var doc = doc || document;
			
			if(elemOrId == null){
				throw "Null identifier to find elem";
			}
			
			if(typeof(elemOrId === 'String')){
				id = elemOrId;
				if(id.substr(0,1) == '#'){
					id = id.substr(1);
				}
				return doc.getElementById(id);
			}
			else if(typeof(elemOrId === 'Object')){
				return elemOrId;
			}
		}
	}
	
	/**
	* Method to build the info window at the target location
	*/
	function buildInfoWindow(elemOrId, options){
		var el;
		var ibox = infoBox;
		var options = options || {};
		var i, k, d;
		var sumbuf = [], detbuf = [];
		var twin, tdoc;
		var regTopWindow = false;
		
		if(options.infoBox != null){
			ibox = mixin(infoBox, options.infoBox);
		}
		
		var html = ibox.viewabilityInfoMarkup;
		var line, tp = ibox.lineMarkup;
		
		var id;
				
		for(i=0;i<ibox.detailDef.length;i++){
			d = ibox.detailDef[i];
			line = tp.replace('##label##', d.label).replace('##ovv##', d.ovv);
			detbuf.push(line);
		}
		for(i=0;i<ibox.summaryDef.length;i++){
			d = ibox.summaryDef[i];
			line = tp.replace('##label##', d.label).replace('##ovv##', d.ovv);
			sumbuf.push(line);
		}
		
		html = html.replace('###DETAILS###', detbuf.join(''));
		html = html.replace('###SUMMARY###', sumbuf.join(''));
		
		if(opts.valuesOutputElem == null){
			opts.valuesOutputElem = [];
		}
		
		if(options.topFrame && !ovvtest.isTopFrame()){
			twin = window.top;
			tdoc = twin.document;
			el = util.getEl(elemOrId, tdoc);
			regTopWindow = true;
			id = el.getAttribute('id');
			
			opts.valuesOutputElem.push(el);
			
		}
		else{
			el = util.getEl(elemOrId);
			id = el.getAttribute('id');
			
			if(id != null){		
				opts.valuesOutputElem.push(id);
			}
			else{
				opts.valuesOutputElem.push(el);
			}
		}
		
		el.innerHTML = html;


		var closeBtn = el.querySelector('button.close');
		if(closeBtn != null){
			closeBtn.addEventListener('click', function(evt){
				var box = document.getElementById('ovvParamValues');
				box.style.display = 'none';
			});
		}
	}
	
	var attachRetries = 0;
	var regTimer = 0;
	function registerOvvListeners(ad_id){
		var ovv;
		var ad_id = ad_id || opts.adId;
		
		if(regTimer !== 0){
			clearTimeout(regTimer);
			regTimer = 0;
		}
		
		if(!window['$ovv']){
			if(++attachRetries < 10){
				regTimer = setTimeout(function(){
					registerOvvListeners();
				}, 300);
			}
			
			return;
		}
		
		var eventNames = [
			'AdLoaded', 'AdImpression', 'AdPlaying', 'AdPaused', 'AdVolumeChange',
			'AdVideoStart', 'AdVideoFirstQuartile', 'AdVideoMidpoint', 'AdVideoThirdQuartile', 
			'AdVideoComplete'
		];
		
		// list of OVV events. We must listen to OVVLog in order to get up to date viewability information
		var ovvEvents = ['OVVReady', 'OVVImpression', 'OVVImpressionUnmeasurable', 'OVVLog'];
		
		ovv = window['$ovv'];
		ovv.subscribe(ovvEvents, ad_id, function(id, eventData){
			if(eventData.ovvArgs != null){
				handleOvvEvent(eventData, eventData.ovvArgs);
			}
			
		}, true);
		
		ovv.subscribe(eventNames, ad_id, function(id, eventData){
			if(eventData.ovvArgs != null){
				handleVpaidEvent(eventData, eventData.ovvArgs);
			}
			
		}, true);
		
		// Error handles
		ovv.subscribe(['AdError', 'OVVError'], ad_id, function(id, eventData, more){
			handleAdError(id, eventData, more);
		}, true);
		
	}
	
	
	function handleAdError(error, args){
		impl.logError(error);
		if(args){
			impl.logError(args);
		}		
	}
	
	function updateViewEngine(eventObj, data){
		var eng = ovvtest.viewEngine;
		var eventName, ovvtime;
		
		if(typeof(eventObj) === 'string'){
			eventName = eventObj;
		}
		else{
			eventName = eventObj.eventName;
			ovvtime = eventObj.eventTime;
		}
		
		if(opts.enableViewEngine && eng != null){
			eng.processEvent(eventName, ovvtime, data);
		}		
	}
	
	/**
	* Handle OVV specific events
	*/
	function handleOvvEvent(eventObj, data){
		var dataObj;
		if(data.ovvData != null){
			dataObj = data.ovvData;
		}
		else{
			dataObj = data;
		}
		
		var dataObj = data.ovvData;
		
		updateViewEngine(eventObj, dataObj);
				
		// ovvtest.log(eventObj, data);
		if(opts.displayOvvValues){
			displayViewableData(dataObj);
		}
	}
	
	/**
	* Handle VPAID events
	*/
	function handleVpaidEvent(eventObj, data){
		var name = eventObj && eventObj.eventName || '';
		
		var dataObj = data.ovvData;
		
		updateViewEngine(eventObj, dataObj);
		
		switch(name){
			case 'AdVideoStart':
			case 'AdImpression':
			case 'AdVideoFirstQuartile':
			case 'AdVideoMidpoint':
			case 'AdVideoThirdQuartile':
			case 'AdVideoComplete':
				displayViewableData(dataObj);
				displayQuartileViewability(name, dataObj);
				
				break;
			
		}
		
		
		console.log(event);
	}
	
	function handleFlashOvvEventCall(eventObj, data){
		console.log('[OVVTest (flash call)]');
		console.log(eventObj);
		handleOvvEvent(eventObj, data);		
	}
	
	function initializeCore(ignoreEvents){
		
		if(opts.enableViewEngine && ovvtest.ViewEngine != null){
			ovvtest.viewEngine = new ovvtest.ViewEngine();
			if(opts.viewabilityReached != null){
				ovvtest.viewEngine.addEventListener('viewabilityReached', opts.viewabilityReached);
			}
		}
		
		if(!ignoreEvents){
			ovvtest.registerOvvListeners();
		}

	}
	
	/**
	* Static implementation object for ovvtest
	*/
	var impl = {
		
		init: initializeCore,
		
		registerOvvListeners: registerOvvListeners,
		
		handleFlashOvvEventCall: handleFlashOvvEventCall,
		
		setOptions: function(options){
			var k, v;
			for(k in options){
				if(options.hasOwnProperty(k)){
					opts[k] = options[k];
					
					if(k == 'viewabilityReached' && ovvtest.viewEngine != null){
						ovvtest.viewEngine.addEventListener('viewabilityReached', opts[k]);
					}					
				}
			}			
		},
		
		buildInfoWindow: buildInfoWindow,
		
		isTopFrame: function(){
			if(window === window.top){
				return true;
			}
			return false;
		},
		
		log: function(message, data){
			if(opts.debug){
				if(console.log){
					console.log('ovvtest: ' + message);
					if(data){
						console.log(data);
					}
				}
				
				if(isFunc(opts.logListener)){
					opts.logListener(message, data);
				}
			}
		},
		logError: function(message, data){
			if(console.error){
				console.error('ovvtest: ' + message);
				if(data){
					console.error(data);
				}
			}
			
			if(isFunc(opts.logListener)){
				opts.logListener(message, data);
			}
		}
		
	}
	
	impl.util = util;
		
	win['ovvtest'] = impl;

})(window);


// Setup bridge methods for demo until we get an updated creative
(function(){
	if(window.DVViewableDetect != null){
		window.prevDVVfunc = DVViewableDetect;
		window.DVViewableDetect = function(eventObj, data){
			ovvtest.handleOvvEvent(eventObj, data);
			prevDVVfunc(eventObj, data);
		}
	}
})();



