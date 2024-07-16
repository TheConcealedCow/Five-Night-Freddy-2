r = {
	ai = 0,
	
	cam = 1,
	dir = 0,
	
	bugTime = 0,
	bugTimeV = 0,
	tryingOffice = false,
	
	moveTree = {
		[1] = {9, 2}, -- stage
		[2] = {9, 4}, -- dining area
		[4] = {6, 5}, -- 2A
		[5] = {6, 50}, -- 2B
		[6] = {50, 4}, -- closet
		[9] = {2, 4}, -- backstage
		[50] = {1, 1}
	},
	soundMove = {
		[1] = {0.1, 0.1},
		[2] = {0.2, 0.2},
		[4] = {0.3, 0.3},
		[5] = {0.4, 0.4},
		[6] = {0.3, 0.3},
		[9] = {0.1, 0.1}
	}
}
local night = 1;
function onCreate()
	runHaxeCode([[
		createGlobalCallback('addBonnie', function() {
			parentLua.call('addAI', []);
		});
	]]);
	
	setCamRobot(r.cam, 2, 'BONNIE'); -- bonnie's first move is ignored if chica moves too because scott
	
	setVar('leftAtDoor', false);
	setVar('leftSnd', false);
	
	runTimer('bonnieMove', pl(4.98), 0);
	
	makeAnimatedLuaSprite('scareBONNIE', 'gameAssets/jumpscares/bonnie');
	addAnimationByPrefix('scareBONNIE', 'scare', 'Scare', 45);
	setCam('scareBONNIE');
	addLuaSprite('scareBONNIE');
	setAlpha('scareBONNIE', 0.00001);
	addScareSlot('scareBONNIE', 3, 1);
	
	night = getVar('night');
	setAI();
end

function updateRoom(n)
	local prev = r.cam;
	setCamRobot(r.cam, 2, '');
	r.cam = n;
	setCamRobot(n, 2, 'BONNIE' .. (n == 2 and getRandomInt(1, 2) or ''));
	addBugTrigger(prev, n);
end

function onUpdatePost(e)
	if r.tryingOffice then tryEnter(); end
end

function moveRobot()
	if r.cam == 100 then return; end
	
	local want = r.moveTree[r.cam][r.dir];
	
	if want == 50 or r.cam == 50 then -- he want go window or he at window
		if r.tryingOffice then return; end
		
		if want == 50 then
			setVar('leftAtDoor', true);
			playAnim('leftOfficeLight', 'lBONNIE', true);
			runMainFunc('disableLight');
			
			setCamRobot(r.cam, 2, '');
			addBugTrigger(r.cam, r.cam);
			
			r.cam = 50;
		else
			tryEnter();
		end
		
		return;
	end
	
	doSound('deepSteps', r.soundMove[r.dir], 'bonnieStep');
	updateRoom(want);
end

function tryEnter()
	local doorPhase = getMainVar('leftDoor').phase;
	r.tryingOffice = true;
	
	if doorPhase == 0 then
		r.tryingOffice = false;
		r.cam = 100;
		
		leaveLight();
		doorProp('left', 'stuck', true);
		
		if not getMainVar('wasGot') then
			setMainVar('wasGot', true);
			setMainVar('gotYou', true);
			setMainVar('slotGot', 3);
			
			runTimer('forceScare', pl(30));
			runTimer('randSoundBonnie', pl(5), 0);
		end
	elseif doorPhase == 2 then
		r.tryingOffice = false;
		leaveLight();
		
		r.cam = 2;
		setCamRobot(2, 2, 'BONNIE' .. getRandomInt(1, 2));
		addBugTrigger(2, 2);
		doSound('deepSteps', 0.3, 'bonnieStep');
	end
end

function leaveLight()
	setVar('leftSnd', false);
	setVar('leftAtDoor', false);
	playAnim('leftOfficeLight', 'l', true);
	runMainFunc('disableLight');
end

local aiLevs = {0, 3, 0, 2, 5, 10};
function setAI()
	if night == 7 then
		
	else
		r.ai = aiLevs[night];
	end
end

function addAI()
	r.ai = r.ai + 1;
end

local firstMove = true;
local timers = {
	['hideStuff'] = function()
		setAlpha('scareBONNIE', 0);
	end,
	['updateSec'] = function()
		r.dir = getRandomInt(1, 2);
	end,
	['bonnieMove'] = function()
		if firstMove then
			firstMove = false;
			if getVar('chicaMoved') then return; end
		end
		
		if getRandomInt(1, 20) <= r.ai then moveRobot(); end
	end
}
function onTimerCompleted(t)
	if timers[t] then timers[t](); end
end
