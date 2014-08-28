module("OVV", { setup: function () {
}
});

test("Test getBrowserDetailsByUserAgent, MSIE8", function () {
    var userAgent = 'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0';
    var browserObj = { ID: 1, name: "MSIE", version: "8" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, MSIE9", function () {
    var userAgent = 'Mozilla/5.0 (Windows; U; MSIE 9.0; Windows NT 9.0; en-US)';
    var browserObj = { ID: 1, name: "MSIE", version: "9" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, MSIE10", function () {
    var userAgent = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)';
    var browserObj = { ID: 1, name: "MSIE", version: "10" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, MSIE11", function () {
    var userAgent = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';
    var browserObj = { ID: 1, name: "MSIE", version: "11" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, Chrome 35", function () {
    var userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.47 Safari/537.36';
    var browserObj = { ID: 3, name: "Chrome", version: "35" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, Firefox 31", function () {
    var userAgent = 'Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0';
    var browserObj = { ID: 2, name: "Firefox", version: "31" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, Safari 6", function () {
    var userAgent = 'Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25';
    var browserObj = { ID: 5, name: "Safari", version: "6" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

test("Test getBrowserDetailsByUserAgent, Opera 12", function () {
    var userAgent = 'Opera/9.80 (Windows NT 6.0) Presto/2.12.388 Version/12.14';
    var browserObj = { ID: 4, name: "Opera", version: "12" };
    baseGetBrowserDetailsByUserAgentTest(userAgent, browserObj);
});

function baseGetBrowserDetailsByUserAgentTest(userAgent, broswerObj) {
    //Arrange    
    window.testOvvConfig = {};
    window.testOvvConfig.userAgent = userAgent;

    //Act
    var $ovv = new window.OVV();

    //Assert
    deepEqual($ovv.browser, broswerObj, 'wrong broswer object.');
}

module("PubSub", { setup: function () {
}
});

test("Test one subscriber", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue = function () { subscriberFunWasCalled = true; };
    var eventName = 'eventName';
    var events = [eventName];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue);

    //Act
    $ovv.publish(eventName, uid);

    //Assert
    equal(subscriberFunWasCalled, true, 'publishResult is incorrect.');
});

test("Test subscribe to two different events", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled1 = false;
    var subscriberFunWasCalled2 = false;

    var funcTrue1 = function (uid, eventArgs) {
        if (eventArgs.ovvArgs === '1') { subscriberFunWasCalled1 = true; }
        if (eventArgs.ovvArgs === '2') { subscriberFunWasCalled2 = true; }
    };

    var eventName1 = 'eventName1';
    var eventName2 = 'eventName2';
    var events = [eventName1, eventName2];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish(eventName1, uid, '1');
    $ovv.publish(eventName2, uid, '2');

    //Assert
    equal(subscriberFunWasCalled1, true, 'publishResult1 is incorrect.');
    equal(subscriberFunWasCalled2, true, 'publishResult2 is incorrect.');
});

test("Test subscribe twice to the same event", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled1 = false;
    var subscriberFunWasCalled2 = false;

    var funcTrue1 = function (uid, eventArgs) {
        if (eventArgs.ovvArgs === '1') { subscriberFunWasCalled1 = true; }
        if (eventArgs.ovvArgs === '2') { subscriberFunWasCalled2 = true; }
    };

    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid1 = 10;
    var uid2 = 11;
    $ovv.subscribe(events, uid1, funcTrue1);
    $ovv.subscribe(events, uid2, funcTrue1);

    //Act
    var publishResult1 = $ovv.publish(eventName1, uid1, '1');
    var publishResult1 = $ovv.publish(eventName1, uid2, '2');

    //Assert    
    equal(subscriberFunWasCalled1, true, 'publishResult1 is incorrect.');
    equal(subscriberFunWasCalled2, true, 'publishResult2 is incorrect.');
});

test("Test publish not exist event name", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish('notExistEventName', uid);

    //Assert    
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test publish not exist uid", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    var publishResult1 = $ovv.publish(eventName1, 'notExistUID');

    //Assert    
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test publish null as the uid", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish(eventName1, null);

    //Assert    
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test publish null as the event name", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish(null, uid);

    //Assert    
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test publish undefined as the uid", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish(eventName1, undefined);

    //Assert        
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test publish undefined as the event name", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled1 = true; };
    var eventName1 = 'eventName1';
    var events = [eventName1];
    var uid = 10;
    $ovv.subscribe(events, uid, funcTrue1);

    //Act
    $ovv.publish(undefined, uid);

    //Assert    
    equal(subscriberFunWasCalled, false, 'publishResult1 is incorrect.');
});

test("Test previous events", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled = true; };
    var eventName = 'eventName';
    var events = [eventName];
    var uid = 10;
    $ovv.publish(eventName, uid);

    //Act
    $ovv.subscribe(events, uid, funcTrue1, true);

    //Assert        
    equal(subscriberFunWasCalled, true, 'publishResult is incorrect.');
});

test("Test previous events when the subscribe event doesn't have and pervious events", function () {
    //Arrange
    var $ovv = new window.OVV();
    var subscriberFunWasCalled = false;
    var funcTrue1 = function () { subscriberFunWasCalled = true; };
    var otherEventName = 'otherEventName';
    var eventName = 'eventName';
    var events = [eventName];
    var uid = 10;
    $ovv.publish(otherEventName, uid);

    //Act
    $ovv.subscribe(events, uid, funcTrue1, true);

    //Assert        
    equal(subscriberFunWasCalled, false, 'publishResult is incorrect.');
});

test("Test previous events with two buffered event verify the order of the events", function () {
    //Arrange
    var $ovv = new window.OVV();
    var firstEvent = false;
    var subscriberFunWasCalled = false;
    var funcTrue1 = function (uid, eventArgs) {
        if (eventArgs.ovvArgs === "1") {
            firstEvent = true;
            subscriberFunWasCalled = true;
        }

        if (!firstEvent) {
            subscriberFunWasCalled = false;
        }

    };
    var eventName = 'eventName';
    var events = [eventName];
    var uid = 10;
    $ovv.publish(eventName, uid, '1');
    $ovv.publish(eventName, uid, '2');

    //Act
    $ovv.subscribe(events, uid, funcTrue1, true);

    //Assert    
    equal(subscriberFunWasCalled, true, 'publishResult is incorrect.');
});

test("Test previous events with several different buffered event verify the order of the events", function () {
    //Arrange
    var $ovv = new window.OVV();
    var firstEvent = false;
    var lastReceivedArgs = -1;
    var eventReceivedInBadOrder = false;

    var funcTrue1 = function (uid, eventArgs) {
        if (eventArgs.ovvArgs < lastReceivedArgs) {
            eventReceivedInBadOrder = true;
        }
        lastReceivedArgs = eventArgs.ovvArgs;

    };
    var eventName1 = 'OVVLog';
    var eventName2 = 'OVVLog';
    var eventName3 = 'AdStarted';
    var eventName4 = 'OVVLog';

    var events = [eventName1, eventName2, eventName3, eventName4];
    var uid = 10;

    $ovv.publish(eventName1, uid, '1');
    $ovv.publish(eventName2, uid, '2');
    $ovv.publish(eventName3, uid, '3');
    $ovv.publish(eventName4, uid, '4');

    //Act
    $ovv.subscribe(events, uid, funcTrue1, true);

    //Assert    
    equal(eventReceivedInBadOrder, false, 'Event received in bad order.');
});

module("OVVGeometryViewabilityCalculator", {
    setup: function () {
        var element = document.getElementById('testObject1');
        element.style.visibility = 'visible';
    },
    teardown: function () {
        var element = document.getElementById('testObject1');
        //element.style.visibility = 'hidden';
    }
});

var positionEnum = {
    top: "top", Bottom: "Bottom", left: "left", right: "right",
    topAndLeft: "topAndLeft", topAndRight: "topAndRight", BottomAndLeft: "BottomAndLeft", BottomAndRight: "BottomAndRight"
};

asyncTest("The Viewability state were the top of the asset is 10% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(10, positionEnum.top);
});

asyncTest("The Viewability state were the Bottom of the asset is 10% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(10, positionEnum.Bottom);
});

asyncTest("The Viewability state were the left side of the asset is 10% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(10, positionEnum.left);
});

asyncTest("The Viewability state were the right side of the asset is 10% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(10, positionEnum.right);
});

asyncTest("The Viewability state were the top of the asset is 0% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(0, positionEnum.top);
});

asyncTest("The Viewability state were the Bottom of the asset is 0% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(0, positionEnum.Bottom);
});

asyncTest("The Viewability state were the left side of the asset is 0% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(0, positionEnum.left);
});

asyncTest("The Viewability state were the right side of the asset is 0% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(0, positionEnum.right);
});

asyncTest("The Viewability state were the top of the asset is 75% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(75, positionEnum.top);
});

asyncTest("The Viewability state were the Bottom of the asset is 75% visible on X axis", function () {
    genericGeometryViewabilityCalculatorTest(75, positionEnum.Bottom);
});

asyncTest("The Viewability state were the left side of the asset is 75% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(75, positionEnum.left);
});

asyncTest("The Viewability state were the right side of the asset is 75% visible on Y axis", function () {
    genericGeometryViewabilityCalculatorTest(75, positionEnum.right);
});

asyncTest("The Viewability state were the top and right side of the asset is visible for 30%", function () {
    genericGeometryViewabilityCalculatorTest(30, positionEnum.topAndLeft, true);
});

asyncTest("The Viewability state were the top and left side of the asset is visible for 30%", function () {
    genericGeometryViewabilityCalculatorTest(30, positionEnum.topAndRight, true);
});

asyncTest("The Viewability state were the Bottom and left side of the asset is visible for 30%", function () {
    genericGeometryViewabilityCalculatorTest(30, positionEnum.BottomAndLeft, true);
});

asyncTest("The Viewability state were the Bottom and right side of the asset is visible for 30%", function () {
    genericGeometryViewabilityCalculatorTest(30, positionEnum.BottomAndRight, true);
});

function genericGeometryViewabilityCalculatorTest(visiblePercentage, position, isElementInCorner) {
    //Arrange
    setTimeout(function () {
        //Allow enough time to move the test element
        var geometryViewabilityCalculator = new OVVGeometryViewabilityCalculator();
        var element = document.getElementById('testObject1');
        var coordinates = getCoordinatesToShowVisiblePercentForGivenAssetPosition(visiblePercentage, element, position);
        moveElementTo(element, coordinates);

        //Act
        var viewabilityResult = geometryViewabilityCalculator.getViewabilityState(element, window);

        //Assert
        if (isElementInCorner)
            visiblePercentage = visiblePercentage * visiblePercentage / 100;
        //equal(viewabilityResult.percentViewable, visiblePercentage, "Expected asset visible percentage should be " + visiblePercentage + "%");
        var allowDeviation = 0.2;
        var lowerBoundary = visiblePercentage - (visiblePercentage*allowDeviation);
        var upperBoundary = visiblePercentage + (visiblePercentage * allowDeviation);
        ok(viewabilityResult.percentViewable >= lowerBoundary && viewabilityResult.percentViewable <= upperBoundary,
         'Expected asset visible percentage should be: ' + viewabilityResult.percentViewable + '. NOT IN RANGE OF ' + lowerBoundary + " AND " + upperBoundary);
        start();
    }, 500);
}

function getCoordinatesToShowVisiblePercentForGivenAssetPosition(visiblePercent, element, position) {
    var viewPostSize = getViewPortSize();
    var elementRect = element.getBoundingClientRect()
    var elementWidth = elementRect.right - elementRect.left
    var elementHeight = elementRect.bottom - elementRect.top
    var coordinates = { x: 0, y: 0 };
    var scrollBarSize = 18;
    switch (position) {
        case positionEnum.top:
            var scrollAmount = viewPostSize.height - (elementHeight * visiblePercent / 100);
            coordinates.y = scrollAmount;
            break;
        case positionEnum.Bottom:
            var scrollAmount = -(elementHeight - (elementHeight * visiblePercent / 100));
            coordinates.y = scrollAmount;
            break;
        case positionEnum.left:
            var scrollAmount = viewPostSize.width - (elementWidth * visiblePercent / 100);
            coordinates.x = scrollAmount;
            break;
        case positionEnum.right:
            var scrollAmount = viewPostSize.width - (elementWidth * visiblePercent / 100);
            coordinates.x = scrollAmount;
            break;
        case positionEnum.topAndLeft:
            var scrollAmountTop = viewPostSize.height - (elementHeight * visiblePercent / 100) -scrollBarSize;
            var scrollAmountLeft = viewPostSize.width - (elementWidth * visiblePercent / 100) - scrollBarSize;
            coordinates.y = scrollAmountTop;
            coordinates.x = scrollAmountLeft;
            break;
        case positionEnum.topAndRight:
            var scrollAmountTop = viewPostSize.height - (elementHeight * visiblePercent / 100) - scrollBarSize;
            var scrollAmountRight = viewPostSize.width - (elementWidth * visiblePercent / 100);
            coordinates.y = scrollAmountTop;
            coordinates.x = scrollAmountRight;
            break;
        case positionEnum.BottomAndLeft:
            var scrollAmountBottom = -(elementHeight - (elementHeight * visiblePercent / 100));
            var scrollAmountLeft = viewPostSize.width - (elementWidth * visiblePercent / 100) - scrollBarSize;
            coordinates.y = scrollAmountBottom;
            coordinates.x = scrollAmountLeft;
            break;
        case positionEnum.BottomAndRight:
            var scrollAmountBottom = -(elementHeight - (elementHeight * visiblePercent / 100));
            var scrollAmountRight = viewPostSize.width - (elementWidth * visiblePercent / 100);
            coordinates.y = scrollAmountBottom;
            coordinates.x = scrollAmountRight;
            break; 

    }

    return coordinates;
};

function moveElementTo(element, coordinates) {
    element.style.position = 'absolute';
    element.style.top = coordinates.y.toString().indexOf('px') > 1 ? coordinates.y : coordinates.y + 'px';
    element.style.left = coordinates.x.toString().indexOf('px') > 1 ? coordinates.x : coordinates.x + 'px';

}

function getViewPortSize() {
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