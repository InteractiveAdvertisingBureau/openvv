/**
* Copyright (c) 2013 Open VideoView
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
* documentation files (the 'Software'), to deal in the Software without restriction, including without limitation
* the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
* to permit persons to whom the Software is furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all copies or substantial portions of
* the Software.
*
* THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
* THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/**
* A container for all OpenVV instances running on the page
* @class
* @constructor
*/
function OVV() {

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
    * Determines whether OpenVV should run in debug mode. Debug mode always
    * adds beacon SWFs to the page, which are color-coded based on their
    * status. OVVCheck.beaconViewabilityState and
    * OVVCheck.geometryViewabilityState are also populated in debug mode.
    * @type {Boolean}
    * @see {@link OVVCheck#geometryViewabilityState}
    * @see {@link OVVCheck#beaconViewabilityState}
    * @see {@link OVVAsset#BEACON_SIZE}
    */
    this.DEBUG = false;

    /**
    * The last asset added to OVV. Useful for easy access from the
    * JavaScript console.
    * @type {OVVAsset}
    */
    this.asset = null;
    /**
    * The id of the interval responsible for positioning beacons.
    */
    this.positionInterval;

    this.userAgent = window.testOvvConfig && window.testOvvConfig.userAgent ? window.testOvvConfig.userAgent : navigator.userAgent;

    this.servingScenarioEnum = { OnPage: 1, SameDomainIframe: 2, CrossDomainIframe: 3 };

     function getServingScenarioType(servingScenarioEnum) {
        try {
			if (window.top == window) {
				return servingScenarioEnum.OnPage;
			}
			var curWin=window;	
			var level=0;			
			while(curWin.parent != curWin  && level<1000){
				 if (curWin.parent.document.domain != curWin.document.domain) {
					return servingScenarioEnum.CrossDomainIframe;
				 }
				 curWin = curWin.parent;
			}
			return servingScenarioEnum.SameDomainIframe;
        } catch (e) { }
        return servingScenarioEnum.CrossDomainIframe;
    };
	
    this.servingScenario = getServingScenarioType(this.servingScenarioEnum);
    this.IN_IFRAME = (this.servingScenario != this.servingScenarioEnum.OnPage);
    this.IN_XD_IFRAME =  (this.servingScenario == this.servingScenarioEnum.CrossDomainIframe);
    this.geometrySupported = !this.IN_XD_IFRAME;
	
    // To support older versions of OVVAsset
    var browserData = new OVVBrowser(this.userAgent);

    this.browser = browserData.getBrowser();

    this.browserIDEnum = browserData.getBrowserIDEnum();

    /**
    * The interval in which ActionScript will poll OVV for viewability
    * information
    * @type {Number}
    */
    this.interval = INTERVAL;

    /**
    * OVV version
    * @type {Number}
    */
    this.releaseVersion = 'OVVRELEASEVERSION';

    /**
    * OVV build version
    * @type {String}
    */
    this.buildVersion = 'OVVBUILDVERSION';

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
    * An object for storing OVVAssets. {@link OVVAsset}s are stored with their
    * id as the key and the OVVAsset as the value.
    * @type {Object}
    */
    var assets = {};

    /**
    * An array for storing the first PREVIOUS_EVENTS_CAPACITY events for each event type. {@see PREVIOUS_EVENTS_CAPACITY}
    * @type {Array}
    */
    var previousEvents = [];

    /**
    * Number of event to store
    * @type {int}
    */
    var PREVIOUS_EVENTS_CAPACITY = 1000;

    /**
    * An array that holds all the subscribes for a eventName+uid combination
    * @type {Array}
    */
    var subscribers = [];

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
    * Stores an asset which can be retrieved later using
    * {@link OVV#getAssetById}. The latest asset added to OVV can also be
    * retrieved via the {@link OVV#asset} property.
    * @param {OVVAsset} ovvAsset An asset to observe
    */
    this.addAsset = function (ovvAsset) {
        if (!assets.hasOwnProperty(ovvAsset.getId())) {
            assets[ovvAsset.getId()] = ovvAsset;
            // save a reference for convenience
            this.asset = ovvAsset;
        }
    };

    /**
    * Removes an {@link OVVAsset} from OVV.
    * @param {OVVAsset} ovvAsset An {@link OVVAsset} to remove
    */
    this.removeAsset = function (ovvAsset) {
        delete assets[ovvAsset.getId()];
    };

    /**
    * Retrieves an {@link OVVAsset} based on its ID
    * @param {String} The id of the element to retrieve
    * @returns {OVVAsset|null} The element matching the given ID, or null if
    * one could not be found
    */
    this.getAssetById = function (id) {
        return assets[id];
    };

    /**
    * @returns {Object} Object an object containing all of the OVVAssets being tracked
    */
    this.getAds = function () {
        var copy = {};
        for (var id in assets) {
            if (assets.hasOwnProperty(id)) {
                copy[id] = assets[id];
            }
        }
        return copy;
    };

    /**
    * Subscribe the {func} to the list of {events}. When getPreviousEvents is true all the stored events that were passed will be fired
    * in a chronological order
    * @param {events} array with all the event names to subscribe to
    * @param {uid} asset identifier
    * @param {func} a function to execute once the assert raise the event
    * @param {getPreviousEvents} if true all buffered event will be triggered
    */
    this.subscribe = function (events, uid, func, getPreviousEvents) {

        if (getPreviousEvents) {
            for (key in previousEvents[uid]) {
                if (previousEvents[uid][key] && contains(previousEvents[uid][key].eventName, events)) {
                    runSafely(function () {
                        func(uid, previousEvents[uid][key]);
                    });
                }
            }
        }

        for (key in events) {
            if (!subscribers[events[key] + uid])
                subscribers[events[key] + uid] = [];
            subscribers[events[key] + uid].push({
                Func: func
            });
        }
    };

    /**
    * Publish {eventName} to all the subscribers. Also, storing the publish event in a buffered array is the capacity wasn't reached
    * @param {eventName} name of the event to publish
    * @param {uid} asset identifier
    * @param {args} argument to send to the published function
    */
    this.publish = function (eventName, uid, args) {
        var eventArgs = {
            eventName: eventName,
            eventTime: getCurrentTime(),
            ovvArgs: args
        };

        if (!previousEvents[uid]) {
            previousEvents[uid] = [];
        }
        if (previousEvents[uid].length < PREVIOUS_EVENTS_CAPACITY) {
            previousEvents[uid].push(eventArgs);
        }

        if (eventName && uid && subscribers[eventName + uid] instanceof Array) {
            for (var i = 0; i < subscribers[eventName + uid].length; i++) {
                var funcObject = subscribers[eventName + uid][i];
                if (funcObject && funcObject.Func && typeof funcObject.Func === 'function') {
                    runSafely(function () {
                        funcObject.Func(uid, eventArgs);
                    });
                }
            }
        }
    };

    /**
     * Return all published events
     * @param {uid} asset identifier
     */
    this.getAllReceivedEvents = function(uid) {
        return previousEvents[uid];
    }

    var getCurrentTime = function () {
        'use strict';
        if (Date.now) {
            return Date.now();
        }
        return (new Date()).getTime();
    };

    var contains = function (item, list) {
        for (var i = 0; i < list.length; i++) {
            if (list[i] === item) {
                return true;
            }
        }
        return false;
    };

    var runSafely = function (action) {
        try {
            var ret = action();
            return ret !== undefined ? ret : true;
        } catch (e) {
            return false;
        }
    };
}


/**
* A container for all the values that OpenVV collects.
* @class
* @constructor
*/
function OVVCheck() {

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
    * The height of the viewport
    * @type {Number}
    */
    this.clientHeight = -1;

    /**
    * The width of the viewport
    * @type {Number}
    */
    this.clientWidth = -1;

    /**
    * A description of any error that occurred
    * @type {String}
    */
    this.error = '';

    /**
    * Whether the tab is focused or not (populated by ActionScript)
    * @type {Boolean}
    */
    this.focus = null;

    /**
    * The frame rate of the asset (populated by ActionScript)
    * @type {Number}
    */
    this.fps = -1;

    /**
    * A unique identifier of the asset
    * @type {String}
    */
    this.id = '';

    /**
    * Whether beacon checking is supported. Beacon support is defined by
    * placing a 'control beacon' SWF off screen, and verifying that it is
    * throttled as expected.
    * @type {Boolean}
    */
    this.beaconsSupported = null;

    /**
    * Whether geometry checking is supported. Geometry support requires
    * that the asset is not within an iframe.
    * @type {Boolean}
    */
    this.geometrySupported = null;

    /**
    * The viewability state measured by the geometry technique. Only populated
    * when OVV.DEBUG is true.
    * @type {String}
    * @see {@link checkGeometry}
    * @see {@link OVV#DEBUG}
    */
    this.geometryViewabilityState = '';

    /**
    * The viewability state measured by the beacon technique. Only populated
    * when OVV.DEBUG is true.
    * @type {String}
    * @see {@link OVVAsset#checkBeacons}
    * @see {@link OVV#DEBUG}
    */
    this.beaconViewabilityState = '';

    /**
     * The viewability state measured by the css visibility technique. Only populated
     * when OVV.DEBUG is true.
     * @type {String}
     * @see {@link checkCssInvisibility}
     * @see {@link OVV#DEBUG}
     */
    this.cssViewabilityState = '';

    /**
     * The viewability state measured by the dom_obs curing technique. Only populated
     * when OVV.DEBUG is true.
     * @type {String}
     * @see {@link checkDomObscuring}
     * @see {@link OVV#DEBUG}
     */
    this.domViewabilityState = '';


    /**
    * The technique used to populate OVVCheck.viewabilityState. Will be either
    * OVV.GEOMETRY when OVV is run in the root page, or OVV.BEACON when OVV is
    * run in an iframe. When in debug mode, will always remain blank.
    * @type {String}
    * @see {@link OVV#GEOMETRY}
    * @see {@link OVV#BEACON}
    */
    this.technique = '';

    /**
    * When OVV is run in an iframe and the beacon technique is used, this array
    * is populated with the states of each beacon, identified by their index.
    * True means the beacon was viewable and false means the beacon was
    * unviewable. Beacon 0 is the 'control beacon' and should always be false.
    * @type {Array.<Boolean>|null}
    * @see {@link OVVAsset.CONTROL}
    * @see {@link OVVAsset.CENTER}
    * @see {@link OVVAsset.OUTER_TOP_LEFT}
    * @see {@link OVVAsset.OUTER_TOP_RIGHT}
    * @see {@link OVVAsset.OUTER_BOTTOM_LEFT}
    * @see {@link OVVAsset.OUTER_BOTTOM_RIGHT}
    * @see {@link OVVAsset.MIDDLE_TOP_LEFT}
    * @see {@link OVVAsset.MIDDLE_TOP_RIGHT}
    * @see {@link OVVAsset.MIDDLE_BOTTOM_LEFT}
    * @see {@link OVVAsset.MIDDLE_BOTTOM_RIGHT}
    * @see {@link OVVAsset.INNER_TOP_LEFT}
    * @see {@link OVVAsset.INNER_TOP_RIGHT}
    * @see {@link OVVAsset.INNER_BOTTOM_LEFT}
    * @see {@link OVVAsset.INNER_BOTTOM_RIGHT}
    */
    this.beacons = new Array();

    /**
    * Whether this asset is in an iframe.
    * @type {Boolean}
    * @see {@link OVV#IN_IFRAME}
    * @see {@link OVV#DEBUG}
    */
    this.inIframe = null;

    /**
    * The distance, in pixels, from the bottom of the asset to the bottom of
    * the viewport
    * @type {Number}
    */
    this.objBottom = -1;

    /**
    * The distance, in pixels, from the left of the asset to the left of
    * the viewport
    * @type {Number}
    */
    this.objLeft = -1;

    /**
    * The distance, in pixels, from the right of the asset to the right of
    * the viewport
    * @type {Number}
    */
    this.objRight = -1;

    /**
    * The distance, in pixels, from the top of the asset to the top of
    * the viewport
    * @type {Number}
    */
    this.objTop = -1;

    /**
    * The percentage of the player that is viewable within the viewport
    * @type {Number}
    */
    this.percentViewable = -1;

    /**
     * The percentage of the player that is obscured by an overlapping element
     * @type {Number}
     */
    this.percentObscured = 0;

    /**
    * Set to {@link OVVCheck#VIEWABLE} when the player was at least 50%
    * viewable. Set to OVVCheck when the player was less than 50% viewable.
    * Set to {@link OVVCheck#UNMEASURABLE} when a determination could not be made.
    * @type {String}
    * @see {@link OVVCheck.UNMEASURABLE}
    * @see {@link OVVCheck.VIEWABLE}
    * @see {@link OVVCheck.UNVIEWABLE}
    * @see {@link OVVCheck.NOT_READY}
    */
    this.viewabilityState = '';
}

/**
* The value that {@link OVVCheck#viewabilityState} will be set to if OVV cannot
* determine whether the asset is at least 50% viewable.
*/
OVVCheck.UNMEASURABLE = 'unmeasurable';

/**
* The value that {@link OVVCheck#viewabilityState} will be set to if OVV
* determines that the asset is at least 50% viewable.
*/
OVVCheck.VIEWABLE = 'viewable';

/**
* The value that {@link OVVCheck#viewabilityState} will be set to if OVV
* determines that the asset is less than 50% viewable.
*/
OVVCheck.UNVIEWABLE = 'unviewable';

/**
* The value that {@link OVVCheck#viewabilityState} will be set to if the beacons
* are not ready to determine the viewability state
*/
OVVCheck.NOT_READY = 'not_ready';

/**
* The value that {@link OVVCheck#technique} will be set to if OVV
* uses the beacon technique to determine {@link OVVCheck#viewabilityState}
*/
OVVCheck.BEACON = 'beacon';

/**
* The value that {@link OVVCheck#technique} will be set to if OVV
* uses the geometry technique to determine {@link OVVCheck#viewabilityState}
*/
OVVCheck.GEOMETRY = 'geometry';

/**
 * The value that {@link OVVCheck#technique} will be set to if OVV
 * uses css 'visibility' or 'display' state to determine an unviewable '
 * value for {@link OVVCheck#viewabilityState}
 */
OVVCheck.CSS_INVISIBILITY = 'css_invisibility';

/**
 * The value that {@link OVVCheck#technique} will be set to if OVV
 * determines the ad is more than 50% obscured by a floating element in fromt
 * of the player in {@link OVVCheck#viewabilityState}
 */
OVVCheck.DOM_OBSCURING = 'dom_obscuring';

function OVVBrowser(userAgent)
{

    var browserIDEnum = {
        MSIE: 1,
        Firefox: 2,
        Chrome: 3,
        Opera: 4,
        safari: 5
    };

    /**
     * Returns an object that contains the browser name, version, id and os if applicable
     * @param {String} ua userAgent
     */
    function getBrowserDetailsByUserAgent(ua, t) {

        var getData = function () {
            var data = { ID: 0, name: '', version: '' };
            var dataString = ua;
            for (var i = 0; i < dataBrowsers.length; i++) {
                // Fill Browser ID
                if (dataString.match(new RegExp(dataBrowsers[i].brRegex)) != null) {
                    data.ID = dataBrowsers[i].id;
                    data.name = dataBrowsers[i].name;
                    if (dataBrowsers[i].verRegex == null) {
                        break;
                    }
                    //Fill Browser Version
                    var brverRes = dataString.match(new RegExp(dataBrowsers[i].verRegex + '[0-9]*'));
                    if (brverRes != null) {
                        var replaceStr = brverRes[0].match(new RegExp(dataBrowsers[i].verRegex));
                        data.version = brverRes[0].replace(replaceStr[0], '');
                    }
                    var brOSRes = dataString.match(new RegExp(winOSRegex + '[0-9\\.]*'));
                    if (brOSRes != null) {
                        data.os = brOSRes[0];
                    }
                    break;
                }
            }
            return data;
        };

        var winOSRegex = '(Windows NT )';
        var dataBrowsers = [{
            id: 4,
            name: 'Opera',
            brRegex: 'OPR|Opera',
            verRegex: '(OPR\/|Version\/)'
        }, {
            id: 1,
            name: 'MSIE',
            brRegex: 'MSIE|Trident/7.*rv:11|rv:11.*Trident/7',
            verRegex: '(MSIE |rv:)'
        }, {
            id: 2,
            name: 'Firefox',
            brRegex: 'Firefox',
            verRegex: 'Firefox\/'
        }, {
            id: 3,
            name: 'Chrome',
            brRegex: 'Chrome',
            verRegex: 'Chrome\/'
        }, {
            id: 5,
            name: 'Safari',
            brRegex: 'Safari|(OS |OS X )[0-9].*AppleWebKit',
            verRegex: 'Version\/'
        }
        ];

        return getData();
    }

    /**
    * browser:
    *	{
    *		ID: ,
    *	  	name: '',
    *	  	version: '',
    *	    os: ''
    *	};
     */
    var  browser = getBrowserDetailsByUserAgent(userAgent);

    this.getBrowser = function()
    {
        return browser;
    }

    this.getBrowserIDEnum = function()
    {
        return browserIDEnum;
    }
}

function OVVBeaconSupportCheck()
{
    var ovvBrowser = new OVVBrowser($ovv.userAgent);

    var browser = ovvBrowser.getBrowser();
    var browserIDEnum = ovvBrowser.getBrowserIDEnum();

    this.supportsBeacons = function()
    {
        //Windows 8.1 is represented as Windows NT 6.3 in user agent string
        var WIN_8_1 = 6.3;
        var isIE = browser.ID == browserIDEnum.MSIE;
        var isSupportedIEVersion = browser.version >= 11;
        var ntVersionArr = browser.os ? browser.os.split(' ') : [0];
        var ntVersion = ntVersionArr[ntVersionArr.length - 1];
        var isSupportedOSForIE = ntVersion >= WIN_8_1;
        return !isIE || (isSupportedIEVersion && isSupportedOSForIE);
    }
}

/**
* Represents an Asset which OVV is going to determine the viewability of
* @constructor
* @param {String} uid - The unique identifier of this asset
*/
function OVVAsset(uid, dependencies) {

    ///////////////////////////////////////////////////////////////////////////
    // CONSTANTS
    ///////////////////////////////////////////////////////////////////////////

    /**
    * The total number of beacons being used
    * @type {Number}
    */
    var TOTAL_BEACONS = 13;

    /**
    * The value of the square root of 2. Computed here and saved for reuse
    * later. Approximately 1.41.
    * @type {Number}
    */
    var SQRT_2 = Math.sqrt(2);

    /**
    * The index/identifier of the control beacon, which is placed off screen to
    * test that throttling occurs.
    * @type {Number}
    */
    var CONTROL = 0;

    /**
    * The index/identifier of the center beacon, which is placed in the center
    * of the player.
    * @type {Number}
    */
    var CENTER = 1;

    /**
    * The index/identifier of the beacon placed at the top left corner of the
    * player.
    * @type {Number}
    */
    var OUTER_TOP_LEFT = 2;

    /**
    * The index/identifier of the beacon placed at the top right corner of the
    * player.
    * @type {Number}
    */
    var OUTER_TOP_RIGHT = 3;

    /**
    * The index/identifier of the beacon placed at the bottom left corner of
    * the player.
    * @type {Number}
    */
    var OUTER_BOTTOM_LEFT = 4;

    /**
    * The index/identifier of the beacon placed at the bottom right corner of
    * the player.
    * @type {Number}
    */
    var OUTER_BOTTOM_RIGHT = 5;

    /**
    * The index/identifier of the beacon placed at the top left corner of the
    * middle area. The middle area defines a region which is 50% of the total
    * area of the player.
    * @type {Number}
    */
    var MIDDLE_TOP_LEFT = 6;

    /**
    * The index/identifier of the beacon placed at the top right corner of the
    * middle area. The middle area defines a region which is 50% of the total
    * area of the player.
    * @type {Number}
    */
    var MIDDLE_TOP_RIGHT = 7;

    /**
    * The index/identifier of the beacon placed at the bottom left corner of
    * the middle area. The middle area defines a region which is 50% of the total
    * area of the player.
    * @type {Number}
    */
    var MIDDLE_BOTTOM_LEFT = 8;

    /**
    * The index/identifier of the beacon placed at the bottom right corner of
    * the middle area. The middle area defines a region which is 50% of the total
    * area of the player.
    * @type {Number}
    */
    var MIDDLE_BOTTOM_RIGHT = 9;

    /**
    * The index/identifier of the beacon placed at the top left corner of
    * the inner area. The inner area defines a region such that the area
    * outside 2 sides of it are 50% of the player's total area.
    * @type {Number}
    */
    var INNER_TOP_LEFT = 10;

    /**
    * The index/identifier of the beacon placed at the top right corner of
    * the inner area. The inner area defines a region such that the area
    * outside 2 sides of it are 50% of the player's total area.
    * @type {Number}
    */
    var INNER_TOP_RIGHT = 11;

    /**
    * The index/identifier of the beacon placed at the bottom left corner of
    * the inner area. The inner area defines a region such that the area
    * outside 2 sides of it are 50% of the player's total area.
    * @type {Number}
    */
    var INNER_BOTTOM_LEFT = 12;

    /**
    * The index/identifier of the beacon placed at the bottom right corner of
    * the inner area. The inner area defines a region such that the area
    * outside 2 sides of it are 50% of the player's total area.
    * @type {Number}
    */
    var INNER_BOTTOM_RIGHT = 13;

    /**
    * millisecond delay between repositioning beacons
    * @type {number}
    */
    var positionBeaconsIntervalDelay = 500;

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
    * the id of the ad that this asset is associated with
    * @type {!String}
    */
    var id = uid;

    /**
    * The number of beacons that have checked in as being ready
    * @type {Number}
    */
    var beaconsStarted = 0;

    /**
    * The height and width of the beacons on the page. 1 for production, 20
    * for {@link OVV#DEBUG} mode.
    * @type {Number}
    */
    var BEACON_SIZE = $ovv.DEBUG ? 20 : 1;

    /**
    * The last known location of the player on the page
    * @type {ClientRect}
    */
    var lastPlayerLocation;

    /**
    * The video player being measured
    * @type {Element}
    */
    var player;

    var geometryViewabilityCalculator = dependencies.geometryViewabilityCalculator;

    /**
    * hold a reference to a function that get the relevant beacon
    * @type {function}
    */
    var getBeaconFunc = function() {return null};

    /**
    * hold a reference to a function that get the relevant beacon continer
    * @type {function}
    */
    var getBeaconContainerFunc = function() {return null};

    var beaconSupportCheck = new OVVBeaconSupportCheck();

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
    * <p>
    * Returns an {@link OVVCheck} object populated with information gathered
    * from the browser. The viewabilityState attribute is populated with
    * either {@link OVVCheck.VIEWABLE}, {@link OVVCheck.UNVIEWABLE}, or {@link OVVCheck.UNMEASURABLE}
    * as determined by either css 'visibility' and/or 'display' attribute values, an opaque dom element
    * obscuring the player, the beacon technique when in a cross domain iframe, or the geometry
    * technique otherwise.
    * </p><p>
    * No technique can definitively prove viewability. Each technique is used in turn to confirm or
    * rule out unviewability based on its particular method of testing for unviewability.
    * </p><p>
    * The css invisibility technique tests the 'visibility' and 'display' style attributes of the player
    * and its inheritable ancestor elements. A value of visibility:hidden or display:none indicates
    * unviewability.
    * </p><p>
    * The dom obscuring technique tests for an opaque dom element obscuring more than 50% of the player
    * area.
    * </p><p>
    * The geometry technique compares the bounds of the viewport, taking
    * scrolling into account, and the bounds of the player.
    * </p><p>
    * The beacon technique places a single beacon off-screen and several
    * on top of the player. It then queries the state of the beacons on top
    * of the player to determine how much of the player is viewable.
    * </p>
    * @returns {OVVCheck}
    * @see {@link OVVCheck}
    * @see {@link checkCssInvisibility}
    * @see {@link checkDomObscuring}
    * @see {@link checkGeometry}
    * @see {@link checkBeacons}
    */
    this.checkViewability = function () {
        var check = new OVVCheck();
        check.id = id;
        check.inIframe = $ovv.IN_IFRAME;
        check.geometrySupported = $ovv.geometrySupported;
        check.focus = isInFocus();
        if (!player) {
            check.error = 'Player not found!';
            return check;
        }
        // Check if a CSS attribute value ( 'visibility:hidden' or 'display:none' )
        // on player or an inheritable containing element is rendering the player invisible.
        if (checkCssInvisibility(check, player) === true){
            if ($ovv.DEBUG) {
                check.cssViewabilityState = OVVCheck.UNVIEWABLE;
            }else{
                return check;
            }
        }
        // Check if any detectable element in the DOM is obscuring more than 50% of the
        // player area.

        if (checkDomObscuring(check, player) === true){
            if ($ovv.DEBUG) {
                check.domViewabilityState = OVVCheck.UNVIEWABLE;
            }else{
                return check;
            }
        }else{
            //player.jsTrace("obscured : " + check.percentObscured.toString());
            //player.jsTrace({OBSCURED:check.percentObscured});
        }

        // if we're in IE and we're in a cross-domain iframe, return unmeasurable
        // We are able to measure for same domain iframe ('friendly iframe')
        if (!beaconSupportCheck.supportsBeacons() && check.geometrySupported === false) {
            check.viewabilityState = OVVCheck.UNMEASURABLE;
            if (!$ovv.DEBUG) {
                return check;
            }
        }
        // if we can use the geometry method, use it over the beacon method
        if (check.geometrySupported) {
            check.technique = OVVCheck.GEOMETRY;
            checkGeometry(check, player);
            check.viewabilityState = (check.percentViewable >= 50) ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
            if ($ovv.DEBUG) {
                // add an additional field when debugging
                check.geometryViewabilityState = check.viewabilityState;
            } else {
                return check;
            }
        }
        var controlBeacon = getBeacon(0);
        var controlBeaconContainer = getBeaconContainer(0);
        // check to make sure the control beacon is found and its callback has been setup
        if (controlBeacon && controlBeacon.isViewable && controlBeaconContainer) {
            // the control beacon should always be off screen and not viewable,
            // if that's not true, it can't be used
            var controlBeaconVisible = isOnScreen(controlBeaconContainer) && controlBeacon.isViewable();
            check.beaconsSupported = !controlBeaconVisible;
        } else {
            // if the control beacon wasn't found or it isn't ready yet,
            // then beacons can't be used for this check
            check.beaconsSupported = false;
        }
        if (!beaconsReady()) {
            check.technique = OVVCheck.BEACON;
            check.viewabilityState = OVVCheck.NOT_READY;
        } else if (check.beaconsSupported) { // if the control beacon checked out, and all the beacons are ready proceed
            check.technique = OVVCheck.BEACON;
            var viewable = checkBeacons(check);

            // certain scenarios return null when the beacons can't guarantee
            // that the player is > 50% viewable, so it's deemed unmeasurable
            if (viewable === null) {
                check.viewabilityState = OVVCheck.UNMEASURABLE;
                // add this informational field when debugging
                if ($ovv.DEBUG) {
                    check.beaconViewabilityState = OVVCheck.UNMEASURABLE;
                }
            } else {
                check.viewabilityState = viewable ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
                // add this informational field when debugging
                if ($ovv.DEBUG) {
                    check.beaconViewabilityState = viewable ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
                }
            }
        } else {
            check.viewabilityState = OVVCheck.UNMEASURABLE;
        }

        // in debug mode, reconcile the viewability states from all techniques
        if ($ovv.DEBUG) {
            // revert the technique to blank during debug, since both were used
            check.technique = '';
            if (check.geometryViewabilityState === null && check.beaconViewabilityState === null) {
                check.viewabilityState = OVVCheck.UNMEASURABLE;
            } else {
                var beaconViewable = (check.beaconViewabilityState === OVVCheck.VIEWABLE);
                var cssViewable = (check.cssViewabilityState === OVVCheck.VIEWABLE);
                var domViewable = (check.domViewabilityState === OVVCheck.VIEWABLE);
                var geometryViewable = (check.geometryViewabilityState === OVVCheck.VIEWABLE);
                check.viewabilityState = (cssViewable || domViewable || beaconViewable ||
                    geometryViewable) ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
            }
        }

        return check;
    };

    /**
    * Called by each beacon to signify that it's ready to measure
    * @param {Number} index The index identifier of the beacon
    */
    this.beaconStarted = function (index) {

        if ($ovv.DEBUG && getBeacon(index).debug) {
            getBeacon(index).debug();
        }

        if (index === 0) {
            return;
        }

        beaconsStarted++;

        if (beaconsReady()) {
            player['onJsReady' + uid]();
        }
    };

    /**
    * Frees up resources created and used by the asset.
    */
    this.dispose = function () {

        for (var index = 1; index <= TOTAL_BEACONS; index++) {
            var container = getBeaconContainer(index);
            if (container) {
                delete beaconsStarted[index];
                container.parentElement.removeChild(container);
            }
        }
        clearInterval( window.$ovv.positionInterval );
        window.$ovv.removeAsset(this);
    };

    /**
    * @returns {String} The randomly generated ID of this asset
    */
    this.getId = function () {
        return id;
    };

    /**
    * @returns {Object} The associated asset's player
    */
    this.getPlayer = function () {
        return player;
    };

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Checks if the player is made invisible by css attribute 'visibility:hidden'
     * or 'display:none'.
     * Is so, viewability at the time of this check is 'not viewable' and no further check
     * is required.
     * These properties are inherited, so no need to parse up the DOM hierarchy.
     * If the player is in an iframe inheritance is restricted to elements within
     * the DOM of the iframe document
     * @param {OVVCheck} check The OVVCheck object to populate
     * @param {Element} player The HTML Element to measure
     */
    var checkCssInvisibility = function (check, player) {
        var style = window.getComputedStyle(player, null);
        var visibility = style.getPropertyValue('visibility');
        var display = style.getPropertyValue('display');
        if ( visibility == 'hidden' || display == 'none' ){
            check.technique = OVVCheck.CSS_INVISIBILITY;
            check.viewabilityState = OVVCheck.UNVIEWABLE;
            return true;
        }
        return false;
    };

    /**
     * Checks if the player is more then 50% obscured by another dom element.
     * Is so, viewability at the time of this check is 'not viewable' and no further check
     * is required.
     * If the player is in an iframe this check is restricted to elements within
     * the DOM of the iframe document
     * @param {OVVCheck} check The OVVCheck object to populate
     * @param {Element} player The HTML Element to measure
     */
    var checkDomObscuring = function(check, player){
        var playerRect = player.getBoundingClientRect(),
            offset = 12, // ToDo: Make sure test points don't overlap beacons.
            xLeft = playerRect.left+offset,
            xRight = playerRect.right-offset,
            yTop = playerRect.top+offset,
            yBottom = playerRect.bottom-offset,
            xCenter = Math.floor(playerRect.left+playerRect.width/2),
            yCenter = Math.floor(playerRect.top+playerRect.height/2),
            testPoints = [
                { x:xLeft,   y:yTop },
                { x:xCenter, y:yTop },
                { x:xRight,  y:yTop },
                { x:xLeft,   y:yCenter },
                { x:xCenter, y:yCenter },
                { x:xRight,  y:yCenter },
                { x:xLeft,   y:yBottom },
                { x:xCenter, y:yBottom },
                { x:xRight,  y:yBottom }
            ];

        for (var p in testPoints) {
            if (testPoints[p] && testPoints[p].x >= 0 && testPoints[p].y >= 0) {
                elem = document.elementFromPoint(testPoints[p].x, testPoints[p].y);

                if (elem != null && elem != player && !player.contains(elem)) {
                    overlappingArea = overlapping(playerRect, elem.getBoundingClientRect());
                    if (overlappingArea > 0) {
                        check.percentObscured = 100 * overlapping(playerRect, elem.getBoundingClientRect());
                        if (check.percentObscured > 50) {
                            check.percentViewable = 100 - check.percentObscured;
                            check.technique = OVVCheck.DOM_OBSCURING;
                            check.viewabilityState = OVVCheck.UNVIEWABLE;
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    var overlapping = function(playerRect, elem ){
        var playerArea = playerRect.width * playerRect.height;
        var  x_overlap = Math.max(0, Math.min(playerRect.right, elem.right) - Math.max(playerRect.left, elem.left));
        var  y_overlap = Math.max(0, Math.min(playerRect.bottom, elem.bottom) - Math.max(playerRect.top, elem.top));
        return (x_overlap * y_overlap) / playerArea;
    }


    /**
    * Performs the geometry technique to determine viewability. First gathers
    * information on the viewport and on the player. Then compares the two to
    * determine what percentage, if any, of the player is within the bounds
    * of the viewport.
    * @param {OVVCheck} check The OVVCheck object to populate
    * @param {Element} player The HTML Element to measure
    */
    var checkGeometry = function (check, player) {
		check.percentObscured = check.percentObscured || 0; // support override of OVVCheck by previous version  
        var viewabilityResult = geometryViewabilityCalculator.getViewabilityState(player, window);
        if (!viewabilityResult.error) {
            check.clientWidth = viewabilityResult.clientWidth;
            check.clientHeight = viewabilityResult.clientHeight;
            check.percentViewable = viewabilityResult.percentViewable - check.percentObscured;
            check.objTop = viewabilityResult.objTop;
            check.objBottom = viewabilityResult.objBottom;
            check.objLeft = viewabilityResult.objLeft;
            check.objRight = viewabilityResult.objRight;
        }
        return viewabilityResult;
    };

    /**
    * Performs the beacon technique. Queries the state of each beacon and
    * attempts to make a determination of whether at least 50% of the player
    * is within the viewport.
    * @param {OVVCheck} check The OVVCheck object to populate
    */
    var checkBeacons = function (check) {
        if (!beaconsReady()) {
            return null;
        }

        var beaconsVisible = 0;
        var outerCornersVisible = 0;
        var middleCornersVisible = 0;
        var innerCornersVisible = 0;
        check.beacons = new Array(TOTAL_BEACONS);

        //Get player dimensions:
        var objRect = player.getClientRects ? player.getClientRects()[0] : { top: -1, bottom: -1, left: -1, right: -1};
        check.objTop = objRect.top;
        check.objBottom = objRect.bottom;
        check.objLeft = objRect.left;
        check.objRight = objRect.right;

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            // the control beacon is only involved in determining if the 
            // browser supports beacon measurement, so move on
            if (index === 0) {
                continue;
            }
            var beacon = getBeacon(index);
            var beaconContainer = getBeaconContainer(index);
            var isViewable = beacon.isViewable();
            var onScreen = isOnScreen(beaconContainer);
            check.beacons[index] = isViewable && onScreen;

            if (isViewable) {

                beaconsVisible++;

                switch (index) {
                    case OUTER_TOP_LEFT:
                    case OUTER_TOP_RIGHT:
                    case OUTER_BOTTOM_LEFT:
                    case OUTER_BOTTOM_RIGHT:
                        outerCornersVisible++;
                        break;

                    case MIDDLE_TOP_LEFT:
                    case MIDDLE_TOP_RIGHT:
                    case MIDDLE_BOTTOM_LEFT:
                    case MIDDLE_BOTTOM_RIGHT:
                        middleCornersVisible++;
                        break;

                    case INNER_TOP_LEFT:
                    case INNER_TOP_RIGHT:
                    case INNER_BOTTOM_LEFT:
                    case INNER_BOTTOM_RIGHT:
                        innerCornersVisible++;
                        break;
                }
            }
        }

        // when all points are visible
        if (beaconsVisible === TOTAL_BEACONS) {
            return true;
        }

        var beacons = check.beacons;

        // when the center is not visible
        if (beacons[CENTER] === false) {
            // and 3 corners are visible
            if((innerCornersVisible >= 3) || (middleCornersVisible >= 3) || (outerCornersVisible >= 3))
            {
                return null;
            }
            return false;
        }

        // when the center of the player is visible
        if ((beacons[CENTER] === true) &&
        // and 2 adjacent outside corners are visible
            ((beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_TOP_RIGHT] === true) ||
            (beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_BOTTOM_LEFT] === true) ||
            (beacons[OUTER_TOP_RIGHT] === true && beacons[OUTER_BOTTOM_RIGHT] === true) ||
            (beacons[OUTER_BOTTOM_LEFT] === true && beacons[OUTER_BOTTOM_RIGHT] === true))
        ) {
            return true;
        }

        // when the center and all of the middle corners are visible
        if (beacons[CENTER] === true && middleCornersVisible == 4) {
            return true;
        }

        // // when top left and bottom right corners are visible
        if ((beacons[OUTER_TOP_LEFT] && beacons[OUTER_BOTTOM_RIGHT]) &&
                // and any of their diagonals are covered
            (!(beacons[MIDDLE_TOP_LEFT] && beacons[INNER_TOP_LEFT] && beacons[CENTER] && beacons[INNER_BOTTOM_RIGHT] && beacons[MIDDLE_BOTTOM_RIGHT]))
        ) {
            return null;
        }

        // when bottom left and top right corners are visible
        if ((beacons[OUTER_BOTTOM_LEFT] && beacons[OUTER_TOP_RIGHT]) &&
            // and any of their diagonals are covered
            (!(beacons[MIDDLE_BOTTOM_LEFT] && beacons[INNER_BOTTOM_LEFT] && beacons[CENTER] && beacons[INNER_TOP_RIGHT] && beacons[MIDDLE_TOP_RIGHT]))
        ) {
            return null;
        }

        return false;
    };

    /**
    * @returns {Boolean} Whether all beacons have checked in
    */
    var beaconsReady = function () {

        if (!player) {
            return false;
        }

        return beaconsStarted === TOTAL_BEACONS;
    };

    /**
    * Creates the beacon SWFs and adds them to the DOM
    * @param {String} url The URL of the beacon SWFs
    * @see {@link positionBeacons}
    */
    var createBeacons = function (url) {
        // double checking that our URL was actually set to something
        // (BEACON_SWF_URL is obfuscated here to prevent it from being
        // String substituted by ActionScript)
        // Dynamically unobfuscate to prevent minify from reconstructing original token string
        var reversed = "LRU_FWS_NOCAEB";
        var unreplaced = reversed.split("").reverse().join('');
        if (url == '' || url == unreplaced) {
            return;
        }

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var swfContainer = document.createElement('DIV');
            swfContainer.id = 'OVVBeaconContainer_' + index + '_' + id;

            swfContainer.style.position = 'absolute';
            swfContainer.style.zIndex = $ovv.DEBUG ? 99999 : -99999;

            var html =
                '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
                '<param name="movie" value="' + url + '" />' +
                '<param name="quality" value="low" />' +
                '<param name="flashvars" value="id=' + id + '&index=' + index + '" />' +
                '<param name="bgcolor" value="#ffffff" />' +
                '<param name="wmode" value="transparent" />' +
                '<param name="allowScriptAccess" value="always" />' +
                '<param name="allowFullScreen" value="false" />' +
                '<!--[if !IE]>-->' +
                '<object id="OVVBeacon_' + index + '_' + id + '" type="application/x-shockwave-flash" data="' + url + '" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
                '<param name="quality" value="low" />' +
                '<param name="flashvars" value="id=' + id + '&index=' + index + '" />' +
                '<param name="bgcolor" value="#ff0000" />' +
                '<param name="wmode" value="transparent" />' +
                '<param name="allowScriptAccess" value="always" />' +
                '<param name="allowFullScreen" value="false" />' +
                '<!--<![endif]-->' +
                '</object>';

            swfContainer.innerHTML = html;
            document.body.insertBefore(swfContainer, document.body.firstChild);
        }

        // move the beacons to their initial position
        positionBeacons.bind(this)();

        // it takes ~500ms for beacons to know if they've been moved off 
        // screen, so they're repositioned at this interval so they'll be
        // ready for the next check
        this.positionInterval = setInterval(positionBeacons.bind(this), positionBeaconsIntervalDelay);
    };

    var createFrameBeacons = function() {
        for (var index = 0; index <= TOTAL_BEACONS; index++) {
            var iframe = document.createElement('iframe');
            iframe.name = iframe.id = 'OVVFrame_' + id + '_' + index;
            iframe.width =  $ovv.DEBUG ? 20 : 1;
            iframe.height =  $ovv.DEBUG ? 20 : 1;
            iframe.frameBorder = 0;
            iframe.style.position = 'absolute';
            iframe.style.zIndex =  $ovv.DEBUG ? 99999 : -99999;

            iframe.src = 'javascript: ' +
                'window.isInViewArea = undefined; ' +
                'window.wasInViewArea = false; ' +
                'window.isInView = undefined; ' +
                'window.wasViewed = false; ' +
                'window.started = false; ' +
                'window.index = ' + index + ';'  +
                'window.isViewable = function() { return window.isInView; }; ' +
                'var cnt = 0; ' +
                'setTimeout(function() {' +
                                'var span = document.createElement("span");' +
                                'span.id = "ad1";' +
                                'document.body.insertBefore(span, document.body.firstChild);' +
                            '},300);' +
                'setTimeout(function() {setInterval(' +
                    'function() { ' +
                        'ad1 = document.getElementById("ad1");' +
                        'ad1.innerHTML = window.mozPaintCount > cnt ? "In View" : "Out of View";' +
                        'var paintCount = window.mozPaintCount; ' +
                        'window.isInView = (paintCount>cnt); ' +
                        'cnt = paintCount; ' +
                        'if (parent.$ovv.DEBUG == true) {' +
                            'if(window.isInView === true){' +
                                'document.body.style.background = "green";' +
                            '} else {' +
                                'document.body.style.background = "red";' +
                            '}' +
                        '}' +
                        'if (window.started === false) {' +
                            'parent.$ovv.getAssetById("'+id+'")' + '.beaconStarted(window.index);' +
                            'window.started = true;' +
                        '}' +
                    '}, 500)},400);';

            document.body.insertBefore(iframe, document.body.firstChild);
        }

        // move the frames to their initial position
        positionBeacons.bind(this)();

        // it takes ~500ms for beacons to know if they've been moved off
        // screen, so they're repositioned at this interval so they'll be
        // ready for the next check
        this.positionInterval = setInterval(positionBeacons.bind(this), positionBeaconsIntervalDelay);
    };

    /**
    * Repositions the beacon SWFs on top of the player
    */
    var positionBeacons = function () {

        if (!beaconsReady()) {
            return;
        }

        var playerLocation = player.getClientRects()[0];

        // when we don't have an initial position, or the position hasn't changed 
        if (lastPlayerLocation && playerLocation && (lastPlayerLocation.left === playerLocation.left && lastPlayerLocation.right === playerLocation.right && lastPlayerLocation.top === playerLocation.top && lastPlayerLocation.bottom === playerLocation.bottom)) {
            // no need to update positions
            return;
        }

        // save for next time
        lastPlayerLocation = playerLocation;

        var playerWidth = playerLocation.right - playerLocation.left;
        var playerHeight = playerLocation.bottom - playerLocation.top;

        var innerWidth = playerWidth / (1 + SQRT_2);
        var innerHeight = playerHeight / (1 + SQRT_2);

        var middleWidth = playerWidth / SQRT_2;
        var middleHeight = playerHeight / SQRT_2;

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var left = playerLocation.left + document.body.scrollLeft;
            var top = playerLocation.top + document.body.scrollTop;

            switch (index) {
                case CONTROL:
                    left = -100000;
                    top = -100000;
                    break;
                case CENTER:
                    left += (playerWidth - BEACON_SIZE) / 2;
                    top += (playerHeight - BEACON_SIZE) / 2;
                    break;
                case OUTER_TOP_LEFT:
                    // nothing to do, already at default position
                    break;
                case OUTER_TOP_RIGHT:
                    left += playerWidth - BEACON_SIZE;
                    break;
                case OUTER_BOTTOM_LEFT:
                    top += playerHeight - BEACON_SIZE;
                    break;
                case OUTER_BOTTOM_RIGHT:
                    left += playerWidth - BEACON_SIZE;
                    top += playerHeight - BEACON_SIZE;
                    break;
                case MIDDLE_TOP_LEFT:
                    left += (playerWidth - middleWidth) / 2;
                    top += (playerHeight - middleHeight) / 2;
                    break;
                case MIDDLE_TOP_RIGHT:
                    left += ((playerWidth - middleWidth) / 2) + middleWidth;
                    top += (playerHeight - middleHeight) / 2;
                    break;
                case MIDDLE_BOTTOM_LEFT:
                    left += (playerWidth - middleWidth) / 2;
                    top += ((playerHeight - middleHeight) / 2) + middleHeight;
                    break;
                case MIDDLE_BOTTOM_RIGHT:
                    left += ((playerWidth - middleWidth) / 2) + middleWidth;
                    top += ((playerHeight - middleHeight) / 2) + middleHeight;
                    break;
                case INNER_TOP_LEFT:
                    left += (playerWidth - innerWidth) / 2;
                    top += (playerHeight - innerHeight) / 2;
                    break;
                case INNER_TOP_RIGHT:
                    left += ((playerWidth - innerWidth) / 2) + innerWidth;
                    top += (playerHeight - innerHeight) / 2;
                    break;
                case INNER_BOTTOM_LEFT:
                    left += (playerWidth - innerWidth) / 2;
                    top += ((playerHeight - innerHeight) / 2) + innerHeight;
                    break;
                case INNER_BOTTOM_RIGHT:
                    left += ((playerWidth - innerWidth) / 2) + innerWidth;
                    top += ((playerHeight - innerHeight) / 2) + innerHeight;
                    break;
            }

            // center the middle and inner beacons on their intended point
            if (index >= MIDDLE_TOP_LEFT) {
                left -= (BEACON_SIZE / 2);
                top -= (BEACON_SIZE / 2);
            }

            var swfContainer = getBeaconContainer(index);
            swfContainer.style.left = left + 'px';
            swfContainer.style.top = top + 'px';
        }
    };

    /**
    * Determines whether a DOM element is within the bounds of the viewport
    * @param {Element} element An HTML Element
    * @returns {Boolean} Whether the parameter is at least partially within
    * the browser's viewport
    */
    var isOnScreen = function (element) {

        if (!element) {
            return false;
        }

        var screenWidth = Math.max(document.body.clientWidth, window.innerWidth);
        var screenHeight = Math.max(document.body.clientHeight, window.innerHeight);
        var objRect = element.getClientRects()[0];

        return (objRect.top < screenHeight && objRect.bottom > 0 && objRect.left < screenWidth && objRect.right > 0);
    };

    /**
    * @returns {Element|null} A beacon by its index
    * Use memoize implementation to reduce duplicate document.getElementById calls
    */
    var getBeacon = (function (index) {
        return getBeaconFunc(index);
    }).memoize();

    /**
    * @returns {Element|null} A beacon by its index
    */
    var getFlashBeacon = function (index) {
        return document.getElementById('OVVBeacon_' + index + '_' + id);
    }

    /**
    * @returns {Element|null} A beacon frame container by its index
    */
    var getFrameBeacon = function (index) {
        var frame = document.getElementById('OVVFrame_' + id + '_' + index);
        var contentWindow = null;
        if (frame) {
            contentWindow = frame.contentWindow;
        }
        return contentWindow;
    };

    /**
    * @returns {Element|null} A beacon container by its index.
    * Use memoize implementation to reduce duplicate document.getElementById calls
    */
    var getBeaconContainer = (function (index) {
        return getBeaconContainerFunc(index);
    }).memoize();

    /**
    * @returns {Element|null} A beacon container by its index
    */
    var getFlashBeaconContainer = function (index) {
        return document.getElementById('OVVBeaconContainer_' + index + '_' + id);
    };

    /**
    * @returns {Element|null} A beacon frame container by its index
    */
    var getFrameBeaconContainer = function (index) {
        return document.getElementById('OVVFrame_' + id + '_' + index);
    };

    /**
    * Finds the video player associated with this asset by searching through
    * each EMBED and OBJECT element on the page, testing to see if it has the
    * randomly generated callback signature.
    * @returns {Element|null} The video player being measured
    */
    var findPlayer = function () {

        var embeds = document.getElementsByTagName('embed');

        for (var i = 0; i < embeds.length; i++) {
            if (embeds[i][id]) {
                return embeds[i];
            }
        }

        var objs = document.getElementsByTagName('object');

        for (var i = 0; i < objs.length; i++) {
            if (objs[i][id]) {
                return objs[i];
            }
        }

        return null;
    };

    var isInFocus = function () {
        if (document.hidden !== 'undefined'){
            if (document.hidden === true){
                // Either the browser window is minified or the page is on an inactive tab.
                // Ad cannot be visible. No need to test document.hasFocus()
                return false;
            }
        }

        // Either we are on an unminified, active tab or 'document.hidden' is not supported).
        // Are we in the active window? ...
        if ($ovv.IN_XD_IFRAME) {
            // Active browser window cannot be determined, and document.hasFocus()
            // fails if player iframe does not have focus within its containing page
            // Give the benefit of the doubt.
            return true;
        }

        // We are in a same-domain iframe (or not in iframe at all)
        // Active browser window can be determined by widow.top.document.hasFocus():
        if (window.top.document.hasFocus) {
            return window.top.document.hasFocus();
        }

        //Cannot be determined : Give the benefit of the doubt.
        return true;
    };

    player = findPlayer();

    // only use the beacons if geometry is not supported, or we we are in DEBUG mode.
    if ($ovv.geometrySupported == false || $ovv.DEBUG) {
        if ($ovv.browser.ID === $ovv.browserIDEnum.Firefox){
            //Use frame technique to measure viewability in cross domain FF scenario
            getBeaconFunc = getFrameBeacon;
            getBeaconContainerFunc = getFrameBeaconContainer;
            createFrameBeacons.bind(this)();
        }
        else {
            getBeaconFunc = getFlashBeacon;
            getBeaconContainerFunc = getFlashBeaconContainer;
            // 'BEACON_SWF_URL' is String substituted from ActionScript
            createBeacons.bind(this)('BEACON_SWF_URL');
        }
    } else if (player && player['onJsReady' + uid]) {
        // since we don't have to wait for beacons to be ready, we're ready now
        setTimeout(function () {
            player['onJsReady' + uid]()
        }, 5); //Use a tiny timeout to keep this async like the beacons
    }
}


function OVVGeometryViewabilityCalculator() {

    this.getViewabilityState = function (element, contextWindow) {
        var minViewPortSize = getMinViewPortSize(),
            viewablePercentage;
        if (minViewPortSize.area == Infinity) {
            return { error: 'Failed to determine viewport'};
        }
        var assetRect = element.getBoundingClientRect();
        var playerArea = assetRect.width * assetRect.height;
        if ((minViewPortSize.area / playerArea) < 0.5) {
            // no position testing required if viewport is less than half the area of the player
            viewablePercentage = Math.floor(100 * minViewPortSize.area / playerArea);
        }else{
            var viewPortSize = getViewPortSize(window.top),
                visibleAssetSize = getAssetVisibleDimension(element, contextWindow);
            //var viewablePercentage = getAssetViewablePercentage(assetSize, viewPortSize);
            //Height within viewport:
            if ( visibleAssetSize.bottom > viewPortSize.height ) {
                //Partially below the bottom
                visibleAssetSize.height -= (visibleAssetSize.bottom - viewPortSize.height);
            }
            if ( visibleAssetSize.top < 0 ) {
                //Partially above the top
                visibleAssetSize.height += visibleAssetSize.top;
            }
            if ( visibleAssetSize.left < 0 ) {
                visibleAssetSize.width += visibleAssetSize.left;
            }
            if ( visibleAssetSize.right > viewPortSize.width ) {
                visibleAssetSize.width -= ( visibleAssetSize.right - viewPortSize.width );
            }
            // Viewable percentage is the portion of the ad that's visible divided by the size of the ad
            viewablePercentage = Math.floor( 100 * ( visibleAssetSize.width * visibleAssetSize.height ) / playerArea );
        }
        /*
        //Get player dimensions:
        var assetRect = element.getBoundingClientRect();
        */
        return {
            clientWidth: viewPortSize.width,
            clientHeight: viewPortSize.height,
            objTop: assetRect.top,
            objBottom: assetRect.bottom,
            objLeft: assetRect.left,
            objRight: assetRect.right,
            percentViewable: viewablePercentage
        };
    };

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    // Check nested iframes
    var getMinViewPortSize = function (){
        var minViewPortSize = getViewPortSize(window),
            minViewPortArea = minViewPortSize.area,
            currentWindow = window;

        while (currentWindow != window.top){
            currentWindow = currentWindow.parent;
            viewPortSize = getViewPortSize(currentWindow);
            if (viewPortSize.area < minViewPortArea){
                minViewPortArea = viewPortSize.area;
                minViewPortSize = viewPortSize;
            }
        }
        return minViewPortSize;
    }


    /**
     * Get the viewport size by taking the smallest dimensions
     */
    var getViewPortSize = function (contextWindow) {
        var viewPortSize = {
            width: Infinity,
            height: Infinity,
            area:Infinity
        };

        //document.body  - Handling case where viewport is represented by documentBody
        //.width
        if (!isNaN(contextWindow.document.body.clientWidth) && contextWindow.document.body.clientWidth > 0) {
            viewPortSize.width = contextWindow.document.body.clientWidth;
        }
        //.height
        if (!isNaN(contextWindow.document.body.clientHeight) && contextWindow.document.body.clientHeight > 0) {
            viewPortSize.height = contextWindow.document.body.clientHeight;
        }
        //document.documentElement - Handling case where viewport is represented by documentElement
        //.width
        if (!!contextWindow.document.documentElement && !!contextWindow.document.documentElement.clientWidth && !isNaN(contextWindow.document.documentElement.clientWidth)) {
            viewPortSize.width = contextWindow.document.documentElement.clientWidth;
        }
        //.height
        if (!!contextWindow.document.documentElement && !!contextWindow.document.documentElement.clientHeight && !isNaN(contextWindow.document.documentElement.clientHeight)) {
            viewPortSize.height = contextWindow.document.documentElement.clientHeight;
        }
        //window.innerWidth/Height - Handling case where viewport is represented by window.innerH/W
        //.innerWidth
        if (!!contextWindow.innerWidth && !isNaN(contextWindow.innerWidth)) {
            viewPortSize.width = Math.min(viewPortSize.width, contextWindow.innerWidth);
        }
        //.innerHeight
        if (!!contextWindow.innerHeight && !isNaN(contextWindow.innerHeight)) {
            viewPortSize.height = Math.min(viewPortSize.height, contextWindow.innerHeight);
        }
        viewPortSize.area = viewPortSize.height * viewPortSize.width;
        return viewPortSize;
    };

    /**
     * Recursive function that return the asset (element) visible dimension
     * @param {element} The element to get his visible dimension
     * @param {contextWindow} The relative window
     */

    var getAssetVisibleDimension = function (element, contextWindow) {
        var currWindow = contextWindow;
        //Set parent window for recursive call
        var parentWindow = contextWindow.parent;
        var resultDimension = { width: 0, height: 0, left: 0, right: 0, top: 0, bottom: 0 };

        if (element) {
            var elementRect = getPositionRelativeToViewPort(element, contextWindow);
            elementRect.width = elementRect.right - elementRect.left;
            elementRect.height = elementRect.bottom - elementRect.top;
            resultDimension = elementRect;
            //Calculate the relative element dimension if we clime to a parent window
            if (currWindow != parentWindow) {
                //Recursive call to get the relative element dimension from the parent window
                var parentDimension = getAssetVisibleDimension(currWindow.frameElement, parentWindow);
                //The asset is partially below the parent window (asset bottom is below the visible window)
                if (parentDimension.bottom < resultDimension.bottom) {
                    if (parentDimension.bottom < resultDimension.top) {
                        //The entire asset is below the parent window
                        resultDimension.top = parentDimension.bottom;
                    }
                    //Set the asset bottom to be the visible part
                    resultDimension.bottom = parentDimension.bottom;
                }
                //The asset is partially right to the parent window
                if (parentDimension.right < resultDimension.right) {
                    if (parentDimension.right < resultDimension.left) {
                        //The entire asset is to the right of the parent window
                        resultDimension.left = parentDimension.right;
                    }
                    //Set the asset right to be the visible
                    resultDimension.right = parentDimension.right;
                }

                resultDimension.width = resultDimension.right - resultDimension.left;
                resultDimension.height = resultDimension.bottom - resultDimension.top;
            }
        }
        return resultDimension;
    };

    var getPositionRelativeToViewPort = function (element, contextWindow) {
        var currWindow = contextWindow;
        var parentWindow = contextWindow.parent;
        var resultPosition = { left: 0, right: 0, top: 0, bottom: 0 };

        if (element) {
            var elementRect = element.getBoundingClientRect();
            if (currWindow != parentWindow) {
                resultPosition = getPositionRelativeToViewPort(currWindow.frameElement, parentWindow);
			}
                resultPosition = {
                    left: elementRect.left + resultPosition.left,
                    right: elementRect.right + resultPosition.left,
                    top: elementRect.top + resultPosition.top,
                    bottom: elementRect.bottom + resultPosition.top
                };
        }
        return resultPosition;
    };
    /**
     * Calculate asset viewable percentage given the asset size and the viewport
     * @param {effectiveAssetRect} the asset viewable rect; effectiveAssetRect = {left :, top :,bottom:,right:,}
     * @param {viewPortSize} the browser viewport size;
     */
    var getAssetViewablePercentage = function (effectiveAssetRect, viewPortSize) {
        // holds the asset viewable surface
        var assetVisibleHeight = 0, assetVisibleWidth = 0;
        var asset = {
            width: effectiveAssetRect.right - effectiveAssetRect.left,
            height: effectiveAssetRect.bottom - effectiveAssetRect.top
        };

        // Ad is 100% out off-view
        if (effectiveAssetRect.bottom < 0 // the entire asset is above the viewport
            || effectiveAssetRect.right < 0 // the entire asset is left to the viewport
            || effectiveAssetRect.top > viewPortSize.height // the entire asset bellow the viewport
            || effectiveAssetRect.left > viewPortSize.width // the entire asset is right to the viewport
            || asset.width <= 0 // the asset width is zero
            || asset.height <= 0)  // the asset height is zero
        {
            return 0;
        }
        // ---- Handle asset visible height ----
        // the asset is partially above the viewport
        if (effectiveAssetRect.top < 0) {
            // take the visible part
            assetVisibleHeight = asset.height + effectiveAssetRect.top;
            //if the asset height is larger then the viewport height, set the asset height to be the viewport height
            if (assetVisibleHeight > viewPortSize.height) {
                assetVisibleHeight = viewPortSize.height;
            }
        }
        // the asset is partially below the viewport
        else if (effectiveAssetRect.top + asset.height > viewPortSize.height) {
            // take the visible part
            assetVisibleHeight = viewPortSize.height - effectiveAssetRect.top;
        }
        // the asset is in the viewport
        else {
            assetVisibleHeight = asset.height;
        }
        // ---- Handle asset visible width ----
        // the asset is partially left to the viewport
        if (effectiveAssetRect.left < 0) {
            // take the visible part
            assetVisibleWidth = asset.width + effectiveAssetRect.left;
            //if the asset width is larger then the viewport width, set the asset width to be the viewport width
            if (assetVisibleWidth > viewPortSize.width) {
                assetVisibleWidth = viewPortSize.width;
            }
        }
        // the asset is partially right to the viewport
        else if (effectiveAssetRect.left + asset.width > viewPortSize.width) {
            // take the visible part
            assetVisibleWidth = viewPortSize.width - effectiveAssetRect.left;
        }
        // the asset is in the viewport
        else {
            assetVisibleWidth = asset.width;
        }
        // Divied the visible asset area by the full asset area to the the visible percentage
        return Math.round((((assetVisibleWidth * assetVisibleHeight)) / (asset.width * asset.height)) * 100);
    };
}

// A memoize function to store function results
Function.prototype.memoized = function(key) {
    this._cacheValue = this._cacheValue || {};
    return this._cacheValue[key] !== undefined ?
        this._cacheValue[key] : // return from cache
        this._cacheValue[key] = this.apply(this, arguments); // call the function is not exist in cache and store in cache for next time
};

Function.prototype.memoize = function() {
    var fn = this;
    return function() {
        return fn.memoized.apply(fn, arguments);
    }
};
var newOVV = new OVV();		
// initialize the OVV object if it doesn't exist
window.$ovv = window.$ovv || newOVV;		
for(var i in newOVV){		
    if(!$ovv.hasOwnProperty(i)){		
        $ovv[i] = newOVV[i];		
   }		
}

// 'OVVID' is String substituted from AS
window.$ovv.addAsset(new OVVAsset('OVVID', { geometryViewabilityCalculator: new OVVGeometryViewabilityCalculator() }));
