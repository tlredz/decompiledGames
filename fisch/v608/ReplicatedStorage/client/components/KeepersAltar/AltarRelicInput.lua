local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage.packages
local Component = require(packages.Component)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
require(packages.Signal)
local modules = ReplicatedStorage.shared.modules
require(modules.SharedDataHelper)
local SharedKeeperEnchant = require(modules.SharedKeeperEnchant)
require(modules.library.rods)
local fish = require(modules.library.fish)
require(modules.library.rods.enchants)
local fx = require(modules.fx)
local assets = require(ReplicatedStorage.shared.utils.assets)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local playerDataReplicator = DataController.PlayerDataReplicator
local legacyControllers = ReplicatedStorage.client.legacyControllers
require(legacyControllers.HudController)
local InventoryController = require(legacyControllers.InventoryController)
require(legacyControllers.PlayerController)
local remoteFunction = Net:RemoteFunction("EnchantAltar/OfferRelic", -1)
local altarpillars = ReplicatedStorage:WaitForChild("resources"):WaitForChild("sounds"):WaitForChild("sfx"):WaitForChild("altarpillars")
local v = Component.new({
	Tag = "AltarRelicInput",
	Ancestors = { workspace }
})

function v:Construct()
	self.trove = Trove.new()
	self.CurrentModel = nil
	self.CurrentModelType = nil
	self.ModelDownloadId = nil
	self.Prompt = self.Instance:WaitForChild("InputCenter"):WaitForChild("ProximityPrompt")
	self.DefaultActionText = self.Prompt.ActionText
	self.Processing = false
end

function v:UpdateVisual()
	playerDataReplicator:WaitForLoaded()
	local currentModelType = self.Instance.Parent and self.Instance.Parent:GetAttribute("Active") and playerDataReplicator:Index({
		"StatuesSecret",
		"AltarState",
		self.Instance:GetAttribute("RelicType")
	})
	local v3 = currentModelType and fish[currentModelType]

	if currentModelType and v3 then
		local relicColorMain = v3.RelicColorMain or Color3.fromRGB(85, 255, 193)
		local relicColorSecondary = v3.RelicColorSecondary or v3.RelicColorMain or Color3.fromRGB(93, 255, 104)
		local colorSequence = ColorSequence.new(relicColorMain)
		local colorSequence2 = ColorSequence.new(relicColorSecondary)

		for _, descendant in self.Instance:GetDescendants() do
			if not (descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Light")) then
				continue
			end

			if not (descendant.Enabled or descendant:IsA("Light")) then
				descendant.LocalTransparencyModifier = 1
				TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {
					LocalTransparencyModifier = 0
				}):Play()
			end

			descendant.Enabled = true
		end

		for _, instance in self.Instance:QueryDescendants(".RecolorPrimary, .ColoredCracks") do
			if instance:IsA("Beam") or instance:IsA("ParticleEmitter") then
				instance.Color = colorSequence
			elseif instance:IsA("Light") or instance:IsA("BasePart") then
				instance.Color = relicColorMain
			end
		end

		for _, instance in self.Instance:QueryDescendants(".RecolorSecondary") do
			if instance:IsA("Beam") or instance:IsA("ParticleEmitter") then
				instance.Color = colorSequence2
			elseif instance:IsA("Light") or instance:IsA("BasePart") then
				instance.Color = relicColorSecondary
			end
		end

		if not (self.CurrentModel and self.CurrentModel.Parent or self.ModelDownloadId) or self.CurrentModelType ~= currentModelType then
			if self.CurrentModel then
				self.trove:Remove(self.CurrentModel)
				self.CurrentModel = nil
			end

			fx:PlaySound(altarpillars:WaitForChild(v3.RelicOfferSound or "default"), self.Instance.PrimaryPart, false)
			local clone = script.ActivateParticles:Clone()
			clone.Parent = self.Instance.PrimaryPart

			for _, emitter in clone:GetChildren() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Color = colorSequence
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			task.delay(10, clone.Destroy, clone)
			self.CurrentModelType = currentModelType
			self.ModelDownloadId = (self.ModelDownloadId or 0) + 1
			local modelDownloadId = self.ModelDownloadId
			local async = assets.getAsync("fish", currentModelType)

			if self.ModelDownloadId == modelDownloadId then
				self.ModelDownloadId = nil

				if async then
					local clone2 = async:Clone()
					clone2:PivotTo(self.Instance:GetPivot() * (v3.RelicDisplayRotation or CFrame.identity))
					clone2:ScaleTo(clone2:GetScale() * 2)
					clone2.Name = "ActiveRelic"

					for _, part in clone2:GetDescendants() do
						if not part:IsA("BasePart") then
							continue
						end

						part.Anchored = true
						part.CanCollide = false
						part.CanTouch = false
						part.CanQuery = false
					end

					clone2.Parent = self.Instance
					self.trove:Add(clone2)
					self.CurrentModel = clone2
				end
			end
		end
	else
		if self.CurrentModel then
			self.trove:Remove(self.CurrentModel)
			self.CurrentModel = nil
			self.CurrentModelType = nil
		end

		for _, descendant in self.Instance:GetDescendants() do
			if not (descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Light")) then
				continue
			end

			descendant.Enabled = false
		end

		for _, v4 in self.Instance:QueryDescendants(".ColoredCracks") do
			local HSV = v4.Color:ToHSV()
			v4.Color = Color3.fromHSV(HSV, 0.25, 0.33)
		end
	end
end

function v:Update()
	if not self.Instance.Parent or not self.Instance.Parent:GetAttribute("Active") or self.Processing then
		self.Prompt.Enabled = false
		return
	end

	playerDataReplicator:WaitForLoaded()
	local index = playerDataReplicator:Index({ "StatuesSecret", "AltarState", self.Instance:GetAttribute("RelicType") })

	if #SharedKeeperEnchant.GetAcceptedRelics(self.Instance:GetAttribute("RelicType")) > 1 then
		self.Prompt.Enabled = true
	else
		self.Prompt.Enabled = index == nil
	end

	local equippedAcceptedRelic = self:GetEquippedAcceptedRelic()
	local prompt = self.Prompt
	local actionText

	if equippedAcceptedRelic then
		actionText = `Offer {equippedAcceptedRelic.name}`
	else
		actionText = self.DefaultActionText
	end

	prompt.ActionText = actionText
end

function v:GetEquippedAcceptedRelic()
	local equippedItem = InventoryController.EquippedItem

	if equippedItem and table.find(
		SharedKeeperEnchant.GetAcceptedRelics(self.Instance:GetAttribute("RelicType")),
		equippedItem.name
	) then
		return equippedItem, InventoryController.EquippedItemId
	end

	return nil
end

function v:Start()
	self.trove:Add(self.Prompt.Triggered:Connect(function()
		if not (self.Instance.Parent and self.Instance.Parent:GetAttribute("Active")) then
			self.Prompt.Enabled = false
			return
		end

		local v2 = nil
		local _, v3 = self:GetEquippedAcceptedRelic()

		if v3 then
			v2 = v3
		elseif self.Instance:GetAttribute("CanSearchInventory") then
			v2 = SharedKeeperEnchant.FindOfferRelic(Players.LocalPlayer, self.Instance:GetAttribute("RelicType"))
		end

		if not v2 then
			ReplicatedStorage.events.anno_localthought:Fire((`This pillar requires a {self.Instance:GetAttribute("RelicType")} Relic.`))
			return
		end

		self.Processing = true
		self.Prompt.Enabled = false
		local v4, v5 = remoteFunction:InvokeServer(self.Instance, v2)

		if not v4 then
			ReplicatedStorage.events.anno_localthought:Fire(v5)
		end

		self.Processing = false
		self:Update()
		self:UpdateVisual()
	end))
	self.trove:Add(playerDataReplicator:Listen(
		{ "StatuesSecret", "AltarState", self.Instance:GetAttribute("RelicType") },
		function()
			self:Update()
			self:UpdateVisual()
		end
	))
	self.trove:Add(InventoryController.EquippedToolChanged:Connect(function()
		self:Update()
	end))

	if self.Instance.Parent then
		self.trove:Add(self.Instance.Parent:GetAttributeChangedSignal("Active"):Connect(function()
			self:Update()
			self:UpdateVisual()
		end))
	end

	self:Update()
	self:UpdateVisual()
end

function v:Stop()
	self.trove:Clean()
	self.CurrentModel = nil
	self.CurrentModelType = nil
	self.ModelDownloadId = nil
end

return v