local DissolveRay = {}
DissolveRay.__index = DissolveRay
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local ammoLabel = Client.Interface.AmmoLabel
game:GetService("RunService")
game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
game:GetService("TweenService")
local dissolveHighlight = workspace:WaitForChild("Highlights"):WaitForChild("DissolveHighlight")

function DissolveRay.new(model, realModel)
	local self = setmetatable({}, DissolveRay)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	return self
end

function DissolveRay:CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	self.Attachment = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 16
	proximityPrompt.ActionText = "Dissolve"
	proximityPrompt.HoldDuration = 0.75
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	self.Prompt = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("paint", self.CurrentFocus)
		self:AttemptPaintStructure(self.CurrentFocus)
	end)
end

function DissolveRay:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function DissolveRay:PrepareStructures()
	if self.LoopChecking then
		return
	end

	self.LoopChecking = true
	self.StructureOptions = CollectionService:GetTagged("NPC")
	self.StructureAddedEvent = CollectionService:GetInstanceAddedSignal("NPC"):Connect(function(p)
		table.insert(self.StructureOptions, p)
	end)
	self.StructureRemovedEvent = CollectionService:GetInstanceRemovedSignal("NPC"):Connect(function(p)
		local index = table.find(self.StructureOptions, p)

		if index then
			table.remove(self.StructureOptions, index)
		end
	end)
end

function DissolveRay:GetClosestStructure()
	local v = nil
	local v2 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for _, structureOption in pairs(self.StructureOptions) do
		if structureOption.Parent ~= workspace.Characters then
			continue
		end

		local magnitude = (position - structureOption:GetPivot().Position).Magnitude

		if not (magnitude < v2 and self:CanDissolve(structureOption)) then
			continue
		end

		v = structureOption
		v2 = magnitude
	end

	return v, v2
end

function DissolveRay:CanDissolve(instance)
	if instance:GetAttribute("NotAttackable") or instance:GetAttribute("Dead") then
		return
	end

	local NPC = instance:FindFirstChild("NPC")

	if not NPC or instance.Parent ~= workspace.Characters or instance:GetAttribute("Tamed") then
		return
	end

	if NPC.Health / NPC.MaxHealth <= localPlayer:GetAttribute("DissolveThreshold") then
		return true
	end
end

function DissolveRay:HighlightClosestStructure()
	local closestStructure, v = self:GetClosestStructure()
	local v2 = nil

	if closestStructure and v <= 25 then
		v2 = closestStructure
	end

	if v2 ~= self.CurrentFocus then
		if v2 then
			dissolveHighlight.Adornee = v2
			dissolveHighlight.Enabled = true
		else
			dissolveHighlight.Adornee = nil
			dissolveHighlight.Enabled = false
		end
	end

	self.CurrentFocus = v2
end

function DissolveRay:LoopCheckClosestStructures()
	task.spawn(function()
		while self.Equipped do
			self:HighlightClosestStructure()
			task.wait(0.1)
		end
	end)
end

function DissolveRay:UpdateAmmo()
	ammoLabel.Text = "Essence Collected: " .. math.round(localPlayer:GetAttribute("AlienEssencePct") or 0) .. "%"
	ammoLabel.Visible = true
end

function DissolveRay:Dissolve(instance)
	local pivot = instance:GetPivot()
	instance.Parent = game.ReplicatedStorage
	Client.Sound.Play("DissolveEnemy")
	Client.Utility.SpawnParticles("DissolveParticles", pivot)
	local v = Client.Events.RequestDissolveEnemy:InvokeServer(instance)

	if not (v and v.Success) then
		task.delay(1, function()
			instance.Parent = workspace.Characters
		end)
	end
end

function DissolveRay:Activate()
	local currentFocus = self.CurrentFocus

	if currentFocus and self:CanDissolve(currentFocus) then
		self:Dissolve(currentFocus)
	else
		Client.Sound.Play("Alien_GunFailed")
	end

	return Enum.ContextActionResult.Sink
end

function DissolveRay.Deactivate(_) end

function DissolveRay:OnEquip()
	self.Equipped = true
	self:PrepareStructures()
	self:LoopCheckClosestStructures()
	self.AmmoChangedEvent = localPlayer:GetAttributeChangedSignal("AlienEssencePct"):Connect(function()
		self:UpdateAmmo()
	end)
	self:UpdateAmmo()
end

function DissolveRay:OnUnequip()
	self.Equipped = false
	Client.StructureInterfaceClient.CloseMenu()
	dissolveHighlight.Adornee = nil
	self.StructureRemovedEvent:Disconnect()
	self.StructureAddedEvent:Disconnect()
	self.StructureOptions = {}

	if self.AmmoChangedEvent then
		self.AmmoChangedEvent:Disconnect()
	end

	ammoLabel.Visible = false
end

return DissolveRay