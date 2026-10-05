local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(7.4, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_SetupProp(script.AwardProp)
	object2:_PlayAnimation("rbxassetid://84334527267845")
	object2:CreateSound("rbxassetid://82968610908198", 1, 0.95 + 0.1 * math.random(), nil, true, 10)
end

function object:_Init() end

return object