openvv
======

There doesn't seem to be much documentation on the net about how to use this cool AS3 library, so I forked it and added this demo to make it easier to use.

The code in Main.as provides a demo of the core OpenVV functionality using the class OVVCheck.  If you're using a browser with a console like Chrome, you can enable logging in Main.as (line 19) and open your console to see what viewability information OpenVV is able to detect.

- To build the demo run ```mxmlc src/Main.as -o bin/Openvv.swf```

- Open bin/index.html in a browser and scroll around, minimize, restore, etc.  

- There are two separate instances of Flash embedded in this page.  If you watch the console you can inspect the messages being passed from each SWF to note how they change as you manipulate the browser window.

It looks like openVV is correctly detecting:

- clientHeight
- clientWidth
- focus
- objBottom, objLeft, objRight, and objTop
- percentViewable
