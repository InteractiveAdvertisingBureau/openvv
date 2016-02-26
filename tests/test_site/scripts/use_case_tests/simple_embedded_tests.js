
/*-------------------------------------------------------------------------------
# * Copyright (c) 2015, Interactive Advertising Bureau
# * All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
#  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer 
#     in the documentation and/or other materials provided with the distribution.
#	  
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER 
# IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF 
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------*/


// =====================================
// ovvtest simple use cases for directly embedded
// * @author Chris Cole
// =====================================
(function(win){
	"use strict";
	
	var ovvtest = win.ovvtest;
	var uc = ovvtest.uc || {}
	var doc = document;
	
	var adId, ucTableId;
	
	function getAd(){
		var ovv = win.$ovv;
		var ads = ovv.getAds()
		
		if(ads != null){
			return ads[adId];
		}
		
		return null;
	}
	
	function runTest(testId, callback){
		console.log('[run uctest ' + testId + '] ');
		
		try{
		tests[testId](callback);
		}
		catch(ex){
			console.log('Test not found ' + testId);
		}
	}
	
	
	var tests = {
		"t_1" : function(cb){
			window.scrollTo(0,0);
			// pause a moment
			setTimeout(function(){
				var ad = getAd();
				var data = ad.checkViewability();
				var iv = data && data.viewabilityState == 'viewable' || false;			
				cb(iv);
			}, 10);				
			
		}
	}
	
	function bindTestButton(btn, ucId){
		var ucId = ucId;
		btn.addEventListener('click', function(evt){
			var row;
			var id;
			if(btn.closest){
				row = btn.closest('tr');
			}
			else{				
				row = btn.parentNode;
				if(row.tagName != 'TR'){
					row = row.parentNode;
				}
			}
			id = ucId || row.getAttribute('data-uc');
			runTest(id, function(result){
				var resultEl = row.querySelector('td.result');
				var txt = result ? 'PASS' : 'FAIL';
				resultEl.innerHTML = txt;
			});
		});	
		
	}
	
	function attachEventHandlers(info){
		var table = doc.getElementById(ucTableId);
		var rows = table.querySelectorAll('tbody tr[data-uc]');
		var i, r, btn, id;
		
		for(i=0;i<rows.length;i++){
			r = rows[i];
			id = r.getAttribute('data-uc');
			btn = r.querySelector('button.exec');
			if(btn != null){
				bindTestButton(btn, id);
			}
		}
		
		var btnTop = doc.getElementById('btnScrollTop');
		var btnBottom = doc.getElementById('btnScrollBottom');
		var btnMin = doc.getElementById('btnMin');
		var btnRestore = doc.getElementById('btnRestore');
		var btnBlur = doc.getElementById('btnBlur');
		
		var cmdStatus = doc.getElementById('cmdStatus');
		
		btnTop.addEventListener('click', function(){
			cmdStatus.innerHTML = '';
			window.scroll(0,0);
			window.setTimeout(function(){
				cmdStatus.innerHTML = 'scrolltop';
			}, 100);
		});
		btnBottom.addEventListener('click', function(){
			cmdStatus.innerHTML = '';
			var ht = document.body.scrollHeight || 10000;
			window.scroll(0,ht);
			window.setTimeout(function(){
				cmdStatus.innerHTML = 'scrollbottom';
			}, 100);
		});
		btnMin.addEventListener('click', function(){
			cmdStatus.innerHTML = '';
			window.moveTo(10000, 10000)
			window.setTimeout(function(){
				cmdStatus.innerHTML = 'minimize';
			}, 100);
		});
		btnRestore.addEventListener('click', function(){
			cmdStatus.innerHTML = '';
			window.moveTo(0,0)
			window.setTimeout(function(){
				cmdStatus.innerHTML = 'restore';
			}, 100);
		});
		btnBlur.addEventListener('click', function(){
			cmdStatus.innerHTML = '';
			window.blur();
			window.setTimeout(function(){
				cmdStatus.innerHTML = 'blur';
			}, 100);
		});
		
	}
	
	var impl = {
		
		init: function(info){
			adId = info.adId;
			ucTableId = info.ucTable;
			
			attachEventHandlers(info);
			
		},
		
		getAd: getAd,
		
		runTest: runTest		
		
	}	
	
	
	
	uc.embedded = impl;
	
	
	ovvtest.uc = uc;
	
	
})(window);