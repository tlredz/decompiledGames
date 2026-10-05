local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(3.9, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	local _SetupProp = object2:_SetupProp(script.PhoneProp)
	object2:_PlayAnimation("rbxassetid://87719925359671")
	wait(0.4)
	Utility:PlayParticles(_SetupProp)
	object2:CreateSound("rbxassetid://96932112018810", 1, 1, nil, true, 5)
	wait(0.65)
	Utility:PlayParticles(_SetupProp)
	object2:CreateSound("rbxassetid://96932112018810", 1, 1, nil, true, 5)
	wait(0.15)
	Utility:PlayParticles(_SetupProp)
	object2:CreateSound("rbxassetid://96932112018810", 1, 1, nil, true, 5)
end

function object:_Init() end

return object