package options;

import objects.Note;
import objects.StrumNote;
import objects.Alphabet;

class ExtrasState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Extras';
		rpcTitle = 'Extras Menu'; //for Discord Rich Presence

		/* //disabling for now
		var option:Option = new Option('Opponent Note Hit Glow',
			"If unchecked, the opponent strums will not play\nthe glow animation when hitting a note",
			'playHitAnim',
			'bool');
		addOption(option);
		*/
		var option:Option = new Option('Camera Movement',
			"If unchecked, the camera wont move when hitting notes",
			'camMovement',
			'bool');
		addOption(option);

		var option:Option = new Option('Fixed Sustain Animations',
			"If unchecked, the player hold animation fix will not take effect",
			'holdAnims',
			'bool');
		addOption(option);

		var option:Option = new Option('Song intro card',
			"If unchecked, the intro card will not appear when starting songs",
			'songIntroScript',
			'bool');
		addOption(option);

		var option:Option = new Option('Dark Mode',
			'Do you want to have Psych in Dark Mode?\n(No Flashes, Dark menu bg etc)\n(Wont work on some states because of some texts)',
			'darkMode',
			'bool');
		addOption(option);

		var option:Option = new Option('Discord Status',
			'Do you want your discord status to\nbe more advanced when playing a song?',
			'advancedDiscord',
			'bool');
		addOption(option);

		var option:Option = new Option('Combo Sprite',
			'Do you want the combo sprite to be shown?',
			'comboSprite',
			'bool');
		addOption(option);

		var option:Option = new Option('Smooth Health Bar',
			'Do you want your healthbar to be smooth?',
			'smoothHealth',
			'bool');
		addOption(option);

		var option:Option = new Option('Watermark',
			"If unchecked, There will NOT be a watermark in the\nbottom left of the screen during songs",
			'watermark',
			'bool');
		addOption(option);

		var option:Option = new Option('Title BG',
			"If checked, the title screen will have a background\nMay overlay the background set in gfDanceTitle.json",
			'backdropTitle',
			'bool');
		addOption(option);

		var option:Option = new Option('Strum Animation:',
			"How do you want the opponent stums\nto play their animation?",
			'strumAnim',
			'string',
			['BPM Based', 'Full Anim', 'None']);
		addOption(option);

		var option:Option = new Option('Menu Song:',
			"What song do you want to play\nwhen in the main menu?",
			'menuSong',
			'string',
			['Default', 'Tricky', 'Shaggy', 'Impostor', 'IC', 'DnB', 'Gapple']);
		addOption(option);
		
		var option:Option = new Option('Rating Type:',
			"What camera do you want your ratings to be on?\nOr do you want them to be invisible?",
			'ratingType',
			'string',
			['camHUD', 'camGame', 'Invisible']);
		addOption(option);

		var option:Option = new Option('Rating Texture:',
			"How do you want your ui to look?",
			'ratingTex',
			'string',
			['Default', 'Kade', 'MMPE', 'Forever', 'Voiid']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			"How do you want the icons to bop?",
			'iconBops',
			'string',
			['Psych', 'None', 'Base', 'Dave and Bambi', 'Golden Apple', 'Bouncy', 'OS']);
		addOption(option);

		var option:Option = new Option('Menu Button Placement:',
			'How do you want the menu buttons\nto be places?',
			'menuButtons',
			'string',
			['Middle', 'Left', 'Right']);
		addOption(option);

		var option:Option = new Option('Lane Underlay Visibility',
			'Sets visibility of lane underlay.',
			'underlaneVisibility',
			'percent');
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
/*
		var option:Option = new Option('Rating Style:',
			"What style do you want your ratings to be like?",
			'ratingStyle',
			'string',
			['Psych', 'Other']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			'How should your icons bounce?',
			'iconBounce',
			'string',
			['Default', 'Golden Apple', 'OS', 'Stretchy']);
		addOption(option);
*/
		super();
	}
}
