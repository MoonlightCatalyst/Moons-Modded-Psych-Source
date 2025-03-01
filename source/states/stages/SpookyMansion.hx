package states.stages;

import objects.Note;
import objects.Character;
import shaders.AdjustColorShader;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

//I now realize how shitty my stage coding really is, especially in haxe oml

class SpookyMansion extends BaseStage
{

	var bg:BGSprite;
	var bgLight:BGSprite;
	var stairsDark:BGSprite;
	var stairsLight:BGSprite;

	var bfClone:Character;
	var gfClone:Character;
	var dadClone:Character;

	//var rain:Rain;
    //var rainShader = new RainShader();
    var solid:FlxSprite;

	override function create()
	{

        solid = new FlxSprite().makeGraphic(2400,2000,0xFF242336);

        var bgTrees = new FlxSprite(200, 50);
        bgTrees.frames = Paths.getSparrowAtlas('erect/bgtrees');
        bgTrees.animation.addByPrefix('idle', 'bgtrees', 5, true);
        bgTrees.scrollFactor.set(0.8, 0.8);
        bgTrees.scale.set(1, 1);
        bgTrees.animation.play('idle');

        var bgDark:BGSprite = new BGSprite('erect/bgDark', -360, -220, 1, 1);
		bgDark.scale.set(1, 1);
        //bgDark.updateHitbox();
		bgDark.alpha = 1;

        bgLight = new BGSprite('erect/bgLight', -360, -220, 1, 1);
		bgLight.scale.set(1, 1);
		bgLight.alpha = 0;

        stairsDark = new BGSprite('erect/stairsDark', 966, -225, 1, 1);
		stairsDark.scale.set(1, 1);
		stairsDark.alpha = 1;

        stairsLight = new BGSprite('erect/stairsLight', 966, -225, 1, 1);
		stairsLight.scale.set(1, 1);
		stairsLight.alpha = 0;

        insert(0, solid); 
        insert(11, bgTrees); 
        insert(10, bgDark); 
        insert(9, bgLight);
	}

    override function createPost() {
        super.createPost();
        if(!ClientPrefs.data.lowQuality) {
            //code
			insert(members.indexOf(game.boyfriendGroup)+1, stairsDark); 
        	insert(members.indexOf(game.boyfriendGroup)+2, stairsLight);

			//These ASSUME you're using Skid and Pump, Normal Boyfriend, and Normal Girlfriend. Sorry for the people who use reskin mods on this, until I find a solution.
			bfClone = new Character(game.boyfriend.x, game.boyfriend.y, 'bf', true);
			insert(members.indexOf(game.boyfriendGroup), bfClone);

			gfClone = new Character(game.gf.x, game.gf.y,'gf', false);
			insert(members.indexOf(game.gfGroup), gfClone);

			dadClone = new Character(game.dad.x, game.dad.y, 'spooky', false); 
			insert(members.indexOf(game.dadGroup), dadClone);

			bfClone.alpha = 0;
			gfClone.alpha = 0;
			dadClone.alpha = 0;
        }
    }
    var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var danced:Bool = false;
	override function beatHit()
	{
		if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
		if(curBeat % 1 == 0 && !danced) 
		{
			gfClone.playAnim('danceRight');
			if(dadClone.animation.finished && dadClone.animation.curAnim.name.startsWith('sing')) {
				dadClone.playAnim('danceRight');
			}
			danced = true;
		} else if(curBeat % 1 == 0 && danced) {
			gfClone.playAnim('danceLeft');
			if(dadClone.animation.finished && dadClone.animation.curAnim.name.startsWith('sing')) {
				dadClone.playAnim('danceLeft');
			}
			danced = false;
		}
		if(curBeat % 2 == 0) {
			bfClone.dance();
		}
	}

    function lightningStrikeShit():Void
    {
        FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));

        lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		//stage and character alpha shit
		game.dad.alpha = 0;
		game.gf.alpha = 0;
		game.boyfriend.alpha = 0;

		bfClone.alpha = 1;
		gfClone.alpha = 1;
		dadClone.alpha = 1;

		bgLight.alpha = 1;
		stairsLight.alpha = 1;

		new FlxTimer().start(0.06, (tmr) -> {
			game.dad.alpha = 1;
			game.gf.alpha = 1;
			game.boyfriend.alpha = 1;

			bfClone.alpha = 0;
			gfClone.alpha = 0;
			dadClone.alpha = 0;

			bgLight.alpha = 0;
			stairsLight.alpha = 0;
		});

		new FlxTimer().start(0.12, (tmrt) -> {
			game.dad.alpha = 0;
			game.gf.alpha = 0;
			game.boyfriend.alpha = 0;

			bfClone.alpha = 1;
			gfClone.alpha = 1;
			dadClone.alpha = 1;

			bgLight.alpha = 1;
			stairsLight.alpha = 1;

			FlxTween.tween(bgLight, {alpha: 0}, 1.5);
			FlxTween.tween(stairsLight, {alpha: 0}, 1.5);
			FlxTween.tween(bfClone, {alpha: 0}, 1.5);
			FlxTween.tween(gfClone, {alpha: 0}, 1.5);
			FlxTween.tween(dadClone, {alpha: 0}, 1.5);
			FlxTween.tween(game.boyfriend, {alpha: 1}, 1.5);
			FlxTween.tween(game.gf, {alpha: 1}, 1.5);
			FlxTween.tween(game.dad, {alpha: 1}, 1.5);
		});
		//

        if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}

		if(dad.animOffsets.exists('scared')) {
			dad.playAnim('scared', true);
		}

		if(gf != null && gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

        if(ClientPrefs.data.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!game.camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}
    }
	override function goodNoteHit(note:Note)
	{
		bfClone.playAnim(boyfriend.animation.name, true);
		bfClone.specialAnim = true;
	}
	override function opponentNoteHit(note:Note)
	{
		dadClone.playAnim(dad.animation.name, true);
		dadClone.specialAnim = true;
	}
}		