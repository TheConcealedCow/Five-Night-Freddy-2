function create()
	runHaxeCode([[
		function stopSprites() {
			for (obj in game.members) if (Std.isOfType(obj, FlxSprite) && obj.active) obj.active = false;
		}
	]]);
	
	makeAnimatedLuaSprite('static', 'gameAssets/night/panel/hud/static');
	addAnimationByPrefix('static', 'static', 'Satic', 60);
	setFrameRate('static', 'static', 59.4);
	playAnim('static', 'static', true);
	addLuaSprite('static');
	
	makeAnimatedLuaSprite('blip', 'gameAssets/night/panel/hud/blipCam');
	addAnimationByPrefix('blip', 'blip', 'Blip', 45, false);
	playAnim('blip', 'blip', true);
	addLuaSprite('blip');
	removeOnFin('blip');
	
	makeLuaSprite('gameOver', 'gameAssets/Gameover/gameOver');
	addLuaSprite('gameOver');
	setAlpha('gameOver', 0.00001);
	
	doSound('static', 1, 'staticSnd');
	runTimer('hideStuff', 0.1);
	runTimer('goGameOver', pl(10));
end

local tweens = {
	['gameOverIN'] = function()
		runTimer('toMenuDeath', pl(10));
	end
}

function onTweenCompleted(t)
	if tweens[t] then tweens[t](); end
end

local timers = {
	['hideStuff'] = function()
		setAlpha('gameOver', 0);
	end,
	['goGameOver'] = function()
		runHaxeFunction('stopSprites');
		stopSound('staticSnd');
		
		setProperty('gameOver.active', true);
		doTweenAlpha('gameOverIN', 'gameOver', 1, pl(1.01));
	end,
	['toMenuDeath'] = function()
		if getRandomInt(1, 10000) == 1 then
			switchState('CreepyEnd');
		else
			switchState('Title');
		end
	end
}

function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
