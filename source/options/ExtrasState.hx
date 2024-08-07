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

		var option:Option = new Option('Random Menu Shenanigans',
			"If checked, random little things will appear on the main menu",
			'randomMenuThings',
			'bool');
		addOption(option);

		var option:Option = new Option('Freeplay Search Bar',
			"If checked, there will be a search bar\nin the freeplay menu",
			'freeplaySearch',
			'bool');
		addOption(option);
*/
		var option:Option = new Option('Low Detail Mode',
			"If checked, the game will run in low detail mode\nor a 'performance mode' to help memory\n(STILL EXPERIMENTAL)",
			'ldm',
			'bool');
		addOption(option);

		var option:Option = new Option('Miss Sounds',
			"If checked, missing a note will play missed note sound effects.",
			'missSounds',
			'bool');
		addOption(option);

		var option:Option = new Option('Bad Sounds',
			"If checked, sounds will play when getting a bad rating",
			'badSounds',
			'bool');
		addOption(option);

		var option:Option = new Option('Camera Movement',
			"If unchecked, the camera wont move when hitting notes",
			'camMovement',
			'bool');
		addOption(option);

		var option:Option = new Option('Old Sustain Animations',
			"If checked, the characters will studder when doing HOLD notes\nlike old FNF before the WEEKEND update",
			'oldHold',
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

		/*
		var option:Option = new Option('Smooth Health Bar',
			'Do you want your healthbar to be smooth?',
			'smoothHealth',
			'bool');
		addOption(option);
		*/

		var option:Option = new Option('Opponent Note Splashes',
			"If checked, the opponent will have note splashes\njust like the player. (Transparency will be the same)",
			'oppSplashes',
			'bool');
		addOption(option);

		var option:Option = new Option('UI Version:',
			"What do you want the UI to be?",
			'uilook',
			'string',
			['Psych', 'Base', 'Dave', 'Forever', 'Gapple']);
		addOption(option);

		var option:Option = new Option('Hitsound Version:',
			"How do you want the hitsounds to sound?\nRequires the hitsound volume option to be higher than 0",
			'hitsounds',
			'string',
			['Psych', 'Dave', 'Switch', 'IndieC']);
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
			['Default', 'Tricky', 'Shaggy', 'Impostor', 'IC', 'DnB', 'Gapple', 'Neo']);
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
			['Default', 'Kade', 'MMPE', 'Forever', 'Voiid', 'Dave and Bambi 3D', 'Golden Apple 3D', 'Sonic.exe', 'Mario Madness', 'Neo']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			"How do you want the icons to bop?",
			'iconBops',
			'string',
			['Psych', 'None', 'OG', 'Dave and Bambi', 'Golden Apple', 'Stretchy', 'OS']);
		addOption(option);

		var option:Option = new Option('Menu Button Placement:',
			'How do you want the menu buttons\nto be places?',
			'menuButtons',
			'string',
			['Middle', 'Left', 'Right']);
		addOption(option);

		var option:Option = new Option('Lane Underlay Visibility:',
			'Sets visibility of lane underlay.',
			'underlaneVisibility',
			'percent');
		addOption(option);	
		option.scrollSpeed = 1;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		
		super();
	}
}
