local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local TransparencyController = {}
TransparencyController.__index = TransparencyController

function TransparencyController.new()
	local self = setmetatable({}, TransparencyController)
	self.lastUpdate = tick()
	self.transparencyDirty = false
	self.enabled = false
	self.lastTransparency = nil
	self.descendantAddedConn = nil
	self.descendantRemovingConn = nil
	self.toolDescendantAddedConns = {}
	self.toolDescendantRemovingConns = {}
	self.cachedParts = {}
	self.waitingMeshConnection = nil
	self.cachedWaitingParts = {}
	return self
end

function TransparencyController:HasToolAncestor(p)
	return p.Parent ~= nil and (p.Parent:IsA("Tool") or self:HasToolAncestor(p.Parent))
end

function TransparencyController:IsValidPartToModify(instance)
	if instance and instance:HasTag("_MESH_LOADING_") then
		self.cachedWaitingParts[instance] = true
		return false
	end

	if instance:IsA("BasePart") or instance:IsA("Decal") then
		return not self:HasToolAncestor(instance)
	end

	return false
end

function TransparencyController:CachePartsRecursive(instance)
	if instance then
		if self:IsValidPartToModify(instance) then
			self.cachedParts[instance] = true
			self.transparencyDirty = true
		end

		for _, child in pairs(instance:GetChildren()) do
			self:CachePartsRecursive(child)
		end
	end
end

function TransparencyController:TeardownTransparency()
	for k, _ in pairs(self.cachedParts) do
		k.LocalTransparencyModifier = 0
	end

	table.clear(self.cachedWaitingParts)
	self.cachedParts = {}
	self.transparencyDirty = true
	self.lastTransparency = nil

	if self.waitingMeshConnection then
		self.waitingMeshConnection:Disconnect()
		self.waitingMeshConnection = nil
	end

	if self.descendantAddedConn then
		self.descendantAddedConn:disconnect()
		self.descendantAddedConn = nil
	end

	if self.descendantRemovingConn then
		self.descendantRemovingConn:disconnect()
		self.descendantRemovingConn = nil
	end

	for k, toolDescendantAddedConn in pairs(self.toolDescendantAddedConns) do
		toolDescendantAddedConn:Disconnect()
		self.toolDescendantAddedConns[k] = nil
	end

	for k, toolDescendantRemovingConn in pairs(self.toolDescendantRemovingConns) do
		toolDescendantRemovingConn:Disconnect()
		self.toolDescendantRemovingConns[k] = nil
	end
end

function TransparencyController:SetupTransparency(ancestor)
	self:TeardownTransparency()

	if self.waitingMeshConnection then
		self.waitingMeshConnection:Disconnect()
	end

	local CollectionService = game:GetService("CollectionService")
	self.waitingMeshConnection = CollectionService:GetInstanceRemovedSignal("_MESH_LOADING_"):Connect(function(p)
		if p and self.cachedWaitingParts[p] and p.Parent then
			self.cachedWaitingParts[p] = nil
			self:CachePartsRecursive(p)
		end
	end)

	if self.descendantAddedConn then
		self.descendantAddedConn:disconnect()
	end

	self.descendantAddedConn = ancestor.DescendantAdded:Connect(function(tool)
		if self:IsValidPartToModify(tool) then
			self.cachedParts[tool] = true
			self.transparencyDirty = true
		elseif tool:IsA("Tool") then
			if self.toolDescendantAddedConns[tool] then
				self.toolDescendantAddedConns[tool]:Disconnect()
			end

			self.toolDescendantAddedConns[tool] = tool.DescendantAdded:Connect(function(instance)
				self.cachedParts[instance] = nil

				if instance:IsA("BasePart") or instance:IsA("Decal") then
					instance.LocalTransparencyModifier = 0
				end
			end)

			if self.toolDescendantRemovingConns[tool] then
				self.toolDescendantRemovingConns[tool]:disconnect()
			end

			self.toolDescendantRemovingConns[tool] = tool.DescendantRemoving:Connect(function(descendant)
				wait()

				if ancestor and descendant and descendant:IsDescendantOf(ancestor) and self:IsValidPartToModify(descendant) then
					self.cachedParts[descendant] = true
					self.transparencyDirty = true
				end
			end)
		end
	end)

	if self.descendantRemovingConn then
		self.descendantRemovingConn:disconnect()
	end

	self.descendantRemovingConn = ancestor.DescendantRemoving:connect(function(p)
		if self.cachedParts[p] then
			self.cachedParts[p] = nil
			p.LocalTransparencyModifier = 0
		end
	end)
	self:CachePartsRecursive(ancestor)
end

function TransparencyController:Enable(enabled)
	if self.enabled ~= enabled then
		self.enabled = enabled
		self:Update()
	end
end

function TransparencyController:SetSubject(instance)
	local parent

	if instance and instance:IsA("Humanoid") then
		parent = instance.Parent
	end

	if instance and instance:IsA("VehicleSeat") and instance.Occupant then
		parent = instance.Occupant.Parent
	end

	if parent then
		self:SetupTransparency(parent)
	else
		self:TeardownTransparency()
	end
end

function TransparencyController:Update()
	local now = tick()
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		local clamped

		if self.enabled then
			local magnitude = (currentCamera.Focus.p - currentCamera.CoordinateFrame.p).magnitude
			local v2 = magnitude < 2 and 1 - (magnitude - 0.5) / 1.5 or 0
			local v3 = v2 < 0.5 and 0 or v2

			if self.lastTransparency then
				local clamped2 = v3 - self.lastTransparency

				if v3 < 1 and self.lastTransparency < 0.95 then
					local v4 = 2.8 * (now - self.lastUpdate)
					clamped2 = CameraUtils.Clamp(-v4, v4, clamped2)
				end

				v3 = self.lastTransparency + clamped2
			else
				self.transparencyDirty = true
			end

			clamped = CameraUtils.Clamp(0, 1, CameraUtils.Round(v3, 2))
		else
			clamped = 0
		end

		if self.transparencyDirty or self.lastTransparency ~= clamped then
			for k, _ in pairs(self.cachedParts) do
				k.LocalTransparencyModifier = clamped
			end

			self.transparencyDirty = false
			self.lastTransparency = clamped
		end
	end

	self.lastUpdate = now
end

return TransparencyController