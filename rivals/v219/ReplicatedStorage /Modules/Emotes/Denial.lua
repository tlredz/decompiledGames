local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(1.75, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://81555757574094")
	object2:CreateSound("rbxassetid://75485128790168", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(0.4)
	object2:CreateSound("rbxassetid://13158735106", 1, 1.2, nil, true, 5)
	wait(0.2)
	object2:CreateSound("rbxassetid://13158735106", 1, 1, nil, true, 5)
	wait(0.2)
	object2:CreateSound("rbxassetid://13158735106", 1, 1.3, nil, true, 5)
end

function object:_Init() end

return object