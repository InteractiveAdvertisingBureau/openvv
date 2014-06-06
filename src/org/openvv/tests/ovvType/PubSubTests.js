module("PubSub");

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
    $ovv.publish(eventName1, uid , '1');
	$ovv.publish(eventName2, uid , '2');
    
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	    
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
	var funcTrue1 = function () { subscriberFunWasCalled1 =  true;  };	    
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
	var funcTrue1 = function () { subscriberFunWasCalled =  true;  };	        
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
            subscriberFunWasCalled =  true;
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