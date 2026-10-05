local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Emote = require(ReplicatedStorage.Modules.Emote)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	self:_PlayAnimation("rbxassetid://113081315310439", "rbxassetid://105533660677821", 1.3)
	local clone = script.Part.Attachment:Clone()
	clone.Name = "BadFeeling"
	clone.Parent = self._humanoid.Parent:FindFirstChild("Head")
	table.insert(self._destroy_these, clone)
	local createSound = self:CreateSound("rbxassetid://104971481474038", 0.75, 1, nil, true)
	createSound.Looped = true
end

function object:_Init() end

return object