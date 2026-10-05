local parent = script.Parent.Parent
local inventory = parent.Inventory
local main = inventory.Main
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ProfileData"))
local processing = parent.Processing
local replicatedStorage = game.ReplicatedStorage
local remotes = replicatedStorage.Remotes
local radio = game.Players.LocalPlayer:GetAttribute("Radio")

-- equivalent calls inferred from this helper; original call sites unknown
local function GetImage(image)
	if _G.Cache[image] ~= nil then
		return _G.Cache[image]
	end

	local v

	if tonumber(image) then
		v = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. image or image
	else
		v = image
	end

	local v2 = v .. "&bust=" .. math.random(1, 10000)
	_G.Cache[image] = v2
	return v2
end

game:GetService("ContextActionService")
local DatabaseCompatability = require(script:WaitForChild("DatabaseCompatability"))
local rarity = DatabaseCompatability.Rarity
local v = {
	Classic = 1,
	Common = 2,
	Uncommon = 3,
	Rare = 4,
	Legendary = 5,
	Godly = 6,
	Victim = 7,
	Unique = 7,
	Christmas = 1.5,
	Halloween = 1.6,
	Ancient = 6.5
}
local v2 = {
	Weapons = nil,
	Effects = nil,
	Perks = nil,
	Emotes = nil,
	Radios = nil,
	Pets = nil
}
local v3 = {
	"Weapons",
	"Perks",
	"Effects",
	"Pets"
}
local v4 = {}
local CopyTable

CopyTable = function(items)
	local result = {}

	for k, item in pairs(items) do
		if type(item) == "table" then
			item = CopyTable(item)
		end

		result[k] = item
	end

	return result
end

local function CreateWeaponFrame(guiObject, p, p2, p3)
	local v5 = (guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton")) and guiObject or guiObject.Icon
	local v6 = p3 == "Item" and "Weapons" or p3

	if p == nil then
		v5.Image = ""
		guiObject.ItemName.Text = ""

		if guiObject:FindFirstChild("Amount") then
			guiObject.Amount.Text = ""
		end
	else
		local v7 = DatabaseCompatability[v6 or "Weapons"][p]
		local image = GetImage(v7.Image) -- equivalent call inferred; original call site unknown
		v5.Image = image
		guiObject.ItemName.Text = v7.ItemName or v7.Name
		guiObject.ItemName.TextColor3 = v7.Rarity and rarity[v7.Rarity] or Color3.new(1, 1, 1)

		if tonumber(p2) and guiObject:FindFirstChild("Amount") then
			guiObject.Amount.Text = "x" .. p2
		end

		if guiObject:FindFirstChild("Rarity") then
			guiObject.Rarity.Text = v7.Rarity or ""
			guiObject.Rarity.TextColor3 = rarity[v7.Rarity] or Color3.new(1, 1, 1)
		end
	end
end

local function SortData()
	for _, v5 in pairs(v3) do
		local copyTable = CopyTable(ProfileData[v5])

		if copyTable == nil then
			continue
		end

		table.sort(copyTable.Owned, function(a, b)
			return a < b
		end)
		v2[v5] = copyTable
	end

	for _, v5 in pairs({ "Weapons", "Pets" }) do
		local copyTable = CopyTable(ProfileData[v5])
		local owned = {}

		for k, amount in pairs(copyTable.Owned) do
			table.insert(owned, {
				ItemID = k,
				Amount = amount
			})
		end

		if v5 == "Weapons" then
			for _, unique in pairs(ProfileData.Uniques) do
				local baseItem = unique.BaseItem

				if unique.EvoEquipped then
					local v8 = 1

					for i = 1, 4 do
						if unique.XP >= DatabaseCompatability.Weapons[baseItem].Evo[i].XPRequired then
							v8 = i
						end
					end

					baseItem = DatabaseCompatability.Weapons[baseItem].Evo[v8].ItemName
				end

				table.insert(owned, {
					ItemID = baseItem,
					Amount = 1
				})
			end
		end

		local v8 = v5
		table.sort(owned, function(a, b)
			local v9 = { a.ItemID, b.ItemID }
			local v10 = { a.Amount, b.Amount }
			local v11 = { DatabaseCompatability[v8][v9[1]], DatabaseCompatability[v8][v9[2]] }
			local v12 = { v[v11[1].Rarity], v[v11[2].Rarity] }

			if v9[1] == "DefaultKnife" then
				return true
			end

			if v9[2] == "DefaultKnife" then
				return false
			end

			if v9[1] == "DefaultGun" then
				return true
			end

			if v9[2] == "DefaultGun" then
				return false
			end

			if v12[1] ~= v12[2] then
				return v12[1] > v12[2]
			end

			if v10[1] == v10[2] then
				return v11[1][v8 == "Weapons" and "ItemName" or "Name"] < v11[2][v8 == "Weapons" and "ItemName" or "Name"]
			end

			return v10[1] > v10[2]
		end)
		copyTable.Owned = owned
		v2[v5] = copyTable
	end
end

local function UpdateCrafting() end

local function CheckItemRecyclable(p)
	local v5 = v4[1]
	local weapon = DatabaseCompatability.Weapons[p]
	local v6 = false

	for _, v7 in pairs(DatabaseCompatability.Recyclable) do
		if v7 == p then
			v6 = true
		end
	end

	if not (v5 and v6) then
		return v6, "Can't Recycle"
	end

	local weapon2 = DatabaseCompatability.Weapons[v5]
	local itemType = weapon2.ItemType
	local rarity2 = weapon2.Rarity

	if weapon.Rarity == rarity2 and weapon.ItemType == itemType then
		local amount = 0

		for _, v8 in pairs(v2.Weapons.Owned) do
			if v8.ItemID ~= p then
				continue
			end

			amount = v8.Amount
			break
		end

		for _, v8 in pairs(v4) do
			if v8 == p then
				amount -= 1
			end
		end

		return amount > 0, "Not Enough"
	else
		local v7 = false

		if weapon.ItemType == itemType then
			return false, "Wrong Rarity"
		end

		return v7, "Wrong Type"
	end
end

local _ = {
	Common = "Uncommon",
	Uncommon = "Rare",
	Rare = "Legendary"
}

local function UpdateRecycling() end

local onEvent

for _, _ in pairs({
	{
		ItemID = nil,
		Amount = 0
	},
	{
		ItemID = nil,
		Amount = 0
	},
	{
		ItemID = nil,
		Amount = 0
	},
	{
		ItemID = nil,
		Amount = 0
	}
}) do

end

local function UpdateEquip()
	for _, v5 in pairs(v3) do
		if v5 == "Weapons" or not v2[v5].Equipped then
			for k, v6 in pairs(v2.Weapons.Equipped) do
				if k == "Misc" then
					continue
				end

				local equipped = k == "Knife" and main.Weapons.Equipped or main.Weapons.Equipped.Knife
				local weapon = DatabaseCompatability.Weapons[v6]
				local icon = equipped[k].Icon
				local image = GetImage(weapon.Image) -- equivalent call inferred; original call site unknown
				icon.Image = image
				equipped[k].ItemName.Text = weapon.ItemName
				equipped[k].ItemName.TextColor3 = rarity[weapon.Rarity]
			end
		else
			local equipped = main[v5].Equipped

			for k, v6 in pairs(v2[v5].Equipped) do
				local v7 = equipped["Slot" .. k]
				local image = GetImage(DatabaseCompatability[v5][v6].Image) -- equivalent call inferred; original call site unknown
				v7.Image = image
				v7.ItemName.Text = DatabaseCompatability[v5][v6].Name
				local v9 = v5
				local v10 = k
				v7.MouseButton1Click:connect(function()
					if DatabaseCompatability.SlotInfo[v9] and DatabaseCompatability.SlotInfo[v9].Unequip then
						table.remove(ProfileData[v9].Equipped, v10)
						onEvent()
						remotes.Inventory.Unequip:FireServer(v10, v9)
					end
				end)
			end
		end
	end
end

local function Equip(p, p2)
	for _, v5 in pairs(v2[p].Equipped) do
		if v5 == p2 then
			return
		end
	end

	table.insert(v2[p].Equipped, 1, p2)
	local count = #v2[p].Equipped

	if v2[p].Slots < count then
		table.remove(v2[p].Equipped, count)
	end

	UpdateEquip()
	replicatedStorage.Remotes.Inventory.Equip:FireServer(p2, p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WeaponAction(itemID, _, p, _)
	if p.ItemType ~= "Misc" then
		v2.Weapons.Equipped[p.ItemType] = itemID
		UpdateEquip()
		replicatedStorage.Remotes.Inventory.Equip:FireServer(itemID, "Weapons")
	end
end

local v5 = {
	Weapons = {
		FrameFunction = function(data, _, p)
			local weapon = DatabaseCompatability.Weapons[p.ItemID]
			data.Icon.Image = weapon.Image
			data.ItemName.Text = weapon.ItemName
			data.ItemName.TextColor3 = rarity[weapon.Rarity]
			data.Rarity.Text = weapon.Rarity
			data.Rarity.TextColor3 = rarity[weapon.Rarity]

			if p.Amount > 1 then
				data.Amount.Text = "x" .. p.Amount
			end

			data.Button.MouseButton1Click:connect(function()
				local itemID = p.ItemID
				local _ = p.Amount
				WeaponAction(itemID, nil, weapon) -- equivalent call inferred; original call site unknown
			end)
		end
	},
	Effects = {
		FrameFunction = function(data, _, p)
			local effect = DatabaseCompatability.Effects[p]
			data.Icon.Image = effect.Image
			data.Type.Text = effect.Type
			data.ItemName.Text = effect.Name
		end
	},
	Perks = {
		FrameFunction = function(p, _, p2)
			local perk = DatabaseCompatability.Perks[p2]
			local icon = p.Icon
			local image = GetImage(perk.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			p.ItemName.Text = perk.Name
		end
	},
	Emotes = {
		FrameFunction = function(data, _, p)
			local emote = DatabaseCompatability.Emotes[p]
			data.ItemName.Text = emote.Name
			data.Icon.Image = emote.Image
			data.Type.Text = ""
		end
	},
	Radios = {
		FrameFunction = function(p, _, p2)
			local radio2 = DatabaseCompatability.Radios[p2]
			p.ItemName.Text = radio2.Name
			p.Icon.Image = "http://www.roblox.com/Thumbs/Asset.ashx?format=png&width=250&height=250&assetId=" .. radio2.Image
		end
	},
	Toys = {
		FrameFunction = function(p, _, p2)
			local toy = DatabaseCompatability.Toys[p2]
			p.ItemName.Text = toy.Name
			local icon = p.Icon
			local image = GetImage(toy.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
		end
	},
	Pets = {
		FrameFunction = function(data, _, p)
			local pet = DatabaseCompatability.Pets[p.ItemID]
			local icon = data.Icon
			local image = GetImage(pet.Image) -- equivalent call inferred; original call site unknown
			icon.Image = image
			data.ItemName.Text = pet.Name
			data.ItemName.TextColor3 = rarity[pet.Rarity]
			data.Rarity.Text = pet.Rarity
			data.Rarity.TextColor3 = rarity[pet.Rarity]

			if p.Amount > 1 then
				data.Amount.Text = "x" .. p.Amount
			end

			data.MouseEnter:connect(function()
				data.Rarity.Visible = true
			end)
			data.MouseLeave:connect(function()
				data.Rarity.Visible = false
			end)
		end
	}
}

local function CreateGrid(p)
	if v2[p] == nil then
		return
	end

	local count = 0
	local scrollFrame = main[p].Items.ScrollFrame
	local container = scrollFrame.Container
	local v6 = not v5[p] and 0.2 or v5[p].Size or 0.2
	local fn = not v5[p] and function() end or v5[p].FrameFunction or function() end
	local Y = scrollFrame.CanvasPosition.Y
	local flag = false
	scrollFrame.Changed:connect(function()
		if flag then
			return
		end

		local Y2 = scrollFrame.CanvasPosition.Y

		if Y < Y2 then
			flag = true
			scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasPosition.Y + 20)
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
			flag = false
		end

		Y = scrollFrame.CanvasPosition.Y
	end)

	if v2[p].Equipped and p ~= "Weapons" then
		main[p].Equipped:ClearAllChildren()
		local clone = script.EquipSlot:Clone()
		clone.ItemName.Text = "Empty"
		clone.Parent = main[p].Equipped
		clone.Name = "Slot" .. 1
		clone.Selectable = p == "Effects" or p == "Pets"
	end

	container:ClearAllChildren()
	local Y2 = nil

	local function CreateFrame(k, p2)
		if p2 ~= "None" then
			local v7 = math.floor(count / (1 / v6))
			local v8 = count % (1 / v6)
			local clone = p2 == "GetMore" and script.GetMore:Clone() or script.Item:Clone()
			clone.Size = UDim2.new(v6, 0, v6, 0)
			clone.Parent = container

			if not Y2 then
				Y2 = clone.AbsoluteSize.Y
			end

			clone.Position = UDim2.new(v6 * v8, 0, 0, Y2 * v7)
			clone.Name = "Slot" .. count

			if k and p2 then
				fn(clone.Container, k, p2)

				if p ~= "Weapons" and p ~= "Emotes" then
					clone.Container.Button.MouseButton1Click:Connect(function()
						if p == "Pets" then
							Equip(p, p2.ItemID)
						else
							Equip(p, p2)
						end
					end)
				end
			end

			if p2 == "GetMore" then
				clone.Container.Button.MouseButton1Click:Connect(function()
					_G.Navigate(p, 0)
				end)
			end

			scrollFrame.CanvasSize = UDim2.new(0, 0, 0, (v7 + 1) * Y2)
			count += 1
		end
	end

	if main[p]:FindFirstChild("BuyRadio") and radio then
		main[p].BuyRadio.Visible = false
	end

	for k, v7 in pairs(v2[p].Owned) do
		CreateFrame(k, v7)
	end
end

onEvent = function(p)
	if not p then
		local GuiService = game:GetService("GuiService")
		local selectedObject = GuiService.SelectedObject
		local name, parent2

		if selectedObject then
			name = selectedObject.Name
			parent2 = selectedObject.Parent
		end

		SortData()

		for _, v6 in v3 do
			CreateGrid(v6)
		end

		UpdateEquip()

		if name and parent2 then
			local GuiService2 = game:GetService("GuiService")
			GuiService2.SelectedObject = parent2[name]
		end
	end
end

onEvent()
game.ReplicatedStorage.Remotes.Inventory.InventoryDataChanged.Event:Connect(onEvent)

local function UpdateRecipes() end

function _G.Process(text)
	if not text then
		processing.Visible = false
		return
	end

	processing.Title.Text = text
	spawn(function()
		while processing.Visible == true do
			processing.Frame.Spinner.Rotation = processing.Frame.Spinner.Rotation + 5
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:wait()
		end
	end)
	spawn(function()
		while processing.Visible == true do
			wait(0.2)
			processing.Title.Text = processing.Title.Text .. "."
		end
	end)
	processing.Visible = true
end

local inventory2 = game.Players.LocalPlayer.PlayerGui:WaitForChild("InputContext"):WaitForChild("Console"):WaitForChild("Inventory")
local v6 = 1
local v7 = {
	"Weapons",
	"Effects",
	"Perks",
	"Pets"
}

local function navigate(p: number)
	v6 += p

	if v6 > #v7 then
		v6 = 1
	end

	if v6 < 1 then
		v6 = #v7
	end

	local text = v7[v6]

	for _, child in inventory.Main:GetChildren() do
		child.Visible = child.Name == text
	end

	for _, child in inventory.Title.Nav:GetChildren() do
		child.Style = child.Name == text and Enum.ButtonStyle.RobloxRoundDefaultButton or Enum.ButtonStyle.RobloxRoundButton
	end

	inventory.Title.Title.Text = text
	local GuiService = game:GetService("GuiService")
	GuiService:Select(inventory)
end

inventory2.NavigateLeft.Pressed:Connect(function()
	navigate(-1)
end)
inventory2.NavigateRight.Pressed:Connect(function()
	navigate(1)
end)