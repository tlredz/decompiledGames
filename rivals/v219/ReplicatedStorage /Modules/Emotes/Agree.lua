local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(1.3, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://85429197687197")
	wait(0.25)
	object2:CreateSound("rbxassetid://78663178795648", 1, 1 + 0.1 * math.random(), nil, true, 5)
end

function object:_Init() end

return object