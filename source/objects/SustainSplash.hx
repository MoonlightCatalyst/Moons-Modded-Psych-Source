package objects;

class SustainSplash extends FlxSprite {

  public static var startCrochet:Float;
  public static var frameRate:Int;
  public static var isPixelStage:Bool;
  public var destroyTimer:FlxTimer;

  public function new():Void {

    super();

    frames = Paths.getSparrowAtlas('noteSplashes/holdSplashes/holdSplash');
    animation.addByPrefix('hold', 'hold', 24, true);
    animation.addByPrefix('end', 'end', 24, false);
    animation.play('hold', true, false, 0);
    animation.curAnim.frameRate = frameRate;
    animation.curAnim.looped = true;

    destroyTimer = new FlxTimer();

  }

  public function setupSusSplash(strum:StrumNote, end:Note, ?playbackRate:Float = 1):Void {

    final timeThingy:Float = (startCrochet * end.parent.tail.length + (end.parent.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset)) / playbackRate * .001;

    end.extraData['holdSplash'] = this;

    clipRect = new flixel.math.FlxRect(0, !isPixelStage ? 0 : -210, frameWidth, frameHeight);

    if (end.shader != null) {
      shader = new objects.NoteSplash.PixelSplashShaderRef().shader;
      shader.data.r.value = end.shader.data.r.value;
      shader.data.g.value = end.shader.data.g.value;
      shader.data.b.value = end.shader.data.b.value;
      shader.data.mult.value = end.shader.data.mult.value;
    }

    setPosition(strum.x, strum.y);
    offset.set(isPixelStage ? 112.5 : 106.25, 100);

    destroyTimer.start(timeThingy, (idk:FlxTimer) -> {

      if (!end.mustPress) {
        die(end);
        return;
      }

      alpha = ClientPrefs.data.holdSplashAlpha;

      clipRect = null;

      animation.play('end', true, false, 0);
      animation.curAnim.looped = false;
      animation.curAnim.frameRate = 24;
      animation.finishCallback = (idkEither:Dynamic) -> {die(end);}

    });

  }

  public function die(?end:Note = null):Void {

    kill();
    super.kill();

    if (FlxG.state is PlayState) {
      PlayState.instance.grpHoldSplashes.remove(this);
    }

    destroy();
    super.destroy();

    if (end != null) {
      end.extraData['holdSplash'] = null;
    }

  }

}