function create()
	luaDebugMode = true;
	
	makeLuaSprite('creepy', 'gameAssets/Jumpscares/yellow');
	addLuaSprite('creepy');
	
	doSound('xScream2', 1, 'yellowScream');
	runTimer('toMenu', pl(1));
end

function onTimerCompleted(t) if t == 'toMenu' then exitGame(); end end
