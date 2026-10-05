local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(4.25, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://125921589993721")
	wait(0.4)
	object2:CreateSound("rbxassetid://134218301690577", 0.5, 1 + 0.1 * math.random(), nil, true, 5)
	object2:CreateSound("rbxassetid://71288358864209", 1, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object