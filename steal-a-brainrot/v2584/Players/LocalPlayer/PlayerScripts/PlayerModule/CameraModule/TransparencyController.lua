local VRService = game:GetService("VRService")
local v = {
	"BasePart",
	"Decal",
	"Beam",
	"ParticleEmitter",
	"Trail",
	"Fire",
	"Smoke",
	"Sparkles",
	"Explosion"
}
local CameraUtils = require(script.Parent:WaitForChild("CameraUtils"))
local success, result = pcall(function()
	return UserSettings():IsUserFeatureEnabled("UserHideCharacterParticlesInFirstPerson")
end)
local v2 = success and result
local TransparencyController = {}
TransparencyController.__index = TransparencyController

function TransparencyController.new()
	local self = setmetatable({}, TransparencyController)
	self.transparencyDirty = false
	self.enabled = false
	self.lastTransparency = nil
	self.descendantAddedConn = nil
	self.descendantRemovingConn = nil
	self.toolDescendantAddedConns = {}
	self.toolDescendantRemovingConns = {}
	self.cachedParts = {}
	return self
end

function TransparencyController:HasToolAncestor(p)
	if p.Parent == nil then
		return false
	end

	assert(p.Parent, "")
	return p.Parent:IsA("Tool") or self:HasToolAncestor(p.Parent)
end

function TransparencyController:IsValidPartToModify(instance)
	if v2 then
		for _, className in v do
			if instance:IsA(className) then
				return not self:HasToolAncestor(instance)
			end
		end
	elseif instance:IsA("BasePart") or instance:IsA("Decal") then
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

	self.cachedParts = {}
	self.transparencyDirty = true
	self.lastTransparency = nil

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

function TransparencyController:Enable(enabled: boolean)
	if self.enabled ~= enabled then
		self.enabled = enabled
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

function TransparencyController:Update(p)
	local currentCamera = workspace.CurrentCamera

	if currentCamera and self.enabled then
		local magnitude = (currentCamera.Focus.p - currentCamera.CoordinateFrame.p).magnitude
		local v3 = magnitude < 2 and 1 - (magnitude - 0.5) / 1.5 or 0
		local v4 = v3 < 0.5 and 0 or v3

		if self.lastTransparency and v4 < 1 and self.lastTransparency < 0.95 then
			local v5 = v4 - self.lastTransparency
			local v6 = 2.8 * p
			local v7 = math.clamp(v5, -v6, v6)
			v4 = self.lastTransparency + v7
		else
			self.transparencyDirty = true
		end

		local v5 = math.clamp(CameraUtils.Round(v4, 2), 0, 1)

		if self.transparencyDirty or self.lastTransparency ~= v5 then
			for k, _ in pairs(self.cachedParts) do
				if VRService.VREnabled and VRService.AvatarGestures then
					local v6 = {
						[Enum.AccessoryType.Hat] = true,
						[Enum.AccessoryType.Hair] = true,
						[Enum.AccessoryType.Face] = true,
						[Enum.AccessoryType.Eyebrow] = true,
						[Enum.AccessoryType.Eyelash] = true
					}

					if k.Parent:IsA("Accessory") and v6[k.Parent.AccessoryType] or k.Name == "Head" then
						k.LocalTransparencyModifier = v5
					else
						k.LocalTransparencyModifier = 0
					end
				else
					k.LocalTransparencyModifier = v5
				end
			end

			self.transparencyDirty = false
			self.lastTransparency = v5
		end
	end
end

return TransparencyController