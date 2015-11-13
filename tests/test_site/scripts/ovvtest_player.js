"use strict";

/*-------------------------------------------------------------------------------
# * Copyright (c) 2015, Interactive Advertising Bureau
# * All rights reserved.
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------*/

/* =====================================
* Define the object that will initialize movie players
*
======================================= */
(function(win){
	var ovvtest = win.ovvtest || {};

	
	function initFlowPlayer(elemId, options){
		var opts = options || {}
		
        // http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4
		// http://video.doubleverify.com/Big-Buck-Bunny-animation-1080p-HD.mp4
		
		var contentVidUrl = opts.contentUrl 
			|| 'http://download.blender.org/peach/bigbuckbunny_movies/BigBuckBunny_320x180.mp4'		
		
		//Configuration="Api=0|Blocked=0|Unknown=1|BlockingServiceTimeout=5000|AllowIfTimeout=true|MovieLength=10|MovieURL=http://video.doubleverify.com/Big-Buck-Bunny-animation-1080p-HD.mp4|LoadOVV=false"
window.Configuration="Api=0|Blocked=0|Unknown=1|BlockingServiceTimeout=5000|AllowIfTimeout=true|MovieLength=10|MovieURL="
+ contentVidUrl
+ '|LoadOVV=false|Tag=ctx=1462413&cmp=2400648&sid=ernstandyoung&plc=1234567&num=&tagformat=2&advid=1313986&adsrv=20'
+ "&region=30&btreg=&btadsrv=&crt=&crtname=&chnl=&unit=&pid=&uid=&tagtype=video&dvtagver=6.1.src|VpaidUrl=''"

        var autoPlay = getParameterByName('autoPlay');
        if (autoPlay != "") {
            autoPlay = autoPlay.toLowerCase().indexOf( 'f' ) == -1?true:false;
        } else {
            autoPlay = true;
        }
        //var vast = $.url().param('vast');
        //if (!vast)
        var	vast =  "vast-example.xml";
        console.log('vast url: ' + vast);
        //var autoPlay = document.getElementById( 'setAutoPlay' ).value;
        flowplayer( 'player', "flowplayer/flowplayer-3.2.18.swf", {
            "clip":  {
                "autoPlay": autoPlay,
                "autoBuffering": true
            },
            "plugins": {
                "controls": {
                    "autoHide": "never"
                },
                "ova": {
                    "url": "flowplayer/ova.flowplayer/ova.swf",
                    "autoPlay": autoPlay,
                    "ads": {
                        "playOnce": false,
                        "servers": [
                            {
                                "type": "direct",
                                "tag": vast
                            }
                        ],
                        "schedule": [
                            {
                                "position": "pre-roll"
                            }
                        ]
                    }
                }
            }
        });
    }
	
	
	var initFunc = initFlowPlayer;



	var impl = {
		
		setPlayer: function(player){
			if(player == 'flowplayer'){
				initFunc = initFlowPlayer;
			}
			
		},
		
		setInitMethod: function(func){
			initFunc = func;
		},
		
		initPlayer: function(elemId, options){
			initFunc(elemId, options);
		}
		
	}

	ovvtest.player = impl;
	win['ovvtest'] = ovvtest;

})(window);
