local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.1, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://103862270973168")
	object2:CreateSound("rbxassetid://88377109323880", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(0.7)
	object2:CreateSound("rbxassetid://13160326139", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object