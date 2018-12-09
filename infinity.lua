--[[
	Author: Exilepilot
	Description: Draw an infinity symbol using dxDrawLine3D, using only the Z and Y axis.
--]]

--[[ 
     	Each section needs be drawn to look continous.
     	To achieve this, I draw each quarter separately.
        Here is a table with the domain ranges for the polar equation.
--]]

local SCALE_SIZE = 500
local MAX_POINTS = 10
local INTERVAL = 0.1
local ranges = {
	{1 * math.pi, 1.5 * math.pi}, -- Forwards
	{0.5 * math.pi, 0}, -- Backwards
	{2 * math.pi, 1.5 * math.pi}, -- Backwards
	{0.5 * math.pi, 1 * math.pi} -- Forwards
}

--[[ Use the polar equation for drawing an infinity symbol ]]
function infinity_polar_to_cartesian(thetaAngle)
	local asymptotes = math.cos(2 * thetaAngle)
	local radius = SCALE_SIZE * math.sqrt(asymptotes)
	local x = radius * math.cos(thetaAngle)
	local y = radius * math.sin(thetaAngle) 
	return x, y
end

local lastTheta = nil    -- Theta since last point added
local lastSectionDrawn = nil -- Section since last point added
local lastInterval = nil
local start = nil
local maxWait = 10000

-- POINTS to take
local points = {}

--[[ Remove the point at index 1 ]]
function removePoint()
	table.remove(points, 1)
end

function startNewSection()
	lastSectionDrawn = lastSectionDrawn + 1
		-- Wrap back to the start
		if lastSectionDrawn > 4 then 
			lastSectionDrawn = nil
		end
		lastTheta = nil
		lastInterval = nil
end

--[[ Add points one by one, to each section ]]
function addPoint()

	if not lastSectionDrawn then
		lastSectionDrawn = 1
	end
	local min, max = ranges[lastSectionDrawn][1], ranges[lastSectionDrawn][2]
	
	if not lastTheta then
		lastTheta = min
	end
	
	if not lastInterval then
		local difference = max - min
		local interval = difference / math.abs(difference)
		lastInterval = interval * INTERVAL
	end
	
	
	local x, y = infinity_polar_to_cartesian(lastTheta)
	lastTheta = lastTheta + lastInterval
	
	-- Section is finished, go to the next section (wrap back to the start)!
	local backwards = false
	if (max < min) then
		backwards = true
	end
	
	if (not backwards and lastTheta >= max) or (backwards and lastTheta <= max) then
		startNewSection()		
	end

	if #points > MAX_POINTS then
		removePoint()
	end

	if validate(x, y) then
		points[#points + 1] = {x, y}
	else
		return false
	end
		
	
end

function validate(...) 
	for i, v in ipairs(arg) do
		if type(v) ~= "number" then
			return false
		end
		
		if v ~= v then
			return false
		end
		
	end
	return true
end

local screenW, screenH = guiGetScreenSize()
--[[ Draw all of the points ]]
function drawPoints()
	if #points < 2 then return false end	
	for i = 2, #points do
		local y1, z1 = points[i-1][1], points[i-1][2]
		local y2, z2 = points[i][1], points[i][2]
		
		if validate(y1, z1, y2, z2) then
			dxDrawLine(screenW/2 + y1, screenH/2 + z1, screenW/2 + y2, screenH/2 + z2)
		end
	end
end


--[[ MAIN ]]
local pointAddDelay = 0
local prevAdd = 0

function addInfinity()
	addPoint()
end
addEventHandler("onClientPreRender", getRootElement(), addInfinity)

function drawInfinity()
	if not start then return false end
	drawPoints()
	if (getTickCount() - start > maxWait) then start = nil end
end
addEventHandler("onClientRender", getRootElement(), drawInfinity)

addEventHandler("onClientResourceStart", getRootElement(), 

function ()
	start = getTickCount()
end
)
