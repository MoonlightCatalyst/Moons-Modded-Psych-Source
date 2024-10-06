package states.stages;

import shaders.AdjustColorShader;

import openfl.filters.ShaderFilter;
import flixel.addons.display.FlxRuntimeShader;

class Backstage extends BaseStage
{
    var characterShaders:Bool = true;

	var bg:BGSprite;
	//var rain:Rain;
    var colorShaderBF = new AdjustColorShader();
    var colorShaderDad = new AdjustColorShader();
    var colorShaderGF = new AdjustColorShader();

	override function create()
	{
        
        var stageBack:BGSprite = new BGSprite('erect/backDark', 729, -170, 1, 1);
		stageBack.scale.set(1, 1);
        //stageBack.updateHitbox();
		stageBack.alpha = 1;

        var brightLightSmall:BGSprite = new BGSprite('erect/brightLightSmall', 967, -103, 1.2, 1.2);
		brightLightSmall.scale.set(1, 1);
        //brightLightSmall.updateHitbox();
		brightLightSmall.alpha = 1;

        var audience = new FlxSprite(560, 290);
        audience.frames = Paths.getSparrowAtlas('erect/crowd');
        audience.animation.addByPrefix('idle', 'Symbol 2 instance 1', 12, true);
        audience.scrollFactor.set(0.8, 0.8);
        audience.scale.set(1, 1);
        audience.animation.play('idle');
        //audience.updateHitbox();

        var stageFront:BGSprite = new BGSprite('erect/bg', -603, -187, 1, 1);
		stageFront.scale.set(1, 1);
        //stageFront.updateHitbox();
		stageFront.alpha = 1;

        var server:BGSprite = new BGSprite('erect/server', -361, 205, 1, 1);
		server.scale.set(1, 1);
        //server.updateHitbox();
		server.alpha = 1;

        var light:BGSprite = new BGSprite('erect/lights', -601, -147, 1.2, 1.2);
		light.scale.set(1, 1);
        //light.updateHitbox();
		light.alpha = 1;

        var orangeLight:BGSprite = new BGSprite('erect/orangeLight', 189, -195, 1, 1);
		orangeLight.scale.set(1, 1);
        //orangeLight.updateHitbox();
		orangeLight.alpha = 1;

        var lightgreen:BGSprite = new BGSprite('erect/lightgreen', -171, 242, 1, 1);
		lightgreen.scale.set(1, 1);
        //lightgreen.updateHitbox();
		lightgreen.alpha = 1;

        var lightred:BGSprite = new BGSprite('erect/lightred', -101, 560, 1, 1);
		lightred.scale.set(1, 1);
        //lightred.updateHitbox();
		lightred.alpha = 1;

        var lightAbove:BGSprite = new BGSprite('erect/lightAbove', 804, -117, 1, 1);
		lightAbove.scale.set(1, 1);
        //lightAbove.updateHitbox();
		lightAbove.alpha = 1;

        insert(0, stageBack);
        insert(10, brightLightSmall);
        insert(5, audience);
        insert(20, stageFront);
        insert(30, server);
        insert(4000, light);
        insert(80, orangeLight);
        insert(40, lightgreen);
        insert(40, lightred);
        insert(4500, lightAbove); 
	}

    override function createPost() {
        super.createPost();
        if(!ClientPrefs.data.lowQuality) {
            game.boyfriend.shader = colorShaderBF;
            game.dad.shader = colorShaderDad;
            game.gf.shader = colorShaderGF;

            colorShaderBF.brightness.value = [-23];
            colorShaderBF.hue.value = [12];
            colorShaderBF.contrast.value = [7];
		    colorShaderBF.saturation.value = [0];

            colorShaderGF.brightness.value = [-30];
            colorShaderGF.hue.value = [-9];
            colorShaderGF.contrast.value = [-4];
		    colorShaderGF.saturation.value = [0];

            colorShaderDad.brightness.value = [-33];
            colorShaderDad.hue.value = [-32];
            colorShaderDad.contrast.value = [-23];
		    colorShaderDad.saturation.value = [0];
        }
    }
}