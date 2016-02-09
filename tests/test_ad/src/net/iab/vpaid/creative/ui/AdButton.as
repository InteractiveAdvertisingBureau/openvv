package net.iab.vpaid.creative.ui
{
	import flash.display.SimpleButton;
	import net.iab.vpaid.core.Style;
	import net.iab.vpaid.core.Styles;
	
	/**
	 * Styleable button use by the ad.
	 * @author Andrei Andreev
	 */
	public class AdButton extends SimpleButton
	{
		private var label:String = "label";
		private var _width:Number = 100;
		
		/**
		 *
		 * @param	label button label
		 * @param	width desirable button width
		 */
		public function AdButton(label:String, width:Number = 100)
		{
			init(label, width);
		}
		
		private function init(label:String, width:Number = 100):void
		{
			this.label = label;
			_width = width;
			var styles:Styles = new Styles();
			var style:Style = styles.buttonUp;
			style.width = _width;
			upState = new AdButtonState(label, style);
			style = styles.buttonOver;
			style.width = _width;
			overState = hitTestState = downState = new AdButtonState(label, style);
		
		}
		/**
		 * Setter changes button label for all button states.
		 */
		public function set labelText(value:String):void
		{
			label = value;
			AdButtonState(upState).labelText = label;
			AdButtonState(overState).labelText = label;
			AdButtonState(hitTestState).labelText = label;
			AdButtonState(downState).labelText = label;
		}

		public function get labelText():String
		{
			return label;
		}
	
	}

}
import flash.display.GradientType;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import net.iab.vpaid.core.Style;

class AdButtonState extends Sprite
{
	
	private var label:String = "label";
	private var style:Style = new Style();
	private var textField:TextField;
	
	public function AdButtonState(label:String, style:Style)
	{
		this.label = label;
		this.style = style;
		draw();
	}
	
	public function set labelText(value:String):void
	{
		label = value;
		textField.text = label;
		textField.x = (style.width - textField.width) * .5;
		textField.y = (style.height - textField.height) * .5;
	}
	
	private function draw():void
	{
		drawBackground();
		drawText();
	}
	
	private function drawText():void
	{
		var textFormat:TextFormat = new TextFormat(style.fontName, style.fontSize, style.textColor);
		textFormat.letterSpacing = .75;
		textField = new TextField();
		textField.defaultTextFormat = textFormat;
		textField.antiAliasType = AntiAliasType.ADVANCED;
		textField.gridFitType = GridFitType.SUBPIXEL;
		textField.sharpness = 0;
		textField.thickness = -100;
		textField.embedFonts = true;
		textField.multiline = false;
		textField.autoSize = TextFieldAutoSize.LEFT;
		labelText = label;
		addChild(textField);
	}
	
	private function drawBackground():void
	{
		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(style.height, style.height, Math.PI / 2);
		graphics.lineStyle(style.lineThickness, 0, style.lineAlpha, true);
		graphics.lineGradientStyle(GradientType.LINEAR, [style.gradientColors[1], style.gradientColors[0]], style.gradientAlphas, style.gradientRatios, matrix);
		graphics.beginGradientFill(GradientType.LINEAR, style.gradientColors, style.gradientAlphas, style.gradientRatios, matrix);
		
		graphics.drawRoundRect(0, 0, style.width, style.height, style.cornerRadius);
	}
}