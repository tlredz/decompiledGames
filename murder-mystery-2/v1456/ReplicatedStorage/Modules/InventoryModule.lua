local InventoryModule = {
	GUI = {},
	MyInventory = {}
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Sync = require(ReplicatedStorage:WaitForChild("Database"):WaitForChild("Sync"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local WindowService = require(ReplicatedStorage2:WaitForChild("Modules"):WaitForChild("WindowService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage3:WaitForChild("Modules"):WaitForChild("ProfileData"))
local v = {
	"Weapons",
	"Effects",
	"Perks",
	"Emotes",
	"Radios",
	"Pets"
}
local v2 = {
	Weapons = true,
	Pets = true
}
local v3 = {
	Christmas = true,
	Halloween = true
}
local rarities = Sync.Rarities
local ItemModule = require(game.ReplicatedStorage.Modules.ItemModule)

function InventoryModule.CreateBlankInventoryTable()
	return {
		Weapons = {
			Current = {},
			Classic = {},
			Christmas = {},
			Halloween = {}
		},
		Effects = {
			Current = {}
		},
		Perks = {
			Current = {}
		},
		Emotes = {
			Current = {}
		},
		Radios = {
			Current = {}
		},
		Pets = {
			Current = {}
		}
	}
end

function InventoryModule.CreateBlankTradeInventoryTable()
	return {
		Weapons = {
			Current = {}
		},
		Pets = {
			Current = {}
		}
	}
end

function InventoryModule.CreateBlankInventorySort(items)
	local result = {}

	for k, _ in pairs(items) do
		result[k] = {}

		for k2, _ in pairs(items[k]) do
			result[k][k2] = {}
		end
	end

	return result
end

function InventoryModule.CreateBlankInventory(p)
	local v4 = {
		Data = p == "Trading" and InventoryModule.CreateBlankTradeInventoryTable() or InventoryModule.CreateBlankInventoryTable()
	}
	v4.Sort = InventoryModule.CreateBlankInventorySort(v4.Data)
	return v4
end

function InventoryModule.CreateNewItemData(dataID, amount, dataType)
	local v4

	if dataType == "Emotes" or dataType == "Toys" then
		v4 = Sync.Emotes[dataID] or Sync.Toys[dataID]
	else
		v4 = Sync[dataType][dataID]
	end

	if v4 == nil then
		print("ERROR LOADING ITEM: " .. dataID, dataType, amount)
		return
	end

	local result = {}

	for k, v5 in pairs(v4) do
		result[k] = v5
	end

	result.Name = v4.ItemName or v4.Name
	result.Amount = amount
	result.DataID = dataID
	result.DataType = dataType

	if result.Rarity == nil then
		result.Rarity = "Common"
	end

	result.Frame = nil
	result.LayoutOrder = 0
	return result
end

local function GetTab(p, p2, p3)
	if p3 == "Trading" then
		return "Current"
	end

	if p2 == nil then
		return "Weapons"
	end

	local event = p2.Event

	if p == "Weapons" and event then
		if event == "Christmas" or event == "Halloween" then
			return event
		end
	else
		if p2.Season then
			return "Current"
		end

		if p == "Weapons" then
			return "Classic"
		end
	end

	return "Current"
end

function InventoryModule.GenerateInventoryTables(p, p2)
	local blankInventory = InventoryModule.CreateBlankInventory(p2)

	for k, _ in pairs(blankInventory.Data) do
		for k2, v4 in pairs(p[k].Owned) do
			local v5

			if v2[k] then
				v5 = k2 or v4
			else
				v5 = v4
			end

			local v6 = tonumber(v4) or 1
			local newItemData = InventoryModule.CreateNewItemData(v5, v6, k)

			if not newItemData then
				continue
			end

			local v7

			if p2 == "Trading" then
				v7 = "Current"
			elseif newItemData == nil then
				v7 = "Weapons"
			else
				local event = newItemData.Event

				if k == "Weapons" and event then
					v7 = event ~= "Christmas" and event ~= "Halloween" and "Current" or event
				else
					v7 = newItemData.Season and "Current" or k == "Weapons" and "Classic" or "Current"
				end
			end

			blankInventory.Data[k][v7][v5] = newItemData
			table.insert(blankInventory.Sort[k][v7], v5)
		end
	end

	for _, v4 in pairs(p.Uniques or {}) do
		local baseItem = v4.BaseItem

		if v4.EvoEquipped then
			local weapon = Sync.Weapons[v4.BaseItem]
			local _ = v4.XP >= weapon.Evo[1].XPRequired
			local v6 = v4.XP >= weapon.Evo[2].XPRequired and 2 or 1
			local v7 = v4.XP >= weapon.Evo[3].XPRequired and 3 or v6
			local v8 = v4.XP >= weapon.Evo[4].XPRequired and 4 or v7
			baseItem = weapon.Evo[v8].ItemName
		end

		local newItemData = InventoryModule.CreateNewItemData(baseItem, 1, "Weapons")
		newItemData.Signature = v4.Signature or ""
		newItemData.Rank = v4.Rank
		newItemData.EvoXP = v4.XP
		newItemData.EvoEquipped = v4.EvoEquipped
		local v5

		if p2 == "Trading" then
			v5 = "Current"
		elseif newItemData == nil then
			v5 = "Weapons"
		else
			local event = newItemData.Event

			if event then
				v5 = event ~= "Christmas" and event ~= "Halloween" and "Current" or event
			else
				v5 = newItemData.Season and "Current" or "Classic"
			end
		end

		blankInventory.Data.Weapons[v5][baseItem] = newItemData
		table.insert(blankInventory.Sort.Weapons[v5], baseItem)
	end

	return blankInventory
end

function InventoryModule.SortTab(p, p2, p3)
	for k, v4 in pairs(p.Sort[p2][p3]) do
		if p.Data[p2][p3][v4] == nil then
			table.remove(p.Sort[p2][p3], k)
		end
	end

	local v4 = p.Sort[p2][p3]
	table.sort(v4, function(a, b)
		local v5 = p.Data[p2][p3][a]
		local v6 = p.Data[p2][p3][b]
		local sort = rarities[v5.Rarity].Sort
		local sort2 = rarities[v6.Rarity].Sort

		if v5.DataID == "DefaultKnife" then
			return true
		end

		if not (v6.DataID ~= "DefaultKnife" and v6.DataID ~= "DefaultGun") then
			return false
		end

		if v5.DataID == "DefaultGun" and v6.DataID ~= "DefaultKnife" then
			return true
		end

		if v5.Rarity ~= v6.Rarity then
			return sort < sort2
		end

		if v5.SortGroup and v6.SortGroup == nil then
			return true
		end

		if v6.SortGroup and v5.SortGroup == nil then
			return false
		end

		if v5.SortGroup and v6.SortGroup and v5.SortGroup ~= v6.SortGroup then
			return v5.SortGroup < v6.SortGroup
		end

		if v5.SortGroup and v6.SortGroup and v5.SortGroup == v6.SortGroup then
			return v5.SortWithinGroup < v6.SortWithinGroup
		end

		return v5.Name < v6.Name
	end)

	for k, v5 in pairs(p.Sort[p2][p3]) do
		p.Data[p2][p3][v5].LayoutOrder = k

		if p.Data[p2][p3][v5].Frame ~= nil then
			p.Data[p2][p3][v5].Frame.LayoutOrder = k
		end
	end

	return p
end

function InventoryModule.SortInventory(p)
	for k, v4 in pairs(p.Sort) do
		for k2, _ in pairs(v4) do
			p = InventoryModule.SortTab(p, k, k2)
		end
	end

	return p
end

function InventoryModule.GenerateNewInventoryFrames(p, instance, p2)
	for childName, v4 in pairs(p.Data) do
		for childName2, v5 in pairs(v4) do
			local v6 = instance:FindFirstChild(childName).Items.Container:FindFirstChild(childName2) or instance:FindFirstChild(childName).Items.Container:FindFirstChild("Holiday").Container:FindFirstChild(childName2)
			local itemSizer = v6:FindFirstChild("ItemSizer") or v6.Parent.Parent:FindFirstChild("ItemSizer")
			local Y

			if itemSizer then
				Y = itemSizer.AbsoluteSize.Y
			end

			if v3[childName2] then
				local clone = (p2 or InventoryModule.GUI.ItemGridLayout or script.ItemGridLayout):Clone()
				clone.Parent = v6.Container
				local v7 = v6
				clone:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					v7.Size = UDim2.new(1, 0, 0, clone.AbsoluteContentSize.Y + 5 + 44)
				end)

				if Y then
					local cellSize = clone.CellSize
					clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, Y)
				end
			else
				local clone = (p2 or InventoryModule.GUI.ItemGridLayout or script.ItemGridLayout):Clone()
				clone.Parent = v6.Container
				local v7 = v6
				clone:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					v7.CanvasSize = UDim2.new(0, 0, 0, clone.AbsoluteContentSize.Y + 5)
				end)

				if Y then
					local cellSize = clone.CellSize
					clone.CellSize = UDim2.new(cellSize.X.Scale, cellSize.X.Offset, 0, Y)
				end
			end

			for k, v7 in pairs(v5) do
				if v7.Frame ~= nil then
					continue
				end

				local clone = script.NewItem:Clone()
				ItemModule.DisplayItem(clone, v7, nil, true)
				clone.Parent = v6.Container
				clone.LayoutOrder = v7.LayoutOrder
				p.Data[childName][childName2][k].Frame = clone
			end
		end
	end

	return p
end

function InventoryModule.ConnectEquipButtons()
	for k, v4 in pairs(InventoryModule.MyInventory.Data) do
		for k2, v5 in pairs(v4) do
			for k3, v6 in pairs(v5) do
				local frame = v6.Frame

				if not (frame and v6.EquipConnection == nil) then
					continue
				end

				local v7 = v6
				local v8 = k
				InventoryModule.MyInventory.Data[k][k2][k3].EquipConnection = frame.Container.ActionButton.MouseButton1Click:connect(function()
					if v7.ItemType == "Misc" or (v8 == "Emotes" or v8 == "Toys") then
						return
					end

					if v8 == "Weapons" then
						local weapon = Sync.Weapons[v7.DataID]
						local evoBaseID = weapon.EvoBaseID

						if evoBaseID then
							local evo = Sync.Weapons[evoBaseID].Evo
							local evoMenu = InventoryModule.GUI.EvoMenu
							evoMenu.Container.TitleFrame.TitleLabel.Text = weapon.ItemName .. " Evo"
							local v9 = v7.EvoXP >= evo[1].XPRequired
							local v11 = v7.EvoXP >= evo[2].XPRequired and 2 or 1
							local v12 = v7.EvoXP >= evo[3].XPRequired and 3 or v11
							local v13 = v7.EvoXP >= evo[4].XPRequired and 4 or v12

							for k4, v14 in pairs(evo) do
								local child = InventoryModule.GUI.EvoMenu.Container.EvoContainer:FindFirstChild("Evo" .. k4)
								local weapon2 = Sync.Weapons[v14.ItemName]
								ItemModule.DisplayItem(child, weapon2, nil, true)
								child.ItemName.Label.Text = weapon2.Rarity
								child.Locked.Visible = v13 < k4
								child:SetAttribute("ItemID", v14.ItemName)
								child:SetAttribute("ItemType", v7.ItemType)
								child:SetAttribute("Locked", v13 < k4)
							end

							local v14 = v13 + 1

							if evo[v14] == nil then
								v14 = v13
							end

							evoMenu.Container.XPFrame.XPLabel.Text = ItemModule.Commafy((math.floor(v7.EvoXP))) .. " / " .. ItemModule.Commafy(evo[v14].XPRequired)
							local v15 = v7.EvoXP / evo[v14].XPRequired
							local v16 = v15 < 0 and 0 or v15 > 1 and 1 or v15
							evoMenu.Container.XPFrame.Background.XPBar.Size = UDim2.new(v16, 0, 1, 0)
							evoMenu.Visible = true
							return
						else
							ProfileData.Weapons.Equipped[v7.ItemType] = v7.DataID
						end
					else
						for k4, v9 in ProfileData[v8].Equipped do
							if v9 == v7.DataType then
								return
							end
						end

						table.insert(ProfileData[v8].Equipped, 1, v7.DataID)
						local count = #ProfileData[v8].Equipped

						if ProfileData[v8].Slots < count then
							table.remove(ProfileData[v8].Equipped, count)
						end
					end

					InventoryModule.UpdateEquip(InventoryModule.GUI.MyInventory.Main, InventoryModule.MyInventory)
					game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(v7.DataID, v7.DataType)
				end)
			end
		end
	end
end

function InventoryModule.ConnectEvoMenu()
	InventoryModule.GUI.EvoMenu.Container.Close.MouseButton1Click:connect(function()
		InventoryModule.GUI.EvoMenu.Visible = false
	end)

	for _, frame in pairs(InventoryModule.GUI.EvoMenu.Container.EvoContainer:GetChildren()) do
		if not frame:IsA("Frame") then
			continue
		end

		local v4 = frame
		frame.Container.Button.MouseButton1Click:connect(function()
			local itemID = v4:GetAttribute("ItemID")
			local itemType = v4:GetAttribute("ItemType")

			if v4:GetAttribute("Locked") ~= true then
				ProfileData.Weapons.Equipped[itemType] = itemID
				InventoryModule.UpdateEquip(InventoryModule.GUI.MyInventory.Main, InventoryModule.MyInventory)
				game.ReplicatedStorage.Remotes.Inventory.Equip:FireServer(itemID, "Weapons")
			end
		end)
	end
end

function InventoryModule.GenerateInventory(p, p2, p3, p4)
	local inventoryTables = InventoryModule.GenerateInventoryTables(p2, p3)
	local sortInventory = InventoryModule.SortInventory(inventoryTables)
	return (InventoryModule.GenerateNewInventoryFrames(sortInventory, p.Main, p4))
end

function InventoryModule.UpdateInventory(p, p2)
	for k, v4 in p2.Data do
		for k2, v5 in v4 do
			for k3, v6 in v5 do
				local amount = (v6.Rarity == "Unique" or v6.EvoEquipped) and 1 or ProfileData[k].Owned[k3]

				for _, v8 in ProfileData[k].Owned do
					if v8 == k3 then
						amount = 1
					end
				end

				if amount == nil or not (amount > 0) then
					p2.Data[k][k2][k3].Frame:Destroy()
					p2.Data[k][k2][k3] = nil
				else
					p2.Data[k][k2][k3].Amount = amount
					p2.Data[k][k2][k3].Frame.Container.Amount.Text = amount and amount > 1 and "x" .. amount or ""

					if v6.Rarity == "Unique" then
						p2.Data[k][k2][k3].Frame.Container.Amount.Text = v6.Rank and "#" .. v6.Rank or ""
					end
				end
			end
		end
	end

	local v4 = {}

	for _, v5 in v do
		for k, v6 in ProfileData[v5].Owned do
			local v7

			if v2[v5] then
				v7 = k or v6
			else
				v7 = v6
			end

			local v8 = tonumber(v6) or 1
			local v9 = Sync[v5][v7]

			if not v9 then
				continue
			end

			local v10

			if v9 == nil then
				v10 = "Weapons"
			else
				local event = v9.Event

				if v5 == "Weapons" and event then
					v10 = event ~= "Christmas" and event ~= "Halloween" and "Current" or event
				else
					v10 = v9.Season and "Current" or v5 == "Weapons" and "Classic" or "Current"
				end
			end

			if not (p2.Data[v5][v10][v7] == nil and v9.Rarity ~= "Unique") then
				continue
			end

			local newItemData = InventoryModule.CreateNewItemData(v7, v8, v5)
			local v11

			if v9 == nil then
				v11 = "Weapons"
			else
				local event = v9.Event

				if v5 == "Weapons" and event then
					v11 = event ~= "Christmas" and event ~= "Halloween" and "Current" or event
				else
					v11 = v9.Season and "Current" or v5 == "Weapons" and "Classic" or "Current"
				end
			end

			p2.Data[v5][v11][v7] = newItemData
			table.insert(p2.Sort[v5][v10], v7)
			v4[v5] = v10
		end
	end

	if v4 then
		local sortInventory = InventoryModule.SortInventory(p2)
		InventoryModule.GenerateNewInventoryFrames(sortInventory, p.Main)
		InventoryModule.ConnectEquipButtons()
	end
end

local v4 = {}

function InventoryModule.UpdateEquip(p, p2)
	for k, _ in pairs(p2.Data) do
		if not p[k]:FindFirstChild("Equipped") then
			continue
		end

		for _, child in pairs(p[k].Equipped.Container:GetChildren()) do
			if child:FindFirstChild("Container") then
				child.Container.Visible = false
			end
		end

		if k == "Effects" and ProfileData[k].Equipped[1] == nil then
			p.Effects.Equipped.Container.DeathEffect.Visible = false
		end

		for k2, v5 in ProfileData[k].Equipped do
			if k2 == "Misc" then
				continue
			end

			local container = p[k].Equipped.Container
			local v6

			if tonumber(k2) then
				v6 = "Item" .. k2 or k2
			else
				v6 = k2
			end

			local v7 = container[v6]
			local v8 = Sync[k][v5]

			if k == "Effects" and v8 ~= nil then
				p.Effects.Equipped.Container.DeathEffect.Visible = v8.DeathModule ~= nil or v8.DeathEffect ~= nil
				p.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = ProfileData.DeathEffect == true
				p.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = ProfileData.DeathEffect == false
			end

			if v8 ~= nil then
				ItemModule.DisplayItem(v7.Container, v8)
			end

			v7.Container.Visible = v8 ~= nil

			if not (p2 == InventoryModule.MyInventory and v7.Container:FindFirstChild("Unequip")) then
				continue
			end

			if v4[v7] then
				v4[v7]:disconnect()
				v4[v7] = nil
			end

			local v9 = k
			local v10 = k2
			v4[v7] = v7.Container.Unequip.Button.MouseButton1Click:connect(function()
				table.remove(ProfileData[v9].Equipped, v10)
				InventoryModule.UpdateMyEquip()
				game.ReplicatedStorage.Remotes.Inventory.Unequip:FireServer(v10, v9)
			end)
		end
	end

	local v5 = time()
	p.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.MouseButton1Click:connect(function()
		if time() - v5 < 1 then
			return
		end

		game.ReplicatedStorage.Remotes.Inventory.ToggleDeathEffects:FireServer(false)
		ProfileData.DeathEffect = false
		p.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = false
		p.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = true
		v5 = time()
	end)
	p.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.MouseButton1Click:connect(function()
		if time() - v5 < 1 then
			return
		end

		game.ReplicatedStorage.Remotes.Inventory.ToggleDeathEffects:FireServer(true)
		ProfileData.DeathEffect = true
		p.Effects.Equipped.Container.DeathEffect.Container2.EffectDisabled.Visible = false
		p.Effects.Equipped.Container.DeathEffect.Container2.EffectEnabled.Visible = true
		v5 = time()
	end)
end

function InventoryModule.UpdateMyEquip()
	InventoryModule.UpdateEquip(InventoryModule.GUI.MyInventory.Main, InventoryModule.MyInventory)
end

function InventoryModule.ConnectNavButtons(instance, instance2)
	local children = instance:GetChildren()

	for _, button in pairs(children) do
		if not button:IsA("TextButton") then
			continue
		end

		local v5 = button
		button.MouseButton1Click:connect(function()
			if v5.Name ~= "Close" then
				for k, button2 in pairs(children) do
					if button2:IsA("TextButton") then
						button2.Style = button2.Name == v5.Name and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
					end
				end

				for i, child in pairs(instance2:GetChildren()) do
					child.Visible = child.Name == v5.Name
				end
			end
		end)
	end
end

function InventoryModule.ConnectTabButtons(p, p2, p3, p4, _)
	local v5 = p3 or p.Main[p2]
	local v6 = p4 or v5.Items.Container
	local container = v5:FindFirstChild("TitleBar") and v5.TitleBar.Container or v5:FindFirstChild("Tabs") or v5.Items.Tabs
	local searchText = container.Search.Container.SearchText
	local children = container:GetChildren()

	for k, v7 in pairs(children) do
		if not v7:FindFirstChild("View") then
			children[k] = nil
		end
	end

	for _, v7 in pairs(children) do
		local name = v7.Name
		v7.View.MouseButton1Click:connect(function()
			searchText.Text = ""

			for k, v9 in pairs(children) do
				v9.ViewBorder.Visible = v9.Name == name
				v9.BackgroundTransparency = v9.Name == name and 0.8 or 0.9
			end

			for i, child in pairs(v6:GetChildren()) do
				child.Visible = child.Name == name
			end
		end)
	end
end

local v5 = nil

function InventoryModule.ConnectCodeFrame(p)
	p.CodeBox.Changed:connect(function()
		for k, _ in pairs(Sync.Codes) do
			local v6 = p.CodeBox.Text == k
			p.Redeem.Style = v6 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton

			if not v6 then
				continue
			end

			v5 = "Normal"
			return
		end

		p.CodeBox.Text = string.gsub(p.CodeBox.Text, "%s+", "")
		p.CodeBox.Text = string.gsub(p.CodeBox.Text, "~", "")
		local v6

		if string.len(p.CodeBox.Text) == 7 then
			v6 = string.sub(p.CodeBox.Text, 4, 4) == "-"
		else
			v6 = false
		end

		p.Redeem.Style = v6 and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
		v5 = v6 and "Shirt" or nil
	end)
	p.Redeem.MouseButton1Click:connect(function()
		InventoryModule.Redeem(p)
	end)
end

function InventoryModule.Redeem(p)
	if v5 ~= nil then
		local v6 = tostring(v5)
		local text = p.CodeBox.Text
		p.CodeBox.Text = "Redeeming..."
		p.Redeem.Style = Enum.ButtonStyle.RobloxRoundButton
		local text2, v8 = game.ReplicatedStorage.Remotes.Extras.RedeemCode:InvokeServer(text, v6)
		p.CodeBox.Text = text2

		if v8 then
			for _, v9 in pairs(v8) do
				_G.NewItem(v9.ID, "You Got...", WindowService:GetFrame("Inventory"), v9.Type)
			end
		end
	end
end

function InventoryModule.ConnectPetNaming(p)
	p.PetNameBox.Text = ProfileData.PetName
	p.Confirm.MouseButton1Click:connect(function()
		local text = p.PetNameBox.Text

		if string.len(text) <= 20 then
			ProfileData.PetName = text
			game.ReplicatedStorage.Remotes.Inventory.RenamePet:FireServer(text)
		else
			p.PetNameBox.Text = "Name too long"
		end
	end)
end

return InventoryModule