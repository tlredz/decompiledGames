local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.6, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://133733650708343")
	wait(0.3)
	object2:CreateSound("rbxassetid://13160326139", 1, 1.3, nil, true, 5)
	wait(0.4)
	object2:CreateSound("rbxassetid://13160326139", 1.1, 1.4, nil, true, 5)
end

function object:_Init() end

return object