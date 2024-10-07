package objects;

@:publicFields
class HoldCover extends FlxSprite {

  // USED to be used for past sustain spawning, but it's fixed now :)
  //static var startingCrochet:Float;

  var extraData:Dynamic;

  var parentEnd:Note;
  var parentStrum:StrumNote;

  var rgbShader:NoteSplash.PixelSplashShaderRef;

  var destroyTimer:FlxTimer;

  var copyVisible:Bool = false;
  var copyAlpha:Bool = true;
  var copyX:Bool = true;
  var copyY:Bool = true;

  override function update(elapsed:Float):Void {
    super.update(elapsed);
    if (parentStrum != null) updateToStrum();
  }

  override function new():Void {
    super();
    frames = Paths.getSparrowAtlas('holdCovers/holdCover');
    animation = new backend.animation.PsychAnimationController(this);
    animation.addByPrefix('start', 'start', 24, false);
    animation.addByPrefix('hold', 'hold');
    animation.addByPrefix('end', 'end', 24, false);
  }

  function setupCover(end:Note, strum:StrumNote):Void {
    parentEnd = end;
    parentStrum = strum;

    updateToStrum();

    rgbShader = new NoteSplash.PixelSplashShaderRef();
    shader = rgbShader.shader;
    if (parentEnd.shader != null) {
      //shader.data.mult.value[0] = parentEnd.shader.data.mult.value[0];
      for (i in 0...3) {
        shader.data.r.value[i] = parentEnd.shader.data.r.value[i];
        shader.data.g.value[i] = parentEnd.shader.data.g.value[i];
        shader.data.b.value[i] = parentEnd.shader.data.b.value[i];
      }
    }

    var mainTime:Float = Conductor.stepCrochet * (parentEnd.parent.tail.length - 1);
    var accountEndSize:Float = parentEnd.height / .45 / PlayState.instance.songSpeed / parentEnd.multSpeed;
    var offsetFromParentPosition:Float = parentEnd.parent.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset;
    destroyTimer = new CoverTimer().start((mainTime + accountEndSize + offsetFromParentPosition) * .001, (t:FlxTimer) -> {
      parentEnd.visible = false;
      if (!parentEnd.mustPress) return kill();
      animation.play('end', true, false, 2);
      copyAlpha = false;
      alpha = ClientPrefs.data.splashAlpha * parentStrum.alpha;
    });

    animation.play('start');
    offset.set(106.25, 100);

    animation.finishCallback = (n:String) -> {
      switch (n) {
        case 'start':
          animation.play('hold');
        case 'end':
          kill();
      }
    }

    parentEnd.cover = this;
  }

  inline function updateToStrum():Void {
    if (copyVisible) visible = parentStrum.visible;
    if (copyAlpha) alpha = parentStrum.alpha;
    if (copyX) x = parentStrum.x;
    if (copyY) y = parentStrum.y;
  }

  override function kill():Void {
    super.kill();
    if (FlxG.state is PlayState && PlayState.instance.grpHoldCovers.getLastIndex(function(i:HoldCover):Bool return i == this) != -1)
      PlayState.instance.grpHoldCovers.remove(this);
  }

}

class CoverTimer extends FlxTimer {
	override public function update(elapsed:Float):Void {
		_timeCounter += elapsed * (PlayState.instance.playbackRate ?? 1);
		while (_timeCounter >= time && active && !finished) {
			_timeCounter -= time;
			_loopsCounter++;
			if (loops > 0 && _loopsCounter >= loops) finished = true;
		}
	}
}
