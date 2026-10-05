local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(5.25, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://73786487009083")
	object2:CreateSound("rbxassetid://122605533507524", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(0.5)
	object2:CreateSound("rbxassetid://126514820442685", 0.75, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object