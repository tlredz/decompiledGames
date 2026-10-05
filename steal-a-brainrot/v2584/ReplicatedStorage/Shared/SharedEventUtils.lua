local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MathUtils = require(ReplicatedStorage.Utils.MathUtils)
require(ReplicatedStorage.Packages.Trove)
local count = 0
local v = {}
local v2 = {}
local inverse = CFrame.new(-410.752, -9.782, 59.406):Inverse()
local _3RoadsEvent = ReplicatedStorage:GetAttribute("3RoadsEvent")
ReplicatedStorage:GetAttributeChangedSignal("3RoadsEvent"):Connect(function()
	_3RoadsEvent = ReplicatedStorage:GetAttribute("3RoadsEvent")
end)

local function pushPartCFrame(p, cframe: CFrame)
	count += 1
	v[count] = p
	v2[count] = cframe
end

local function isPointInCarpet(vector2: Vector3)
	if _3RoadsEvent then
		return MathUtils.isPointInVolume_direct(vector2, inverse, createVector(68, 661.5, 401))
	end

	return MathUtils.isPointInVolume_direct(vector2, inverse, createVector(20, 661.5, 401))
end

local function isPointInCarpetHalf(vector2: Vector3)
	if _3RoadsEvent then
		return MathUtils.isPointInVolume_direct(vector2, inverse, createVector(34, 661.5, 200.5))
	end

	return MathUtils.isPointInVolume_direct(vector2, inverse, createVector(10, 661.5, 200.5))
end

local function stepParts()
	debug.profilebegin("SharedEventUtils:StepParts")
	workspace:BulkMoveTo(v, v2, Enum.BulkMoveMode.FireCFrameChanged)
	count = 0
	table.clear(v)
	table.clear(v2)
	debug.profileend()
end

local function loadAnimation(object, animator, animation)
	local track = animator:LoadAnimation(animation)

	local function cleanup()
		track:Stop(0)
		track:Destroy()
	end

	object:Add(cleanup)
	return track, function()
		object:Remove(cleanup)
	end
end

if RunService:IsServer() then
	RunService.PostSimulation:Connect(stepParts)
else
	RunService.PreRender:Connect(stepParts)
end

return {
	pushPartCFrame = pushPartCFrame,
	isPointInCarpet = isPointInCarpet,
	isPointInCarpetHalf = isPointInCarpetHalf,
	loadAnimation = loadAnimation
}