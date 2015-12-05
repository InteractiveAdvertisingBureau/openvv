package net.iab.vpaid.core
{
	import flash.text.Font;
	
	/**
	 * Collection of fonts used for embedding.
	 * @author Andrei Andreev
	 */
	public class Fonts
	{
		
		[Embed(source = "../../../fonts/ARIALBD.TTF", fontWeight = "bold", fontName = "ArialBold", fontFamily = "ArialFont", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false", unicodeRange = 'U+0021-U+007B')]
		public var FontArialBold:Class;
		
		[Embed(source = "../../../fonts/ARIAL.TTF", fontWeight = "normal", fontName = "ArialNormal", fontFamily = "ArialFont", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false", unicodeRange = 'U+0021-U+007B')]
		public var FontArial:Class;
		
		[Embed(source = "../../../fonts/OCRAEXT.TTF", fontName = "OCR", mimeType = "application/x-font", advancedAntiAliasing = "true", embedAsCFF = "false", unicodeRange = 'U+0021-U+007B')]
		public var FontOCR:Class;
	
	}

}