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

		var option:Option = new Option('Note Hold Splash Opacity',
			'How much transparent should the Note Hold Splashes be.',
			'holdSplashAlpha',
			PERCENT);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option('Low Detail Mode',
			"If checked, the game will run in low detail mode\nor a 'performance mode' to help memory\n(STILL EXPERIMENTAL)",
			'ldm',
			BOOL);
		addOption(option);

		var option:Option = new Option('Miss Sounds',
			"If checked, missing a note will play missed note sound effects.",
			'missSounds',
			BOOL);
		addOption(option);

		var option:Option = new Option('Bad Sounds',
			"If checked, sounds will play when getting a bad rating",
			'badSounds',
			BOOL);
		addOption(option);

		var option:Option = new Option('Camera Movement',
			"If unchecked, the camera wont move when hitting notes",
			'camMovement',
			BOOL);
		addOption(option);

		var option:Option = new Option('Old Sustain Animations',
			"If checked, the characters will studder when doing HOLD notes\nlike old FNF before the WEEKEND update",
			'oldHold',
			BOOL);
		addOption(option);

		/* Gone but not forgotten. May you rest in peace Song Intro Card. 
		var option:Option = new Option('Song intro card',
			"If unchecked, the intro card will not appear when starting songs",
			'songIntroScript',
			BOOL);
		addOption(option);
		*/

		var option:Option = new Option('Dark Mode',
			'Do you want to have Psych in Dark Mode?\n(No Flashes, Dark menu bg etc)\n(Wont work on some states because of some texts)',
			'darkMode',
			BOOL);
		addOption(option);

		var option:Option = new Option('Discord Status',
			'Do you want your discord status to\nbe more advanced when playing a song?',
			'advancedDiscord',
			BOOL);
		addOption(option);

		var option:Option = new Option('Combo Sprite',
			'Do you want the combo sprite to be shown?',
			'comboSprite',
			BOOL);
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes',
			"If checked, the opponent will have note splashes\njust like the player. (Transparency will be the same)",
			'oppSplashes',
			BOOL);
		addOption(option);

		/*
		var option:Option = new Option('UI Version:',
			"What do you want the UI to be?",
			'uilook',
			STRING,
			['Psych', 'Base', 'Dave', 'Forever', 'Gapple']);
		addOption(option);
		*/

		var option:Option = new Option('Hitsound Version:',
			"How do you want the hitsounds to sound?\nRequires the hitsound volume option to be higher than 0",
			'hitsounds',
			STRING,
			['Psych', 'Dave', 'Switch', 'IndieC', 'Snap']);
		addOption(option);

		var option:Option = new Option('Menu Song:',
			"What song do you want to play\nwhen in the main menu?",
			'menuSong',
			STRING,
			['Default', 'Tricky', 'Shaggy', 'Impostor', 'IC', 'DnB', 'Gapple', 'Neo']);
		addOption(option);
		
		var option:Option = new Option('Rating Type:',
			"What camera do you want your ratings to be on?\nOr do you want them to be invisible?",
			'ratingType',
			STRING,
			['camHUD', 'camGame', 'Invisible']);
		addOption(option);

		var option:Option = new Option('Rating Texture:',
			"How do you want your ui to look?",
			'ratingTex',
			STRING,
			['Default', 'Kade', 'MMPE', 'Forever', 'Voiid', 'Dave and Bambi 3D', 'Golden Apple 3D', 'Sonic.exe', 'Mario Madness', 'Neo']);
		addOption(option);

		var option:Option = new Option('Icon Bounce:',
			"How do you want the icons to bop?",
			'iconBops',
			STRING,
			['Psych', 'None', 'OG', 'Dave and Bambi', 'Golden Apple', 'Stretchy', 'OS']);
		addOption(option);
		
		super();
	}
}
