local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("ServerScriptService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage3:WaitForChild("UserInputService"))
game:GetService("StarterGui")
game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Freeze)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Common.Utils)
local _ = require3(ReplicatedStorage2.Shared.Inventory).Client
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
local v5 = require3(ReplicatedStorage2.Shared.Inventory.Shared)
local v6 = require3(ReplicatedStorage2.Controllers.UI.ShopControllerAPI)
local v7 = require3(ReplicatedStorage2.Controllers.Trading.TradeController)
local v8 = require3(ReplicatedStorage2.Controllers.Trading.ExistCounterController)
local v9 = require3(ReplicatedStorage2.Controllers.Trading.RAPController)
local v10 = require3(ReplicatedStorage2.Shared.ItemInfo)
local v11 = require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
local v12 = require3(ReplicatedStorage2.Shared.Statable)
require3(ReplicatedStorage2.ServerInfo)
local v13 = require3(ReplicatedStorage2.Shared.VirtualGridScroll)
local v14 = require3(ReplicatedStorage2.Controllers.HoverInfoController)
local v15 = require3(ReplicatedStorage2.Shared.ReplicatedInstances.SwordAccessories)
local icon = v4.Icons:GetIcon("DEFAULT_MISSING")
local v16 = {
	Most = -1,
	Least = 1
}
local _ = {
	Explosion = 0,
	Sword = 1,
	Emote = 2
}
local v17 = {
	"Default",
	"Alphabetical",
	"RAP",
	"Creation Date",
	"Exists"
}
local _ = Players.LocalPlayer.PlayerGui
local state = v12.State(false)
v12.State(true)
local v18 = nil
local v19 = {}
local InventoryController = {}

function InventoryController:GetFavoriteState(p, p2: string)
	local states = v19[p]

	if not states then
		states = {}
		v19[p] = states
	end

	if states[p2] then
		return states[p2]
	end

	local state2 = v12.State(false)
	states[p2] = state2
	v18 = v18 or v.Client:WaitReplion("Data")
	local v20 = { v5:GetLegacyInventoryPath(p), "Favorites", p2 }

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateFavorited()
		state2:Set(v18:Get(v20) and true or false)
	end

	updateFavorited() -- equivalent call inferred; original call site unknown
	v18:OnChange(v20, updateFavorited)
	return state2
end

function InventoryController.CreateTabOptions(_, instance, object, p)
	local maid = v3.new()

	for _, button in instance:GetChildren() do
		if not button:IsA("ImageButton") then
			continue
		end

		local v20 = button
		maid:Add(v12.Computed(function(callback)
			local v21

			if callback(object) == v20.Name then
				v21 = p and callback(p) == ""
			else
				v21 = false
			end

			v20.Image = v21 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			v20.HoverImage = v21 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = v20.Label.UIStroke
			local color

			if v21 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			return nil
		end))
		local v21 = button
		maid:Add(button.Activated:Connect(function()
			object:Set(v21.Name)
		end))
	end

	return maid
end

function InventoryController.CreateSearchBox(_, p, object)
	local maid = v3.new()
	local searchBox = p.SearchBox
	maid:Add(searchBox.FocusLost:Connect(function(flag: boolean)
		if flag then
			object:Set(searchBox.Text)
		end
	end))
	maid:Add(p.Search.Activated:Connect(function()
		object:Set(searchBox.Text)
	end))
	maid:Add(object:Connect(function()
		if searchBox.Text ~= object:Get() then
			searchBox.Text = ""
		end
	end))
	return maid
end

function InventoryController.CreateSortOptions(_, data, object, object2, p)
	local maid = v3.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function toggleSort()
		debug.profilebegin("toggleSort")
		object2:Set(object2:Get() == "Most" and "Least" or "Most")
		debug.profileend()
	end

	for _, v20 in p or v17 do
		local clone = maid:Clone(data.FilterPopUp.UIListLayout.Template)
		clone.Name = v20
		clone.Label.Text = v20
		local v21 = v20
		maid:Add(v12.Computed(function(callback)
			local v23 = callback(object) == v21
			clone.Image = v23 and "rbxassetid://18123223527" or "rbxassetid://18123248161"
			clone.HoverImage = v23 and "rbxassetid://18123872657" or "rbxassetid://18123874724"
			local uIStroke = clone.Label.UIStroke
			local color

			if v23 then
				color = Color3.fromRGB(149, 67, 0)
			else
				color = Color3.fromRGB(21, 56, 169)
			end

			uIStroke.Color = color
			return nil
		end))
		clone.Parent = data.FilterPopUp
		local v23 = v20
		maid:Add(clone.Activated:Connect(function()
			if object:Get() == v23 then
				toggleSort() -- equivalent call inferred; original call site unknown
			else
				object2:Set("Most")
				object:Set(v23)
			end

			data.FilterPopUp.Visible = false
		end))

		if v20 ~= "RAP" then
			continue
		end

		local v24 = clone
		maid:Add(task.spawn(function()
			local v25 = v.Client:WaitReplion("ItemRAP")
			maid:Add(v12.setPropertyComputed(v24, "Visible", function(callback)
				return callback((v12.getReplionPathState(v25, "AllItemsLoaded")))
			end))
		end))
	end

	maid:Add(v12.setPropertyComputed(data.Arrow, "Rotation", function(callback)
		if callback(object2) == "Most" then
			return 0
		end

		return 180
	end))
	local v20 = 0
	maid:Add(data.Activated:Connect(function()
		local now = os.clock()
		local visible = not data.FilterPopUp.Visible

		if visible then
			v20 = now
		elseif now - v20 < 0.3 then
			toggleSort() -- equivalent call inferred; original call site unknown
		end

		data.FilterPopUp.Visible = visible
	end))
	return maid
end

function InventoryController:CreateInventory(data)
	local itemTemplate = data.ItemTemplate
	local container = data.Container
	local caller = data.Caller
	local inventoryType = data.InventoryType
	local searchFilter = data.SearchFilter
	local pageVisible = data.PageVisible
	local v20 = assert(
		container:IsA("ScrollingFrame") and container:FindFirstChildWhichIsA("UIGridLayout"),
		"Container is not a scrolling frame, it needs to be a ScrollingFrame with UIGridLayout"
	)
	local sortOrder = v20.SortOrder
	local sortOrder2 = data.SortOrder
	local sortOption = data.SortOption
	local sortMode = data.SortMode
	local useFavorites = data.UseFavorites
	local changeNameStroke = data.ChangeNameStroke ~= false
	local showCreatedAt = data.ShowCreatedAt == true
	local allowedIcons = data.AllowedIcons or {
		"Stack",
		"Lock",
		"Favorited",
		"Finisher",
		"SwordAccessory"
	}
	local allowAbilityInfo = data.AllowAbilityInfo
	local existCounterReplionChannel = data.ExistCounterReplionChannel or "ClientExistCount"
	local maid = v3.new()
	local index

	if itemTemplate:FindFirstChild("FavoritedTemplate") == nil then
		index = false
	else
		index = table.find(allowedIcons, "Favorited")
	end

	local index2

	if itemTemplate:FindFirstChild("Finisher") == nil then
		index2 = false
	else
		index2 = table.find(allowedIcons, "Finisher")
	end

	local index3

	if itemTemplate:FindFirstChild("SwordAccessory") == nil then
		index3 = false
	else
		index3 = table.find(allowedIcons, "SwordAccessory")
	end

	local index4

	if itemTemplate:FindFirstChild("Stack") == nil then
		index4 = false
	else
		index4 = table.find(allowedIcons, "Stack")
	end

	local index5

	if itemTemplate:FindFirstChild("Lock") == nil then
		index5 = false
	else
		index5 = table.find(allowedIcons, "Lock")
	end

	local v21 = {}
	local stack

	if index4 then
		stack = itemTemplate.Stack
	end

	local finisher

	if index2 then
		finisher = itemTemplate.Finisher
	end

	local swordAccessory

	if index3 then
		swordAccessory = itemTemplate.SwordAccessory
	end

	local v22

	if index5 and index2 and itemTemplate.Lock.Size == itemTemplate.Finisher.Size then
		v22 = itemTemplate.Lock
	end

	v21[1], v21[2], v21[3], v21[4] = stack, finisher, swordAccessory, v22

	for i = #v21, 1, -1 do
		if v21[i] == nil then
			table.remove(v21, i)
		end
	end

	local positions = {}

	for k, v23 in v21 do
		local position = v23:GetAttribute("Position")

		if not position then
			position = v23.Position
			v23:SetAttribute("Position", position)
		end

		positions[k] = position
	end

	local v23 = maid:Add(v13({
		Container = container,
		Template = itemTemplate,
		Sort = function(p, p2)
			if sortOrder ~= Enum.SortOrder.LayoutOrder then
				return p.Name:Get() < p2.Name:Get()
			end

			local v24 = p.LayoutOrder:Get()
			local v25 = p2.LayoutOrder:Get()

			if v24 == v25 then
				return p.Name:Get() < p2.Name:Get()
			end

			return v24 < v25
		end,
		Constructor = function(data2, state2, _)
			local maid2 = v3.new()
			state2.ItemName.Text = data2.ItemInfo.DisplayName or data2.ItemInfo.Name
			state2.Vector.Image = data2.ItemInfo.Icon or icon

			if data2.IsFavorited and data2.IsFavorited ~= state and index then
				maid2:Add(v12.setPropertyState(state2.FavoritedTemplate, "Visible", data2.IsFavorited))
				maid2:Add(function()
					state2.FavoritedTemplate.Visible = false
				end)
			end

			v14:Add(state2, inventoryType, data2.Item, data2.ItemKey, {
				AllowAbilityInfo = allowAbilityInfo,
				ShowCreatedAt = showCreatedAt
			})
			maid2:Add(function()
				v14:Remove(state2)
			end)
			local rarity = data2.ItemInfo.Rarity

			if rarity then
				local image = state2.Image
				local hoverImage = state2.HoverImage
				local color = state2.ItemName.UIStroke.Color
				local v24 = v11.SlotColors[rarity] or v11.SlotColors.Default
				state2.Image = v24.Image
				state2.HoverImage = v24.HoverImage

				if changeNameStroke then
					state2.ItemName.UIStroke.Color = v24.StrokeColor
				end

				maid2:Add(function()
					state2.Image = image
					state2.HoverImage = hoverImage

					if changeNameStroke then
						state2.ItemName.UIStroke.Color = color
					end
				end)
			end

			if data.OnSlotCreated then
				data.OnSlotCreated(inventoryType, data2.Item, data2.ItemKey, state2, maid2)
			end

			local function updateIcons()
				local v24 = 1

				for _, v25 in v21 do
					local v26 = state2[v25.Name]

					if not v26.Visible then
						continue
					end

					v26.Position = positions[v24] or v26.Position
					v24 += 1
				end
			end

			if index4 and (inventoryType ~= "Ability" or allowAbilityInfo) then
				maid2:Add(v12.Computed(function(callback)
					local v24 = callback(data2.ItemsMatching)

					if inventoryType == "Emote" and string.find(data2.Name:Get(), "Emote1058") ~= nil then
						state2.Stack.Visible = true
						state2.Stack.Label.Text = "x67"
					else
						local stack2 = state2.Stack
						stack2.Visible = not (data.ShowCreatedAt and data2.Item.CreatedAt) and #v24 >= 2
						state2.Stack.Label.Text = `x{#v24}`
					end

					updateIcons()
					return nil
				end))
				maid2:Add(function()
					state2.Stack.Visible = false
				end)
			end

			if inventoryType == "Sword" and index2 then
				local item = data2.Item
				state2.Finisher.Visible = item.Finisher ~= nil

				if item.Finisher ~= nil then
					local child = ReplicatedStorage2.Misc.DataFinishers:FindFirstChild(item.Name)
					state2.Finisher.Icon.Image = child and child:GetAttribute("Icon") or icon
				end

				maid2:Add(function()
					state2.Finisher.Visible = false
				end)
			end

			if inventoryType == "Sword" and index3 then
				local item = data2.Item
				state2.SwordAccessory.Visible = item.Accessory == true

				if item.Accessory == true then
					local v24 = v15:GetCollection()[item.Name]
					state2.SwordAccessory.Icon.Image = v24 and v24.Icon or icon
				end

				maid2:Add(function()
					state2.SwordAccessory.Visible = false
				end)
			end

			if index5 then
				v7:CanTradeInstant()

				-- equivalent calls inferred from this helper; original call sites unknown
				local function updateLock()
					local lock = state2.Lock
					lock.Visible = data2.Item.TradeLock ~= nil and (inventoryType ~= "Ability" or allowAbilityInfo) and v18 and v18:Get("HasInteractedWithTrading") and data2.Item.TradeLock.Type ~= "Trial"
				end

				updateLock() -- equivalent call inferred; original call site unknown

				if not (v18 and v18:Get("HasInteractedWithTrading")) then
					maid2:Add(task.spawn(function()
						if not v18 then
							v18 = v.Client:WaitReplion("Data")
						end

						assert(v18)
						local v24 = nil
						v24 = maid2:Add(v18:OnChange("HasInteractedWithTrading", function()
							maid2:Remove(v24)
							updateLock() -- equivalent call inferred; original call site unknown
						end))
					end))
				end

				maid2:Add(function()
					state2.Lock.Visible = false
				end)
			end

			updateIcons()
			return function()
				maid2:Destroy()
			end
		end
	}))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function itemToKey(inventoryType2, p)
		return v5:ItemToKey(inventoryType2, p, { "Id" }, data.ShowCreatedAt)
	end

	local findItemsWithKey = data.FindItemsWithKey or function(p, p2: string)
		return v5:FindItemsWithKey(caller, p, p2)
	end
	local v24 = {}

	local function tryRemoveSlot(p)
		debug.profilebegin("tryRemoveSlot")
		debug.profilebegin("itemToKey")
		local v25 = itemToKey(inventoryType, p) -- equivalent call inferred; original call site unknown
		debug.profileend()

		if not v25 or #findItemsWithKey(inventoryType, v25) > 0 then
			debug.profileend()
			return
		end

		local v26 = v24[v25]

		if not v26 then
			debug.profileend()
			return
		end

		debug.profilebegin("trove:Destroy")
		v26.Trove:Destroy()
		debug.profileend()
		debug.profileend()
		return true
	end

	local function updateSlot(p)
		debug.profilebegin("updateSlot")
		debug.profilebegin("itemToKey")
		local v25 = itemToKey(inventoryType, p) -- equivalent call inferred; original call site unknown
		debug.profileend()

		if not v25 then
			debug.profileend()
			return
		end

		local v26 = v24[v25]

		if not v26 then
			debug.profileend()
			return
		end

		debug.profilebegin("findItemsWithKey")
		local itemsWithKey = findItemsWithKey(inventoryType, v25)
		debug.profileend()

		if #itemsWithKey <= 0 then
			debug.profileend()
			return tryRemoveSlot(p)
		end

		if not v2.List.equals(v26.ItemsMatching:Get(), itemsWithKey) then
			v26.ItemsMatching:Set(itemsWithKey)
		end

		debug.profileend()
	end

	local function createSlot(p)
		debug.profilebegin("createSlot")
		debug.profilebegin("itemToKey")
		local itemKey = itemToKey(inventoryType, p) -- equivalent call inferred; original call site unknown
		debug.profileend()

		if not itemKey then
			debug.profileend()
			return
		end

		if v24[itemKey] then
			debug.profileend()
			return updateSlot(p)
		end

		debug.profilebegin("findItemsWithKey")
		local itemsWithKey = findItemsWithKey(inventoryType, itemKey)
		debug.profileend()

		if #itemsWithKey <= 0 then
			debug.profileend()
			return
		end

		local itemInfo = v10[inventoryType][p.Name]

		if not itemInfo then
			warn((`Failed to find info for {inventoryType}: "{p.Name}"`))
			return
		end

		debug.profilebegin("getFilteredItemKey")
		local filteredItemKey = v9:GetFilteredItemKey(inventoryType, p)
		debug.profileend()
		local maid2 = maid:Extend()
		local name = itemInfo.Name
		local v27 = string.gsub(name, ".", function(value)
			return (string.char(255 - string.byte(value)))
		end)
		local displayName = itemInfo.DisplayName or name
		local v28

		if displayName == name then
			v28 = v27
		else
			v28 = string.gsub(displayName, ".", function(value)
				return (string.char(255 - string.byte(value)))
			end)
		end

		local v29 = not itemInfo.Rarity and 0 or v6.RarityOrder[itemInfo.Rarity] or 0

		if name ~= "Base Sword" and name ~= "Explosion Normal" then
			v29 += 1
		end

		local isFavorited = state

		if useFavorites then
			local favoriteState = self:GetFavoriteState(inventoryType, name)
			isFavorited = v12.Computed(function(callback)
				return callback(useFavorites) and callback(favoriteState)
			end)
		end

		local createdAt = itemInfo.CreatedAt
		local state2 = v12.State(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRAP()
			state2:Set(v9:IsEnabled() and v9:FastGetRAP(inventoryType, p, filteredItemKey) or v9:ShouldShowRAP(
				inventoryType,
				name
			) and 0 or -1)
		end

		maid2:Add(task.spawn(function()
			v.Client:WaitReplion("ItemRAP")
			maid2:Add(v9:OnRAPUpdated(inventoryType, filteredItemKey, updateRAP))
		end))
		updateRAP() -- equivalent call inferred; original call site unknown
		local state3 = v12.State(-1)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateExistCounter()
			state3:Set(v8:IsEnabled(existCounterReplionChannel) and v8:Get(
				inventoryType,
				itemKey,
				true,
				existCounterReplionChannel
			) or -1)
		end

		maid2:Add(task.spawn(function()
			v.Client:WaitReplion(existCounterReplionChannel)
			maid2:Add(v8:OnUpdated(inventoryType, itemKey, updateExistCounter, existCounterReplionChannel))
			updateExistCounter() -- equivalent call inferred; original call site unknown
		end))
		local v31 = string.lower(displayName)
		local v32

		if data.GetVisibleState then
			v32 = data.GetVisibleState(inventoryType, p)
		else
			v32 = nil
		end

		local computed = v12.Computed(function(callback)
			local v33 = not searchFilter and "" or string.lower(callback(searchFilter))

			if not pageVisible or callback(pageVisible) or v33 ~= "" then
				return (v32 == nil or callback(v32)) and (#v33 <= 0 or v31 == v33 or string.sub(v31, 1, #v33) == v33 or string.find(
					v31,
					v33,
					1,
					true
				) ~= nil)
			else
				return false
			end
		end)
		local computed2 = v12.Computed(function(callback)
			local v33 = not sortOption and "Default" or callback(sortOption)
			local v34 = v16[not sortOrder2 and "Most" or callback(sortOrder2) or "Most"]
			local name2

			if v33 == "Alphabetical" then
				if v34 == 1 then
					name2 = v28
				else
					name2 = displayName
				end
			elseif v34 == 1 then
				name2 = v27
			else
				name2 = itemInfo.Name
			end

			return (`{(useFavorites == nil or callback(useFavorites)) and callback(isFavorited) and v33 == "Default" and "#" or ""}{p.TradeLock and "~" or ""}{v33 == "Alphabetical" and "" or v29}|{name2}`)
		end)
		local name3 = v12.Computed(function(callback)
			local v33 = callback(computed2)
			local v34 = not sortOption and "Default" or callback(sortOption)

			if type(v34) == "function" and sortMode and callback(sortMode) == "Name" then
				return v34(v33, inventoryType, p)
			end

			return v33
		end)
		local computed4 = v12.Computed(function(callback)
			local v33 = not sortOption and "Default" or callback(sortOption)

			if v33 == "RAP" then
				return callback(state2) * v16[sortOrder2 and callback(sortOrder2) or "Most"]
			elseif v33 == "Exists" then
				return callback(state3) * v16[sortOrder2 and callback(sortOrder2) or "Most"]
			elseif v33 == "Creation Date" then
				return (createdAt or 0) * v16[sortOrder2 and callback(sortOrder2) or "Most"]
			end

			return 0
		end)
		local layoutOrder = v12.Computed(function(callback)
			local v33 = callback(computed4)
			local v34 = not sortOption and "Default" or callback(sortOption)

			if type(v34) == "function" and sortMode and callback(sortMode) == "LayoutOrder" then
				return v34(v33, inventoryType, p)
			end

			return v33
		end)
		local v33 = {
			Name = name3,
			LayoutOrder = layoutOrder,
			IsFavorited = isFavorited,
			ItemsMatching = v12.State(itemsWithKey),
			Item = p,
			ItemKey = itemKey,
			ItemInfo = itemInfo,
			Trove = maid2
		}
		v24[itemKey] = v33
		maid2:Add(computed2:Connect(function()
			if sortOrder == Enum.SortOrder.Name then
				v23.Sort()
			end
		end))
		maid2:Add(layoutOrder:Connect(function()
			if sortOrder == Enum.SortOrder.LayoutOrder then
				v23.Sort()
			end
		end))
		local computed6 = v12.Computed(function(callback)
			if callback(computed) then
				v23.AddInstance(v33)
			else
				v23.RemoveInstance(v33)
			end

			return nil
		end)
		maid2:Add(function()
			v23.RemoveInstance(v33)
			v24[itemKey] = nil
			computed6:Destroy()
			layoutOrder:Destroy()
			computed4:Destroy()
			name3:Destroy()
			computed2:Destroy()
			computed:Destroy()

			if isFavorited ~= state then
				isFavorited:Destroy()
			end
		end)
		debug.profileend()
	end

	local function onChange(p, p2, p3)
		if p2 == "Insert" then
			createSlot(p)
		elseif p2 == "Remove" then
			if not tryRemoveSlot(p) then
				updateSlot(p)
			end
		elseif p2 == "Change" then
			createSlot(p)

			if p3 and not tryRemoveSlot(p3) then
				updateSlot(p3)
			end
		end
	end

	local v25 = v5:Get(caller, inventoryType)

	if v25 then
		for _, v26 in v25 do
			createSlot(v26)
		end
	end

	local v26 = (data.WatchOnChange == nil or data.WatchOnChange == true) and v5:OnChange(
		caller,
		inventoryType,
		onChange
	)

	if v26 then
		maid:Add(v26)
	end

	maid:Add(v12.setPropertyComputed(v20, "SortOrder", function(callback)
		local v27 = not sortOption and "Default" or callback(sortOption)
		local v28

		if v27 == "Default" or v27 == "Alphabetical" then
			v28 = Enum.SortOrder.Name
		else
			v28 = Enum.SortOrder.LayoutOrder
		end

		sortOrder = v28
		return sortOrder
	end))
	return {
		TriggerUpdate = onChange,
		Destroy = function()
			maid:Destroy()
		end
	}
end

function InventoryController.Start(_)
	v18 = v.Client:WaitReplion("Data")
end

return InventoryController