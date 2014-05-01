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
 * @constructor
 */
function OVV() {

    this.DEBUG = true;

    /**
     * The container for the assets
     * @type {object}
     */
    var assets = {};

    this.asset = null;

    /**
     * Stores an Element
     * @param {Element} An element to observe
     */
    this.addAsset = function(ovvAsset) {
        if (!assets.hasOwnProperty(ovvAsset.getId())) {
            assets[ovvAsset.getId()] = ovvAsset;
            // save a reference for convenience
            this.asset = ovvAsset;
        }
    }

    /**
     * Removes an Element from storage
     * @param {Element} The element to remove
     */
    this.removeAsset = function(ovvAsset) {
        delete assets[ovvAsset.getId()];
    }

    /**
     * Retreives an Element based on its ID
     * @param {string} The id of the element to retreive
     * @returns {Element|null} The element matching the given ID
     */
    this.getAssetById = function(id) {
        return assets[id];
    }

    /**
     * @returns {object} an object containing all of the OVVAssets being tracked
     */
    this.getAds = function() {
        var copy = {};
        for (var id in assets) {
            if (assets.hasOwnProperty(id)) {
                copy[id] = assets[id];
            }
        }
        return copy;
    }
}

function OVVCheck() {

    this.clientHeight = -1;

    this.clientWidth = -1;

    this.error = '';

    this.focus = null;

    this.fps = -1;

    this.id = '';

    this.beaconsSupported = null;

    this.geometrySupported = null;

    this.technique = '';

    this.beacons = new Array();

    this.inIframe = null;

    this.objBottom = -1;

    this.objLeft = -1;

    this.objRight = -1;

    this.objTop = -1;

    this.percentViewable = -1;

    this.viewabilityState = '';

    this.viewable = null;
}

OVVCheck.UNMEASURABLE = 'unmeasurable';
OVVCheck.VIEWABLE = 'viewable';
OVVCheck.UNVIEWABLE = 'unviewable';
OVVCheck.BEACON = 'beacon';
OVVCheck.GEOMETRY = 'geometry';

/**
 * Represents an Asset which OVV is going to determine the viewability of
 * @constructor
 * @param {string} uid - The unique identifier of this asset
 */
function OVVAsset(uid) {


    /**
     * The total number of beacons being used
     * @type {number}
     */
    const TOTAL_BEACONS = 13;

    const SQRT_2 = Math.sqrt(2);

    const CONTROL = 0;

    const OUTER_TOP_LEFT = 1;
    const OUTER_TOP_RIGHT = 2;

    const CENTER = 3;

    const OUTER_BOTTOM_LEFT = 4;
    const OUTER_BOTTOM_RIGHT = 5;

    const MIDDLE_TOP_LEFT = 6;
    const MIDDLE_TOP_RIGHT = 7;
    const MIDDLE_BOTTOM_LEFT = 8
    const MIDDLE_BOTTOM_RIGHT = 9;

    const INNER_OUTER_TOP_LEFT = 10;
    const INNER_OUTER_TOP_RIGHT = 11;
    const INNER_OUTER_BOTTOM_LEFT = 12
    const INNER_OUTER_BOTTOM_RIGHT = 13;

    //
    // PRIVATE ATTRIBUTES
    //

    /**
     * the id of the ad that this asset is associatied with
     * @type {!string}
     */
    var id = uid;

    /**
     * The numer of beacons that have checked in as being ready
     * @type {number}
     */
    var beaconsStarted = 0;

    /**
     * The height and width of the beacons on the page (1 for prod, greater for visibilty/testing)
     * @type {!number}
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

    //
    // PUBLIC FUNCTIONS
    //

    /**
     * @returns {Element} The video player that is being measured
     */
    this.getPlayer = function() {

        if (!player) {
            player = findPlayer();
        }

        return player;
    };

    /**
     * @returns {boolean} Whether the player is viewable, as reported by at least 3 of the Beacon SWFs
     */
    var isPlayerViewable = function(check) {

        if (!this.beaconsReady()) {
            return null;
        }

        var beaconsVisible = 0;
        var innerCornersVisible = 0;
        var outerCornersVisible = 0;
        var middleCornersVisible = 0;
        check.beacons = new Array(TOTAL_BEACONS);

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var beacon = getBeacon(index);
            var isVisible = beacon.isVisible();
            var onScreen = isOnScreen(beacon);

            check.beacons[index] = isVisible && isOnScreen;

            if (index === 0) {
                continue;
            }

            if (isVisible) {

                beaconsVisible++;

                switch (index) {
                    case OUTER_TOP_LEFT:
                    case OUTER_TOP_RIGHT:
                    case OUTER_BOTTOM_LEFT:
                    case OUTER_BOTTOM_RIGHT:
                        outerCornersVisible++;
                        break;

                    case MIDDLE_TOP_LEFT = 6:
                    case MIDDLE_TOP_RIGHT = 7:
                    case MIDDLE_BOTTOM_LEFT = 8:
                    case MIDDLE_BOTTOM_RIGHT = 9:
                        middleCornersVisible++;
                        break;

                    case INNER_OUTER_TOP_LEFT:
                    case INNER_OUTER_TOP_RIGHT:
                    case INNER_OUTER_BOTTOM_LEFT:
                    case INNER_OUTER_BOTTOM_RIGHT:
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
            (beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_TOP_RIGHT] == true) ||
            (beacons[OUTER_TOP_LEFT] === true && beacons[OUTER_BOTTOM_LEFT] == true) ||
            (beacons[OUTER_TOP_RIGHT] === true && beacons[OUTER_BOTTOM_RIGHT] == true) ||
            (beacons[OUTER_BOTTOM_LEFT] === true && beacons[OUTER_BOTTOM_RIGHT] == true)
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

        // // when top left and bottom right match
        // if (beacons[OUTER_TOP_LEFT] === beacons[OUTER_BOTTOM_RIGHT] &&
        //     // and the beacons between them don't match their status
        //     (beacons[INNER_OUTER_TOP_LEFT] && beacons[CENTER] && beacons[INNER_OUTER_BOTTOM_RIGHT]) !== (beacons[OUTER_TOP_LEFT] && beacons[OUTER_BOTTOM_RIGHT])
        // ) {
        //     return null;
        // }

        // // when top bottom left and top right match
        // if (beacons[OUTER_BOTTOM_LEFT] === beaconse[OUTER_TOP_RIGHT]
        //     // and the beacons between them don't match their status
        //     (beacons[INNER_OUTER_BOTTOM_LEFT] && beacons[CENTER] && beacons[INNER_OUTER_TOP_RIGHT]) !== (beacons[OUTER_BOTTOM_LEFT] && beaconse[OUTER_TOP_RIGHT])
        // ) {
        //     return null;
        // }

        return false;
    };

    this.checkViewability = function() {

        var check = new OVVCheck();
        check.id = id;
        check.inIframe = (parent !== window);
        check.geometrySupported = !check.inIframe;

        if (!player) {
            check.error = 'Player not found!';
            return check;
        }

        if (check.geometrySupported) {
            checkGeometry.bind(this)(check, player);
        }

        var controlBeacon = getBeacon(0);
        if (controlBeacon && controlBeacon.isVisible) {
            var controlBeaconVisible = isOnScreen(controlBeacon) && controlBeacon.isVisible();
            check.beaconsSupported = !controlBeaconVisible;
        } else {
            check.beaconsSupported = false;
        }

        var useBeacons = check.beaconsSupported && this.beaconsReady();
        var useGeometry = check.geometrySupported;

        if (useGeometry) {
            check.technique = OVVCheck.GEOMETRY;
            check.viewabilityState = (check.percentViewable >= 50) ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
        } else if (useBeacons) {
            check.technique = OVVCheck.BEACON;
            var viewable = isPlayerViewable.bind(this)(check);
            if (viewable === null) {
                check.viewabilityState = OVVCheck.UNMEASURABLE;
            } else {
                check.viewabilityState = viewable ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;
            }
        } else {
            check.viewabilityState = OVVCheck.UNMEASURABLE;
        }

        return check;
    };

    var checkGeometry = function(check, player) {
        //Avoid including scrollbars in viewport size by taking the smallest dimensions (also
        //ensures ad object is not obscured)
        check.clientWidth = Infinity;
        check.clientHeight = Infinity;
        //document.body  - Handling case where viewport is represented by documentBody
        //.width
        if (!isNaN(document.body.clientWidth) && document.body.clientWidth > 0) {
            check.clientWidth = document.body.clientWidth;
        }
        //.height
        if (!isNaN(document.body.clientHeight) && document.body.clientHeight > 0) {
            check.clientHeight = document.body.clientHeight;
        }
        //document.documentElement - Handling case where viewport is represented by documentElement
        //.width
        if ( !! document.documentElement && !! document.documentElement.clientWidth && !isNaN(document.documentElement.clientWidth)) {
            check.clientWidth = document.documentElement.clientWidth;
        }
        //.height
        if ( !! document.documentElement && !! document.documentElement.clientHeight && !isNaN(document.documentElement.clientHeight)) {
            check.clientHeight = document.documentElement.clientHeight;
        }
        //window.innerWidth/Height - Handling case where viewport is represented by window.innerH/W
        //.innerWidth
        if ( !! window.innerWidth && !isNaN(window.innerWidth)) {
            check.clientWidth = Math.min(check.clientWidth,
                window.innerWidth);

        }
        //.innerHeight
        if ( !! window.innerHeight && !isNaN(window.innerHeight)) {
            check.clientHeight = Math.min(check.clientHeight,
                window.innerHeight);
        }
        if (check.clientHeight == Infinity || check.clientWidth == Infinity) {
            check = {
                "error": "Failed to determine viewport"
            };
        } else {
            //Get player dimensions:
            var objRect = player.getClientRects()[0];
            check.objTop = objRect.top;
            check.objBottom = objRect.bottom;
            check.objLeft = objRect.left;
            check.objRight = objRect.right;

            if (objRect.bottom < 0 || objRect.right < 0 ||
                objRect.top > check.clientHeight || objRect.left > check.clientWidth) {
                //Entire object is out of viewport
                check.percentViewable = 0;
            } else {
                var totalObjectArea = (objRect.right - objRect.left) *
                    (objRect.bottom - objRect.top);
                var xMin = Math.ceil(Math.max(0, objRect.left));
                var xMax = Math.floor(Math.min(check.clientWidth, objRect.right));
                var yMin = Math.ceil(Math.max(0, objRect.top));
                var yMax = Math.floor(Math.min(check.clientHeight, objRect.bottom));
                var visibleObjectArea = (xMax - xMin + 1) * (yMax - yMin + 1);
                check.percentViewable = Math.round(visibleObjectArea / totalObjectArea * 100);
            }
        }
    }

    /**
     * Called by each beacon on startup to signify that it's ready to measure
     * @param {number} The index identifier of the beacon
     */
    this.beaconStarted = function(index) {

        if ($ovv.DEBUG) {
            getBeacon(index).debug();
        }

        if (index == 0) {
            return;
        }

        beaconsStarted++;

        if (this.beaconsReady()) {
            player.startImpressionTimer();
        }
    };

    /**
     * @returns {boolean} Whether all beacons have checked in
     */
    this.beaconsReady = function() {

        if (!this.getPlayer()) {
            return false;
        }

        return beaconsStarted === TOTAL_BEACONS;
    };

    /**
     * Tears down the asset
     */
    this.dispose = function() {

        for (var index = 1; index <= TOTAL_BEACONS; index++) {
            var container = getBeaconContainer(index);
            if (container) {
                delete beaconsStarted[index];
                container.parentElement.removeChild(container);
            }
        }

        window.$ovv.removeAsset(this);
    };

    /**
     * @returns {string} The randomly generated ID of this asset
     */
    this.getId = function() {
        return id;
    };

    // PRIVATE FUNCTIONS

    /**
     * Creates the beacon SWFs and adds them to the DOM
     * @param {string} The URL of the beacon SWFs
     * @see {@link positionSWFs}
     */
    var createBeacons = function(url) {

        // double checking that our URL was actually set to something
        // obfuscating BEACON _SWF_ URL so it doesn't get string replaced 
        // by ActionScript
        if (url === '' || url === ('BEACON' + '_SWF_' + 'URL')) {
            return;
        }


        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var swfContainer = document.createElement('DIV');
            swfContainer.id = 'OVVBeaconContainer_' + index + '_' + id;

            swfContainer.style.position = 'absolute';
            swfContainer.style.zIndex = $ovv.DEBUG ? 99999 : -99999;

            var html =
                '<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
                '<param name="movie" value="' + url + '?id=' + id + '&index=' + index + '" />' +
                '<param name="quality" value="low" />' +
                '<param name="bgcolor" value="#ffffff" />' +
                '<param name="wmode" value="transparent" />' +
                '<param name="allowScriptAccess" value="always" />' +
                '<param name="allowFullScreen" value="false" />' +
                '<!--[if !IE]>-->' +
                '<object id="OVVBeacon_' + index + '_' + id + '" type="application/x-shockwave-flash" data="' + url + '?id=' + id + '&index=' + index + '" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
                '<param name="quality" value="low" />' +
                '<param name="bgcolor" value="#ff0000" />' +
                '<param name="wmode" value="transparent" />' +
                '<param name="allowScriptAccess" value="always" />' +
                '<param name="allowFullScreen" value="false" />' +
                '<!--<![endif]-->' +
                '</object>';

            swfContainer.innerHTML = html;
            document.body.insertBefore(swfContainer, document.body.firstChild);
        }

        positionSWFs.bind(this)();

        // it takes ~500ms for beacons to know if they've been moved off 
        // screen, so we reposition them at this interval so they'll be
        // ready for the next check
        setInterval(positionSWFs.bind(this), 500);
    };

    /**
     * Finds the video player associated with this asset by searching through
     * each EMBED and OBJECT element on the page, testing to see if it has the
     * randomly generated callback signature.
     * @returns {Element|null} The video player being measured
     */
    var findPlayer = function() {

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

    /**
     * Repositions the beacon SWFs on top of the video player
     */
    var positionSWFs = function() {

        if (!this.beaconsReady()) {
            return;
        }

        var playerLocation = this.getPlayer().getClientRects()[0];

        // when we don't have an initial position, or the position hasn't changed 
        if (lastPlayerLocation && (lastPlayerLocation.left === playerLocation.left && lastPlayerLocation.right === playerLocation.right && lastPlayerLocation.top === playerLocation.top && lastPlayerLocation.bottom === playerLocation.bottom)) {
            // no need to update positions
            return;
        }

        // save for next time
        lastPlayerLocation = playerLocation;

        var innerWidth = playerLocation.width / (1 + SQRT_2);
        var innerHeight = playerLocation.height / (1 + SQRT_2);

        var middleWidth = playerLocation.width / SQRT_2;
        var middleHeight = playerLocation.height / SQRT_2;

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var left = playerLocation.left + document.body.scrollLeft;
            var top = playerLocation.top + document.body.scrollTop;

            switch (index) {
                case CONTROL:
                    left = -100000;
                    top = -100000;
                    break;

                case OUTER_TOP_LEFT:
                    // nothing to do, already at default position
                    break;

                case OUTER_TOP_RIGHT:
                    left += playerLocation.width - BEACON_SIZE;
                    break;

                case CENTER:
                    left += (playerLocation.width - BEACON_SIZE) / 2;
                    top += (playerLocation.height - BEACON_SIZE) / 2;
                    break;

                case OUTER_BOTTOM_LEFT:
                    top += playerLocation.height - BEACON_SIZE;
                    break;

                case OUTER_BOTTOM_RIGHT:
                    left += playerLocation.width - BEACON_SIZE;
                    top += playerLocation.height - BEACON_SIZE;
                    break;

                case MIDDLE_TOP_LEFT:
                    left += (playerLocation.width - middleWidth) / 2;
                    top += (playerLocation.height - middleHeight) / 2;
                    break;

                case MIDDLE_TOP_RIGHT:
                    left += ((playerLocation.width - middleWidth) / 2) + middleWidth;
                    top += (playerLocation.height - middleHeight) / 2;
                    break;

                case MIDDLE_BOTTOM_LEFT:
                    left += (playerLocation.width - middleWidth) / 2;
                    top += ((playerLocation.height - middleHeight) / 2) + middleHeight;
                    break;

                case MIDDLE_BOTTOM_RIGHT:
                    left += ((playerLocation.width - middleWidth) / 2) + middleWidth;
                    top += ((playerLocation.height - middleHeight) / 2) + middleHeight;
                    break;

                case INNER_OUTER_TOP_LEFT:
                    left += (playerLocation.width - innerWidth) / 2;
                    top += (playerLocation.height - innerHeight) / 2;
                    break;

                case INNER_OUTER_TOP_RIGHT:
                    left += ((playerLocation.width - innerWidth) / 2) + innerWidth;
                    top += (playerLocation.height - innerHeight) / 2;
                    break;

                case INNER_OUTER_BOTTOM_LEFT:
                    left += (playerLocation.width - innerWidth) / 2;
                    top += ((playerLocation.height - innerHeight) / 2) + innerHeight;
                    break;

                case INNER_OUTER_BOTTOM_RIGHT:
                    left += ((playerLocation.width - innerWidth) / 2) + innerWidth;
                    top += ((playerLocation.height - innerHeight) / 2) + innerHeight;
                    break;
            }

            // center the inner beacons on their intended point
            if (index >= INNER_OUTER_TOP_LEFT) {
                left -= (BEACON_SIZE / 2);
                top -= (BEACON_SIZE / 2);
            }

            var swfContainer = getBeaconContainer(index)
            swfContainer.style.left = left + 'px';
            swfContainer.style.top = top + 'px';
        }
    };

    /**
     * @param {Element} An HTML DOM Element
     * @returns {boolean} Whether the parameter is at least partially within the browser's viewport
     */
    var isOnScreen = function(element) {

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
    var getBeacon = function(index) {
        return document.getElementById('OVVBeacon_' + index + '_' + id);
    };

    /**
     * @returns {Element|null} A beacon container by its index
     */
    var getBeaconContainer = function(index) {
        return document.getElementById('OVVBeaconContainer_' + index + '_' + id);
    };

    // 'BEACON_SWF_URL' is string substituted from ActionScript
    createBeacons.bind(this)('BEACON_SWF_URL');
}

// initialize the OVV object if it doesn't exist
window.$ovv = window.$ovv || new OVV();

// 'OVVID' is string substituted from AS
window.$ovv.addAsset(new OVVAsset('OVVID'));