local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.25, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_SetupProp(script.Props)
	object2:_PlayAnimation("rbxassetid://76947942879532")
	object2:CreateSound("rbxassetid://13456860578", 1.25, 1, nil, true, 5)
	wait(1.6)
	object2:CreateSound("rbxassetid://133211885821177", 1.5, 1 + 0.2 * math.random(), nil, true, 5)
end

function object:_Init() end

return object