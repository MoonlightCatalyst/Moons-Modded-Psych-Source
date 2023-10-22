package states;

import flixel.*;
import flixel.FlxSprite;
import flixel.text.FlxText;
//import backend.Controls;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.math.FlxMath;
import sys.FileSystem;
import flixel.addons.ui.FlxInputText;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

class Gallery extends MusicBeatState
{
    var itemGroup:FlxTypedGroup<GalleryImage>;
    var imagePaths:Array<String>;
    var imageDescriptions:Array<String>;
    var imageTitle:Array<String>;
    var currentIndex:Int = 0;
    var descriptionText:FlxText;
    var titleText:FlxText;
    var background:FlxSprite;
    var imageSprite:FlxSprite;
    var bg:FlxSprite;

    override public function create():Void
    {
        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Gallery", null);
		#end

        // Set up background
        background = new FlxSprite(10, 50).loadGraphic(Paths.image("menuBGDark"));
        background.setGraphicSize(Std.int(background.width * 1));
        background.screenCenter();
        add(background);

        /* //for backdrop shit, won't add for now.
        var grid:FlxBackdrop = new FlxBackdrop(FlxGridOverlay.createGrid(80, 80, 160, 160, true, 0x33FFFFFF, 0x0));
		grid.velocity.set(40, 40);
		grid.alpha = 0;
		FlxTween.tween(grid, {alpha: 1}, 0.5, {ease: FlxEase.quadOut});
		add(grid);
        */

        // Set up image paths and descriptions
        imagePaths = ["gallery/local swords = Swords", "gallery/unholyseksradical", "gallery/cry_about_it", "gallery/funkay", "gallery/goober", "gallery/unholyonemoretime", "gallery/keoiki"];
        imageDescriptions = ["local swords = Swords", "unholyseksradical", "Cry about it", "Very funkay", "Mlem", "unholy once again", "guh"];
        imageTitle = ["Swords", "unholyseksradical", "Smash Bros", "Funkay", "Goofy Goober", "back for round two", "keoiki"];

        itemGroup = new FlxTypedGroup<GalleryImage>();
        
        for (id => i in imagePaths) {
            var newItem = new GalleryImage();
            newItem.loadGraphic(Paths.image(i));
            newItem.ID = id;
            newItem.screenCenter(Y);
            itemGroup.add(newItem);
        }
        
        add(itemGroup);

        descriptionText = new FlxText(50, -100, FlxG.width - 100, imageDescriptions[currentIndex]);
        descriptionText.setFormat(null, 25, 0xff4c06ee, "center");
        descriptionText.screenCenter();
        descriptionText.color = 0xff4c06ee;
        descriptionText.y += 250;
        descriptionText.setFormat(Paths.font("kapi.ttf"), 32);
        add(descriptionText);

        titleText = new FlxText(50, 50, FlxG.width - 100, imageTitle[currentIndex]);
        titleText.screenCenter(X);
        titleText.color = 0xff4c06ee;
        titleText.setFormat(null, 40, 0xff4c06ee, "center");
        titleText.setFormat(Paths.font("kapi.ttf"), 32);
        add(titleText);
        
        persistentUpdate = true;
        changeSelection();
    }

    var allowInputs:Bool = true;
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Handle left and right arrow keys to scroll through image
        if ((controls.UI_LEFT_P || controls.UI_RIGHT_P) && allowInputs) {
            changeSelection(controls.UI_LEFT_P ? -1 : 1);
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
        
        if (controls.BACK && allowInputs)
        {
            allowInputs = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
            MusicBeatState.switchState(new MainMenuState());
        }
    }
    
    private function changeSelection(i = 0)
    {
        currentIndex = FlxMath.wrap(currentIndex + i, 0, imageTitle.length - 1);
        
        descriptionText.text = imageDescriptions[currentIndex];

        titleText.text = imageTitle[currentIndex]; 
        
        var change = 0;
        for (item in itemGroup) {
            item.posX = change++ - currentIndex;
            item.alpha = item.ID == currentIndex ? 1 : 0.6;
        }
    }
}

class GalleryImage extends FlxSprite {
    public var posX:Float = 0;
    
    // Edit the 760 to change the distance between each image
    override function update(elapsed:Float) {
        super.update(elapsed);
        x = FlxMath.lerp(x, (FlxG.width - width) / 2 + posX * 760, CoolUtil.boundTo(elapsed * 3, 0, 1));
    }
}