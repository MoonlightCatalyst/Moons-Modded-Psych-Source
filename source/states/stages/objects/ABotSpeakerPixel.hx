package states.stages.objects;

#if funkin.vis
import funkin.vis.dsp.SpectralAnalyzer;
#end

class ABotSpeakerPixel extends FlxSpriteGroup
{
	final VIZ_MAX = 7; //ranges from viz1 to viz7
	final VIZ_POS_X:Array<Float> = [0, 55, 55, 55, 55, 55, 55];
	final VIZ_POS_Y:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

	public var bg:FlxSprite;
	public var vizSprites:Array<FlxSprite> = [];
	public var eyeBg:FlxSprite;
	public var eyes:FlxSprite;
	public var speaker:FlxSprite;

	#if funkin.vis
	var analyzer:SpectralAnalyzer;
	#end
	var volumes:Array<Float> = [];

	public var snd(default, set):FlxSound;
	function set_snd(changed:FlxSound)
	{
		snd = changed;
		#if funkin.vis
		initAnalyzer();
		#end
		return snd;
	}

	public function new(x:Float = 0, y:Float = 0, path:String = '')
	{
		super(x, y);

		var antialias:Bool = false;
		var newScale:Float = 6;

		bg = new FlxSprite(-45, 0).loadGraphic(Paths.image('abot/abotPixel/aBotPixelBack'));
		bg.antialiasing = antialias;
		add(bg);

		var vizX:Float = 0;
		var vizY:Float = 0;
		var vizFrames = Paths.getSparrowAtlas('abot/abotPixel/aBotVizPixel');
		for (i in 1...VIZ_MAX+1)
		{
			volumes.push(0.0);
			vizX += VIZ_POS_X[i-1];
			vizY += VIZ_POS_Y[i-1];
			var viz:FlxSprite = new FlxSprite(vizX - 165, vizY + 34);
			viz.frames = vizFrames;
			viz.animation.addByPrefix('VIZ', 'viz$i', 0);
			viz.animation.play('VIZ', true);
			viz.animation.curAnim.finish(); //make it go to the lowest point
			viz.antialiasing = antialias;
			vizSprites.push(viz);
			viz.updateHitbox();
			viz.centerOffsets();
			viz.scale.set(newScale, newScale);
			add(viz);
		}

		eyes = new FlxSprite(-310, 50);
		eyes.frames = Paths.getSparrowAtlas('abot/abotPixel/abotHead');
		eyes.antialiasing = antialias;
		eyes.animation.addByPrefix('lookleft', 'toleft', 24, false);
		eyes.animation.addByPrefix('left', 'left', 24, false);
		eyes.animation.addByPrefix('lookright', 'toright', 24, false);
		eyes.animation.addByPrefix('right', 'right', 24, false);
		eyes.animation.play('lookright');
		add(eyes);

		speaker = new FlxSprite(-65, -10);
		speaker.frames = Paths.getSparrowAtlas('abot/abotPixel/aBotPixel');
		speaker.animation.addByPrefix('anim', 'idle', 24, false);
		speaker.animation.play('anim', true);
		speaker.antialiasing = antialias;
		add(speaker);

		speaker.scale.set(newScale, newScale);
		eyes.scale.set(newScale, newScale);
		bg.scale.set(newScale, newScale);
	}

	#if funkin.vis
	var levels:Array<Bar>;
	var levelMax:Int = 0;
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(analyzer == null) return;

		levels = analyzer.getLevels(levels);
		var oldLevelMax = levelMax;
		levelMax = 0;
		for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
		{
			var animFrame:Int = Math.round(levels[i].value * 5);
			animFrame = Std.int(Math.abs(FlxMath.bound(animFrame, 0, 5) - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!
		
			vizSprites[i].animation.curAnim.curFrame = animFrame;
			levelMax = Std.int(Math.max(levelMax, 5 - animFrame));
		}

		/*
		if(levelMax >= 4)
		{
			//trace(levelMax);
			if(oldLevelMax <= levelMax && (levelMax >= 5 || speaker.anim.curFrame >= 3))
				beatHit();
		}
		*/
	}
	#end
	public function beatHit()
	{
		speaker.animation.play('anim', true);
	}

	#if funkin.vis
	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, 7, 0.1, 40);
	
		#if desktop
		// On desktop it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}
	#end

	var lookingAtRight:Bool = true;
	public function lookLeft()
	{
		if(lookingAtRight) eyes.animation.play('lookleft', true);
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.animation.play('lookright', true);
		lookingAtRight = true;
	}
}