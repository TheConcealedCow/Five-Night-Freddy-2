local r = {
	ai = 0,
	phase = 0,
	
	cam = 11, -- she starts on 11, but cant be seen
	
	lookedEl = 0,
	flashed = false,
	moveDir = 0,
	
	attEl = 0,
	pausedTime = 0,
	startedMus = false,
	
	moveTree = {
		[1] = {50, 50}, -- 50 means inOffice, 100 means gotYou
		[2] = {50, 50},
		[3] = {1, 1},
		[4] = {2, 2},
		[7] = {3, 4},
		[10] = {7, 7},
		[11] = {10, 10}
		
	}
};
function onCreate() -- TODO: MAKE HER JUMPSCARE YOU AND ADD HALLUCINATIONS AFTER FLASHING
	setVar('puppetPhase', r.phase);
	setCamRobot(r.cam, 1, 'PUPPET');
	
	runTimer('unflashSock', pl(0.11), 0);
end

function updateRoom(n)
	if r.cam < 13 then setCamRobot(r.cam, 1, ''); end
	r.cam = n;
	
	if n < 13 then setCamRobot(n, 1, 'PUPPET'); end
end

function updateFunc(e, t, ticks)
	r.pausedTime = r.pausedTime - t;
	
	if getMainVar('viewCam') == r.cam then
		r.lookedEl = r.lookedEl + e;
		
		while r.lookedEl >= 0.2 do
			r.lookedEl = r.lookedEl - 0.2
			
			setMainVar('staticD', 100 + Random(100));
			runMainFunc('refreshStatic');
		end
	else
		setMainVar('staticD', 0);
	end
	
	if getMainVar('windTime') <= 0 then
		r.attEl = r.attEl + e;
		
		while r.attEl >= 1 do
			r.attEl = r.attEl - 1;
			if r.phase < 3 and Random(20) <= r.ai then
				puppetMovePhase();
			end
		end
	end
	
	if r.cam ~= 11 then
		if getMainVar('isLit') and getMainVar('viewCam') == r.cam then
			r.flashed = true;
			r.pausedTime = 10;
		end
	end
	
	if ticks > 0 then
		for i = 1, ticks do
			tick();
		end
	end
end

function tick()
	
end

function puppetMovePhase()
	if not getMainVar('isLit') or getMainVar('viewCam') ~= 11 then
		r.phase = r.phase + 1;
		setVar('puppetPhase', r.phase);
		setCamRobot(r.cam, 1, 'PUPPET' .. r.phase);
	end
end

function movePuppet()
	if r.pausedTime > 0 or r.cam >= 50 then return; end
	
	if not r.startedMus then
		r.startedMus = true;
		
		doSound('jackInTheBox', 0.75, 'puppetGoneSnd', true);
		stopSound('musBoxSnd');
	end
	
	local want = r.moveTree[r.cam][r.moveDir];
	updateRoom(want);
	
	debugPrint(want);
end

local timers = {
	['unflashSock'] = function()
		r.flashed = false;
	end,
	['updateSec'] = function()
		r.moveDir = getRandomInt(1, 2);
		
		if r.pausedTime <= 0 and r.phase >= 3 and Random(20) <= r.ai then
			movePuppet();
		end
	end
}

function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
