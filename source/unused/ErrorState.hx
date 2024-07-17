// Referenced from Super Engine lmao
class FlxSafeGame extends FlxGame
{
override function create(_:Event)
try
{
super.create(_);
}
catch (e:Exception)
Util.error(e, 'FlxGame: create', true);

override function onEnterFrame(_)
try
{
super.onEnterFrame(_);
}
catch (e:Exception)
Util.error(e, 'FlxGame: onEnterFrame', true);

override function update()
try
{
super.update();
}
catch (e:Exception)
Util.error(e, 'FlxGame: update', true);

override function draw()
try
{
super.draw();
}
catch (e:Exception)
Util.error(e, 'FlxGame: draw', true);

override function onFocus(_)
try
{
super.onFocus(_);
}
catch (e:Exception)
Util.error(e, 'FlxGame: onFocus', true);

override function onFocusLost(_)
try
{
super.onFocusLost(_);
}
catch (e:Exception)
Util.error(e, 'FlxGame: onFocusLost', true);
}