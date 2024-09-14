package states;

import backend.Highscore;
import backend.StageData;
import backend.WeekData;
import backend.Song;
import backend.Section;
import backend.Rating;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import openfl.events.KeyboardEvent;
import haxe.Json;

import cutscenes.CutsceneHandler;
import cutscenes.DialogueBoxPsych;

import states.StoryMenuState;
import states.FreeplayState;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;

import substates.PauseSubState;
import substates.GameOverSubstate;

#if !flash
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import Shaders;
import openfl.filters.BitmapFilter;

#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import objects.Note.EventNote;
import objects.*;
import states.stages.objects.*;

#if LUA_ALLOWED
import psychlua.*;
#else
import psychlua.LuaUtils;
import psychlua.HScript;
#end

#if SScript
import tea.SScript;
#end

import flixel.group.FlxSpriteGroup;
import StringTools; // idk if psych imports it automatically
import objects.NoteSplash.PixelSplashShader;

//hold splash
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import objects.BGSprite;
import shaders.RGBPalette;
import objects.NoteSplash.PixelSplashShaderRef;
import flixel.math.FlxRect;
//

//visualizer
import haxe.io.UInt16Array;
import lime.media.AudioSource;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.graphics.frames.FlxAtlasFrames;
//

//hud shit
import haxe.ds.StringMap;
import openfl.text.TextFormat;

//forever

import states.MainMenuState;
import backend.Difficulty;
import backend.CoolUtil;

import Main;
//

/**
 * This is where all the Gameplay stuff happens and is managed
 *
 * here's some useful tips if you are making a mod in source:
 *
 * If you want to add your stage to the game, copy states/stages/Template.hx,
 * and put your stage code there, then, on PlayState, search for
 * "switch (curStage)", and add your stage to that list.
 *
 * If you want to code Events, you can either code it on a Stage file or on PlayState, if you're doing the latter, search for:
 *
 * "function eventPushed" - Only called *one time* when the game loads, use it for precaching events that use the same assets, no matter the values
 * "function eventPushedUnique" - Called one time per event, use it for precaching events that uses different assets based on its values
 * "function eventEarlyTrigger" - Used for making your event start a few MILLISECONDS earlier
 * "function triggerEvent" - Called when the song hits your event's timestamp, this is probably what you were looking for
**/
class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	//event variables
	private var isCameraOnForcedPos:Bool = false;

	public var boyfriendMap:Map<String, Character> = new Map<String, Character>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	public var variables:Map<String, Dynamic> = new Map<String, Dynamic>();

	#if HSCRIPT_ALLOWED
	public var hscriptArray:Array<HScript> = [];
	public var instancesExclude:Array<String> = [];
	#end

	#if LUA_ALLOWED
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, FlxText> = new Map<String, FlxText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var playbackRate(default, set):Float = 1;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var stageUI:String = "normal";
	public static var isPixelStage(get, never):Bool;

	@:noCompletion
	static function get_isPixelStage():Bool
		return stageUI == "pixel" || stageUI.endsWith("-pixel");

	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var spawnTime:Float = 2000;

	public var inst:FlxSound;
	public var vocals:FlxSound;
	public var opponentVocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Character = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	public var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public var grpHoldSplashes:FlxTypedGroup<SustainSplash>;

	public var camZooming:Bool = false;
	public var camZoomingMult:Float = 1;
	public var camZoomingDecay:Float = 1;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health(default, set):Float = 1;
	public var combo:Int = 0;

	public var healthBar:Bar;
	public var timeBar:Bar;
	var songPercent:Float = 0;

	public var ratingsData:Array<Rating> = Rating.loadDefault();

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;

	public var guitarHeroSustains:Bool = false;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	//lua shader shit
	public var shaderUpdates:Array<Float->Void> = [];
	public var camGameShaders:Array<ShaderEffect> = [];
	public var camHUDShaders:Array<ShaderEffect> = [];
	public var camOtherShaders:Array<ShaderEffect> = [];

	//Gameplay settings
	public var hpDrainLevel:Float = 1;
	public var opponentDrain:Bool = false;
	var dancingLeft:Bool = false;
	var flip:Bool = false;
	var randomMode:Bool = false;
	var stairs:Bool = false;
	var waves:Bool = false;
	var oneK:Bool = false;
	var jackass:Bool = false;
	var shoot:FlxSound;
	var death:FlxSound;
	public var polyphony:Float = 1;

	//cum

	public var laneunderlay:FlxSprite;

	#if DISCORD_ALLOWED
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Int> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	#if LUA_ALLOWED public var luaArray:Array<FunkinLua> = []; #end

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	private var luaDebugGroup:FlxTypedGroup<psychlua.DebugLuaText>;
	#end
	public var introSoundsSuffix:String = '';

	// Less laggy controls
	private var keysArray:Array<String>;
	public var songName:String;

	// Callbacks for stages
	public var startCallback:Void->Void = null;
	public var endCallback:Void->Void = null;

	//abot stuff
	var abotEyess:Float = 0;
	var abotEyes:FlxAnimate; //don't get the two mixed, one is a float while the other is the animate sprite
	var abot:FlxAnimate; //don't get the two mixed, one is a float while the other is the animate sprite

	var tmr1:FlxTimer;
	var tmr2:FlxTimer;
	//

	var ogCamZoom:Float = 0;

	//visualizer
	var musicSrc:AudioSource;
	var data:lime.utils.UInt16Array;
	var debugText:FlxText;
	var musicList:Array<String> = [];
	//

	//hud shitsssss

	var kadeEngineWatermark:FlxText;
	var creditsWatermark:FlxText;

	var ogIconSize:Array<Array<Int>> = [];
	
	var credits:StringMap<String> = [
		// add your mod songs below! i, tehpuertoricanspartan, left an example. you can remove it if you want. if you have problems with the map, take a hint from the song name to the left
		"test" => "what? it's a test song",
	];
	//
	//Forever
	var ranks:Array<Dynamic> = [
		[100, 'S+'],
		[95, 'S'],
		[90, 'A'],
		[85, 'B'],
		[80, 'C'],
		[75, 'D'],
		[70, 'E']
	];
	
	var counter:FlxText;
	var autoplayMark:FlxText;
	
	var sine:Float = 0;
	
	var camStrums:FlxCamera;
	
	var oldUpdate = null;
	var memPeak:Float = 0;
	//

	// while most can be just .toLowerCase, i feel you can just change them yourself anyway
	public var rateNames:Array<String> = [
		'sick',
		'good',
		'bad',
		'shit'
	];
	public var ratingDirectories:Map<String, String> = [
		'Kade' => 'kade',
		'MMPE' => 'custom',
		'Forever' => 'forever',
		'Voiid' => 'voiid',
		'Dave and Bambi 3D' => 'dambi',
		'Golen Apple 3D' => 'grapple',
		'Sonic.exe' => 'sonic.exe',
		'Mario Madness' => 'mario madness',
		'Neo' => 'neo'
	];

	var ogIconBounce:String;

	override public function create()
	{
		//trace('Playback Rate: ' + playbackRate);
		Paths.clearStoredMemory();

		startCallback = startCountdown;
		endCallback = endSong;

		// for lua
		instance = this;

		PauseSubState.songName = null; //Reset to default
		playbackRate = ClientPrefs.getGameplaySetting('songspeed');

		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain');
		healthLoss = ClientPrefs.getGameplaySetting('healthloss');
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill');
		practiceMode = ClientPrefs.getGameplaySetting('practice');
		cpuControlled = ClientPrefs.getGameplaySetting('botplay');
		randomMode = ClientPrefs.getGameplaySetting('randommode');
		opponentDrain = ClientPrefs.getGameplaySetting('opponentdrain');
		flip = ClientPrefs.getGameplaySetting('flip');
		stairs = ClientPrefs.getGameplaySetting('stairmode');
		waves = ClientPrefs.getGameplaySetting('wavemode');
		oneK = ClientPrefs.getGameplaySetting('onekey');
		jackass = ClientPrefs.getGameplaySetting('jackass');
		hpDrainLevel = ClientPrefs.getGameplaySetting('drainlevel');
		guitarHeroSustains = ClientPrefs.data.guitarHeroSustains;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = initPsychCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camOther, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		grpHoldSplashes = new FlxTypedGroup<SustainSplash>();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.bpm = SONG.bpm;


		#if DISCORD_ALLOWED
		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		storyDifficultyText = Difficulty.getString();

		if (isStoryMode)
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		else
			detailsText = "Freeplay";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		songName = Paths.formatToSongPath(SONG.song);
		if(SONG.stage == null || SONG.stage.length < 1) {
			SONG.stage = StageData.vanillaSongStage(songName);
		}
		curStage = SONG.stage;

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = StageData.dummy();
		}

		defaultCamZoom = stageData.defaultZoom;

		stageUI = "normal";
		if (stageData.stageUI != null && stageData.stageUI.trim().length > 0)
			stageUI = stageData.stageUI;
		else {
			if (stageData.isPixelStage)
				stageUI = "pixel";
		}

		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'stage': new states.stages.StageWeek1(); //Week 1
			case 'spooky': new states.stages.Spooky(); //Week 2
			case 'philly': new states.stages.Philly(); //Week 3
			case 'limo': new states.stages.Limo(); //Week 4
			case 'mall': new states.stages.Mall(); //Week 5 - Cocoa, Eggnog
			case 'mallEvil': new states.stages.MallEvil(); //Week 5 - Winter Horrorland
			case 'school': new states.stages.School(); //Week 6 - Senpai, Roses
			case 'schoolEvil': new states.stages.SchoolEvil(); //Week 6 - Thorns
			case 'tank': new states.stages.Tank(); //Week 7 - Ugh, Guns, Stress
			case 'phillyStreets': new states.stages.PhillyStreets(); //Weekend 1 - Darnell, Lit Up, 2Hot, Blazin
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup);
		add(dadGroup);
		add(boyfriendGroup);

		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		luaDebugGroup = new FlxTypedGroup<psychlua.DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		// "GLOBAL" SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'scripts/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		// STAGE SCRIPTS
		#if LUA_ALLOWED
		startLuasNamed('stages/' + curStage + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		startHScriptsNamed('stages/' + curStage + '.hx');
		#end

		if (!stageData.hide_girlfriend)
		{
			if(SONG.gfVersion == null || SONG.gfVersion.length < 1) SONG.gfVersion = 'gf'; //Fix for the Chart Editor
			gf = new Character(0, 0, SONG.gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterScripts(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterScripts(dad.curCharacter);

		boyfriend = new Character(0, 0, SONG.player1, true);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterScripts(boyfriend.curCharacter);

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}
		stagesFunc(function(stage:BaseStage) stage.createPost());

		comboGroup = new FlxSpriteGroup();
		add(comboGroup);
		noteGroup = new FlxTypedGroup<FlxBasic>();
		add(noteGroup);
		uiGroup = new FlxSpriteGroup();
		add(uiGroup);

		laneunderlay = new FlxSprite(0, 0).makeGraphic(110 * 4 + 50, FlxG.height * 2);
		laneunderlay.color = FlxColor.BLACK;
		laneunderlay.scrollFactor.set();
        laneunderlay.alpha = ClientPrefs.data.underlaneVisibility - 1;
        laneunderlay.visible = true;
	  	//add(laneunderlay);
		insert(1, laneunderlay);

		Conductor.songPosition = -5000 / Conductor.songPosition;
		var showTime:Bool = (ClientPrefs.data.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = updateTime = showTime;
		if(ClientPrefs.data.downScroll) timeTxt.y = FlxG.height - 44;
		if(ClientPrefs.data.timeBarType == 'Song Name') timeTxt.text = SONG.song;

		timeBar = new Bar(0, timeTxt.y + (timeTxt.height / 4), 'timeBar', function() return songPercent, 0, 1);
		timeBar.scrollFactor.set();
		timeBar.screenCenter(X);
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		uiGroup.add(timeBar);
		uiGroup.add(timeTxt);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		noteGroup.add(strumLineNotes);

		if(ClientPrefs.data.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.000001; //cant make it invisible or it won't allow precaching

		SustainSplash.startCrochet = Conductor.stepCrochet;
		SustainSplash.frameRate = Math.floor(24 / 100 * SONG.bpm);
		SustainSplash.isPixelStage = isPixelStage;
		var splash:SustainSplash = new SustainSplash();
		grpHoldSplashes.add(splash);
		splash.alpha = 0.0001;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		noteGroup.add(grpHoldSplashes);
		noteGroup.add(grpNoteSplashes);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		camPos.put();

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.snapToTarget();

		ogCamZoom = defaultCamZoom;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		moveCameraSection();

		healthBar = new Bar(0, FlxG.height * (!ClientPrefs.data.downScroll ? 0.89 : 0.11), 'healthBar', function() return health, 0, 2);
		healthBar.screenCenter(X);
		healthBar.leftToRight = false;
		healthBar.scrollFactor.set();
		healthBar.visible = !ClientPrefs.data.hideHud;
		healthBar.alpha = ClientPrefs.data.healthBarAlpha;
		reloadHealthBarColors();
		uiGroup.add(healthBar);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.data.hideHud;
		iconP1.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.data.hideHud;
		iconP2.alpha = ClientPrefs.data.healthBarAlpha;
		uiGroup.add(iconP2);

		scoreTxt = new FlxText(0, healthBar.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.data.hideHud;
		updateScore(false);
		uiGroup.add(scoreTxt);

		botplayTxt = new FlxText(400, timeBar.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		uiGroup.add(botplayTxt);
		if(ClientPrefs.data.downScroll)
			botplayTxt.y = timeBar.y - 78;

		uiGroup.cameras = [camHUD];
		noteGroup.cameras = [camHUD];
		comboGroup.cameras = [camHUD];

		laneunderlay.cameras = [camHUD];

		startingSong = true;

		#if LUA_ALLOWED
		for (notetype in noteTypes)
			startLuasNamed('custom_notetypes/' + notetype + '.lua');
		for (event in eventsPushed)
			startLuasNamed('custom_events/' + event + '.lua');
		#end

		#if HSCRIPT_ALLOWED
		for (notetype in noteTypes)
			startHScriptsNamed('custom_notetypes/' + notetype + '.hx');
		for (event in eventsPushed)
			startHScriptsNamed('custom_events/' + event + '.hx');
		#end
		noteTypes = null;
		eventsPushed = null;

		if(eventNotes.length > 1)
		{
			for (event in eventNotes) event.strumTime -= eventEarlyTrigger(event);
			eventNotes.sort(sortByTime);
		}

		// SONG SPECIFIC SCRIPTS
		#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'data/$songName/'))
			for (file in FileSystem.readDirectory(folder))
			{
				#if LUA_ALLOWED
				if(file.toLowerCase().endsWith('.lua'))
					new FunkinLua(folder + file);
				#end

				#if HSCRIPT_ALLOWED
				if(file.toLowerCase().endsWith('.hx'))
					initHScript(folder + file);
				#end
			}
		#end

		startCallback();
		RecalculateRating();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);

		//PRECACHING THINGS THAT GET USED FREQUENTLY TO AVOID LAGSPIKES
		if(ClientPrefs.data.hitsoundVolume > 0) Paths.sound('hitsounds/hitsound-' + ClientPrefs.data.hitsounds);
		for (i in 1...4) Paths.sound('missnote$i');
		Paths.image('alphabet');

		if (PauseSubState.songName != null)
			Paths.music(PauseSubState.songName);
		else if(Paths.formatToSongPath(ClientPrefs.data.pauseMusic) != 'none')
			Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic));

		resetRPC();

		callOnScripts('onCreatePost');

		cacheCountdown();
		cachePopUpScore();

		super.create();
		Paths.clearUnusedMemory();

		timeBar.setColors(0xFFB200FF, 0xFF404040);

		//Optimizations were finally done. Thanks pumpsuki :3
		if (!PlayState.isPixelStage && ClientPrefs.data.ratingTex != 'Default') {
			final yes:String = ClientPrefs.data.ratingTex;
			for (i in 0...3) {
				ratingsData[i].image = 'ratings/${ratingDirectories.get(yes)}/${rateNames[i]}';
				if ((yes == 'Forever' && i != 0) || (yes == 'Voiid' && (i == 1 || i == 2))) {
					ratingsData[i].image = 'ratings/default/${rateNames[i]}';
				}
			}
		}

		if(eventNotes.length < 1) checkEventNote();
		
		if(gf.curCharacter == 'nene') {
			var stBg:BGSprite = new BGSprite('stereo/stereoBG', gf.x + 18, gf.y + 318, 1, 1);
			stBg.scale.set(1.05, 1.05);
			stBg.x = gf.x + 18;
			stBg.y = gf.y + 318;
			stBg.alpha = 1;
			addBehindGF(stBg);

			var eyesBg = new FlxSprite(0, 0).makeGraphic(110,70,FlxColor.WHITE);
			eyesBg.x = gf.x - 80;
			eyesBg.y = gf.y + 550;
			addBehindGF(eyesBg);

			abotEyes = new FlxAnimate();
			Paths.loadAnimateAtlas(abotEyes, 'stereo/systemEyes');
			abotEyes.anim.addBySymbolIndices('l', 'a bot eyes lookin', [0, 1, 2, 3, 10, 11, 12, 13], 24, false);
			abotEyes.anim.addBySymbolIndices('r', 'a bot eyes lookin', [13, 12, 11, 10, 3, 2, 1, 0], 24, false);
			abotEyes.x = gf.x - 640;
			abotEyes.y = gf.y - 175;
			addBehindGF(abotEyes);

			abot = new FlxAnimate();
			Paths.loadAnimateAtlas(abot, 'stereo/abotSystem');
			//sprite.anim.addBySymbol('name', 'symbolName', frameRate, looped, X, Y);
			abot.anim.addBySymbolIndices('i', 'Abot System', [0, 1, 2, 3, 4], 24, false);
			abot.x = gf.x - 133;
			abot.y = gf.y + 310;
			addBehindGF(abot);
		}

		ogIconBounce = ClientPrefs.data.iconBops;

		if(ClientPrefs.data.uilook == 'Base') {
			for (hud in [timeBar, timeTxt]) hud.kill();

			healthBar.leftBar.color = 0xFF0000;
    		healthBar.rightBar.color = 0xFF66FF33;

			if (!ClientPrefs.data.middleScroll)
			{
				for (i in 0...strumLineNotes.length)
				{
					strumLineNotes.members[i].x -= 42;
				}
			}

			healthBar.bg.y = (ClientPrefs.data.downScroll ? FlxG.height * 0.1 : FlxG.height * 0.9);
    		healthBar.x += 4;
    		healthBar.y += 4;

    		iconP1.y = healthBar.y - (iconP1.height / 1.9);
    		iconP2.y = healthBar.y - (iconP2.height / 1.9);

    		scoreTxt.fieldWidth = 0;
    		scoreTxt.x = healthBar.bg.x + healthBar.bg.width - 190;
    		scoreTxt.y = healthBar.bg.y + 30;
    		scoreTxt.size = 16;
    		scoreTxt.alignment = 'right'; // I THINK THIS WORKS?????
		}
		if(ClientPrefs.data.uilook == 'Dave') {

			Main.fpsVar.defaultTextFormat = new TextFormat(Paths.font('comic.ttf'), 15, FlxColor.WHITE, true);

			ClientPrefs.data.iconBops = 'Dave and Bambi'; //had to use this cuz apparently it doesn't work just by itself
		
			timeBar.alpha = 1;
			timeTxt.visible = true;
			timeTxt.alpha = 1;
		
			var bars:Array<Dynamic> = [healthBar, timeBar];
			for (i in bars) {
				i.set_barWidth(i.bg.width - 8);
				i.set_barHeight(i.bg.height - 8);
				i.barOffset.set(4, 4);
				i.screenCenter(X);
			}
			healthBar.y = (ClientPrefs.data.downScroll ? 50 : FlxG.height * 0.9);
			iconP1.y = healthBar.y - (iconP1.height / 2);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			timeBar.y = (ClientPrefs.data.downScroll ? (FlxG.height * 0.9) + 20 : 30);
		
			var xValues = getMinAndMax(timeTxt.width, timeBar.width);
			var yValues = getMinAndMax(timeTxt.height, timeBar.height);
			timeTxt.setFormat(Paths.font("comic.ttf"), 32 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.x = timeBar.x - ((xValues[0] - xValues[1]) / 2);
			timeTxt.y = timeBar.y + ((timeBar.height / 2) - (timeTxt.height / 2));
			timeTxt.borderSize = 2.5 * 1;
			timeBar.leftBar.color = 0xFF37FF14;
			timeBar.rightBar.color = 0xFF808080;
		
			scoreTxt.y = healthBar.y + 40;
			scoreTxt.setFormat(Paths.font("comic.ttf"), 20 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.5 * 1;
		
			botplayTxt.y = healthBar.bg.y + (ClientPrefs.data.downScroll ? 100 : -100);
			botplayTxt.setFormat(Paths.font("comic.ttf"), 42 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplayTxt.borderSize = 2.5 * 1;
		
			var songName = PlayState.SONG.song;
			kadeEngineWatermark = new FlxText(4, healthBar.bg.y + (credits.get(songName) != null ? 30 : 50), 0, songName);
			kadeEngineWatermark.setFormat(Paths.font("comic.ttf"), 16 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			kadeEngineWatermark.borderSize = 1.25 * 1;
			kadeEngineWatermark.camera = camHUD;
			add(kadeEngineWatermark);
		
			if (credits.get(songName) != null) {
				creditsWatermark = new FlxText(4, healthBar.bg.y + 50, 0, credits.get(songName));
				creditsWatermark.setFormat(Paths.font("comic.ttf"), 16 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				creditsWatermark.borderSize = 1.25 * 1;
				creditsWatermark.camera = camHUD;
				add(creditsWatermark);
			}

			healthBar.bg.loadGraphic(Paths.image('healthBarDave'));
			//timeBar.bg.loadGraphic(Paths.image('timeBarDave'));
			//botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		}
		if(ClientPrefs.data.uilook == 'Forever') {
			oldUpdate = Main.fpsVar.updateText;

    		timeTxt.kill();
    		timeBar.kill();

    		healthBar.y = ClientPrefs.data.downScroll ? 64 : FlxG.height * 0.875;

    		iconP1.y = iconP2.y = healthBar.y - 75;

    		scoreTxt.y = Math.floor(healthBar.y + 40);
    		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
    		scoreTxt.size = 18;

    		var cornerMark:FlxText = new FlxText(0, 0, 0, 'PSYCH ENGINE v' + MainMenuState.psychEngineVersion);
    		cornerMark.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE);
    		cornerMark.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
    		cornerMark.cameras = [camHUD];
    		cornerMark.active = false;
    		add(cornerMark);

    		var centerMark:FlxText = new FlxText(0, ClientPrefs.data.downScroll ? FlxG.height - 40 : 10,
    		0, '- ' + StringTools.replace(PlayState.SONG.song, '-', ' ') + ' [' + Difficulty.getString().toUpperCase() + '] -' );
    		centerMark.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE);
   			centerMark.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
    		centerMark.screenCenter(X);
    		centerMark.cameras = [camHUD];
    		centerMark.active = false;
    		add(centerMark);

    		if (cpuControlled) {
    		    botplayTxt.visible = false;

    		    autoplayMark = new FlxText(-5, ClientPrefs.data.downScroll ? centerMark.y - 60 : centerMark.y + 60, FlxG.width - 800);
    		    autoplayMark.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, 'center', FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    		    autoplayMark.borderSize = 2;
    		    autoplayMark.text = '[AUTOPLAY]';
    		    autoplayMark.screenCenter();
       			autoplayMark.cameras = [camHUD];
        		autoplayMark.active = false;
        		add(autoplayMark);

        		if (ClientPrefs.data.middleScroll) {
        		    autoplayMark.y = (ClientPrefs.data.downScroll ? autoplayMark.y - 125 : autoplayMark.y + 125);
       			}
    		}

			/*
    		counter = new FlxText(5 + ('left' ? 0 : FlxG.width - 90), FlxG.height * 0.5, 0);
    		counter.setFormat(Paths.font('vcr.ttf'), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    		counter.cameras = [camHUD];
    		counter.active = false;
    		add(counter);
    		updateJudgementCounter();
			*/

        	for (cam in [camHUD, camOther]) FlxG.cameras.remove(cam, false);

        	camStrums = new FlxCamera();
        	camStrums.bgColor = FlxColor.TRANSPARENT;

        	for (cam in [camHUD, camStrums, camOther]) FlxG.cameras.add(cam, false);
        	for (strum in strumLineNotes) strum.cameras = [camStrums];
        	for (note in unspawnNotes) if (!note.isSustainNote) note.cameras = [camStrums];

        	grpNoteSplashes.cameras = [camStrums];
			grpHoldSplashes.cameras = [camStrums];

    		updateIconsScale = (elapsed:Float) -> {
        		var lerp:Float = 1 - fpsAdjust(.15) * playbackRate;
        		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, lerp);
        		var multP2:Float = FlxMath.lerp(1, iconP2.scale.x, lerp);

        		iconP1.scale.set(mult, mult);
        		iconP1.updateHitbox();

        		iconP2.scale.set(multP2, multP2);
        		iconP2.updateHitbox();

        		iconP1.origin.set(50, 0);
        		iconP2.origin.set(80, 0);
    		}
    
    		Main.fpsVar.defaultTextFormat = new TextFormat('VCR OSD Mono', 18, 0xFFFFFF);
    		Main.fpsVar.x = Main.fpsVar.y = 0;

    		Main.fpsVar.updateText = () -> {
        	if (memPeak <= Main.fpsVar.memoryMegas) memPeak = Main.fpsVar.memoryMegas;

        	Main.fpsVar.text = Main.fpsVar.currentFPS + ' FPS\n' +
        	FlxStringUtil.formatBytes(Main.fpsVar.memoryMegas) + ' / ' + FlxStringUtil.formatBytes(memPeak); 
    	}

    	return;
		}
		if(ClientPrefs.data.uilook == 'Gapple') {
			ClientPrefs.data.iconBops = 'Golden Apple';
			Main.fpsVar.defaultTextFormat = new TextFormat(Paths.font('comic2.ttf'), 15, 0xFFFFFF, true);

			timeBar.visible = false;
			timeBar.bg.visible = false;

			timeTxt.setFormat(Paths.font('comic2.ttf'), 32 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeTxt.borderSize = 2.5 * 1;

			scoreTxt.y = healthBar.y + 40;
			scoreTxt.setFormat(Paths.font('comic2.ttf'), 20 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.borderSize = 1.5 * 1;

			botplayTxt.y = healthBar.bg.y + (ClientPrefs.data.downScroll ? 100 : -100);
			botplayTxt.setFormat(Paths.font('comic2.ttf'), 42 * 1, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botplayTxt.borderSize = 2.5 * 1;

			var healthOver:FlxSprite = new FlxSprite(healthBar.x, healthBar.y).loadGraphic(Paths.image("healthBarOverlay"));
			healthOver.cameras = [camHUD];
			healthOver.scale.set(1, 1);
			healthOver.alpha = 1;
			remove(iconP1);
			remove(iconP2);
			add(healthOver);
			add(iconP1);
			add(iconP2);

			var songName = PlayState.SONG.song;
			kadeEngineWatermark = new FlxText(4, healthBar.bg.y + (credits.get(songName) != null ? 30 : 50), 0, songName);
			kadeEngineWatermark.setFormat(Paths.font('comic2.ttf'), 16 * 1, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
			kadeEngineWatermark.borderSize = 1.25 * 1;
			kadeEngineWatermark.camera = camHUD;
			add(kadeEngineWatermark);

			if (credits.get(songName) != null) {
				creditsWatermark = new FlxText(4, healthBar.bg.y + 50, 0, credits.get(songName));
				creditsWatermark.setFormat(Paths.font('comic2.ttf'), 16 * 1, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
				creditsWatermark.borderSize = 1.25 * 1;
				creditsWatermark.camera = camHUD;
				add(creditsWatermark);
			}

		}

		if(ClientPrefs.data.ldm) {
			var newCam = new FlxCamera();
	    	newCam.bgColor = 0x00000000;

        	FlxG.cameras.add(newCam,false); 
			FlxG.cameras.remove(camGame,false);
			FlxG.cameras.remove(camHUD,false);
			FlxG.cameras.remove(camOther,false);

			//healthBar.cameras = [newCam];
			//healthBar.bg.cameras = [newCam];
			timeTxt.cameras = [newCam];
			scoreTxt.cameras = [newCam];

			iconP1.visible = false;
			iconP2.visible = false;
			timeBar.visible = false;
			timeBar.bg.visible = false;
			grpNoteSplashes.visible = false;
			camGame.visible = false;
			camHUD.visible = false;

        	for (i in 0...8) strumLineNotes.members[i].cameras = [newCam];
        	grpNoteSplashes.cameras = [newCam];
        	for (note in unspawnNotes) 
        	{
        	    note.cameras = [newCam];
        	    if (note.isSustainNote) note.cameras = [newCam];
        	};
			for (strumsz in opponentStrums) {
				strumsz.x -= 90000; //just generally offscreen
			}
			for (strums in playerStrums) {
				strums.x -= 315;
			}
		}
		if(isPixelStage) {
			for (note in unspawnNotes) {
				if(note.isSustainNote) {
					note.scale.x /= 1.5;
					note.alpha = 1;
					note.multAlpha = 1;
				}
			}
		}
	}

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		songSpeed = value;
		noteKillOffset = Math.max(Conductor.stepCrochet, 350 / songSpeed * playbackRate);
		return value;
	}

	function set_playbackRate(value:Float):Float
	{
		#if FLX_PITCH
		if(generatedMusic)
		{
			vocals.pitch = value;
			opponentVocals.pitch = value;
			FlxG.sound.music.pitch = value;

			var ratio:Float = playbackRate / value; //funny word huh
			if(ratio != 1)
			{
				for (note in notes.members) note.resizeByRatio(ratio);
				for (note in unspawnNotes) note.resizeByRatio(ratio);
			}
		}
		playbackRate = value;
		FlxG.animationTimeScale = value;
		Conductor.safeZoneOffset = (ClientPrefs.data.safeFrames / 60) * 1000 * value;
		setOnScripts('playbackRate', playbackRate);
		#else
		playbackRate = 1.0; // ensuring -Crow
		#end
		return playbackRate;
	}

	#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
	public function addTextToDebug(text:String, color:FlxColor) {
		var newText:psychlua.DebugLuaText = luaDebugGroup.recycle(psychlua.DebugLuaText);
		newText.text = text;
		newText.color = color;
		newText.disableTime = 6;
		newText.alpha = 1;
		newText.setPosition(10, 8 - newText.height);

		luaDebugGroup.forEachAlive(function(spr:psychlua.DebugLuaText) {
			spr.y += newText.height + 2;
		});
		luaDebugGroup.add(newText);

		Sys.println(text);
	}
	#end

	public function reloadHealthBarColors() {
		healthBar.setColors(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Character = new Character(0, 0, newCharacter, true);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterScripts(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterScripts(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterScripts(newGf.curCharacter);
				}
		}
	}

	function startCharacterScripts(name:String)
	{
		// Lua
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/$name.lua';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(luaFile);
		if(FileSystem.exists(replacePath))
		{
			luaFile = replacePath;
			doPush = true;
		}
		else
		{
			luaFile = Paths.getSharedPath(luaFile);
			if(FileSystem.exists(luaFile))
				doPush = true;
		}
		#else
		luaFile = Paths.getSharedPath(luaFile);
		if(Assets.exists(luaFile)) doPush = true;
		#end

		if(doPush)
		{
			for (script in luaArray)
			{
				if(script.scriptName == luaFile)
				{
					doPush = false;
					break;
				}
			}
			if(doPush) new FunkinLua(luaFile);
		}
		#end

		// HScript
		#if HSCRIPT_ALLOWED
		var doPush:Bool = false;
		var scriptFile:String = 'characters/' + name + '.hx';
		#if MODS_ALLOWED
		var replacePath:String = Paths.modFolders(scriptFile);
		if(FileSystem.exists(replacePath))
		{
			scriptFile = replacePath;
			doPush = true;
		}
		else
		#end
		{
			scriptFile = Paths.getSharedPath(scriptFile);
			if(FileSystem.exists(scriptFile))
				doPush = true;
		}

		if(doPush)
		{
			if(SScript.global.exists(scriptFile))
				doPush = false;

			if(doPush) initHScript(scriptFile);
		}
		#end
	}

	public function getLuaObject(tag:String, text:Bool=true):FlxSprite {
		#if LUA_ALLOWED
		if(modchartSprites.exists(tag)) return modchartSprites.get(tag);
		if(text && modchartTexts.exists(tag)) return modchartTexts.get(tag);
		if(variables.exists(tag)) return variables.get(tag);
		#end
		return null;
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String)
	{
		#if VIDEOS_ALLOWED
		inCutscene = true;

		var filepath:String = Paths.video(name);
		#if sys
		if(!FileSystem.exists(filepath))
		#else
		if(!OpenFlAssets.exists(filepath))
		#end
		{
			FlxG.log.warn('Couldnt find video file: ' + name);
			startAndEnd();
			return;
		}

		var video:VideoHandler = new VideoHandler();
			#if (hxCodec >= "3.0.0")
			// Recent versions
			video.play(filepath);
			video.onEndReached.add(function()
			{
				video.dispose();
				startAndEnd();
				return;
			}, true);
			#else
			// Older versions
			video.playVideo(filepath);
			video.finishCallback = function()
			{
				startAndEnd();
				return;
			}
			#end
		#else
		FlxG.log.warn('Platform not supported!');
		startAndEnd();
		return;
		#end
	}

	public function addShaderToCamera(cam:String,effect:ShaderEffect){//STOLE FROM ANDROMEDA
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud':
					camHUDShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camHUDShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camHUD.setFilters(newCamEffects);
			case 'camother' | 'other':
					camOtherShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camOtherShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camOther.setFilters(newCamEffects);
			case 'camgame' | 'game':
					camGameShaders.push(effect);
					var newCamEffects:Array<BitmapFilter>=[]; // IT SHUTS HAXE UP IDK WHY BUT WHATEVER IDK WHY I CANT JUST ARRAY<SHADERFILTER>
					for(i in camGameShaders){
					  newCamEffects.push(new ShaderFilter(i.shader));
					}
					camGame.setFilters(newCamEffects);
			default:
				if(modchartSprites.exists(cam)) {
					Reflect.setProperty(modchartSprites.get(cam),"shader",effect.shader);
				} else if(modchartTexts.exists(cam)) {
					Reflect.setProperty(modchartTexts.get(cam),"shader",effect.shader);
				} else {
					var OBJ = Reflect.getProperty(PlayState.instance,cam);
					Reflect.setProperty(OBJ,"shader", effect.shader);
				}
		}
  }

  public function removeShaderFromCamera(cam:String,effect:ShaderEffect){
		switch(cam.toLowerCase()) {
			case 'camhud' | 'hud': 
    			camHUDShaders.remove(effect);
    			var newCamEffects:Array<BitmapFilter>=[];
    			for(i in camHUDShaders){
    			  newCamEffects.push(new ShaderFilter(i.shader));
    			}
    			camHUD.setFilters(newCamEffects);
			case 'camother' | 'other': 
				camOtherShaders.remove(effect);
				var newCamEffects:Array<BitmapFilter>=[];
				for(i in camOtherShaders){
					newCamEffects.push(new ShaderFilter(i.shader));
				}
				camOther.setFilters(newCamEffects);
			default: 
			camGameShaders.remove(effect);
			var newCamEffects:Array<BitmapFilter>=[];
			for(i in camGameShaders){
			  newCamEffects.push(new ShaderFilter(i.shader));
			}
			camGame.setFilters(newCamEffects);
		}
  }
	
  	public function clearShaderFromCamera(cam:String){
	switch(cam.toLowerCase()) {
		case 'camhud' | 'hud': 
			camHUDShaders = [];
			var newCamEffects:Array<BitmapFilter>=[];
			camHUD.setFilters(newCamEffects);
		case 'camother' | 'other': 
			camOtherShaders = [];
			var newCamEffects:Array<BitmapFilter>=[];
			camOther.setFilters(newCamEffects);
		default: 
			camGameShaders = [];
			var newCamEffects:Array<BitmapFilter>=[];
			camGame.setFilters(newCamEffects);
		}	  
  	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			startAndEnd();
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countdownPrepare:FlxSprite;
	public var countdownReady:FlxSprite;
	public var countdownSet:FlxSprite;
	public var countdownGo:FlxSprite;
	public static var startOnTime:Float = 0;

	function cacheCountdown()
	{
		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
		var introImagesArray:Array<String> = switch(stageUI) {
			case "pixel": ['${stageUI}UI/prepare-pixel', '${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
			case "normal": ["prepare", "ready", "set" ,"go"];
			default: ['${stageUI}UI/prepare', '${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
		}
		introAssets.set(stageUI, introImagesArray);
		var introAlts:Array<String> = introAssets.get(stageUI);
		for (asset in introAlts) Paths.image(asset);

		Paths.sound('intro3' + introSoundsSuffix);
		Paths.sound('intro2' + introSoundsSuffix);
		Paths.sound('intro1' + introSoundsSuffix);
		Paths.sound('introGo' + introSoundsSuffix);
	}

	public function startCountdown()
	{
		if(startedCountdown) {
			callOnScripts('onStartCountdown');
			return false;
		}

		seenCutscene = true;
		inCutscene = false;
		var ret:Dynamic = callOnScripts('onStartCountdown', null, true);
		if(ret != LuaUtils.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnScripts('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnScripts('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnScripts('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnScripts('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.data.middleScroll) opponentStrums.members[i].visible = false;
			}

			laneunderlay.x = playerStrums.members[0].x - 25;
			laneunderlay.screenCenter(Y);

			startedCountdown = true;
			Conductor.songPosition = -Conductor.crochet * 5;
			setOnScripts('startedCountdown', true);
			callOnScripts('onCountdownStarted', null);

			if(ClientPrefs.data.uilook == 'Dave' || ClientPrefs.data.uilook == 'Gapple') {
				for (i in strumLineNotes) {
					i.x += 5.5;
					if (ClientPrefs.data.downScroll)
						i.y -= 15;
				}
				for (j in 0...playerStrums.length) {
					setOnScripts('defaultPlayerStrumX' + j, playerStrums.members[j].x);
					setOnScripts('defaultPlayerStrumY' + j, playerStrums.members[j].y);
				}
				for (j in 0...opponentStrums.length) {
					setOnScripts('defaultOpponentStrumX' + j, opponentStrums.members[j].x);
					setOnScripts('defaultOpponentStrumY' + j, opponentStrums.members[j].y);
				}
			}

			var swagCounter:Int = 0;
			if (startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 350);
				return true;
			}
			else if (skipCountdown)
			{
				setSongTime(0);
				return true;
			}
			moveCameraSection();

			startTimer = new FlxTimer().start(Conductor.crochet / 1000 / playbackRate, function(tmr:FlxTimer)
			{
				characterBopper(tmr.loopsLeft);

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				var introImagesArray:Array<String> = switch(stageUI) {
					case "pixel": ['${stageUI}UI/prepare-pixel', '${stageUI}UI/ready-pixel', '${stageUI}UI/set-pixel', '${stageUI}UI/date-pixel'];
					case "normal": ["prepare", "ready", "set" ,"go"];
					default: ['${stageUI}UI/prepare', '${stageUI}UI/ready', '${stageUI}UI/set', '${stageUI}UI/go'];
				}
				introAssets.set(stageUI, introImagesArray);

				var introAlts:Array<String> = introAssets.get(stageUI);
				var antialias:Bool = (ClientPrefs.data.antialiasing && !isPixelStage);
				var tick:Countdown = THREE;

				switch (swagCounter)
				{
					case 0:
						countdownReady = createCountdownSprite(introAlts[0], antialias);
						FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						tick = THREE;
					case 1:
						countdownReady = createCountdownSprite(introAlts[1], antialias);
						FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						tick = TWO;
					case 2:
						countdownSet = createCountdownSprite(introAlts[2], antialias);
						FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						tick = ONE;
					case 3:
						countdownGo = createCountdownSprite(introAlts[3], antialias);
						FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						tick = GO;
					case 4:
						tick = START;
				}

				notes.forEachAlive(function(note:Note) {
					if(ClientPrefs.data.opponentStrums || note.mustPress)
					{
						note.copyAlpha = false;
						note.alpha = note.multAlpha;
						if(ClientPrefs.data.middleScroll && !note.mustPress)
							note.alpha *= 0.35;
					}
				});

				stagesFunc(function(stage:BaseStage) stage.countdownTick(tick, swagCounter));
				callOnLuas('onCountdownTick', [swagCounter]);
				callOnHScript('onCountdownTick', [tick, swagCounter]);

				FlxTween.tween(laneunderlay, {alpha: ClientPrefs.data.underlaneVisibility}, 0.5, {ease: FlxEase.quadOut});

				swagCounter += 1;
			}, 5);
		}
		return true;
	}

	inline private function createCountdownSprite(image:String, antialias:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(image));
		spr.cameras = [camHUD];
		spr.scrollFactor.set();
		spr.updateHitbox();

		if (PlayState.isPixelStage)
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.screenCenter();
		spr.antialiasing = antialias;
		insert(members.indexOf(noteGroup), spr);
		FlxTween.tween(spr, {/*y: spr.y + 100,*/ alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				remove(spr);
				spr.destroy();
			}
		});
		return spr;
	}

	public function addBehindGF(obj:FlxBasic)
	{
		insert(members.indexOf(gfGroup), obj);
	}
	public function addBehindBF(obj:FlxBasic)
	{
		insert(members.indexOf(boyfriendGroup), obj);
	}
	public function addBehindDad(obj:FlxBasic)
	{
		insert(members.indexOf(dadGroup), obj);
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 350 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;
				invalidateNote(daNote);
			}
			--i;
		}
	}

	// fun fact: Dynamic Functions can be overriden by just doing this
	// `updateScore = function(miss:Bool = false) { ... }
	// its like if it was a variable but its just a function!
	// cool right? -Crow
	public dynamic function updateScore(miss:Bool = false)
	{
		var ret:Dynamic = callOnScripts('preUpdateScore', [miss], true);
		if (ret == LuaUtils.Function_Stop)
			return;

		var str:String = ratingName;
		if(totalPlayed != 0)
		{
			var percent:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
			str += ' (${percent}%) - ${ratingFC}';
		}

		var tempScore:String = 'Score: ${songScore}'
		+ (!instakillOnMiss ? ' | Misses: ${songMisses}' : "")
		+ ' | Rating: ${str}';
		// "tempScore" variable is used to prevent another memory leak, just in case
		// "\n" here prevents the text from being cut off by beat zooms
		scoreTxt.text = '${tempScore}\n';

		if (!miss && !cpuControlled)
			doScoreBop();

		callOnScripts('onUpdateScore', [miss]);
		if(ClientPrefs.data.uilook == 'Base') {
			scoreTxt.text = 'Score: ' + songScore;
		}
		if(ClientPrefs.data.uilook == 'Forever') {
			var divider:String = ' • ';
    		var comboDisplay:String = ratingFC != null && ratingFC != '' && ratingFC != 'Clear' ? ' [' + ratingFC + ']' : '';
    		var acc:Float = CoolUtil.floorDecimal(ratingPercent * 100, 2);
    		var rank:String = determineRank(acc);

    		scoreTxt.text = 'Score: ' + songScore + divider + 'Accuracy: ' + acc + '%'
    		+ comboDisplay + divider + 'Combo Breaks: ' + songMisses + divider + 'Rank: ' + rank;

    		return;
		}
	}

	public dynamic function fullComboFunction()
	{
		var sicks:Int = ratingsData[0].hits;
		var goods:Int = ratingsData[1].hits;
		var bads:Int = ratingsData[2].hits;
		var shits:Int = ratingsData[3].hits;

		ratingFC = "";
		if(songMisses == 0)
		{
			if (bads > 0 || shits > 0) ratingFC = 'FC';
			else if (goods > 0) ratingFC = 'GFC';
			else if (sicks > 0) ratingFC = 'SFC';
		}
		else {
			if (songMisses < 10) ratingFC = 'SDCB';
			else ratingFC = 'Clear';
		}
	}

	public function doScoreBop():Void {
		if(!ClientPrefs.data.scoreZoom)
			return;

		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.x = 1.075;
		scoreTxt.scale.y = 1.075;
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.time = time;
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.play();

		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = time;
			opponentVocals.time = time;
			#if FLX_PITCH
			vocals.pitch = playbackRate;
			opponentVocals.pitch = playbackRate;
			#end
		}
		vocals.play();
		opponentVocals.play();
		Conductor.songPosition = time;
	}

	public function startNextDialogue() {
		dialogueCount++;
		callOnScripts('onNextDialogue', [dialogueCount]);
	}

	public function skipDialogue() {
		callOnScripts('onSkipDialogue', [dialogueCount]);
	}

	function startSong():Void
	{
		startingSong = false;

		@:privateAccess
		FlxG.sound.playMusic(inst._sound, 1, false);
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		FlxG.sound.music.onComplete = finishSong.bind();
		vocals.play();
		opponentVocals.play();

		if(startOnTime > 0) setSongTime(startOnTime - 500);
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence (with Time Left)
		if(autoUpdateRPC) DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnScripts('songLength', songLength);
		callOnScripts('onSongStart');
	}

	var debugNum:Int = 0;
	private var noteTypes:Array<String> = [];
	private var eventsPushed:Array<String> = [];
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeed = PlayState.SONG.speed;
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype');
		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed');
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed');
		}

		var songData = SONG;
		Conductor.bpm = songData.bpm;

		curSong = songData.song;

		vocals = new FlxSound();
		opponentVocals = new FlxSound();
		try
		{
			if (songData.needsVoices)
			{
				var playerVocals = Paths.voices(songData.song, (boyfriend.vocalsFile == null || boyfriend.vocalsFile.length < 1) ? 'Player' : boyfriend.vocalsFile);
				vocals.loadEmbedded(playerVocals != null ? playerVocals : Paths.voices(songData.song));
				
				var oppVocals = Paths.voices(songData.song, (dad.vocalsFile == null || dad.vocalsFile.length < 1) ? 'Opponent' : dad.vocalsFile);
				if(oppVocals != null) opponentVocals.loadEmbedded(oppVocals);
			}
		}
		catch(e:Dynamic) {}

		#if FLX_PITCH
		vocals.pitch = playbackRate;
		opponentVocals.pitch = playbackRate;
		#end
		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(opponentVocals);

		inst = new FlxSound();
		try {
			inst.loadEmbedded(Paths.inst(songData.song));
		}
		catch(e:Dynamic) {}
		FlxG.sound.list.add(inst);

		notes = new FlxTypedGroup<Note>();
		noteGroup.add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var file:String = Paths.json(songName + '/events');
		#if MODS_ALLOWED
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file))
		#else
		if (OpenFlAssets.exists(file))
		#end
		{
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
				for (i in 0...event[1].length)
					makeEvent(event, i);
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var stair:Int = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var gottaHitNote:Bool = section.mustHitSection;

				if (!randomMode && !flip && !stairs && !waves)
				{
					daNoteData = Std.int(songNotes[1] % 4);
				}
				if (randomMode) {
					daNoteData = FlxG.random.int(0, 3);
				}
				if (flip) {
					daNoteData = Std.int(Math.abs((songNotes[1] % 4) - 3));
				}
				if (oneK)
				{
					daNoteData = 2;
				}
				if (stairs && !waves) {
				daNoteData = stair % 4;
				stair++;
				}
				if (waves) {
						switch (stair % 6)
							{
								case 0 | 1 | 2 | 3:
									daNoteData = stair % 6;
								case 4:
									daNoteData = 2;
								case 5:
									daNoteData = 1;
							}
				stair++;
				}

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				unspawnNotes.push(swagNote);

				final susLength:Float = swagNote.sustainLength / Conductor.stepCrochet;
				final floorSus:Int = Math.floor(susLength);

				if(floorSus > 0) {
					for (susNote in 0...floorSus + 1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						sustainNote.parent = swagNote;
						unspawnNotes.push(sustainNote);
						swagNote.tail.push(sustainNote);

						sustainNote.correctionOffset = swagNote.height / 2;
						if(!PlayState.isPixelStage)
						{
							if(oldNote.isSustainNote)
							{
								oldNote.scale.y *= Note.SUSTAIN_SIZE / oldNote.frameHeight;
								oldNote.scale.y /= playbackRate;
								oldNote.updateHitbox();
							}

							if(ClientPrefs.data.downScroll)
								sustainNote.correctionOffset = 0;
						}
						else if(oldNote.isSustainNote)
						{
							oldNote.scale.y /= playbackRate;
							oldNote.updateHitbox();
						}

						if (sustainNote.mustPress) sustainNote.x += FlxG.width / 2; // general offset
						else if(ClientPrefs.data.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
								sustainNote.x += FlxG.width / 2 + 25;
						}
						sustainNote.noAnimation = (!ClientPrefs.data.oldHold);
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.data.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypes.contains(swagNote.noteType)) {
					noteTypes.push(swagNote.noteType);
				}
			}
		}
		for (event in songData.events) //Event Notes
			for (i in 0...event[1].length)
				makeEvent(event, i);

		unspawnNotes.sort(sortByTime);
		generatedMusic = true;
	}

	// called only once per different event (Used for precaching)
	function eventPushed(event:EventNote) {
		eventPushedUnique(event);
		if(eventsPushed.contains(event.event)) {
			return;
		}

		stagesFunc(function(stage:BaseStage) stage.eventPushed(event));
		eventsPushed.push(event.event);
	}

	// called by every event with the same name
	function eventPushedUnique(event:EventNote) {
		switch(event.event) {
			case "Change Character":
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						var val1:Int = Std.parseInt(event.value1);
						if(Math.isNaN(val1)) val1 = 0;
						charType = val1;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);

			case 'Play Sound':
				Paths.sound(event.value1); //Precache sound
		}
		stagesFunc(function(stage:BaseStage) stage.eventPushedUnique(event));
	}

	function eventEarlyTrigger(event:EventNote):Float {
		var returnedValue:Null<Float> = callOnScripts('eventEarlyTrigger', [event.event, event.value1, event.value2, event.strumTime], true, [], [0]);
		if(returnedValue != null && returnedValue != 0 && returnedValue != LuaUtils.Function_Continue) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function makeEvent(event:Array<Dynamic>, i:Int)
	{
		var subEvent:EventNote = {
			strumTime: event[0] + ClientPrefs.data.noteOffset,
			event: event[1][i][0],
			value1: event[1][i][1],
			value2: event[1][i][2]
		};
		eventNotes.push(subEvent);
		eventPushed(subEvent);
		callOnScripts('onEventPushed', [subEvent.event, subEvent.value1 != null ? subEvent.value1 : '', subEvent.value2 != null ? subEvent.value2 : '', subEvent.strumTime]);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		var strumLineX:Float = ClientPrefs.data.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X;
		var strumLineY:Float = ClientPrefs.data.downScroll ? (FlxG.height - 150) : 50;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1)
			{
				if(!ClientPrefs.data.opponentStrums) targetAlpha = 0;
				else if(ClientPrefs.data.middleScroll) targetAlpha = 0.35;
			}

			var babyArrow:StrumNote = new StrumNote(strumLineX, strumLineY, i, player);
			babyArrow.downScroll = ClientPrefs.data.downScroll;
			if (!isStoryMode && !skipArrowStartTween)
			{
				//babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {/*y: babyArrow.y + 10,*/ alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
				babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				if(ClientPrefs.data.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		stagesFunc(function(stage:BaseStage) stage.openSubState(SubState));
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				opponentVocals.pause();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = false);
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		super.closeSubState();
		
		stagesFunc(function(stage:BaseStage) stage.closeSubState());
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = true);
			FlxTween.globalManager.forEach(function(twn:FlxTween) if(!twn.finished) twn.active = true);

			paused = false;
			callOnScripts('onResume');
			resetRPC(startTimer != null && startTimer.finished);
		}
	}

	override public function onFocus():Void
	{
		if (health > 0 && !paused) resetRPC(Conductor.songPosition > 0.0);
		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if DISCORD_ALLOWED
		if (health > 0 && !paused && autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		super.onFocusLost();
	}

	// Updating Discord Rich Presence.
	public var autoUpdateRPC:Bool = true; //performance setting for custom RPC things
	function resetRPC(?showTime:Bool = false)
	{
		#if DISCORD_ALLOWED
		if(!autoUpdateRPC) return;

		if (showTime)
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.data.noteOffset);
		else
			DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();
		opponentVocals.pause();

		FlxG.sound.music.play();
		#if FLX_PITCH FlxG.sound.music.pitch = playbackRate; #end
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length)
		{
			vocals.time = Conductor.songPosition;
			#if FLX_PITCH vocals.pitch = playbackRate; #end
		}

		if (Conductor.songPosition <= opponentVocals.length)
		{
			opponentVocals.time = Conductor.songPosition;
			#if FLX_PITCH opponentVocals.pitch = playbackRate; #end
		}
		vocals.play();
		opponentVocals.play();
	}

	public var paused:Bool = false;
	public var canReset:Bool = true;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var freezeCamera:Bool = false;
	var allowDebugKeys:Bool = true;
	var max:Float = 0;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused && !freezeCamera) {
			FlxG.camera.followLerp = 2.4 * cameraSpeed * playbackRate;
			if(!startingSong && !endingSong && boyfriend.getAnimationName().startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}
		else FlxG.camera.followLerp = 0;
		callOnScripts('onUpdate', [elapsed]);

		super.update(elapsed);

		setOnScripts('curDecStep', curDecStep);
		setOnScripts('curDecBeat', curDecBeat);

		if(ClientPrefs.data.ratingType == 'camGame') {
			var playerX:Float = gf.x;
    		var playerY:Float = gf.y;

    		var offsetX:Float = 100; // How far to the left of the player you want the combo to appear
    		var offsetY:Float = 100; // How far above the player you want the combo to appear

			if(isPixelStage) {
				offsetY = 300;
				offsetX = 300;
				comboGroup.x = playerX - offsetX;
			} else {
				comboGroup.x = playerX + offsetX;
			}
    		comboGroup.y = playerY - offsetY;
		}
		/*
		for (n in notes) {
	    	if (n.clipRect != null && n.clipRect.height <= 0 && !n.extraData.get('consumed') && StringTools.endsWith(n.animation.curAnim.name, 'end')) {
	    		n.extraData.set('consumed', true); //prevent it running more than once
	    		coverLogic(n, true);
	    	}
	    }
		*/

		if(ClientPrefs.data.ldm) {
			camHUD.zoom = 1;
			camHUD.angle = 1;
			scoreTxt.scale.x = 1;
			scoreTxt.scale.y = 1;
		}
		if(gf.curCharacter == 'nene') {
			var max:Float = 0;
			var curIndex = Math.floor(musicSrc.buffer.sampleRate * (FlxG.sound.music.time / 1000));
			// trace(curIndex / (data.length * 2));
			// trace(FlxG.sound.music.time / FlxG.sound.music.length);
			// max = Math.max(max, data[curIndex]);
			debugText.text = "";
			// refactor below code to use addDebugText function
			// addDebugText(max / 2);
			// addDebugText(musicSrc.buffer.sampleRate);
			// addDebugText(data[curIndex]);
			// addDebugText(FlxG.sound.music.time / FlxG.sound.music.length);
			// addDebugText(curIndex / (data.length / 4));
			// addDebugText((data.length / 4) / musicSrc.buffer.sampleRate);
			// addDebugText(FlxG.sound.music.length / 1000);
			if (FlxG.keys.justPressed.SPACE)
			{
				#if instrument
				// instrument.coverage.Coverage.endCoverage(); // when measuring coverage
				instrument.profiler.Profiler.endProfiler(); // when profiling
				#end
			}
		}

		if(botplayTxt != null && botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnScripts('onPause', null, true);
			if(ret != LuaUtils.Function_Stop) {
				openPauseMenu();
			}
		}

		if(!endingSong && !inCutscene && allowDebugKeys)
		{
			if (controls.justPressed('debug_1'))
				openChartEditor();
			else if (controls.justPressed('debug_2'))
				openCharacterEditor();
		}

		if (healthBar.bounds.max != null && health > healthBar.bounds.max)
			health = healthBar.bounds.max;

		updateIconsScale(elapsed);
		updateIconsPosition();

		if (startedCountdown && !paused)
			Conductor.songPosition += FlxG.elapsed * 1000 * playbackRate;

		if (startingSong)
		{
			if (startedCountdown && Conductor.songPosition >= 0)
				startSong();
			else if(!startedCountdown)
				Conductor.songPosition = -Conductor.crochet * 5;
		}
		else if (!paused && updateTime)
		{
			var curTime:Float = Math.max(0, Conductor.songPosition - ClientPrefs.data.noteOffset);
			songPercent = (curTime / songLength);

			var songCalc:Float = (songLength - curTime);
			if(ClientPrefs.data.timeBarType == 'Time Elapsed') songCalc = curTime;

			var secondsTotal:Int = Math.floor(songCalc / 1000);
			if(secondsTotal < 0) secondsTotal = 0;

			if(ClientPrefs.data.timeBarType != 'Song Name')
				timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

			if(ClientPrefs.data.timeBarType == 'Elapsed, Left' || ClientPrefs.data.uilook == 'Gapple')
				timeTxt.text = '${FlxStringUtil.formatTime(Conductor.songPosition / 1000)} / ${FlxStringUtil.formatTime(songLength / 1000)}';
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * playbackRate));
		}

		FlxG.watch.addQuick("secShit", curSection);
		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.data.noReset && controls.RESET && canReset && !inCutscene && startedCountdown && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = spawnTime * playbackRate;
			if(songSpeed < 1) time /= songSpeed;
			if(unspawnNotes[0].multSpeed < 1) time /= unspawnNotes[0].multSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);
				dunceNote.spawned = true;

				callOnLuas('onSpawnNote', [notes.members.indexOf(dunceNote), dunceNote.noteData, dunceNote.noteType, dunceNote.isSustainNote, dunceNote.strumTime]);
				callOnHScript('onSpawnNote', [dunceNote]);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if(!inCutscene)
			{
				if(!cpuControlled)
					keysCheck();
				else
					playerDance();

				if(notes.length > 0)
				{
					if(startedCountdown)
					{
						var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
						notes.forEachAlive(function(daNote:Note)
						{
							var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
							if(!daNote.mustPress) strumGroup = opponentStrums;

							var strum:StrumNote = strumGroup.members[daNote.noteData];
							daNote.followStrumNote(strum, fakeCrochet, songSpeed / playbackRate);

							if(daNote.mustPress)
							{
								if(cpuControlled && !daNote.blockHit && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
									goodNoteHit(daNote);
							}
							else if (daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
								opponentNoteHit(daNote);

							if(daNote.isSustainNote && strum.sustainReduce) daNote.clipToStrumNote(strum);

							// Kill extremely late notes and cause misses
							if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
							{
								if (daNote.mustPress && !cpuControlled && !daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit))
									noteMiss(daNote);

								daNote.active = daNote.visible = false;
								invalidateNote(daNote);
							}
						});
					}
					else
					{
						notes.forEachAlive(function(daNote:Note)
						{
							daNote.canBeHit = false;
							daNote.wasGoodHit = false;
						});
					}
				}
			}
			checkEventNote();
		}

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnScripts('cameraX', camFollow.x);
		setOnScripts('cameraY', camFollow.y);
		setOnScripts('botPlay', cpuControlled);
		callOnScripts('onUpdatePost', [elapsed]);

		if(ClientPrefs.data.uilook == 'Dave' || ClientPrefs.data.uilook == 'Gapple') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Accuracy: ' + truncateFloat(ratingPercent * 100, 2) + '%';
			scoreTxt.scale.set(1, 1);
			scoreTxt.updateHitbox();
			if (camZooming) {
				camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			}
		}
		if(ClientPrefs.data.camMovement) {
			final animIndexArray:Array<Array<Int>> = [[-1, 0], [0, 1], [0, -1], [1, 0]];
			var offsetArray:Array<Float> = [];

			//Camera Intensity
			final mult:Float = 20;

			camGame.targetOffset.set(0, 0);
   			offsetArray = [0, 0];

    		for (i in 0...4) for (strums in [playerStrums, opponentStrums]) if (strums.members[i].animation.curAnim.name == "confirm") offsetArray = [animIndexArray[i][0] * mult, animIndexArray[i][1] * mult];
    		camGame.targetOffset.set(camGame.targetOffset.x + offsetArray[0], camGame.targetOffset.y + offsetArray[1]);
		}

		if (jackass) {
			for (note in notes.members) {
				if (! cpuControlled) {
				  note.blockHit = note.mustPress;
				  var safeHit = note.strumTime - Conductor.songPosition < 10;
				  if (note.mustPress) {
					if (safeHit && returnKey(note.noteData)) {
					  goodNoteHit(note);
					//  debugPrint('hit!');
					}
				  }
				}
			}
		}

		for (i in shaderUpdates){
			i(elapsed);
		}
	}

	function returnKey(key) {
		switch (key) {
		  case 0: return FlxG.keys.anyPressed(ClientPrefs.keyBinds.get('note_left'));
		  case 1: return FlxG.keys.anyPressed(ClientPrefs.keyBinds.get('note_down'));
		  case 2: return FlxG.keys.anyPressed(ClientPrefs.keyBinds.get('note_up'));
		  case 3: return FlxG.keys.anyPressed(ClientPrefs.keyBinds.get('note_right'));
		  default: return FlxG.keys.anyPressed(ClientPrefs.keyBinds.get('note_left'));
		}
		return false;
	}

	function addDebugText(text:Dynamic)
	{
		debugText.text += "\n";
		debugText.text += "" + text;
	}

	/**
	 * Returns an array of song names to use for music list
	 * @param listPath file path to the txt file
	 * @return An array of song names from the txt file
	 */
	function fillMusicList(listPath:String):Array<String>
	{
		return Assets.getText(listPath).split("\n").map(str -> str.trim());
	}

	// Health icon updaters
	public dynamic function updateIconsScale(elapsed:Float)
	{
		if(ClientPrefs.data.iconBops == 'Psych' || ClientPrefs.data.iconBops == 'OS') {
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 * playbackRate));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();

			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 * playbackRate));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == 'Stretchy') {
			var thingy = 0.88; //(144 / Main.fps.currentFPS) * 0.88;
			//still gotta make this fps consistent crap

			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, thingy)),Std.int(FlxMath.lerp(150, iconP1.height, thingy)));
			iconP1.updateHitbox();

			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, thingy)),Std.int(FlxMath.lerp(150, iconP2.height, thingy)));
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == 'Dave and Bambi' || ClientPrefs.data.uilook == 'Dave') {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.9 * playbackRate)),Std.int(FlxMath.lerp(150, iconP1.height, 0.9 * playbackRate)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.9 * playbackRate)),Std.int(FlxMath.lerp(150, iconP2.height, 0.9 * playbackRate)));
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == 'Golden Apple' || ClientPrefs.data.uilook == 'Gapple') {
			iconP1.centerOffsets();
			iconP2.centerOffsets();
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == 'OG') {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
	}

	public dynamic function updateIconsPosition()
	{
		var iconOffset:Int = 26;
		iconP1.x = healthBar.barCenter + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.barCenter - (150 * iconP2.scale.x) / 2 - iconOffset * 2;
		if(ClientPrefs.data.uilook == 'Dave') {
			var healthFlip = healthBar.leftToRight;
			if (healthFlip) {
				iconP2.flipX = true;
				iconP1.flipX = true;
				var bfArray = boyfriend.healthColorArray;
				var dadArray = dad.healthColorArray;
				healthBar.leftBar.color = FlxColor.fromRGB(bfArray[0], bfArray[1], bfArray[2]);
				healthBar.rightBar.color = FlxColor.fromRGB(dadArray[0], dadArray[1], dadArray[2]);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(100 - healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(100 - healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP1.width - iconOffset);
			} else {
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			}
		}
	}

	var iconsAnimations:Bool = true;
	function set_health(value:Float):Float // You can alter how icon animations work here
	{
		if(!iconsAnimations || healthBar == null || !healthBar.enabled || healthBar.valueFunction == null)
		{
			health = value;
			return health;
		}

		// update health bar
		health = value;
		var newPercent:Null<Float> = FlxMath.remapToRange(FlxMath.bound(healthBar.valueFunction(), healthBar.bounds.min, healthBar.bounds.max), healthBar.bounds.min, healthBar.bounds.max, 0, 100);
		healthBar.percent = (newPercent != null ? newPercent : 0);

		//iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0; //If health is under 20%, change player icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		//iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0; //If health is over 80%, change opponent icon to frame 1 (losing icon), otherwise, frame 0 (normal)
		//unoptimized AS SHIT but I'm too lazy and tired to try and optimize it for 0.7.3 atm
		if (iconP1.animation.frames == 3) {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else if (healthBar.percent >80)
				iconP1.animation.curAnim.curFrame = 2;
			else
				iconP1.animation.curAnim.curFrame = 0;
		} 
		else {
			if (healthBar.percent < 20)
				iconP1.animation.curAnim.curFrame = 1;
			else
				iconP1.animation.curAnim.curFrame = 0;
		}
		if (iconP2.animation.frames == 3) {
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else if (healthBar.percent < 20)
				iconP2.animation.curAnim.curFrame = 2;
			else 
				iconP2.animation.curAnim.curFrame = 0;
		} else {
			if (healthBar.percent > 80)
				iconP2.animation.curAnim.curFrame = 1;
			else 
				iconP2.animation.curAnim.curFrame = 0;
		}
		return health;
	}

	function openPauseMenu()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if(FlxG.sound.music != null) {
			FlxG.sound.music.pause();
			vocals.pause();
			opponentVocals.pause();
		}
		if(!cpuControlled)
		{
			for (note in playerStrums)
				if(note.animation.curAnim != null && note.animation.curAnim.name != 'static')
				{
					note.playAnim('static');
					note.resetAnim = 0;
				}
		}
		openSubState(new PauseSubState());

		#if DISCORD_ALLOWED
		if(autoUpdateRPC) DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end
	}

	function openChartEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		chartingMode = true;

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Chart Editor", null, null, true);
		DiscordClient.resetClientID();
		#end

		MusicBeatState.switchState(new ChartingState());
	}

	function openCharacterEditor()
	{
		FlxG.camera.followLerp = 0;
		persistentUpdate = false;
		paused = true;
		if(FlxG.sound.music != null)
			FlxG.sound.music.stop();
		#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
		MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
	}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnScripts('onGameOver', null, true);
			if(ret != LuaUtils.Function_Stop) {
				FlxG.animationTimeScale = 1;
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				opponentVocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				FlxTimer.globalManager.clear();
				FlxTween.globalManager.clear();
				#if LUA_ALLOWED
				modchartTimers.clear();
				modchartTweens.clear();
				#end

				openSubState(new GameOverSubstate());

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if DISCORD_ALLOWED
				// Game Over doesn't get his its variable because it's only used here
				if(autoUpdateRPC) DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				return;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEvent(eventNotes[0].event, value1, value2, leStrumTime);
			eventNotes.shift();
		}
	}

	public function triggerEvent(eventName:String, value1:String, value2:String, strumTime:Float) {
		var flValue1:Null<Float> = Std.parseFloat(value1);
		var flValue2:Null<Float> = Std.parseFloat(value2);
		var zoomedOut:Bool = false;

		//unoptimized ish but oh well
		var gfCamX = gf.getMidpoint().x+gf.cameraPosition[0];
		var gfCamY = gf.getMidpoint().y+gf.cameraPosition[1];
		var dadCamX = dad.getMidpoint().x+dad.cameraPosition[0];
		var dadCamY = dad.getMidpoint().y+dad.cameraPosition[1];
		var bfCamX = boyfriend.getMidpoint().x+boyfriend.cameraPosition[0];
		var bfCamY = boyfriend.getMidpoint().x+boyfriend.cameraPosition[1];

		//var ogCamZoom = FlxG.camera.zoom;
		//

		if(Math.isNaN(flValue1)) flValue1 = null;
		if(Math.isNaN(flValue2)) flValue2 = null;

		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				if(flValue2 == null || flValue2 <= 0) flValue2 = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = flValue2;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = flValue2;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = flValue2;
				}

			case 'Set GF Speed':
				if(flValue1 == null || flValue1 < 1) flValue1 = 1;
				gfSpeed = Math.round(flValue1);

			case 'Add Camera Zoom':
				if(ClientPrefs.data.camZooms && FlxG.camera.zoom < 1.35) {
					if(flValue1 == null) flValue1 = 0.015;
					if(flValue2 == null) flValue2 = 0.03;

					FlxG.camera.zoom += flValue1;
					camHUD.zoom += flValue2;
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						if(flValue2 == null) flValue2 = 0;
						switch(Math.round(flValue2)) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				if(camFollow != null)
				{
					isCameraOnForcedPos = false;
					if(flValue1 != null || flValue2 != null)
					{
						isCameraOnForcedPos = true;
						if(flValue1 == null) flValue1 = 0;
						if(flValue2 == null) flValue2 = 0;
						camFollow.x = flValue1;
						camFollow.y = flValue2;
					}
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}
			case 'Focus Camera':
				camZooming = true;
				switch(value2.toLowerCase().trim()) {
					case 'true' | 'True':
						switch(value1.toLowerCase().trim()) {
							case 'gf' | 'girlfriend':
								//defaultCamZoom -= 0.05;
								triggerEvent('Camera Follow Pos', Std.string(gfCamX), Std.string(gfCamY), Conductor.songPosition);
							case 'dad':
								triggerEvent('Camera Follow Pos', Std.string(dadCamX), Std.string(dadCamY), Conductor.songPosition);
								//defaultCamZoom += 0.05;
							case 'bf' | 'boyfriend':
								triggerEvent('Camera Follow Pos', Std.string(bfCamX), Std.string(bfCamY), Conductor.songPosition);
								//defaultCamZoom += 0.05;
						}
					case 'false' | 'False':
						triggerEvent('Camera Follow Pos', '', '', Conductor.songPosition);
				}

			case 'Set Cam Zoom':
				camZooming = true;
				defaultCamZoom = Std.parseFloat(value1);
				if(value1 == '') {defaultCamZoom = ogCamZoom;}

			case 'Change Character':
				var charType:Int = 0;
				switch(value1.toLowerCase().trim()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnScripts('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf-') || dad.curCharacter == 'gf';
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf-') && dad.curCharacter != 'gf') {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnScripts('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2)) {
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnScripts('gfName', gf.curCharacter);
						}
				}
				if(ClientPrefs.data.uilook == 'Dave') {
					reloadIcons(value1);
				}
				if(ClientPrefs.data.uilook == 'Base') {
					healthBar.leftBar.color = 0xFF0000;
        			healthBar.rightBar.color = 0xFF66FF33;
				}
				else {
					reloadHealthBarColors();
				}

			case 'Change Scroll Speed':
				if (songSpeedType != "constant")
				{
					if(flValue1 == null) flValue1 = 1;
					if(flValue2 == null) flValue2 = 0;

					var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed') * flValue1;
					if(flValue2 <= 0)
						songSpeed = newValue;
					else
						songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, flValue2 / playbackRate, {ease: FlxEase.linear, onComplete:
							function (twn:FlxTween)
							{
								songSpeedTween = null;
							}
						});
				}

			case 'Set Property':
				try
				{
					var split:Array<String> = value1.split('.');
					if(split.length > 1) {
						LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1], value2);
					} else {
						LuaUtils.setVarInArray(this, value1, value2);
					}
				}
				catch(e:Dynamic)
				{
					var len:Int = e.message.indexOf('\n') + 1;
					if(len <= 0) len = e.message.length;
					#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
					addTextToDebug('ERROR ("Set Property" Event) - ' + e.message.substr(0, len), FlxColor.RED);
					#else
					FlxG.log.warn('ERROR ("Set Property" Event) - ' + e.message.substr(0, len));
					#end
				}

			case 'Play Sound':
				if(flValue2 == null) flValue2 = 1;
				FlxG.sound.play(Paths.sound(value1), flValue2);
		}

		stagesFunc(function(stage:BaseStage) stage.eventCalled(eventName, value1, value2, flValue1, flValue2, strumTime));
		callOnScripts('onEvent', [eventName, value1, value2, strumTime]);
	}

	function moveCameraSection(?sec:Null<Int>):Void {
		if(sec == null) sec = curSection;
		if(sec < 0) sec = 0;

		if(SONG.notes[sec] == null) return;

		if (gf != null && SONG.notes[sec].gfSection)
		{
			camFollow.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnScripts('onMoveCamera', ['gf']);
			return;
		}

		var isDad:Bool = (SONG.notes[sec].mustHitSection != true);
		moveCamera(isDad);
		callOnScripts('onMoveCamera', [isDad ? 'dad' : 'boyfriend']);
		//abot stuffz
		if(gf.curCharacter == 'nene') {
			new FlxTimer().start(0.2, (tmr) -> {
				if (abotEyess == (isDad ? 1 : 0)) {
				  
				  abotEyess = (isDad) ? 0 : 1;
				  abotEyes.animation.play((isDad) ? 'l' : 'r');
				}
			});	
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		if(isDad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	public function tweenCamIn() {
		if (songName == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		updateTime = false;
		FlxG.sound.music.volume = 0;

		vocals.volume = 0;
		vocals.pause();
		opponentVocals.volume = 0;
		opponentVocals.pause();

		if(ClientPrefs.data.noteOffset <= 0 || ignoreNoteOffset) {
			endCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.data.noteOffset / 1000, function(tmr:FlxTimer) {
				endCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong()
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return false;
			}
		}

		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		var weekNoMiss:String = WeekData.getWeekFileName() + '_nomiss';
		checkForAchievement([weekNoMiss, 'ur_bad', 'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);
		#end

		var ret:Dynamic = callOnScripts('onEndSong', null, true);
		if(ret != LuaUtils.Function_Stop && !transitioning)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			#end
			playbackRate = 1;

			if (chartingMode)
			{
				openChartEditor();
				return false;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					Mods.loadTopMod();
					FlxG.sound.playMusic(Paths.music('menuSongs/freakyMenu-' + ClientPrefs.data.menuSong));
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice') && !ClientPrefs.getGameplaySetting('botplay') && !ClientPrefs.getGameplaySetting('jackass')) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = Difficulty.getFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				Mods.loadTopMod();
				#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end

				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('menuSongs/freakyMenu-' + ClientPrefs.data.menuSong));
				changedDifficulty = false;
			}
			transitioning = true;
		}
		return true;
	}

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;
			invalidateNote(daNote);
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showComboNum:Bool = true;
	public var showRating:Bool = true;

	// Stores Ratings and Combo Sprites in a group
	public var comboGroup:FlxSpriteGroup;
	// Stores HUD Objects in a Group
	public var uiGroup:FlxSpriteGroup;
	// Stores Note Objects in a Group
	public var noteGroup:FlxTypedGroup<FlxBasic>;

	private function cachePopUpScore()
	{
		var uiPrefix:String = '';
		var uiSuffix:String = '';
		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
		}

		for (rating in ratingsData)
			Paths.image(uiPrefix + rating.image + uiSuffix);
		for (i in 0...10)
			Paths.image(uiPrefix + 'num' + i + uiSuffix);
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.data.ratingOffset);
		vocals.volume = 1;

		if (!ClientPrefs.data.comboStacking && comboGroup.members.length > 0) {
			for (spr in comboGroup) {
				spr.destroy();
				comboGroup.remove(spr);
			}
		}

		var placement:Float = FlxG.width * 0.35;
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:Rating = Conductor.judgeNote(ratingsData, noteDiff / playbackRate);

		totalNotesHit += daRating.ratingMod;
		note.ratingMod = daRating.ratingMod;
		if(!note.ratingDisabled) daRating.hits++;
		note.rating = daRating.name;
		score = daRating.score;

		if(daRating.noteSplash && !note.noteSplashData.disabled)
			spawnNoteSplashOnNote(note);

		if(!practiceMode && !cpuControlled && !jackass) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating(false);
			}
		}

		var uiPrefix:String = "";
		var uiSuffix:String = '';
		var antialias:Bool = ClientPrefs.data.antialiasing;

		if (stageUI != "normal")
		{
			uiPrefix = '${stageUI}UI/';
			if (PlayState.isPixelStage) uiSuffix = '-pixel';
			antialias = !isPixelStage;
		}

		rating.loadGraphic(Paths.image(uiPrefix + daRating.image + uiSuffix));
		rating.screenCenter();
		rating.x = placement - 40;
		rating.y -= 60;
		rating.acceleration.y = 550 * playbackRate * playbackRate;
		rating.velocity.y -= FlxG.random.int(140, 175) * playbackRate;
		rating.velocity.x -= FlxG.random.int(0, 10) * playbackRate;
		rating.visible = (!ClientPrefs.data.hideHud && showRating);
		rating.x += ClientPrefs.data.comboOffset[0];
		rating.y -= ClientPrefs.data.comboOffset[1];
		rating.antialiasing = antialias;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'combo' + uiSuffix));
		comboSpr.screenCenter();
		comboSpr.x = placement;
		comboSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
		comboSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
		comboSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
		comboSpr.x += ClientPrefs.data.comboOffset[0];
		comboSpr.y -= ClientPrefs.data.comboOffset[1];
		comboSpr.antialiasing = antialias;
		comboSpr.y += 60;
		comboSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
		comboGroup.add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		var xThing:Float = 0;
		if (showCombo)
			//comboGroup.add(comboSpr);

		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(uiPrefix + 'num' + Std.int(i) + uiSuffix));
			numScore.screenCenter();
			numScore.x = placement + (43 * daLoop) - 90 + ClientPrefs.data.comboOffset[2];
			numScore.y += 80 - ClientPrefs.data.comboOffset[3];

			if (!PlayState.isPixelStage) numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			numScore.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			numScore.velocity.x = FlxG.random.float(-5, 5) * playbackRate;
			numScore.visible = !ClientPrefs.data.hideHud;
			numScore.antialiasing = antialias;

			/*if (combo >= 10 || combo == 0)
			if(showComboNum)
				comboGroup.add(numScore);*/

			if (ClientPrefs.data.comboSprite) {
				if (combo >= 10) {
					comboGroup.add(numScore);
					comboGroup.add(comboSpr);
				}
			}
			if (!ClientPrefs.data.comboSprite && combo >= 1) {
				comboGroup.add(numScore);
			}

			if (ClientPrefs.data.ratingType == 'Invisible') {
				comboSpr.visible = false;
				rating.visible = false;
				numScore.visible = false;
			}
			else {
				comboSpr.cameras = [LuaUtils.cameraFromString(ClientPrefs.data.ratingType)];
				rating.cameras = [LuaUtils.cameraFromString(ClientPrefs.data.ratingType)];
				numScore.cameras = [LuaUtils.cameraFromString(ClientPrefs.data.ratingType)];
			}

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		comboSpr.x = xThing + 50;
		FlxTween.tween(rating, {alpha: 0}, 0.2 / playbackRate, {
			startDelay: Conductor.crochet * 0.001 / playbackRate
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / playbackRate, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.002 / playbackRate
		});
	}

	public var strumsBlocked:Array<Bool> = [];
	private function onKeyPress(event:KeyboardEvent):Void
	{

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);

		if (!controls.controllerMode)
		{
			#if debug
			//Prevents crash specifically on debug without needing to try catch shit
			@:privateAccess if (!FlxG.keys._keyListMap.exists(eventKey)) return;
			#end

			if(FlxG.keys.checkStatus(eventKey, JUST_PRESSED)) keyPressed(key);
		}
	}

	private function keyPressed(key:Int)
	{
		if(cpuControlled || paused || inCutscene || key < 0 || key >= playerStrums.length || !generatedMusic || endingSong || boyfriend.stunned) return;

		var ret:Dynamic = callOnScripts('onKeyPressPre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		// more accurate hit time for the ratings?
		var lastTime:Float = Conductor.songPosition;
		if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time;

		// obtain notes that the player can hit
		var plrInputNotes:Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return n != null && canHit && !n.isSustainNote && n.noteData == key;
		});
		plrInputNotes.sort(sortHitNotes);

		var shouldMiss:Bool = !ClientPrefs.data.ghostTapping;

		if (plrInputNotes.length != 0) { // slightly faster than doing `> 0` lol
			var funnyNote:Note = plrInputNotes[0]; // front note

			if (plrInputNotes.length > 1) {
				var doubleNote:Note = plrInputNotes[1];

				if (doubleNote.noteData == funnyNote.noteData) {
					// if the note has a 0ms distance (is on top of the current note), kill it
					if (Math.abs(doubleNote.strumTime - funnyNote.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < funnyNote.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						funnyNote = doubleNote;
					}
				}
			}
			goodNoteHit(funnyNote);
		}
		else if(shouldMiss)
		{
			callOnScripts('onGhostTap', [key]);
			noteMissPress(key);
		}

		// Needed for the  "Just the Two of Us" achievement.
		//									- Shadow Mario
		if(!keysPressed.contains(key)) keysPressed.push(key);

		//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
		Conductor.songPosition = lastTime;

		var spr:StrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyPress', [key]);
	}

	public static function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(keysArray, eventKey);
		if(!controls.controllerMode && key > -1) keyReleased(key);
	}

	private function keyReleased(key:Int)
	{
		if(cpuControlled || !startedCountdown || paused || key < 0 || key >= playerStrums.length) return;

		var ret:Dynamic = callOnScripts('onKeyReleasePre', [key]);
		if(ret == LuaUtils.Function_Stop) return;

		var spr:StrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
		callOnScripts('onKeyRelease', [key]);
		/*
		var data = inArray(holdCovers, key + opponentStrums.length);
    	if (data == null) //do nothing?
    	var cover = data.cover;
    	if (cover != null && cover.animation.curAnim.name != 'end') cover.visible = false;
		*/
	}

	public static function getKeyFromEvent(arr:Array<String>, key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...arr.length)
			{
				var note:Array<FlxKey> = Controls.instance.keyboardBinds[arr[i]];
				for (noteKey in note)
					if(key == noteKey)
						return i;
			}
		}
		return -1;
	}

	// Hold notes
	private function keysCheck():Void
	{
		// HOLDING
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];
		for (key in keysArray)
		{
			holdArray.push(controls.pressed(key));
			if(controls.controllerMode)
			{
				pressArray.push(controls.justPressed(key));
				releaseArray.push(controls.justReleased(key));
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(controls.controllerMode && pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i] && strumsBlocked[i] != true)
					keyPressed(i);

		if (startedCountdown && !inCutscene && !boyfriend.stunned && generatedMusic)
		{
			if (notes.length > 0) {
				for (n in notes) { // I can't do a filter here, that's kinda awesome
					var canHit:Bool = (n != null && !strumsBlocked[n.noteData] && n.canBeHit
						&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit);

					if (guitarHeroSustains)
						canHit = canHit && n.parent != null && n.parent.wasGoodHit;

					if (canHit && n.isSustainNote) {
						var released:Bool = !holdArray[n.noteData];

						if (!released)
							goodNoteHit(n);
					}
				}
			}

			if (!holdArray.contains(true) || endingSong)
				playerDance();

			#if ACHIEVEMENTS_ALLOWED
			else checkForAchievement(['oversinging']);
			#end
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if((controls.controllerMode || strumsBlocked.contains(true)) && releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i] || strumsBlocked[i] == true)
					keyReleased(i);
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1)
				invalidateNote(note);
		});

		final end:Note = daNote.isSustainNote ? daNote.parent.tail[daNote.parent.tail.length - 1] : daNote.tail[daNote.tail.length - 1];
		if (end != null && end.extraData['holdSplash'] != null) {
			end.extraData['holdSplash'].visible = false;
		}

		noteMissCommon(daNote.noteData, daNote);
		var result:Dynamic = callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('noteMiss', [daNote]);
		if(ClientPrefs.data.missSounds) {FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));}
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if(ClientPrefs.data.ghostTapping) return; //fuck it

		noteMissCommon(direction);
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		callOnScripts('noteMissPress', [direction]);
	}

	function noteMissCommon(direction:Int, note:Note = null)
	{
		// score and data
		var subtract:Float = 0.05;
		if(note != null) subtract = note.missHealth;

		// GUITAR HERO SUSTAIN CHECK LOL!!!!
		if (note != null && guitarHeroSustains && note.parent == null) {
			if(note.tail.length > 0) {
				note.alpha = 0.35;
				for(childNote in note.tail) {
					childNote.alpha = note.alpha;
					childNote.missed = true;
					childNote.canBeHit = false;
					childNote.ignoreNote = true;
					childNote.tooLate = true;
				}
				note.missed = true;
				note.canBeHit = false;

				//subtract += 0.385; // you take more damage if playing with this gameplay changer enabled.
				// i mean its fair :p -Crow
				subtract *= note.tail.length + 1;
				// i think it would be fair if damage multiplied based on how long the sustain is -Tahir
			}

			if (note.missed)
				return;
		}
		if (note != null && guitarHeroSustains && note.parent != null && note.isSustainNote) {
			if (note.missed)
				return;

			var parentNote:Note = note.parent;
			if (parentNote.wasGoodHit && parentNote.tail.length > 0) {
				for (child in parentNote.tail) if (child != note) {
					child.missed = true;
					child.canBeHit = false;
					child.ignoreNote = true;
					child.tooLate = true;
				}
			}
		}

		if(instakillOnMiss)
		{
			vocals.volume = 0;
			opponentVocals.volume = 0;
			doDeathCheck(true);
		}

		var lastCombo:Int = combo;
		combo = 0;

		health -= subtract * healthLoss;
		if(!practiceMode && !jackass) songScore -= 10;
		if(!endingSong) songMisses++;
		totalPlayed++;
		RecalculateRating(true);

		// play character anims
		var char:Character = boyfriend;
		if((note != null && note.gfNote) || (SONG.notes[curSection] != null && SONG.notes[curSection].gfSection)) char = gf;

		if(char != null && (note == null || !note.noMissAnimation) && char.hasMissAnimations)
		{
			var suffix:String = '';
			if(note != null) suffix = note.animSuffix;

			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, direction)))] + 'miss' + suffix;
			char.playAnim(animToPlay, true);

			if(char != gf && lastCombo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
				gf.specialAnim = true;
			}
		}
		vocals.volume = 0;
		//popUpScore(note);

		if(lastCombo > 5) {
			var broke:FlxSprite = new FlxSprite().loadGraphic(Paths.image(PlayState.isPixelStage ? 'pixelUI/comboBroke-pixel' : 'comboBroke'));
			broke.screenCenter();
			broke.x = FlxG.width * 0.35 - 40;
			broke.y -= 60;
			broke.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			broke.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			broke.visible = (!ClientPrefs.data.hideHud && showCombo);
			broke.x += ClientPrefs.data.comboOffset[0];
			broke.y -= ClientPrefs.data.comboOffset[1];
			broke.antialiasing = ClientPrefs.data.antialiasing;
			//broke.y += 60;
			broke.velocity.x += FlxG.random.int(1, 10) * playbackRate;
			comboGroup.add(broke);
			FlxTween.tween(broke, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: tween -> broke.destroy(),
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});
			if (ClientPrefs.data.ratingType == 'Invisible') {
				broke.visible = false;
			}
			else {
				broke.cameras = [LuaUtils.cameraFromString(ClientPrefs.data.ratingType)];
			}
			if (!PlayState.isPixelStage)
			{
				broke.setGraphicSize(Std.int(broke.width * 0.7));
			}
			else
			{
				broke.setGraphicSize(Std.int(broke.width * daPixelZoom * 0.75));
			}
		}
		else {
		
			var missSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(PlayState.isPixelStage ? 'pixelUI/miss-pixel' : 'miss'));
			missSpr.screenCenter();
			missSpr.x = FlxG.width * 0.35 - 40;
			missSpr.y -= 60;
			missSpr.acceleration.y = FlxG.random.int(200, 300) * playbackRate * playbackRate;
			missSpr.velocity.y -= FlxG.random.int(140, 160) * playbackRate;
			missSpr.visible = (!ClientPrefs.data.hideHud && showCombo);
			missSpr.x += ClientPrefs.data.comboOffset[0];
			missSpr.y -= ClientPrefs.data.comboOffset[1];
			missSpr.antialiasing = ClientPrefs.data.antialiasing;
			//missSpr.y += 60;
			missSpr.velocity.x += FlxG.random.int(1, 10) * playbackRate;
			comboGroup.add(missSpr);
			FlxTween.tween(missSpr, {alpha: 0}, 0.2 / playbackRate, {
				onComplete: tween -> missSpr.destroy(),
				startDelay: Conductor.crochet * 0.002 / playbackRate
			});
			if (ClientPrefs.data.ratingType == 'Invisible') {
				missSpr.visible = false;
			}
			else {
				missSpr.cameras = [LuaUtils.cameraFromString(ClientPrefs.data.ratingType)];
			}
			if (!PlayState.isPixelStage)
			{
				missSpr.setGraphicSize(Std.int(missSpr.width * 0.7));
			}
			else
			{
				missSpr.setGraphicSize(Std.int(missSpr.width * daPixelZoom * 0.1));
			}
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		var result:Dynamic = callOnLuas('opponentNoteHitPre', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHitPre', [note]);

		if (songName != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = note.animSuffix;

			if (SONG.notes[curSection] != null)
				if (SONG.notes[curSection].altAnim && !SONG.notes[curSection].gfSection)
					altAnim = '-alt';

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))] + altAnim;
			if(note.gfNote) char = gf;

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
			}
		}

		if (note.isSustainNote) dad.holdTimer = 0;

		if(opponentVocals.length <= 0) vocals.volume = 1;
		//	strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);

		if(!ClientPrefs.data.oldHold) {
			if (note.isSustainNote) {
				var spr = opponentStrums.members[note.noteData];
				if(note.animation.curAnim.name.endsWith('end')) {
					spr.resetAnim = note.height / .45 / songSpeed / note.multSpeed / playbackRate * .001;
				} else spr.resetAnim = 0;
			} else {
				strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
			}
		} else {
			strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		}


		note.hitByOpponent = true;

		if (opponentDrain && health > 0.1) health -= note.hitHealth * hpDrainLevel * polyphony;

		spawnHoldSplashOnNote(note);
		
		var result:Dynamic = callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('opponentNoteHit', [note]);

		if(!note.noteSplashData.disabled && !note.isSustainNote && ClientPrefs.data.oppSplashes) spawnNoteSplashOnNoteOpp(note);

		if (!note.isSustainNote) invalidateNote(note);
	}

	public function goodNoteHit(note:Note):Void
	{
		if(note.wasGoodHit) return;
		if(cpuControlled && note.ignoreNote) return;
		if (note.isSustainNote) boyfriend.holdTimer = 0;

		var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
		var leData:Int = Math.round(Math.abs(note.noteData));
		var leType:String = note.noteType;

		var result:Dynamic = callOnLuas('goodNoteHitPre', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHitPre', [note]);

		note.wasGoodHit = true;

		if (ClientPrefs.data.hitsoundVolume > 0 && !note.hitsoundDisabled)
			FlxG.sound.play(Paths.sound(note.hitsound), ClientPrefs.data.hitsoundVolume);

		if(note.hitCausesMiss) {
			if(!note.noMissAnimation) {
				switch(note.noteType) {
					case 'Hurt Note': //Hurt note
						if(boyfriend.animOffsets.exists('hurt')) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}
			}

			noteMiss(note);
			if(!note.noteSplashData.disabled && !note.isSustainNote) spawnNoteSplashOnNote(note);
			if(!note.isSustainNote) invalidateNote(note);
			return;
		}

		if(!note.noAnimation) {
			var animToPlay:String = singAnimations[Std.int(Math.abs(Math.min(singAnimations.length-1, note.noteData)))];

			var char:Character = boyfriend;
			var animCheck:String = 'hey';
			if(note.gfNote)
			{
				char = gf;
				animCheck = 'cheer';
			}

			if(char != null)
			{
				char.playAnim(animToPlay + note.animSuffix, true);
				char.holdTimer = 0;

				if(note.noteType == 'Hey!') {
					if(char.animOffsets.exists(animCheck)) {
						char.playAnim(animCheck, true);
						char.specialAnim = true;
						char.heyTimer = 0.6;
					}
				}
				if(note.noteType == 'Warning Note') {
					if(boyfriend.animOffsets.exists('dodge')) {
						boyfriend.playAnim('dodge', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
						shoot = new FlxSound().loadEmbedded(Paths.sound('shoot'));
						FlxG.sound.list.add(shoot);
						shoot.play(true);
						camGame.shake(0.20, 0.02);
					}
				}
				if(note.noteType == 'Ex Note') {
					if(boyfriend.animOffsets.exists('hurt')) {
						boyfriend.playAnim('hurt', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
						death = new FlxSound().loadEmbedded(Paths.sound('death'));
						FlxG.sound.list.add(death);
						death.play(true);
					}
				}
			}
		}
		
		//this shit is so ass oml
		if(!ClientPrefs.data.oldHold) {
			if(!cpuControlled)
			{
				var spr = playerStrums.members[note.noteData];
				if (spr != null && spr.animation.name != 'confirm') spr.playAnim('confirm', true);
			} else {
				if (note.isSustainNote) {
					var spr = playerStrums.members[note.noteData];
					if(note.animation.curAnim.name.endsWith('end')) {
						spr.resetAnim = note.height / .45 / songSpeed / note.multSpeed / playbackRate * .001;
					} else spr.resetAnim = 0;
				} else {
					strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
				}
			}
		} else {
			if(!cpuControlled)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.stepCrochet * 1.25 / 1000 / playbackRate);
		}
		vocals.volume = 1;

		spawnHoldSplashOnNote(note);
		if (!note.isSustainNote)
		{
			combo++;
			if(combo > 9999) combo = 9999;
			popUpScore(note);
		}
		if(note.rating <= 'bad' && ClientPrefs.data.badSounds) {
			FlxG.sound.play(Paths.soundRandom('badnoise', 1, 3), FlxG.random.float(0.2, 0.4));
		}
		var gainHealth:Bool = true; // prevent health gain, *if* sustains are treated as a singular note
		if (guitarHeroSustains && note.isSustainNote) gainHealth = false;
		if (gainHealth) health += note.hitHealth * healthGain;

		var result:Dynamic = callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
		if(result != LuaUtils.Function_Stop && result != LuaUtils.Function_StopHScript && result != LuaUtils.Function_StopAll) callOnHScript('goodNoteHit', [note]);

		if(!note.isSustainNote) {
			invalidateNote(note);
			if (note.rating == 'bad' || note.rating == 'shit') {
				makeGhostNote(note);
			}
		}
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	public function spawnHoldSplashOnNote(note:Note) {
		if (!note.isSustainNote && note.tail.length != 0 && note.tail[note.tail.length - 1].extraData['holdSplash'] == null) {
			spawnHoldSplash(note);
		} else if (note.isSustainNote) {
			final end:Note = StringTools.endsWith(note.animation.curAnim.name, 'end') ? note : note.parent.tail[note.parent.tail.length - 1];
			if (end != null) {
				var leSplash:SustainSplash = end.extraData['holdSplash'];
				if (leSplash == null && !end.parent.wasGoodHit) {
					spawnHoldSplash(note);
				} else if (leSplash != null && !leSplash.visible) {
					leSplash.visible = true;
				}
			}
		}
	}

	public function spawnHoldSplash(note:Note) {
		var end:Note = note.isSustainNote ? note.parent.tail[note.parent.tail.length - 1] : note.tail[note.tail.length - 1];
		var splash:SustainSplash = grpHoldSplashes.recycle(SustainSplash);
		splash.setupSusSplash(strumLineNotes.members[end.noteData + (end.mustPress ? 4 : 0)], end, playbackRate);
		grpHoldSplashes.add(splash);
	}

	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplashOnNoteOpp(note:Note) {
		if(note != null) {
			var strum:StrumNote = opponentStrums.members[note.noteData];
			if(strum != null)
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, note);
		grpNoteSplashes.add(splash);
	}

	/*
	function opponentNoteHit(i, d, _, s)
    	if not s then
    	    callMethod('spawnNoteSplash', {getProperty('opponentStrums.members['..d..'].x'), getProperty('opponentStrums.members['..d..'].y'), d, instanceArg('notes.members['..i..']')})
    	end
	end
	*/

	override function destroy() {
		#if LUA_ALLOWED
		for (lua in luaArray)
		{
			lua.call('onDestroy', []);
			lua.stop();
		}
		luaArray = [];
		FunkinLua.customFunctions.clear();
		#end

		#if HSCRIPT_ALLOWED
		for (script in hscriptArray)
			if(script != null)
			{
				script.call('onDestroy');
				script.destroy();
			}

		while (hscriptArray.length > 0)
			hscriptArray.pop();
		#end

		if(ClientPrefs.data.uilook == 'Dave' || ClientPrefs.data.uilook == 'Gapple') {
			Main.fpsVar.defaultTextFormat = new TextFormat("_sans", 14, 0xFFFFFF, false);
			ClientPrefs.data.iconBops = ogIconBounce;
		}
		if(ClientPrefs.data.uilook == 'Forever') {
			Main.fpsVar.defaultTextFormat = new TextFormat('_sans', 14, 0xFFFFFF);
    		Main.fpsVar.x = 10;
    		Main.fpsVar.y = 3;
   			Main.fpsVar.updateText = oldUpdate;
		}

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		FlxG.animationTimeScale = 1;
		#if FLX_PITCH FlxG.sound.music.pitch = 1; #end
		Note.globalRgbShaders = [];
		backend.NoteTypesConfig.clearNoteTypesData();
		instance = null;
		super.destroy();
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		if (SONG.needsVoices && FlxG.sound.music.time >= -ClientPrefs.data.noteOffset)
		{
			var timeSub:Float = Conductor.songPosition - Conductor.offset;
			var syncTime:Float = 20 * playbackRate;
			if (Math.abs(FlxG.sound.music.time - timeSub) > syncTime ||
			(vocals.length > 0 && Math.abs(vocals.time - timeSub) > syncTime) ||
			(opponentVocals.length > 0 && Math.abs(opponentVocals.time - timeSub) > syncTime))
			{
				resyncVocals();
			}
		}

		if(ClientPrefs.data.advancedDiscord) {

			#if desktop
			if (isStoryMode)
    			detailsText = WeekData.getCurrentWeek().weekName + " - " + scoreTxt.text;
			else
    			detailsText = scoreTxt.text;
			DiscordClient.changePresence(detailsText, SONG.song
    			+ " ("
    			+ storyDifficultyText
    			+ ")", iconP2.getCharacter(), true, songLength
    			- Conductor.songPosition);
			#end
		}

		super.stepHit();

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnScripts('curStep', curStep);
		callOnScripts('onStepHit');
	}

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
			notes.sort(FlxSort.byY, ClientPrefs.data.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);

		dancingLeft = !dancingLeft;

		if (ClientPrefs.data.iconBops == "OS") {
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);

			if (dancingLeft){
				iconP1.angle = 8; iconP2.angle = 8; // maybe i should do it with tweens, but i'm lazy // i'll make it in -1.0.0, i promise
			} else { 
				iconP1.angle = -8; iconP2.angle = -8;
			}
		}

		if(ClientPrefs.data.iconBops == "Psych")
		{
			iconP1.scale.set(1.2, 1.2);
			iconP2.scale.set(1.2, 1.2);
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == "None")
		{
			iconP1.scale.set(1, 1);
			iconP2.scale.set(1, 1);
	
			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if (ClientPrefs.data.iconBops == 'Dave and Bambi' || ClientPrefs.data.uilook == 'Dave') {
			var funny:Float = Math.max(Math.min(healthBar.percent,1.9),0.01);

			iconP2.setGraphicSize(Std.int(iconP2.width + (50 / funny)),Std.int(iconP2.height - (25 * funny)));
			iconP1.setGraphicSize(Std.int(iconP1.width + (50 / ((2 - funny) + 0.1))),Std.int(iconP1.height - (25 * ((2 - funny) + 0.1))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == "Golden Apple" || ClientPrefs.data.uilook == 'Gapple')
		{
			var funny:Float = (healthBar.percent * 0.01) + 0.01;
	
			//health icon bounce but epic
			if (curBeat % gfSpeed == 0)
			{
				curBeat % (gfSpeed * 2) == 0 ? {
					iconP1.scale.set(1.1, 0.8);
					iconP2.scale.set(1.1, 1.3);
						
					FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				} : {
					iconP1.scale.set(1.1, 1.3);
					iconP2.scale.set(1.1, 0.8);
	
					FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
					FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				}
	
				FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			}
		}
		if(ClientPrefs.data.iconBops == "Stretchy")
		{
			var funny:Float = Math.max(Math.min(healthBar.percent,1.9),0.1);//Math.clamp(healthBar.value,0.02,1.98);//Math.min(Math.min(healthBar.value,1.98),0.02);
					
			iconP2.setGraphicSize(Std.int(iconP2.width + (50 * funny)),Std.int(iconP2.height - (25 * funny)));
			iconP1.setGraphicSize(Std.int(iconP1.width + (50 * ((2 - funny) + 0.1))),Std.int(iconP1.height - (25 * ((2 - funny) + 0.1))));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(ClientPrefs.data.iconBops == "OG") {
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}
		if(gf.curCharacter == 'nene') {
			abot.animation.play("i");
		}

		characterBopper(curBeat);

		super.beatHit();
		lastBeatHit = curBeat;

		setOnScripts('curBeat', curBeat);
		callOnScripts('onBeatHit');
	}

	public function characterBopper(beat:Int):Void
	{
		if (gf != null && beat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.getAnimationName().startsWith('sing') && !gf.stunned)
			gf.dance();
		if (boyfriend != null && beat % boyfriend.danceEveryNumBeats == 0 && !boyfriend.getAnimationName().startsWith('sing') && !boyfriend.stunned)
			boyfriend.dance();
		if (dad != null && beat % dad.danceEveryNumBeats == 0 && !dad.getAnimationName().startsWith('sing') && !dad.stunned)
			dad.dance();
	}

	public function playerDance():Void
	{
		var anim:String = boyfriend.getAnimationName();
		if(boyfriend.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * boyfriend.singDuration && anim.startsWith('sing') && !anim.endsWith('miss'))
			boyfriend.dance();
	}

	override function sectionHit()
	{
		if (SONG.notes[curSection] != null)
		{
			if (generatedMusic && !endingSong && !isCameraOnForcedPos)
				moveCameraSection();

			if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.data.camZooms)
			{
				FlxG.camera.zoom += 0.015 * camZoomingMult;
				camHUD.zoom += 0.03 * camZoomingMult;
			}

			if (SONG.notes[curSection].changeBPM)
			{
				Conductor.bpm = SONG.notes[curSection].bpm;
				setOnScripts('curBpm', Conductor.bpm);
				setOnScripts('crochet', Conductor.crochet);
				setOnScripts('stepCrochet', Conductor.stepCrochet);
			}
			setOnScripts('mustHitSection', SONG.notes[curSection].mustHitSection);
			setOnScripts('altAnim', SONG.notes[curSection].altAnim);
			setOnScripts('gfSection', SONG.notes[curSection].gfSection);
		}
		super.sectionHit();

		setOnScripts('curSection', curSection);
		callOnScripts('onSectionHit');
	}

	#if LUA_ALLOWED
	public function startLuasNamed(luaFile:String)
	{
		#if MODS_ALLOWED
		var luaToLoad:String = Paths.modFolders(luaFile);
		if(!FileSystem.exists(luaToLoad))
			luaToLoad = Paths.getSharedPath(luaFile);

		if(FileSystem.exists(luaToLoad))
		#elseif sys
		var luaToLoad:String = Paths.getSharedPath(luaFile);
		if(OpenFlAssets.exists(luaToLoad))
		#end
		{
			for (script in luaArray)
				if(script.scriptName == luaToLoad) return false;

			new FunkinLua(luaToLoad);
			return true;
		}
		return false;
	}
	#end

	#if HSCRIPT_ALLOWED
	public function startHScriptsNamed(scriptFile:String)
	{
		#if MODS_ALLOWED
		var scriptToLoad:String = Paths.modFolders(scriptFile);
		if(!FileSystem.exists(scriptToLoad))
			scriptToLoad = Paths.getSharedPath(scriptFile);
		#else
		var scriptToLoad:String = Paths.getSharedPath(scriptFile);
		#end

		if(FileSystem.exists(scriptToLoad))
		{
			if (SScript.global.exists(scriptToLoad)) return false;

			initHScript(scriptToLoad);
			return true;
		}
		return false;
	}

	public function initHScript(file:String)
	{
		try
		{
			var newScript:HScript = new HScript(null, file);
			if(newScript.parsingException != null)
			{
				addTextToDebug('ERROR ON LOADING: ${newScript.parsingException.message}', FlxColor.RED);
				newScript.destroy();
				return;
			}

			hscriptArray.push(newScript);
			if(newScript.exists('onCreate'))
			{
				var callValue = newScript.call('onCreate');
				if(!callValue.succeeded)
				{
					for (e in callValue.exceptions)
					{
						if (e != null)
						{
							var len:Int = e.message.indexOf('\n') + 1;
							if(len <= 0) len = e.message.length;
								addTextToDebug('ERROR ($file: onCreate) - ${e.message.substr(0, len)}', FlxColor.RED);
						}
					}

					newScript.destroy();
					hscriptArray.remove(newScript);
					trace('failed to initialize tea interp!!! ($file)');
				}
				else trace('initialized tea interp successfully: $file');
			}

		}
		catch(e)
		{
			var len:Int = e.message.indexOf('\n') + 1;
			if(len <= 0) len = e.message.length;
			addTextToDebug('ERROR - ' + e.message.substr(0, len), FlxColor.RED);
			var newScript:HScript = cast (SScript.global.get(file), HScript);
			if(newScript != null)
			{
				newScript.destroy();
				hscriptArray.remove(newScript);
			}
		}
	}
	#end

	public function callOnScripts(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var result:Dynamic = callOnLuas(funcToCall, args, ignoreStops, exclusions, excludeValues);
		if(result == null || excludeValues.contains(result)) result = callOnHScript(funcToCall, args, ignoreStops, exclusions, excludeValues);
		return result;
	}

	public function callOnLuas(funcToCall:String, args:Array<Dynamic> = null, ignoreStops = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;
		#if LUA_ALLOWED
		if(args == null) args = [];
		if(exclusions == null) exclusions = [];
		if(excludeValues == null) excludeValues = [LuaUtils.Function_Continue];

		var arr:Array<FunkinLua> = [];
		for (script in luaArray)
		{
			if(script.closed)
			{
				arr.push(script);
				continue;
			}

			if(exclusions.contains(script.scriptName))
				continue;

			var myValue:Dynamic = script.call(funcToCall, args);
			if((myValue == LuaUtils.Function_StopLua || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
			{
				returnVal = myValue;
				break;
			}

			if(myValue != null && !excludeValues.contains(myValue))
				returnVal = myValue;

			if(script.closed) arr.push(script);
		}

		if(arr.length > 0)
			for (script in arr)
				luaArray.remove(script);
		#end
		return returnVal;
	}

	public function callOnHScript(funcToCall:String, args:Array<Dynamic> = null, ?ignoreStops:Bool = false, exclusions:Array<String> = null, excludeValues:Array<Dynamic> = null):Dynamic {
		var returnVal:Dynamic = LuaUtils.Function_Continue;

		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = new Array();
		if(excludeValues == null) excludeValues = new Array();
		excludeValues.push(LuaUtils.Function_Continue);

		var len:Int = hscriptArray.length;
		if (len < 1)
			return returnVal;
		for(i in 0...len) {
			var script:HScript = hscriptArray[i];
			if(script == null || !script.exists(funcToCall) || exclusions.contains(script.origin))
				continue;

			var myValue:Dynamic = null;
			try {
				var callValue = script.call(funcToCall, args);
				if(!callValue.succeeded)
				{
					var e = callValue.exceptions[0];
					if(e != null)
					{
						var len:Int = e.message.indexOf('\n') + 1;
						if(len <= 0) len = e.message.length;
						addTextToDebug('ERROR (${callValue.calledFunction}) - ' + e.message.substr(0, len), FlxColor.RED);
					}
				}
				else
				{
					myValue = callValue.returnValue;
					if((myValue == LuaUtils.Function_StopHScript || myValue == LuaUtils.Function_StopAll) && !excludeValues.contains(myValue) && !ignoreStops)
					{
						returnVal = myValue;
						break;
					}

					if(myValue != null && !excludeValues.contains(myValue))
						returnVal = myValue;
				}
			}
		}
		#end

		return returnVal;
	}

	public function setOnScripts(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		if(exclusions == null) exclusions = [];
		setOnLuas(variable, arg, exclusions);
		setOnHScript(variable, arg, exclusions);
	}

	public function setOnLuas(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if LUA_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in luaArray) {
			if(exclusions.contains(script.scriptName))
				continue;

			script.set(variable, arg);
		}
		#end
	}

	public function setOnHScript(variable:String, arg:Dynamic, exclusions:Array<String> = null) {
		#if HSCRIPT_ALLOWED
		if(exclusions == null) exclusions = [];
		for (script in hscriptArray) {
			if(exclusions.contains(script.origin))
				continue;

			if(!instancesExclude.contains(variable))
				instancesExclude.push(variable);
			script.set(variable, arg);
		}
		#end
	}

	function strumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = opponentStrums.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating(badHit:Bool = false) {
		setOnScripts('score', songScore);
		setOnScripts('misses', songMisses);
		setOnScripts('hits', songHits);
		setOnScripts('combo', combo);

		var ret:Dynamic = callOnScripts('onRecalculateRating', null, true);
		if(ret != LuaUtils.Function_Stop)
		{
			ratingName = '?';
			if(totalPlayed != 0) //Prevent divide by 0
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				if(ratingPercent < 1)
					for (i in 0...ratingStuff.length-1)
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
			}
			fullComboFunction();
		}
		updateScore(badHit); // score will only update after rating is calculated, if it's a badHit, it shouldn't bounce
		setOnScripts('rating', ratingPercent);
		setOnScripts('ratingName', ratingName);
		setOnScripts('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null)
	{
		if(chartingMode) return;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice') || ClientPrefs.getGameplaySetting('botplay'));
		if(cpuControlled) return;

		for (name in achievesToCheck) {
			if(!Achievements.exists(name)) continue;

			var unlock:Bool = false;
			if (name != WeekData.getWeekFileName() + '_nomiss') // common achievements
			{
				switch(name)
				{
					case 'ur_bad':
						unlock = (ratingPercent < 0.2 && !practiceMode);

					case 'ur_good':
						unlock = (ratingPercent >= 1 && !usedPractice);

					case 'oversinging':
						unlock = (boyfriend.holdTimer >= 10 && !usedPractice);

					case 'hype':
						unlock = (!boyfriendIdled && !usedPractice);

					case 'two_keys':
						unlock = (!usedPractice && keysPressed.length <= 2);

					case 'toastie':
						unlock = (!ClientPrefs.data.cacheOnGPU && !ClientPrefs.data.shaders && ClientPrefs.data.lowQuality && !ClientPrefs.data.antialiasing);

					case 'debugger':
						unlock = (songName == 'test' && !usedPractice);
				}
			}
			else // any FC achievements, name should be "weekFileName_nomiss", e.g: "week3_nomiss";
			{
				if(isStoryMode && campaignMisses + songMisses < 1 && Difficulty.getString().toUpperCase() == 'HARD'
					&& storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
					unlock = true;
			}

			if(unlock) Achievements.unlock(name);
		}
	}
	#end
	#if (!flash && sys)
	public var runtimeShaders:Map<String, Array<String>> = new Map<String, Array<String>>();
	public function createRuntimeShader(name:String):FlxRuntimeShader
	{
		if(!ClientPrefs.data.shaders) return new FlxRuntimeShader();

		#if (!flash && MODS_ALLOWED && sys)
		if(!runtimeShaders.exists(name) && !initLuaShader(name))
		{
			FlxG.log.warn('Shader $name is missing!');
			return new FlxRuntimeShader();
		}

		var arr:Array<String> = runtimeShaders.get(name);
		return new FlxRuntimeShader(arr[0], arr[1]);
		#else
		FlxG.log.warn("Platform unsupported for Runtime Shaders!");
		return null;
		#end
	}

	public function initLuaShader(name:String, ?glslVersion:Int = 120)
	{
		if(!ClientPrefs.data.shaders) return false;

		#if (MODS_ALLOWED && !flash && sys)
		if(runtimeShaders.exists(name))
		{
			FlxG.log.warn('Shader $name was already initialized!');
			return true;
		}

		for (folder in Mods.directoriesWithFile(Paths.getSharedPath(), 'shaders/'))
		{
			var frag:String = folder + name + '.frag';
			var vert:String = folder + name + '.vert';
			var found:Bool = false;
			if(FileSystem.exists(frag))
			{
				frag = File.getContent(frag);
				found = true;
			}
			else frag = null;

			if(FileSystem.exists(vert))
			{
				vert = File.getContent(vert);
				found = true;
			}
			else vert = null;

			if(found)
			{
				runtimeShaders.set(name, [frag, vert]);
				//trace('Found shader $name!');
				return true;
			}
		}
			#if (LUA_ALLOWED || HSCRIPT_ALLOWED)
			addTextToDebug('Missing shader $name .frag AND .vert files!', FlxColor.RED);
			#else
			FlxG.log.warn('Missing shader $name .frag AND .vert files!');
			#end
		#else
		FlxG.log.warn('This platform doesn\'t support Runtime Shaders!');
		#end
		return false;
	}
	function truncateFloat(number:Float, precision:Int):Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}
	
	function reloadIcons(char:String) {
		@:privateAccess {
			if (char.toLowerCase() == 'dad' || char.toLowerCase() == 'opponent' || char == '0') {
				ogIconSize.shift();
				ogIconSize.insert(0, [Std.int(iconP2._frame.frame.width) + Std.int(iconP2._frame.frame.height)]);
			} else {
				ogIconSize.pop();
				ogIconSize.push([Std.int(iconP1._frame.frame.width) + Std.int(iconP1._frame.frame.height)]);
			}
		}
	}

	function makeGhostNote(note:Note) {
		var ghost = new Note(note.strumTime, note.noteData, null, note.isSustainNote);
		ghost.noteType = 'MISSED_NOTE';
		ghost.multAlpha = note.multAlpha * .5;
		ghost.mustPress = note.mustPress;
		ghost.ignoreNote = true;
		ghost.blockHit = true;
		notes.add(ghost);
		ghost.rgbShader.r.saturation = .2;
		ghost.rgbShader.g.saturation = .2;
		ghost.rgbShader.b.saturation = .2;
		ghost.rgbShader.r = ghost.rgbShader.r;
		ghost.rgbShader.g = ghost.rgbShader.g;
		ghost.rgbShader.b = ghost.rgbShader.b;
	}
	
	function setObjectOrderSource(obj:FlxBasic, position:Int) {
		remove(obj);
		insert(position, obj);
	}

	function determineRank(acc:Float):String {
		for (i in ranks) if (i[0] <= acc) return i[1];
		return acc <= 65 && acc > 0 ? 'F' : 'N/A';
	}
	
	function fpsAdjust(num:Float):Float {
		return num * (60 / ClientPrefs.data.framerate);
	}
	
	function getMinAndMax(value1:Float, value2:Float):Array<Float>
	{
		var minAndMaxs:Array<Float> = [];
	
		var min = Math.min(value1, value2);
		var max = Math.max(value1, value2);
	
		minAndMaxs.push(min);
		minAndMaxs.push(max);
	
		return minAndMaxs;
	}	
	#end
}