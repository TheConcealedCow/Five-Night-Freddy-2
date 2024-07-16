local r = {
	ai = 0,
	movePhase = 0,
	
	stunTime = 0,
	
	cam = 12,
	
	moveTree = {
		[1] = {2, 2},
		[2] = {6, 1},
		[6] = {50, 50},
		[7] = {30, 30},
		[10] = {7, 7},
		[11] = {10, 10},
		[12] = {11, 11},
		[30] = {2, 2}
	},
	
	frCam = {
		[1] = 3,
		[2] = 2,
		[7] = 3,
		[10] = 1,
		[11] = 0
	}
}
function onCreate()
	setCamRobot(r.cam, 2, 'MANGLE');
	
	setVar('mangleCam', r.cam);
end

function updateRoom(n)
	local prev = r.cam;
	
	if r.cam < 13 then setCamRobot(r.cam, 2, ''); end
	if r.cam == 30 then setHallRobot('fir', 2, ''); end
	
	r.cam = n;
	r.movePhase = 0;
	
	if r.frCam[n] then setFrame('mangleInCams', r.frCam[n]); end
	
	setVar('mangleCam', n);
	
	if n < 13 then setCamRobot(n, 2, 'MANGLE'); end
	if n == 30 then setHallRobot('fir', 2, 'MANGLE'); end
	
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
	
	if r.cam ~= 11 and getMainVar('isLit') and getMainVar('viewCam') == r.cam then -- scott why cam 11
		r.stunTime = 400;
	end
end

function moveCheck()
	if r.movePhase ~= 1 then return; end
	
	local ca = getMainVar('viewCam');
	if r.stunTime <= 0 and ((ca > 0 and ca ~= r.cam) or (ca == -1 and not getMainVar('officeMidLit'))) then
		r.movePhase = 2;
	end
end

local extraCheckCam = {
	[1] = function()
		return not getMainVar('officeMidLit');
	end,
	[7] = function()
		return not getMainVar('officeMidLit');
	end,
	[30] = function()
		return not getMainVar('officeMidLit');
	end,
	
	[6] = function()
		return false;
	end
}

function makeMove()
	if r.movePhase ~= 2 then return; end
	if extraCheckCam[r.cam] and not extraCheckCam[r.cam]() then return; end
	
	local want = r.moveTree[r.cam][getMainVar('decidePath')];
	updateRoom(want);
end

local timers = {
	['tryMove'] = function()
		if Random(20) < r.ai then
			r.movePhase = 1;
		end
	end
}

function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
