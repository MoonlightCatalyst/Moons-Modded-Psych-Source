package debug;

import debug.memory.Memory;

class FPSCounter extends openfl.text.TextField
{
	public var currentFPS(default, null):Int = 0;
	public var memoryMegas(get, never):Float;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();
		this.x = x;
		this.y = y;
		selectable = mouseEnabled = false;
		defaultTextFormat = new openfl.text.TextFormat('_sans', 14, color);
		autoSize = LEFT;
		multiline = true;
	}

	@:noCompletion private var times:Array<Float> = [];
	@:noCompletion private var curTime:Float = 0;
	override function __enterFrame(deltaTime:Float)
	{
		curTime += deltaTime;
		times.push(curTime);
		while (times[0] < curTime - 1000)
			times.shift();
		currentFPS = times.length;
		updateText();
	}

	public dynamic function updateText()
	{
		text = 'FPS: $currentFPS\nRAM: ' + formatBytes(memoryMegas) + '\nGCM: ' + formatBytes(#if hl hl.Gc.stats().currentMemory #else openfl.system.System.totalMemory #end);
		textColor = currentFPS <= FlxG.drawFramerate * .5 ? 0xffff0000 : 0xffffffff;
	}

	@:noCompletion var u:Array<String> = ['', 'K', 'M', 'G', 'T', 'P'];
	@:noCompletion function formatBytes(m:Float):String
	{
		var i:Int = 0;
		while (m >= 1000)
		{
			m *= .001;
			i++;
		}
		return (Math.fround(m * 100) * .01) + ' ' + u[i] + 'B';
	}

	@:noCompletion inline function get_memoryMegas():Float
	{
		return Memory.getCurrentUsage();
	}
}