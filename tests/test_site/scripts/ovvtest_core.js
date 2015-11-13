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
		
	var valOutput = [
	{ key: 'adHeight', type: 'calc', prop : 'objBottom - objTop'},
	{ key: 'adWidth', type: 'calc', prop : 'objRight - objLeft'},
	{ key: 'viewportHeight', type: 'val', prop : 'clientHeight'},
	{ key: 'viewportWidth', type: 'val', prop : 'clientWidth'},
	{ key: 'adTop', type: 'val', prop : 'objTop'},
	{ key: 'adLeft', type: 'val', prop : 'objLeft'},
	{ key: 'adRight', type: 'val', prop : 'objRight'},
	{ key: 'adBottom', type: 'val', prop : 'objBottom'},
	{ key: 'windowActive', type: 'val', prop : 'focus'},
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
<h2>OVV Viewability data</h2> \
###DETAILS### \
<hr class="light" /> \
###SUMMARY### \
</div> ',

		lineMarkup: '<div><label>##label##</label> <span data-ovv="##ovv##"></span></div>',

		detailDef: [
			{label: 'Ad Width', ovv: 'adWidth'},
			{label: 'Ad Height', ovv: 'adHeight'},
			{label: 'Viewport Width', ovv: 'viewportWidth'},
			{label: 'Viewport Height', ovv: 'viewportHeight'}
		],
			
		summaryDef: [
			{label: 'Viewable', ovv: 'percentViewable'},
			{label: 'Window Focus', ovv: 'windowActive'}
		]
	}

	
	// Options
	var opts = {
		debug: true,
		logListener: noop,
		displayOvvValues: true,
		buildInfoBox: false,
		infoBoxTarget: null,
		valuesOutputElem: null
	};
	
	/**
	* Displays ovv data object values in given DOM element.
	*/
	function displayViewableData(data){
		var el = opts.valuesOutputElem;
		var id;
		var k, val, i;
		if(typeof(el) === 'string'){
			id = el;
			el = doc.getElementById(id);
			if(el == null){
				el = doc.querySelector(id);
			}
		}
		
		/**
		* Embedded function to display the value
		*/
		var showData = function(obj, valKey){
			var valEl, val, parts;
			var attr = '[data-ovv=' + valKey.key + ']';
			valEl = doc.querySelector(attr);
			if(valEl == null){
				valEl = doc.querySelector('.' + valKey.key);
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
		
		if(el == null){
			return;
		}
		
		for(i=0;i<valOutput.length;i++){
			showData(data, valOutput[i]);
		}
	}
	
	/**
	* openvvtest.util object definition
	*/
	var util = {
		getEl: function(elemOrId){
			var id, el;
			
			if(elemOrId == null){
				throw "Null identifier to find elem";
			}
			
			if(typeof(elemOrId === 'String')){
				id = elemOrId;
				if(id.substr(0,1) == '#'){
					id = id.substr(1);
				}
				return document.getElementById(id);
			}
			else if(typeof(elemOrId === 'Object')){
				return elemOrId;
			}
		}
	}
	
	/**
	* Method to build the info window at the target location
	*/
	function buildInfoWindow(elemOrId){
		var el = util.getEl(elemOrId);
		var html = infoBox.viewabilityInfoMarkup;
		var line, tp = infoBox.lineMarkup;
		var i, k, d;
		var sumbuf = [], detbuf = []
		
		var id;
		
		id = el.getAttribute('id');
		if(id != null){		
			ovvtest.setOptions({ valuesOutputElem: id});
		}
		else{
			ovvtest.setOptions({ valuesOutputElem: el});
		}
		
		for(i=0;i<infoBox.detailDef.length;i++){
			d = infoBox.detailDef[i];
			line = tp.replace('##label##', d.label).replace('##ovv##', d.ovv);
			detbuf.push(line);
		}
		for(i=0;i<infoBox.summaryDef.length;i++){
			d = infoBox.summaryDef[i];
			line = tp.replace('##label##', d.label).replace('##ovv##', d.ovv);
			sumbuf.push(line);
		}
		
		html = html.replace('###DETAILS###', detbuf.join(''));
		html = html.replace('###SUMMARY###', sumbuf.join(''));
		
		el.innerHTML = html;


		var closeBtn = el.querySelector('button.close');
		if(closeBtn != null){
			closeBtn.addEventListener('click', function(evt){
				var box = document.getElementById('ovvParamValues');
				box.style.display = 'none';
			});
		}
	}
	
	
	/**
	* Static implementation object for ovvtest
	*/
	var impl = {
		
		handleOvvEvent: function(event, data){
			// ovvtest.log(event, data);
			if(opts.displayOvvValues){
				displayViewableData(data.ovvData);
			}			
		},
		
		setOptions: function(options){
			var k, v;
			for(k in options){
				if(options.hasOwnProperty(k)){
					opts[k] = options[k];
				}
			}			
		},
		
		buildInfoWindow: buildInfoWindow,
		
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
var prevDVVfunc = DVViewableDetect;
window.DVViewableDetect = function(event, data){
	ovvtest.handleOvvEvent(event, data);
	prevDVVfunc(event, data);
}



