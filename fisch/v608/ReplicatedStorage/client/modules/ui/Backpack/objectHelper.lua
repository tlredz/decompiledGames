local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("UserService")
local library = require(ReplicatedStorage.shared.modules.library)
local enchants = require(ReplicatedStorage.shared.modules.library.rods.enchants)
local spearEnchants = require(ReplicatedStorage.shared.modules.library.spears.spearEnchants)
local harpoonEnchants = require(ReplicatedStorage.shared.modules.library.harpoonGuns.harpoonEnchants)
local itemDisplayInfo = require(script.Parent.itemDisplayInfo)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local itemTemplate = ReplicatedStorage.resources.ui.backpack.ItemTemplate
local appraised = ReplicatedStorage.resources.ui.backpack.Appraised
local weightAppraised = ReplicatedStorage.resources.ui.backpack.WeightAppraised
local weight = ReplicatedStorage.resources.ui.backpack.Weight
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local stack = ReplicatedStorage.resources.ui.backpack.Stack
local localPlayer = Players.LocalPlayer
local FischUtils = require(ReplicatedStorage.shared.utils.FischUtils)
local playerDataReplicator = DataController.PlayerDataReplicator
legacyLocalPlayerData.fetch()
local v = {}
local v2 = {}
local value = nil
local uDim = UDim2.fromOffset(100000, 0)
local uDim2 = UDim2.fromOffset(0, 0)
local v3 = {
	low = {
		ColorSequence.new(Color3.fromRGB(179, 179, 179)),
		Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
	},
	med = {
		ColorSequence.new(Color3.fromRGB(255, 232, 138)),
		Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
	},
	high = {
		ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 140)),
		Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
	}
}

local function loadObject(parent, instance)
	local v4 = v2[parent][instance]

	if v4 then
		v4[1].Visible = true
		v4[2] = false
		return v4[1]
	else
		local clone = instance:Clone()
		clone.Parent = parent
		v2[parent][instance] = { clone, false }
		return clone
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unloadObject(p, p2)
	local v4 = v2[p][p2]

	if v4 then
		v4[1].Visible = false
		v2[p][p2][2] = true
	end
end

local function getItemFullNameWithData(p)
	return (FischUtils.ItemDisplay(p, {
		rich = true
	}))
end

local function indexData(items)
	local data = playerDataReplicator and playerDataReplicator.Data

	for _, item in items do
		if typeof(data) ~= "table" then
			return nil
		end

		data = data[item]
	end

	return data
end

local v4 = {
	{
		Library = library.rods,
		Enchants = enchants,
		Keeperbound = true,
		GetRecord = function(p: string)
			local data = playerDataReplicator and playerDataReplicator.Data

			for _, v5 in { "Rods", p } do
				if typeof(data) ~= "table" then
					return nil
				end

				data = data[v5]
			end

			return data
		end
	},
	{
		Library = library.spears,
		Enchants = spearEnchants,
		GetRecord = function(p: string)
			local data = playerDataReplicator and playerDataReplicator.Data

			for _, v5 in { "Spears", p } do
				if typeof(data) ~= "table" then
					return nil
				end

				data = data[v5]
			end

			return data
		end
	},
	{
		Library = library.harpoonGuns,
		Enchants = harpoonEnchants,
		GetRecord = function(p: string)
			local data = playerDataReplicator and playerDataReplicator.Data

			for _, v5 in { "HarpoonGuns", "Owned", p } do
				if typeof(data) ~= "table" then
					return nil
				end

				data = data[v5]
			end

			return data
		end
	}
}

local function getToolFullName(p: string)
	for _, v5 in v4 do
		if not v5.Library[p] then
			continue
		end

		local record = v5.GetRecord(p)

		if not record then
			return p
		end

		local v6 = {}
		-- equivalent calls inferred from this helper; original call sites unknown
		local enchants2 = v5.Enchants
		local richDisplayNames = v6

		local function addEnchant(value2)
			if typeof(value2) == "string" and value2 ~= "" and value2 ~= "none" and enchants2.Enchants[value2] then
				table.insert(richDisplayNames, enchants2:GetRichDisplayName(value2))
			end
		end

		if v5.Keeperbound and record.keeperboundActive then
			addEnchant(record.keeperboundEnchant) -- equivalent call inferred; original call site unknown
		else
			addEnchant(record.enchant) -- equivalent call inferred; original call site unknown
			addEnchant(record.secondaryEnchant) -- equivalent call inferred; original call site unknown
		end

		table.insert(v6, p)
		return table.concat(v6, " ")
	end

	return nil
end

local function getItemFullName(displayName: string)
	local v5 = v[displayName]

	if v5 then
		return (FischUtils.ItemDisplay(v5, {
			rich = true
		}))
	end

	local toolFullName = getToolFullName(displayName)

	if toolFullName then
		return toolFullName
	end

	if itemDisplayInfo[displayName] then
		displayName = itemDisplayInfo[displayName].displayName or displayName
	end

	return displayName
end

local v5 = string.rep("%S", 8)
local v6 = {}

local function updateAquariumMap(p)
	if not p then
		return
	end

	table.clear(v6)

	for _, v7 in p.FishIndex do
		v6[v7] = true
	end

	for _, v7 in p.CosmeticFishIndex do
		v6[v7] = true
	end
end

local function updateItemComponent(parent, p: string)
	if p then
		if value == p then
			parent.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		else
			parent.UIStroke.Color = Color3.fromRGB(30, 30, 30)
		end

		local itemName = parent.ItemName
		local v7 = v[p]
		local displayName

		if v7 then
			displayName = FischUtils.ItemDisplay(v7, {
				rich = true
			})
		else
			displayName = getToolFullName(p)

			if not displayName then
				if itemDisplayInfo[p] then
					displayName = itemDisplayInfo[p].displayName or p
				else
					displayName = p
				end
			end
		end

		itemName.Text = displayName
		local richText = parent.ItemName.Text:find("[<>&]") ~= nil

		if richText ~= parent.ItemName.RichText then
			parent.ItemName.RichText = richText
		end

		parent.ItemName.UITextSizeConstraint.MaxTextSize = richText and parent.ItemName.ContentText:find(v5) and 13 or 15
		local v9 = v[p]

		if v9 then
			if v9.sub.Favourited then
				if v6[p] then
					parent.Favourited.BackgroundColor3 = Color3.fromRGB(0, 208, 255)
					parent.Favourited.BackgroundTransparency = 0.8
					parent.Favourited.UIStroke.Color = Color3.fromRGB(0, 168, 206)
					parent.Favourited.Star.ImageColor3 = Color3.fromRGB(0, 208, 255)
					parent.Favourited.Star.Image = "rbxassetid://102251433114509"
				else
					parent.Favourited.BackgroundColor3 = Color3.fromRGB(254, 255, 174)
					parent.Favourited.BackgroundTransparency = 0.87
					parent.Favourited.UIStroke.Color = Color3.fromRGB(181, 182, 113)
					parent.Favourited.Star.ImageColor3 = Color3.fromRGB(254, 255, 174)
					parent.Favourited.Star.Image = "rbxassetid://18162767851"
				end

				parent.Favourited.Position = uDim2
			else
				parent.Favourited.Position = uDim
			end

			if v9.sub.Appraised then
				local appraised2 = appraised
				local v11 = v2[parent][appraised2]

				if v11 then
					v11[1].Visible = true
					v11[2] = false
					local _ = v11[1]
				else
					local clone = appraised2:Clone()
					clone.Parent = parent
					v2[parent][appraised2] = { clone, false }
				end
			else
				unloadObject(parent, appraised) -- equivalent call inferred; original call site unknown
			end

			if v9.sub.DefaultWeight then
				local weightAppraised2 = weightAppraised
				local v11 = v2[parent][weightAppraised2]

				if v11 then
					v11[1].Visible = true
					v11[2] = false
					local _ = v11[1]
				else
					local clone = weightAppraised2:Clone()
					clone.Parent = parent
					v2[parent][weightAppraised2] = { clone, false }
				end
			else
				unloadObject(parent, weightAppraised) -- equivalent call inferred; original call site unknown
			end

			if v9.sub.Weight then
				local weight2 = weight
				local v11 = v2[parent][weight2]
				local clone

				if v11 then
					v11[1].Visible = true
					v11[2] = false
					clone = v11[1]
				else
					clone = weight2:Clone()
					clone.Parent = parent
					v2[parent][weight2] = { clone, false }
				end

				if v9.sub.Weight >= 1000 then
					clone.Text = string.format("%.2fT", v9.sub.Weight / 1000)
					clone.UIGradient.Color = v3.high[1]
					clone.FontFace = v3.high[2]
				elseif v9.sub.Weight >= 100 then
					clone.Text = `{math.floor(v9.sub.Weight * 10) / 10}Kg`
					clone.UIGradient.Color = v3.med[1]
					clone.FontFace = v3.med[2]
				else
					clone.Text = `{math.floor(v9.sub.Weight * 10) / 10}Kg`
					clone.UIGradient.Color = v3.low[1]
					clone.FontFace = v3.low[2]
				end
			else
				unloadObject(parent, weight) -- equivalent call inferred; original call site unknown
			end

			if v9.sub.Stack and v9.sub.Stack > 1 then
				local stack2 = stack
				local v11 = v2[parent][stack2]
				local clone

				if v11 then
					v11[1].Visible = true
					v11[2] = false
					clone = v11[1]
				else
					clone = stack2:Clone()
					clone.Parent = parent
					v2[parent][stack2] = { clone, false }
				end

				clone.Text = `x{v9.sub.Stack}`
			else
				unloadObject(parent, stack) -- equivalent call inferred; original call site unknown
			end
		else
			parent.Favourited.Position = uDim
			unloadObject(parent, appraised) -- equivalent call inferred; original call site unknown
			unloadObject(parent, weight) -- equivalent call inferred; original call site unknown
			unloadObject(parent, stack) -- equivalent call inferred; original call site unknown
		end
	else
		parent.ItemName.Text = ""
		parent.UIStroke.Color = Color3.fromRGB(30, 30, 30)
		parent.Favourited.Position = uDim
		unloadObject(parent, appraised) -- equivalent call inferred; original call site unknown
		unloadObject(parent, weight) -- equivalent call inferred; original call site unknown
		unloadObject(parent, stack) -- equivalent call inferred; original call site unknown
		unloadObject(parent, weightAppraised) -- equivalent call inferred; original call site unknown
	end
end

local function setComponentItem(clone, name: string?)
	if name == nil then
		clone.ItemName.Text = ""
		clone.ImageLabel.Image = ""
		clone.Rarity.Visible = false
	else
		if v[name] then
			name = v[name].name or name
		end

		local v7 = itemDisplayInfo[name]

		if v7 then
			if v7.rarity == "" and not v7.color then
				clone.Rarity.Visible = false
				clone.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
			else
				local color = v7.color or library.rarities.StaticColors[v7.rarity] or Color3.new(1, 1, 1)
				clone.Rarity.Visible = true
				clone.Rarity.UIGradient.Color = ColorSequence.new(color)
				clone.Rarity.UIGradient.Rotation = 0
				clone.ImageLabel.ImageColor3 = color
			end

			clone.ImageLabel.Image = v7.icon
		else
			clone.ImageLabel.Image = "rbxassetid://12230941577"
			clone.Rarity.Visible = false
		end
	end
end

local function createItemComponent(p: string)
	local clone = itemTemplate:Clone()
	setComponentItem(clone, p)
	v2[clone] = {}
	clone.Destroying:Connect(function()
		v2[clone] = nil
	end)
	return clone
end

local function createItemWithData(p)
	local clone = itemTemplate:Clone()
	local v7 = itemDisplayInfo[p.name]
	v2[clone] = {}

	if v7 then
		if v7.rarity == "" then
			clone.Rarity.Visible = false
			clone.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
		else
			clone.Rarity.Visible = true
			local imageColor = library.rarities.StaticColors[v7.rarity] or Color3.new(1, 1, 1)
			clone.Rarity.UIGradient.Color = ColorSequence.new(imageColor)
			clone.Rarity.UIGradient.Rotation = 0
			clone.ImageLabel.ImageColor3 = imageColor
		end

		clone.ImageLabel.Image = v7.icon
	else
		clone.ImageLabel.Image = "rbxassetid://12230941577"
		clone.Rarity.Visible = false
	end

	clone.ItemName.Text = FischUtils.ItemDisplay(p, {
		rich = true
	})

	if p then
		if p.sub.Favourited then
			clone.Favourited.Position = uDim2
		else
			clone.Favourited.Position = uDim
		end

		if p.sub.Appraised then
			local appraised2 = appraised
			local v9 = v2[clone][appraised2]

			if v9 then
				v9[1].Visible = true
				v9[2] = false
				local _ = v9[1]
			else
				local clone2 = appraised2:Clone()
				clone2.Parent = clone
				v2[clone][appraised2] = { clone2, false }
			end
		else
			unloadObject(clone, appraised) -- equivalent call inferred; original call site unknown
		end

		if p.sub.DefaultWeight then
			local weightAppraised2 = weightAppraised
			local v9 = v2[clone][weightAppraised2]

			if v9 then
				v9[1].Visible = true
				v9[2] = false
				local _ = v9[1]
			else
				local clone2 = weightAppraised2:Clone()
				clone2.Parent = clone
				v2[clone][weightAppraised2] = { clone2, false }
			end
		else
			unloadObject(clone, weightAppraised) -- equivalent call inferred; original call site unknown
		end

		if p.sub.Weight then
			local weight2 = weight
			local v9 = v2[clone][weight2]
			local clone2

			if v9 then
				v9[1].Visible = true
				v9[2] = false
				clone2 = v9[1]
			else
				clone2 = weight2:Clone()
				clone2.Parent = clone
				v2[clone][weight2] = { clone2, false }
			end

			if p.sub.Weight >= 1000 then
				clone2.Text = string.format("%.2fT", p.sub.Weight / 1000)
				clone2.UIGradient.Color = v3.high[1]
				clone2.FontFace = v3.high[2]
			elseif p.sub.Weight >= 100 then
				clone2.Text = `{math.floor(p.sub.Weight * 10) / 10}Kg`
				clone2.UIGradient.Color = v3.med[1]
				clone2.FontFace = v3.med[2]
			else
				clone2.Text = `{math.floor(p.sub.Weight * 10) / 10}Kg`
				clone2.UIGradient.Color = v3.low[1]
				clone2.FontFace = v3.low[2]
			end
		else
			unloadObject(clone, weight) -- equivalent call inferred; original call site unknown
		end

		if p.sub.Stack and p.sub.Stack > 1 then
			local stack2 = stack
			local v9 = v2[clone][stack2]
			local clone2

			if v9 then
				v9[1].Visible = true
				v9[2] = false
				clone2 = v9[1]
			else
				clone2 = stack2:Clone()
				clone2.Parent = clone
				v2[clone][stack2] = { clone2, false }
			end

			clone2.Text = `x{p.sub.Stack}`
		else
			unloadObject(clone, stack) -- equivalent call inferred; original call site unknown
		end
	else
		clone.Favourited.Position = uDim
		unloadObject(clone, appraised) -- equivalent call inferred; original call site unknown
		unloadObject(clone, weight) -- equivalent call inferred; original call site unknown
		unloadObject(clone, stack) -- equivalent call inferred; original call site unknown
	end

	v2[clone] = nil
	return clone
end

local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cleanupCharacterConnections()
	for _, connection in connections do
		connection:Disconnect()
	end

	table.clear(connections)
end

local function OnCharacterAdded(instance)
	cleanupCharacterConnections() -- equivalent call inferred; original call site unknown
	table.insert(connections, instance.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			local link = tool:FindFirstChild("link")

			if link then
				value = link.Value
			else
				value = tool.Name
			end
		end
	end))
	table.insert(connections, instance.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			value = nil
		end
	end))
end

if localPlayer.Character then
	task.spawn(OnCharacterAdded, localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(OnCharacterAdded)
playerDataReplicator:Observe({ "PersonalAquarium" }, updateAquariumMap)
task.spawn(function()
	while true do
		for _, v7 in v2 do
			for k, v8 in v7 do
				if not v8[2] then
					continue
				end

				v8[1]:Destroy()
				v7[k] = nil
			end
		end

		task.wait(10)
	end
end)
local ObjectHelper = {}

function ObjectHelper.setInventory(p)
	v = p
end

ObjectHelper.create = createItemComponent
ObjectHelper.update = updateItemComponent

function ObjectHelper.setComponentTransparency(state, p: number)
	state.BackgroundTransparency = math.lerp(itemTemplate.BackgroundTransparency, 1, p)
	state.Rarity.BackgroundTransparency = math.lerp(itemTemplate.Rarity.BackgroundTransparency, 1, p)
	state.ImageLabel.ImageTransparency = math.lerp(itemTemplate.ImageLabel.ImageTransparency, 1, p)
end

ObjectHelper.setComponentItem = setComponentItem
ObjectHelper.getItemFullName = getItemFullName
ObjectHelper.createWithData = createItemWithData
return ObjectHelper