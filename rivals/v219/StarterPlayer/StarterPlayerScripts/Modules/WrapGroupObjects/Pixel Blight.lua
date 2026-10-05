local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self:_Init()
	return self
end

function object:_Brighten(p)
	local HSV, v, v2 = p:ToHSV()
	return v2 < (v > 0.5 and 0.1 or 0.35) and p or Color3.fromHSV(HSV, v, (math.max(0.75, v2)))
end

function object:_Setup()
	if self.Object:IsA("BasePart") then
		self.Object.Color = self:_Brighten(self.Object.Color)
	elseif self.Object:IsA("Beam") or self.Object:IsA("Trail") or self.Object:IsA("ParticleEmitter") then
		local colorSequenceKeypoints = {}

		for _, keypoint in pairs(self.Object.Color.Keypoints) do
			table.insert(
				colorSequenceKeypoints,
				ColorSequenceKeypoint.new(keypoint.Time, self:_Brighten(keypoint.Value))
			)
		end

		self.Object.Color = ColorSequence.new(colorSequenceKeypoints)
	end
end

function object:_Init()
	self:_Setup()
end

return object