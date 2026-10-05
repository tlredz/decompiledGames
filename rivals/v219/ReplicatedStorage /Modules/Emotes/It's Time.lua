local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(6.2, script.Name, ...), object)
	self:_Init()
	return self
end

function object.PlayClient(object2, ...)
	Emote.PlayClient(object2, ...)
	object2:_PlayAnimation("rbxassetid://137924113002985")
	local _SetupMultipleProps = object2:_SetupMultipleProps(script.ItsTimeProp)
	wait(1.9)
	object2:CreateSound("rbxassetid://85464929329408", 1, 0.8 + 0.1 * math.random(), nil, true, 5)
	wait(0.65)
	object2:CreateSound("rbxassetid://85464929329408", 1, 0.9 + 0.1 * math.random(), nil, true, 5)
	wait(0.55)
	object2:CreateSound("rbxassetid://85464929329408", 1, 1 + 0.1 * math.random(), nil, true, 5)
	wait(0.35)
	object2:CreateSound("rbxassetid://135970869546121", 1.25, 1 + 0.1 * math.random(), nil, true, 5)
	wait(0.55)

	for _, _SetupMultipleProp in pairs(_SetupMultipleProps) do
		_SetupMultipleProp.LocalTransparencyModifier = 1
	end
end

function object:_Init() end

return object