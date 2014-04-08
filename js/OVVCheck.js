function a(obfuFn) {
    var results = {};

    //Find Object by looking for obfuFn (Obfuscated Function set by Flash)
    var myObj = null;
    //When IE is detected, some pages only use an embed:
    var embeds = document.getElementsByTagName("embed");
    for (var i = 0; i < embeds.length; i++) {
        if ( !! embeds[i][obfuFn]) {
            myObj = embeds[i];
        }
    }
    if (myObj == null) {
        var objs = document.getElementsByTagName("object");
        for (var i = 0; i < objs.length; i++) {
            if ( !! objs[i][obfuFn]) {
                myObj = objs[i];
            }
        }
    }
    if (myObj == null) {
        //report object not found
        results = {
            "error": "Object not found"
        };
    } else {
        //Capture the player id for reporting (not necessary to check viewability):
        results['id'] = myObj.id;
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
            var rects = myObj.getClientRects();
            objRect = rects[0];
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
    }
    return results;
}