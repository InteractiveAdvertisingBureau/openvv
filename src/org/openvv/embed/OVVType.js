function ovvType() {
	
	var subscribers = [];

	this.subscribe = function (eventName, uid, func, actionName) {
		if (!subscribers[eventName + uid])
			subscribers[eventName + uid] = [];
		subscribers[eventName + uid].push({ Func: func, ActionName: actionName  });
	};

	this.publish = function(eventName, uid, args) {
		var actionsResults = [];
		if (eventName && uid && subscribers[eventName + uid] instanceof Array) {
			for (var i = 0; i < subscribers[eventName + uid].length; i++) {
				var funcObject = subscribers[eventName + uid][i];
				if (funcObject && funcObject.Func && typeof funcObject.Func == "function") {
					var isSucceeded = runSafely(function() {
						return funcObject.Func(eventName, uid, args);
					});
					actionsResults.push(encodeURIComponent(funcObject.ActionName) + '=' + (isSucceeded ? '1' : '0'));
				}
			}
		}
		return actionsResults.join('&');
	};
	
	var runSafely = function (action) {
		try {
			var ret = action();
			return ret !== undefined ? ret : true;
		} catch (e) { return false; }
	};

}
	
try {
	window.$ovv = (window.$ovv || new ovvType());												
} catch (e) { console.log(e.message); }