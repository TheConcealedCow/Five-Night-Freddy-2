local r = {
	ai = 0,
	movePhase = 0,
	
	cam = 8,
	stunTime = 0,
	
	moveTree = {
		[8] = 7,
		[7] = 30, -- hall stage 1
		[30] = 1,
		[1] = 5,
		[5] = 50
	}
}
function onCreate()
	setCamRobot(r.cam, 9, 'OLDBONNIE');
end

function updateRoom(n)
	local prev = r.cam;
	
	if r.cam < 13 then setCamRobot(r.cam, 9, ''); end
	if r.cam == 30 then setHallRobot('fir', 7, ''); end
	
	r.cam = n;
	r.movePhase = 0;
	
	if n < 13 then setCamRobot(n, 9, 'OLDBONNIE'); end
	if n == 30 then setHallRobot('fir', 7, 'OLDBONNIE'); end
	
	addBugTrigger(prev, n, 20);
end

function updateFunc(e, t)
	moveCheck();
	makeMove();
	
	if r.stunTime > 0 then r.stunTime = r.stunTime - t; end
	
	updateForCam();
end

local updateCam = {
	[30] = function()
		if getMainVar('officeMidLit') then r.stunTime = 40; end
	end
}

function updateForCam()
	if updateCam[r.cam] then updateCam[r.cam](); end
	
	if r.cam ~= 8 and getMainVar('isLit') and getMainVar('viewCam') == r.cam then
		r.stunTime = 400;
	end
end

function moveCheck()
	if r.movePhase ~= 1 then return; end
	
	if r.stunTime <= 0 and getMainVar('curCam') ~= r.cam then
		r.movePhase = 2;
	end
end

local extraCheckCam = {
	[7] = function()
		return not getMainVar('officeMidLit');
	end,
	[30] = function()
		return not getMainVar('officeMidLit');
	end,
	
	[5] = function()
		return false;
	end
}

function makeMove()
	if r.movePhase ~= 2 then return; end
	if extraCheckCam[r.cam] and not extraCheckCam[r.cam]() then return; end
	
	local want = r.moveTree[r.cam];
	updateRoom(want);
end

local timers = {
	['tryMove'] = function()
		if getRandomInt(1, 20) <= r.ai then
			r.movePhase = 1;
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
