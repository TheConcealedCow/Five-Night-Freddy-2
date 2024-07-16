import tea.SScript;
import psychlua.LuaUtils;
import backend.Highscore;
import backend.Song;
import backend.Paths;
import lime.app.Application;
import lime.graphics.Image;
import backend.DiscordClient;
import openfl.Lib;
import backend.Mods;
import flixel.util.FlxSave;
import backend.CoolUtil;
import openfl.media.SoundTransform;
import flixel.sound.FlxSound;
import Reflect;
import flixel.math.FlxMath;
import flixel.addons.transition.FlxTransitionableState;
import haxe.format.JsonParser;
import sys.FileSystem;
import llua.Lua_helper;
import haxe.ds.StringMap;
import flixel.FlxCamera;
import psychlua.CustomSubstate;
import psychlua.FunkinLua;

final autoPause:Bool = ClientPrefs.data.autoPause;

// would do a while loop but while loops for maps are a pain in the ass
function setScriptVar(name:String, value:Dynamic) for (hx in SScript.global) hx.set(name, value);

FlxTransitionableState.skipNextTransIn = true;
FlxTransitionableState.skipNextTransOut = true;

final saveName:String = 'FNAF2';
final title:String = "Five Nights at Freddys 2";

var stateLua;
var stateHaxe;

var debugCam;

final scriptDir = 'data/' + PlayState.SONG.song;

final scriptTypes:Array<String> = ['.hx', '.lua'];

final curModDir:String = 'mods/' + (Mods.currentModDirectory + '/' ?? '');

final haxeFunctions:StringMap<Dynamic> = [
    // because haxe doesn't allow `'key' => func` in maps for some reason
    'exitGame' => function() exit()

    'switchState' => function(name:String) nextState(name)
];

final luaFunctions:StringMap<Dynamic> = [ // Rudy cried here
	'switchState' => function(name:String) nextState(name)
    'exitGame' => function() exit()
	
	'bound' => function(x, a, b) return FlxMath.bound(x, a, b)
	'lerp' => function(x, y, a) return FlxMath.lerp(x, y, a)
	
	'clAlph' => function(a) return 1. - (a / 255.)
	
	'Random' => function(n) {
		return FlxG.random.int(1, n) - 1;
	},
	'pl' => function(n) {
		return n / game.playbackRate;
	},
	'mouseOverlaps' => function(o) {
		return FlxG.mouse.overlaps(LuaUtils.getObjectDirectly(o, false), debugCam);
	}
	
	'setCam' => function(o, ?c) {
		c ??= 'mainCam';
		var cam = getVar(c);
		LuaUtils.getObjectDirectly(o).camera = cam;
	},
	
	'camMouseX' => function() {
		return FlxG.mouse.getScreenPosition(debugCam).x;
	},
	'camMouseY' => function() {
		return FlxG.mouse.getScreenPosition(debugCam).y;
	},
	
	'getX' => function(o) {
		return LuaUtils.getObjectDirectly(o).x;
	},
	'getY' => function(o) {
		return LuaUtils.getObjectDirectly(o).y;
	},
	
	'setX' => function(o, x) {
		LuaUtils.getObjectDirectly(o).x = x;
	},
	'setY' => function(o, y) {
		LuaUtils.getObjectDirectly(o).y = y;
	},
	'setPos' => function(o, x, y) {
		LuaUtils.getObjectDirectly(o).setPosition(x, y);
	},
	
	
	'setAlpha' => function(o, a) {
		var ob = LuaUtils.getObjectDirectly(o);
		if (ob != null) ob.alpha = a;
	},
	'getAlpha' => function(o) {
		return LuaUtils.getObjectDirectly(o).alpha;
	},
	'setVis' => function(o, v) {
		LuaUtils.getObjectDirectly(o).visible = v;
	},
	'setFrame' => function(o, f) {
		LuaUtils.getObjectDirectly(o).animation.curAnim.curFrame = f;
	},
	
	'setFrameRate' => function(o, a, f) {
		LuaUtils.getObjectDirectly(o, false).animation.getByName(a).frameRate = f;
	},
	
	'removeOnFin' => function(o) {
		var obj = LuaUtils.getObjectDirectly(o, false);
		obj.animation.finishCallback = function() {
			obj.kill();
			LuaUtils.getTargetInstance().remove(obj, true);
			
			obj.destroy();
			game.modchartSprites.remove(o);
		}
	},
	
	'addToGrp' => function(o, g) getVar(g).add(LuaUtils.getObjectDirectly(o, false))
	'removeFromGrp' => function(o, g) getVar(g).remove(LuaUtils.getObjectDirectly(o, false))
	
	'doSound' => function(s, ?v, ?t, ?l) {
		if (s == null || s.length == 0) return;
		
		v ??= 1;
		l ??= false;
		
		var so = FlxG.sound.play(Paths.sound(s), v, l, null, true, function() {
			if (t != null && !l) {
				game.modchartSounds.remove(t);
				game.callOnLuas('onSoundFinished', [t]);
			}
		});
		so.pitch = game.playbackRate;
		if (t != null) {
			if (game.modchartSounds.exists(t)) {
				game.modchartSounds.get(t).stop();
			}
			
			game.modchartSounds.set(t, so);
		}
	}
];

function onCreatePost() {
    game.inCutscene = true;
    game.canPause = false;

    // kills every object in playstate so that the draw and update calls are reduced
    for (obj in game.members) {
        obj.alive = false;
        obj.exists = false;
    }

    FlxG.autoPause = false;
    FlxG.mouse.visible = true;
	FlxG.mouse.useSystemCursor = true;
	
	//FlxG.fullscreen = true;
	
	FlxG.camera.active = true;
	FlxG.camera.bgColor = 0xFF000000;

    final absDir = curModDir + scriptDir;

    for (fileExt in scriptTypes) {
        if (FileSystem.exists(absDir + fileExt)) {
            switch (fileExt) {
                case '.hx':
                    game.startHScriptsNamed(scriptDir + fileExt);
                    for (obj in SScript.global.keys()) {
                        if (obj == (absDir + fileExt)) {
                            stateHaxe = SScript.global.get(obj);
                            break;
                        }
                    }

                case '.lua':
                    game.startLuasNamed(scriptDir + fileExt);
                    for (file in game.luaArray) {
                        if (file.scriptName == (absDir + fileExt)) {
                            stateLua = file;
                            break;
                        }
                    }
            }
        }
    }
    // if you wanna change the game's resolution
    resize(1024, 768);

    // in case you wanna add your own event listeners for key pressing
    FlxG.stage.removeEventListener("keyDown", game.onKeyPress);
    FlxG.stage.removeEventListener("keyUp", game.onKeyRelease);
	
	// would check if the image i want to change to is different than the one already as the icon but
    // you can't grab the application's icon image to my knowledge

    // common lime L :sob:
    final img:Image = Image.fromFile(Paths.modFolders('images/fnafIcon.png'));
    Application.current.window.setIcon(img);

    // resets the game to have only one camera
    FlxG.cameras.reset();
    FlxG.camera.active = true;

    game.luaDebugGroup.revive();

    // initializes the main save
    if (!game.modchartSaves.exists(saveName)) {
        final save:FlxSave = new FlxSave();
        save.bind(saveName, CoolUtil.getSavePath() + '/conCowPorts');
        game.modchartSaves.set(saveName, save);
    }

    if (Lib.application.window.title != title) Lib.application.window.title = title;

    for (func in haxeFunctions.keys()) {
        for (file in game.hscriptArray) file.set(func, haxeFunctions.get(func));
    }

    for (func in luaFunctions.keys()) {
        for (file in game.luaArray) Lua_helper.add_callback(file.lua, func, luaFunctions.get(func));
		
		FunkinLua.customFunctions.set(func, luaFunctions.get(func));
    }

    callStateFunction('create');
	
	debugCam = FlxG.cameras.add(new FlxCamera(), false);
	debugCam.bgColor = 0x00000000;
	game.luaDebugGroup.cameras = [debugCam];
}

function nextState(name:String) {
    game.modchartSaves.get(saveName).flush();

    PlayState.SONG = new JsonParser('{
        "notes": [],
        "events": [],
        "song": "' + name + '",
        "needsVoices": false
    }').doParse();

    callStateFunction('destroy');
    FlxG.resetState();
}

function onUpdate(elapsed:Float) {
    //callStateFunction('update', [elapsed]);
    if (FlxG.keys.justPressed.ESCAPE) closeFully();
}

function onCustomSubstateUpdatePost() {
	if (FlxG.keys.justPressed.ESCAPE) closeFully();
}

function closeFully() {
	exit();
}

function exit() {
    game.modchartSaves.get(saveName).flush();
    FlxG.autoPause = autoPause;
    FlxTransitionableState.skipNextTransIn = false;
	FlxG.fullscreen = false;

    resize();
    PlayState.deathCounter = 0;

    callStateFunction('onGameClose');

    Lib.application.window.title = "Friday Night Funkin': Psych Engine";
    FlxG.mouse.visible = false;
	FlxG.mouse.useSystemCursor = false;
	FlxG.mouse.load();

    Mods.loadTopMod();
    FlxG.switchState(new states.FreeplayState());
    DiscordClient.resetClientID();
    FlxG.sound.playMusic(Paths.music('freakyMenu'));
    game.transitioning = true;
	
	Application.current.window.setIcon(Image.fromFile(Paths.modFolders('images/fnfIcon.png')));
}

function resize(?width:Int, ?height:Int) {
    width ??= 1280;
    height ??= 720;
	/*
    FlxG.resizeWindow(width, height);
	FlxG.resizeGame(width, height);
    FlxG.width = width;
    FlxG.height = height;

    FlxG.scaleMode.scale.x = 1;
    FlxG.scaleMode.scale.y = 1;

    FlxG.game.x = 0; // (1366 / 2) - (1024 / 2)
    FlxG.game.y = 0;
	*/
	var originalWidth = FlxG.stage.stageWidth;
	var originalHeight = FlxG.stage.stageHeight;
	
	if (FlxG.initialWidth != width) {
		var sizeChangeX = originalWidth / FlxG.width;
		var sizeChangeY = originalHeight / FlxG.height;
		
		var windWidth = Math.floor(width * sizeChangeX);
		var windHeight = Math.floor(height * sizeChangeY);
		
		var xChange = Math.floor(((originalWidth - windWidth) / 2) * sizeChangeX);
		
		FlxG.stage.width = windWidth;
		FlxG.stage.height = windHeight;
		
		FlxG.initialWidth = FlxG.width = FlxG.camera.width = width;
		FlxG.initialHeight = FlxG.height = FlxG.camera.height = height;
		
		FlxG.resizeGame(width, height);
		FlxG.resizeWindow(windWidth, windHeight);
		
		FlxG.scaleMode.scale.x = sizeChangeX;
		FlxG.scaleMode.scale.y = sizeChangeY;

		FlxG.game.x = 0; // (1366 / 2) - (1024 / 2)
		FlxG.game.y = 0;
		
		Application.current.window.x += xChange;
	}

	if (PlayState.deathCounter == 0) {
		PlayState.deathCounter = 1;
		FlxG.resetState();
	}
}

function callStateFunction(name:String, ?args:Array<Dynamic>) {
    args ??= [];

    // haxe calling
    for (script in game.hscriptArray) {
        if (!script.exists(name)) continue;

        final callValue = script.call(name, args);
        if (!callValue.succeeded) {
            final e = callValue.exceptions[0];
            if(e != null) {
                var len:Int = e.message.indexOf('\n') + 1;
                if (len <= 0) len = e.message.length;
                debugPrint('ERROR (' + callValue.calledFunction + ') - ' + e.message.substr(0, len), FlxColor.RED);
            }
        }
    }

    // lua calling
    for (script in game.luaArray) script.call(name, args);
}