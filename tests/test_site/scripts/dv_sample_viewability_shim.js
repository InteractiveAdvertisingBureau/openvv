/*
* Shim file that exposes an expected set of public events which the "DVVpaidWrapper.swf" sample ad expects.
* This file, in conjuction with a Shim event listener will appropriately andle events raised  by the referenced swf.
*
*/

var $gl = function(id){
	if(id.substr(0,1) == '#'){
		id = id.substr(1);
	}
	return document.getElementById(id);
}


function displayEvent(eventName, eventPercent, active ) {
	//alert("setStats()");
	
	var viewableID = "viewable";
	var viewableText = "";
	
	eventPercent = Number(eventPercent);
	
	if ( eventPercent >= 50 && active ) {
		viewableText = "VIEWABLE";
	} else if ( eventPercent < 50 || !active ) {
		viewableText = "NOT VIEWABLE";
		viewableID = "notviewable";
	}
	var chipHDVL = "";
	chipHDVL += "<table border='0' cellpadding='0' cellspacing='0' class='chip_bubble "+viewableID+"_color'>";
    chipHDVL += "  <tr>";
    chipHDVL += "    <td width='34'><img src='includes/images/"+viewableID+".png' width='34' height='30' class='chip_bubble_image'></td>";
    chipHDVL += "    <td width='' class='chip_bubble_title'>"+eventName+"</td>";
    if (eventPercent >= 0 && eventPercent <= 100 ) {
			chipHDVL += "    <td width='50' class='chip_bubble_percent'>"+eventPercent+"%</td>";
	    if ( active != 'false' ) {
			chipHDVL += "    <td width='80'><div class='chip_bubble_result "+viewableID+"_text'>"+viewableText+"</div></td>";
		} else {
			chipHDVL += "    <td width='80'><div class='chip_bubble_result "+viewableID+"_text'>NOT VIEWABLE: INACTIVE</div></td>";
		}
	}
    chipHDVL += "  </tr>";
    chipHDVL += "</table>";
	// IE fix - hide/show to force redraw for dynamic shadow
	$("#chip").hide();
	$("#chip_events").append(chipHDVL);
	$("#chip").show();
}

function getParameterByName(name) {
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.search);
  if(results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}

function DVAdLoad() {
	displayEvent("Ad Load");
}

function DVViewableDetectTest() {
	DVViewableDetect(ovvData);
}

function DVSomethingTest() {
	//displayEvent("Ad Something", $('#viewPercent').val());
}

function DVViewableDetect(event, data) {
    
    var ovvData = data.ovvData;
	if ( ovvData.error == "Ad in iFrame" || getParameterByName( 'iframe') == 'true' /* Cheating a bit for the demo */ ) {
		$('#chip_iFrame').text(true);
		displayEvent("iFrame Present", 0);
	} else {
		$('#chip_adHeight').text(ovvData.objBottom - ovvData.objTop);
		$('#chip_adWidth').text(ovvData.objRight - ovvData.objLeft);
		$('#chip_viewportHeight').text(ovvData.clientHeight);
		$('#chip_viewportWidth').text(ovvData.clientWidth);
		$('#chip_objTop').text(ovvData.objTop);
		$('#chip_objLeft').text(ovvData.objLeft);
		$('#chip_objRight').text(ovvData.objRight);
		$('#chip_objBottom').text(ovvData.objBottom);
		$('#chip_windowActive').text(ovvData.focus);
		$('#chip_view').text(ovvData.percentViewable);
		
		//$('#chip_isMuted').text(ovvData.mute);
		$('#chip_iFrame').text(false);
		var eventName;
		switch( event ) {
			case 'AdStarted':
				eventName = 'Ad Start';
				break;
			case 'OVVLog':
				eventName = 'AdLog';
				break;
			case 'AdLoaded':
				eventName = 'Ad Loaded'
				break;
			case 'OVVImpression':
				eventName = '1 Second'
				break;
			case 'AdVideoFirstQuartile':
				eventName = 'First Quartile';
				break;
			case 'AdVideoMidpoint':
				eventName = 'Midpoint';
				break;
			case 'AdVideoThirdQuartile':
				eventName = 'Third Quartile';
				break;
			case 'AdVideoComplete':
				eventName = 'Completion';
				break;
			case  'AdVolumeChange':
				eventName = 'AdVolumeChange';
				break;
			case  'AdImpression':
				eventName = 'AdImpression';
				break;
			case  'AdStopped':
				eventName = 'AdStopped';
				break;
		}
		if ( eventName == 'AdLog' || eventName == 'AdVolumeChange' || eventName == 'AdImpression' || eventName == 'AdStopped' ){
			return;
		}
		
		displayEvent( eventName, ovvData.percentViewable, ovvData.focus );
	}
}
function DVAdReload() {
	var newUrl = window.location.toString().indexOf( '?') > 0?
		window.location.toString().substring( 0, window.location.toString().indexOf( '?') + 1 ):
		window.location.toString() + '?';
	newUrl += 'autoPlay=' + $( '#setAutoPlay' ).is(':checked');
	newUrl += '&top=' + $( '#setTop' ).val();
	newUrl += '&left=' + $( '#setLeft' ).val();
	newUrl += '&width=' + $( '#setWidth' ).val(); 
	newUrl += '&height=' + $( '#setHeight' ).val();

	window.location = newUrl;
}
/*
var ovvData = {
        "objBounds": {
          "objTop": "107",
          "objLeft": "289.5",
          "objRight": "819.5",
          "objBottom": "467"
        },
        "viewable": {
          "AS": "100",
          "JS": "100"
        },
        "windowActive": "true",
        "site": "http%3A%2F%2Fwww.tubemogul.com%2Fconfigurator%2Fad_preview%2FZDbXdrI16JYdqFoJA9q5%3Ffullsize%3D1",
        "height": {
          "adHeight": "360",
          "objHeight": "360"
        },
        "width": {
          "adWidth": "530",
          "objWidth": "530"
        },
        "version": "3",
        "siteId": "334212345",
        "action": "Complete",
        "userAgent": "Mozilla%2F5.0%20(Macintosh%3B%20Intel%20Mac%20OS%20X%2010.7%3B%20rv%3A18.0)%20Gecko%2F20100101%20Firefox%2F18.0 ",
        "id": "DV_player_vast_api",
        "viewport": {
          "viewportHeight": "474",
          "viewportWidth": "1419"
        }
      };
      */