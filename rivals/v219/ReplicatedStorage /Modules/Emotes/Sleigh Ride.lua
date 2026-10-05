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
	object2:_SetupProp(script.SleighProp)
	object2:_PlayAnimation("rbxassetid://109002557953309", "rbxassetid://81364109953531", 2.82)
	local createSound = object2:CreateSound("rbxassetid://121867696577749", 2, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object