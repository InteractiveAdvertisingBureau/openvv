/**
* Test cases for embedded OpenVV ad.
*
* Using webdriver-sync
* Suite for simple viewability.
*
*
*/

var wd = require('webdriver-sync');
var ChromeDriver = wd.ChromeDriver;
var By = wd.By;
var Wait = wd.WebDriverWait;
var TimeUnit = wd.TimeUnit;
var assert = require('assert');

	
var settings = require('./test_settings.json');
var testPage = settings.base_url + 'index.html';
var timeout = parseInt(settings.pageTimeout);

if(isNaN(timeout)){
	timeout = 10000;
}

var driver = null; // our global driver


before(function(){
	this.timeout(timeout);
	driver = new ChromeDriver();
});

after(function(){
	driver.quit();
});


describe('OpenVV Embedd Video Test', function() {
	
	before(function(){
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		var title = driver.getTitle();
		assert.ok(title.indexOf('OpenVV') > -1);
	});
	

	
	it('should load the test page', function() {
		this.timeout(timeout);

		driver.get(testPage);
		pageutil.letLoad();
		var header = driver.findElement(By.cssSelector('header > div.header > h1'));
		var text = header.getText();
		assert.ok(text.indexOf('On Page Video') > -1, "Title missing");
	});
	
	it('should find the view params element', function(){
		var vpElems;
		var stateEl, beginEl;
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		pageutil.letStartVideo();
		
		stateEl = driver.findElement(By.id('ovvExecutionState'));
		beginEl = driver.findElement(By.id('ovvStartBox'));
		
		var hd = driver.findElement(By.cssSelector('div.header h1'));
		var pageHeaderText = hd.getText()
		
		assert.ok(pageHeaderText == 'On Page Video');
	});
	
	it('should be viewable with page scrolled to top', function(){
		var vpElems;
		var inviewEl;
		var state;
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		pageutil.letStartVideo();
		
		pageutil.scrollTop();
		pageutil.allowInitViewable();		
		
		vpElems = driver.findElement(By.id('ovvParamValues'));
		inviewEl = driver.findElement(By.cssSelector('#ovvParamValues div.ovvParamBox span[data-ovv="viewabilityState"]'));
		
		assert.ok(inviewEl != null);
		state = inviewEl.getText();
		assert.equal(state, 'viewable', "Wrong value - is: " + state );
	});
	
	it('should not be viewable with page scrolled to bottom', function(){
		var vpElems;
		var inviewEl;
		var state;
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		pageutil.letStartVideo();
		
		pageutil.scrollBottom();
		pageutil.allowInitViewable();		
		
		vpElems = driver.findElement(By.id('ovvParamValues'));
		inviewEl = driver.findElement(By.cssSelector('#ovvParamValues div.ovvParamBox span[data-ovv="viewabilityState"]'));
		
		assert.ok(inviewEl != null);
		state = inviewEl.getText();
		assert.equal(state, 'unviewable', "Wrong value - is: " + state );
	});
	it('should not be viewable without focus', function(){
		var vpElems;
		var inviewEl;
		var state;
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		pageutil.letStartVideo();
		
		pageutil.blurWindow();
		pageutil.allowInitViewable();		
		
		vpElems = driver.findElement(By.id('ovvParamValues'));
		inviewEl = driver.findElement(By.cssSelector('#ovvParamValues div.ovvParamBox span[data-ovv="viewabilityState"]'));
		
		assert.ok(inviewEl != null);
		state = inviewEl.getText();
		assert.equal(state, 'unviewable', "Wrong value - is: " + state );
		pageutil.onScreen();
	});
	it('should not be viewable when off screen', function(){
		var vpElems;
		var inviewEl;
		var state;
		this.timeout(timeout);
		driver.get(testPage);
		pageutil.letLoad();
		pageutil.letStartVideo();
		
		pageutil.offScreen();
		pageutil.allowInitViewable();		
		
		vpElems = driver.findElement(By.id('ovvParamValues'));
		inviewEl = driver.findElement(By.cssSelector('#ovvParamValues div.ovvParamBox span[data-ovv="viewabilityState"]'));
		
		assert.ok(inviewEl != null);
		state = inviewEl.getText();
		assert.equal(state, 'unviewable', "Wrong value - is: " + state );
		pageutil.onScreen();
	});
	
	
});

// ===============================================
// Utility methods
// ===============================================


var pageutil = {
	
	getEl: {
		viewParams: function(){
			var items = driver.findElements(By.css("#dataViewWrapper *[data-ovv]"));
			
			return items;
		},
		viewparamLine: function(key){
			var line = driver.findElement(By.css("#dataViewWrapper *[data-ovv=" + key + "]"));
			
			return line;
		}
	},
	
	scrollTop: function(){
		var b = driver.findElement(By.id('btnScrollTop'));
		b.click();
		// wd.Timeouts
		pageutil.waitForCommand('scrolltop', 500);
	},
	scrollBottom: function(){
		var b = driver.findElement(By.id('btnScrollBottom'));
		b.click();
		pageutil.waitForCommand('scrollbottom', 500);
	},
	offScreen: function(){
		var b = driver.findElement(By.id('btnMin'));
		b.click();
		pageutil.waitForCommand('minimize', 500);
	},
	onScreen: function(){
		var b = driver.findElement(By.id('btnRestore'));
		b.click();
		pageutil.waitForCommand('restore', 500);
	},
	blurWindow: function(){
		var b = driver.findElement(By.id('btnBlur'));
		b.click();
		pageutil.waitForCommand('blur', 500);
	},
	waitForCommand: function(str, time){
		var time = time || 500;
		var cmdStatus = driver.findElement(By.id('cmdStatus'));
		wd.wait(function(){
			var value = cmdStatus.getText();
			return value == str;
		}, {timeout: time});
		
	},
	// interface not wired in this version
	execScript: function(jscript){
		var jsExec = driver;
		
		var result = jsExec.executeScript(jscript);
		return result;
	},
	
	
	allowInitViewable: function(){
		wd.wait(function(){
			var inviewEl = driver.findElement(By.cssSelector('#ovvParamValues div.ovvParamBox span[data-ovv="viewabilityState"]'));
			var txt = inviewEl.getText();
			return txt != null && txt != '';
		});
	},
	
	letLoad: function(){
		wd.wait(function(){
			var title = driver.getTitle();
			return title != null && title.indexOf('OpenVV') > -1;
		});
	},
	
	letStartVideo: function(){
		wd.wait(function(){
			var stateEl, beginEl;
			stateEl = driver.findElement(By.id('ovvExecutionState'));
			beginEl = driver.findElement(By.id('ovvStartBox'));
			
			return 'block' == beginEl.getCssValue('display');
			
		}, { timeout: 20000 });
	},
	
	dumpKeys: function(obj, depth){
		var depth = depth || 0;
		var k, v;
		
		for(k in obj){
			console.log(k);
		}
		
	}
}

