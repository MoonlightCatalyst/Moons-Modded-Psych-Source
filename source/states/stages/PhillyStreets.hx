package states.stages;

import states.stages.objects.*;
import objects.Character;
import openfl.filters.ShaderFilter;

class PhillyStreets extends BaseStage
{
	var bg:BGSprite;
	var can:BGSprite;

	//var rain:Rain;

	override function create()
	{
		var sky:BGSprite = new BGSprite('phillyStreets/phillySkybox', -545, -123, 0, 0);
		sky.scale.set(1, 1);
		sky.alpha = 1;
		add(sky);

		var skyl:BGSprite = new BGSprite('phillyStreets/phillySkyline', -545, -123, 0.2, 0.2);
		skyl.scale.set(1, 1);
		skyl.alpha = 1;
		add(skyl);

		var fg:BGSprite = new BGSprite('phillyStreets/phillyForegroundCity', 625, 394, 0.3, 0.3);
		fg.scale.set(1, 1);
		fg.alpha = 1;
		add(fg);

		var con:BGSprite = new BGSprite('phillyStreets/phillyConstruction', 1800, 1064, 0.7, 1);
		con.scale.set(1, 1);
		con.alpha = 1;
		add(con);

		var lights:BGSprite = new BGSprite('phillyStreets/phillyHighwayLights', 284, 1005, 1, 1);
		lights.scale.set(1, 1);
		lights.alpha = 1;
		add(lights);

		var hw:BGSprite = new BGSprite('phillyStreets/phillyHighway', 139, 909, 1, 1);
		hw.scale.set(1, 1);
		hw.alpha = 1;
		add(hw);

		var smg:BGSprite = new BGSprite('phillyStreets/phillySmog', -6, 945, 1, 1);
		smg.scale.set(1, 1);
		smg.alpha = 1;
		add(smg);

		/*
		var cars:BGSprite = new BGSprite('phillyStreets/phillyCars', 1748, 818, 1, 1);
		cars.animation.addByPrefix('car1', "car1", 24);
		cars.animation.addByPrefix('car2', "car2", 24);
		cars.animation.addByPrefix('car3', "car3", 24);
		cars.animation.addByPrefix('car4', "car4", 24);
		cars.scale.set(1, 1);
		cars.alpha = 1;
		add(cars);

		var cars2:BGSprite = new BGSprite('phillyStreets/phillyCars', 1748, 818, 1, 1);
		cars2.animation.addByPrefix('car1', "car1", 24);
		cars2.animation.addByPrefix('car2', "car2", 24);
		cars2.animation.addByPrefix('car3', "car3", 24);
		cars2.animation.addByPrefix('car4', "car4", 24);
		cars2.scale.set(1, 1);
		cars2.alpha = 1;
		add(cars2);

		var traffic:BGSprite = new BGSprite('phillyStreets/phillyTraffic', 1840, 608, 0.9, 1);
		traffic.animation.addByPrefix('greentored', "greentored", 24);
		traffic.animation.addByPrefix('redtogreen', "redtogreen", 24);
		traffic.scale.set(1, 1);
		traffic.alpha = 1;
		add(traffic);
		*/

		var lightmap2:BGSprite = new BGSprite('phillyStreets/phillyTraffic_lightmap', 1840, 608, 0.9, 1);
		lightmap2.scale.set(1, 1);
		lightmap2.alpha = 1;
		add(lightmap2);

		var fg2:BGSprite = new BGSprite('phillyStreets/phillyForeground', 88, 1050, 1, 1);
		fg2.scale.set(1, 1);
		fg2.alpha = 1;
		add(fg2);

		can = new BGSprite('SpraycanPile', 980, 1765, 1, 1);
		can.scale.set(1, 1);
		can.alpha = 1;

		/*
		var bga = new FlxSprite(0, 0);
		bga.frames = Paths.getSparrowAtlas('NewTitleMenuBG', 'exe');
		bga.animation.addByPrefix('idle', "TitleMenuSSBG instance 1", 24);
		bga.animation.play('idle');
		bga.alpha = .75;
		bga.scale.x = 3;
		bga.scale.y = 3;
		bga.antialiasing = true;
		bga.updateHitbox();
		bga.screenCenter();
		add(bga)
		*/
	}
	override function createPost() {
		super.createPost();
		addBehindBF(can);

		/*
		rain = new Rain();
		FlxG.camera.setFilters([new ShaderFilter(rain.shader)]);
		rain.setFloatArray('uScreenResolution', FlxG.width, FlxG.height);
		rain.setFloat('uTime', 0);
		rain.setFloat('uScale', FlxG.height / 200);
		rain.setFloat('uIntensity', 0.1);
        return;
		*/
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		switch(event.event)
		{
			case "":
				
		}
	}
	//stagesFunc(function(stage:BaseStage) stage.onMoveCamera(isDad ? 'dad' : 'boyfriend')); //shit does something???? idfk atp too tired

	/*
	override function moveCameraSection(focus)
	{
		new FlxTimer().start(0.2, (tmr) -> {
			if (abotEyess == (focus == 'dad' ? 1 : 0)) {
			  
			  abotEyess = (focus == 'dad') ? 0 : 1;
			  abotEyes.animation.play((focus == 'dad') ? 'l' : 'r');
			}
		});
	}
	*/
	override function beatHit()
	{
		
	}

	var fun:Float = 0;
	override function update(e)
	{
		fun += e;
		/*
		rain.setFloatArray('uCameraBounds')
		{get('scroll.x') + get('viewMarginX'); // left
        get('scroll.y') + get('viewMarginY'); // top
        get('scroll.x') + (get('width') - get('viewMarginX')); // right
        get('scroll.y') + (get('height') - get('viewMarginY'));} // bottom
		*/
		//rain.setFloat('uTime', fun);
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

function get(p)
{
	//game.camGame;
}