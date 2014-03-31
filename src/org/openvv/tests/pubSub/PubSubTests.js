module("PubSub");

module("PubSub", { setup: function () {    
}
});

test("Test one subscriber", function () {   
	//Arrange
    var $ovv = new window.ovvType();
    var funcTrue = function () { return true; };
    var eventName = 'eventName';
    var uid = 10;
    $ovv.subscribe(eventName, uid, funcTrue, 'funcTrue');
    
    //Act
    var publishResult = $ovv.publish(eventName, uid);
   
    //Assert
    var publishExpectedResult = '{0}=1'.format(encodeURIComponent('funcTrue'));
    equal(publishResult, publishExpectedResult, 'publishResult is incorrect.');
});

test("Test subscribe to two diffrent events", function () {
    //Arrange
    var $ovv = new window.ovvType();
    var funcTrue1 = function () { return true; };    
    var funcTrue2 = function () { return true; };        

    var eventName1 = 'eventName1';
    var eventName2 = 'eventName2';
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcTrue1, 'funcTrue1');
    $ovv.subscribe(eventName2, uid, funcTrue2, 'funcTrue2');	

    //Act
    var publishResult1 = $ovv.publish(eventName1, uid);
	var publishResult2 = $ovv.publish(eventName2, uid);
    
    //Assert
    var publishExpectedResult1 = '{0}=1'.format(encodeURIComponent('funcTrue1'));
    equal(publishResult1, publishExpectedResult1, 'publishResult1 is incorrect.');
	
	var publishExpectedResult2 = '{0}=1'.format(encodeURIComponent('funcTrue2'));
    equal(publishResult2, publishExpectedResult2, 'publishResult2 is incorrect.');
});

test("Test subscribe twice to the same event", function () {
    //Arrange
    var $ovv = new window.ovvType();
    var funcTrue1 = function () { return true; };    
    var funcTrue2 = function () { return true; };        
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcTrue1, 'funcTrue1');
    $ovv.subscribe(eventName1, uid, funcTrue2, 'funcTrue2');	

    //Act
    var publishResult1 = $ovv.publish(eventName1, uid);	
    
    //Assert
    var publishExpectedResult1 = '{0}=1&{1}=1'.format(encodeURIComponent('funcTrue1'), encodeURIComponent('funcTrue2'));
    equal(publishResult1, publishExpectedResult1, 'publishResult1 is incorrect.');
});


test("Test subscribe function failed", function () {
    //Arrange
    var $ovv = new window.ovvType();
    var funcFalse = function () { return false; };    
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcFalse, 'funcFalse');
    
    //Act
    var publishResult1 = $ovv.publish(eventName1, uid);	
    
    //Assert
    var publishExpectedResult1 = '{0}=0'.format(encodeURIComponent('funcFalse'));
    equal(publishResult1, publishExpectedResult1, 'publishResult1 is incorrect.');
});

test("Test subscribe function throw an exception", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(eventName1, uid);	
    
    //Assert
    var publishExpectedResult1 = '{0}=0'.format(encodeURIComponent('funcException'));
    equal(publishResult1, publishExpectedResult1, 'publishResult1 is incorrect.');
});

test("Test publish not exist event name", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
	
    //Act
    var publishResult1 = $ovv.publish('notExistEventName', uid);	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});

test("Test publish not exist uid", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(eventName1, 'notExistUID');	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});

test("Test publish null as the uid", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(eventName1, null);	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});

test("Test publish null as the event name", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(null, uid);	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});


test("Test publish undefined as the uid", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(eventName1, undefined);	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});

test("Test publish undefined as the event name", function () {
    //Arrange
    var $ovv = new window.ovvType();    
	var funcException = function () { throw 'Exception'; };	
    var eventName1 = 'eventName1';    
    var uid = 10;
    $ovv.subscribe(eventName1, uid, funcException, 'funcException');
    
    //Act
    var publishResult1 = $ovv.publish(undefined, uid);	
    
    //Assert    
    equal(publishResult1, '', 'publishResult1 is incorrect.');
});