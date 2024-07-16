local night = 'gameAssets/night/';

local atan2 = math.atan2;
local floor = math.floor;
local sqrt = math.sqrt;
local cos = math.cos;
local sin = math.sin;
local abs = math.abs;

local maskNodes = {[0] = {0, 0}};
local maskTrig = {0, 0};
local maskOff = {0, 0}; -- current offsets for the node
local maskAt = {0, 0}; -- current starting node
local maskDis = {0, 0}; -- distance to travel
local maskSpd = 4;
local maskVel = floor(maskSpd * 7.487569464755777);
function onCreate()
	luaDebugMode = true;
	
	local fileWNodes = getTextFromFile('paths/freddyMask.txt'); -- suggestion by betpowo to debloat these scripts
	local noNLine = fileWNodes:gsub('\n', '');
	local eachOf = stringSplit(fileWNodes, '|');
	for i = 1, #eachOf do
		local numGrp = stringSplit(eachOf[i], ',');
		numGrp = {tonumber(numGrp[1]), tonumber(numGrp[2])};
		table.insert(maskNodes, numGrp);
	end
	
	makeLuaSprite('mask', night .. 'fx/mask', -100, -66);
	setCam('mask', 'maskCam');
	addLuaSprite('mask');
	setAlpha('mask', 0.00001);
	
	makeAnimatedLuaSprite('maskAnim', night .. 'fx/maskAnim');
	addAnimationByPrefix('maskAnim', 'mask', 'Mask', 45, false);
	playAnim('maskAnim', 'mask', true);
	setCam('maskAnim', 'maskCam');
	addLuaSprite('maskAnim');
	setAlpha('maskAnim', 0.00001);
	
	calcDistance();
end

local lastNode = 0; -- last node
local curNode = 1; -- targetted node
function updateFunc(e, t)
	local velFr = (maskVel * e);
	maskOff[1] = maskOff[1] + (velFr * maskTrig[1]);
	maskOff[2] = maskOff[2] + (velFr * maskTrig[2]);
	
	local abOff = {abs(maskOff[1]), abs(maskOff[2])};
	local abDis = {abs(maskDis[1]), abs(maskDis[2])};
	
	while abOff[1] >= abDis[1] and abOff[2] >= abDis[2] do
		lastNode = curNode;
		curNode = (curNode + 1) % (#maskNodes + 1);
		
		local extraDistance = {abOff[1] - abDis[1], abOff[2] - abDis[2]};
		local disPyth = sqrt((extraDistance[1] * extraDistance[1]) + (extraDistance[2] * extraDistance[2]));
		local totPyth = sqrt((abDis[1] * abDis[1]) + (abDis[2] * abDis[2]));
		local per = disPyth / totPyth;
		
		calcDistance();
		
		maskOff = {maskDis[1] * per, maskDis[2] * per};
		
		abOff = {abs(maskOff[1]), abs(maskOff[2])};
		abDis = {abs(maskDis[1]), abs(maskDis[2])};
	end
	
	if getMainVar('inMask') then 
		setPos('mask', -100 + maskAt[1] + maskOff[1], -66 + maskAt[2] + maskOff[2]);
	end
end

function calcDistance()
	local cur = maskNodes[curNode];
	local las = maskNodes[lastNode];
	
	local xDist = cur[1] - las[1]; -- subtract the prev target from the current target to get the total distance
	local yDist = cur[2] - las[2];
	
	local ang = atan2(yDist, xDist); -- determine the angle based on where it needs to go to hit the origin
	
	local xNew = cutForComp(cos(ang)); -- new x angle 
	local yNew = cutForComp(sin(ang)); -- new y angle
	
	maskAt = las;
	maskOff = {0, 0};
	maskDis = {xDist, yDist};
	maskTrig = {xNew, yNew};
end

function cutForComp(n) -- computers are goofy and 0 isnt actually 0!
	return math.floor(n * 1000000) / 1000000;
end
