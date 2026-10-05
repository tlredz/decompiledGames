local ZoomController = require(script.Parent:WaitForChild("ZoomController"))
local class = {}
class.__index = class
local cframe = CFrame.new()

local function cframeToAxis(object)
	local axisAngle, v = object:toAxisAngle()
	return axisAngle * v
end

-- equivalent calls inferred from this helper; original call sites unknown
local function axisToCFrame(p)
	local magnitude = p.magnitude

	if magnitude > 0.00001 then
		return CFrame.fromAxisAngle(p, magnitude)
	end

	return cframe
end

-- equivalent calls inferred from this helper; original call sites unknown
local function extractRotation(lastCFrame)
	local _, _, _, v, v2, v3, v4, v5, v6, v7, v8, v9 = lastCFrame:components()
	return CFrame.new(0, 0, 0, v, v2, v3, v4, v5, v6, v7, v8, v9)
end

function class.new()
	return (setmetatable({
		lastCFrame = nil
	}, class))
end

function class:Step(p2, lastCFrame)
	local lastCFrame2 = self.lastCFrame or lastCFrame
	self.lastCFrame = lastCFrame
	local p3 = lastCFrame.p
	local rotation = extractRotation(lastCFrame) -- equivalent call inferred; original call site unknown
	local p4 = lastCFrame2.p
	local rotation2 = extractRotation(lastCFrame2) -- equivalent call inferred; original call site unknown
	local posVelocity = (p3 - p4) / p2
	local axisAngle, v4 = (rotation * rotation2:inverse()):toAxisAngle()
	local rotVelocity = axisAngle * v4 / p2
	return {
		extrapolate = function(p5)
			local v6 = posVelocity * p5 + p3
			local v8 = axisToCFrame(rotVelocity * p5) -- equivalent call inferred; original call site unknown
			return v8 * rotation + v6
		end,
		posVelocity = posVelocity,
		rotVelocity = rotVelocity
	}
end

function class:Reset()
	self.lastCFrame = nil
end

local BaseOcclusion = require(script.Parent:WaitForChild("BaseOcclusion"))
local object = setmetatable({}, BaseOcclusion)
object.__index = object

function object.new()
	local self = setmetatable(BaseOcclusion.new(), object)
	self.focusExtrapolator = class.new()
	return self
end

function object.GetOcclusionMode(_)
	return Enum.DevCameraOcclusionMode.Zoom
end

function object.Enable(p, _)
	p.focusExtrapolator:Reset()
end

function object.Update(p, p2, p3, p4, _)
	local v = CFrame.new(p4.p, p3.p) * CFrame.new(0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0, -1)
	local v2 = p.focusExtrapolator:Step(p2, v)
	local v3 = ZoomController.Update(p2, v, v2)
	return v * CFrame.new(0, 0, v3), p4
end

function object.CharacterAdded(_, _, _) end

function object.CharacterRemoving(_, _, _) end

function object.OnCameraSubjectChanged(_, _) end

return object