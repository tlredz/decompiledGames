local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Common.MarketplaceService)
local localPlayer = Players.LocalPlayer
local ContextActionService = game:GetService("ContextActionService")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils.Utilities.Icons)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Freeze)
local v5 = require3(ReplicatedStorage2.Packages.Replion)
local v6 = require3(ReplicatedStorage2.Shared.DynArgs)
local v7 = require3(ReplicatedStorage2.ClientGameModules.CoreCall)
local v8 = require3(ReplicatedStorage2.Common.Utils)
local v9 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.Packages.Observers)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v10 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v11 = require3(ReplicatedStorage2.ServerInfo)
local v12 = require3(ReplicatedStorage2.Common.Utils.Utilities.ValueConvertor)
require3(ReplicatedStorage2.Common.GachaItemsData)
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v13 = require3(ReplicatedStorage2.Shared.DeleteItemUtils)
local v14 = require3(ReplicatedStorage2.ClientGameModules.CreatePriceLabel)
local v15 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v16 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local v17 = require3(ReplicatedStorage2.Shared.ProgressiveRewardsData)
local v18 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v19 = require3(ReplicatedStorage2.Controllers.DeleteItemPromptController)
local v20 = require3(script.Parent.Parent)
local v21 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v22 = require3(ReplicatedStorage2.Shared.UiPresets)
local v23 = require3(ReplicatedStorage2.Controllers.UI.HUDController)
local v24 = require3(ReplicatedStorage2.Controllers.GiftingController)
require3(ReplicatedStorage2.Controllers.HalloweenGachaNPCController)
local v25 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v26 = require3(ReplicatedStorage2.Controllers.Trading.RAPChartController)
local v27 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
local playerGui = localPlayer.PlayerGui
local controllerShop = playerGui:WaitForChild("ControllerShop")
local main = controllerShop.Main
local deleteItems = main.DeleteItems
local list = deleteItems.List
local scrollingFrame = list.ContentsCanvas.ScrollingFrame
v3.new()
local v28 = {
	Sword = v9.State(),
	Explosion = v9.State(),
	Ability = v9.State(),
	Robux = v9.State()
}
local pagesSearchs = {
	Sword = v9.State(),
	Explosion = v9.State(),
	Ability = v9.State(),
	Robux = v9.State()
}
local v30 = {
	Sword = v9.State("Default"),
	Explosion = v9.State("Default"),
	Ability = v9.State("Default")
}
local v31 = {
	Sword = v9.State(Enum.SortDirection.Ascending),
	Explosion = v9.State(Enum.SortDirection.Ascending),
	Ability = v9.State(Enum.SortDirection.Ascending)
}
local state = v9.State(false)
v9.setPropertyState(deleteItems, "Visible", state)
local v32 = {}
local state2 = v9.State("Ability")
local state3 = v9.State("All")
local state4 = v9.State(false)
local frameUIHiddenDynArgs = v6.Or()
frameUIHiddenDynArgs:LinkState(state4)
local computed = v9.Computed(function(callback)
	return not callback(state4)
end)
local state5 = v9.State(false)
local v34 = v6.Or()
v34:LinkState(state5)
local computed2 = v9.Computed(function(callback)
	return not callback(state5)
end)
v34:AddStatable(state)
local v35 = {
	Normal = Color3.fromRGB(124, 120, 113),
	Limited = Color3.fromRGB(37, 131, 255),
	LimitedU = Color3.fromRGB(37, 131, 255),
	Rare = Color3.fromRGB(218, 59, 59),
	Legendary = Color3.fromRGB(255, 204, 0),
	Unique = Color3.fromRGB(120, 17, 129)
}
local v36 = {
	[true] = {
		Image = "rbxassetid://15697987058",
		HoverImage = "rbxassetid://15697983062"
	},
	[false] = {
		Image = "rbxassetid://15697981750",
		HoverImage = "rbxassetid://15697987058"
	}
}
local color = Color3.fromRGB(255, 166, 0)
local v37 = { "All", "Owned", "Unowned" }
local v38 = {
	Sword = v37,
	Explosion = v37,
	Ability = v37
}
local v39 = {
	[Enum.SortDirection.Descending] = -1,
	[Enum.SortDirection.Ascending] = 1
}
local v40 = { "Sword", "Explosion" }
local v41 = {
	All = function(_, _)
		return true
	end,
	Owned = function(p, callback)
		return not p.OwnedCopies or callback(p.OwnedCopies) > 0
	end,
	Unowned = function(p, callback)
		if p.OwnedCopies then
			return callback(p.OwnedCopies) <= 0
		end

		return false
	end
}
local remoteEvent = v:RemoteEvent("ConfigureRandomizerEvent")
local Console = {
	DataReplion = nil,
	PagesSearchs = pagesSearchs,
	FrameUIHiddenDynArgs = frameUIHiddenDynArgs,
	PageInfo = {
		Sword = {
			ItemState = v28.Sword,
			Template = controllerShop.Templates.SwordTemplate,
			PageName = "Sword"
		},
		Explosion = {
			ItemState = v28.Explosion,
			Template = controllerShop.Templates.ExplosionTemplate,
			PageName = "Explosion"
		},
		Ability = {
			ItemState = v28.Ability,
			Template = controllerShop.Templates.AbilityTemplate,
			PageName = "Ability"
		},
		Robux = {
			ItemState = v28.Robux,
			Template = controllerShop.Templates.DevProductTemplate,
			PageName = "Robux"
		}
	}
}
local v42 = {
	Sword = Console.PageInfo.Sword,
	Explosion = Console.PageInfo.Explosion,
	Ability = Console.PageInfo.Ability,
	Robux = Console.PageInfo.Robux
}
local v43 = {
	Sword = "SwordSkins",
	Explosion = "ExplosionSkins",
	Ability = "Abilities"
}
Console.ItemTypesTemplates = {
	GamePass = controllerShop.Templates.GamePassTemplate,
	DevProduct = controllerShop.Templates.DevProductTemplate
}

function Console:SetSelectedItems()
	local equippedItem = v20:GetEquippedItem("Sword")
	v28.Sword:Set(v20:GetItemData("Sword", v20:ParseItemKey("Sword", equippedItem or {
		Name = "Base Sword"
	})))
	local equippedItem2 = v20:GetEquippedItem("Ability")
	v28.Ability:Set(v20:GetItemData("Ability", v20:ParseItemKey("Ability", equippedItem2 or {
		Name = "Dash"
	})))
	local equippedItem3 = v20:GetEquippedItem("Explosion")
	v28.Explosion:Set(v20:GetItemData("Explosion", v20:ParseItemKey("Explosion", equippedItem3 or {
		Name = "Explosion Normal"
	})))
end

function Console:Open()
	v10:Open("ControllerShop")
	v23:Hide("ControllerShop")
	v26:Close("ControllerShop")
	self:SetSelectedItems()
	v7(Enum.CoreGuiType.Chat, false)
end

function Console:Close()
	v10:Close("ControllerShop")
	v23:Show("ControllerShop")
	v7(Enum.CoreGuiType.Chat, true)
end

function Console.SwitchPage(_) end

function Console.OpenRobuxPage(_)
	state2:Set("Robux")
end

local function applyColor(instance, color2)
	if typeof(color2) == "Color3" then
		instance.TextColor3 = color2
		return
	end

	instance.TextColor3 = Color3.new(1, 1, 1);
	(instance:FindFirstChildWhichIsA("UIGradient") or Instance.new("UIGradient", instance)).Color = color2
end

function Console:UpdateDeletingItems()
	for k, v44 in v32 do
		if v44.__deletingItemsConn then
			continue
		end

		local clone = nil
		local v45 = v44
		local v46 = k

		local function update()
			if v45:Get() > 0 then
				if not clone then
					clone = scrollingFrame.UIListLayout.Template:Clone()
					clone.Button.Item.Vector.Image = v46.ItemInfo.Icon or ""
					clone.Button.Label.Text = v46.ItemInfo.DisplayName
					clone.Parent = scrollingFrame
					clone.Button.Activated:Connect(function()
						v45:Set(v45:Get() - 1)
						self:UpdateItem(v46)
					end)
				end

				clone.Visible = true
				clone.Button.Item.Label.Text = `x{v45:Get()}`
			elseif clone then
				clone.Visible = false
			end
		end

		v44.__deletingItemsConn = v44:Connect(update)
		update()
	end
end

function Console:GetDeletingItemState(p)
	local v44 = v32[p]

	if not v44 then
		v44 = v9.State(0)
		v32[p] = v44
	end

	self:UpdateDeletingItems()
	return v44
end

-- equivalent calls inferred from this helper; original call sites unknown
local function useOwnedCopies(callback, p)
	return callback(p.OwnedCopies) - (callback(state) and callback(Console:GetDeletingItemState(p)) or 0)
end

local function GET_FN(object)
	return object:Get()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOwnedCopies(p)
	return p.OwnedCopies:Get() - (state:Get() and Console:GetDeletingItemState(p):Get() or 0)
end

function Console:EquipCurrent()
	local v44 = state2:Get()

	for _, v45 in Console.PageInfo do
		if v45.PageName ~= v44 then
			continue
		end

		local v46 = v45.ItemState:Get()

		if not v46 then
			continue
		end

		local itemInfo = v46.ItemInfo
		local itemType = itemInfo.ItemType

		if itemInfo.ItemType == "Ability" then
			if v46.OwnedCopies:Get() > 0 then
				local name = itemInfo.Name
				v20:SetEquipped(itemType, client:FindItemsWithKey(itemType, v46.ParsedItemKey)[1] or name)
			elseif itemInfo.Pack then
				v10:Open(itemInfo.Pack.Menu)
			else
				v20:RequestAbilityPurchase(v46.ItemInfo.Name)
			end
		elseif v46.ItemInfo.IsInventorey then
			local name = itemInfo.Name
			v20:SetEquipped(itemType, client:FindItemsWithKey(itemType, v46.ParsedItemKey)[1] or name)
		elseif itemInfo.ItemType == "DevProduct" then
			v16:PromptPurchase(itemInfo.ProductId, Enum.InfoType.Product)
		elseif itemInfo.ItemType == "GamePass" then
			if v46.Owns:Get() then
				break
			else
				v16:PromptPurchase(itemInfo.ProductId, Enum.InfoType.GamePass)
			end
		end
	end
end

function Console:UpgradeCurrent()
	local v44 = state2:Get()

	for _, v45 in Console.PageInfo do
		if v45.PageName ~= v44 then
			continue
		end

		local v46 = v45.ItemState:Get()

		if not v46 then
			continue
		end

		local itemInfo = v46.ItemInfo

		if itemInfo.ItemType == "Ability" then
			if v46.OwnedCopies:Get() <= 0 then
				break
			end

			if itemInfo.Upgrade.CustomUpgrade then
				v10:Open(itemInfo.Upgrade.CustomUpgrade)
			elseif v20:RequestAbilityUpgrade(client:FindItemsWithKey(itemInfo.ItemType, v46.ParsedItemKey)[1]) then
				local keyToItem = client:KeyToItem(v46.ParsedItemKey)
				keyToItem.Upgrade = (keyToItem.Upgrade or 0) + 1
				v28.Ability:Set(v20:GetAbilityData(v20:ParseItemKey("Ability", keyToItem)))
			end
		elseif itemInfo.ItemType == "DevProduct" then
			v24:SetGift(itemInfo.DisplayName)
		elseif itemInfo.ItemType == "GamePass" then
			v24:SetGift(itemInfo.GiftName)
		end
	end
end

function Console:SelectedAbilityHandler(_)
	local ability = main.Pages:WaitForChild("Ability")
	local right = ability:WaitForChild("Right")
	local equipButton = right:WaitForChild("EquipButton")
	local upgradeButton = right:WaitForChild("UpgradeButton")
	local upgrades = right:WaitForChild("Upgrades")
	local arrowButton = right:WaitForChild("ArrowButton")
	local favorite = right:WaitForChild("Favorite")
	local upgradesInfo = right:WaitForChild("UpgradesInfo")
	local purchaseButton = right:WaitForChild("PurchaseButton")
	local killsProgressBar = right:WaitForChild("KillsProgressBar")
	right:WaitForChild("ArrowButton").Activated:Connect(function()
		upgradesInfo.Visible = not upgradesInfo.Visible
	end)
	local v44 = nil
	v9.Computed(function(callback)
		local v45 = callback(v28.Ability)

		if v45 then
			local itemInfo = v45.ItemInfo

			if callback(v45.OwnedCopies) > 0 then
				favorite.Visible = true
				equipButton.Visible = true
				local visible = (not itemInfo.Upgrade.NonUpgradable or itemInfo.Upgrade.CustomUpgrade) and true or false
				upgrades.Visible = visible
				arrowButton.Visible = visible
				upgradeButton.Visible = visible
				equipButton.Equip.Text = callback(v45.IsEquipped) and "Equipped" or "Equip"
				purchaseButton.Visible = false
			else
				favorite.Visible = false

				if itemInfo.Price then
					purchaseButton.Visible = true
					purchaseButton.Label.Text = `Purchase for {itemInfo.Price} Coins`
				elseif itemInfo.Attributes.Pack then
					purchaseButton.Visible = true
					purchaseButton.Label.Text = itemInfo.Attributes.Pack
				else
					purchaseButton.Visible = false
				end

				upgrades.Visible = false
				arrowButton.Visible = false
				upgradeButton.Visible = false
				equipButton.Visible = false
			end

			local upgrade = client:KeyToItem(v45.ParsedItemKey).Upgrade or 0
			local count = 0

			for i = 1, 3 do
				local child = upgradesInfo:FindFirstChild((`Description{i}`))

				if not child then
					continue
				end

				local text = itemInfo.Upgrade.UpgradeInfo[i]

				if text then
					child.UpgradeDesc.Text = text
					child.OwnedLabel.Visible = i <= upgrade
					child.Visible = i <= itemInfo.Upgrade.MaxUpgrade
					count += 1
				else
					child.Visible = false
				end
			end

			for i = 1, 3 do
				local child = upgradesInfo:FindFirstChild((`Description{i}`))

				if not child then
					continue
				end

				local size

				if count == 3 then
					size = UDim2.fromScale(0.832, 0.28)
				else
					size = UDim2.fromScale(0.832, 0.44)
				end

				child.Size = size

				if i == 1 then
					local position

					if count == 3 then
						position = UDim2.fromScale(0.122, 0.05)
					else
						position = UDim2.fromScale(0.122, 0.035)
					end

					child.Position = position
				elseif i == 2 then
					local position

					if count == 3 then
						position = UDim2.fromScale(0.1, 0.35)
					else
						position = UDim2.fromScale(0.07, 0.51)
					end

					child.Position = position
				end
			end
		else
			upgradesInfo.Visible = false
		end

		if v44 and v44 ~= v45 then
			upgradesInfo.Visible = false
		end

		v44 = v45
		return nil
	end)
	local v45 = v3.new()
	v9.Computed(function(callback)
		v45:Destroy()
		killsProgressBar.Visible = false
		local v46 = callback(v28.Ability)

		if not v46 then
			return nil
		end

		local itemInfo = v46.ItemInfo
		local upgrade = client:KeyToItem(v46.ParsedItemKey).Upgrade or 0
		local maxUpgrade = itemInfo.Upgrade.MaxUpgrade

		if upgrade == maxUpgrade then
			upgradeButton.MidUpgrade.Text = "Max"
			upgradeButton.ImageLabel.Visible = false
			upgradeButton.Upgrade.Visible = false
			upgradeButton.UpgradeCost.Visible = false
			upgradeButton.MidUpgrade.Visible = true
		else
			local abilityUpgradePrice = v20:GetAbilityUpgradePrice(v46)
			local visible = abilityUpgradePrice and abilityUpgradePrice > 0
			upgradeButton.ImageLabel.Visible = visible
			upgradeButton.Upgrade.Visible = visible
			upgradeButton.UpgradeCost.Visible = visible
			upgradeButton.MidUpgrade.Visible = false

			if visible then
				upgradeButton.UpgradeCost.Text = abilityUpgradePrice
			elseif itemInfo.Upgrade.CustomUpgrade then
				upgradeButton.MidUpgrade.Visible = true
				upgradeButton.MidUpgrade.Text = "Upgrade"
			end

			local killRequirement = itemInfo.Upgrade.KillRequirements[upgrade + 1]

			if killRequirement then
				killsProgressBar.Visible = true
				local v48

				if itemInfo.Attributes.UseLegacyUpgradeProgression then
					v48 = math.clamp(
						(callback((v9.getReplionPathState(self.DataReplion, "TotalStats.Kills"))) or 0) - (callback((v9.getReplionPathState(
							self.DataReplion,
							(`AbilityUpgradeProgression.{itemInfo.Name}`)
						))) or 0),
						0,
						killRequirement
					)
				else
					v48 = math.clamp(
						callback((v9.getReplionPathState(
							self.DataReplion,
							(`NewAbilityUpgradeProgression.{itemInfo.Name}`)
						))) or 0,
						0,
						killRequirement
					)
				end

				killsProgressBar.Progress.Text = `{v48}/{killRequirement} Elims`
				killsProgressBar.Fill.Size = UDim2.fromScale(v48 / killRequirement, 0.9)
			end
		end

		for i = 1, maxUpgrade do
			local clone = v45:Clone(controllerShop.Templates.AbilityUpgradeTemplate)
			clone.Visible = true
			clone.LayoutOrder = i

			if i <= upgrade then
				clone.Image = "rbxassetid://15645666568"
			end

			clone.Parent = upgrades
		end

		return nil
	end)
	v22.animateButtonClick(upgradeButton)
	v22.animateButtonClick(equipButton)
	v22.animateButtonClick(favorite)
	favorite.Activated:Connect(function()
		local v46 = v28.Ability:Get()

		if v46 then
			v20:ToggleFavorited(v46)
		end
	end)
	v9.Computed(function(callback)
		local v46 = callback(v28.Ability)

		if v46 then
			favorite.Image = callback(v46.IsFavorited) and "rbxassetid://15697987058" or "rbxassetid://15697983062"
		end

		return nil
	end)
	local randomizerView = ability.RandomizerView
	local shuffle = ability.FrameUI.Scrolling:WaitForChild("!!!Shuffle")

	local function updateShuffle()
		local v46 = {}

		for _, v47 in pairs(client:Get("Ability") or {}) do
			if not v46[v47.Name] then
				v46[v47.Name] = true
			end
		end

		shuffle.Visible = not v11.isHuntPrivateServer() and v4.Dictionary.count(v46) >= 15
	end

	client:OnInventoryChange("Ability", updateShuffle)
	updateShuffle()
	shuffle.Activated:Connect(function()
		state:Set(false)
		randomizerView.Visible = true
		v34:SetTag("Shuffle", true)
		remoteEvent:FireServer("Abilities", true, false)
	end)
	randomizerView.UseFavoritesLabel.Activated:Connect(function()
		remoteEvent:FireServer(
			"Abilities",
			true,
			not self.DataReplion:GetExpect("Settings.Misc.AbilitiesRandomizer.UseFavorites")
		)
	end)
	v9.Computed(function(callback)
		local v46 = callback((v9.getReplionPathState(self.DataReplion, "Settings.Misc.AbilitiesRandomizer")))
		local current = v46.Current
		local useFavorites = v46.UseFavorites
		shuffle.Checkmark.Visible = current
		randomizerView.UseFavoritesLabel.Star.Image = useFavorites and v36[true].Image or v36[true].HoverImage
		randomizerView.UseFavoritesLabel.TextColor3 = useFavorites and color or Color3.fromRGB(255, 255, 255)
		randomizerView.UseFavoritesLabel.Text = useFavorites and "          Favorites Only: On" or "          Favorites Only: Off"
		return nil
	end)
end

function Console:SelectedSwordHandler(instance)
	local sword = main.Pages:WaitForChild("Sword")
	local right = sword:WaitForChild("Right")
	local buttons = right:WaitForChild("Buttons")
	local subButtons = buttons:WaitForChild("SubButtons")
	local purchaseButton = right:WaitForChild("PurchaseButton")
	local upgradeButton = right:WaitForChild("UpgradeButton")
	upgradeButton.Activated:Connect(function()
		v10:Open("SecretUpgrade")
	end)
	local randomizerView = sword.RandomizerView
	local shuffle = sword.FrameUI.Scrolling:WaitForChild("!!!Shuffle")

	local function updateShuffle()
		local v44 = {}

		for _, v45 in pairs(client:Get("Sword") or {}) do
			if not v44[v45.Name] then
				v44[v45.Name] = true
			end
		end

		shuffle.Visible = v4.Dictionary.count(v44) >= 15
	end

	client:OnInventoryChange("Sword", updateShuffle)
	updateShuffle()
	shuffle.Activated:Connect(function()
		state:Set(false)
		randomizerView.Visible = true
		v34:SetTag("Shuffle", true)
		remoteEvent:FireServer("SwordSkins", true, false)
	end)
	randomizerView.UseFavoritesLabel.Activated:Connect(function()
		remoteEvent:FireServer(
			"SwordSkins",
			true,
			not self.DataReplion:GetExpect("Settings.Misc.SwordSkinsRandomizer.UseFavorites")
		)
	end)
	v9.Computed(function(callback)
		local v44 = callback((v9.getReplionPathState(self.DataReplion, "Settings.Misc.SwordSkinsRandomizer")))
		local current = v44.Current
		local useFavorites = v44.UseFavorites
		shuffle.Checkmark.Visible = current
		randomizerView.UseFavoritesLabel.Star.Image = useFavorites and v36[true].Image or v36[true].HoverImage
		randomizerView.UseFavoritesLabel.TextColor3 = useFavorites and color or Color3.fromRGB(255, 255, 255)
		randomizerView.UseFavoritesLabel.Text = useFavorites and "          Favorites Only: On" or "          Favorites Only: Off"
		return nil
	end)
	local secretUpgrade = playerGui:WaitForChild("SecretUpgrade")
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if not v44 then
			return nil
		end

		if callback(v44.OwnedCopies) > 0 then
			right.Favorite.Visible = true
			purchaseButton.Visible = true
			purchaseButton.Equip.Text = callback(v44.IsEquipped) and "Equipped" or "Equip"
			upgradeButton.Visible = v44.ItemInfo.Attributes.CanAwaken

			if v44.ItemInfo.Attributes.CanAwaken then
				secretUpgrade:SetAttribute("ToAwaken", client:FindItemsWithKey("Sword", v44.ParsedItemKey)[1])
			else
				secretUpgrade:SetAttribute("ToAwaken", nil)
			end
		else
			right.Favorite.Visible = false
			purchaseButton.Visible = false
			upgradeButton.Visible = false
		end

		return nil
	end)
	local accessoryButton = buttons:WaitForChild("AccessoryButton")
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if v44 then
			if not v44.ItemInfo.AccessoryToggleable then
				accessoryButton.Visible = false
				return nil
			end

			if not callback(v44.HasAccessory) then
				accessoryButton.Visible = false
				return nil
			end

			if callback(v44.OwnedCopies) > 0 and callback(v44.IsEquipped) then
				local v45 = callback((v9.getAttributeState(localPlayer, "ShowSwordAccessory")))
				accessoryButton.Label.Text = v44.ItemInfo.Name == "Cherub" and "Switch" or v45 and "Unequip Accessory" or "Equip Accessory"
				local uIStroke = accessoryButton.Label.UIStroke
				local color2

				if v45 then
					color2 = Color3.fromRGB(65, 18, 18)
				else
					color2 = Color3.fromRGB(81, 56, 43)
				end

				uIStroke.Color = color2
				accessoryButton.Image = v45 and "rbxassetid://15452502387" or "rbxassetid://15452544682"
				accessoryButton.HoverImage = "rbxassetid://14783051124"
				accessoryButton.Visible = true
			else
				accessoryButton.Visible = false
			end
		else
			accessoryButton.Visible = false
		end

		return nil
	end)
	accessoryButton.Activated:Connect(function()
		v20:ToggleSwordAccessory()
	end)
	local styleButton = subButtons:WaitForChild("StyleButton")
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if v44 then
			local v45 = callback((v9.getAttributeState(localPlayer, "ShowSwordAccessory")))
			local animationStyle = v44.ItemInfo.AnimationStyles[v45 and "Accessory" or "Base"]

			if not animationStyle or #animationStyle <= 1 then
				styleButton.Visible = false
				return nil
			end

			local v46 = callback((v9.getAttributeState(localPlayer, "AnimationStyle"))) or "Default"
			local index = table.find(animationStyle, v46)
			local v47 = select(2, next(animationStyle, index)) or animationStyle[1]

			if callback(v44.OwnedCopies) > 0 and callback(v44.IsEquipped) and v47 then
				local v48 = (index or 1) % 2 == 0
				styleButton.Label.Text = `EQUIP {string.upper(v47)} STYLE`
				local uIStroke = styleButton.Label.UIStroke
				local color2

				if v48 then
					color2 = Color3.fromRGB(65, 18, 18)
				else
					color2 = Color3.fromRGB(81, 56, 43)
				end

				uIStroke.Color = color2
				styleButton.Image = v48 and "rbxassetid://15452502387" or "rbxassetid://15452544682"
				styleButton.HoverImage = "rbxassetid://14783051124"
				styleButton.Visible = true
			else
				styleButton.Visible = false
			end
		else
			styleButton.Visible = false
		end

		return nil
	end)
	styleButton.Activated:Connect(function()
		v20:ToggleSwordStyle()
	end)
	local finisherButton = subButtons:WaitForChild("FinisherButton")
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if v44 then
			if not v44.ItemInfo.HasFinisher then
				finisherButton.Visible = false
				return nil
			end

			if callback(v44.OwnedCopies) > 0 then
				if client:KeyToItem(v44.ParsedItemKey).Finisher then
					local v45 = callback(v44.IsFinisherEquipped)
					finisherButton.Label.Text = v45 and "Unequip Finisher" or "Equip Finisher"
					local uIStroke = finisherButton.Label.UIStroke
					local color2

					if v45 then
						color2 = Color3.fromRGB(65, 18, 18)
					else
						color2 = Color3.fromRGB(81, 56, 43)
					end

					uIStroke.Color = color2
					finisherButton.Image = v45 and "rbxassetid://15452502387" or "rbxassetid://15452544682"
					finisherButton.HoverImage = "rbxassetid://14783051124"
				else
					local obtainFinisher = v44.ItemInfo.Attributes.ObtainFinisher

					if obtainFinisher then
						finisherButton.Label.Text = obtainFinisher
						finisherButton.Label.UIStroke.Color = Color3.fromRGB(29, 90, 0)
						finisherButton.Image = "rbxassetid://15790014217"
						finisherButton.HoverImage = "rbxassetid://15790016390"
					else
						finisherButton.Label.Text = "Unobtainable"
						finisherButton.Label.UIStroke.Color = Color3.fromRGB(53, 53, 53)
						finisherButton.Image = "rbxassetid://14783051124"
						finisherButton.HoverImage = "rbxassetid://14783051124"
					end
				end

				finisherButton.Visible = true
			else
				finisherButton.Visible = false
			end
		else
			finisherButton.Visible = false
		end

		return nil
	end)
	finisherButton.Activated:Connect(function()
		local v44 = v28.Sword:Get()

		if v44 then
			if client:KeyToItem(v44.ParsedItemKey).Finisher then
				v20:RequestFinisherEquip(v44.ItemInfo)
			elseif v44.ItemInfo.Attributes.FinisherUI then
				v10:Open(v44.ItemInfo.Attributes.FinisherUI)
			end
		end
	end)
	v22.animateButtonClick(right.PurchaseButton)
	v22.animateButtonClick(right.Favorite)
	right.Favorite.Activated:Connect(function()
		local v44 = v28.Sword:Get()

		if v44 then
			v20:ToggleFavorited(v44)
		end
	end)
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if v44 then
			right.Favorite.Image = callback(v44.IsFavorited) and "rbxassetid://15697987058" or "rbxassetid://15697983062"
		end

		return nil
	end)
	local itemViewport = right:WaitForChild("ItemViewport")
	v9.Computed(function(callback)
		instance:Destroy()
		local v44 = callback(v28.Sword)

		if v44 and not v44.ItemInfo.Icon then
			local v45 = v2:SetSwordIconAsViewportByName(itemViewport, v44.ItemInfo.Name)
			right.ItemIcon.Visible = false
			right.ItemViewport.Visible = true

			if v45 then
				instance:Add(v45)
			end
		end

		return nil
	end)
end

function Console:SelectedExplosion(_)
	local explosion = main.Pages:WaitForChild("Explosion")
	local right = explosion:WaitForChild("Right")
	right:WaitForChild("ItemTitle")
	v9.Computed(function(callback)
		local v44 = callback(v28.Explosion)

		if not v44 then
			return nil
		end

		if callback(v44.OwnedCopies) > 0 then
			right.Favorite.Visible = true
			right.Btn.Visible = true
			right.Btn.Equip.Text = callback(v44.IsEquipped) and "Equipped" or "Equip"
		else
			right.Favorite.Visible = false
			right.Btn.Visible = false
		end

		return nil
	end)
	v22.animateButtonClick(right.Favorite)
	right.Favorite.Activated:Connect(function()
		local v44 = v28.Explosion:Get()

		if v44 then
			v20:ToggleFavorited(v44)
		end
	end)
	v9.Computed(function(callback)
		local v44 = callback(v28.Sword)

		if v44 then
			right.Favorite.Image = callback(v44.IsFavorited) and "rbxassetid://15697987058" or "rbxassetid://15697983062"
		end

		return nil
	end)
	local randomizerView = explosion.RandomizerView
	local shuffle = explosion.FrameUI.Scrolling:WaitForChild("!!!Shuffle")

	local function updateShuffle()
		local v44 = {}

		for _, v45 in pairs(client:Get("Explosion") or {}) do
			if not v44[v45.Name] then
				v44[v45.Name] = true
			end
		end

		shuffle.Visible = v4.Dictionary.count(v44) >= 15
	end

	client:OnInventoryChange("Explosion", updateShuffle)
	updateShuffle()
	shuffle.Activated:Connect(function()
		state:Set(false)
		randomizerView.Visible = true
		v34:SetTag("Shuffle", true)
		remoteEvent:FireServer("ExplosionSkins", true, false)
	end)
	randomizerView.UseFavoritesLabel.Activated:Connect(function()
		remoteEvent:FireServer(
			"ExplosionSkins",
			true,
			not self.DataReplion:GetExpect("Settings.Misc.ExplosionSkinsRandomizer.UseFavorites")
		)
	end)
	v9.Computed(function(callback)
		local v44 = callback((v9.getReplionPathState(self.DataReplion, "Settings.Misc.ExplosionSkinsRandomizer")))
		local current = v44.Current
		local useFavorites = v44.UseFavorites
		shuffle.Checkmark.Visible = current
		randomizerView.UseFavoritesLabel.Star.Image = useFavorites and v36[true].Image or v36[true].HoverImage
		randomizerView.UseFavoritesLabel.TextColor3 = useFavorites and color or Color3.fromRGB(255, 255, 255)
		randomizerView.UseFavoritesLabel.Text = useFavorites and "          Favorites Only: On" or "          Favorites Only: Off"
		return nil
	end)
end

function Console:SelectedRobux(_)
	local right = main.Pages:WaitForChild("Robux"):WaitForChild("Right")
	local itemTitle = right:WaitForChild("ItemTitle")
	v9.Computed(function(callback)
		local v44 = callback(v28.Robux)

		if not v44 then
			return nil
		end

		if v44.ItemInfo.ItemType == "DevProduct" then
			right.Visible = true
			itemTitle.Text = v12:AddCommas(v44.ItemInfo.CoinReward)
			right.Btn.Equip.Text = "Purchase"
		elseif v44.ItemInfo.ItemType == "GamePass" then
			right.Visible = true
			right.Btn.Equip.Text = callback(v44.Owns) and "Purchased" or "Purchase"
		end

		return nil
	end)
end

function Console:GeneralHandler(_, _: string, p, instance)
	local itemTitle = instance:WaitForChild("ItemTitle")
	local desc = instance:WaitForChild("Desc")
	local itemInfo = p.ItemInfo

	if itemInfo.Icon then
		local altIcon = itemInfo.Attributes and itemInfo.Attributes.AltIcon or p.ItemInfo.Icon
		local itemIcon = instance:WaitForChild("ItemIcon")
		itemIcon.Visible = true
		itemIcon.Image = altIcon
	end

	if itemInfo.Description then
		desc.Text = itemInfo.Description
	end

	itemTitle.Text = itemInfo.DisplayName or itemInfo.Name
end

function Console:SetupPageRight()
	local v44 = v3.new()
	local v45 = v3.new()

	for _, v46 in Console.PageInfo do
		local pageName = v46.PageName
		local right = main.Pages:WaitForChild(pageName):WaitForChild("Right")
		local itemState = v46.ItemState
		v9.Computed(function(callback)
			local v50 = callback(itemState)

			if not v50 then
				return nil
			end

			local itemInfo = v50.ItemInfo
			local v51 = table.find(v40, itemInfo.ItemType) ~= nil
			local rap = v51 and right:FindFirstChild("Rap")

			if rap then
				rap.Coins.Amount.Text = "---"
				local visible = v51 and v25:IsEnabled() and v25:ShouldShowRAP(itemInfo.ItemType, itemInfo.Name)
				rap.Visible = visible

				if visible then
					rap.Coins.Amount.Text = v8.ValueConvertor:AddCommas(callback(v50.RAP))
				end
			end

			local existCount = right:FindFirstChild("ExistCount")

			if existCount then
				local v52 = v27:Get(itemInfo.ItemType, v50.ParsedItemKey)

				if v52 then
					existCount.Label.Text = `{v8.ValueConvertor:ShrinkNumber(v52)} Exist{v52 == 1 and "s" or ""}`
				end

				existCount.Visible = v52 ~= nil
			end

			self:GeneralHandler(callback, pageName, v50, right)
			return nil
		end)
	end

	self:SelectedAbilityHandler(v45)
	self:SelectedExplosion(v44)
	self:SelectedSwordHandler(v44)
	self:SelectedRobux(v44)
end

local v44 = {
	Sword = {},
	Explosion = {},
	Ability = {},
	DevProduct = {},
	GamePass = {}
}

function Console:RenderSword(data, maid)
	local itemInfo = data.ItemInfo
	local keyToItem = client:KeyToItem(data.ParsedItemKey)
	local clone = controllerShop.Templates.SwordTemplate:Clone()
	clone.Visible = true
	v44.Sword[data.ParsedItemKey] = clone

	if itemInfo.Icon then
		clone.ViewportFrame.Visible = false
		clone.ItemIcon.Visible = true
		clone.ItemIcon.Image = itemInfo.Icon
	else
		clone.ViewportFrame.Visible = true
		clone.ItemIcon.Visible = false
		v2:SetSwordIconAsViewportByName(clone.ViewportFrame, itemInfo.Name)
	end

	clone.ItemName.Text = itemInfo.DisplayName
	clone.ImageColor3 = v35[itemInfo.Rarity] or v35.Normal
	local child = keyToItem.Finisher and ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(itemInfo.Name)

	if child then
		local clone2 = script.NewInventory.Finisher:Clone()
		clone2.Icon.Image = child:GetAttribute("Icon") or v8.Icons:GetIcon("DEFAULT_MISSING")
		clone2.Parent = clone
	end

	if keyToItem.Accessory ~= nil then
		local clone_2 = script.NewInventory.SwordAccessory:Clone()
		clone_2.Parent = clone
	end

	maid:Add(v9.setPropertyComputed(clone.Checkmark, "Visible", function(callback)
		return callback(data.IsEquipped) and not callback((v9.getReplionPathState(
			self.DataReplion,
			"Settings.Misc.SwordSkinsRandomizer.Current"
		)))
	end))
	local state6 = v9.State(-1)

	local function updateExistCounter()
		state6:Set(v27:IsEnabled() and v27:Get("Sword", data.ParsedItemKey, true) or -1)
	end

	maid:Add(task.spawn(function()
		v5.Client:WaitReplion("ClientExistCount")
		maid:Add(v27:OnUpdated("Sword", data.ParsedItemKey, updateExistCounter))
	end))
	state6:Set(not v27:IsEnabled() and -1 or v27:Get("Sword", data.ParsedItemKey, true) or -1)
	local displayName = itemInfo.DisplayName:lower()
	local v45 = string.gsub(displayName, ".", function(value)
		return (string.char(255 - string.byte(value)))
	end)
	local layoutOrder = v20.RarityOrder[itemInfo.Rarity] or 0
	clone.Name = `{layoutOrder}{displayName}`
	clone.LayoutOrder = layoutOrder
	clone:SetAttribute("OriginalLayoutOrder", clone.LayoutOrder)
	local attributeState, v47 = v9.getAttributeState(clone, "OriginalLayoutOrder")
	maid:Add(v47)
	local sword = v30.Sword
	local sword2 = v31.Sword
	maid:Add(v9.setPropertyComputed(clone, "Name", function(callback)
		local v48 = not sword and "Default" or callback(sword)
		local ascending

		if sword2 then
			ascending = callback(sword2)
		else
			ascending = Enum.SortDirection.Ascending
		end

		local v50

		if v39[ascending] == 1 then
			v50 = displayName
		else
			v50 = v45
		end

		local v51 = v48 ~= "Default" and "" or layoutOrder
		return (`{callback(data.IsFavorited) and "#" or ""}{v51}|{v50}`)
	end))
	maid:Add(v9.setPropertyComputed(clone, "LayoutOrder", function(callback)
		local v48 = not sword and "Default" or callback(sword)
		local v50

		if sword2 then
			v50 = callback(sword2)
		else
			v50 = Enum.SortDirection.Ascending
		end

		local v51 = v39[v50]

		if v48 == "RAP" then
			return (callback(data.RAP) or 0) * v51
		elseif v48 == "Exists" then
			return (callback(state6) or 0) * v51
		elseif v48 == "Creation Date" then
			return ((data.ItemInfo.CreatedAt or 0) - 888347471) * v51
		end

		return callback(attributeState) or 0
	end))
	local favorite = clone:WaitForChild("Favorite")
	favorite.Visible = false
	maid:Add(v9.Computed(function(callback)
		favorite.Visible = callback(data.IsFavorited)
		return nil
	end))
	maid:Add(v9.setPropertyComputed(clone, "Visible", function(callback)
		local v48 = not itemInfo.Hidden
		return v48 or useOwnedCopies(callback, data) > 0 or itemInfo.AlwaysVisible
	end))
	maid:Add(v9.Computed(function(callback)
		local v49 = useOwnedCopies(callback, data) -- equivalent call inferred; original call site unknown
		local stack = clone:FindFirstChild("Stack")

		if stack then
			stack.Visible = v49 > 1

			if v49 > 1 and stack then
				stack.Label.Text = `x{v8.ValueConvertor:AddCommas(v49)}`
			end
		end

		return nil
	end))
	clone.Parent = main.Pages.Sword.FrameUI.Scrolling
	return clone
end

function Console:RenderExplosion(data, maid)
	local itemInfo = data.ItemInfo
	client:KeyToItem(data.ParsedItemKey)
	local clone = controllerShop.Templates.ExplosionTemplate:Clone()
	clone.Visible = true
	v44.Explosion[data.ParsedItemKey] = clone
	clone.ItemTitle.Text = itemInfo.Title.Text
	clone.ItemTitle.TextStrokeColor3 = itemInfo.Title.StrokeColor
	applyColor(clone.ItemTitle, itemInfo.Title.Color)
	clone.ItemTitle.UIStroke.Color = itemInfo.Title.StrokeColor
	clone.ItemIcon.Image = v2:GetExplosionIcon(data.ItemInfo.Name)
	clone.ImageColor3 = v35[itemInfo.Rarity] or v35.Normal
	maid:Add(v9.setPropertyComputed(clone.Checkmark, "Visible", function(callback)
		return callback(data.IsEquipped) and not callback((v9.getReplionPathState(
			self.DataReplion,
			"Settings.Misc.ExplosionSkinsRandomizer.Current"
		)))
	end))
	local text = itemInfo.Title.Text:lower()
	local v45 = string.gsub(text, ".", function(value)
		return (string.char(255 - string.byte(value)))
	end)
	local layoutOrder = v20.RarityOrder[itemInfo.Rarity] or 0
	clone.Name = `{layoutOrder}{text}`
	clone.LayoutOrder = layoutOrder
	clone:SetAttribute("OriginalLayoutOrder", clone.LayoutOrder)
	local attributeState, v47 = v9.getAttributeState(clone, "OriginalLayoutOrder")
	maid:Add(v47)
	local explosion = v30.Explosion
	local explosion2 = v31.Explosion
	maid:Add(v9.setPropertyComputed(clone, "Name", function(callback)
		local v48 = not explosion and "Default" or callback(explosion)
		local ascending

		if explosion2 then
			ascending = callback(explosion2)
		else
			ascending = Enum.SortDirection.Ascending
		end

		local v50

		if v39[ascending] == 1 then
			v50 = text
		else
			v50 = v45
		end

		local v51 = v48 ~= "Default" and "" or layoutOrder
		return (`{callback(data.IsFavorited) and "#" or ""}{v51}|{v50}`)
	end))
	maid:Add(v9.setPropertyComputed(clone, "LayoutOrder", function(callback)
		local v48 = not explosion and "Default" or callback(explosion)
		local v50

		if explosion2 then
			v50 = callback(explosion2)
		else
			v50 = Enum.SortDirection.Ascending
		end

		local v51 = v39[v50]

		if v48 == "RAP" then
			return (callback(data.RAP) or 0) * v51
		elseif v48 == "Creation Date" then
			return ((itemInfo.CreatedAt or 0) - 888347471) * v51
		end

		return callback(attributeState) or 0
	end))
	local favorite = clone:WaitForChild("Favorite")
	favorite.Visible = false
	maid:Add(v9.Computed(function(callback)
		favorite.Visible = callback(data.IsFavorited)
		return nil
	end))
	clone.Parent = main.Pages.Explosion.FrameUI.Scrolling
	return clone
end

function Console:RenderAbility(data, maid)
	local itemInfo = data.ItemInfo
	local keyToItem = client:KeyToItem(data.ParsedItemKey)
	local clone = controllerShop.Templates.AbilityTemplate:Clone()
	clone.Visible = true
	v44.Ability[data.ParsedItemKey] = clone
	clone.ItemName.Text = itemInfo.Title.Text
	clone.ItemName.TextStrokeColor3 = itemInfo.Title.StrokeColor
	applyColor(clone.ItemName, itemInfo.Title.Color)
	clone.ItemIcon.Image = v2:GetAbilityIcon(itemInfo.Name)
	maid:Add(v9.setPropertyComputed(clone.Checkmark, "Visible", function(callback)
		return callback(data.IsEquipped) and not callback((v9.getReplionPathState(
			self.DataReplion,
			"Settings.Misc.AbilitiesRandomizer.Current"
		)))
	end))
	local upgrade = keyToItem.Upgrade or 0
	clone.ItemLevel.Text = string.format(
		"Lv. %s",
		(tostring(itemInfo.Upgrade.MaxUpgrade <= upgrade and "Max" or upgrade))
	)
	clone.ItemLevel.Visible = upgrade >= 1
	local order = data.ItemInfo.Order
	maid:Add(v9.Computed(function(callback)
		clone.LayoutOrder = (callback(data.IsFavorited) and -1000 or 0) + order
		return nil
	end))
	local favorite = clone:WaitForChild("Favorite")
	favorite.Visible = false
	maid:Add(v9.Computed(function(callback)
		favorite.Visible = callback(data.IsFavorited)
		return nil
	end))
	v9.Computed(function(callback)
		local active = callback(itemInfo.IsAllowed)
		clone.Red.Visible = not active
		clone.Active = active
		return nil
	end)
	clone.Parent = main.Pages.Ability.FrameUI.Scrolling
	return clone
end

function Console:RenderDevProduct(p, _)
	local itemInfo = p.ItemInfo
	client:KeyToItem(p.ParsedItemKey)
	local clone = controllerShop.Templates.DevProductTemplate:Clone()
	clone.Visible = true
	v44.DevProduct[p.ParsedItemKey] = clone
	clone.Title.Text = itemInfo.TitleText
	clone.CoinAmount.Text = string.format("%d Coins", itemInfo.CoinReward)

	if itemInfo.TitleText == "Medium" or itemInfo.TitleText == "Big" then
		clone.HoverImage = "rbxassetid://15645383004"
		clone.Image = "rbxassetid://15645383170"
	elseif itemInfo.TitleText == "Massive" or itemInfo.TitleText == "Huge" then
		clone.HoverImage = "rbxassetid://15645401974"
		clone.Image = "rbxassetid://15645402097"
	end

	v14(clone.Cost, itemInfo.ProductId, "DevProduct", ":robux: %s")
	clone.Itemicon.Image = itemInfo.Icon or v2:GetIcon("DEFAULT_MISSING")
	clone.LayoutOrder = 100 + itemInfo.CoinReward
	clone.Parent = main.Pages.Robux.FrameUI.Scrolling.Items
	return clone
end

function Console:RenderGamePass(data, maid)
	client:KeyToItem(data.ParsedItemKey)
	local itemInfo = data.ItemInfo
	local clone = controllerShop.Templates.GamePassTemplate:Clone()
	clone.Visible = true
	v44.GamePass[data.ParsedItemKey] = clone
	clone.ItemTitle.Text = itemInfo.DisplayName
	clone.ItemIcon.Image = itemInfo.Icon
	maid:Add(v9.setPropertyComputed(clone.Checkmark, "Visible", function(callback)
		return callback(data.Owns)
	end))
	v14(clone.ItemPrice, itemInfo.ProductId, "GamePass", ":robux: %s")
	clone.LayoutOrder = 1
	clone.Parent = main.Pages.Robux.FrameUI.Scrolling.Items
	return clone
end

function Console:RenderSlot(data)
	local keyToItem = client:KeyToItem(data.ParsedItemKey)
	local itemInfo = data.ItemInfo
	local itemType = itemInfo.ItemType

	if not itemInfo then
		warn((`Player owns non-existent sword "{keyToItem.Name}"`))
		return
	end

	local v45 = (itemInfo.ItemType == "GamePass" or itemInfo.ItemType == "DevProduct") and "Robux" or itemInfo.ItemType
	local v46 = Console.PageInfo[v45]
	local v47 = v20:ParseItemKey(itemType, keyToItem) == v20:ParseItemKey(itemType, {
		Name = keyToItem.Name
	})

	if itemInfo.IsInventorey then
		local alwaysShow = itemInfo.AlwaysShow
		local v48 = data.OwnedCopies:Get() - (not state:Get() and 0 or Console:GetDeletingItemState(data):Get() or 0) > 0
		local v49 = v20.OwnedBases[itemType][keyToItem.Name].State:Get()

		if not v48 and (not alwaysShow or not v47 or v49) then
			return
		end
	end

	local maid = v3.new()
	local parent = nil

	if itemInfo.ItemType == "Sword" then
		parent = Console:RenderSword(data, maid)
	elseif itemInfo.ItemType == "Explosion" then
		parent = Console:RenderExplosion(data, maid)
	elseif itemInfo.ItemType == "Ability" then
		parent = Console:RenderAbility(data, maid)
	elseif itemInfo.ItemType == "DevProduct" then
		parent = Console:RenderDevProduct(data, maid)
	elseif itemInfo.ItemType == "GamePass" then
		parent = Console:RenderGamePass(data, maid)
	end

	if parent then
		parent:SetAttribute("ParsedItemKey", data.ParsedItemKey)
		maid:Add(parent)
		maid:Add(function()
			v44[itemType][data.ParsedItemKey] = nil
		end)
	end

	local v49

	if itemInfo.IsInventorey then
		local itemData = v20:GetItemData(itemType, data.ParsedItemKey)
		v49 = v9.Computed(function(callback)
			local v50 = itemData
			local alwaysShow

			if callback(v50.OwnedCopies) - (not callback(state) and 0 or callback(Console:GetDeletingItemState(v50)) or 0) > 0 then
				alwaysShow = true
				return true
			end

			if not v47 then
				alwaysShow = false
				return false
			end

			alwaysShow = itemInfo.AlwaysShow
			return alwaysShow and not callback(v20.OwnedBases[itemType][keyToItem.Name].State)
		end)
		v15:Add(parent, itemType, keyToItem, itemData.ParsedItemKey)
	else
		v49 = nil
	end

	local v50 = pagesSearchs[v45]
	local v51 = { itemInfo.DisplayName or itemInfo.Name }

	if itemInfo.ItemType == "Sword" then
		if keyToItem.Finisher then
			table.insert(v51, "Finisher")
		end
	elseif itemInfo.ItemType == "Ability" then
		table.insert(v51, (tostring(keyToItem.Upgrade or 0)))
	end

	local joined = table.concat(v51, "|"):lower()

	if itemInfo.IsInventorey then
		local itemData = v20:GetItemData(itemType, data.ParsedItemKey)
		local alwaysShow = itemInfo.AlwaysShow
		local state6 = v20.OwnedBases[itemType][keyToItem.Name].State

		if itemData.OwnedCopies:Get() - (not state:Get() and 0 or Console:GetDeletingItemState(itemData):Get() or 0) > 0 or alwaysShow and v47 and not state6:Get() then
			maid:Add(v9.Computed(function(callback)
				local v52 = itemData

				if not (callback(v52.OwnedCopies) - (not callback(state) and 0 or callback(Console:GetDeletingItemState(v52)) or 0) > 0) and (not alwaysShow or not v47 or callback(state6)) then
					task.defer(function()
						if not (getOwnedCopies(itemData) > 0) and (not alwaysShow or not v47 or state6:Get()) then
							maid:Destroy()
						end
					end)
				end

				return nil
			end))
		else
			maid:Destroy()
			return
		end
	end

	if not parent then
		return
	end

	if keyToItem.TradeLock and keyToItem.TradeLock.Value then
		local clone = script.NewInventory.Lock:Clone()
		clone.Parent = parent
		maid:Add(v9.Computed(function(callback)
			clone.Visible = callback((v9.getReplionPathState(self.DataReplion, "HasInteractedWithTrading")))
			return nil
		end))
	end

	local pageName = v46.PageName
	local child = main.Pages:FindFirstChild(pageName)
	parent.Activated:Connect(function()
		if state:Get() then
			local isDeleteable, v52 = v13.IsDeleteable(localPlayer, itemType, keyToItem)

			if isDeleteable then
				if data.OwnedCopies and data.OwnedCopies:Get() <= 0 then
					v18:SendNotification("You don't own this item!")
					return
				end

				local deletingItemState = self:GetDeletingItemState(data)
				deletingItemState:Set(deletingItemState:Get() + 1)
			elseif v52 then
				v18:SendNotification(v52)
			end
		else
			v46.ItemState:Set(data)

			if v43[pageName] and child then
				child.RandomizerView.Visible = false
				v34:SetTag("Shuffle", false)
				remoteEvent:FireServer(v43[pageName], false, false)
			end
		end
	end)
	maid:Add(v9.Computed(function(callback)
		if callback(state2) ~= v46.PageName then
			return nil
		end

		local v52 = callback(state3)
		local v54 = v41[(itemInfo.ItemType == "DevProduct" or itemInfo.ItemType == "GamePass") and "All" or v52]
		local visible = (not v49 or callback(v49)) and v54(data, callback)

		if v50 then
			local v56 = callback(v50)

			if v56 then
				visible = visible and (joined == v56 or joined:sub(1, #v56) == v56 or joined:find(v56, 1, true) ~= nil)
			end
		end

		parent.Visible = visible
		return nil
	end))
	v22.animateButtonClick(parent)
	v22.animateButtonHover(parent)
	return parent
end

function Console:UpdateItem(p)
	if not v44[p.ItemInfo.ItemType][p.ParsedItemKey] then
		self:RenderSlot(p)
	end
end

function Console.HandlePageChange(_, _: string) end

function Console.GetCurrentPage(_)
	return state2:Get()
end

function Console:Start()
	local dataReplion = v5.Client:WaitReplion("Data")
	self.DataReplion = dataReplion
	local top = main:WaitForChild("Top")
	local tabs = top:WaitForChild("Tabs")
	local coinValue = top:WaitForChild("CoinValue")
	local v46 = {
		"Ability",
		"Explosion",
		"Sword",
		"Robux"
	}
	local _ = { "All", "Owned", "Unowned" }
	local color2 = Color3.fromRGB(63, 63, 63)
	local color3 = Color3.fromRGB(26, 126, 21)
	main.ConsoleKeys.L1.Activated:Connect(function()
		local v47 = state2:Get()
		local v48 = (table.find(v46, v47) - 2) % #v46 + 1
		local v49 = v46[math.max(1, v48)]
		state2:Set(v49)
		local v50 = v38[v49] and v38[v49][1]

		if not v50 then
			return
		end

		state3:Set(v50)
	end)
	main.ConsoleKeys.R1.Activated:Connect(function()
		local v47 = state2:Get()
		local v48 = table.find(v46, v47) % #v46 + 1
		local v49 = v46[math.max(1, v48)]
		state2:Set(v49)
		local v50 = v38[v49] and v38[v49][1]

		if not v50 then
			return
		end

		state3:Set(v50)
	end)
	main.ConsoleKeys.Circle.Activated:Connect(function()
		v10:Close()
	end)

	for _, button in main.Top.Tabs:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v47 = button
		button.Activated:Connect(function()
			state2:Set(v47.Name)
		end)
	end

	local popUpTokensBuy = playerGui:WaitForChild("PopUpTokensBuy")

	for _, frame in main.Pages:GetChildren() do
		if not frame:IsA("Frame") then
			continue
		end

		local name = frame.Name
		local child = tabs:FindFirstChild(name)

		if not child then
			continue
		end

		v9.setPropertyState(frame.FrameUI, "Visible", computed)

		if frame:FindFirstChild("Top") then
			v9.setPropertyState(frame.Top, "Visible", computed)
		end

		v9.setPropertyState(frame.Right, "Visible", computed2)
		local name3 = name
		local v48 = child
		local v49 = frame
		v9.Computed(function(callback)
			local visible = callback(state2) == name3
			v48.Image = visible and "rbxassetid://15643806432" or "rbxassetid://15643737651"
			v48.Text.UIStroke.Color = visible and color3 or color2
			v49.Visible = visible
			v49.FrameUI.Scrolling.ScrollingEnabled = not callback((v9.getPropertyState(popUpTokensBuy, "Enabled")))
			return nil
		end)
		local searchFrame = frame:FindFirstChild("SearchFrame")

		if searchFrame then
			local v50 = searchFrame
			local name4 = name

			local function updateInput()
				local text = v50.Input.Box.Text

				if text and #text > 0 then
					self.PagesSearchs[name4]:Set(text:lower())
				else
					self.PagesSearchs[name4]:Set()
				end
			end

			searchFrame.Input.Box.Changed:Connect(updateInput)
			searchFrame.Search.Activated:Connect(updateInput)
			local v52 = v30[name]
			local v53 = v31[name]

			if searchFrame:FindFirstChild("Sort") then
				for _, guiObject in searchFrame.Sort.List:GetChildren() do
					if not guiObject:IsA("GuiObject") then
						continue
					end

					local name2 = guiObject.Name
					local v54 = v52
					local v55 = guiObject
					v9.Computed(function(callback)
						local v56 = callback(v54) == v55.Name
						v55.Image = v56 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
						v55.HoverImage = v56 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
						v55.Label.UIStroke.Color = v56 and Color3.fromRGB(149, 67, 0) or Color3.fromRGB(21, 56, 169)
						return nil
					end)
					local v56 = v52
					local v57 = guiObject
					local v58 = v53
					local v60 = frame
					guiObject.Activated:Connect(function()
						if v56:Get() == v57.Name then
							local v62

							if v58:Get() == Enum.SortDirection.Ascending then
								v62 = Enum.SortDirection.Descending
							else
								v62 = Enum.SortDirection.Ascending
							end

							v58:Set(v62)
						else
							v56:Set(v57.Name)
							v58:Set(Enum.SortDirection.Ascending)

							if name2 == "Default" or name2 == "Alphabetical" then
								v60.FrameUI.Scrolling.UIGridLayout.SortOrder = Enum.SortOrder.Name
							else
								v60.FrameUI.Scrolling.UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
							end
						end
					end)
				end

				local v54 = v53
				local v55 = searchFrame
				v9.Computed(function(callback)
					if callback(v54) == Enum.SortDirection.Ascending then
						v55.Sort.Arrow.Rotation = 180
					else
						v55.Sort.Arrow.Rotation = 0
					end

					return nil
				end)
				local visible = false
				local v57 = searchFrame
				searchFrame.Sort.Activated:Connect(function()
					visible = not visible
					v57.Sort.List.Visible = visible
				end)
			end

			if searchFrame:FindFirstChild("Delete") then
				searchFrame.Delete.Activated:Connect(function()
					state:Set(not state:Get())
				end)
				v9.setPropertyComputed(searchFrame.Delete, "Visible", function(callback)
					return not callback(state)
				end)
			end

			state:Connect(function(p)
				if not p then
					for _, v54 in v32 do
						v54:Set(0)
					end
				end
			end)
		end

		local top2 = frame:FindFirstChild("Top")

		if top2 then
			local sorting = top2:WaitForChild("Sorting")

			for _, uIListLayout in sorting:GetChildren() do
				if uIListLayout:IsA("UIListLayout") then
					continue
				end

				local name2 = name
				local v51 = uIListLayout
				uIListLayout.Activated:Connect(function()
					if state2:Get() == name2 then
						state3:Set(v51.Name)
					end
				end)
			end

			top2.L2.Activated:Connect(function()
				local v50 = state2:Get()
				local v51 = state3:Get()
				local v52 = v38[v50]

				if not v52 then
					return
				end

				state3:Set(v52[math.max(1, (table.find(v52, v51) - 2) % #v52 + 1)])
			end)
			top2.R2.Activated:Connect(function()
				local v50 = state2:Get()
				local v51 = state3:Get()
				local v52 = v38[v50]

				if not v52 then
					return
				end

				state3:Set(v52[math.max(1, table.find(v52, v51) % #v52 + 1)])
			end)
			local name4 = name
			v9.Computed(function(callback)
				if callback(state2) ~= name4 then
					return nil
				end

				local v52 = callback(state3)

				for i, uIListLayout in sorting:GetChildren() do
					if not uIListLayout:IsA("UIListLayout") then
						uIListLayout.ImageTransparency = uIListLayout.Name == v52 and 0 or 1
					end
				end

				return nil
			end)
		end

		local right = frame:FindFirstChild("Right")

		if right then
			if right:FindFirstChild("Btn") then
				right.Btn.Activated:Connect(function()
					self:EquipCurrent()
				end)
			end

			if right:FindFirstChild("EquipButton") then
				right.EquipButton.Activated:Connect(function()
					self:EquipCurrent()
				end)
			end

			if right:FindFirstChild("PurchaseButton") then
				right.PurchaseButton.Activated:Connect(function()
					self:EquipCurrent()
				end)
			end

			local upgradeButton = right:FindFirstChild("UpgradeButton") or right:FindFirstChild("Gift")

			if upgradeButton then
				upgradeButton.Activated:Connect(function()
					self:UpgradeCurrent()
				end)
			end
		end

		local v50 = frame
		local v51 = name
		task.spawn(function()
			local shuffle = v50.FrameUI.Scrolling:WaitForChild("!!!Shuffle", 1)

			if shuffle then
				v22.animateButtonClick(shuffle)
				v22.animateButtonHover(shuffle)
				v42[v51].ItemState:Connect(function()
					v50.RandomizerView.Visible = false
					v50.Right.Visible = true
					remoteEvent:FireServer(v43[v51], false, false)
				end)
			end
		end)
	end

	ContextActionService:BindActionAtPriority("ConsoleShopTabChanged", function(_, p, p2)
		if not (v10:IsOpen("ControllerShop") and p == Enum.UserInputState.Begin) then
			return Enum.ContextActionResult.Pass
		end

		local v47 = p2.KeyCode == Enum.KeyCode.ButtonR2 and 1 or -1
		local v48 = state2:Get()
		local v49 = (table.find(v46, v48) + v47 - 1) % #v46 + 1
		local v50 = v46[math.max(1, v49)]
		state2:Set(v50)
		local v51 = v38[v50] and v38[v50][1]

		if not v51 then
			return Enum.ContextActionResult.Sink
		end

		state3:Set(v51)
		return Enum.ContextActionResult.Sink
	end, false, 9999, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
	ContextActionService:BindActionAtPriority("ConsoleShopPurchaseButton", function(_, p, _)
		if not (v10:IsOpen("ControllerShop") and p == Enum.UserInputState.Begin) then
			return Enum.ContextActionResult.Pass
		end

		self:EquipCurrent()
		return Enum.ContextActionResult.Sink
	end, false, 9999, Enum.KeyCode.ButtonX)
	ContextActionService:BindActionAtPriority("ConsoleShopUpgradeButton", function(_, p, _)
		if not (v10:IsOpen("ControllerShop") and p == Enum.UserInputState.Begin) then
			return Enum.ContextActionResult.Pass
		end

		self:UpgradeCurrent()
		return Enum.ContextActionResult.Sink
	end, false, 9999, Enum.KeyCode.ButtonY)
	ContextActionService:BindActionAtPriority("ConsoleShopInnerTabChanged", function(_, p, p2)
		if not (v10:IsOpen("ControllerShop") and p == Enum.UserInputState.Begin) then
			return Enum.ContextActionResult.Pass
		end

		local v47 = p2.KeyCode == Enum.KeyCode.ButtonR1 and 1 or -1
		local v48 = state2:Get()
		local v49 = state3:Get()
		local v50 = v38[v48]

		if not v50 then
			return Enum.ContextActionResult.Sink
		end

		state3:Set(v50[math.max(1, (table.find(v50, v49) + v47 - 1) % #v50 + 1)])
		return Enum.ContextActionResult.Sink
	end, false, 9999, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL1)
	coinValue.Text = v12:AddCommas((math.floor(self.DataReplion:Get("Credits") or 0)))
	self.DataReplion:OnChange("Credits", function(p, _)
		coinValue.Text = v12:AddCommas((math.floor(p)))
	end)
	self:SetupPageRight()
	v3.new()
	v10:OnGuiClose("GiftingUI", function()
		if not controllerShop.Enabled then
			return
		end

		task.wait()
		v10:Open("ControllerShop", true)
		v10:Lock("ControllerShop", true)
		task.wait()
		v10:Unlock("ControllerShop", true)
		v10:Close("ControllerShop", true)
		self:Close()
	end)
	v10:OnGuiClose("ControllerShop", function()
		task.wait(0.1)

		if not v10:IsOpen("GiftingUI") then
			self:Close()
		end
	end)

	for _, v47 in Console.PageInfo do
		local pageName = v47.PageName

		if pageName == "Sword" or pageName == "Explosion" or pageName == "Ability" then
			local pageName2 = pageName
			v20:ObserveItemsStates(pageName, function(p)
				self:UpdateItem(v20:GetItemData(pageName2, v20:ParseItemKey(pageName2, p)))
			end)

			for _, v49 in v21[pageName] do
				self:UpdateItem(v20:GetItemData(v49.ItemType, v20:ParseItemKey(v49.ItemType, {
					Name = v49.Name
				})))

				if v20.IsSinglePlayerMode and pageName == "Ability" then
					self:UpdateItem(v20:GetItemData(v49.ItemType, v20:ParseItemKey(v49.ItemType, {
						Name = v49.Name,
						Upgrade = v49.Upgrade.MaxUpgrade
					})))
				end
			end
		elseif pageName == "Robux" then
			for _, v48 in v21.DevProduct do
				self:UpdateItem(v20:GetItemData(v48.ItemType, v20:ParseItemKey(v48.ItemType, {
					Name = v48.Name
				})))
			end

			for _, v48 in v21.GamePass do
				self:UpdateItem(v20:GetItemData(v48.ItemType, v20:ParseItemKey(v48.ItemType, {
					Name = v48.Name
				})))
			end
		end
	end

	local robux = main.Pages.Robux
	local summerPack = robux.FrameUI.Scrolling.SummerPack
	local uIPageLayout = summerPack.Main.List.UIPageLayout
	local v47 = {}
	local clones = {}
	local v48 = true

	for i = 1, 6 do
		local clone = uIPageLayout.Template:Clone()
		clone.LayoutOrder = i
		clone.Name = i
		clone.Parent = summerPack.Main.List
		clone.Buy.Activated:Connect(function()
			local v50 = v47[clone]

			if not v50 then
				return
			end

			local v51, v52 = v:Invoke("ClaimProgressiveReward", v50)

			if v51 or not v52 then
				return
			end

			ReplicatedStorage2.Misc.error:Play()
			v18:SendNotification(v52)
		end)
		-- equivalent calls inferred from this helper; original call sites unknown
		local v50 = clone

		local function updateText()
			local targetProdctId = v50:GetAttribute("TargetProdctId")
			local formatted = `<stroke color="rgb(8, 76, 28)" thickness="{v50.Buy.Label.UIStroke.Thickness}">{targetProdctId and "" or ""}<font size="16">{v50.Buy.Label.PriceLabel.Text}</font></stroke>`
			v50.Buy.Label.Text = formatted
		end

		local v51 = clone

		local function updateProduct()
			v51.Buy.Label.PriceLabel:RemoveTag("ProductPriceLabel")
			local targetProdctId = v51:GetAttribute("TargetProdctId")

			if targetProdctId then
				v14(v51.Buy.Label.PriceLabel, targetProdctId, "DevProduct", "%s")
			else
				v51.Buy.Label.PriceLabel.Text = "FREE"
			end

			updateText() -- equivalent call inferred; original call site unknown
		end

		clone.Buy.Label.PriceLabel:GetPropertyChangedSignal("Text"):Connect(updateText)
		clone.Buy.Label.UIStroke:GetPropertyChangedSignal("Thickness"):Connect(updateText)
		clone:GetAttributeChangedSignal("TargetProdctId"):Connect(updateProduct)
		task.spawn(updateText)
		task.spawn(updateProduct)
		clones[i] = clone
	end

	local v49 = nil

	local function updateSlots()
		local thread = coroutine.running()

		if v49 and coroutine.status(v49) == "suspended" and thread ~= v49 then
			v8.Thread.SafeCancel(v49)
		end

		v49 = thread
		local expect = dataReplion:GetExpect("ProgressiveRewards.Claimed")
		local v50 = #expect + 1
		local expect2 = dataReplion:GetExpect("ProgressiveRewards.Rewards")
		uIPageLayout:JumpToIndex(v50 % 6)
		local currentPage = uIPageLayout.CurrentPage
		local name = currentPage and tonumber(currentPage.Name) or 1
		local v51 = {}
		local v52 = {}

		for i = 1, 6 do
			local v53 = i - 2
			local v54 = (name + v53 - 1) % 6 + 1
			local v55 = math.max(v50 + v53, 1)
			local v56 = clones[v54]
			local v57 = expect[v55]
			local active = not v57 and v55 <= v50
			v56.Buy.Image = active and "rbxassetid://18453026315" or "rbxassetid://18468467098"
			v56.Buy.HoverImage = active and "rbxassetid://18453540357" or "rbxassetid://18468473058"
			v56.Buy.Active = active

			if not v57 and v55 <= v50 then
				v48 = false

				if robux.Visible and controllerShop.Enabled and not v48 then
					v8.Sounds:Play("SummerPackPurchase")
					task.delay(0.1, v8.Sounds.Play, v8.Sounds, "SummerPackScroll")
				end
			end

			v47[v56] = v55
			v51[i] = v55
			v52[i] = v56
		end

		task.wait(uIPageLayout.TweenTime)

		if thread ~= v49 then
			return
		end

		print(#expect2, 6)

		for i = 1, 6 do
			local v53 = v51[i]
			local v54 = v52[i]
			local v55 = expect2[math.clamp(v53, 1, #expect2)]
			local reward = v55 and v17.RewardsList[v55.Type][v55.Index].Reward

			if v55 then
				v54:SetAttribute("TargetProdctId", v17.ProductIds[v55.Type])
				v54.Vector.Image = reward.Icon or ""
				local label = v54.Label
				local text

				if reward.Type == "Ability" then
					text = `{reward.DisplayName}\nPERMANENT`
				else
					text = reward.DisplayName
				end

				label.Text = text
			else
				v54.Vector.Image = ""
				v54.Label.Text = "???"
			end
		end
	end

	dataReplion:OnChange("ProgressiveRewards.Rewards", updateSlots)
	dataReplion:OnChange("ProgressiveRewards.Claimed", updateSlots)
	task.spawn(updateSlots)
	local timer = summerPack.Main.Timer
	local blackFridaySale = robux.FrameUI.Scrolling.BlackFridaySale
	v8.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v50 = dataReplion:Get("ProgressiveRewards.LastReset")
		timer.Text = not v50 and "" or `{v8.ValueConvertor:FormatTimeHHMMSS(v50 + v17.ResetTime - workspace:GetServerTimeNow())}`
		local instantFFlag = v8.FFlag.GetInstantFFlag("BlackFridaySaleEndTime", 0)
		blackFridaySale.Visible = serverTimeNow < instantFFlag and v8.FFlag.GetInstantFFlag("BlackFridaySaleEnabled") == true
		blackFridaySale.Timer.Text = v8.ValueConvertor:FormatTimeWithDaysFull(instantFFlag - serverTimeNow)
	end)

	for _, childName in { "Sword", "Explosion" } do
		local v50 = childName
		main.Pages:FindFirstChild(childName).Right.Rap.RapButton.Activated:Connect(function()
			local v51 = v28[v50]:Get()

			if not (v51 and table.find(v40, v50) and v25:IsEnabled() and v25:ShouldShowRAP(v50, v51.ItemInfo.Name)) then
				return
			end

			local parsedItemKey = v51.ParsedItemKey

			if v26:Render("ControllerShop", v50, v51.ParsedItemKey) then
				return
			end

			warn("Failed to render RAP chart")
			v18:SendNotification("Failed to load RAP history. Try again later")
			v26:Close("ControllerShop")
		end)
	end

	v9.Computed(function(callback)
		callback(state2)
		v26:Close("ControllerShop")
		return nil
	end)
	state2:Connect(function()
		state:Set(false)
	end)
	list.Buttons.Delete.Activated:Connect(function()
		local v50 = {}
		local count = 0

		for k, v51 in v32 do
			if not (v51:Get() > 0) then
				continue
			end

			local items = client:FindItemsWithKey(k.ItemInfo.ItemType, k.ParsedItemKey)

			for i = 1, v51:Get() do
				local item = items[i]

				if not item then
					continue
				end

				local v52 = v50[k.ItemInfo.ItemType]

				if not v52 then
					v52 = {}
					v50[k.ItemInfo.ItemType] = v52
				end

				count += 1
				table.insert(v52, item)
			end
		end

		v19:PromptConfirmation({
			PromptType = "Single",
			Description = `Are you sure you want to delete x{count} items? This cannot be undone.`
		}, function(p, p2: string?)
			if p then
				state:Set(false)
				local v51, v52 = v:Invoke("RequestDelete", v50)

				if not v51 and v52 then
					v18:SendNotification(v52)
				end
			elseif p2 then
				v18:SendNotification(p2)
			end
		end)
	end)
	list.Buttons.Cancel.Activated:Connect(function()
		state:Set(false)
	end)
end

return Console