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
	object2:_SetupProp(script.PortalProp)
	object2:_PlayAnimation("rbxassetid://118879812674727", "rbxassetid://137721007241440", 2.45)
	wait(1.4)
	object2:CreateSound("rbxassetid://7127702569", 1, 1.2, nil, true, 5)
end

function object:_Init() end

return object