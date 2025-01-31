package states.stages;

import states.stages.objects.*;

import shaders.AdjustColorShader;
import flixel.addons.display.FlxBackdrop;

enum HenchmenKillStates
{
	WAIT;
	KILLING;
	SPEEDING_OFFSCREEN;
	SPEEDING;
	STOPPING;
}

class LimoNight extends BaseStage
{
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:BGSprite;
	var fastCarCanDrive:Bool = true;

	// event
	var limoKillingState:HenchmenKillStates = WAIT;
	var limoMetalPole:BGSprite;
	var limoLight:BGSprite;
	var limoCorpse:BGSprite;
	var limoCorpseTwo:BGSprite;
	var bgLimo:BGSprite;
	var grpLimoParticles:FlxTypedGroup<BGSprite>;
	var dancersDiff:Float = 320;

	//shader
	var colorShader = new AdjustColorShader();

	//shooting star shit
	var shootingStarBeat:Int = 0;
	var shootingStarOffset:Int = 2;

	var shootingStar:FlxSprite;
	//
	//mist shit
	var mist:FlxBackdrop;
	var mist2:FlxBackdrop;
	//

	override function create()
	{
		var sunOverlay:BGSprite = new BGSprite('limo/limoOverlay', 0, 0, 1, 1);
		sunOverlay.setGraphicSize(Std.int(sunOverlay.width * 2));
		sunOverlay.camera = camHUD;
		sunOverlay.updateHitbox();
		add(sunOverlay);

		var skyBG:BGSprite = new BGSprite('limo/erect/limoSunset', -120, -50, 0.1, 0.1);
		add(skyBG);

		shootingStar = new FlxSprite(200, 0);
        shootingStar.frames = Paths.getSparrowAtlas('limo/erect/shooting star');
        shootingStar.animation.addByPrefix('shooting star', 'shooting star', 24, false);
        shootingStar.scrollFactor.set(0.12, 0.12);
        shootingStar.scale.set(1, 1);
        shootingStar.animation.play('shooting star');
		insert(20, shootingStar);

		if(!ClientPrefs.data.lowQuality) {
			limoMetalPole = new BGSprite('gore/metalPole', -500, 220, 0.4, 0.4);
			add(limoMetalPole);

			bgLimo = new BGSprite('limo/erect/bgLimo', -150, 480, 0.4, 0.4, ['background limo pink'], true);
			add(bgLimo);

			limoCorpse = new BGSprite('gore/noooooo', -500, limoMetalPole.y - 130, 0.4, 0.4, ['Henchmen on rail'], true);
			add(limoCorpse);

			limoCorpseTwo = new BGSprite('gore/noooooo', -500, limoMetalPole.y, 0.4, 0.4, ['henchmen death'], true);
			add(limoCorpseTwo);

			grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
			add(grpLimoDancers);

			for (i in 0...5)
			{
				var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + dancersDiff + bgLimo.x, bgLimo.y - 400);
				dancer.scrollFactor.set(0.4, 0.4);
				grpLimoDancers.add(dancer);
			}

			limoLight = new BGSprite('gore/coldHeartKiller', limoMetalPole.x - 180, limoMetalPole.y - 80, 0.4, 0.4);
			add(limoLight);

			grpLimoParticles = new FlxTypedGroup<BGSprite>();
			add(grpLimoParticles);

			//PRECACHE BLOOD
			var particle:BGSprite = new BGSprite('gore/stupidBlood', -400, -400, 0.4, 0.4, ['blood'], false);
			particle.alpha = 0.01;
			grpLimoParticles.add(particle);
			resetLimoKill();

			//PRECACHE SOUND
			Paths.sound('dancerdeath');
			setDefaultGF('gf-car');
		}

		//mist shitsss
		mist = new FlxBackdrop(Paths.image('limo/erect/mistBack'));
		mist.x = -650;
		mist.y = -380;
    	mist.velocity.x = 700;
    	mist.velocity.y = 0;
		mist.scrollFactor.set(0.6, 0.6);
		mist.scale.set(1.5,1.5);
		mist.color = 0xFF9c77c7;
    	mist.antialiasing = ClientPrefs.data.antialiasing;
    	mist.alpha = 1;
    	insert(98, mist);

		mist2 = new FlxBackdrop(Paths.image('limo/erect/mistMid'));
		mist2.x = -650;
		mist2.y = -400;
    	mist2.velocity.x = 1700;
    	mist2.velocity.y = 0;
		mist2.scrollFactor.set(0.2, 0.2);
		mist2.scale.set(1.5,1.5);
		mist2.color = 0xFFE7A480;
    	mist2.antialiasing = ClientPrefs.data.antialiasing;
    	mist2.alpha = 1;
    	insert(15, mist2);

		mist.blend = ADD;
		mist2.blend = ADD;

		fastCar = new BGSprite('limo/erect/fastCarLol', -300, 160);
		fastCar.active = true;
	}
	override function createPost()
	{
		resetFastCar();
		addBehindGF(fastCar);
		
		var limo:BGSprite = new BGSprite('limo/erect/limoDrive', -120, 550, 1, 1, ['Limo stage'], true);
		addBehindDad(limo); //Shitty layering but whatev it works LOL

		if(!ClientPrefs.data.lowQuality) {
			game.boyfriend.shader = colorShader;
			game.dad.shader = colorShader;
			game.gf.shader = colorShader;

			for (sprite in grpLimoDancers) { sprite.shader = colorShader; }
			limoCorpseTwo.shader = colorShader;
			limoCorpse.shader = colorShader;

			fastCar.shader = colorShader;

			colorShader.brightness.value = [-30];
			colorShader.hue.value = [-30];
			colorShader.contrast.value = [0];
			colorShader.saturation.value = [-20];
		}
	}

	var limoSpeed:Float = 0;
	var _timer:Float = 0;
	override function update(elapsed:Float)
	{
		_timer += elapsed;
		mist.y = -180 + (Math.sin(_timer*0.4)*300);
		mist2.y = -350 + (Math.sin(_timer*0.2)*150);

		if(!ClientPrefs.data.lowQuality) {
			grpLimoParticles.forEach(function(spr:BGSprite) {
				if(spr.animation.curAnim.finished) {
					spr.kill();
					grpLimoParticles.remove(spr, true);
					spr.destroy();
				}
			});

			switch(limoKillingState) {
				case KILLING:
					limoMetalPole.x += 5000 * elapsed;
					limoLight.x = limoMetalPole.x - 180;
					limoCorpse.x = limoLight.x - 50;
					limoCorpseTwo.x = limoLight.x + 35;

					var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
					for (i in 0...dancers.length) {
						if(dancers[i].x < FlxG.width * 1.5 && limoLight.x > (370 * i) + 170) {
							switch(i) {
								case 0 | 3:
									if(i == 0) FlxG.sound.play(Paths.sound('dancerdeath'), 0.5);

									var diffStr:String = i == 3 ? ' 2 ' : ' ';
									var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 200, dancers[i].y, 0.4, 0.4, ['hench leg spin' + diffStr + 'PINK'], false);
									grpLimoParticles.add(particle);
									var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x + 160, dancers[i].y + 200, 0.4, 0.4, ['hench arm spin' + diffStr + 'PINK'], false);
									grpLimoParticles.add(particle);
									var particle:BGSprite = new BGSprite('gore/noooooo', dancers[i].x, dancers[i].y + 50, 0.4, 0.4, ['hench head spin' + diffStr + 'PINK'], false);
									grpLimoParticles.add(particle);

									var particle:BGSprite = new BGSprite('gore/stupidBlood', dancers[i].x - 110, dancers[i].y + 20, 0.4, 0.4, ['blood'], false);
									particle.flipX = true;
									particle.angle = -57.5;
									grpLimoParticles.add(particle);
								case 1:
									limoCorpse.visible = true;
								case 2:
									limoCorpseTwo.visible = true;
							} //Note: Nobody cares about the fifth dancer because he is mostly hidden offscreen :(
							dancers[i].x += FlxG.width * 2;
						}
					}

					if(limoMetalPole.x > FlxG.width * 2) {
						resetLimoKill();
						limoSpeed = 800;
						limoKillingState = SPEEDING_OFFSCREEN;
					}

				case SPEEDING_OFFSCREEN:
					limoSpeed -= 4000 * elapsed;
					bgLimo.x -= limoSpeed * elapsed;
					if(bgLimo.x > FlxG.width * 1.5) {
						limoSpeed = 3000;
						limoKillingState = SPEEDING;
					}

				case SPEEDING:
					limoSpeed -= 2000 * elapsed;
					if(limoSpeed < 1000) limoSpeed = 1000;

					bgLimo.x -= limoSpeed * elapsed;
					if(bgLimo.x < -275) {
						limoKillingState = STOPPING;
						limoSpeed = 800;
					}
					dancersParenting();

				case STOPPING:
					bgLimo.x = FlxMath.lerp(-150, bgLimo.x, Math.exp(-elapsed * 9));
					if(Math.round(bgLimo.x) == -150) {
						bgLimo.x = -150;
						limoKillingState = WAIT;
					}
					dancersParenting();

				default: //nothing
			}
		}
	}

	override function beatHit()
	{
		if(!ClientPrefs.data.lowQuality) {
			grpLimoDancers.forEach(function(dancer:BackgroundDancer)
			{
				dancer.dance();
			});
		}

		if (FlxG.random.bool(10) && fastCarCanDrive)
			fastCarDrive();

		if (FlxG.random.bool(10) && curBeat > (shootingStarBeat + shootingStarOffset))
		{
			doShootingStar(curBeat);
		}
	}

	function doShootingStar(beat:Int):Void
		{
			shootingStar.x = FlxG.random.int(50,900);
			shootingStar.y = FlxG.random.int(-10,20);
			shootingStar.flipX = FlxG.random.bool(50);
			shootingStar.animation.play('shooting star');
	
			shootingStarBeat = beat;
			shootingStarOffset = FlxG.random.int(4, 8);
	
		}
	
	// Substates for pausing/resuming tweens and timers
	override function closeSubState()
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = true;
		}
	}

	override function openSubState(SubState:flixel.FlxSubState)
	{
		if(paused)
		{
			if(carTimer != null) carTimer.active = false;
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Kill Henchmen":
				killHenchmen();
		}
	}

	function dancersParenting()
	{
		var dancers:Array<BackgroundDancer> = grpLimoDancers.members;
		for (i in 0...dancers.length) {
			dancers[i].x = (370 * i) + dancersDiff + bgLimo.x;
		}
	}
	
	function resetLimoKill():Void
	{
		limoMetalPole.x = -500;
		limoMetalPole.visible = false;
		limoLight.x = -500;
		limoLight.visible = false;
		limoCorpse.x = -500;
		limoCorpse.visible = false;
		limoCorpseTwo.x = -500;
		limoCorpseTwo.visible = false;
	}

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = FlxG.random.int(30600, 39600);
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	function killHenchmen():Void
	{
		if(!ClientPrefs.data.lowQuality) {
			if(limoKillingState == WAIT) {
				limoMetalPole.x = -400;
				limoMetalPole.visible = true;
				limoLight.visible = true;
				limoCorpse.visible = false;
				limoCorpseTwo.visible = false;
				limoKillingState = KILLING;

				#if ACHIEVEMENTS_ALLOWED
				var kills = Achievements.addScore("roadkill_enthusiast");
				FlxG.log.add('Henchmen kills: $kills');
				#end
			}
		}
	}
}