local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConcertSharedConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("ConcertSharedConfig"))
local NeonPulseController = {}
NeonPulseController.__index = NeonPulseController

function NeonPulseController.new()
	local self = setmetatable({}, NeonPulseController)
	self._parts = {}
	self._modelParts = {}
	self._connections = {}
	self._time = 0
	self:_init()
	return self
end

function NeonPulseController:_cacheModel(model)
	if not model:IsA("Model") or self._modelParts[model] then
		return
	end

	local parts = {}

	for _, part in ipairs(model:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Material = Enum.Material.Neon
		self._parts[part] = true
		table.insert(parts, part)
	end

	self._modelParts[model] = parts
	local descendantAddedConnection = model.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Neon
			self._parts[part] = true
			table.insert(self._modelParts[model], part)
		end
	end)
	local descendantRemovingConnection = model.DescendantRemoving:Connect(function(part)
		if part:IsA("BasePart") then
			self._parts[part] = nil
			local _modelPart = self._modelParts[model]
			local index = _modelPart and table.find(_modelPart, part)

			if index then
				table.remove(_modelPart, index)
			end
		end
	end)
	table.insert(self._connections, descendantAddedConnection)
	table.insert(self._connections, descendantRemovingConnection)
end

function NeonPulseController:_uncacheModel(p2)
	local _modelPart = self._modelParts[p2]

	if _modelPart then
		for _, v in ipairs(_modelPart) do
			self._parts[v] = nil
		end

		self._modelParts[p2] = nil
	end
end

function NeonPulseController:_cachePart(part)
	if not part:IsA("BasePart") then
		return
	end

	part.Material = Enum.Material.Neon
	self._parts[part] = true
end

function NeonPulseController:_uncachePart(p2)
	self._parts[p2] = nil
end

function NeonPulseController:_init()
	for _, v in ipairs(CollectionService:GetTagged("Neons")) do
		self:_cacheModel(v)
	end

	local connection = CollectionService:GetInstanceAddedSignal("Neons"):Connect(function(p)
		self:_cacheModel(p)
	end)
	local connection2 = CollectionService:GetInstanceRemovedSignal("Neons"):Connect(function(p)
		self:_uncacheModel(p)
	end)
	table.insert(self._connections, connection)
	table.insert(self._connections, connection2)

	for _, v in ipairs(CollectionService:GetTagged("NeonPart")) do
		self:_cachePart(v)
	end

	local connection3 = CollectionService:GetInstanceAddedSignal("NeonPart"):Connect(function(p)
		self:_cachePart(p)
	end)
	local connection4 = CollectionService:GetInstanceRemovedSignal("NeonPart"):Connect(function(p)
		self:_uncachePart(p)
	end)
	table.insert(self._connections, connection3)
	table.insert(self._connections, connection4)
end

function NeonPulseController:update(p: number)
	local neonPulseDuration = ConcertSharedConfig.NeonPulseDuration or 4
	local neonMinimumBrightness = ConcertSharedConfig.NeonMinimumBrightness or 0
	local neonMaximumBrightness = ConcertSharedConfig.NeonMaximumBrightness or 1
	local neonBaseColor = ConcertSharedConfig.NeonBaseColor or Color3.fromRGB(103, 172, 114)
	local neonPulseColor = ConcertSharedConfig.NeonPulseColor or Color3.fromRGB(0, 0, 0)
	self._time = (self._time + p) % neonPulseDuration
	local midpoint = (math.sin(self._time * 3.141592653589793 * 2 / neonPulseDuration) + 1) / 2
	local lerped = neonPulseColor:Lerp(
		neonBaseColor,
		neonMinimumBrightness + (neonMaximumBrightness - neonMinimumBrightness) * midpoint
	)

	for k in pairs(self._parts) do
		if k and k.Parent then
			k.Color = lerped
		else
			self._parts[k] = nil
		end
	end
end

function NeonPulseController:destroy()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)
	table.clear(self._parts)
	table.clear(self._modelParts)
end

return NeonPulseController