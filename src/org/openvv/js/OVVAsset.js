function OVV(){this.DEBUG=false;this.IN_IFRAME=(window.top!==window.self);this.asset=null;this.positionInterval;var i=window.testOvvConfig&&window.testOvvConfig.userAgent?window.testOvvConfig.userAgent:navigator.userAgent;function g(l){var k=function(){var r={ID:0,name:"",version:""};var q=l;for(var o=0;o<m.length;o++){if(q.match(new RegExp(m[o].brRegex))!=null){r.ID=m[o].id;r.name=m[o].name;if(m[o].verRegex==null){break}var p=q.match(new RegExp(m[o].verRegex+"[0-9]*"));if(p!=null){var n=p[0].match(new RegExp(m[o].verRegex));r.version=p[0].replace(n[0],"")}break}}return r};var m=[{id:4,name:"Opera",brRegex:"OPR|Opera",verRegex:"(OPR/|Version/)"},{id:1,name:"MSIE",brRegex:"MSIE|Trident/7.*rv:11|rv:11.*Trident/7",verRegex:"(MSIE |rv:)"},{id:2,name:"Firefox",brRegex:"Firefox",verRegex:"Firefox/"},{id:3,name:"Chrome",brRegex:"Chrome",verRegex:"Chrome/"},{id:5,name:"Safari",brRegex:"Safari|(OS |OS X )[0-9].*AppleWebKit",verRegex:"Version/"}];return k()}this.browserIDEnum={MSIE:1,Firefox:2,Chrome:3,Opera:4,safari:5};this.inIFrame;this.browser=g(i);this.servingScenarioEnum={OnPage:1,SameDomainIframe:2,CrossDomainIframe:3};function h(k){try{if(window.top==window){return k.OnPage}else{if(window.top.document.domain==window.document.domain){return k.SameDomainIframe}}}catch(l){}return k.CrossDomainIframe}this.servingScenario=h(this.servingScenarioEnum);this.geometrySupported=this.servingScenario!==this.servingScenarioEnum.CrossDomainIframe;this.interval=INTERVAL;this.releaseVersion="OVVRELEASEVERSION";this.buildVersion="OVVBUILDVERSION";var d={};var c=[];var f=1000;var a=[];this.addAsset=function(k){if(!d.hasOwnProperty(k.getId())){d[k.getId()]=k;this.asset=k}};this.removeAsset=function(k){delete d[k.getId()]};this.getAssetById=function(k){return d[k]};this.getAds=function(){var l={};for(var k in d){if(d.hasOwnProperty(k)){l[k]=d[k]}}return l};this.subscribe=function(l,k,m,n){if(n){for(key in c[k]){if(b(c[k][key].eventName,l)){e(function(){m(k,c[k][key])})}}}for(key in l){if(!a[l[key]+k]){a[l[key]+k]=[]}a[l[key]+k].push({Func:m})}};this.publish=function(m,p,n){var l={eventName:m,eventTime:j(),ovvArgs:n};if(!c[p]){c[p]=[]}if(c[p].length<f){c[p].push(l)}if(m&&p&&a[m+p] instanceof Array){for(var o=0;o<a[m+p].length;o++){var k=a[m+p][o];if(k&&k.Func&&typeof k.Func==="function"){e(function(){k.Func(p,l)})}}}};this.getAllReceivedEvents=function(k){return c[k]};var j=function(){if(Date.now){return Date.now()}return(new Date()).getTime()};var b=function(l,m){for(var k=0;k<m.length;k++){if(m[k]===l){return true}}return false};var e=function(l){try{var k=l();return k!==undefined?k:true}catch(m){return false}}}function OVVCheck(){this.clientHeight=-1;this.clientWidth=-1;this.error="";this.focus=null;this.fps=-1;this.id="";this.beaconsSupported=null;this.geometrySupported=null;this.geometryViewabilityState="";this.beaconViewabilityState="";this.cssViewabilityState="";this.technique="";this.beacons=new Array();this.inIframe=null;this.objBottom=-1;this.objLeft=-1;this.objRight=-1;this.objTop=-1;this.percentViewable=-1;this.viewabilityState=""}OVVCheck.UNMEASURABLE="unmeasurable";OVVCheck.VIEWABLE="viewable";OVVCheck.UNVIEWABLE="unviewable";OVVCheck.NOT_READY="not_ready";OVVCheck.BEACON="beacon";OVVCheck.GEOMETRY="geometry";OVVCheck.CSS_VISIBILITY="css_visibility";function OVVAsset(f,w){var v=13;var d=Math.sqrt(2);var Q=0;var D=1;var E=2;var a=3;var o=4;var A=5;var i=6;var K=7;var j=8;var q=9;var e=10;var b=11;var k=12;var F=13;var M=500;var G=f;var C=0;var c=$ovv.DEBUG?20:1;var I;var N;var B=w.geometryViewabilityCalculator;var m=function(){return null};var n=function(){return null};this.checkViewability=function(){var T=new OVVCheck();T.id=G;T.inIframe=$ovv.IN_IFRAME;T.geometrySupported=$ovv.geometrySupported;T.focus=l();if(!N){T.error="Player not found!";return T}if(L(N)){T.technique=OVVCheck.CSS_VISIBILITY;T.viewabilityState=OVVCheck.UNVIEWABLE;if($ovv.DEBUG){T.cssViewabilityState=OVVCheck.UNVIEWABLE}else{return T}}if($ovv.browser.ID===$ovv.browserIDEnum.MSIE&&T.geometrySupported===false){T.viewabilityState=OVVCheck.UNMEASURABLE;if(!$ovv.DEBUG){return T}}if(T.geometrySupported){T.technique=OVVCheck.GEOMETRY;y(T,N);T.viewabilityState=(T.percentViewable>=50)?OVVCheck.VIEWABLE:OVVCheck.UNVIEWABLE;if($ovv.DEBUG){T.geometryViewabilityState=T.viewabilityState}else{return T}}var X=x(0);var V=O(0);if(X&&X.isViewable&&V){var W=P(V)&&X.isViewable();T.beaconsSupported=!W}else{T.beaconsSupported=false}if(!u()){T.technique=OVVCheck.BEACON;T.viewabilityState=OVVCheck.NOT_READY}else{if(T.beaconsSupported){T.technique=OVVCheck.BEACON;var S=H(T);if(S===null){T.viewabilityState=OVVCheck.UNMEASURABLE;if($ovv.DEBUG){T.beaconViewabilityState=OVVCheck.UNMEASURABLE}}else{T.viewabilityState=S?OVVCheck.VIEWABLE:OVVCheck.UNVIEWABLE;if($ovv.DEBUG){T.beaconViewabilityState=S?OVVCheck.VIEWABLE:OVVCheck.UNVIEWABLE}}}else{T.viewabilityState=OVVCheck.UNMEASURABLE}}if($ovv.DEBUG){T.technique="";if(T.geometryViewabilityState===null&&T.beaconViewabilityState===null&&T.cssViewabilityState===null){T.viewabilityState=OVVCheck.UNMEASURABLE}else{var U=(T.beaconViewabilityState===OVVCheck.VIEWABLE);var R=(T.geometryViewabilityState===OVVCheck.VIEWABLE);T.viewabilityState=(U||R)?OVVCheck.VIEWABLE:OVVCheck.UNVIEWABLE}}return T};this.beaconStarted=function(R){if($ovv.DEBUG&&x(R).debug){x(R).debug()}if(R===0){return}C++;if(u()){N.onJsReady()}};this.dispose=function(){for(var S=1;S<=v;S++){var R=O(S);if(R){delete C[S];R.parentElement.removeChild(R)}}clearInterval(window.$ovv.positionInterval);window.$ovv.removeAsset(this)};this.getId=function(){return G};this.getPlayer=function(){return N};var y=function(R,S){var T=B.getViewabilityState(S,window);if(!T.error){R.clientWidth=T.clientWidth;R.clientHeight=T.clientHeight;R.percentViewable=T.percentViewable;R.objTop=T.objTop;R.objBottom=T.objBottom;R.objLeft=T.objLeft;R.objRight=T.objRight}return T};var L=function(S){var T=window.getComputedStyle(S,null);var R=T.getPropertyValue("visibility");var U=T.getPropertyValue("display");return(R=="hidden"||U=="none")};var H=function(R){if(!u()){return null}var Y=0;var V=0;var aa=0;var ac=0;R.beacons=new Array(v);var U=N.getClientRects?N.getClientRects()[0]:{top:-1,bottom:-1,left:-1,right:-1};R.objTop=U.top;R.objBottom=U.bottom;R.objLeft=U.left;R.objRight=U.right;for(var W=0;W<=v;W++){if(W===0){continue}var S=x(W);var ab=O(W);var T=S.isViewable();var Z=P(ab);R.beacons[W]=T&&Z;if(T){Y++;switch(W){case E:case a:case o:case A:V++;break;case i:case K:case j:case q:aa++;break;case e:case b:case k:case F:ac++;break}}}if(Y===v){return true}var X=R.beacons;if((X[D]===true)&&((X[E]===true&&X[a]==true)||(X[E]===true&&X[o]==true)||(X[a]===true&&X[A]==true)||(X[o]===true&&X[A]==true))){return true}if(X[D]===false&&ac>=3){return true}if(X[D]===true&&aa==4){return true}if((X[E]&&X[A])&&(!X[i]||![e]||!X[D]||X[F]||X[q])){return null}if((X[o]&&X[a])&&(!X[j]||!X[k]||!X[D]||!X[b]||!X[K])){return null}return false};var u=function(){if(!N){return false}return C===v};var J=function(S){if(S===""||S===("BEACON_SWF_URL")){return}for(var R=0;R<=v;R++){var U=document.createElement("DIV");U.id="OVVBeaconContainer_"+R+"_"+G;U.style.position="absolute";U.style.zIndex=$ovv.DEBUG?99999:-99999;var T='<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="'+c+'" height="'+c+'"><param name="movie" value="'+S+'" /><param name="quality" value="low" /><param name="flashvars" value="id='+G+"&index="+R+'" /><param name="bgcolor" value="#ffffff" /><param name="wmode" value="transparent" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="false" /><!--[if !IE]>--><object id="OVVBeacon_'+R+"_"+G+'" type="application/x-shockwave-flash" data="'+S+'" width="'+c+'" height="'+c+'"><param name="quality" value="low" /><param name="flashvars" value="id='+G+"&index="+R+'" /><param name="bgcolor" value="#ff0000" /><param name="wmode" value="transparent" /><param name="allowScriptAccess" value="always" /><param name="allowFullScreen" value="false" /><!--<![endif]--></object>';U.innerHTML=T;document.body.insertBefore(U,document.body.firstChild)}s.bind(this)();this.positionInterval=setInterval(s.bind(this),M)};var t=function(){for(var R=0;R<=v;R++){var S=document.createElement("iframe");S.name=S.id="OVVFrame_"+G+"_"+R;S.width=$ovv.DEBUG?20:1;S.height=$ovv.DEBUG?20:1;S.frameBorder=0;S.style.position="absolute";S.style.zIndex=$ovv.DEBUG?99999:-99999;S.src="javascript: window.isInViewArea = undefined; window.wasInViewArea = false; window.isInView = undefined; window.wasViewed = false; window.started = false; window.index = "+R+';window.isViewable = function() { return window.isInView; }; var cnt = 0; setTimeout(function() {var span = document.createElement("span");span.id = "ad1";document.body.insertBefore(span, document.body.firstChild);},300);setTimeout(function() {setInterval(function() { ad1 = document.getElementById("ad1");ad1.innerHTML = window.mozPaintCount > cnt ? "In View" : "Out of View";var paintCount = window.mozPaintCount; window.isInView = (paintCount>cnt); cnt = paintCount; if (parent.$ovv.DEBUG == true) {if(window.isInView === true){document.body.style.background = "green";} else {document.body.style.background = "red";}}if (window.started === false) {parent.$ovv.getAssetById("'+G+'").beaconStarted(window.index);window.started = true;}}, 500)},400);';document.body.insertBefore(S,document.body.firstChild)}s.bind(this)();this.positionInterval=setInterval(s.bind(this),M)};var s=function(){if(!u()){return}var U=N.getClientRects()[0];if(I&&(I.left===U.left&&I.right===U.right&&I.top===U.top&&I.bottom===U.bottom)){return}I=U;var S=U.right-U.left;var aa=U.bottom-U.top;var X=S/(1+d);var R=aa/(1+d);var V=S/d;var Z=aa/d;for(var W=0;W<=v;W++){var T=U.left+document.body.scrollLeft;var Y=U.top+document.body.scrollTop;switch(W){case Q:T=-100000;Y=-100000;break;case D:T+=(S-c)/2;Y+=(aa-c)/2;break;case E:break;case a:T+=S-c;break;case o:Y+=aa-c;break;case A:T+=S-c;Y+=aa-c;break;case i:T+=(S-V)/2;Y+=(aa-Z)/2;break;case K:T+=((S-V)/2)+V;Y+=(aa-Z)/2;break;case j:T+=(S-V)/2;Y+=((aa-Z)/2)+Z;break;case q:T+=((S-V)/2)+V;Y+=((aa-Z)/2)+Z;break;case e:T+=(S-X)/2;Y+=(aa-R)/2;break;case b:T+=((S-X)/2)+X;Y+=(aa-R)/2;break;case k:T+=(S-X)/2;Y+=((aa-R)/2)+R;break;case F:T+=((S-X)/2)+X;Y+=((aa-R)/2)+R;break}if(W>=i){T-=(c/2);Y-=(c/2)}var ab=O(W);ab.style.left=T+"px";ab.style.top=Y+"px"}};var P=function(R){if(!R){return false}var S=Math.max(document.body.clientWidth,window.innerWidth);var U=Math.max(document.body.clientHeight,window.innerHeight);var T=R.getClientRects()[0];return(T.top<U&&T.bottom>0&&T.left<S&&T.right>0)};var x=(function(R){return m(R)}).memoize();var r=function(R){return document.getElementById("OVVBeacon_"+R+"_"+G)};var h=function(S){var T=document.getElementById("OVVFrame_"+G+"_"+S);var R=null;if(T){R=T.contentWindow}return R};var O=(function(R){return n(R)}).memoize();var z=function(R){return document.getElementById("OVVBeaconContainer_"+R+"_"+G)};var p=function(R){return document.getElementById("OVVFrame_"+G+"_"+R)};var g=function(){var S=document.getElementsByTagName("embed");for(var R=0;R<S.length;R++){if(S[R][G]){return S[R]}}var T=document.getElementsByTagName("object");for(var R=0;R<T.length;R++){if(T[R][G]){return T[R]}}return null};var l=function(){var S=document.getElementById("_do_not_expect_focus_")!==null;var R=true;if(typeof document.hidden!=="undefined"){R=window.document.hidden?false:true;if(S){return R}}else{if(document.hasFocus){R=document.hasFocus()}}if($ovv.IN_IFRAME===false&&R===true&&document.hasFocus){R=document.hasFocus()}return R};N=g();if($ovv.geometrySupported==null||$ovv.DEBUG){if($ovv.browser.ID===$ovv.browserIDEnum.Firefox){m=h;n=p;t.bind(this)()}else{m=r;n=z;J.bind(this)("BEACON_SWF_URL")}}else{if(N&&N.onJsReady){setTimeout(function(){N.onJsReady()},5)}}}function OVVGeometryViewabilityCalculator(){this.getViewabilityState=function(i,l){var h=a();if(h.height==Infinity||h.width==Infinity){return{error:"Failed to determine viewport"}}var g=i.getBoundingClientRect();var j=g.width*g.height;if((h.area/j)<0.5){f=100*h.area/j}else{var k=c(i,l);var f=d(k,h)}var g=i.getBoundingClientRect();return{clientWidth:h.width,clientHeight:h.height,objTop:g.top,objBottom:g.bottom,objLeft:g.left,objRight:g.right,percentViewable:f}};var a=function(){var g=e(window.top);if(!$ovv.IN_IFRAME){return g}var f=e(window);if(g.area<f.area){return g}else{return f}};var e=function(g){var f={width:Infinity,height:Infinity,area:Infinity};if(!isNaN(g.document.body.clientWidth)&&g.document.body.clientWidth>0){f.width=g.document.body.clientWidth}if(!isNaN(g.document.body.clientHeight)&&g.document.body.clientHeight>0){f.height=g.document.body.clientHeight}if(!!g.document.documentElement&&!!g.document.documentElement.clientWidth&&!isNaN(g.document.documentElement.clientWidth)){f.width=g.document.documentElement.clientWidth}if(!!g.document.documentElement&&!!g.document.documentElement.clientHeight&&!isNaN(g.document.documentElement.clientHeight)){f.height=g.document.documentElement.clientHeight}if(!!g.innerWidth&&!isNaN(g.innerWidth)){f.width=Math.min(f.width,g.innerWidth)}if(!!g.innerHeight&&!isNaN(g.innerHeight)){f.height=Math.min(f.height,g.innerHeight)}if(!(f.height==Infinity||f.width==Infinity)){f.area=f.height*f.width}return f};var c=function(g,l){var k=l;var j=l.parent;var i={width:0,height:0,left:0,right:0,top:0,bottom:0};if(g){var f=b(g,l);f.width=f.right-f.left;f.height=f.bottom-f.top;i=f;if(k!=j){var h=c(k.frameElement,j);if(h.bottom<i.bottom){if(h.bottom<i.top){i.top=h.bottom}i.bottom=h.bottom}if(h.right<i.right){if(h.right<i.left){i.left=h.right}i.right=h.right}i.width=i.right-i.left;i.height=i.bottom-i.top}}return i};var b=function(h,k){var j=k;var i=k.parent;var g={left:0,right:0,top:0,bottom:0};if(h){var f=h.getBoundingClientRect();if(j!=i){g=b(j.frameElement,i)}else{g={left:f.left+g.left,right:f.right+g.left,top:f.top+g.top,bottom:f.bottom+g.top}}}return g};var d=function(g,f){var j=0,i=0;var h={width:g.right-g.left,height:g.bottom-g.top};if(g.bottom<0||g.right<0||g.top>f.height||g.left>f.width||h.width<=0||h.height<=0){return 0}if(g.top<0){j=h.height+g.top;if(j>f.height){j=f.height}}else{if(g.top+h.height>f.height){j=f.height-g.top}else{j=h.height}}if(g.left<0){i=h.width+g.left;if(i>f.width){i=f.width}}else{if(g.left+h.width>f.width){i=f.width-g.left}else{i=h.width}}return Math.round((((i*j))/(h.width*h.height))*100)}}Function.prototype.memoized=function(a){this._cacheValue=this._cacheValue||{};return this._cacheValue[a]!==undefined?this._cacheValue[a]:this._cacheValue[a]=this.apply(this,arguments)};Function.prototype.memoize=function(){var a=this;return function(){return a.memoized.apply(a,arguments)}};window.$ovv=window.$ovv||new OVV();window.$ovv.addAsset(new OVVAsset("OVVID",{geometryViewabilityCalculator:new OVVGeometryViewabilityCalculator()}));
