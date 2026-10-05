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
	object2:_PlayAnimation("rbxassetid://115000869501227", "rbxassetid://83376670167687", 4.15)
	object2:CreateSound("rbxassetid://80133530921906", 1.5, 1, nil, true)
	wait(15.54)
	local createSound = object2:CreateSound("rbxassetid://98970356172671", 1.5, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object