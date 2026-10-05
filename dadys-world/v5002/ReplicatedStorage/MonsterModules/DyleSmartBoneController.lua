local createVector = vector.create
local RunService = game:GetService("RunService")
local DyleSmartBoneController = {}
DyleSmartBoneController.__index = DyleSmartBoneController

function DyleSmartBoneController.new(character, config)
	local object = setmetatable({}, DyleSmartBoneController)
	object.character = character
	object.config = config
	object.humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	local DyleMonster = require(game.ReplicatedStorage.MonsterData.DyleMonster)

	if not DyleMonster.SmartBoneEnabled then
		print("DyleSmartBoneController: SmartBone disabled in config")
		return nil
	end

	local rootPart = character:FindFirstChild("RootPart")

	if not rootPart then
		warn("DyleSmartBoneController: Could not find RootPart in character")
		return nil
	end

	local CollectionService = game:GetService("CollectionService")

	if not CollectionService:HasTag(rootPart, "SmartBone") then
		warn("DyleSmartBoneController: RootPart doesn't have SmartBone tag, model may not be set up correctly")
		return nil
	end

	object.rootPart = rootPart
	object.smartBonePart = rootPart
	object.dynamicEnabled = DyleMonster.SmartBoneDynamic
	object.speedMultiplier = DyleMonster.SmartBoneSpeedMultiplier or 0.5
	object.attackForce = DyleMonster.SmartBoneAttackForce or 2
	object.originalForce = object.smartBonePart:GetAttribute("Force") or createVector(10, 0, 0)
	object.originalDamping = object.smartBonePart:GetAttribute("Damping") or 0.1
	object.originalElasticity = object.smartBonePart:GetAttribute("Elasticity") or 0.5
	object.originalStiffness = object.smartBonePart:GetAttribute("Stiffness") or 0.4
	object.chaser = character:WaitForChild("Chaser", 5)

	if not object.dynamicEnabled then
		return object
	end

	object:startDynamicControl()
	return object
end

function DyleSmartBoneController.applyAttributes(p, items)
	if not p.smartBonePart then
		return
	end

	for k, item in pairs(items) do
		local v = k
		local v2 = item
		local success, result = pcall(function()
			p.smartBonePart:SetAttribute(v, v2)
		end)

		if not success then
			warn("DyleSmartBoneController: Failed to set attribute", k, ":", result)
		end
	end
end

function DyleSmartBoneController:startDynamicControl()
	local v = false
	self.connection = RunService.Heartbeat:Connect(function()
		if not self.character.Parent then
			return
		end

		local dyleSpeedPercent = self.character:GetAttribute("DyleSpeedPercent") or 0
		local attacking = self.chaser and self.chaser:GetAttribute("Attacking") or false

		if attacking and not v then
			self:applyAttackPhysics()
			v = true
		elseif attacking or not v then
			if not attacking then
				self:updateSpeedPhysics(dyleSpeedPercent)
			end
		else
			self:restoreNormalPhysics(dyleSpeedPercent)
			v = false
		end
	end)
end

function DyleSmartBoneController:updateSpeedPhysics(p)
	if not self.smartBonePart then
		return
	end

	local v = 1 + p * self.speedMultiplier
	local v2 = p * 0.05
	local v3 = self.originalForce * v
	self.smartBonePart:SetAttribute("Force", v3)
	self.smartBonePart:SetAttribute("Damping", (math.max(0.05, self.originalDamping - v2)))
	local v4 = p * 0.1
	self.smartBonePart:SetAttribute("Elasticity", (math.max(0.3, self.originalElasticity - v4)))
	local v5 = p * 0.1
	self.smartBonePart:SetAttribute("Stiffness", (math.max(0.2, self.originalStiffness - v5)))
end

function DyleSmartBoneController:applyAttackPhysics()
	if not self.smartBonePart then
		return
	end

	local v = self.originalForce * self.attackForce
	self.smartBonePart:SetAttribute("Force", v)
	self.smartBonePart:SetAttribute("Elasticity", (math.min(0.9, self.originalElasticity + 0.2)))
	self.smartBonePart:SetAttribute("Damping", 0.05)
	self.smartBonePart:SetAttribute("Stiffness", 0.2)
	print("DyleSmartBoneController: Attack physics applied")
end

function DyleSmartBoneController:restoreNormalPhysics(p)
	if not self.smartBonePart then
		return
	end

	local force = self.smartBonePart:GetAttribute("Force")
	local v = self.originalForce * (1 + p * self.speedMultiplier)

	for i = 1, 10 do
		if not self.character.Parent then
			break
		end

		local lerped = force:Lerp(v, i / 10)
		self.smartBonePart:SetAttribute("Force", lerped)
		self.smartBonePart:SetAttribute("Damping", self.originalDamping)
		self.smartBonePart:SetAttribute("Elasticity", self.originalElasticity)
		self.smartBonePart:SetAttribute("Stiffness", self.originalStiffness)
		task.wait(0.05)
	end

	self:updateSpeedPhysics(p)
end

function DyleSmartBoneController:destroy()
	if self.connection then
		self.connection:Disconnect()
		self.connection = nil
	end

	if self.smartBonePart then
		self.smartBonePart:SetAttribute("Force", self.originalForce)
		self.smartBonePart:SetAttribute("Damping", self.originalDamping)
		self.smartBonePart:SetAttribute("Elasticity", self.originalElasticity)
		self.smartBonePart:SetAttribute("Stiffness", self.originalStiffness)
	end

	print("DyleSmartBoneController: Destroyed")
end

return DyleSmartBoneController