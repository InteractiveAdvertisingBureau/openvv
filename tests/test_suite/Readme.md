===========
Test Suite Instructions
===========

This test suite is written to use Selenium Webdriver and NodeJS.

Setup
----------
Prior to execution you need to build both OpenVV and the OpenVV Test Ad.
Follow instructions in the Readme.md in the project root and tests/test_ad
respectively.

Next you need to configure a website that points to the [project_root]/tests/test_site
directory as the root.

Finally, modify test_settings.json in this directory to identify the website.


Execution
----------
From a CLI execute the command:
	
	mocha cases_simple_sync.js 


Use Cases
---------
https://docs.google.com/document/d/1SSpsAkH_RwiMm9PWhFnexeN1jIMY37ZixfxU80XEh5I/edit

------
Prerequisites
------
Install the following software:

* NodeJS
* Java JDK
* ChromeDriver (https://code.google.com/p/selenium/wiki/ChromeDriver)
* Mocha (http://mochajs.org/)
* Webdriver-sync (https://github.com/jsdevel/webdriver-sync)

	
Not used:
--------
We have abandoned using the official Selenium WebDriver for NodeJS due to issues
with their extensive use of Promises. Instead we are using Webdriver-sync which
is a Javascript wrapper on top of the Java standalone Selenium Webdriver implementation.

* Selenium WebDriver (https://www.npmjs.com/package/selenium-webdriver)

	



