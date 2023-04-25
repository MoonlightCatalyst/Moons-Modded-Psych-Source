package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class ExtrasState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Extras';
		rpcTitle = 'Extras Menu'; //for Discord Rich Presence

		var option:Option = new Option('Opponent Note Hit Glow',
			"If unchecked, the opponent strums will not play\nthe glow animation when hitting a note",
			'opptStaticArrows',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Camera Movement',
			"If unchecked, the camera wont move when hitting notes",
			'camMovement',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Fixed Sustain Animations',
			"If unchecked, the player hold animation fix will not take effect",
			'holdAnims',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Song intro card',
			"If unchecked, the intro card will not appear when starting songs",
			'songIntroScript',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Combo Sprite',
			"If unchecked, The combo sprite will NOT appear",
			'comboSprite',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Watermark',
			"If unchecked, There will NOT be a watermark in the\nbottom left of the screen during songs",
			'watermark',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Title Menu Background', //fuck you OS I'm stealing this too :troll:
			"Do you want the title screen to have\na background?",
			'backdropTitle',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Discord Presence', //fuck you OS I'm stealing this too :troll:
			"Do you want to have a detailed discord presence\nwhen playing a song?",
			'discordShit',
			'bool',
			false);
		addOption(option);

/* shit stopped working (Fuck you OS engine)
		var option:Option = new Option('Themed Main Menu Background',
			'If checked, the background color of the main menu depends on the time of day.',
			'themedmainmenubg',
			'bool',
			false);
		option.defaultValue = false;
		addOption(option);
/*
		var option:Option = new Option('Rating Style:',
			'How should your ratings look?',
			'ratingStyle',
			'string',
			'Default',
			['Default', 'OG', 'Kade Old', 'Kade New', 'impostor', 'void']);
		addOption(option);
*/
		var option:Option = new Option('Note Skin', //Definitly not just stealing from OS now :troll:
			"What note skin do you prefer for playing?",
			'noteSkinSettings',
			'string',
			'Classic',
			['Classic', 'Circle', '3d', 'Hex', 'Holofunk', 'Stepmania']);
		addOption(option);

		var option:Option = new Option('Note Splash Texture:',
			'What note splash style do \n you want to use?',
			'splashTex',
			'string',
			'Default',
			['Default', 'Base Game', 'Impostor', 'Indie Cross', 'Forever']);
		addOption(option);
		
		var option:Option = new Option('Rating Camera:',
			"What type of camera type do you prefer \n the ratings to be on?",
			'ratingCameraType',
			'string',
			'camHUD',
			['camHUD', 'camGame', 'camOther']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			'How should your icons bounce?',
			'iconBounce',
			'string',
			'Default',
			['Default', /*'Golden Apple',*/ 'OS', 'Strident Crisis']);
		addOption(option);

		var option:Option = new Option('Menu Button Placement:',
			'How do you want the menu buttons\nto be places?',
			'buttonsStuff',
			'string',
			'Left',
			['Centered', 'Left', 'Right']);
		addOption(option);

		/*
		var option:Option = new Option('Opponent Lane Underlay Visibility',
			'Sets visibility of opponent\'s lane underlay.',
			'opponentUnderlaneVisibility',
			'percent',
			0);
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
*/
		var option:Option = new Option('Lane Underlay Visibility',
			'Sets visibility of lane underlay.',
			'underlaneVisibility',
			'percent',
			0);
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;

		super();
	}
}
