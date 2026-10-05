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
	object2:_PlayAnimation("rbxassetid://98020061651338", "rbxassetid://99622591614050", 1.3)
	object2:CreateSound("rbxassetid://110965772629921", 1, 1, nil, true)
	wait(1.3)
	local createSound = object2:CreateSound("rbxassetid://100664444144490", 1, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object