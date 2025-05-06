package states.stages;

import states.stages.objects.*;
import cutscenes.CutsceneHandler;
import shaders.AdjustColorShader;
import shaders.DropShadowShader;
import objects.Character;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

class TankErect extends BaseStage
{
	var tankmanRun:FlxTypedGroup<TankmenBG>;

	var sniper:BGSprite;
	var guy:BGSprite;

	var colorShader = new AdjustColorShader();

	override function create()
	{
		var sky:BGSprite = new BGSprite('erect/bg', -985, -805, 1, 1);
		sky.scale.set(1.15, 1.15);
		add(sky);

		sniper = new BGSprite('erect/sniper', -300, 229, 1, 1, ['Tankmanidlebaked instance 1', 'tanksippingBaked instance 1'], false);
		sniper.animation.play('idle', true, false, 0);
		sniper.scale.set(1.15, 1.15);
		sniper.animation.finishCallback = function(name:String){
			if (name == 'tanksippingBaked instance 1')
				drinking = false;
		}
		add(sniper);

		guy = new BGSprite('erect/guy', 1298, 287, 1, 1, ['BLTank2 instance 1'], false);
		guy.animation.play('idle', true, false, 0);
		guy.scale.set(1.15, 1.15);
		add(guy);

		tankmanRun = new FlxTypedGroup<TankmenBG>();
		add(tankmanRun);

		// Default GFs
		if(songName == 'stress') setDefaultGF('pico-speaker');
		else if(songName == 'Stress (Pico Mix)') setDefaultGF('otis-speaker');
		else setDefaultGF('gf-tankmen');
	}
	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
		{
			if (ClientPrefs.data.shaders) {
				for (char in [boyfriend, dad, gf]) {
					var newShader:DropShadowShader = new DropShadowShader();
					char.shader = newShader;

					newShader.hue.value = [-38];
					newShader.saturation.value = [-20];
					newShader.contrast.value = [-25];
					newShader.brightness.value = [-46];
	
					newShader.str.value = [1];
					newShader.dist.value = [15];
					newShader.thr.value = [0.1];
	
					newShader.aa_stages.value = [2];
					newShader.dropColor.value = [223 / 255, 239 / 255, 60 / 255];

					if (char == dad) {
						newShader.thr.value = [0.3];
						newShader.ang.value = [135 * Math.PI / 180];
					} else {
						newShader.ang.value = [90 * Math.PI / 180];
					}				

					char.animation.callback = function(name, frameNum, frameIdx) {
						var frame = char.frame;
						newShader.uFrameBounds.value = [frame.uv.x, frame.uv.y, frame.uv.width, frame.uv.height];
						newShader.angOffset.value = [frame.angle * Math.PI / 180];
					}


					var newImage = char.imageFile.split('/');
					if (FileSystem.exists('erect/masks/${newImage}_mask.png')) {
						newShader.altMask.input = Paths.image('erect/masks/' + newImage + '_mask').bitmap;
						newShader.thr2.value = [1];
						newShader.useMask.value = [true];
					} else {
						newShader.useMask.value = [false];
					}
	
					if (gf.curCharacter == 'gf-tankmen') {
						newShader.thr2.value = [0.4];
					}
				}
			}

				/* //Color shader shit
				game.boyfriend.shader = colorShader;
				game.gf.shader = colorShader;
				if (PlayState.instance.abot != null) {PlayState.instance.abot.shader = colorShader;}

				colorShader.brightness.value = [-30];
				colorShader.hue.value = [-30];
				colorShader.contrast.value = [0];
				colorShader.saturation.value = [-20];
				*/
			}

			for (daGf in gfGroup)
			{
				var gf:Character = cast daGf;
				if(gf.curCharacter == 'pico-speaker' || gf.curCharacter == 'otis-speaker')
				{
					if (gf.curCharacter == 'otis-speaker'){
						gf.animation.finishCallback = function(name){
							if (name.contains('shoot')) gfCanIdle = true;
						}
					}
					var firstTank:TankmenBG = new TankmenBG(-20, 500, true);
					firstTank.resetShit(20, 1500, true);
					firstTank.strumTime = 10;
					firstTank.visible = false;
					firstTank.shader = colorShader;
					tankmanRun.add(firstTank);

					for (i in 0...TankmenBG.animationNotes.length)
					{
						if(FlxG.random.bool(16)) {
							var tankBih = tankmanRun.recycle(TankmenBG);
							tankBih.strumTime = TankmenBG.animationNotes[i][0];
							tankBih.resetShit(500, 120, TankmenBG.animationNotes[i][1] < 2);
							tankBih.shader = colorShader;
							tankmanRun.add(tankBih);
						}
					}
					break;
			}
		}
	}

	var drinking:Bool = false;
	override function countdownTick(count:Countdown, num:Int) {
		if(num % 2 == 0) {
			sniper.animation.play('Tankmanidlebaked instance 1', true, false, 0);
			guy.animation.play('BLTank2 instance 1', true, false, 0);
		}
	}

	var gfCanIdle:Bool = false;
	override function beatHit() {
		if (curBeat % 1 == 0) {
			guy.animation.play('BLTank2 instance 1', true, false, 0);
			if (!drinking) sniper.animation.play('Tankmanidlebaked instance 1', true, false, 0);
		}
		if (gfCanIdle && curBeat % 2 == 0) {
			gf.playAnim('idle', true, false, 0);
		}
		if (FlxG.random.bool(2) && !drinking) {
			sniper.animation.play('tanksippingBaked instance 1', true, false, 0);
			drinking = true;
		}
	}

	override public function update(elapsed) {
		super.update(elapsed);
	}

	// Cutscenes
	var cutsceneHandler:CutsceneHandler;
	var tankman:FlxAnimate;
	var pico:FlxAnimate;
	var boyfriendCutscene:FlxSprite;
	var audioPlaying:FlxSound;
	function prepareCutscene()
	{
		cutsceneHandler = new CutsceneHandler();

		dadGroup.alpha = 0.00001;
		camHUD.visible = false;
		//inCutscene = true; //this would stop the camera movement, oops

		tankman = new FlxAnimate(dad.x + 419, dad.y + 225);
		tankman.showPivot = false;
		Paths.loadAnimateAtlas(tankman, 'cutscenes/tankman');
		tankman.antialiasing = ClientPrefs.data.antialiasing;
		addBehindDad(tankman);
		cutsceneHandler.push(tankman);

		cutsceneHandler.finishCallback = function()
		{
			var timeForStuff:Float = Conductor.crochet / 1000 * 4.5;
			FlxG.sound.music.fadeOut(timeForStuff);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, timeForStuff, {ease: FlxEase.quadInOut});
			startCountdown();

			dadGroup.alpha = 1;
			camHUD.visible = true;
			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
		};

		cutsceneHandler.skipCallback = function()
		{
			dadGroup.alpha = 1;
			gfGroup.alpha = 1;
			boyfriendGroup.alpha = 1;
			camHUD.visible = true;

			if(audioPlaying != null)
				audioPlaying.stop();

			boyfriend.animation.finishCallback = null;
			gf.animation.finishCallback = null;
			gf.dance();
			dad.dance();
			boyfriend.dance();

			FlxTween.cancelTweensOf(FlxG.camera);
			FlxTween.cancelTweensOf(camFollow);
			game.moveCameraSection();
			FlxG.camera.scroll.set(camFollow.x - FlxG.width/2, camFollow.y - FlxG.height/2);
			FlxG.camera.zoom = defaultCamZoom;
			startCountdown();
		};
		camFollow.setPosition(dad.x + 280, dad.y + 170);
	}

	function stressIntro()
	{
		prepareCutscene();
		
		cutsceneHandler.endTime = 35.5;
		gfGroup.alpha = 0.00001;
		boyfriendGroup.alpha = 0.00001;
		camFollow.setPosition(dad.x + 400, dad.y + 170);
		FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2}, 1, {ease: FlxEase.quadInOut});
		Paths.sound('stressCutscene');

		pico = new FlxAnimate(gf.x + 150, gf.y + 450);
		pico.showPivot = false;
		Paths.loadAnimateAtlas(pico, 'cutscenes/picoAppears');
		pico.antialiasing = ClientPrefs.data.antialiasing;
		pico.anim.addBySymbol('dance', 'GF Dancing at Gunpoint', 24, true);
		pico.anim.addBySymbol('dieBitch', 'GF Time to Die sequence', 24, false);
		pico.anim.addBySymbol('picoAppears', 'Pico Saves them sequence', 24, false);
		pico.anim.addBySymbol('picoEnd', 'Pico Dual Wield on Speaker idle', 24, false);
		pico.anim.play('dance', true);
		addBehindGF(pico);
		cutsceneHandler.push(pico);

		// prepare pico animation cycle
		function picoStressCycle() {
			switch (pico.anim.curInstance.symbol.name) {
				case "dieBitch", "GF Time to Die sequence":
					pico.anim.play('picoAppears', true);
					boyfriendGroup.alpha = 1;
					boyfriendCutscene.visible = false;
					boyfriend.playAnim('bfCatch', true);
					boyfriend.animation.finishCallback = function(name:String)
					{
						if(name != 'idle')
						{
							boyfriend.playAnim('idle', true);
							boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
						}
					};
				case "picoAppears", "Pico Saves them sequence":
					pico.anim.play('picoEnd', true);
				case "picoEnd", "Pico Dual Wield on Speaker idle":
					gfGroup.alpha = 1;
					pico.visible = false;
					if (pico.anim.onComplete.has(picoStressCycle)) // for safety
						pico.anim.onComplete.remove(picoStressCycle);
			}
		}
		pico.anim.onComplete.add(picoStressCycle);

		boyfriendCutscene = new FlxSprite(boyfriend.x + 5, boyfriend.y + 20);
		boyfriendCutscene.antialiasing = ClientPrefs.data.antialiasing;
		boyfriendCutscene.frames = Paths.getSparrowAtlas('characters/BOYFRIEND');
		boyfriendCutscene.animation.addByPrefix('idle', 'BF idle dance', 24, false);
		boyfriendCutscene.animation.play('idle', true);
		boyfriendCutscene.animation.curAnim.finish();
		addBehindBF(boyfriendCutscene);
		cutsceneHandler.push(boyfriendCutscene);

		var cutsceneSnd:FlxSound = new FlxSound().loadEmbedded(Paths.sound('stressCutscene'));
		FlxG.sound.list.add(cutsceneSnd);

		tankman.anim.addBySymbol('godEffingDamnIt', 'TANK TALK 3 P1 UNCUT', 24, false);
		tankman.anim.addBySymbol('lookWhoItIs', 'TANK TALK 3 P2 UNCUT', 24, false);
		tankman.anim.play('godEffingDamnIt', true);

		cutsceneHandler.onStart = function()
		{
			cutsceneSnd.play(true);
			audioPlaying = cutsceneSnd;
		};

		cutsceneHandler.timer(15.2, function()
		{
			FlxTween.tween(camFollow, {x: 650, y: 300}, 1, {ease: FlxEase.sineOut});
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 2.25, {ease: FlxEase.quadInOut});
			pico.anim.play('dieBitch', true);
		});

		cutsceneHandler.timer(17.5, function()
		{
			zoomBack();
		});

		cutsceneHandler.timer(19.5, function()
		{
			tankman.anim.play('lookWhoItIs', true);
		});

		cutsceneHandler.timer(20, function()
		{
			camFollow.setPosition(dad.x + 500, dad.y + 170);
		});

		cutsceneHandler.timer(31.2, function()
		{
			boyfriend.playAnim('singUPmiss', true);
			boyfriend.animation.finishCallback = function(name:String)
			{
				if (name == 'singUPmiss')
				{
					boyfriend.playAnim('idle', true);
					boyfriend.animation.curAnim.finish(); //Instantly goes to last frame
				}
			};

			camFollow.setPosition(boyfriend.x + 280, boyfriend.y + 200);
			FlxG.camera.snapToTarget();
			game.cameraSpeed = 12;
			FlxTween.tween(FlxG.camera, {zoom: 0.9 * 1.2 * 1.2}, 0.25, {ease: FlxEase.elasticOut});
		});

		cutsceneHandler.timer(32.2, function()
		{
			zoomBack();
		});
	}

	function zoomBack()
	{
		var calledTimes:Int = 0;
		camFollow.setPosition(630, 425);
		FlxG.camera.snapToTarget();
		FlxG.camera.zoom = 0.8;
		game.cameraSpeed = 1;

		calledTimes++;
	}
}