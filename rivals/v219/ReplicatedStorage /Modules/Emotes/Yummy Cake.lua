local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.15, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_SetupProp(script.CakeProp)
	object2:_PlayAnimation("rbxassetid://100896527733090")
	wait(1.2)
	object2:CreateSound("rbxassetid://18128895977", 1.25, 1, nil, true, 5)
	object2:CreateSound("rbxassetid://99386279085681", 1.25, 1, nil, true, 5)
end

function object:_Init() end

return object