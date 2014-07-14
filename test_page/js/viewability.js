$(document).ready(function() {
   
    $('#chip_iFrame').text(window !== window.parent);
    $('#chip_windowActive').text(!document.hidden);

    var playerTop = Number(!getParameterByName('top') ? 125 : getParameterByName('top'));
    var playerLeft = Number(!getParameterByName('left') ? 20 : getParameterByName('left'));
    var playerHeight = Number(!getParameterByName('height') ? 400 : getParameterByName('height'));
    var playerWidth = Number(!getParameterByName('width') ? 600 : getParameterByName('width'));
    var autoPlay = (!getParameterByName('autoPlay') || getParameterByName('autoPlay').toLowerCase().indexOf('f') == -1) ? true : false;

    $('#setTop').val(playerTop);
    $('#setLeft').val(playerLeft);
    $('#setHeight').val(playerHeight);
    $('#setWidth').val(playerWidth);
    
    if (autoPlay) {
        $('#setAutoPlay').attr('checked', 'checked');
    } else {
        $('#setAutoPlay').removeAttr('checked');
    }

    $('#wrapper').css('top', playerTop);
    $('#wrapper').css('left', playerLeft);
    $('#wrapper').css('height', playerHeight);
    $('#wrapper').css('width', playerWidth);

    var flashvars = {};
    flashvars.file = "content.flv";
    flashvars.autostart = $('#setAutoPlay').attr('checked');
    flashvars.volume = 100;
    flashvars.plugins = "swf/ova.swf";
    flashvars.config = "xml/ova_config.xml";

    var params = {};
    params.allowScriptAccess = "always";
    params.bgcolor = "#000000";

    var attributes = {};
    attributes.id = attributes.name = "jwp";

    swfobject.embedSWF("swf/jwplayer.swf", "player", playerWidth, playerHeight, "9", "", flashvars, params, attributes);
});

function displayEvent(eventName, eventPercent, active, viewabilityState) {
    //alert('detectData');
    //alert("setStats()");
    var viewableID = "viewable";
    var viewableText = "";

    eventPercent = Number(eventPercent);

    switch (viewabilityState) {
        case "viewable":
            viewableText = "VIEWABLE";
            break;

        case "unviewable":
            viewableText = "NOT VIEWABLE";
            viewableID = "notviewable";
            break;

        default:
            viewableText = "UNMEASURABLE";
            viewableID = "unmeasurable";
            break;
    }

    var chipHTML = "";
    chipHTML += "<table border='0' cellpadding='0' cellspacing='0' class='chip_bubble " + viewableID + "_color'>";
    chipHTML += "  <tr>";
    chipHTML += "    <td width='34'><img src='images/" + viewableID + ".png' width='34' height='30' class='chip_bubble_image'></td>";
    chipHTML += "    <td width='' class='chip_bubble_title'>" + eventName + "</td>";
    chipHTML += "    <td width='50' class='chip_bubble_percent'>" + eventPercent + "%</td>";
    if (active != 'false') {
        chipHTML += "    <td width='80'><div class='chip_bubble_result " + viewableID + "_text'>" + viewableText + "</div></td>";
    } else {
        chipHTML += "    <td width='80'><div class='chip_bubble_result " + viewableID + "_text'>NOT VIEWABLE: INACTIVE</div></td>";
    }
    chipHTML += "  </tr>";
    chipHTML += "</table>";
    // IE fix - hide/show to force redraw for dynamic shadow
    $("#chip").hide();
    $("#chip_events").append(chipHTML);
    $("#chip").show();

    var playerPosition = document.getElementById('wrapper').getClientRects()[0];

    $('#chip_adHeight').text(playerPosition.height);
    $('#chip_adWidth').text(playerPosition.width);
    $('#chip_viewportHeight').text(document.body.clientHeight);
    $('#chip_viewportWidth').text(document.body.clientWidth);
    $('#chip_objTop').text(playerPosition.top);
    $('#chip_objLeft').text(playerPosition.left);
    $('#chip_objRight').text(playerPosition.right);
    $('#chip_objBottom').text(playerPosition.bottom);
    $('#chip_windowActive').text(active ? "true" : "false");
    // $('#chip_isMuted').text(detectData.mute);
    $('#chip_iFrame').text(window !== window.parent);
}

function getParameterByName(name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regexS = "[\\?&]" + name + "=([^&#]*)";
    var regex = new RegExp(regexS);
    var results = regex.exec(window.location.search);
    if (results == null)
        return "";
    else
        return decodeURIComponent(results[1].replace(/\+/g, " "));
}

function TmAdReload() {
    var newUrl = window.location.toString().indexOf('?') > 0 ?
        window.location.toString().substring(0, window.location.toString().indexOf('?') + 1) :
        window.location.toString() + '?';
    newUrl += 'autoPlay=' + $('#setAutoPlay').is(':checked');
    newUrl += '&top=' + $('#setTop').val();
    newUrl += '&left=' + $('#setLeft').val();
    newUrl += '&width=' + $('#setWidth').val();
    newUrl += '&height=' + $('#setHeight').val();

    window.location = newUrl;
}