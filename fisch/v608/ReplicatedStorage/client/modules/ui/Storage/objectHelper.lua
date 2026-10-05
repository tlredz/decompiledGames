local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
game:GetService("UserService")
local library = require(ReplicatedStorage.shared.modules.library)
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
local function unloadObject(parent, p)
	local v4 = v2[parent][p]

	if v4 then
		v4[1].Visible = false
		v2[parent][p][2] = true
	end
end

local function getItemFullNameWithData(p)
	return (FischUtils.ItemDisplay(p, {
		rich = true
	}))
end

local function getItemFullName(p: string)
	local v4 = v[p]

	if v4 then
		return (FischUtils.ItemDisplay(v4, {
			rich = true
		}))
	end

	if not library.rods[p] then
		return p
	end

	local v5 = playerDataReplicator and playerDataReplicator.Data and playerDataReplicator.Data.Rods and playerDataReplicator.Data.Rods[p]

	if not v5 then
		return
	end

	local secondaryEnchant = v5.secondaryEnchant

	if v5.enchant == "none" or not library.enchants[tostring(v5.enchant)] then
		local v6

		if secondaryEnchant == "none" then
			v6 = false
		else
			v6 = library.enchants[tostring(secondaryEnchant)]
		end

		local v7

		if v6 then
			local enchant = library.enchants[tostring(secondaryEnchant)]
			v7 = ` <font color ='#{enchant.Color:ToHex()}'>{enchant.Display}</font> `
		else
			v7 = ""
		end

		return (`{v7}{p}`)
	else
		local enchant = library.enchants[tostring(v5.enchant)]
		local v6

		if secondaryEnchant == "none" then
			v6 = false
		else
			v6 = library.enchants[tostring(secondaryEnchant)]
		end

		local v7

		if v6 then
			local enchant2 = library.enchants[tostring(secondaryEnchant)]
			v7 = `<font color ='#{enchant2.Color:ToHex()}'>{enchant2.Display}</font> `
		else
			v7 = ""
		end

		return (`<font color ='#{enchant.Color:ToHex()}'>{enchant.Display}</font> {v7}{p}`)
	end
end

local v4 = {}

local function updateAquariumMap(p)
	if not p then
		return
	end

	table.clear(v4)

	for _, v5 in p.FishIndex do
		v4[v5] = true
	end

	for _, v5 in p.CosmeticFishIndex do
		v4[v5] = true
	end
end

local function updateItemComponent(parent, p: string)
	if p then
		if value == p then
			parent.UIStroke.Color = Color3.fromRGB(255, 255, 255)
		else
			parent.UIStroke.Color = Color3.fromRGB(30, 30, 30)
		end

		parent.ItemName.Text = getItemFullName(p)
		local v5 = v[p]

		if v5 then
			if v5.sub.Favourited then
				if v4[p] then
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

			if v5.sub.Appraised then
				local appraised2 = appraised
				local v7 = v2[parent][appraised2]

				if v7 then
					v7[1].Visible = true
					v7[2] = false
					local _ = v7[1]
				else
					local clone = appraised2:Clone()
					clone.Parent = parent
					v2[parent][appraised2] = { clone, false }
				end
			else
				unloadObject(parent, appraised) -- equivalent call inferred; original call site unknown
			end

			if v5.sub.DefaultWeight then
				local weightAppraised2 = weightAppraised
				local v7 = v2[parent][weightAppraised2]

				if v7 then
					v7[1].Visible = true
					v7[2] = false
					local _ = v7[1]
				else
					local clone = weightAppraised2:Clone()
					clone.Parent = parent
					v2[parent][weightAppraised2] = { clone, false }
				end
			else
				unloadObject(parent, weightAppraised) -- equivalent call inferred; original call site unknown
			end

			if v5.sub.Weight then
				local weight2 = weight
				local v7 = v2[parent][weight2]
				local clone

				if v7 then
					v7[1].Visible = true
					v7[2] = false
					clone = v7[1]
				else
					clone = weight2:Clone()
					clone.Parent = parent
					v2[parent][weight2] = { clone, false }
				end

				if v5.sub.Weight >= 1000 then
					clone.Text = string.format("%.2fT", v5.sub.Weight / 1000)
					clone.UIGradient.Color = v3.high[1]
					clone.FontFace = v3.high[2]
				elseif v5.sub.Weight >= 100 then
					clone.Text = `{math.floor(v5.sub.Weight * 10) / 10}Kg`
					clone.UIGradient.Color = v3.med[1]
					clone.FontFace = v3.med[2]
				else
					clone.Text = `{math.floor(v5.sub.Weight * 10) / 10}Kg`
					clone.UIGradient.Color = v3.low[1]
					clone.FontFace = v3.low[2]
				end
			else
				unloadObject(parent, weight) -- equivalent call inferred; original call site unknown
			end

			if v5.sub.Stack and v5.sub.Stack > 1 then
				local stack2 = stack
				local v7 = v2[parent][stack2]
				local clone

				if v7 then
					v7[1].Visible = true
					v7[2] = false
					clone = v7[1]
				else
					clone = stack2:Clone()
					clone.Parent = parent
					v2[parent][stack2] = { clone, false }
				end

				clone.Text = `x{v5.sub.Stack}`
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

		local v5 = itemDisplayInfo[name]

		if v5 then
			if v5.rarity == "" then
				clone.Rarity.Visible = false
				clone.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
			else
				clone.Rarity.Visible = true
				local imageColor = library.rarities.StaticColors[v5.rarity] or CFrame.new(1, 1, 1)
				clone.Rarity.UIGradient.Color = ColorSequence.new(imageColor)
				clone.Rarity.UIGradient.Rotation = 0
				clone.ImageLabel.ImageColor3 = imageColor
			end

			clone.ImageLabel.Image = v5.icon
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
		for _, v5 in v2 do
			for k, v6 in v5 do
				if not v6[2] then
					continue
				end

				v6[1]:Destroy()
				v5[k] = nil
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
return ObjectHelper