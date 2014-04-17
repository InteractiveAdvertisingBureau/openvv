/**
 * A container for all OpenVV instances running on the page
 * @constructor
 */
function OVV() {

    /**
     * The container for the ads
     * @type {object}
     */
    var ads = {};

    /**
     * Stores an Element
     * @param {Element} An element to observe
     */
    this.addAd = function(ovvAsset) {
        if (!ads.hasOwnProperty(ovvAsset.getId())) {
            ads[ovvAsset.getId()] = ovvAsset;
        }
    }

    /**
     * Removes an Element from storage
     * @param {Element} The element to remove
     */
    this.removeAd = function(ovvAsset) {
        delete ads[ovvAsset.getId()];
    }

    /**
     * Retreives an Element based on its ID
     * @param {string} The id of the element to retreive
     * @returns {Element|null} The element matching the given ID
     */
    this.getAdById = function(id) {
        return ads[id];
    }

    /**
     * @returns {object} an object containing all of the OVVAssets being tracked
     */
    this.getAds = function() {
        var copy = {};
        for (var id in ads) {
            if (ads.hasOwnProperty(id)) {
                copy[id] = ads[id];
            }
        }
        return copy;
    }
}

/**
 * Represents an Asset which OVV is going to determine the viewability of
 * @constructor
 * @param {string} uid - The unique identifier of this asset
 */
function OVVAsset(uid) {

    //
    // PRIVATE ATTRIBUTES
    //

    /**
     * the id of the ad that this asset is associatied with
     * @type {!string}
     */
    var id = uid;

    /**
     * Stores the indices of the beacons that are on the page as the key, each associated with a value of true
     * @type {!Object.<number, boolean>}
     */
    var beaconsStarted = {};

    /**
     * The height and width of the beacons on the page (1 for prod, greater for visibilty/testing)
     * @type {!number}
     */
    var BEACON_SIZE = 1;

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
    this.isPlayerViewable = function() {

        positionSWFs.bind(this)();

        var visible = 0;

        for (var index = 1; index <= 5; index++) {
            if (isOnScreen(getBeacon(index)) && getBeacon(index).isVisible()) {
                visible += 1;
            }
        }
        return visible >= 3;
    };

    this.checkViewability = function() {

        if (!player) {
            return {
                "error": "Object not found"
            };
        }

        var results = {};
        //Capture the player id for reporting (not necessary to check viewability):
        results['id'] = id;
        //Avoid including scrollbars in viewport size by taking the smallest dimensions (also
        //ensures ad object is not obscured)
        results['clientWidth'] = Infinity;
        results['clientHeight'] = Infinity;
        //document.body  - Handling case where viewport is represented by documentBody
        //.width
        if (!isNaN(document.body.clientWidth) && document.body.clientWidth > 0) {
            results['clientWidth'] = document.body.clientWidth;
        }
        //.height
        if (!isNaN(document.body.clientHeight) && document.body.clientHeight > 0) {
            results['clientHeight'] = document.body.clientHeight;
        }
        //document.documentElement - Handling case where viewport is represented by documentElement
        //.width
        if ( !! document.documentElement && !! document.documentElement.clientWidth && !isNaN(document.documentElement.clientWidth)) {
            results['clientWidth'] = document.documentElement.clientWidth;
        }
        //.height
        if ( !! document.documentElement && !! document.documentElement.clientHeight && !isNaN(document.documentElement.clientHeight)) {
            results['clientHeight'] = document.documentElement.clientHeight;
        }
        //window.innerWidth/Height - Handling case where viewport is represented by window.innerH/W
        //.innerWidth
        if ( !! window.innerWidth && !isNaN(window.innerWidth)) {
            results['clientWidth'] = Math.min(results['clientWidth'],
                window.innerWidth);

        }
        //.innerHeight
        if ( !! window.innerHeight && !isNaN(window.innerHeight)) {
            results['clientHeight'] = Math.min(results['clientHeight'],
                window.innerHeight);
        }
        if (results['clientHeight'] == Infinity || results['clientWidth'] == Infinity) {
            results = {
                "error": "Failed to determine viewport"
            };
        } else {
            //Get player dimensions:
            var objRect = player.getClientRects()[0];
            results['objTop'] = objRect.top;
            results['objBottom'] = objRect.bottom;
            results['objLeft'] = objRect.left;
            results['objRight'] = objRect.right;

            if (objRect.bottom < 0 || objRect.right < 0 ||
                objRect.top > results.clientHeight || objRect.left > results.clientWidth) {
                //Entire object is out of viewport
                results['percentViewable'] = 0;
            } else {
                var totalObjectArea = (objRect.right - objRect.left) *
                    (objRect.bottom - objRect.top);
                var xMin = Math.ceil(Math.max(0, objRect.left));
                var xMax = Math.floor(Math.min(results.clientWidth, objRect.right));
                var yMin = Math.ceil(Math.max(0, objRect.top));
                var yMax = Math.floor(Math.min(results.clientHeight, objRect.bottom));
                var visibleObjectArea = (xMax - xMin + 1) * (yMax - yMin + 1);
                results['percentViewable'] = Math.round(visibleObjectArea / totalObjectArea * 100);
            }
        }

        if (!this.isReady() || !player) {
            results['viewabilityState'] = 'unmeasurable';
        } else {
            results['viewabilityState'] = this.isPlayerViewable() ? 'viewable' : 'notViewable';
        }

        return results;
    };

    /**
     * Called by each beacon on startup to signify that it's ready to measure
     * @param {number} The index identifier of the beacon
     */
    this.beaconStarted = function(index) {
        beaconsStarted[index] = true;

        if (this.isReady()) {
            player.ready();
        }
    };

    /**
     * @returns {boolean} Whether all beacons have been added to the page
     */
    this.isReady = function() {
        var ready = 0;

        for (beacon in beaconsStarted) {
            ready += 1;
        }

        return ready === 5;
    };

    /**
     * Tears down the asset
     */
    this.dispose = function() {

        for (var index = 1; index <= 5; index++) {
            var container = getBeaconContainer(index);
            if (container) {
                delete beaconsStarted[index];
                container.parentElement.removeChild(container);
            }
        }

        window.$ovv.removeAd(this);
    };

    /**
     * @returns {string} The randomly generated ID of this asset
     */
    this.getId = function() {
        return id;
    };

    // PRIVATE FUNCTIONS

    /**
     * Creates the 5 SWFs and adds them to the DOM
     * @param {string} The URL of the beacon SWFs
     * @see {@link positionSWFs}
     */
    var createSWFs = function(url) {

        if (url === '' || url === ('BEACON' + '_SWF_' + 'URL')) {
            return;
        }

        for (var index = 1; index <= 5; index++) {

            var swfContainer = document.createElement('DIV');
            swfContainer.id = 'OVVBeaconContainer_' + index + '_' + id;

            swfContainer.style.position = 'absolute';
            swfContainer.style.zIndex = 99999;

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
    };

    /**
     * Finds the video player associated with this asset by searching through
     * each EMBED and OBJECT element on the page, testing to see if it has the
     * randomly generated callback signature.
     * @returns {Element|null} The viedo player being measured
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

        if (!this.getPlayer()) {
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

        for (var index = 1; index <= 5; index++) {
            var left, top;

            switch (index) {
                case 1: // TOP LEFT
                    left = playerLocation.left;
                    top = playerLocation.top;
                    break;

                case 2: // TOP RIGHT
                    left = playerLocation.left + playerLocation.width - BEACON_SIZE;
                    top = playerLocation.top;
                    break;

                case 3: // CENTER
                    left = playerLocation.left + ((playerLocation.width - BEACON_SIZE) / 2);
                    top = playerLocation.top + ((playerLocation.height - BEACON_SIZE) / 2);
                    break;

                case 4: // BOTTOM LEFT
                    left = playerLocation.left;
                    top = playerLocation.top + playerLocation.height - BEACON_SIZE;
                    break;

                case 5: // BOTTOM RIGHT
                    left = playerLocation.left + playerLocation.width - BEACON_SIZE;
                    top = playerLocation.top + playerLocation.height - BEACON_SIZE;
                    break;
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

        if (element === null) {
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
    createSWFs.bind(this)('BEACON_SWF_URL');
}

// initialize the OVV object if it doesn't exist
window.$ovv = window.$ovv || new OVV();

// 'OVVID' is string substituted from AS
window.$ovv.addAd(new OVVAsset('OVVID'));