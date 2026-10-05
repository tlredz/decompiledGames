local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Component = require(packages:WaitForChild("Component"))
local Trove = require(packages:WaitForChild("Trove"))
local Net = require(packages:WaitForChild("Net"))
local legacyControllers = ReplicatedStorage:WaitForChild("client"):WaitForChild("legacyControllers")
local InventoryController = require(legacyControllers:WaitForChild("InventoryController"))
local DataController = require(legacyControllers:WaitForChild("DataController"))
local playerDataReplicator = DataController.PlayerDataReplicator
local SettingsController = require(legacyControllers:WaitForChild("SettingsController"))
local modules = ReplicatedStorage:WaitForChild("shared"):WaitForChild("modules")
local fish = require(modules:WaitForChild("library"):WaitForChild("fish"))
local mutations = require(modules:WaitForChild("fishing"):WaitForChild("mutations"))
local FishModel = require(modules.FishModel)
local utils = ReplicatedStorage:WaitForChild("shared"):WaitForChild("utils")
local assets = require(utils:WaitForChild("assets"))
local remoteFunction = Net:RemoteFunction("ItemSubmit/RequestSubmit", -1)
local _ = Players.LocalPlayer
local v = Component.new({
	Tag = "ItemSubmit"
})

-- equivalent calls inferred from this helper; original call sites unknown
local function arrayAttribute(value: string?)
	if value then
		return value:split(";;")
	end

	return nil
end

function v:Construct()
	self.Trove = Trove.new()
	self.Submitting = false
end

function v:UpdatePrompt()
	self.Prompt.Enabled = not self:GetPlacedInfo() and InventoryController:CheckHeldItem(
		self.RequiredNames,
		self.RequiredSub
	)
end

function v:GetPlacedInfo()
	if not self.Instance:GetAttribute("ServerSide") then
		playerDataReplicator:WaitForLoaded()
		return playerDataReplicator:TryIndex({ "ItemSubmit", "ActiveLocal", self.Instance:GetAttribute("UID") }) or nil
	end

	local placedItem = self.Instance:GetAttribute("PlacedItem")

	if placedItem == "" then
		return nil
	end

	return placedItem
end

function v:UpdatePlacedItem()
	self:UpdatePrompt()
	local placedInfo = self:GetPlacedInfo()

	if self.PlacedItem and not placedInfo then
		self.Trove:Remove(self.PlacedItem)
		self.PlacedItem = nil
	elseif placedInfo and not self.PlacedItem then
		local v2 = fish[placedInfo] ~= nil
		local v3

		if v2 and self.RequiredSub.Shiny then
			v3 = "Shiny_" .. placedInfo
		else
			v3 = placedInfo
		end

		local async = assets.getAsync(v2 and "fish" or "item", v3)

		if async then
			if not async:IsA("Model") then
				async = async:FindFirstChildWhichIsA("Model")

				if not async then
					return
				end
			end

			local clone = async:Clone()

			if v2 and self.RequiredSub.Sparkling then
				FishModel.ApplySparkling(clone, fish[placedInfo].SparkleColor)
			end

			if v2 and typeof(self.RequiredSub.Mutation) == "string" then
				local clone2 = table.clone(self.RequiredSub)
				clone2.Name = placedInfo
				mutations:MutateModel(clone, self.RequiredSub.Mutation, clone2)
			end

			for _, part in clone:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Massless = true
			end

			local maxItemSize = self.Instance:GetAttribute("MaxItemSize") or 8
			local extentsSize = clone:GetExtentsSize()
			local v4 = math.max(extentsSize.X, extentsSize.Y, extentsSize.Z)
			self.PlacedItemSizeY = extentsSize.Y

			if maxItemSize < v4 then
				clone:ScaleTo(clone:GetScale() * (maxItemSize / v4))
				self.PlacedItemSizeY *= maxItemSize / v4
			end

			clone:PivotTo(self.Instance:GetPivot() * (self.Instance:GetAttribute("DisplayOffset") or CFrame.identity) * CFrame.new(
				0,
				self.PlacedItemSizeY / 2 + self.PodiumSizeY / 2,
				0
			))
			clone.Parent = self.Instance
			self.PlacedItem = self.Trove:Add(clone)
		end
	end
end

function v:UpdateRequirements()
	local requiredNames = arrayAttribute(self.Instance:GetAttribute("RequiredName")) -- equivalent call inferred; original call site unknown
	self.RequiredNames = requiredNames
	local mutation = arrayAttribute(self.Instance:GetAttribute("RequiredMutation")) -- equivalent call inferred; original call site unknown
	self.RequiredSub = {
		Mutation = mutation,
		Shiny = self.Instance:GetAttribute("RequiredShiny") or nil,
		Sparkling = self.Instance:GetAttribute("RequiredSparkling") or nil,
		Weight = self.Instance:GetAttribute("RequiredWeight") or nil
	}
	self.Prompt.ObjectText = self.Instance:GetAttribute("ObjectText") or "Podium"
	self.Prompt.ActionText = self.Instance:GetAttribute("ActionText") or "Place Item"
	self.Prompt.HoldDuration = self.Instance:GetAttribute("HoldDuration") or 1
	self.Prompt.MaxActivationDistance = self.Instance:GetAttribute("MaxDistance") or 12
	self.FloatDistance = self.Instance:GetAttribute("FloatDistance")
	self.FloatTime = 1 / (self.Instance:GetAttribute("FloatSpeed") or 1)
	self.DisplayOffset = self.Instance:GetAttribute("DisplayOffset") or CFrame.identity
	self:UpdatePlacedItem()
end

function v:AttemptSubmit()
	if not self.Submitting and InventoryController:CheckHeldItem(self.RequiredNames, self.RequiredSub) then
		self.Submitting = true
		remoteFunction:InvokeServer(self.Instance:GetAttribute("UID"))
		self.Submitting = false
	end
end

function v:Start()
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Triggered:Connect(function()
		self:AttemptSubmit()
	end)
	proximityPrompt.Parent = self.Instance
	self.Prompt = self.Trove:Add(proximityPrompt)

	if self.Instance:IsA("Model") then
		self.PodiumSizeY = self.Instance:GetExtentsSize().Y
	elseif self.Instance:IsA("BasePart") then
		self.PodiumSizeY = self.Instance.Size.Y
	end

	self:UpdateRequirements()
	self.Trove:Connect(self.Instance.AttributeChanged, function()
		self:UpdateRequirements()
	end)
	self.Trove:Connect(InventoryController.EquippedToolChanged, function()
		self:UpdatePrompt()
	end)

	if self.Instance:GetAttribute("ServerSide") then
		self.Trove:Connect(self.Instance:GetAttributeChangedSignal("IsPlaced"), function()
			self:UpdatePlacedItem()
		end)
	else
		self.Trove:Add(playerDataReplicator:Observe(
			{ "ItemSubmit", "ActiveLocal", self.Instance:GetAttribute("UID") },
			function()
				task.defer(self.UpdatePlacedItem, self)
			end
		))
	end

	if self.Instance:GetAttribute("FloatDistance") then
		self.Trove:Connect(RunService.RenderStepped, function()
			if SettingsController:GetSettingValue("shownVfx") == "HideAll" then
				return
			end

			if self.PlacedItem then
				local v2 = self.PlacedItemSizeY / 2 + self.PodiumSizeY / 2 + self.FloatDistance * math.sin(os.clock() * self.FloatTime)
				self.PlacedItem:PivotTo(self.Instance:GetPivot() * self.DisplayOffset * CFrame.new(0, v2, 0))
			end
		end)
	end
end

function v:Stop()
	self.Trove:Clean()
	self.Prompt = nil
	self.PlacedItem = nil
end

return v