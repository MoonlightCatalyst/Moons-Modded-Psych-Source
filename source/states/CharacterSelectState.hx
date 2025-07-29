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
    var cursor:FlxSprite;

    var crowd:FlxAnimate;
    var barThing:FlxAnimate;
    var speakers:FlxAnimate;

    var bf:FlxAnimate;
    var gf:FlxAnimate;
    var pico:FlxAnimate;
    var nene:FlxAnimate;
    var template:FlxAnimate;

    var grpIcons:FlxSpriteGroup;
    var matrixFilter:Array<Float> = [
        1, 1, 1,
        1, 1, 1,
        1, 1, 1
    ];

    var currentX:Int = 1; //the default X position. Starts it in the Center. Change the value to 0 to start it at the far left, or 2 to start it at the far right.
    var currentY:Int = 1; //the default Y position. Starts it in the Center. Change the value to 0 to start it at the bottom, or 2 to start it at the top.
    var grpXSpread:Int = 107;
    var grpYSpread:Int = 127;

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

        cursor = new FlxSprite(0, 0).loadGraphic(Paths.image(imagePath + 'charSelector'));
        cursor.scrollFactor.set(0, 0);
        cursor.screenCenter();
        add(cursor);
        FlxTween.color(cursor, 0.2, 0xFFFFFF00, 0xFFFFCC00, {type: PINGPONG});

        backspace = new FlxSprite(0, 560);
        backspace.frames = Paths.getSparrowAtlas('gallery/ui/backspace');
        backspace.animation.addByPrefix('white', "backspace to exit white0", 24);
        backspace.animation.addByPrefix('exit', "backspace to exit", 12);
        backspace.animation.play('white');
        backspace.updateHitbox();
        add(backspace);

        FlxG.sound.playMusic(Paths.music('charSelect/stayFunky'), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);

        createLocks();

        super.create();
    }

    function createLocks() {
        grpIcons = new FlxSpriteGroup();
        add(grpIcons);

        for (i in 0...9) {
            var icons = new FlxSprite(0, 0).loadGraphic('auto');
            icons.setGraphicSize(128, 128);
            icons.updateHitbox();
            icons.ID = i;
            grpIcons.add(icons);
        }
        updateIconPositions();
    }

    function updateIconPositions() {
        grpIcons.x = 450;
        grpIcons.y = 120;
        for (index => member in grpIcons.members) {
            var posX:Float = (index % 3);
            var posY:Float = Math.floor(index / 3);

            member.x = posX * grpXSpread;
            member.y = posY * grpYSpread;

            member.x += grpIcons.x;
            member.y += grpIcons.y;
        }
    }

    override function update(elapsed:Float):Void {
        if (controls.BACK && allowInputs) {
            allowInputs = false;
            MusicBeatState.switchState(new FreeplayState());
            FlxG.sound.play(Paths.sound('cancelMenu'));
            backspace.animation.play('exit');
        }

        if (allowInputs) {
            if ((controls.UI_LEFT_P || controls.UI_RIGHT_P)) {
                changeSelection('x', controls.UI_LEFT_P ? -1 : controls.UI_RIGHT_P ? 1 : 0);
            }
            if ((controls.UI_DOWN_P || controls.UI_UP_P)) {
                changeSelection('y', controls.UI_DOWN_P ? -1 : controls.UI_UP_P ? 1 : 0);
            }
            if (currentX == -1 || currentX == 3) {
                currentX = 1;
            }
            if (currentY == -1 || currentY == 3) {
                currentY = 1;
            }
        }

        super.update(elapsed);
    }

    function changeSelection(direction:String, value:Int) {
        if (direction == 'x' && (currentX >= 0 && currentX <= 2)) {
            currentX += value;
            FlxG.sound.play(Paths.sound('charSelect/CS_select'));
        }
        if (direction == 'y' && (currentY >= 0 && currentY <= 2)) {
            currentY += value;
            FlxG.sound.play(Paths.sound('charSelect/CS_select'));
        }
        trace('X Position: ' + currentX + ' Y Position: ' + currentY);
    }

    override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;

		FlxG.sound.playMusic(Paths.music('menuSongs/freakyMenu-' + ClientPrefs.data.menuSong), 0);
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
	}	
}