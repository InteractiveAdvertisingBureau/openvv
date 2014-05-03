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

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Determines whether OpenVV should run in debug mode. Debug mode always
     * adds beacon SWFs to the page, which are color-coded based on their
     * status. OVVCheck.beaconViewabilityState and
     * OVVCheck.geometryViewabilityState are also populated in debug mode.
     * @type {boolean}
     * @see {@link OVVCheck.geometryViewabilityState}
     * @see {@link OVVCheck.beaconViewabilityState}
     * @see {@link OVVAsset.BEACON_SIZE}
     */
    this.DEBUG = false;

    /**
     * Whether OpenVV is running within an iframe or not.
     * @type {boolean}
     */
    this.IN_IFRAME = (parent !== window);

    /**
     * The last asset added to OVV. Useful for easy access from the
     * JavaScript console.
     * @type {OVVAsset}
     */
    this.asset = null;

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
     * An object for storing assets by their id.
     * @type {object}
     */
    var assets = {};

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

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

/**
 * A container for all the values that OpenVV collects.
 * @constructor
 */
function OVVCheck() {

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

    /**
     * The height of the viewport
     * @type {number}
     */
    this.clientHeight = -1;

    /**
     * The width of the viewport
     * @type {number}
     */
    this.clientWidth = -1;

    /**
     * A description of any error that occured
     * @type {string}
     */
    this.error = '';

    /**
     * Whether the tab is focused or not (populated by ActionScript)
     * @type {boolean}
     */
    this.focus = null;

    /**
     * The framerate of the asset (populated by ActionScript)
     * @type {number}
     */
    this.fps = -1;

    /**
     * A unique identifier of the asset measured
     * @type {string}
     */
    this.id = '';

    /**
     * Whether beacon checking is supported. Beacon support is defined by
     * placing a "control beacon" SWF off screen, and verifying that it is
     * throttled as expected.
     * @type {boolean}
     */
    this.beaconsSupported = null;

    /**
     * Whether geometry checking is supported. Geometry support requires
     * that the asset is not within an iframe.
     * @type {boolean}
     */
    this.geometrySupported = null;

    /**
     * The viewability state measured by the geometry technique. Only populated
     * when OVV.DEBUG is true.
     * @type {string}
     * @see {@link OVVAsset.checkGeometry}
     * @see {@link OVV.DEBUG}
     */
    this.geometryViewabilityState = '';

    /**
     * The viewability state measured by the beacon technique. Only populated
     * when OVV.DEBUG is true.
     * @type {string}
     * @see {@link OVVAsset.checkBeacons}
     * @see {@link OVV.DEBUG}
     */
    this.beaconViewabilityState = '';

    /**
     * The technique used to populate OVVCheck.viewabilityState. Will be either
     * OVV.GEOMETRY when OVV is run in the root page, or OVV.BEACON when OVV is
     * run in an iframe. When in debug mode, will always remain blank.
     * @type {string}
     * @see {@link OVV.GEOMETRY}
     * @see {@link OVV.BEACON}
     */
    this.technique = '';

    /**
     * When OVV is run in an iframe and the beacon technique is used, this array
     * is populated with the states of each beacon, identified by their index.
     * True means the beacon was viewable and false means the beacon was
     * unviewable. Beacon 0 is the "control beacon" and should always be false.
     * @type {array<boolean>|null}
     * @see {@link OVVAsset.CONTROL}
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
     * @type {boolean}
     * @see {@link OVV.IN_IFRAME}
     * @see {@link OVV.DEBUG}
     */
    this.inIframe = null;

    /**
     * The distance, in pixels, from the bottom of the asset to the bottom of
     * the viewport
     * @type {number}
     */
    this.objBottom = -1;

    /**
     * The distance, in pixels, from the left of the asset to the left of
     * the viewport
     * @type {number}
     */
    this.objLeft = -1;

    /**
     * The distance, in pixels, from the right of the asset to the right of
     * the viewport
     * @type {number}
     */
    this.objRight = -1;

    /**
     * The distance, in pixels, from the top of the asset to the top of
     * the viewport
     * @type {number}
     */
    this.objTop = -1;

    /**
     * The percentage of the player that is viewable within the viewport
     * @type {number}
     */
    this.percentViewable = -1;

    /**
     * Set to OVVCheck.VIEWABLE when the player was at least 50%
     * viewable. Set to OVVCheck when the player was less than 50% viewable.
     * Set to OVVCheck.UNMEASURABLE when a determination could not be made.
     * @type {string}
     * @see {@link OVVCheck.UNMEASURABLE}
     * @see {@link OVVCheck.VIEWABLE}
     * @see {@link OVVCheck.UNVIEWABLE}
     */
    this.viewabilityState = '';
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

    ///////////////////////////////////////////////////////////////////////////
    // CONSTANTS
    ///////////////////////////////////////////////////////////////////////////

    /**
     * The total number of beacons being used
     * @type {number}
     */
    const TOTAL_BEACONS = 13;

    /**
     * The value of the square root of 2. Computed here and saved for reuse
     * later. Approximately 1.41.
     * @type {number}
     */
    const SQRT_2 = Math.sqrt(2);

    /**
     * The index/identifier of the control beacon, which is placed off screen to
     * test that throttling occurs.
     * @type {number}
     */
    const CONTROL = 0;

    /**
     * The index/identifier of the center beacon, which is placed in the center
     * of the player.
     * @type {number}
     */
    const CENTER = 1;

    /**
     * The index/identifier of the beacon placed at the top left corner of the
     * player.
     * @type {number}
     */
    const OUTER_TOP_LEFT = 2;

    /**
     * The index/identifier of the beacon placed at the top right corner of the
     * player.
     * @type {number}
     */
    const OUTER_TOP_RIGHT = 3;

    /**
     * The index/identifier of the beacon placed at the bottom left corner of
     * the player.
     * @type {number}
     */
    const OUTER_BOTTOM_LEFT = 4;

    /**
     * The index/identifier of the beacon placed at the bottom right corner of
     * the player.
     * @type {number}
     */
    const OUTER_BOTTOM_RIGHT = 5;

    /**
     * The index/identifier of the beacon placed at the top left corner of the
     * middle area. The middle area defines a region which is 50% of the total
     * area of the player.
     * @type {number}
     */
    const MIDDLE_TOP_LEFT = 6;

    /**
     * The index/identifier of the beacon placed at the top right corner of the
     * middle area. The middle area defines a region which is 50% of the total
     * area of the player.
     * @type {number}
     */
    const MIDDLE_TOP_RIGHT = 7;

    /**
     * The index/identifier of the beacon placed at the bottom left corner of
     * the middle area. The middle area defines a region which is 50% of the total
     * area of the player.
     * @type {number}
     */
    const MIDDLE_BOTTOM_LEFT = 8;

    /**
     * The index/identifier of the beacon placed at the bottom right corner of
     * the middle area. The middle area defines a region which is 50% of the total
     * area of the player.
     * @type {number}
     */
    const MIDDLE_BOTTOM_RIGHT = 9;

    /**
     * The index/identifier of the beacon placed at the top left corner of
     * the inner area. The inner area defines a region such that the area
     * outside 2 sides of it are 50% of the player's total area.
     * @type {number}
     */
    const INNER_TOP_LEFT = 10;

    /**
     * The index/identifier of the beacon placed at the top right corner of
     * the inner area. The inner area defines a region such that the area
     * outside 2 sides of it are 50% of the player's total area.
     * @type {number}
     */
    const INNER_TOP_RIGHT = 11;

    /**
     * The index/identifier of the beacon placed at the bottom left corner of
     * the inner area. The inner area defines a region such that the area
     * outside 2 sides of it are 50% of the player's total area.
     * @type {number}
     */
    const INNER_BOTTOM_LEFT = 12;

    /**
     * The index/identifier of the beacon placed at the bottom right corner of
     * the inner area. The inner area defines a region such that the area
     * outside 2 sides of it are 50% of the player's total area.
     * @type {number}
     */
    const INNER_BOTTOM_RIGHT = 13;

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE ATTRIBUTES
    ///////////////////////////////////////////////////////////////////////////

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

    ///////////////////////////////////////////////////////////////////////////
    // PUBLIC FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Returns an OVVCheck object populated with information gathered from the
     * browser. The viewabilityState attribute is populated with either
     * OVVCheck.VIEWABLE, OVVCheck.UNVIEWABLE, or OVVCheck.UNMEASURABLE as
     * determined by either the geometry technique or beacon technique when in
     * an iframe.
     *
     * The geometry technique compares the bounds of the viewport, taking
     * scrolling into account, and the bounds of the player.
     *
     * The beacon technique places a single beacon offscreen and several
     * on top of the player. It then queries the state of the beacons on top
     * of the player to determine how much of the player is viewable.
     *
     * @returns {OVVCheck}
     * @see {@link OVVCheck}
     * @see {@link checkGeometry}
     * @see {@link checkBeacons}
     */
    this.checkViewability = function() {

        var check = new OVVCheck();
        check.id = id;
        check.inIframe = $ovv.IN_IFRAME;
        check.geometrySupported = !$ovv.IN_IFRAME;

        if (!player) {
            check.error = 'Player not found!';
            return check;
        }

        // if we can use the geometry method, use it over the beacon method
        if (check.geometrySupported) {
            check.technique = OVVCheck.GEOMETRY;
            checkGeometry.bind(this)(check, player);
            check.viewabilityState = (check.percentViewable >= 50) ? OVVCheck.VIEWABLE : OVVCheck.UNVIEWABLE;

            if ($ovv.DEBUG) {
                // add an additonal field when debugging
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

        // if the control beacon checked out, and all the beacons are ready
        // proceed
        if (check.beaconsSupported && beaconsReady()) {
            check.technique = OVVCheck.BEACON;
            var viewable = checkBeacons.bind(this)(check);
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

        if (beaconsReady()) {
            player.startImpressionTimer();
        }
    };

    /**
     * Frees up resources created and used by the asset.
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

    ///////////////////////////////////////////////////////////////////////////
    // PRIVATE FUNCTIONS
    ///////////////////////////////////////////////////////////////////////////

    /**
     * Performs the geometry technique to determin viewability. First gathers
     * information on the viewport and on the player. The compares the two to
     * determine what percentage, if any, of the player is within the bounds
     * of the viewport.
     * @param {OVVCheck} check The OVVCheck object to populate
     * @param {Element} player The DOM element to measure
     */
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
     * Performs the beacon technique. Queries the state of each beacon and
     * attempts to make a determination of whether at least 50% of the player
     * is within the viewport.
     * @param {OVVCheck} check The OVVCheck object to populate
     */
    var checkBeacons = function(check) {

        if (!beaconsReady()) {
            return null;
        }

        var beaconsVisible = 0;
        var outerCornersVisible = 0;
        var middleCornersVisible = 0;
        var innerCornersVisible = 0;
        check.beacons = new Array(TOTAL_BEACONS);

        for (var index = 0; index <= TOTAL_BEACONS; index++) {

            var beacon = getBeacon(index);
            var isViewable = beacon.isViewable();
            var onScreen = isOnScreen(beacon);

            check.beacons[index] = isViewable && isOnScreen;

            // the control beacon is only involved in determining if the 
            // browser supports beacon measurement, so move on
            if (index === 0) {
                continue;
            }

            if (isViewable) {

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
     * @returns {boolean} Whether all beacons have checked in
     */
    var beaconsReady = function() {

        if (!player) {
            return false;
        }

        return beaconsStarted === TOTAL_BEACONS;
    };

    /**
     * Creates the beacon SWFs and adds them to the DOM
     * @param {string} The URL of the beacon SWFs
     * @see {@link positionBeacons}
     */
    var createBeacons = function(url) {

        // double checking that our URL was actually set to something
        // (BEACON_SWF_URL is obfuscated here to prevent it from being
        // string substituted by ActionScript)
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

        // move the beacons to their initial position
        positionBeacons.bind(this)();

        // it takes ~500ms for beacons to know if they've been moved off 
        // screen, so they're repositioned at this interval so they'll be
        // ready for the next check
        setInterval(positionBeacons.bind(this), 500);
    };

    /**
     * Repositions the beacon SWFs on top of the player
     */
    var positionBeacons = function() {

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
                case CENTER:
                    left += (playerLocation.width - BEACON_SIZE) / 2;
                    top += (playerLocation.height - BEACON_SIZE) / 2;
                    break;
                case OUTER_TOP_LEFT:
                    // nothing to do, already at default position
                    break;
                case OUTER_TOP_RIGHT:
                    left += playerLocation.width - BEACON_SIZE;
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
                case INNER_TOP_LEFT:
                    left += (playerLocation.width - innerWidth) / 2;
                    top += (playerLocation.height - innerHeight) / 2;
                    break;
                case INNER_TOP_RIGHT:
                    left += ((playerLocation.width - innerWidth) / 2) + innerWidth;
                    top += (playerLocation.height - innerHeight) / 2;
                    break;
                case INNER_BOTTOM_LEFT:
                    left += (playerLocation.width - innerWidth) / 2;
                    top += ((playerLocation.height - innerHeight) / 2) + innerHeight;
                    break;
                case INNER_BOTTOM_RIGHT:
                    left += ((playerLocation.width - innerWidth) / 2) + innerWidth;
                    top += ((playerLocation.height - innerHeight) / 2) + innerHeight;
                    break;
            }

            // center the middle and inner beacons on their intended point
            if (index >= MIDDLE_TOP_LEFT) {
                left -= (BEACON_SIZE / 2);
                top -= (BEACON_SIZE / 2);
            }

            var swfContainer = getBeaconContainer(index)
            swfContainer.style.left = left + 'px';
            swfContainer.style.top = top + 'px';
        }
    };

    /**
     * Determines whether a DOM element is within the bounds of the viewport
     * @param {Element} A DOM Element
     * @returns {boolean} Whether the parameter is at least partially within
     * the browser's viewport
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

    player = findPlayer();

    // only use the beacons if we're in an iframe, but go ahead and add them
    // during debug mode
    if ($ovv.IN_IFRAME || $ovv.DEBUG) {
        // 'BEACON_SWF_URL' is string substituted from ActionScript
        createBeacons.bind(this)('BEACON_SWF_URL');
    } else {
        // since we don't have to wait for beacons to be ready, we start the 
        // impression timer now
        player.startImpressionTimer();
    }
}

// initialize the OVV object if it doesn't exist
window.$ovv = window.$ovv || new OVV();

// 'OVVID' is string substituted from AS
window.$ovv.addAsset(new OVVAsset('OVVID'));