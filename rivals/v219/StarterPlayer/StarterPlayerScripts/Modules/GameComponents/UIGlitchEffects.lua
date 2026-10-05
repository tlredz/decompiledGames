local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
game:GetService("Players")
local ItemLibrary = require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local v = {
	[Enum.TextXAlignment.Left] = 0,
	[Enum.TextXAlignment.Right] = 1,
	[Enum.TextYAlignment.Top] = 0,
	[Enum.TextYAlignment.Bottom] = 1
}
local color = Color3.fromRGB(0, 0, 0)
local color2 = ItemLibrary.Statuses.Contraband.Color
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self._objects = {}
	self:_Init()
	return self
end

function class:Update(p2)
	for k, _object in pairs(self._objects) do
		if not Utility:IsUIElementVisible(k) then
			continue
		end

		if _object.IsTextLabel then
			local v2 = Vector2.new(math.min(5, k.AbsoluteSize.X), (math.min(5, k.AbsoluteSize.Y))) * Vector2.new(
				math.random() - 0.5,
				math.random() - 0.5
			)
			local v3 = math.min(math.abs(v2.X), (math.abs(v2.Y)))
			k.Position = _object.OriginalPosition + UDim2.new(
				0,
				math.min(math.abs(v2.X), v3) * math.sign(v2.X),
				0,
				math.min(math.abs(v2.Y), v3) * math.sign(v2.Y)
			)
		end

		if tick() > _object.Cooldown then
			_object.Cooldown = tick() + 0.1
			local X = _object.IsTextLabel and k.TextBounds.X or k.AbsoluteSize.X
			local Y = _object.IsTextLabel and k.TextBounds.Y or k.AbsoluteSize.Y
			local v2 = not _object.IsTextLabel and 0.5 or v[k.TextXAlignment] or 0.5
			local v3 = not _object.IsTextLabel and 0.5 or v[k.TextYAlignment] or 0.5
			local v4 = (0.375 + 0.25 * math.random()) * 0.375
			local v5 = (0.375 + 0.25 * math.random()) * 0.375

			if X > 0 then
				local frame = Instance.new("Frame")
				frame.BorderSizePixel = 0
				frame.AnchorPoint = Vector2.new(0.5, 0.5)
				frame.BackgroundColor3 = color2:Lerp(color, math.random())
				frame.Size = UDim2.new(v4, 0, v5, 0)
				frame.Position = UDim2.new(v2, (math.random() - v2) * X, v3, (math.random() - v3) * Y)
				local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
				uIAspectRatioConstraint.AspectRatio = 1 + 2 * math.random()
				uIAspectRatioConstraint.Parent = frame
				frame.Parent = k
				table.insert(_object.Particles, {
					Particle = frame,
					Age = 0,
					OriginalPosition = frame.Position,
					Direction = math.sign(math.random() - 0.5)
				})
			end
		end

		for i = #_object.Particles, 1, -1 do
			local particle = _object.Particles[i]
			particle.Age += p2

			if particle.Age >= 0.5 then
				particle.Particle:Destroy()
				table.remove(_object.Particles, i)
			else
				particle.Particle.Position = particle.OriginalPosition + UDim2.new(
					0,
					particle.Age * 10 * particle.Direction,
					0,
					0
				)

				if not _object.IsTextLabel then
					local v2 = particle.Particle.AbsoluteSize * Vector2.new(math.random() - 0.5, math.random() - 0.5) * 0.25
					particle.Particle.Position += UDim2.new(0, v2.X, 0, v2.Y)
				end
			end
		end
	end
end

function class:_ObjectRemoved(p2)
	if not self._objects[p2] then
		return
	end

	for _, particle in pairs(self._objects[p2].Particles) do
		particle.Particle:Destroy()
	end

	self._objects[p2] = nil
end

function class:_ObjectAdded(label)
	self:_ObjectRemoved(label)
	self._objects[label] = {
		IsTextLabel = label:IsA("TextLabel"),
		OriginalPosition = label.Position,
		Cooldown = 0,
		Particles = {}
	}
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("UIGlitchEffect"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("UIGlitchEffect"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v2 in pairs(CollectionService:GetTagged("UIGlitchEffect")) do
		task.spawn(self._ObjectAdded, self, v2)
	end
end

return class._new()