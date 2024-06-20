
package debug;

class FPSCounter extends openfl.text.TextField {

	public var currentFPS(default, null):Int;
	public var memoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;
	@:noCompletion private var daTime:Float;

	public function new(?x:Float = 10, ?y:Float = 10, ?color:Int = 0xff000000):Void {
		super();
		this.x = x;
		this.y = y;
		currentFPS = 0;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('_sans', 14, color);
		autoSize = LEFT;
		multiline = true;
		times = [];
		daTime = 0;
	}

	private override function __enterFrame(deltaTime:Float):Void {
		times.push(daTime += deltaTime);
		while (times[0] < daTime - 1000) {times.shift();}
		currentFPS = times.length;
		updateText();
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: $currentFPS\nGCM: ${flixel.util.FlxStringUtil.formatBytes(memoryMegas)}';
		textColor = currentFPS < FlxG.drawFramerate * 0.5 ? 0xffff0000 : 0xffffffff;
	}

	inline public function get_memoryMegas():Float {
		return cast (openfl.system.System.totalMemory, UInt);
	}

}
