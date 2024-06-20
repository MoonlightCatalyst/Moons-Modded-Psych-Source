
package backend;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

class CoolUtil {

	inline public static function quantize(f:Float, snap:Float):Float {
		return Math.fround(f * snap) / snap;
	}

	inline public static function capitalize(text:String):String {
		return text.charAt(0).toUpperCase() + text.substr(1).toLowerCase();
	}

	inline public static function coolTextFile(path:String):Array<String> {
		var daList:String = null;
		#if (sys && MODS_ALLOWED)
		final formatted:Array<String> = path.split(':'); //prevent "shared:", "preload:" and other library names on file path
		path = formatted[formatted.length - 1];
		if (FileSystem.exists(path)) {
			daList = File.getContent(path);
		}
		#else
		if (Assets.exists(path)) {
			daList = Assets.getText(path);
		}
		#end
		return daList != null ? listFromString(daList) : [];
	}

	inline public static function colorFromString(color:String):FlxColor {
		color = ~/[\t\n\r]/.split(color).join('').trim();
		if (color.startsWith('0x')) {
			color = color.substring(color.length - 6);
		}
		return (FlxColor.fromString(color) ?? FlxColor.fromString('#$color')) ?? FlxColor.WHITE;
	}

	inline public static function listFromString(string:String):Array<String> {
		return string.trim().split('\n').map((i:String) -> {i.trim();});
	}

	inline public static function floorDecimal(value:Float, decimals:Int):Float {
		final tempMult:Float = Math.pow(10, decimals);
		return decimals < 1 ? Math.floor(value) : Math.floor(value * tempMult) / tempMult;
	}

	inline public static function dominantColor(sprite:flixel.FlxSprite):Int {
		var countByColor:Map<Int,Int> = [];
		for (col in 0...sprite.frameWidth) {
			for (row in 0...sprite.frameHeight) {
				var pixClr:Int = sprite.pixels.getPixel32(col, row);
				if (pixClr != 0) {
					if (countByColor.exists(pixClr)) {
						countByColor[pixClr]++;
					} else if (countByColor[pixClr] != -13520687) {
						countByColor[pixClr] = 1;
					}
				}
			}
		}
		var maxCount:Int = 0;
		var maxKey:Int = 0;
		countByColor[FlxColor.BLACK] = 0;
		for (key in countByColor.keys()) {
			if (countByColor[key] >= maxCount) {
				maxCount = countByColor[maxKey = key];
			}
		}
		countByColor = [];
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min:Int = 0):Array<Int> {
		return [for (i in min...max) {i;}];
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	inline public static function browserLoad(site:String):Void {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function openFolder(folder:String, ?absolute:Bool = false):Void {
		#if sys
		if (!absolute) {
			folder = Sys.getCwd() + folder;
		}
		folder = folder.replace('/', '\\');
		if (folder.endsWith('/')) {
			folder.substr(0, folder.length - 1);
		}
		final command:String = #if linux '/usr/bin/xdg-open' #else 'explorer.exe' #end;
		Sys.command(command, [folder]);
		trace('$command $folder');
		#else
		FlxG.error('Platform is not supported for CoolUtil.openFolder');
		#end
	}

	@:access(flixel.util.FlxSave.validate)
	inline public static function getSavePath():String {
		final meta:Dynamic = FlxG.stage.application.meta;
		return '${meta.get('company')}/${flixel.util.FlxSave.validate(meta.get('file'))}';
	}

	public static function setTextBorderFromString(text:FlxText, border:String):Void {
		switch (border.toLowerCase().trim()) {
			case 'shadow':
				text.borderStyle = SHADOW;
			case 'outline':
				text.borderStyle = OUTLINE;
			case 'outline_fast', 'outlinefast':
				text.borderStyle = OUTLINE_FAST;
			default:
				text.borderStyle = NONE;
		}
	}

}