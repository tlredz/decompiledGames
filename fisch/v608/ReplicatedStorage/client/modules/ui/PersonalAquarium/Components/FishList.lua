local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local packages = ReplicatedStorage.packages
require(packages.State)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Promise = require(packages.Promise)
local utils = ReplicatedStorage.shared.utils
local NumberUtils = require(utils.NumberUtils)
local assets = require(utils.assets)
local FischUtils = require(utils.FischUtils)
local modules = ReplicatedStorage.shared.modules
local fish = require(modules.library.fish)
require(modules.fishing.mutations)
local FishModel = require(modules.FishModel)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local NotificationController = require(legacyControllers.NotificationController)
local DataController = require(legacyControllers.DataController)
local aquariumController = legacyControllers.AquariumController
local viewportModule = require(aquariumController.viewportModule)
local legacy = ReplicatedStorage.client.legacy
local legacyUiLoader = require(legacy.legacyUiLoader)
local sharedPersonalAquarium = modules.SharedPersonalAquarium
require(sharedPersonalAquarium.SharedTypes)
local sharedData = sharedPersonalAquarium.SharedData
local SlotData = require(sharedData.SlotData)
local sharedFunctions = sharedPersonalAquarium.SharedFunctions
local RewardFunctions = require(sharedFunctions.RewardFunctions)
require("../Types")
local remoteEvent = Net:RemoteEvent("PersonalAquarium/AddFish")
local remoteEvent2 = Net:RemoteEvent("PersonalAquarium/AddCosmeticFish")
local remoteEvent3 = Net:RemoteEvent("PersonalAquarium/RemoveCosmeticFish")
local remoteEvent4 = Net:RemoteEvent("PersonalAquarium/RemoveFish")
local remoteEvent5 = Net:RemoteEvent("PersonalAquarium/BuyNextSlot")
local _ = legacyUiLoader.PlayerGui.hud.safezone.PersonalAquarium
local color = Color3.fromRGB(145, 145, 145)

local function isAddValid()
	local localPlayer = Players.LocalPlayer
	local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
	local link = tool and tool:FindFirstChild("link")

	if not link then
		NotificationController:Notify("You don't have a fish in your hand!", 3)
		return
	end

	if DataController.getItem(link.Value) then
		return link.Value
	end

	NotificationController:Notify("You don't have a fish in your hand!", 3)
end

local FishList = {}
local v = false

function FishList.Start(_, dependencies)
	FishList.Dependencies = dependencies
	FishList.Trove = Trove.new()
	FishList._SetTemplates()
	FishList.Dependencies.Shared.CurrentFishType:observe(FishList._OnFishTypeChanged)
	FishList.Dependencies.Shared.PersonalAquariumController.ProfileCacheChangedSignal:Connect(function()
		if dependencies.Instance.Parent.Visible and v then
			FishList.Trove:Clean()
			FishList._OnFishTypeChanged(FishList.Dependencies.Shared.CurrentFishType:get())
		end
	end)
	FishList.PriceInRobuxMap = {}

	for k, v2 in SlotData.PerSlot do
		local v3 = v2
		local v4 = k
		Promise.new(function(p)
			local productInfo = MarketplaceService:GetProductInfo(v3.DeveloperProductID, Enum.InfoType.Product)
			FishList.PriceInRobuxMap[v4] = productInfo.PriceInRobux
		end)
	end
end

function FishList.Opened()
	v = true
	FishList._OnFishTypeChanged(FishList.Dependencies.Shared.CurrentFishType:get())
end

function FishList.Closed()
	v = false
	FishList._ClearFishList()
end

local function getDisplayName(p)
	return (`{FischUtils.ItemDisplay(p, {
		rich = true,
		disable_newlines = true,
		rarity_color = true
	})} <font color='#b3b3b3'><b>({NumberUtils:Comma(p.sub.Weight or 0)}kg)</b></font>`)
end

local function buildFish(p, instance, p2, flag: boolean?)
	if not p then
		return
	end

	FishList.Trove:Add(instance)
	local camera = Instance.new("Camera")
	instance.vpbg.vp.CurrentCamera = camera
	camera.Parent = instance.vpbg.vp
	FishList.Trove:Add(camera)
	local flag2 = false
	FishList.Trove:Add(function()
		flag2 = true
	end)
	FishList.Trove:Add(task.spawn(function()
		local folder = nil
		pcall(function()
			folder = FishModel.Create({
				Name = p.name,
				ItemData = p.sub,
				ResizeArgs = {
					MaxSize = 14
				},
				CastShadow = false
			})
		end)

		if flag2 then
			if folder then
				folder:Destroy()
			end
		elseif folder then
			if instance and instance:FindFirstChild("vpbg") then
				for _, part in pairs(folder:GetDescendants()) do
					if part:IsA("BasePart") and part.Material == Enum.Material.Neon then
						part.Material = Enum.Material.Plastic
					end
				end

				folder.Parent = instance.vpbg.vp
				local v2 = viewportModule.new(instance.vpbg.vp, camera)

				for _, part in pairs(folder:GetChildren()) do
					if not (part:IsA("BasePart") and part.Name:lower():find("template")) then
						continue
					end

					part:Destroy()
				end

				local boundingBox, _ = folder:GetBoundingBox()
				local v3 = not (fish[p.name] and fish[p.name].ViewportSizeOffset) and 1 or fish[p.name].ViewportSizeOffset
				v2:SetModel(folder)
				local v4 = v2:GetFitDistance(boundingBox.Position) * v3
				local total = 0
				local cframe = CFrame.new()
				camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v4)
				FishList.Trove:Connect(RunService.RenderStepped, function(p3)
					total += math.rad(20 * p3)
					cframe = CFrame.fromEulerAnglesYXZ(0, total, 0.4363323129985824)
					camera.CFrame = CFrame.new(boundingBox.Position) * cframe * CFrame.new(0, 0, v4)
				end)
			else
				if instance then
					instance:Destroy()
				end

				if folder then
					folder:Destroy()
				end
			end
		elseif instance then
			instance:Destroy()
		end
	end))
	instance.FishName.Text = getDisplayName(p)

	if flag then
		instance.Earnings:Destroy()
		instance.CompoundLoss:Destroy()
		instance.Cosmetic.Image = "rbxassetid://122617339295515"
	else
		local hourlyRewardsForFish, v2 = RewardFunctions.getHourlyRewardsForFish(p, p2)

		if v2 > 0 then
			instance.CompoundLoss.Text = `Duplicate: <b>-{math.ceil(v2)}%</b>`
			instance.CompoundLoss.Visible = true
		else
			instance.CompoundLoss.Visible = false
		end

		instance.Earnings["C$"].Text = `{hourlyRewardsForFish.HourlyCoins} C$/Hr. `
		instance.Earnings.XP.Text = `{hourlyRewardsForFish.HourlyXP} XP/Hr. `
		instance.Earnings.Items.Label.Text = `{hourlyRewardsForFish.HourlyItems} Items/Hr.`
	end
end

function FishList._SetTemplates()
	FishList.FishTemplate = FishList.Dependencies.Instance.ScrollingFrame.Fish:Clone()
	FishList.AddTemplate = FishList.Dependencies.Instance.ScrollingFrame.Add:Clone()
	FishList.CosmeticTemplate = FishList.Dependencies.Instance.ScrollingFrame.Cosmetic:Clone()
	FishList.UnlockTemplate = FishList.Dependencies.Instance.ScrollingFrame.Unlock:Clone()
	FishList.Dependencies.Instance.ScrollingFrame.Unlock:Destroy()
	FishList.Dependencies.Instance.ScrollingFrame.Add:Destroy()
	FishList.Dependencies.Instance.ScrollingFrame.Fish:Destroy()
	FishList.Dependencies.Instance.ScrollingFrame.Cosmetic:Destroy()
end

function FishList._ClearFishList()
	FishList.Trove:Clean()
end

local flag = false

function FishList._BuildFishList()
	if not v then
		return
	end

	FishList.Trove:Add(task.defer(function()
		if not v then
			return
		end

		local cache = FishList.Dependencies.Shared.PersonalAquariumController.Cache

		if not cache then
			return
		end

		local fishIndex = cache.FishIndex
		local cosmeticFishIndex = cache.CosmeticFishIndex
		local v2 = cosmeticFishIndex and #cosmeticFishIndex or 0
		local fishSlotsUnlocked = cache.FishSlotsUnlocked
		local count = #fishIndex
		DataController.InventoryReplicator:WaitForLoaded()
		local v3 = {}

		for k, v4 in fishIndex do
			local item = DataController.getItem(v4)

			if not item then
				continue
			end

			local clone = FishList.FishTemplate:Clone()
			clone.LayoutOrder = k
			local v6 = v4
			local v7 = item

			if pcall(function()
				FishList.Dependencies.Shared.HandleButtonFn(clone.Discard, function()
					remoteEvent4:FireServer(v6)
				end, false)
				table.insert(v3, v7)
				buildFish(v7, clone, v3)
				clone.Parent = FishList.Dependencies.Instance.ScrollingFrame
			end) then
				local _SetupCosmeticToggle = FishList._SetupCosmeticToggle
				local v8

				if cosmeticFishIndex then
					v8 = cosmeticFishIndex[k]
				end

				_SetupCosmeticToggle(clone, k, v8, v2)
			else
				if clone then
					clone:Destroy()
				end

				if flag then
					return
				end

				flag = true
				local v8 = v4
				local v9 = item
				task.defer(function()
					warn((`Resource stream timeout or other problem. Retrying load in a moment. {v8}`))
					assets.cancelDownload("fish", v9.name)
					task.wait(2)
					flag = false
					FishList._OnFishTypeChanged(FishList.Dependencies.Shared.CurrentFishType:get())
				end)
				return
			end
		end

		for i = 1, fishSlotsUnlocked - count do
			local layoutOrder = count + i
			local clone = FishList.AddTemplate:Clone()
			FishList.Trove:Add(clone)
			clone.LayoutOrder = layoutOrder
			clone.Active = true
			FishList.Dependencies.Shared.HandleButtonFn(clone, function()
				local addValid = isAddValid()

				if not addValid then
					return
				end

				remoteEvent:FireServer(addValid)
			end, false)
			clone.Parent = FishList.Dependencies.Instance.ScrollingFrame
			local _SetupCosmeticToggle = FishList._SetupCosmeticToggle
			local v5

			if cosmeticFishIndex then
				v5 = cosmeticFishIndex[layoutOrder]
			end

			_SetupCosmeticToggle(clone, layoutOrder, v5, v2)
		end

		if fishSlotsUnlocked == #SlotData.PerSlot then
			return
		end

		local costInSoftCurrency = SlotData.PerSlot[fishSlotsUnlocked + 1].CostInSoftCurrency
		local v4 = FishList.Trove:Add(FishList.UnlockTemplate:Clone())
		v4.LayoutOrder = fishSlotsUnlocked + 1
		v4.Parent = FishList.Dependencies.Instance.ScrollingFrame
		v4.Options["C$"].Label.Text = NumberUtils:ToString(costInSoftCurrency) .. " Coins"
		v4.Options.Robux.Label.Text = `{utf8.char(57346)} {FishList.PriceInRobuxMap[fishSlotsUnlocked + 1] or "Err."}`
		FishList.Dependencies.Shared.HandleButtonFn(v4.Options["C$"], function()
			remoteEvent5:FireServer("SoftCurrency")
		end, false)
		FishList.Dependencies.Shared.HandleButtonFn(v4.Options.Robux, function()
			remoteEvent5:FireServer("HardCurrency")
		end, false)
	end))
end

function FishList:_SetupCosmeticToggle(layoutOrder, p2, p3)
	local scrollingFrame = FishList.Dependencies.Instance.ScrollingFrame
	local enabled = p2 ~= nil
	local cosmeticActive = self.Cosmetic:FindFirstChild("CosmeticActive")

	if cosmeticActive then
		cosmeticActive.Enabled = enabled
	end

	local v3 = nil

	local function showProfit()
		if v3 then
			v3.Visible = false
		end

		self.Visible = true
	end

	local function ensureCosmeticFace()
		if v3 then
			return
		end

		if enabled then
			local clone = FishList.FishTemplate:Clone()
			clone.LayoutOrder = layoutOrder
			FishList.Dependencies.Shared.HandleButtonFn(clone.Discard, function()
				remoteEvent3:FireServer(p2)
			end, false)
			FishList.Dependencies.Shared.HandleButtonFn(clone.Cosmetic, showProfit, false)
			buildFish(DataController.getItem(p2), clone, {}, true)
			clone.Parent = scrollingFrame
			v3 = clone
		else
			local clone = FishList.CosmeticTemplate:Clone()
			clone.LayoutOrder = layoutOrder
			FishList.Trove:Add(clone)
			FishList.Dependencies.Shared.HandleButtonFn(clone, function()
				local addValid = isAddValid()

				if not addValid then
					return
				end

				remoteEvent2:FireServer(addValid)
			end, false)
			FishList.Dependencies.Shared.HandleButtonFn(clone.Back, showProfit, false)
			clone.Parent = scrollingFrame
			v3 = clone
		end
	end

	local v4 = enabled or layoutOrder == p3 + 1

	if not v4 then
		self.Cosmetic.CosmeticActive.Enabled = false
		self.Cosmetic.ImageColor3 = color
	end

	FishList.Dependencies.Shared.HandleButtonFn(self.Cosmetic, function()
		if v4 then
			ensureCosmeticFace()
			self.Visible = false

			if v3 then
				v3.Visible = true
			end
		else
			local v5 = {}

			for i = p3 + 1, layoutOrder - 1 do
				table.insert(v5, (tostring(i)))
			end

			NotificationController:Notify(`Use cosmetic slot {table.concat(v5, ", ")} before using this slot!`, 3)
		end
	end, false)
end

function FishList._OnFishTypeChanged(_)
	if not v then
		return
	end

	FishList.Trove:Clean()
	FishList._BuildFishList()
end

return FishList