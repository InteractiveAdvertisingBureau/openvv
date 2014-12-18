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

/**
* A container for all OpenVV instances running on the page
* @class
* @constructor
*/
function OVV() {
    var that = this;

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
    * Whether OpenVV is running within an iframe or not.
    * @type {Boolean}
    */
    this.IN_IFRAME = (window.top !== window.self);

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

    var userAgent = window.testOvvConfig && window.testOvvConfig.userAgent ? window.testOvvConfig.userAgent : navigator.userAgent;

    /**
    * Returns an object that contains the browser name, version and id {@link OVV#browserIDEnum}		
    * @param {ua} userAgent
    */
    function getBrowserDetailsByUserAgent(ua) {

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
    };

    this.browserSupportsBeacons = function()
    {
        //Windows 8.1 is represented as Windows NT 6.3 in user agent string
        var WIN_8_1 = 6.3;
        var isIE = that.browser.ID == that.browserIDEnum.MSIE;
        var isSupportedIEVersion = that.browser.version >= 11;
        var ntVersionArr = that.browser.version ? that.browser.version.split(' ') : [0];
        var ntVersion = ntVersionArr[ntVersionArr.length - 1];
        var isSupportedOSForIE = ntVersion >= WIN_8_1;
        var isFF = that.browser.ID == that.browserIDEnum.Firefox;
        return !((isIE && !(isSupportedIEVersion && isSupportedOSForIE)) || isFF);
    }

    this.browserIDEnum = {
        MSIE: 1,
        Firefox: 2,
        Chrome: 3,
        Opera: 4,
        safari: 5
    };

    /**
    * browser:
    *	{ 
    *		ID: ,  
    *	  	name: '', 
    *	  	version: '',
    *	    os: ''
    *	};
    */
    this.browser = getBrowserDetailsByUserAgent(userAgent);

    this.servingScenarioEnum = { OnPage: 1, SameDomainIframe: 2, CrossDomainIframe: 3 };

    function getServingScenarioType(servingScenarioEnum) {
        try {
            if (window.top == window) {
                return servingScenarioEnum.OnPage;
            } else if (window.top.document.domain == window.document.domain) {
                return servingScenarioEnum.SameDomainIframe;
            }
        } catch (e) { }
        return servingScenarioEnum.CrossDomainIframe;
    };

    this.servingScenario = getServingScenarioType(this.servingScenarioEnum);

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
                if (contains(previousEvents[uid][key].eventName, events)) {
                    runSafely(function () {
                        func(uid, previousEvents[uid][key]); // changed in vtag.js
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
                if (funcObject && funcObject.Func && typeof funcObject.Func === "function") {
                    runSafely(function () {
                        funcObject.Func(uid, eventArgs);
                    });
                }
            }
        }
    };

    var getCurrentTime = function () {
        "use strict";
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
    * placing a "control beacon" SWF off screen, and verifying that it is
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
    * unviewable. Beacon 0 is the "control beacon" and should always be false.
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

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
    * <p>
    * Returns an {@link OVVCheck} object populated with information gathered
    * from the browser. The viewabilityState attribute is populated with
    * either {@link OVVCheck.VIEWABLE}, {@link OVVCheck.UNVIEWABLE}, or {@link OVVCheck.UNMEASURABLE}
    * as determined by either beacon technique when in a cross domain iframe, or the
    * geometry technique otherwise.
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
    * @see {@link checkGeometry}
    * @see {@link checkBeacons}
    */
    this.checkViewability = function () {
        var check = new OVVCheck();
        check.id = id;
        check.inIframe = $ovv.IN_IFRAME;
        check.geometrySupported = $ovv.servingScenario !== $ovv.servingScenarioEnum.CrossDomainIframe;

        check.focus = isInFocus();
        if (!player) {
            check.error = 'Player not found!';
            return check;
        }

        // if we're in IE or FF and we're in an cross domain iframe, return unmeasurable						
        // We are able to measure for same domain iframe ('friendly iframe')
        if (!$ovv.browserSupportsBeacons() &&
            check.geometrySupported === false) {
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

        // check to make sure the control beacon is found and its 
        // callback has been setup
        if (controlBeacon && controlBeacon.isViewable) {
            // the control beacon should always be off screen and not viewable,
            // if that's not true, it can't be used
            var controlBeaconVisible = isOnScreen(controlBeacon) && controlBeacon.isViewable();
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

        // in debug mode, reconcile the viewability states from both techniques
        if ($ovv.DEBUG) {
            // revert the technique to blank during debug, since both were used
            check.technique = '';
            if (check.geometryViewabilityState === null && check.beaconViewabilityState === null) {
                check.viewabilityState = OVVCheck.UNMEASURABLE;
            } else {
                var beaconViewable = (check.beaconViewabilityState === OVVCheck.VIEWABLE);
                var geometryViewable = (check.geometryViewabilityState === OVVCheck.VIEWABLE);
                check.viewabilityState = (beaconViewable || geometryViewable) ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
            }
        }

        return check;
    };

    /**
    * Called by each beacon to signify that it's ready to measure
    * @param {Number} index The index identifier of the beacon
    */
    this.beaconStarted = function (index) {

        if ($ovv.DEBUG) {
            getBeacon(index).debug();
        }

        if (index === 0) {
            return;
        }

        beaconsStarted++;

        if (beaconsReady()) {
            player.onJsReady();
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
    * Performs the geometry technique to determine viewability. First gathers
    * information on the viewport and on the player. The compares the two to
    * determine what percentage, if any, of the player is within the bounds
    * of the viewport.
    * @param {OVVCheck} check The OVVCheck object to populate
    * @param {Element} player The HTML Element to measure
    */
    var checkGeometry = function (check, player) {
        var viewabilityResult = geometryViewabilityCalculator.getViewabilityState(player, window);
        
        if (!viewabilityResult.error) {            
            check.clientWidth = viewabilityResult.clientWidth;
            check.clientHeight = viewabilityResult.clientHeight;
            check.percentViewable =  viewabilityResult.percentViewable;
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
        var objRect = player.getClientRects()[0];
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
            var isViewable = beacon.isViewable();
            var onScreen = isOnScreen(beacon);
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
        // when the center of the player is visible
        if ((beacons[CENTER] === true) &&
        // and 2 adjacent outside corners are visible
            ((beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_TOP_RIGHT] == true) ||
            (beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_BOTTOM_LEFT] == true) ||
            (beacons[OUTER_TOP_RIGHT] === true && beacons[OUTER_BOTTOM_RIGHT] == true) ||
            (beacons[OUTER_BOTTOM_LEFT] === true && beacons[OUTER_BOTTOM_RIGHT] == true))
        ) {
            return true;
        }

        // when any 3 of the inner corners are visible
        if (beacons[CENTER] === false && innerCornersVisible >= 3) {
            return true;
        }

        // when the center and all of the middle corners are visible
        if (beacons[CENTER] === true && middleCornersVisible == 4) {
            return true;
        }

        // // when top left and bottom right corners are visible
        if ((beacons[OUTER_TOP_LEFT] && beacons[OUTER_BOTTOM_RIGHT]) &&
            // and any of their diagonals are covered
            (!beacons[MIDDLE_TOP_LEFT] || ![INNER_TOP_LEFT] || !beacons[CENTER] || beacons[INNER_BOTTOM_RIGHT] || beacons[MIDDLE_BOTTOM_RIGHT])
        ) {
            return null;
        }

        // when bottom left and top right corners are visible
        if ((beacons[OUTER_BOTTOM_LEFT] && beacons[OUTER_TOP_RIGHT]) &&
            // and any of their diagonals are covered
            (!beacons[MIDDLE_BOTTOM_LEFT] || !beacons[INNER_BOTTOM_LEFT] || !beacons[CENTER] || !beacons[INNER_TOP_RIGHT] || !beacons[MIDDLE_TOP_RIGHT])
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
        if (url === '' || url === ('BEACON' + '_SWF_' + 'URL')) {
            return;
        }

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var swfContainer = document.createElement('DIV');
            swfContainer.id = 'OVVBeaconContainer_' + index + '_' + id;

            swfContainer.style.position = 'absolute';
            swfContainer.style.zIndex = $ovv.DEBUG ? 99999 : -99999;

            var html =
                '<object id="OVVBeacon_' + index + '_' + id + '" type="application/x-shockwave-flash" data="' + url + '" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
                    '<param name="quality" value="low" />' +
                    '<param name="flashvars" value="id=' + id + '&index=' + index + '" />' +
                    '<param name="bgcolor" value="#ff0000" />' +
                    '<param name="wmode" value="transparent" />' +
                    '<param name="allowScriptAccess" value="always" />' +
                    '<param name="allowFullScreen" value="false" />' +
                '</object>';

            swfContainer.innerHTML = html;
            document.body.insertBefore(swfContainer, document.body.firstChild);
        }

        // move the beacons to their initial position
        positionBeacons.bind(this)();

        // it takes ~500ms for beacons to know if they've been moved off 
        // screen, so they're repositioned at this interval so they'll be
        // ready for the next check
        this.positionInterval = setInterval(positionBeacons.bind(this), 500);
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
        if (lastPlayerLocation && (lastPlayerLocation.left === playerLocation.left && lastPlayerLocation.right === playerLocation.right && lastPlayerLocation.top === playerLocation.top && lastPlayerLocation.bottom === playerLocation.bottom)) {
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
    */
    var getBeacon = function (index) {
        return document.getElementById('OVVBeacon_' + index + '_' + id);
    };

    /**
    * @returns {Element|null} A beacon container by its index
    */
    var getBeaconContainer = function (index) {
        return document.getElementById('OVVBeaconContainer_' + index + '_' + id);
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
        var inFocus = true;
        if (typeof document.hidden !== 'undefined') {
            inFocus = window.document.hidden ? false : true;
        } else if (document.hasFocus) {
            inFocus = document.hasFocus();
        }

        if ($ovv.IN_IFRAME === false && inFocus === true && document.hasFocus) {
            inFocus = document.hasFocus();
        }

        return inFocus;
    };

    player = findPlayer();

    // only use the beacons if we're in an iframe, but go ahead and add them
    // during debug mode
    if ($ovv.IN_IFRAME || $ovv.DEBUG) {
        // 'BEACON_SWF_URL' is String substituted from ActionScript
        createBeacons.bind(this)('BEACON_SWF_URL');
    } else if (player && player.onJsReady) {
		// since we don't have to wait for beacons to be ready, we're ready now
		setTimeout( function(){ player.onJsReady() }, 5 ); //Use a tiny timeout to keep this async like the beacons
    }
}

function OVVGeometryViewabilityCalculator() {

    this.getViewabilityState = function (element, contextWindow) {
        var viewPortSize = getViewPortSize();
        if (viewPortSize.height == Infinity || viewPortSize.width == Infinity) {
            return { error: "Failed to determine viewport"};
        }

        var assetSize = getAssetVisibleDimension(element, contextWindow);
        var viewablePercentage = getAssetViewablePercentage(assetSize, viewPortSize);
        //Get player dimensions:
        var assetRect = element.getBoundingClientRect();
        
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
    
    /**
    * Get the viewport size by taking the smallest dimensions
    */
    var getViewPortSize = function () {
        var viewPortSize = {
            width: Infinity,
            height: Infinity
        };

        var contextWindow = window.top;

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
            if (currWindow != parentWindow)
                resultPosition = getPositionRelativeToViewPort(currWindow.frameElement, parentWindow);
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
        var assetVisiableHeight = 0, assetVisiableWidth = 0;

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
            assetVisiableHeight = asset.height + effectiveAssetRect.top;
            //if the asset height is larger then the viewport height, set the asset height to be the viewport height
            if (assetVisiableHeight > viewPortSize.height) {
                assetVisiableHeight = viewPortSize.height;
            }
        }
        // the asset is partially below the viewport
        else if (effectiveAssetRect.top + asset.height > viewPortSize.height) {
            // take the visible part
            assetVisiableHeight = viewPortSize.height - effectiveAssetRect.top;
        }
        // the asset is in the viewport
        else {
            assetVisiableHeight = asset.height;
        }

        // ---- Handle asset visible width ----
        // the asset is partially left to the viewport
        if (effectiveAssetRect.left < 0) {
            // take the visible part
            assetVisiableWidth = asset.width + effectiveAssetRect.left;
            //if the asset width is larger then the viewport width, set the asset width to be the viewport width
            if (assetVisiableWidth > viewPortSize.width) {
                assetVisiableWidth = viewPortSize.width;
            }
        }
        // the asset is partially right to the viewport
        else if (effectiveAssetRect.left + asset.width > viewPortSize.width) {
            // take the visible part
            assetVisiableWidth = viewPortSize.width - effectiveAssetRect.left;
        }
        // the asset is in the viewport
        else {
            assetVisiableWidth = asset.width;
        }

        // Divied the visible asset area by the full asset area to the the visible percentage
        return Math.round((((assetVisiableWidth * assetVisiableHeight)) / (asset.width * asset.height)) * 100);
    };
}

// initialize the OVV object if it doesn't exist
window.$ovv = window.$ovv || new OVV();

// 'OVVID' is String substituted from AS
window.$ovv.addAsset(new OVVAsset('OVVID', { geometryViewabilityCalculator: new OVVGeometryViewabilityCalculator() }));
