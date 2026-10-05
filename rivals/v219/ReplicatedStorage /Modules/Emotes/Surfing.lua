local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Utility)
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
	object2:_SetupProp(script.SurfProp)
	object2:_PlayAnimation("rbxassetid://126498832296593", "rbxassetid://88575062377123", 4)
	object2:CreateSound("rbxassetid://108806529299457", 1, 1 + 0.05 * math.random(), nil, true)
	local createSound = object2:CreateSound("rbxassetid://137714378265704", 1, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object