package net.iab
{
	/**
	 * Interface for all of the properties and methods that a VPAID SWF can implement.  This interface
	 * does not need to be used for any VPAID SWFs, but it can help make coding easier.  This source can 
	 * be found in the VPAID specification: http://www.iab.net/media/file/VPAIDFINAL51109.pdf
	 */
	public interface IVPAID
	{
		// Properties
		function get adLinear():Boolean;
		function get adExpanded():Boolean;
		function get adRemainingTime():Number;
		function get adVolume():Number;
		function set adVolume(value:Number):void;
		// Methods
		function handshakeVersion(playerVPAIDVersion:String):String;
		function initAd(width:Number, height:Number, viewMode:String, desiredBitrate:Number, 
						creativeData:String, environmentVars:String):void;
		function resizeAd(width:Number, height:Number, viewMode:String):void;
		function startAd():void;
		function stopAd():void;
		function pauseAd():void;
		function resumeAd():void;
		function expandAd():void;
		function collapseAd():void;
	}
}