var SWF_URL = "http://localhost/OVVBeacon.swf";

function addSWFs(playerId)
{
	var player = findPlayer(playerId);

	if (player === null)
	{
		console.error("Couldn't find player!");
		return;
	}

	var playerLocation = player.getClientRects()[0];
	var wmode = "direct"; //TODO
	var BEACON_SIZE = 2; //TODO

	for(var index = 1; index <= 5; index++)
	{
		var left, top;

		switch(index)
		{
			case 1: // TOP LEFT
				left = playerLocation.left;
				top = playerLocation.top;
				break;

			case 2: // TOP RIGHT
				left = playerLocation.left + playerLocation.width - BEACON_SIZE;
				top = playerLocation.top;
				break;

			case 3: // CENTER
				left = playerLocation.left + ((playerLocation.width - BEACON_SIZE) / 2);
				top = playerLocation.top + ((playerLocation.height - BEACON_SIZE) / 2);
				break;

			case 4: // BOTTOM LEFT
				left = playerLocation.left;
				top = playerLocation.top + playerLocation.height - BEACON_SIZE;
				break;

			case 5: // BOTTOM RIGHT
				left = playerLocation.left + playerLocation.width - BEACON_SIZE;
				top = playerLocation.top + playerLocation.height - BEACON_SIZE;
				break;
		}

		var swfContainer = document.createElement("DIV");
			swfContainer.id = "OVVBeaconContainer" + index;
			swfContainer.style.position = "absolute";
			swfContainer.style.zIndex = 99999;
			swfContainer.style.left = left + "px";
			swfContainer.style.top = top + "px";

		var html =
			'<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
				'<param name="movie" value="http://localhost/OVVBeacon.swf" />' +
				'<param name="quality" value="low" />' +
				'<param name="bgcolor" value="#ffffff" />' +
				'<param name="allowScriptAccess" value="always" />' +
				'<param name="allowFullScreen" value="false" />' +
					'<!--[if !IE]>-->' +
					'<object id="OVVBeacon' + index + '" type="application/x-shockwave-flash" data="http://localhost/OVVBeacon.swf" width="' + BEACON_SIZE + '" height="' + BEACON_SIZE + '">' +
						'<param name="quality" value="low" />' +
						'<param name="bgcolor" value="#ff0000" />' +
						'<param name="allowScriptAccess" value="always" />' +
						'<param name="allowFullScreen" value="false" />' +
					'<!--<![endif]-->' +
			'</object>';

		swfContainer.innerHTML = html;
		document.body.insertBefore(swfContainer, document.body.firstChild);
	}
}

function isPlayerVisible()
{
	var visible = 0;

	for(var index = 1; index <= 5; index++)
	{
		// console.error('OVVBeacon' + index '.isVisible(): ' + document.getElementById('OVVBeacon' + index).isVisible());

		if(document.getElementById('OVVBeacon' + index).isVisible())
		{
			visible += 1;
		}
	}

	return visible >= 3;
}

function findPlayer(id)
{
	console.debug("findPlayer('" + id + "')");

	//When IE is detected, some pages only use an embed:
	var embeds = document.getElementsByTagName("embed");

	for (var i = 0; i < embeds.length; i++)
	{
		if (!!embeds[i][id])
		{
			return embeds[i];
		}
	}

	var objs = document.getElementsByTagName("object");

	for (var i = 0; i < objs.length; i++)
	{
		if (!!objs[i][id])
		{
			return objs[i];
		}
	}

	return null;
}
