local r = {
	ai = 0,
	movePhase = 0,
	
	cam = 8,
	stunTime = 0,
	
	moveTree = {
		[2] = 6,
		[4] = 2,
		[6] = 50,
		[8] = 4
	}
}
function onCreate()
	setCamRobot(r.cam, 10, 'OLDCHICA');
end

function updateRoom(n)
	local prev = r.cam;
	
	if r.cam < 13 then setCamRobot(r.cam, 10, ''); end
	
	r.cam = n;
	r.movePhase = 0;
	
	if n < 13 then setCamRobot(n, 10, 'OLDCHICA'); end
	
	addBugTrigger(prev, n, 20);
end

function updateFunc(e, t)
	moveCheck();
	makeMove();
	
	if r.stunTime > 0 then r.stunTime = r.stunTime - t; end
	
	updateForCam();
end

function updateForCam()
	if r.cam ~= 8 and getMainVar('isLit') and getMainVar('viewCam') == r.cam then
		r.stunTime = 400;
	end
end

function moveCheck()
	if r.movePhase ~= 1 then return; end
	
	local otherCheck = true;
	if getMainVar('curNight') ~= 7 then
		otherCheck = getMainVar('cameraProps')[8].slots[9] == '';
	end
	
	if r.stunTime <= 0 and otherCheck and getMainVar('curCam') ~= r.cam then
		r.movePhase = 2;
	end
end

local extraCheckCam = {
	[6] = function()
		return false;
	end
}

function makeMove()
	if r.movePhase ~= 2 then return; end
	if extraCheckCam[r.cam] and not extraCheckCam[r.cam]() then return; end
	
	local want = r.moveTree[r.cam];
	updateRoom(want);
	debugPrint('old chica moved');
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