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
	object2:_SetupProp(script.CameraProp)
	object2:_PlayAnimation("rbxassetid://73203002019666", "rbxassetid://81983459727703", 3.1)
	object2:CreateSound("rbxassetid://113889823753206", 1, 0.9 + 0.2 * math.random(), nil, true)
end

function object:_Init() end

return object