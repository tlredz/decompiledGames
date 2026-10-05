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
	object2:_SetupProp(script.HorseProp)
	object2:_PlayAnimation("rbxassetid://90957073891780", "rbxassetid://131785768380910", 4.45)
	object2:CreateSound("rbxassetid://119722200205656", 1, 1, nil, true)
	local createSound = object2:CreateSound("rbxassetid://100899302728675", 0.5, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object