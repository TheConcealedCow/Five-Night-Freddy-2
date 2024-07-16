local r = {
	ai = 0,
	movePhase = 0,
	stunTime = 0,
	
	cam = 4,
	didMove = false
}
function onCreate()
	r.ai = math.floor((getRandomInt(1, 100)) / 100);
	setCamRobot(r.cam, 4, 'PAL');
end 

function updateFunc(e, t)
	if r.stunTime > 0 then r.stunTime = r.stunTime - t; end
	
	moveCheck();
	makeMove();
	
	if getMainVar('viewCam') == 4 and getMainVar('isLit') then
		r.stunTime = 400 - (getMainVar('curNight') * 50);
	end
end

function moveCheck()
	if r.movePhase ~= 1 then return; end
	
	if r.stunTime <= 0 and getMainVar('curCam') ~= r.cam then
		r.movePhase = 2;
	end
end

function makeMove()
	if r.movePhase ~= 2 then return; end
	
	local c = getMainVar('viewCam');
	if c == 4 or c == -1 then return; end
	
	setCamRobot(r.cam, 4, '');
	setAlpha('paperPal', 1);
	r.cam = 100;
	r.movePhase = 0;
end

local timers = {
	['tryMove'] = function()
		if not r.didMove and getRandomInt(1, 20) <= r.ai then
			r.movePhase = 1;
			r.didMove = true;
		end
	end
}

function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
