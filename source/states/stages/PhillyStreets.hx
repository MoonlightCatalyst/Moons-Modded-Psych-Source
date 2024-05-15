package states.stages;

import states.stages.objects.*;
import objects.Character;

class Philly extends BaseStage
{
	var bg:BGSprite;

	override function create()
	{
		
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			case "":
				
		}
	}

	override function update(elapsed:Float)
	{
		
	}

	override function beatHit()
	{
		
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case " ":
				
			}
		}
	}

function doFlash()
{
	var color:FlxColor = FlxColor.WHITE;
	if(!ClientPrefs.data.flashing) color.alphaFloat = 0.5;

	FlxG.camera.flash(color, 0.15, null, true);
}