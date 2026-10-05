local Popper = require(script:WaitForChild("Popper"))
local clamp = math.clamp
local exp = math.exp
local min = math.min
local max = math.max
local cameraMinZoomDistance = nil
local cameraMaxZoomDistance = nil
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
assert(localPlayer)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateBounds()
	cameraMinZoomDistance = localPlayer.CameraMinZoomDistance
	cameraMaxZoomDistance = localPlayer.CameraMaxZoomDistance
end

updateBounds() -- equivalent call inferred; original call site unknown
localPlayer:GetPropertyChangedSignal("CameraMinZoomDistance"):Connect(updateBounds)
localPlayer:GetPropertyChangedSignal("CameraMaxZoomDistance"):Connect(updateBounds)
local class = {}
class.__index = class

function class.new(freq: number, p2: number, minValue: number, maxValue: number)
	local goal = clamp(p2, minValue, maxValue)
	return (setmetatable({
		freq = freq,
		x = goal,
		v = 0,
		minValue = minValue,
		maxValue = maxValue,
		goal = goal
	}, class))
end

function class:Step(p: number)
	local v = self.freq * 2 * 3.141592653589793
	local x = self.x
	local v2 = self.v
	local minValue = self.minValue
	local maxValue = self.maxValue
	local goal = self.goal
	local v3 = goal - x
	local v4 = v * p
	local v6 = exp(-v4)
	local v7 = goal + (v2 * p - v3 * (v4 + 1)) * v6
	local v8 = ((v3 * v - v2) * v4 + v2) * v6

	if v7 < minValue then
		v7 = minValue
		v8 = 0
	elseif maxValue < v7 then
		v7 = maxValue
		v8 = 0
	end

	self.x = v7
	self.v = v8
	return v7
end

local v = class.new(4.5, 12.5, 0.5, (max(cameraMaxZoomDistance, 0.5)))

local function stepTargetZoom(p: number, p2: number, p3: number, p4: number)
	local v3 = clamp(p + p2 * (p * 0.0375 + 1), p3, p4)

	if v3 < 1 then
		return p2 <= 0 and p3 or 1
	end

	return v3
end

local v2 = 0
local ZoomController = {}

function ZoomController.Update(p: number, cframe: CFrame, p2)
	local v3

	if v.goal > 1 then
		local x = v.x
		local goal = v.goal
		local v4 = v2
		local v5 = cameraMinZoomDistance
		local v6 = cameraMaxZoomDistance
		local v8 = clamp(goal + v4 * (goal * 0.0375 + 1), v5, v6)

		if v8 < 1 then
			v8 = v4 <= 0 and v5 or 1
		end

		local v9 = max(x, v8)
		v3 = Popper(cframe * CFrame.new(0, 0, 0.5), v9 - 0.5, p2) + 0.5
	else
		v3 = 1e999
	end

	v.minValue = 0.5
	v.maxValue = min(cameraMaxZoomDistance, v3)
	return v:Step(p)
end

function ZoomController.GetZoomRadius()
	return v.x
end

function ZoomController.SetZoomParameters(goal, p)
	v.goal = goal
	v2 = p
end

function ZoomController.ReleaseSpring()
	v.x = v.goal
	v.v = 0
end

return ZoomController