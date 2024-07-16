local r = {
	ai = 50,
	movePhase = 0,
	
	cam = 8,
	aggro = 0,
	stunTime = 0,
	flashTime = 0,
	
	moveTree = {
		[8] = 30,
	}
}
function onCreate()
	setCamRobot(r.cam, 6, 'OLDFOXY');
end

function updateRoom(n)
	local prev = r.cam;
	
	if r.cam < 13 then setCamRobot(r.cam, 6, ''); end
	if r.cam == 30 then setHallRobot('fir', 3, ''); end
	
	r.cam = n;
	r.movePhase = 0;
	
	if n < 13 then setCamRobot(n, 6, 'OLDFOXY'); end
	if n == 30 then setHallRobot('fir', 3, 'OLDFOXY'); end
	
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
		if getMainVar('officeMidLit') then r.stunTime = 50; end
	end
}

function updateForCam()
	if updateCam[r.cam] then updateCam[r.cam](); end
end

function moveCheck()
	if r.movePhase ~= 1 then return; end
	
	if r.stunTime <= 0 and getMainVar('curCam') ~= r.cam then
		r.movePhase = 2;
	end
end

local extraCheckCam = {
	[8] = function()
		return not getMainVar('officeMidLit');
	end,
	[30] = function()
		return false;
		--return not getMainVar('officeMidLit');
	end
}

function makeMove()
	if r.movePhase ~= 2 then return; end
	if extraCheckCam[r.cam] and not extraCheckCam[r.cam]() then return; end
	
	local want = r.moveTree[r.cam];
	updateRoom(want);
	debugPrint('old foxy moved!');
end

local timers = {
	['tryMove'] = function()
		if (21 + Random(5)) - r.aggro <= r.ai then
			r.movePhase = 1;
		end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
