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
	object2:_SetupProp(script.BroomProp)
	object2:_PlayAnimation("rbxassetid://111768394484614", "rbxassetid://92649987724159", 4.35)
	object2:CreateSound("rbxassetid://11169686206", 0.75, 1, nil, true, 10)
end

function object:_Init() end

return object