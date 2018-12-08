--[[
	Author: Exilepilot
	Description: Draw an infinity symbol using dxDrawLine3D, using only the Z and Y axis.
--]]

--[[ 
     	Each section needs be drawn to look continous.
     	To achieve this, I draw each quarter separately.
        Here is a table with the domain ranges for the polar equation.
--]]
local SCALE_SIZE = math.sqrt(2)
local MAX_POINTS = 10
local INTERVAL = 0.1
local P = {0, 0, 100}

local ranges = {
	{math.pi, 1.5 * math.pi}, -- Forwards
	{0.5 * math.pi, 0}, -- Backwards
	{2 * math.pi, 1.5 * math.pi}, -- Backwards
	{0.5 * math.pi, math.pi} -- Forwards
}

--[[ Use the polar equation for drawing an infinity symbol ]]
function infinity_polar_to_cartesian(thetaAngle)
	local radius = SCALE_SIZE * math.sqrt(math.cos(2 * thetaAngle))
	local x = radius * math.cos(thetaAngle)
	local y = radius * math.sin(thetaAngle)
	return x, y
end

local lastTheta = nil    -- Theta since last point added
local lastSectionDrawn = nil -- Section since last point added
local lastInterval = nil

-- POINTS to take
local points = {}

--[[ Remove the point at index 1 ]]
function removePoint()
	table.remove(points, 1)
end

--[[ Add points one by one, to each section ]]
function addPoint()
	if not lastSectionDrawn then
		lastSectionDrawn = 1
	end
	local min, max = ranges[lastSectionDrawn][1], ranges[lastSectionDrawn][2]
	
	if not lastTheta then
		lastTheta = ranges[lastSectionDrawn][1]
	end
	
	if not lastInterval then
		local difference = max - min
		local interval = difference / math.abs(difference)
		lastInterval = interval * INTERVAL
	end
	
	points[#points + 1] = {infinity_polar(lastTheta)}
	lastTheta = lastTheta + lastInterval
	
	-- Section is finished, go to the next section (wrap back to the start)!
	if lastTheta >= max then
		lastSectionDrawn = lastSectionDrawn + 1
		-- Wrap back to the start
		if lastSectionDrawn >= 5 then 
			lastSectionDrawn = 1
		end
		lastTheta = nil
		lastInterval = nil
	end

	if #points > MAX_POINTS then
		removePoint()
	end
end

--[[ Draw all of the points ]]
function drawPoints()
	if #points < 2 then return false end	
	for i = 2, #points do
		local y1, z1 = points[i-1][1], points[i-1][2]
		local y2, z2 = points[i][1], points[i][2]
		dxDrawLine3D(P[1], P[2]+y1, P[3]+z1, P[1], P[2]+y2, P[3]+z2)
	end
end


--[[ MAIN ]]
local pointAddDelay = 50
local prevAdd = 0

function drawInfinity()
	local tick = getTickCount()
	local elapsed = (tick - prevAdd)
	if elapsed > pointAddDelay then
		addPoint()
		prevAdd = tick
	end
	
	drawPoints()
end
addEventHandler("onClientRender", getRootElement(), drawInfinity)
