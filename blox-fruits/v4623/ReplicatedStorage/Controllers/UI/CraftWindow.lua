local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local AbilityKeybinds = require(ReplicatedStorage.Modules.Data.AbilityKeybinds)
local AssetComponent = require(ReplicatedStorage.Modules.Create.AssetComponent)
local KeyImages = require(ReplicatedStorage.Modules.KeyImages)
local LastInput = require(ReplicatedStorage.Modules.LastInput)
local FruitInfo = require(ReplicatedStorage.FruitInfo)
local Create = require(ReplicatedStorage.Modules.Create)
local Util = require(ReplicatedStorage.Util)
require(ReplicatedStorage.Modules.Asset.GetCurrencyUpsell)
local CraftingRecipes = require(ReplicatedStorage.Modules.Data.CraftingRecipes)
local ItemData = require(ReplicatedStorage.Modules.Asset.ItemData)
local Net = require(ReplicatedStorage.Modules.Net)
local CraftUtil = require(ReplicatedStorage.Modules.CraftUtil)
local Table = require(game.ReplicatedStorage.Modules.Util.Table)
local FishHelper = require(ReplicatedStorage.Modules.FishHelper)
local FishingIndexInventoryData = require(ReplicatedStorage.FishReplicated:WaitForChild("FishingIndexInventoryData"))
local Flags = require(ReplicatedStorage.Modules.Flags)
local Notification = require(ReplicatedStorage.Notification)
local Trove = require(ReplicatedStorage.Modules.Util.Trove)
local remoteFunction = Net:RemoteFunction("Craft")
local remoteFunction2 = Net:RemoteFunction("GetCraftPlayerData")
local remoteFunction3 = Net:RemoteFunction("EnchantInvoke")
local v = {
	[0] = { "Common", Color3.fromRGB(179, 179, 179) },
	[1] = { "Uncommon", Color3.fromRGB(92, 140, 211) },
	[2] = { "Rare", Color3.fromRGB(140, 82, 255) },
	[3] = { "Legendary", Color3.fromRGB(213, 43, 228) },
	[4] = { "Mythical", Color3.fromRGB(238, 47, 50), true },
	[5] = { "Premium", Color3.fromRGB(221, 188, 0), true }
}
local localPlayer = game.Players.LocalPlayer
local craft = localPlayer.PlayerGui:WaitForChild("Craft", 999)
local window = craft.Window
local crafting = window.Main.Crafting
local craftingGrid = crafting.Main.LeftSide.CraftingGrid
local result = crafting.Main.Result
local itemInfo = result.ItemInfo
local changeRecipe = crafting.Main.LeftSide.ChangeRecipe
local selection = window.Main.Selection
local confirm = window.Info.Confirm
local select = window.Info.Select
local back = window.Info.Back
result.AssetTile.Filled:Destroy()
local template = Create.Template("AssetComponentTemplate")
template.UIAspectRatioConstraint:Destroy()
template.Visible = true
template.Name = "ResultAsset"
template.LayoutOrder = -999
template.Size = UDim2.fromScale(1, 1)
template.Parent = result.AssetTile
local assetComponent = AssetComponent(template)
assetComponent:EnableHoverHighlight(false)
assetComponent:EnableAutoShine(false)
local v3 = {}
local v4 = nil
local maid = nil
local v5 = {}
local v6 = {}
local connections = {}
local v7 = {}
local name = nil
local v8 = nil
local v9 = nil
local v10 = nil
local flag = false
local v11 = nil
local v12 = {
	Craft = {
		DisplayTitle = "CRAFT"
	},
	Experiment = {
		DisplayTitle = "RESEARCH MATERIALS"
	},
	SelectSlappingFish = {
		DisplayTitle = "SELECT A FISH"
	}
}
local CraftWindow = {}

for i = 1, 6 do
	local child = craftingGrid:FindFirstChild(i)
	child.Name = i
	child.LayoutOrder = i
	local template2 = Create.Template("AssetComponentTemplate")
	template2.UIAspectRatioConstraint:Destroy()
	template2.Visible = true
	template2.Name = i
	template2.LayoutOrder = i
	template2.Size = UDim2.fromScale(1, 1)
	template2.Parent = child
	local component = AssetComponent(template2)
	component:EnableHoverHighlight(false)
	component:EnableAutoShine(false)
	local clone_2 = script.ChooseFishFrame:Clone()
	clone_2.Parent = template2.Filled
	table.insert(v3, {
		Component = component,
		Rbx = template2
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentPlayerData()
	local v13 = remoteFunction2:InvokeServer()
	v13.DecodedFishInventory = FishHelper.DecodeFishInventory(v13.EncodedFishInventory)
	return v13
end

local function clearScrollingFrame(instance)
	for _, frame in instance:GetChildren() do
		if frame:IsA("Frame") then
			frame:Destroy()
		end
	end
end

local function close()
	craft.Enabled = false

	if v4 then
		pcall(function()
			if localPlayer.PlayerGui then
				Util.Sound:Play("Campfire_Interact_CloseCookingMenu_01", localPlayer.PlayerGui)
			end
		end)
	end

	if maid then
		maid:Destroy()
		maid = nil
	end

	assetComponent:UpdateAsset(nil)

	for _, v13 in v3 do
		v13.Component:UpdateAsset(nil)
	end

	for _, v13 in v5 do
		v13:Destroy()
	end

	v5 = {}

	for _, v13 in v6 do
		v13:Destroy()
	end

	v6 = {}
	clearScrollingFrame(window.Main.RecipeSelection.ScrollingFrame)
	clearScrollingFrame(selection.List)
	selection.Visible = false
	window.Info.Back.Visible = false
	window.Info.Confirm.Visible = false
	window.Info.Select.Visible = false

	for _, connection in connections do
		connection:Disconnect()
	end

	connections = {}
	v7 = {}
	name = nil
	v8 = nil
	v9 = nil
	v10 = nil
	v4 = nil
	flag = false
end

local function applyButtonColors(select2, p, p2)
	if p == "Active" then
		local trans = select2:FindFirstChild("Trans")

		if p2 == "Secondary" then
			select2.BackgroundColor3 = Color3.fromRGB(62, 140, 208)
			select2.BorderColor3 = Color3.fromRGB(29, 65, 120)
			trans.BackgroundColor3 = Color3.fromRGB(84, 173, 232)
		else
			select2.BackgroundColor3 = Color3.fromRGB(255, 214, 49)
			select2.BorderColor3 = Color3.fromRGB(136, 61, 0)
			trans.BackgroundColor3 = Color3.fromRGB(255, 241, 87)
		end

		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
		select2:SetAttribute("Active", true)
	elseif p == "Inactive" then
		select2.BackgroundColor3 = Color3.fromRGB(132, 132, 132)
		select2.BorderColor3 = Color3.fromRGB(91, 91, 91)
		local trans = select2:FindFirstChild("Trans")
		trans.BackgroundColor3 = Color3.fromRGB(194, 194, 194)
		trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
		select2:SetAttribute("Active", false)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function reflectSelectButtonColor(items, p)
	local count = 0

	for _ in items do
		count += 1
	end

	applyButtonColors(select, count == p and "Active" or "Inactive")
end

local function openSelection(unsortedIndexes, decodedFishInventory, p, rarity, p2, p3)
	for _, connection in connections do
		connection:Disconnect()
	end

	connections = {}
	v11[8] = true
	local copy = Table.deepCopy(decodedFishInventory)

	for k, v13 in copy do
		v13.UnsortedIndex = k
	end

	table.sort(copy, function(a, b)
		return FishHelper.GetTrueWeight(a) > FishHelper.GetTrueWeight(b)
	end)

	for k, v13 in copy do
		local v14 = FishingIndexInventoryData.FishIndex[v13.Id]

		if v14.Rarity ~= rarity then
			continue
		end

		local clone = script.SelectionTileTemplate:Clone()
		local template2 = Create.Template("AssetComponentTemplate")
		template2.UIAspectRatioConstraint:Destroy()
		template2.Visible = true
		template2.Name = k
		template2.LayoutOrder = k
		template2.Size = UDim2.fromScale(1, 1)
		template2.Parent = clone
		local v15 = {
			StorageName = v14.Name,
			DisplayName = v14.Name .. " " .. FishHelper.FormatTrueWeight(FishHelper.GetTrueWeight(v13)),
			Rarity = rarity,
			Type = p,
			IsNew = false,
			Selected = table.find(unsortedIndexes, k) ~= nil,
			OverlayEffect = table.find(v13.Modifiers, "Corrupted") ~= nil and "Corrupted" or nil
		}
		local assetComponent2 = AssetComponent(template2)
		assetComponent2:EnableHoverHighlight(false)
		assetComponent2:EnableAutoShine(false)
		assetComponent2:UpdateAsset(v15)

		if v15.OverlayEffect then
			local clone_2 = script.CorruptedOverlayEffect:Clone()
			clone_2.Parent = assetComponent2._Rbx.Filled
		end

		reflectSelectButtonColor(unsortedIndexes, p3) -- equivalent call inferred; original call site unknown
		local v17 = v13
		assetComponent2._Rbx.Filled.TextButton.Activated:Connect(function()
			local index = table.find(unsortedIndexes, v17.UnsortedIndex)

			if p3 <= #unsortedIndexes and not index then
				return
			end

			if index then
				table.remove(unsortedIndexes, index)
			else
				table.insert(unsortedIndexes, v17.UnsortedIndex)
			end

			v15.Selected = not index
			assetComponent2:UpdateAsset(v15)
			local text = string.format("%s/%s %s", #unsortedIndexes, p3, p2)
			selection.Header.Text = text
			selection.Header.TextLabel.Text = text
			reflectSelectButtonColor(unsortedIndexes, p3) -- equivalent call inferred; original call site unknown
		end)
		table.insert(v5, assetComponent2)
		clone.Parent = selection.List
	end

	local text2 = string.format("%s/%s %s", #unsortedIndexes, p3, p2)
	selection.Header.Text = text2
	selection.Header.TextLabel.Text = text2
	crafting.Visible = false
	confirm.Visible = false
	select.Visible = true
	selection.Visible = true
end

local function openSlappingFishSelection(list, decodedFishInventory, p, p2)
	for _, connection in connections do
		connection:Disconnect()
	end

	connections = {}
	v11[8] = true
	local copy = Table.deepCopy(decodedFishInventory)

	for k, v13 in copy do
		v13.UnsortedIndex = k
	end

	table.sort(copy, function(a, b)
		return FishHelper.GetTrueWeight(a) > FishHelper.GetTrueWeight(b)
	end)
	local v13 = nil

	for k, v14 in copy do
		local v15 = FishingIndexInventoryData.FishIndex[v14.Id]
		v14.lastId = v14.UnsortedIndex
		local clone = script.SelectionTileTemplate:Clone()
		local template2 = Create.Template("AssetComponentTemplate")
		template2.UIAspectRatioConstraint:Destroy()
		template2.Visible = true
		template2.Name = k
		template2.LayoutOrder = k
		template2.Size = UDim2.fromScale(1, 1)
		template2.Parent = clone
		local v16 = {
			StorageName = v15.Name,
			DisplayName = v15.Name .. " " .. FishHelper.FormatTrueWeight(FishHelper.GetTrueWeight(v14)),
			Rarity = v15.Rarity,
			Type = p,
			IsNew = false,
			Selected = table.find(list, v14) ~= nil,
			OverlayEffect = v14.Modifiers
		}
		local assetComponent2 = AssetComponent(template2)
		assetComponent2:EnableHoverHighlight(false)
		assetComponent2:EnableAutoShine(false)
		assetComponent2:UpdateAsset(v16)
		v14.Name = v15.Name

		if v16.OverlayEffect then
			for _, _ in v16.OverlayEffect do
				local clone_2 = script.CorruptedOverlayEffect:Clone()
				clone_2.Parent = assetComponent2._Rbx.Filled
			end
		end

		reflectSelectButtonColor(list, 1) -- equivalent call inferred; original call site unknown
		local onActivated
		local v18 = v14

		onActivated = function()
			if v13 then
				local v21 = v13
				v13 = nil
				v21()
			end

			local index = table.find(list, v18)

			if #list >= 1 and not index then
				return
			end

			if index then
				table.remove(list, index)
			else
				table.insert(list, v18)
			end

			v16.Selected = not index
			assetComponent2:UpdateAsset(v16)
			local text = string.format("%s/%s %s", #list, 1, p2)
			selection.Header.Text = text
			selection.Header.TextLabel.Text = text
			reflectSelectButtonColor(list, 1) -- equivalent call inferred; original call site unknown
			v13 = onActivated
		end

		assetComponent2._Rbx.Filled.TextButton.Activated:Connect(onActivated)
		table.insert(v5, assetComponent2)
		clone.Parent = selection.List
	end

	local text2 = string.format("%s/%s %s", #list, 1, p2)
	selection.Header.Text = text2
	selection.Header.TextLabel.Text = text2
	crafting.Visible = false
	confirm.Visible = false
	select.Visible = true
	selection.Visible = true
end

local displayRecipe

displayRecipe = function(list, data, state, value, callback, value2, value3, p)
	v11 = {
		list,
		data,
		state,
		value,
		callback,
		value2,
		value3,
		false
	}

	if maid then
		maid:Destroy()
		maid = nil
	end

	maid = Trove.new()
	local v13 = value or "Craft"
	local v14 = value2 or "NPC"
	v8 = callback
	local v15 = data and CraftingRecipes[data.Recipe]
	local v16

	if data and data.Name then
		v16 = string.match(string.lower(data.Name), "bait")
	else
		v16 = false
	end

	local v17 = value3 or 1
	local name2 = data.Name
	local v18 = ItemData.Potion[name2] or ItemData.Food[name2] or ItemData.Bait[name2] or ItemData.Scroll[name2]
	local v19 = v18 and v18[2]
	local v20 = v9.EtcItems[name2] or 0
	changeRecipe.Visible = v14 == "Campfire"
	result.MultiCraft.Visible = v15 and v15.MultiCraft or v16
	local displayTitle = v12[v13].DisplayTitle

	if v13 == "Experiment" then
		local abilityKeybind = AbilityKeybinds[data.AbilityInfo.Keybind]

		if abilityKeybind then
			local v21 = LastInput:Get()
			result.HiddenAbilityInfo.KeybindLabel.Text = string.format("[%s]", abilityKeybind.MouseKeyboard)
			result.HiddenAbilityInfo.KeybindLabel.Visible = v21 == "MouseKeyboard"
			local stringForKeyCode = UserInputService:GetStringForKeyCode(Enum.KeyCode[abilityKeybind.Gamepad])
			local image = KeyImages.Gamepad[stringForKeyCode]
			result.HiddenAbilityInfo.KeybindImage.Image = image
			result.HiddenAbilityInfo.KeybindImage.Visible = v21 == "Gamepad"
		else
			result.HiddenAbilityInfo.KeybindLabel.Visible = false
			result.HiddenAbilityInfo.KeybindImage.Visible = false
		end

		result.HiddenAbilityInfo.AbilityNameLabel.Text = data.AbilityInfo.DisplayName
	end

	result.HiddenAbilityInfo.Visible = v13 == "Experiment"
	window.Title.TextLabel.Text = displayTitle
	window.Title.TextLabel.TextLabel.Text = displayTitle

	if v13 == "SelectSlappingFish" then
		for _, v21 in v5 do
			v21:Destroy()
		end

		v5 = {}
		clearScrollingFrame(selection.List)
		local v21 = list[1]
		v7[v21.Name] = {}
		openSlappingFishSelection(v7[v21.Name], v9.DecodedFishInventory, "Fish", "Fish")
		local v22 = false
		local thread = coroutine.running()
		select.Activated:Once(function()
			if not v22 then
				task.spawn(thread)
			end
		end)
		window.Title.Close.Activated:Once(function()
			if not v22 then
				v7[v21.Name] = {}
				task.spawn(thread)
			end
		end)
		back.Activated:Once(function()
			if not v22 then
				v7[v21.Name] = {}
				task.spawn(thread)
			end
		end)
		coroutine.yield()
		v22 = true
		local v23 = v7 and v7[v21.Name] and v7[v21.Name][1]
		selection.Visible = false
		select.Visible = false

		for _, v24 in v5 do
			v24:Destroy()
		end

		v5 = {}
		clearScrollingFrame(selection.List)
		close()
		return v23
	else
		table.sort(list, function(a, b)
			if a.Rarity ~= b.Rarity then
				return a.Rarity > b.Rarity
			end

			if a.Required == b.Required then
				return a.Name > b.Name
			end

			return a.Required > b.Required
		end)
		local v21 = nil
		local v22 = true
		local visible = false
		local v24 = {
			Type = data.Type,
			IsNew = false
		}
		local increaseQuantity = result.MultiCraft.IncreaseQuantity
		local decreaseQuantity = result.MultiCraft.DecreaseQuantity
		increaseQuantity.TextLabel.Text = "+"
		increaseQuantity.TextLabel.TextLabel.Text = "+"
		decreaseQuantity.TextLabel.Text = "-"
		decreaseQuantity.TextLabel.TextLabel.Text = "-"

		local function reflectRequirements(p2)
			v11[7] = v17

			if v17 >= CraftUtil:GetMaxCraftQuantity() then
				local increaseQuantity2 = increaseQuantity
				increaseQuantity2.BackgroundColor3 = Color3.fromRGB(132, 132, 132)
				increaseQuantity2.BorderColor3 = Color3.fromRGB(91, 91, 91)
				local trans = increaseQuantity2:FindFirstChild("Trans")
				trans.BackgroundColor3 = Color3.fromRGB(194, 194, 194)
				trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
				increaseQuantity2:SetAttribute("Active", false)
			else
				local increaseQuantity2 = increaseQuantity
				local trans = increaseQuantity2:FindFirstChild("Trans")
				increaseQuantity2.BackgroundColor3 = Color3.fromRGB(62, 140, 208)
				increaseQuantity2.BorderColor3 = Color3.fromRGB(29, 65, 120)
				trans.BackgroundColor3 = Color3.fromRGB(84, 173, 232)
				trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
				increaseQuantity2:SetAttribute("Active", true)
			end

			if v17 <= 1 then
				local decreaseQuantity2 = decreaseQuantity
				decreaseQuantity2.BackgroundColor3 = Color3.fromRGB(132, 132, 132)
				decreaseQuantity2.BorderColor3 = Color3.fromRGB(91, 91, 91)
				local trans = decreaseQuantity2:FindFirstChild("Trans")
				trans.BackgroundColor3 = Color3.fromRGB(194, 194, 194)
				trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
				decreaseQuantity2:SetAttribute("Active", false)
			else
				local decreaseQuantity2 = decreaseQuantity
				local trans = decreaseQuantity2:FindFirstChild("Trans")
				decreaseQuantity2.BackgroundColor3 = Color3.fromRGB(62, 140, 208)
				decreaseQuantity2.BorderColor3 = Color3.fromRGB(29, 65, 120)
				trans.BackgroundColor3 = Color3.fromRGB(84, 173, 232)
				trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
				decreaseQuantity2:SetAttribute("Active", true)
			end

			if data.AbilityInfo then
				v24.StorageName = data.AbilityInfo.FruitName or data.Name
				v24.Rarity = FruitInfo.get(data.AbilityInfo.FruitName).Rarity.Value
			else
				local count = (data.Count or 1) * v17
				v24.StorageName = data.Name
				v24.Upgrades = data.Grade
				v24.Count = count
				v24.Rarity = data.Rarity
				local v26 = (data.Count or 1) * (v17 + 1)

				if v19 and v19 < v20 + v26 then
					local increaseQuantity2 = increaseQuantity
					increaseQuantity2.BackgroundColor3 = Color3.fromRGB(132, 132, 132)
					increaseQuantity2.BorderColor3 = Color3.fromRGB(91, 91, 91)
					local trans = increaseQuantity2:FindFirstChild("Trans")
					trans.BackgroundColor3 = Color3.fromRGB(194, 194, 194)
					trans.BorderColor3 = Color3.fromRGB(27, 42, 53)
					increaseQuantity2:SetAttribute("Active", false)
				end
			end

			assetComponent:UpdateAsset(v24)

			for k, v25 in list do
				local v26 = v3[k]
				local rbx = v26.Rbx
				local parent = rbx.Parent
				local component = v26.Component
				local isChoosable = v25.IsChoosable
				local flag2 = false
				local v27 = v25.Required * v17

				if v25.Name == "Fragments" or v25.Name == "Beli" then
					if v25.Name == "Fragments" then
						v21 = v27
					end

					component:UpdateAsset({
						StorageName = "Wooden Plank",
						Rarity = 1,
						Type = "Material",
						IsNew = false
					})

					if v25.Name == "Fragments" then
						rbx.Filled.Icon.Image = "rbxassetid://9999319457"
						rbx.Filled.Icon.ImageRectOffset = Vector2.new(609, 0)
						rbx.Filled.Icon.ImageRectSize = Vector2.new(203, 138)
						rbx.Filled.Background.ImageRectOffset = Vector2.new(438, 225)
						rbx.Filled.ItemInformation.ItemName.Text = v27 .. " Fragments"
						rbx.Filled.ItemInformation.ItemName.TextLabel.Text = v27 .. " Fragments"
						rbx.Filled.ItemInformation.ItemName.Size = UDim2.fromScale(0.85, 0.3)
						flag2 = true
					elseif v25.Name == "Beli" then
						rbx.Filled.Icon.Image = "rbxassetid://9999319457"
						rbx.Filled.Icon.ImageRectOffset = Vector2.new(203, 0)
						rbx.Filled.Icon.ImageRectSize = Vector2.new(203, 138)
						rbx.Filled.Background.ImageRectOffset = Vector2.new(218, 450)
						rbx.Filled.ItemInformation.ItemName.Text = v27 .. " Money"
						rbx.Filled.ItemInformation.ItemName.TextLabel.Text = v27 .. " Money"
						rbx.Filled.ItemInformation.ItemName.Size = UDim2.fromScale(0.85, 0.3)
						flag2 = true
					end

					rbx.Filled.Icon.ScaleType = Enum.ScaleType.Fit
					rbx.Filled.Icon.Visible = true
					parent.ItemCount.Visible = false
					rbx.Visible = true
				else
					if isChoosable then
						component:UpdateAsset({
							Rarity = v25.Rarity,
							Type = "Fish",
							IsNew = false
						})
						local text = string.format("%s Fish", v[v25.Rarity][1])
						rbx.Filled.ItemInformation.ItemName.Text = text
						rbx.Filled.ItemInformation.ItemName.TextLabel.Text = text
						rbx.Filled.ItemInformation.ItemLine1.Text = "Fish"
						rbx.Filled.ItemInformation.ItemLine1.TextLabel.Text = "Fish"
						rbx.Filled.Icon.Visible = false
						rbx.Visible = true

						if not v7[v25.Name] then
							v7[v25.Name] = {}
						end

						if not p or p2 then
							for _ = 1, v27 do
								for i = #v9.DecodedFishInventory, 1, -1 do
									local v29 = v9.DecodedFishInventory[i]

									if v29 and FishingIndexInventoryData.FishIndex[v29.Id].Rarity == v25.Rarity and not table.find(
										v7[v25.Name],
										i
									) then
										table.insert(v7[v25.Name], i)
									end

									if v27 <= #v7[v25.Name] then
										break
									end
								end
							end
						end

						local v29 = v25
						local v30 = v27
						table.insert(connections, rbx.Filled.TextButton.Activated:Connect(function()
							if v29.Count < v30 then
								return
							end

							name = v29.Name
							openSelection(v7[v29.Name], v9.DecodedFishInventory, "Fish", v29.Rarity, text, v30)
						end))
					else
						component:UpdateAsset({
							StorageName = v25.Name,
							Rarity = v25.Rarity,
							Type = "Material",
							IsNew = false
						})
						rbx.Filled.Icon.Visible = true
						rbx.Visible = true
					end

					flag2 = true
				end

				if flag2 then
					if v25.Count and v27 and v25.Count < v27 then
						v22 = false
					end

					if parent then
						local count = 0
						local itemCount = parent.ItemCount

						if isChoosable and v27 <= v25.Count then
							if v27 <= #v7[v25.Name] then
								itemCount.Visible = v27 <= #v7[v25.Name]
								visible = #v7[v25.Name] < v27
								count = #v7[v25.Name]
							else
								itemCount.Visible = false
								visible = true
							end
						else
							itemCount.Visible = true
							visible = false
							count = v25.Count
						end

						local v28 = count / v27

						if v25.Name == "Beli" or v25.Name == "Fragments" then
							itemCount.Text = v28 >= 1 and "1/1" or "0/1"
							itemCount.TextColor3 = v28 >= 1 and Color3.fromRGB(53, 229, 0) or Color3.fromRGB(236, 0, 3)
						else
							itemCount.Text = count .. "/" .. v27

							if v28 >= 1 then
								itemCount.TextColor3 = Color3.fromRGB(53, 229, 0)
							elseif v28 >= 0.5 then
								itemCount.TextColor3 = Color3.fromRGB(236, 118, 0)
							else
								itemCount.TextColor3 = Color3.fromRGB(236, 0, 3)
							end
						end
					end
				end

				parent.Plus.Visible = visible
				parent.Plus.TextColor3 = Color3.fromRGB(236, 0, 3)
				rbx.Filled.ChooseFishFrame.Visible = isChoosable
			end
		end

		reflectRequirements()

		if #list < 6 then
			for i = #list + 1, 6 do
				local v25 = v3[i]
				v25.Component:UpdateAsset(nil)
				v25.Rbx.Visible = false
				v25.Rbx.Parent.ItemCount.Visible = false
				v25.Rbx.Parent.Plus.Visible = false
				v25.Rbx.Filled.ChooseFishFrame.Visible = false
			end
		end

		itemInfo.ItemName.Text = data.Name
		itemInfo.Desc.Text = v[data.Rarity or 0][1]

		if data.Grade then
			itemInfo.Desc.Text ..= ", Grade " .. data.Grade
		end

		itemInfo.Desc.TextColor3 = v[data.Rarity or 0][2]

		if state and not state.Old and state.New then
			state.Old = { "No additional stats" }
		end

		if state and state.Old then
			itemInfo.Visible = true
			result.Stats.Visible = true
			result.Stats.Current.Text = string.format("<b>Current:</b> %s", state.Old[1])

			if state.New then
				result.Stats.New.Text = string.format("<b>New:</b> %s", state.New[1])
				result.Stats.New.TextColor3 = Color3.fromRGB(240, 220, 59)
			else
				result.Stats.New.Text = "<b>Max Upgrades Applied</b>"
				result.Stats.New.TextColor3 = Color3.fromRGB(255, 0, 4)
			end
		else
			itemInfo.Visible = false
			result.Stats.Visible = false
		end

		local v25 = nil
		confirm.Visible = data.Could or data.ErrorMessage
		maid:Add(confirm.Activated:Connect(function()
			if v25 then
				v25.Notify()
				return
			end

			if not data.Could and data.ErrorMessage then
				Notification.new(`<Color=Red>{data.ErrorMessage}<Color=/>`, 3):Display()
				return
			end

			if v13 == "Experiment" then
				callback()
			elseif data.Physical then
				local v26

				if Flags.ENCHANT_USES_NEW_SERVICE then
					v26 = remoteFunction3:InvokeServer("Upgrade", data.Physical)
				else
					v26 = ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeItem", "Upgrade", data.Physical)
				end

				if v26 then
					v9 = getCurrentPlayerData()
					displayRecipe(v26.Required, v26.Result, v26.ResultStats)
				end
			else
				local v26 = remoteFunction:InvokeServer("Craft", data.Recipe, v17, v7)

				if v26 then
					if v14 == "Campfire" then
						pcall(function()
							if localPlayer.PlayerGui then
								Util.Sound:Play("Campfire_Cook_0" .. tostring(math.random(1, 3)), localPlayer.PlayerGui)
							end
						end)
					end

					v9 = getCurrentPlayerData()
					displayRecipe(v26.Required, v26.Result, v26.ResultStats)
				end
			end

			close()
		end))
		maid:Add(increaseQuantity.Activated:Connect(function()
			local v26 = v19 - v20
			local v27 = (data.Count or 1) * (v17 + 1)

			if not (v26 <= v17) and not (v19 < v20 + v27) then
				v17 = math.min(v26, v17 + 1)
				reflectRequirements(true)
			end
		end))
		maid:Add(decreaseQuantity.Activated:Connect(function()
			v7 = {}
			v17 = math.max(1, v17 - 1)
			reflectRequirements(true)
		end))
	end
end

local function buildRecipeSelection()
	local count = 0

	for k, craftingRecipe in CraftingRecipes do
		if craftingRecipe.Offsale then
			continue
		end

		local storageName = craftingRecipe.Reward[1]
		local v14 = ItemData.Potion[storageName] or ItemData.Food[storageName]

		if not v14 then
			continue
		end

		if v4 then
			if craftingRecipe.WhitelistedCampfires and not table.find(craftingRecipe.WhitelistedCampfires, v4.Name) then
				continue
			end

			local whitelistedRecipes = v4:GetAttribute("WhitelistedRecipes")

			if whitelistedRecipes then
				local v15 = string.split(whitelistedRecipes, ", ")

				if not table.find(v15, k) then
					continue
				end
			end
		end

		local v15 = CraftUtil:Check(localPlayer, k, v9)
		local v16 = v15.Result.CraftProgressionComplete == nil or v15.Result.CraftProgressionComplete
		local template2 = Create.Template("AssetComponentTemplate")
		template2.UIAspectRatioConstraint.AspectRatio = 0.98
		template2.Visible = true
		template2.Name = tostring(count) .. storageName
		template2.LayoutOrder = count
		template2.Size = UDim2.fromScale(1, 1)
		template2.Parent = window.Main.RecipeSelection.ScrollingFrame
		local assetComponent2 = AssetComponent(template2)
		assetComponent2:EnableHoverHighlight(false)
		assetComponent2:EnableAutoShine(false)
		local rarity = v14[1]
		local amount = craftingRecipe.Reward[2]
		local v21 = {
			StorageName = storageName,
			DisplayName = v16 and storageName or "???",
			Rarity = rarity,
			Type = craftingRecipe.Reward[3] or "Material",
			IsNew = false,
			Hidden = not v16,
			Amount = 0
		}

		if typeof(amount) ~= "number" then
			amount = nil
		end

		v21.Amount = amount
		assetComponent2:UpdateAsset(v21)
		table.insert(v6, assetComponent2)
		local v22 = k
		assetComponent2._Rbx.Filled.TextButton.Activated:Connect(function()
			if not v16 then
				return
			end

			local v23 = CraftUtil:Check(localPlayer, v22, v9)
			displayRecipe(v23.Required, v23.Result, nil, "Craft", nil, "Campfire")
			window.Main.RecipeSelection.Visible = false
			window.Main.Crafting.Visible = true
		end)
		count += 1
	end
end

function CraftWindow:Open(p: string?, ...)
	if flag then
		return
	end

	flag = true
	v9 = getCurrentPlayerData()
	window.Main.Crafting.Visible = p ~= "Campfire"
	window.Main.RecipeSelection.Visible = p == "Campfire"
	v10 = p

	if p == "Campfire" then
		local v13 = ({ ... })[1]

		if not v4 and v13 then
			v4 = v13
		end

		if v4 then
			pcall(function()
				if localPlayer.PlayerGui then
					Util.Sound:Play("Campfire_Interact_OpenCookingMenu_01", localPlayer.PlayerGui)
				end
			end)
		end

		buildRecipeSelection()
	elseif p == "SelectSlappingFish" then
		window.Visible = true
		craft.Enabled = true
		return displayRecipe(...)
	else
		displayRecipe(...)
	end

	window.Visible = true
	craft.Enabled = true
end

function CraftWindow.Close(_)
	close()
end

function CraftWindow.IsOpen(_)
	return flag
end

function CraftWindow.OnStart(_)
	window.Info.Back.Visible = false
	window.Info.Confirm.Visible = false
	window.Info.Select.Visible = false
	window.Title.Close.Activated:Connect(function()
		if v8 then
			v8(true)
		end

		close()
	end)
	changeRecipe.Activated:Connect(function()
		v7 = {}
		name = nil
		confirm.Visible = false
		window.Main.Crafting.Visible = false
		window.Main.RecipeSelection.Visible = true
	end)

	local function exitSelectionPage()
		selection.Visible = false
		select.Visible = false

		for _, v13 in v5 do
			v13:Destroy()
		end

		v5 = {}
		clearScrollingFrame(selection.List)

		if v11[4] == "SelectSlappingFish" then
			return
		end

		displayRecipe(unpack(v11))
		crafting.Visible = true
	end

	select.Activated:Connect(function()
		if select:GetAttribute("Active") then
			exitSelectionPage()
		end
	end)
	selection:GetPropertyChangedSignal("Visible"):Connect(function()
		back.Visible = selection.Visible
	end)
	back.Activated:Connect(function()
		if v7 and name then
			v7[name] = {}
		end

		exitSelectionPage()
	end)

	local function campfireAdded(instance)
		if not instance:GetAttribute("CraftingCampfire") then
			return
		end

		local craftingPrompt = instance:WaitForChild("Interact"):WaitForChild("CraftingPrompt")

		if not craftingPrompt then
			return
		end

		local triggeredConnection = craftingPrompt.Triggered:Connect(function()
			v4 = instance
			CraftWindow:Open("Campfire")
			task.spawn(function()
				while task.wait(1) and v4 == instance do
					local character = localPlayer.Character

					if not (character and (character:GetPivot().Position - instance:GetPivot().Position).Magnitude > 20) then
						continue
					end

					close()
					break
				end
			end)
			local isDisabledChangedConnection = nil
			isDisabledChangedConnection = instance:GetAttributeChangedSignal("IsDisabled"):Connect(function()
				if instance:GetAttribute("IsDisabled") and v4 == instance then
					isDisabledChangedConnection:Disconnect()
					isDisabledChangedConnection = nil
					close()
				end
			end)
		end)
		local ancestryChangedConnection = nil
		ancestryChangedConnection = instance.AncestryChanged:Connect(function(_, parent)
			if not parent then
				ancestryChangedConnection:Disconnect()
				ancestryChangedConnection = nil
				triggeredConnection:Disconnect()
				triggeredConnection = nil

				if v4 == instance then
					close()
				end
			end
		end)
	end

	for _, child in workspace:GetChildren() do
		task.defer(campfireAdded, child)
	end

	workspace.ChildAdded:Connect(campfireAdded)

	for _, child in workspace._WorldOrigin.PermanentCampfires:GetChildren() do
		task.defer(campfireAdded, child)
	end

	workspace._WorldOrigin.PermanentCampfires.ChildAdded:Connect(campfireAdded)

	for _, v13 in CollectionService:GetTagged("CraftingCampfire") do
		task.defer(campfireAdded, v13)
	end

	CollectionService:GetInstanceAddedSignal("CraftingCampfire"):Connect(campfireAdded)
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() then
		local TextChatService = game:GetService("TextChatService")
		TextChatService.SendingMessage:Connect(function(p)
			if p.Text == "opencampfire" then
				CraftWindow:Open("Campfire")
			end
		end)
	end
end

return CraftWindow