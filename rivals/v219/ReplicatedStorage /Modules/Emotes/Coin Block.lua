local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(2.75, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_SetupProp(script.BlockProp)
	object2:_PlayAnimation("rbxassetid://95053547196006")
	wait(1.5)
	object2:CreateSound("rbxassetid://113804909921716", 1, 1, nil, true, 5)
	wait(0.35)
	object2:CreateSound("rbxassetid://85894619049999", 1, 1, nil, true, 5)
	object2:CreateSound("rbxassetid://79780131367448", 1, 1, nil, true, 5)
end

function object:_Init() end

return object