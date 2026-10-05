local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Utility = require(ReplicatedStorage.Modules.Utility)
local primeSparkle = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("PrimeSparkle")
local v = {
	[Enum.TextXAlignment.Left] = 0,
	[Enum.TextXAlignment.Right] = 1,
	[Enum.TextYAlignment.Top] = 0,
	[Enum.TextYAlignment.Bottom] = 1
}
local color = Color3.fromRGB(255, 255, 255)
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

		if tick() > _object.Cooldown then
			_object.Cooldown = tick() + 0.5
			local X = _object.IsTextLabel and k.TextBounds.X or k.AbsoluteSize.X
			local Y = _object.IsTextLabel and k.TextBounds.Y or k.AbsoluteSize.Y
			local v2 = not _object.IsTextLabel and 0.5 or v[k.TextXAlignment] or 0.5
			local v3 = not _object.IsTextLabel and 0.5 or v[k.TextYAlignment] or 0.5
			local v4 = (0.375 + 0.25 * math.random()) * 1

			if X > 0 then
				local clone = primeSparkle:Clone()
				clone.ImageTransparency = _object.IsTextLabel and k.TextTransparency or not _object.IsImageLabel and 0 or k.ImageTransparency or 0
				clone.ImageColor3 = color
				clone.Size = UDim2.new(v4, 0, v4, 0)
				clone.Position = UDim2.new(v2, (math.random() - v2) * X, v3, (math.random() - v3) * Y)
				clone.Rotation = math.random() * 360
				clone.Parent = k

				if clone:IsDescendantOf(Players) then
					clone:TweenSize(UDim2.new(), "In", "Back", 2, true)
				end

				table.insert(_object.Particles, {
					Particle = clone,
					Age = 0
				})
			end
		end

		for i = #_object.Particles, 1, -1 do
			local particle = _object.Particles[i]
			particle.Age += p2

			if particle.Age >= 2 then
				particle.Particle:Destroy()
				table.remove(_object.Particles, i)
			else
				particle.Particle.Rotation = particle.Age * 180 * 1
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

function class:_ObjectAdded(guiObject)
	self:_ObjectRemoved(guiObject)
	self._objects[guiObject] = {
		IsTextLabel = guiObject:IsA("TextLabel"),
		IsImageLabel = guiObject:IsA("ImageLabel"),
		Cooldown = 0,
		Particles = {}
	}
end

function class:_Init()
	CollectionService:GetInstanceRemovedSignal("UISparkleEffect"):Connect(function(p)
		self:_ObjectRemoved(p)
	end)
	CollectionService:GetInstanceAddedSignal("UISparkleEffect"):Connect(function(p)
		self:_ObjectAdded(p)
	end)

	for _, v2 in pairs(CollectionService:GetTagged("UISparkleEffect")) do
		task.spawn(self._ObjectAdded, self, v2)
	end
end

return class._new()