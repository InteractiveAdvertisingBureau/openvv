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
			if(obj.hasOwnProperty(k)){
				console.log(k);
				
			}
		}
		
	}
}

