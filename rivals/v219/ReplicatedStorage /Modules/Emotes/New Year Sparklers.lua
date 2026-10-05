local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://93712852727557", "rbxassetid://97084758451290", 3.6)
	local _SetupMultipleProps = object2:_SetupMultipleProps(script.SparklersProp)
	wait(1.1)

	for _, effect in pairs(_SetupMultipleProps.stick1:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	object2:CreateSound("rbxassetid://15573552175", 3, 1 + 0.1 * math.random(), nil, true, 5)
	local createSound = object2:CreateSound("rbxassetid://75644699023746", 1, 1, nil, true)
	createSound.Looped = true
	wait(1.65)

	for _, effect in pairs(_SetupMultipleProps.stick2:GetDescendants()) do
		if effect:IsA("ParticleEmitter") or effect:IsA("Trail") then
			effect.Enabled = true
		end
	end

	object2:CreateSound("rbxassetid://15573552175", 3, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object