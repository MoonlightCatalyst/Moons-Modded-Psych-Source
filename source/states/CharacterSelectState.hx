package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.addons.display.FlxRuntimeShader;

class CharacterSelectState extends MusicBeatState
{
    var allowInputs:Bool = true;

    var backspace:FlxSprite;
    var background:FlxSprite;
    var stage:FlxSprite;
    var curtains:FlxSprite;
    var light:FlxSprite;
    var light2:FlxSprite;
    var blur:FlxSprite;
    var backingBlur:FlxSprite;
    var backing:FlxSprite;
    var choose:FlxSprite;

    var crowd:FlxAnimate;
    var barThing:FlxAnimate;
    var speakers:FlxAnimate;

    var bf:FlxAnimate;
    var gf:FlxAnimate;
    var pico:FlxAnimate;
    var nene:FlxAnimate;
    var template:FlxAnimate;

    var imagePath:String = "charSelect/";

    override function create() {
        background = new FlxSprite(-153, -140).loadGraphic(Paths.image(imagePath + 'charSelectBG'));
        background.scrollFactor.set(0.1, 0.1);
        add(background);

        crowd = new FlxAnimate(0, 230);
		Paths.loadAnimateAtlas(crowd, imagePath + 'crowd');
		crowd.anim.addBySymbol('idle', 'crowd', 24, true);
        crowd.anim.play('idle', true, false, 0);
        crowd.scrollFactor.set(0.3, 0.3);
		add(crowd);

        stage = new FlxSprite(-40, 391).loadGraphic(Paths.image(imagePath + 'charSelectStage'));
        stage.frames = Paths.getSparrowAtlas(imagePath + 'charSelectStage');
        stage.animation.addByPrefix("idle", "stage full instance 1", 24, true);
        stage.animation.play('idle');
        stage.scrollFactor.set(1, 1);
        add(stage);

        curtains = new FlxSprite(-47, -49).loadGraphic(Paths.image(imagePath + 'curtains'));
        curtains.scrollFactor.set(1.4, 1.4);
        add(curtains);

        barThing = new FlxAnimate(-20, 0);
		Paths.loadAnimateAtlas(barThing, imagePath + 'barThing');
		barThing.anim.addBySymbol('idle', 'name bar animated', 24, true);
        barThing.scrollFactor.set(0, 0);
        barThing.anim.play('idle');
		add(barThing);
        barThing.y += 80;
        FlxTween.tween(barThing, {y: barThing.y - 80}, 1.3, {ease: FlxEase.expoOut});

        light = new FlxSprite(800, 250).loadGraphic(Paths.image(imagePath + 'charLight'));
        add(light);

        light2 = new FlxSprite(180, 240).loadGraphic(Paths.image(imagePath + 'charLight'));
        add(light2);

        //WHERE THE CHARS SHOULD GO. SAVE THIS SPOT
        bf = new FlxAnimate(600, 350);
		Paths.loadAnimateAtlas(bf, imagePath + 'bfChill');
		bf.anim.addBySymbol('idle', 'bf cs idle', 24, true);
        bf.anim.play('idle', true, false, 0);
        bf.scrollFactor.set(1, 1);
		add(bf);

        gf = new FlxAnimate(600, 350);
		Paths.loadAnimateAtlas(gf, imagePath + 'gfChill');
		gf.anim.addBySymbol('idle', 'Partner GF idle', 24, true);
        gf.anim.play('idle', true, false, 0);
        gf.scrollFactor.set(1, 1);
		add(gf);

        pico = new FlxAnimate(600, 350);
		Paths.loadAnimateAtlas(pico, imagePath + 'picoChill');
		pico.anim.addBySymbol('idle', 'pico cs idle', 24, true);
        pico.anim.play('idle', true, false, 0);
        pico.scrollFactor.set(1, 1);
		add(pico);

        nene = new FlxAnimate(600, 350);
		Paths.loadAnimateAtlas(nene, imagePath + 'neneChill');
		nene.anim.addBySymbol('idle', 'nene cs idle', 24, true);
        nene.anim.play('idle', true, false, 0);
        nene.scrollFactor.set(1, 1);
		add(nene);

        pico.visible = false;
        nene.visible = false;
        //

        speakers = new FlxAnimate(0, 0);
		Paths.loadAnimateAtlas(speakers, imagePath + 'charSelectSpeakers');
		speakers.anim.addBySymbol('idle', 'G', 24, true);
        speakers.anim.play('idle', true, false, 0);
        speakers.scrollFactor.set(1.8, 1.8);
		add(speakers);

        blur = new FlxSprite(-125, 170).loadGraphic(Paths.image(imagePath + 'foregroundBlur'));
        blur.blend = MULTIPLY;
        add(blur);

        backingBlur = new FlxSprite(419, -65);
        backingBlur.frames = Paths.getSparrowAtlas(imagePath + 'dipshitBlur');
        backingBlur.animation.addByPrefix("idle", "CHOOSE vertical offset instance 1", 24, true);
        backingBlur.animation.play('idle');
        backingBlur.blend = ADD;
        add(stage);

        backing = new FlxSprite(423, -17);
        backing.frames = Paths.getSparrowAtlas(imagePath + 'dipshitBacking');
        backing.animation.addByPrefix("idle", "CHOOSE horizontal offset instance 1", 24, true);
        backing.animation.play('idle');
        backing.blend = ADD;
        add(stage);
        backing.y += 210;
        FlxTween.tween(backing, {y: backing.y - 210}, 1.1, {ease: FlxEase.expoOut});

        choose = new FlxSprite(426, -13).loadGraphic(Paths.image(imagePath + 'chooseDipshit'));
        add(choose);
        choose.y += 200;
        FlxTween.tween(choose, {y: choose.y - 200}, 1, {ease: FlxEase.expoOut});
        backingBlur.y += 220;
        FlxTween.tween(backingBlur, {y: backingBlur.y - 220}, 1.2, {ease: FlxEase.expoOut});

        backingBlur.scrollFactor.set();
        backing.scrollFactor.set();
        choose.scrollFactor.set();

        backspace = new FlxSprite(0, 560);
        backspace.frames = Paths.getSparrowAtlas('gallery/ui/backspace');
        backspace.animation.addByPrefix('white', "backspace to exit white0", 24);
        backspace.animation.addByPrefix('exit', "backspace to exit", 12);
        backspace.animation.play('white');
        backspace.updateHitbox();
        add(backspace);

        FlxG.sound.playMusic(Paths.music('charSelect/stayFunky'), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
        super.create();
    }

    override function update(elapsed:Float):Void {
        if (controls.BACK && allowInputs) {
            allowInputs = false;
            MusicBeatState.switchState(new FreeplayState());
            FlxG.sound.play(Paths.sound('cancelMenu'));
            backspace.animation.play('exit');
        }
        super.update(elapsed);
    }

    override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;

		FlxG.sound.playMusic(Paths.music('menuSongs/freakyMenu-' + ClientPrefs.data.menuSong), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
	}	
}