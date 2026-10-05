local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(3.85, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://119282539520778")
	wait(0.4)
	object2:CreateSound("rbxassetid://79768694812211", 0.8, 0.9, nil, true, 5)
	wait(0.6)
	object2:CreateSound("rbxassetid://79768694812211", 1, 1.1, nil, true, 5)
	wait(0.95)
	object2:CreateSound("rbxassetid://79768694812211", 0.8, 0.8, nil, true, 5)
	wait(0.4)
	object2:CreateSound("rbxassetid://79768694812211", 1, 1, nil, true, 5)
end

function object:_Init() end

return object