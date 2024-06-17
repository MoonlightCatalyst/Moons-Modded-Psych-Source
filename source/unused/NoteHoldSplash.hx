package objects;

import flixel.util.FlxColor;
import objects.NoteSplash.PixelSplashShader;
import flixel.group.FlxTypedSpriteGroup;

import backend.animation.PsychAnimationController;
import shaders.RGBPalette;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;

import states.PlayState;

var coverGroup:FlxTypedSpriteGroup<FlxSprite>;
var coverSplashGroup:FlxTypedSpriteGroup<FlxSprite>;
var prevFrame:Int = 0;
var rgbs:Array = []; //rgb shader references for hold covers
var holdCovers:Array = [];
var playHits:Array = [];
var playPresses:Array = [];
var holdsData:Array = [];

class NoteHoldSplash extends FlxSprite {

        override function createPost() {
        super.createPost();
	
        coverGroup = new FlxTypedSpriteGroup();
	    coverGroup.cameras = [game.camHUD];
	    game.add(coverGroup);
	    coverSplashGroup = new FlxTypedSpriteGroup();
	    coverSplashGroup.cameras = [game.camHUD];
	    game.add(coverSplashGroup);
	
	    var pixel:Float = (PlayState.isPixelStage ? PlayState.daPixelZoom : 1);
	    var i = 0;
	    for (strum in game.strumLineNotes.members) {
		    strum.animation.rename('confirm', 'hit');
		
		    var cover = new FlxSprite();
		    cover.frames = Paths.getSparrowAtlas('holdCoverShader');
		    cover.antialiasing = ClientPrefs.data.antialiasing;
		    cover.animation.addByPrefix('start', 'holdCoverStart', 24, false);
		    cover.animation.addByPrefix('loop', 'holdCover0', 24, true);
		    cover.animation.play('loop', true);
		    cover.offset.set(106, 100);
		    cover.visible = false;
		
		    var rgb = new PixelSplashShader();
		    rgb.uBlocksize.value = [pixel, pixel];
		    cover.shader = rgb;
		    rgbs.push(rgb);
		    holdCovers.push({cover: cover, strum: strum});
		    coverSplashGroup.add(cover);
		
		    i ++;
	    }
	    return Function_Continue;
    }
    function inArray(array, pos) { //array access lags workaround???
        var i = 0;
	    if (pos >= array.length) return null;
        for (item in array) {
            if (i == pos) { return item; }
            i ++;
        }
        return null;
    }

    override function onKeyRelease(k) {
    	var data = inArray(holdCovers, k + game.opponentStrums.length);
    	if (data == null) return Function_Continue;
    	var cover = data.cover;
    	if (cover != null && cover.animation.curAnim.name != 'end') cover.visible = false;
    	return Function_Continue;
    }
    function popCover(note, strum, cover, rgb) {
	    var strum = cover.strum;
    	if (strum != null && !strum.visible) return;
	
    	cover.visible = true;
    	if (rgb != null) {
    		rgb.r.value = int2rgbfloat(note.rgbShader.r);
    		rgb.g.value = int2rgbfloat(note.rgbShader.g); //blue color channel is not used
    	}
    	cover.animation.play('start', true);
    }
    function spawnCoverSparks(cover) {
    	var coverSplash:FlxSprite = new FlxSprite(); //coverSplashGroup.recycle(FlxSprite); figure out why this doesnt work correctly later
    	coverSplash.frames = Paths.getSparrowAtlas('holdCoverShader');
    	coverSplash.setPosition(cover.x, cover.y);
    	coverSplash.offset.x = cover.offset.x;
    	coverSplash.offset.y = cover.offset.y;
    	coverSplash.antialiasing = ClientPrefs.data.antialiasing;
    	coverSplash.animation.addByPrefix('end', 'holdCoverEnd', 24, false);
    	coverSplash.animation.play('end', true);
    	coverSplash.shader = cover.shader;
    	coverSplash.animation.finishCallback = () -> coverSplash.destroy();
    	coverSplashGroup.add(coverSplash);
    }
    function coverLogic(note, end) {
	    if (note.noteSplashData.disabled) return;
	
	    var data = note.noteData;
	    if (note.mustPress) data += game.opponentStrums.length;
	
	    var coverData = inArray(holdCovers, data);
	    var rgb = inArray(rgbs, data);
	
	    if (coverData == null) return;
	    var strum = inArray(note.mustPress ? playerStrums.members : opponentStrums.members, note.noteData);
	    if (strum == null) return;
	
	    var cover = coverData.cover;
	    if (note.isSustainNote) {
	    	if (!cover.visible || cover.animation.curAnim.name == 'end') popCover(note, strum, cover, rgb);
	    	if ((end || Conductor.songPosition >= note.strumTime + Conductor.stepCrochet) && StringTools.endsWith(note.animation.curAnim.name, 'holdend')) {
	    		if (!note.mustPress) {
	    			cover.visible = false;
	    			strum.playAnim('static');
	    		} else if (strum.animation.curAnim.name != 'static') strum.playAnim(game.cpuControlled ? 'static' : 'pressed');
	    		strum.animation.finishCallback = null;
	    		strum.resetAnim = 0;
	    		if (cover.visible && note.mustPress) {
	    			cover.visible = false;
	    			spawnCoverSparks(cover);
	    		}
	    	}
	    } else if (note.tail.length > 0) popCover(note, strum, cover, rgb);
    }
    override function opponentNoteHit(note) {
	    coverLogic(note, false);
	    if (note.isSustainNote) game.dad.holdTimer = 0;
	    else {
		    var strum = inArray(game.opponentStrums.members, note.noteData);
		    if (strum != null) {
			    strum.playAnim('hit', true);
			    strum.resetAnim = (note.tail.length > 0 ? note.sustainLength : Conductor.crochet) / 1000;
			    if (note.tail.length > 0) {
				    strum.animation.finishCallback = () -> {
				    	strum.playAnim('hit', true);
				    	strum.animation.finishCallback = null;
				    }
			    }
		    }
	    }
    }
    function makeGhostNote(note) {
	    var ghost = new Note(note.strumTime, note.noteData, null, note.isSustainNote);
	    ghost.noteType = 'MISSED_NOTE';
	    ghost.multAlpha = note.multAlpha * .5;
	    ghost.mustPress = note.mustPress;
	    ghost.ignoreNote = true;
	    ghost.blockHit = true;
	    game.notes.add(ghost);
	    ghost.rgbShader.r = int_desat(ghost.rgbShader.r, 0.5); //desaturate note
	    ghost.rgbShader.g = int_desat(ghost.rgbShader.g, 0.5);
	    ghost.rgbShader.b = int_desat(ghost.rgbShader.b, 0.5);
    }
    override function goodNoteHit(note) {
	    var strum = inArray(game.playerStrums.members, note.noteData);
	    if (note.isSustainNote) {
	    	game.boyfriend.holdTimer = 0;
	    	if (strum != null) strum.resetAnim = Conductor.crochet / 1000;
	    } else if (strum != null) {
	    	playHits.push({strum: strum, hold: note.sustainLength > 0});
	    	for (press in playPresses) if (press.strum == strum) playPresses.remove(press);
	    	if (note.tail.length == 0) playPresses.push({strum: strum, time: note.strumTime + Conductor.crochet});
	    	strum.resetAnim = ((note.tail.length > 0 || game.cpuControlled) ? Conductor.crochet : 0) / 1000;
	    }
	    coverLogic(note, false);
	    return Function_Continue;
    }
    override function update(elapsed:Float)
    {
        for (n in game.notes) {
	    	if (n.clipRect != null && n.clipRect.height <= 0 && !n.extraData.get('consumed') && StringTools.endsWith(n.animation.curAnim.name, 'end')) {
	    		n.extraData.set('consumed', true); //prevent it running more than once
	    		coverLogic(n, true);
	    	}
	    }
	    return Function_Continue;
    }
    override function updatePost(elapsed:Float) {
        while (playHits.length > 0) { //psych engine is a meanie
	    	var i = playHits.shift();
	    	var strum = i.strum;
	    	if (strum == null) continue;
	    	strum.playAnim('hit', true);
	    	if (i.hold) {
	    		strum.animation.finishCallback = () -> {
	    			strum.playAnim('hit', true);
	    			strum.animation.finishCallback = null;
	    		}
	    	}
	    }
	    for (press in playPresses) {
		    if (Conductor.songPosition >= press.time) {
		    	var strum = press.strum;
		    	if (strum != null && strum.animation.curAnim.name == 'hit' && strum.resetAnim <= 0) {
		    		strum.animation.finishCallback = null;
		    		strum.playAnim('pressed');
		    		strum.resetAnim = 0;
		    	}
		    	playPresses.remove(press);
		    }
	    }
	    for (cover in holdCovers) {
	    	var instance = cover.cover;
	    	var strum = cover.strum;
	    	if (strum != null) {
	    		instance.setPosition(strum.x, strum.y);
	    		instance.alpha = (strum.alpha > 0 ? 1 : 0);
	    		if (strum.animation.curAnim.name != 'hit') instance.visible = false;
	    	}
	    	if (instance.animation.curAnim.finished) instance.animation.play('loop', true);
	    }
	    return Function_Continue;
    }

    //RGB FUNCTIONS CAUSE CUSTOMFLXCOLOR IS ASS
    //(functions taken directly from FlxColor)
    function int_desat(col, sat) { //except this one
    	var hsv = rgb2hsv(int2rgb(col));
    	hsv.saturation *= (1 - sat);
    	var rgb = hsv2rgb(hsv);
    	return FlxColor.fromRGBFloat(rgb.red, rgb.green, rgb.blue);
    }
    function int2rgbfloat(col) return [((col >> 16) & 0xff) / 255, ((col >> 8) & 0xff) / 255, (col & 0xff) / 255]; //or this one (lol)
    function int2rgb(col) return {red: (col >> 16) & 0xff, green: (col >> 8) & 0xff, blue: col & 0xff}; //or this one
    function rgb2hsv(col) {
    	var hueRad = Math.atan2(Math.sqrt(3) * (col.green - col.blue), 2 * col.red - col.green - col.blue);
    	var hue:Float = 0;
    	if (hueRad != 0) hue = 180 / Math.PI * hueRad;
    	hue = hue < 0 ? hue + 360 : hue;
    	var bright:Float = Math.max(col.red, Math.max(col.green, col.blue));
    	var sat:Float = (bright - Math.min(col.red, Math.min(col.green, col.blue))) / bright;
	    return {hue: hue, saturation: sat, brightness: bright};
    }
    function hsv2rgb(col) {
	    var chroma = col.brightness * col.saturation;
	    var match = col.brightness - chroma;
	
	    var hue:Float = col.hue % 360;
	    var hueD = hue / 60;
	    var mid = chroma * (1 - Math.abs(hueD % 2 - 1)) + match;
	    chroma += match;
	
	    chroma /= 255; //joy emoji
	    mid /= 255;
	    match /= 255;

	    switch (Std.int(hueD)) {
	    	case 0: return {red: chroma, green: mid, blue: match};
	    	case 1: return {red: mid, green: chroma, blue: match};
	    	case 2: return {red: match, green: chroma, blue: mid};
	    	case 3: return {red: match, green: mid, blue: chroma};
	    	case 4: return {red: mid, green: match, blue: chroma};
	    	case 5: return {red: chroma, green: match, blue: mid};
	    }
    }
}