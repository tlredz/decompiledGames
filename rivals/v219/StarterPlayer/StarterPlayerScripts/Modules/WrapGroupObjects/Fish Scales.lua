game:GetService("TweenService")
local Players = game:GetService("Players")
local WrapGroupObject = require(Players.LocalPlayer.PlayerScripts.Modules.WrapGroupObject)
local object = setmetatable({}, WrapGroupObject)
object.__index = object

function object.new(...)
	local self = setmetatable(WrapGroupObject.new(...), object)
	self:_Init()
	return self
end

function object.Update(_, _) end

function object:_Evaluate(instance)
	local v = math.floor(DateTime.now().UnixTimestamp / 86400)
	local number = Random.new(v):NextNumber(0, 0.92)

	if instance:IsA("BasePart") then
		local _, v2, v3 = instance.Color:ToHSV()
		instance.Color = Color3.fromHSV(number, v2, v3)
	elseif instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
		local _, v2, v3 = instance.Color.Keypoints[1].Value:ToHSV()
		local color = Color3.fromHSV(number, v2, v3)
		instance.Color = ColorSequence.new(color)
	elseif instance:IsA("RopeConstraint") or instance:IsA("RodConstraint") then
		local _, v2, v3 = instance.Color.Color:ToHSV()
		local color = Color3.fromHSV(number, v2, v3)
		instance.Color = BrickColor.new(color)
	end
end

function object:_Setup()
	self:_Evaluate(self.Object)

	for _, extraObject in self.ExtraObjects do
		self:_Evaluate(extraObject)
	end
end

function object:_Init()
	self:_Setup()
end

return object