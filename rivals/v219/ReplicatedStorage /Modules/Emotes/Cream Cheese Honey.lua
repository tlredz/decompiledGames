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
	object2:_PlayAnimation("rbxassetid://71250144811352")
	local createSound = object2:CreateSound("rbxassetid://120250934207816", 1, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object