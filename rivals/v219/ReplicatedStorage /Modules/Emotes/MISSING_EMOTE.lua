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
end

function object:_Recolor()
	for _, part in pairs(self._humanoid.Parent:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency < 0.99) then
			continue
		end

		for _, child in pairs(script.Textures:GetChildren()) do
			local clone = child:Clone()
			clone.Parent = part
		end
	end
end

function object:_Init()
	task.spawn(self._Recolor, self)
end

return object