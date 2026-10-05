local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local itemSelected = localPlayer.MenuDestination.InventoryOption.ItemSelected
local idSelected = itemSelected.IdSelected
local data = Utility.GetData(localPlayer, true)
local Item = require(script.Item)
local CircleButton = require(ReplicatedStorage.CAM.Client.Components.Misc.Buttons.CircleButton)
local SelectModeHandler = require(script.SelectModeHandler)
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local MenuConfig = require(ReplicatedStorage.CAM.Client.Components.Layout.NoneResetting.Menu.MenuConfig)
local ItemEquipepdFrame = require(script.ItemEquipepdFrame)
local Menum = require(ReplicatedStorage.CAM.Global.Menum)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local v = {}
local v2 = {}
local miscEquippedBaitId = DataValue.new("Misc/EquippedBaitId", 0)
local Searchbar = require(ReplicatedStorage.CAM.Client.Components.Misc.Utilities.Searchbar)
require(ReplicatedStorage.Packages.faye)
local v3 = {}
local itemSearchbar = localPlayer.MenuDestination.InventoryOption.ItemSearchbar
local Loadouts = require(script.Loadouts)
local CategoryBrowser = require(ReplicatedStorage.CAM.Client.Components.Misc.CategoryBrowser)
local ClassFilter = require(ReplicatedStorage.CAM.Client.Components.Misc.ClassFilter)
local ItemViewer = require(script.ItemViewer)

local function heldEntries()
	return Utility.HeldEntries(data)
end

local function equippedIds()
	local v4 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function add(value)
		if type(value) == "number" and value ~= 0 then
			v4[value] = true
		end
	end

	for _, child in data.Inventory.Toolbar:GetChildren() do
		add(child.Value) -- equivalent call inferred; original call site unknown
	end

	for _, child in data.Inventory.Accessories.Stats:GetChildren() do
		add(child.Value) -- equivalent call inferred; original call site unknown
	end

	for _, child in data.Inventory.Accessories.Vanity:GetChildren() do
		add(child.Value) -- equivalent call inferred; original call site unknown
	end

	add(miscEquippedBaitId:Get()) -- equivalent call inferred; original call site unknown
	return v4
end

return function(maid, p)
	local v4 = {
		Enabled = maid:Value(false),
		Selected = maid:Value({})
	}
	local value = maid:Value(false)
	local value2 = maid:Value(false)
	local v5 = {}
	local value3 = maid:Value({})
	local v6 = {}
	local v7 = 1
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function feedTiles()
		if flag then
			return
		end

		flag = true
		maid:Spawn(function()
			while v7 <= #v6 do
				for _ = 1, 20 do
					local v8 = v6[v7]

					if v8 == nil then
						break
					end

					v7 += 1
					local v9 = v5[v8]

					if v9 ~= nil then
						value3:Add(v8, v9)
					end
				end

				if v7 > #v6 then
					break
				else
					task.wait()
				end
			end

			table.clear(v6)
			v7 = 1
			flag = false
		end)
	end

	local function refreshTiles()
		for k in value3:Get() do
			if v5[k] == nil then
				value3:Remove(k)
			end
		end

		table.clear(v6)
		v7 = 1

		for k in v5 do
			table.insert(v6, k)
		end

		feedTiles() -- equivalent call inferred; original call site unknown
	end

	local value4 = maid:Value(UDim2.new(1, -10, 1, -10))
	local canvasSize = maid:Value(UDim2.fromScale(0, 0))
	local value6 = maid:Value("All")
	local value7 = maid:Value(ClassFilter.ALL)
	local v8 = equippedIds()
	local v9 = {}
	local v10 = {}
	local v11 = {}
	local counts = {
		All = 0,
		Equipped = 0
	}
	local v13 = {}

	for _, v14 in Utility.HeldEntries(data) do
		local item = Items[v14.Name]

		if not (item ~= nil and item.InventoryCategory ~= nil) then
			continue
		end

		if table.find(v9, item.InventoryCategory) == nil then
			table.insert(v9, item.InventoryCategory)
		end

		if not v10[v14.Name] then
			v10[v14.Name] = true
			counts[item.InventoryCategory] = (counts[item.InventoryCategory] or 0) + 1
			counts.All += 1
			ClassFilter.Tally(v13, v14.Name)
		end

		local id = v14:FindFirstChild("Id")

		if id == nil or not v8[id.Value] or v11[v14.Name] then
			continue
		end

		v11[v14.Name] = true
		counts.Equipped += 1
	end

	table.sort(v9)
	table.insert(v9, 1, "All")
	table.insert(v9, 2, "Equipped")
	local value8 = maid:Value(nil)

	local function fn()
		local v14, value9

		if value2:Compare(true) then
			v14 = Character_info_provider.GetItemFromId(localPlayer, idSelected.Value)

			if v14 ~= nil and v14.Name ~= itemSelected.Value then
				v14 = nil
			end

			if v14 == nil then
				if idSelected.Value ~= 0 then
					idSelected.Value = 0
				end

				if idSelected.ItemName.Value ~= "" then
					idSelected.ItemName.Value = ""
				end
			end

			value9 = idSelected.Value
		else
			v14 = Utility.HeldItem(data, itemSelected.Value)

			if v14 == nil and value2:Compare(false) then
				v14 = Character_info_provider.GetItemFromId(localPlayer, idSelected.Value)
				value9 = idSelected.Value
			else
				value9 = v14.Id.Value
			end
		end

		itemSelected.ItemId.Value = value9
		value8:Set(v14)
	end

	local function updateItems()
		local inventoryRepsExceeds = MenuConfig.inventoryRepsExceeds(
			Utility.ItemBag(data, itemSelected.Value) or data.Inventory.Inventory,
			itemSelected.Value
		)
		table.clear(v5)
		table.clear(v3)
		local v14 = false

		if inventoryRepsExceeds == false then
			v14 = true
			local v15

			if value6:Get() == "Equipped" then
				v15 = equippedIds()
			end

			for _, v16 in Utility.HeldEntries(data) do
				if Items[v16.Name] == nil then
					continue
				end

				local v17 = string.gsub(v16.Name, "_", " ")

				if table.find(v3, v17) == nil then
					table.insert(v3, v17)
				end

				if not (itemSearchbar.Value == "" or string.lower(itemSearchbar.Value) == string.lower((string.sub(
					v17,
					0,
					#itemSearchbar.Value
				)))) then
					continue
				end

				if v15 == nil then
					if value6:Get() ~= "All" and Items[v16.Name].InventoryCategory ~= value6:Get() then
						continue
					end
				elseif not v15[v16.Id.Value] then
					continue
				end

				if not (value7:Get() == ClassFilter.ALL or Items[v16.Name].Class == value7:Get()) then
					continue
				end

				if v5[v16.Name] == nil then
					v5[v16.Name] = {
						Name = v16.Name,
						Amount = v16:FindFirstChild("Amount") == nil and 1 or v16.Amount.Value or 1,
						DestinctAmount = 1,
						ItemId = v16.Id.Value,
						RefineLevel = v16:FindFirstChild("RefineLevel") == nil and 0 or v16.RefineLevel.Value or 0
					}
				else
					v5[v16.Name].DestinctAmount += 1
					v5[v16.Name].Amount += v16:FindFirstChild("Amount") == nil and 1 or v16.Amount.Value or 1
				end
			end
		else
			for _, v15 in Utility.HeldEntries(data) do
				if not (Items[v15.Name] ~= nil and v5[v15.Id.Value] == nil and v15.Name == itemSelected.Value) then
					continue
				end

				v5[v15.Id.Value] = {
					Name = v15.Name,
					Id = v15.Id.Value,
					Amount = v15:FindFirstChild("Amount") == nil and 1 or v15.Amount.Value or 1,
					DestinctAmount = 1,
					RefineLevel = v15:FindFirstChild("RefineLevel") == nil and 0 or v15.RefineLevel.Value or 0
				}
			end
		end

		local v15 = {}

		for _, v16 in v5 do
			table.insert(v15, v16)
		end

		table.sort(v15, function(a, b)
			local rarity = Items[a.Name].Rarity or 0
			local rarity2 = Items[b.Name].Rarity or 0

			if rarity ~= rarity2 then
				return rarity < rarity2
			end

			if a.Name == b.Name then
				return (a.Id or a.ItemId or 0) < (b.Id or b.ItemId or 0)
			end

			return a.Name < b.Name
		end)

		for k, v16 in v15 do
			v16.Order = k
		end

		value:Set(v14)
		value2:Set(inventoryRepsExceeds)
		refreshTiles()
	end

	updateItems()
	maid:Connect(itemSelected.Changed, function(p2)
		if v5 == nil or v5[p2] == nil or not (v5[p2].Amount > 1) then
			if value2:Compare(true) then
				updateItems()
			end
		elseif value2:Compare(false) then
			updateItems()
		end

		fn()
	end)
	fn()
	maid:Connect(idSelected.Changed, function()
		if value2:Compare(true) then
			fn()
		end
	end)
	maid:Connect(itemSearchbar:GetPropertyChangedSignal("Value"), updateItems)
	maid:Connect(value6.Changed, updateItems)
	maid:Connect(value7.Changed, updateItems)

	local function refreshEquippedTab()
		if value6:Get() == "Equipped" then
			updateItems()
		end
	end

	for _, child in data.Inventory.Toolbar:GetChildren() do
		maid:Connect(child.Changed, refreshEquippedTab)
	end

	for _, child in data.Inventory.Accessories.Stats:GetChildren() do
		maid:Connect(child.Changed, refreshEquippedTab)
	end

	for _, child in data.Inventory.Accessories.Vanity:GetChildren() do
		maid:Connect(child.Changed, refreshEquippedTab)
	end

	maid:Add(miscEquippedBaitId.Changed:Connect(refreshEquippedTab))

	for _, v14 in Utility.ItemBags(data) do
		maid:Connect(v14.ChildAdded, updateItems)
		maid:Connect(v14.ChildRemoved, updateItems)
	end

	local connections = {}

	local function watchAmounts()
		for _, connection in connections do
			maid:Remove(connection)
			connection:Disconnect()
		end

		table.clear(connections)

		for _, v14 in Utility.HeldEntries(data) do
			local amount = v14:FindFirstChild("Amount")

			if amount ~= nil and amount:IsA("ValueBase") then
				table.insert(connections, maid:Connect(amount.Changed, updateItems))
			end
		end
	end

	for _, v14 in Utility.ItemBags(data) do
		maid:Connect(v14.ChildAdded, watchAmounts)
		maid:Connect(v14.ChildRemoved, watchAmounts)
	end

	watchAmounts()
	local springInfo = maid.SpringInfo(0.4, 1, 0.6)
	local value9 = maid:Value(UDim2.fromScale(0.5, 0.45))
	local v14 = 0
	local value10 = maid:Value(true)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateEq(_)
		if v14 ~= 1 then
			value10:Set(true)
			value9:Set(UDim2.fromScale(0.5, 0.45))
			v14 = 1
		end
	end

	value8.Changed:Connect(updateEq)
	value8:Get()
	updateEq() -- equivalent call inferred; original call site unknown
	local space = maid:Space(function(state, data2, object, object2, object3, object4, object5, object6, object7, object8, object9, p2)
		local v15 = nil
		local item = v4.Selected:GetItem(data2.Name)
		local v16

		if not v4.Enabled:Compare(true) then
			v16 = 0
		elseif item == nil then
			v16 = 2
		elseif item[data2.Id or data2.ItemId] == nil and (not (item.Count > 0) or data2.Id ~= nil) then
			v16 = 2
		else
			v16 = 1
		end

		object:Set(v16 == 0)

		if v16 == 0 then
			if Items[data2.Name].EquipType == Menum.ItemEquipType.Accessory or Items[data2.Name].EquipType == Menum.ItemEquipType.Costume or Items[data2.Name].EquipType == Menum.ItemEquipType.Clothing then
				local v17 = {
					Vanity = false,
					Stats = false
				}

				if data2.Folder then
					for _, child in ipairs(data.Inventory.Accessories.Stats:GetChildren()) do
						if child.Value == 0 then
							continue
						end

						local item2 = Character_info_provider.GetItemFromId(localPlayer, child.Value)

						if not (item2 ~= nil and item2.Name == data2.Name) then
							continue
						end

						v17.Stats = true
						break
					end

					for _, child in ipairs(data.Inventory.Accessories.Vanity:GetChildren()) do
						if child.Value == 0 then
							continue
						end

						local item2 = Character_info_provider.GetItemFromId(localPlayer, child.Value)

						if not (item2 ~= nil and item2.Name == data2.Name) then
							continue
						end

						v17.Vanity = true
						break
					end
				else
					for _, child in ipairs(data.Inventory.Accessories.Stats:GetChildren()) do
						if child.Value ~= data2.ItemId then
							continue
						end

						v17.Stats = true
						break
					end

					for _, child in ipairs(data.Inventory.Accessories.Vanity:GetChildren()) do
						if child.Value ~= data2.ItemId then
							continue
						end

						v17.Vanity = true
						break
					end
				end

				if v17.Vanity or v17.Stats then
					v15 = v17
				end
			elseif Items[data2.Name].EquipType == Menum.ItemEquipType.Bait then
				local v17 = miscEquippedBaitId:Get()

				if v17 ~= 0 and (data2.Id or data2.ItemId) == v17 then
					v15 = "Bait"
				end
			elseif data2.Folder then
				local count = 0

				for k, v17 in pairs(v2) do
					if v17 ~= data2.Name then
						continue
					end

					count += 1
					local v18 = v15 == nil and "" or v15

					if count == 1 then
						v15 = v18 .. k
					else
						v15 = v18 .. "," .. k
					end
				end
			else
				local count = 0

				for k, v17 in pairs(v) do
					if v17 ~= (data2.Id or data2.ItemId) then
						continue
					end

					count += 1
					local v18 = v15 == nil and "" or v15

					if count == 1 then
						v15 = v18 .. k
					else
						v15 = v18 .. "," .. k
					end
				end
			end
		end

		object9:Set(v15)
		local v17 = not data2.Folder

		if v17 then
			if data2.Amount > 1 and item ~= nil and item[data2.Id or data2.ItemId] ~= nil then
				v17 = v16 == 1 and state.In and not data2.Folder

				if not v17 then
					if v16 == 1 or v16 == 2 then
						v17 = p2.Value > 1
					else
						v17 = false
					end
				end
			else
				v17 = false
			end
		end

		object8:Set(v17)
		local lastState

		if v16 == 0 then
			lastState = (value2:Compare(true) and idSelected.Value == data2.Id or value2:Compare(false) and (itemSelected.Value == data2.Name or data2.Name == idSelected.ItemName.Value)) and 1 or state.In == true and 2 or 3
		else
			lastState = v16 == 1 and 4 or 5
		end

		if lastState ~= state.LastState then
			if lastState == 4 or lastState == 5 then
				object5:Reset()

				if lastState == 4 then
					object6:Reset()
					object2:Reset()
					object7:Reset()
					object3:Set(0.5)
					object4:Set(0.25)
				else
					object6:Set(0.75)
					object7:Set(0.5)
					object2:Set(0.75)
					object3:Set(0.9)
					object4:Set(0.9)
				end
			else
				object6:Reset()
				object6:Reset()
				object7:Reset()
				object5:Set(state.RarityColor)

				if lastState == 1 then
					object2:Set(0.25)
					object3:Set(0.1)
					object4:Set(0.15)
				elseif lastState == 2 then
					object2:Set(0.25)
					object3:Set(0.185)
					object4:Reset()
				else
					object4:Reset()
					object2:Reset()
					object3:Reset()
				end
			end

			state.LastState = lastState
		end
	end)
	space:Connect(value2.Changed)
	space:Connect(itemSelected:GetPropertyChangedSignal("Value"))
	space:Connect(idSelected:GetPropertyChangedSignal("Value"))
	math.random(1, 9999)

	for _, child in ipairs(data.Inventory.Toolbar:GetChildren()) do
		v[child.Name] = child.Value
		v2[child.Name] = Character_info_provider.GetItemNameOnSlot(localPlayer.Name, child.Name)
		local v15 = child
		maid:Connect(child.Changed, function()
			v[v15.Name] = v15.Value
			v2[v15.Name] = Character_info_provider.GetItemNameOnSlot(localPlayer.Name, v15.Name)
			space:Call()
		end)
	end

	for _, child in ipairs(data.Inventory.Accessories.Stats:GetChildren()) do
		maid:Connect(child.Changed, function()
			space:Call()
		end)
	end

	for _, child in ipairs(data.Inventory.Accessories.Vanity:GetChildren()) do
		maid:Connect(child.Changed, function()
			space:Call()
		end)
	end

	maid:Add(miscEquippedBaitId.Changed:Connect(function()
		space:Call()
	end))
	maid:Connect(v4.Selected.Changed, function(_)
		space:Call()
	end)
	maid:Connect(v4.Enabled.Changed, function(p2)
		if p2 ~= true then
			v4.Selected:Set({})
			return
		end

		local v15 = value8:Get()

		if v15 == nil or Items[v15.Name] == nil or (Items[v15.Name].NoDelete == true or Items[v15.Name].NoDiscard == true) then
			return
		end

		local value11 = v15:FindFirstChild("Id") ~= nil and v15.Id.Value or itemSelected.ItemId.Value

		if value11 == nil or value11 == 0 then
			return
		end

		local item = v4.Selected:GetItem(v15.Name)

		if item == nil then
			v4.Selected:Add(v15.Name, {
				[value11] = 1,
				Count = 1
			})
		elseif item[value11] == nil then
			item.Count += 1
			item[value11] = 1
			v4.Selected:Refresh()
		end
	end)
	space:Connect(v4.Enabled.Changed)
	local children = {}

	for i, child in data.ItemLoadouts:GetChildren() do
		if child.Name ~= "Counter" then
			children[i] = child
		end
	end

	local value11 = maid:Value(children)
	maid:Connect(data.ItemLoadouts.ChildAdded, function(p2)
		value11 += p2
	end)
	return maid:Create("Frame")({
		Name = "CharactersMain",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(0.44, 0.75),
		Position = maid:Animation(value9, springInfo),
		maid:Create("UIAspectRatioConstraint")({
			AspectRatio = 1
		}),
		BackgroundTransparency = 1,
		maid:Create("Frame")({
			Name = "SearchbarHolder",
			Size = UDim2.fromScale(0.3, 0.05),
			Position = UDim2.fromScale(0, -0.015),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			maid:State(function(callback, p2)
				if callback(value) then
					return Searchbar(p2, v3, itemSearchbar)
				end
			end)
		}),
		CategoryBrowser(maid, p, value6, v9, {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.fromScale(-0.05, 0),
			Size = UDim2.fromScale(0.35, 0.5),
			TabHeight = 0.12,
			Counts = counts
		}),
		maid:State(function(callback, p2)
			if callback(value) then
				return ClassFilter.Pick(p2, value7, v13, 0.05)
			end

			return nil
		end),
		ItemViewer(maid, p, value8),
		maid:Create("Frame")({
			maid:Create("UIListLayout")({
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Right,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0.15)
			}),
			Name = "SelectModeButtons",
			Size = UDim2.fromScale(0.1, 0.035),
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, -0.015),
			BackgroundTransparency = 1,
			SelectModeHandler(maid, v4)
		}),
		maid:State(function(callback, object)
			if callback(value10) ~= true or callback(v4.Enabled) == true then
				return
			end

			local animation = object:Animation(UDim2.fromScale(1, 0.165), springInfo, {
				From = UDim2.fromScale(0.8, 0.132)
			})
			return object:Create("Frame")({
				Position = UDim2.fromScale(0.5, 1.01),
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = 1,
				Size = animation,
				OnClean = function(object2, p2)
					if animation ~= nil and animation.Destroy then
						animation:Destroy()
					end

					object2:Configure(p2)({
						Size = object2:Animation(UDim2.fromScale(0, 0), object2.Info(0.1))
					})
				end,
				ItemEquipepdFrame(object, p, value8, itemSelected.ItemId)
			})
		end),
		maid:State(function(callback, object)
			if callback(value2) == true then
				return object:Create("Frame")({
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromOffset(0, -5) + UDim2.fromScale(0.035, -0.035),
					Size = object:Animation(UDim2.fromScale(0.07, 0.07), object.SpringInfo(0.25, 1, 0.6), {
						From = UDim2.fromScale(0.035, 0.035)
					}),
					BackgroundTransparency = 1,
					CleanDelay = 0.1,
					CleanFunction = function(object2, p2)
						object2:Configure(p2)({
							Size = object2:Animation(UDim2.fromScale(0, 0), object2.Info(0.2))
						})
					end,
					CircleButton(object, {
						Image = "rbxassetid://140427393388249",
						Clicked = function()
							itemSelected.Value = ""
						end
					})
				})
			end
		end),
		maid:Create("ScrollingFrame")({
			Name = "CharHolder",
			CanvasSize = canvasSize,
			ScrollBarThickness = 0,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			maid:Create("UIStroke")({
				Color = Color3.new(1, 1, 1),
				maid:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.75),
						NumberSequenceKeypoint.new(0.4, 0.92),
						NumberSequenceKeypoint.new(1, 0.99)
					}),
					Rotation = 90
				})
			}),
			maid:Create("UICorner")({
				CornerRadius = UDim.new(0.0225)
			}),
			maid:Create("Frame")({
				Name = "ActualHolder",
				Size = maid:Animation(value4, maid.SpringInfo(0.35, 1, 0.65), {
					AlwaysFrom = UDim2.new(0.885, -10, 0.885, -10)
				}),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				maid:Create("UICorner")({
					CornerRadius = UDim.new(0.0225)
				}),
				BackgroundColor3 = Color3.new(0.25, 0.25, 0.25),
				maid:Create("UIGradient")({
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.4, 0.7),
						NumberSequenceKeypoint.new(1, 0.9)
					}),
					Rotation = 90
				}),
				BackgroundTransparency = 1,
				maid:Create("UIListLayout")({
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					Wraps = true,
					Padding = UDim.new(0.012945),
					AbsoluteContentSizeOnChangedInit = function(p2)
						canvasSize:Set(UDim2.fromOffset(0, p2.AbsoluteContentSize.Y + 50))
					end
				}),
				maid:AdvancedIterate(value3, function(_, p2, p3)
					return Item(p3, p2, value2, idSelected, itemSelected, v4, space)
				end)
			})
		}),
		Loadouts(maid, value11)
	})
end