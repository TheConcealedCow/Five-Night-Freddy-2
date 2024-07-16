function create()
	makeAnimatedLuaSprite('static', 'gameAssets/night/panel/hud/static');
	addLuaSprite('static');
	setAlpha('static', 0.00001);
	
	makeAnimatedLuaSprite('blip', 'gameAssets/night/panel/hud/blipCam');
	addLuaSprite('blip');
	setAlpha('blip', 0.00001);
	
	makeAnimatedLuaSprite('freddy', 'gameAssets/Jumpscares/freddy2');
	addAnimationByPrefix('freddy', 'scare', 'Scare', 36, false);
	playAnim('freddy', 'scare', true);
	addLuaSprite('freddy');
	
	runHaxeCode([[
		game.modchartSprites.get('freddy').animation.finishCallback = function() {
			parentLua.call('switchState', ['died']);
		}
	]]);
	
	doSound('xScream', 1, 'scareSnd');
	runTimer('hideStuff', 0.1);
end

function onTimerCompleted(t)
	if t == 'hideStuff' then
		setAlpha('static', 0);
		setAlpha('blip', 0);
	end
end
