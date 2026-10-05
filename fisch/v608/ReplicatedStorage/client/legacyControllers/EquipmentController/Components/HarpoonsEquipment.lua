local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local parent = script.Parent
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local harpoonGuns = require(modules.library.harpoonGuns)
local harpoonEnchants = require(modules.library.harpoonGuns.harpoonEnchants)
local HarpoonGunSkins = require(modules.HarpoonGunSkins)
local fx = require(modules.fx)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local HuntNames = require(ReplicatedStorage.shared.data.HuntNames)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local patch = require(packages.patch)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local VirtualEquipmentList = require(parent:WaitForChild("VirtualEquipmentList"))
local EquipmentSearch = require(parent:WaitForChild("EquipmentSearch"))
local remoteFunction = Net:RemoteFunction("HarpoonGun/SetEquipped")
local remoteFunction2 = Net:RemoteFunction("HarpoonGun/SetSkin")
local remoteFunction3 = Net:RemoteFunction("HarpoonGun/Favorite")
local remoteFunction4 = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local equipment = HudController:GetSafeZone().equipment
local container = equipment.Container
local header = equipment.Header
local harpoonGuns2 = container.HarpoonGuns
local main = harpoonGuns2.Main
local scrollingFrame = main.ScrollingFrame
local skins = harpoonGuns2.Skins
local UI = script.UI
local color = Color3.fromRGB(175, 175, 175)
local color2 = Color3.fromRGB(190, 150, 150)
local color3 = Color3.fromRGB(162, 234, 166)
local color4 = Color3.fromRGB(81, 81, 81)
local maid = Trove.new()
local folder = Instance.new("Folder")
folder.Name = "the evil harpoon zone"
folder.Parent = script
local count = 0
local v = {
	Power = {
		statKey = "Power",
		format = function(_, p, callback)
			return (`Power: {p.Power}{callback("Power")}`)
		end,
		colorBands = {
			{
				threshold = 0.001,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Range = {
		statKey = "Range",
		format = function(_, p, callback)
			return (`Range: {p.Range} studs{callback("Range")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Reload = {
		statKey = "Reload",
		format = function(_, p, callback)
			return (`Reload: {string.format("%.2f", p.Reload)}s{callback("Reload")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Velocity = {
		statKey = "Velocity",
		format = function(_, p, callback)
			return (`Velocity: {p.Velocity}/ps{callback("Velocity")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Resilience = {
		statKey = "Resilience",
		format = function(_, p, callback)
			return (`Resilience: {p.Resilience}%{callback("Resilience")}`)
		end,
		colorBands = {
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Accuracy = {
		statKey = "Accuracy",
		format = function(_, p, callback)
			return (`Accuracy: {p.Accuracy}%{callback("Accuracy")}`)
		end,
		colorBands = {
			{
				threshold = 0,
				color = color2
			},
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Strength = {
		statKey = "Strength",
		format = function(_, p, callback)
			return (`Max Kg: {NumberUtils:Comma(p.Strength)}{callback("Strength")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Disturbance = {
		statKey = "Disturbance",
		format = function(p, _, callback)
			return (`+{p.Disturbance or 0}{callback("Disturbance", false)}`)
		end,
		visibleIf = function(p)
			return p.Disturbance and p.Disturbance ~= 0
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	PreferredDisturbance = {
		statKey = "PreferredDisturbance",
		format = function(_, p, _)
			local preferredDisturbance = p.PreferredDisturbance
			return (`{HuntNames[preferredDisturbance.Event] or preferredDisturbance.Event} (+{preferredDisturbance.Risk})`)
		end,
		visibleIf = function(p)
			local preferredDisturbance = p.PreferredDisturbance
			return preferredDisturbance ~= nil and preferredDisturbance.Risk ~= 0 and preferredDisturbance.Event ~= ""
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	},
	Caught = {
		statKey = "Caught",
		format = function(_, p)
			return (`Caught: {NumberUtils:Comma(p.Caught or 0)}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color
			}
		}
	}
}
local settingValue = "Names"
local v2 = nil
local v3 = nil
local v4 = {
	Strength = "Max Kg",
	PreferredDisturbance = "Hunt Focus"
}
local v5 = ""

for _, harpoonGun in harpoonGuns do
	if not harpoonGun.Unregistered then
		count += 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRecord(p: string)
	return playerDataReplicator:TryIndex({ "HarpoonGuns", "Owned", p })
end

local function getPatchedStats(key: string)
	local harpoonGun = harpoonGuns[key]

	if not harpoonGun then
		return nil, nil
	end

	local copy = GeneralUtils.copy(harpoonGun, true)
	local record = getRecord(key) -- equivalent call inferred; original call site unknown
	local skin = record and record.skin
	local v6 = skin and HarpoonGunSkins.Skins[skin]

	if v6 and v6.GunPatches then
		copy = GeneralUtils.applyTable(copy, v6.GunPatches, true)
	end

	if record then
		harpoonEnchants:ApplyToStats(copy, { record.enchant, record.secondaryEnchant }, localPlayer)
	end

	return harpoonGun, copy
end

local function addBoostIndicator(p, p2, p3: string)
	local v6 = math.round(((p2[p3] or 0) - (p[p3] or 0)) * 1000) / 1000

	if v6 == 0 or v6 ~= v6 then
		return ""
	end

	return (` <font color="#ffd43a">({v6 > 0 and "+" or ""}{v6})</font>`)
end

local function updateFavorited(data)
	local favorited = data.favorited
	local color5 = favorited and Color3.fromRGB(255, 162, 0) or Color3.fromRGB(255, 255, 255)
	local favorite = data.Frame.HarpoonOptions.favorite
	favorite.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
	favorite.ImageTransparency = favorited and 0.25 or 0.5
	favorite.ImageColor3 = color5
	data.Frame.Harpoon.HarpoonInfo.harpoonTitle.TextColor3 = color5
	local gridFrame = data.gridFrame

	if gridFrame then
		local favorite2 = gridFrame.HarpoonOptions:FindFirstChild("favorite")

		if favorite2 then
			favorite2.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
			favorite2.ImageTransparency = favorited and 0.25 or 0.5
			favorite2.ImageColor3 = color5
		end

		gridFrame.harpoonTitle.TextColor3 = color5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSymbol(p: string)
	local enchant = harpoonEnchants.Enchants[p]

	if not enchant then
		return "★"
	end

	if enchant.RelicGroup == "Exalted" then
		return "❖"
	end

	if enchant.Secondary then
		return "♦"
	end

	return "★"
end

local function applyEnchantLabel(instance, p: string?)
	local v6 = p and harpoonEnchants.Enchants[p]

	if v6 then
		local symbol = getSymbol(p) -- equivalent call inferred; original call site unknown
		instance.RichText = true
		instance.Text = `{symbol} {harpoonEnchants:GetRichDisplayName(p)} {symbol}`
		instance.TextColor3 = v6.Color
		instance.Visible = true

		for _, image in { instance:FindFirstChild("bg"), instance:FindFirstChild("bg2") } do
			if image and image:IsA("ImageLabel") then
				image.ImageColor3 = v6.Color
			end
		end

		return true
	else
		instance.Text = "★ x ★"
		instance.Visible = false
		return false
	end
end

local function updateEnchant(p)
	local v7 = playerDataReplicator:TryIndex({ "HarpoonGuns", "Owned", p.key })

	if not v7 then
		return
	end

	local enchants = p.Frame.Harpoon.Enchants
	local detail = enchants:FindFirstChild("detail")
	enchants.Visible = true
	applyEnchantLabel(enchants.enchant, v7.enchant)
	local secondary = detail and detail:FindFirstChild("secondary")

	if secondary and secondary:IsA("TextLabel") then
		applyEnchantLabel(secondary, v7.secondaryEnchant)
	end

	local mella = detail and detail:FindFirstChild("mella")

	if mella then
		mella.Visible = false
	end

	local powerFrame = enchants:FindFirstChild("powerFrame")

	if powerFrame then
		powerFrame.Visible = false
	end
end

local function updateStats(data)
	local patchedStats, v6 = getPatchedStats(data.key)

	if not patchedStats then
		return
	end

	local v8 = playerDataReplicator:TryIndex({ "HarpoonGuns", "Owned", data.key })
	v6.Caught = tonumber(v8 and v8.caught) or 0
	local stats = data.Frame.Stats

	local function boosts(p: string)
		local v10 = math.round(((v6[p] or 0) - (patchedStats[p] or 0)) * 1000) / 1000

		if v10 == 0 or v10 ~= v10 then
			return ""
		end

		return (` <font color="#ffd43a">({v10 > 0 and "+" or ""}{v10})</font>`)
	end

	for childName, v9 in v do
		local child = stats:FindFirstChild(childName)

		if not child then
			continue
		end

		local visible = not v9.visibleIf or v9.visibleIf(v6)
		child.Visible = visible

		if not visible then
			continue
		end

		local formatted = v9.format(patchedStats, v6, boosts)
		local match, v11 = formatted:match("^(.-):%s*(.+)$")
		data.statTexts[childName] = {
			name = match or childName,
			value = v11 or formatted
		}
		local v12 = v6[v9.statKey] or 0
		local color5 = color

		if typeof(v12) == "number" then
			for _, colorBand in v9.colorBands do
				if not (v12 < colorBand.threshold) then
					continue
				end

				color5 = colorBand.color
				break
			end
		end

		child.Label.TextColor3 = color5
		child.Icon.ImageColor3 = color5
	end

	data.changeStatDisplay(settingValue)
end

local function runEntryUpdate(p, p2: string)
	if not p.Frame then
		return
	end

	if p2 == "stats" then
		updateStats(p)
	elseif p2 == "enchant" then
		updateEnchant(p)
	elseif p2 == "favorited" then
		updateFavorited(p)
	elseif p2 == "display" then
		p.changeStatDisplay(settingValue)
	end
end

local function compareEntries(p, p2)
	if p.favorited == p2.favorited then
		return p.key < p2.key
	end

	return p.favorited
end

local v6 = VirtualEquipmentList.new({
	MainFrame = main,
	ScrollingFrame = scrollingFrame,
	OffscreenParent = folder,
	ListItemWidthScale = 0.31,
	ListAnchorYScale = 0.485,
	GridItemWidthScale = 0.157,
	GridItemHeightScale = 0.27,
	GridColumns = 6,
	Compare = compareEntries,
	RunUpdate = runEntryUpdate
})
local entries = v6:GetEntries()

local function updateEquipped()
	if v2 and entries[v2.key] then
		local v7 = v2
		v7.Frame.Equip.UIStroke.Color = color3
		v7.Frame.Equip.Label.TextColor3 = color3
		v7.Frame.Equip.Label.Text = "[Equip]"

		if v7.gridFrame then
			v7.gridFrame.Equipped.Enabled = false
		end
	end

	v2 = nil
	local v7 = playerDataReplicator:TryIndex({ "HarpoonGuns", "Equipped" })
	local v8 = v7 and entries[v7]

	if v8 then
		v8.Frame.Equip.UIStroke.Color = color4
		v8.Frame.Equip.Label.TextColor3 = color4
		v8.Frame.Equip.Label.Text = "[Equipped]"

		if v8.gridFrame then
			v8.gridFrame.Equipped.Enabled = true
		end

		v2 = v8
	end
end

local function updatePercent(flag: boolean?)
	if not (flag or harpoonGuns2.Visible) then
		return
	end

	local count2 = 0

	for _ in entries do
		count2 += 1
	end

	local v7 = math.clamp(math.round(count2 / count * 1000) / 10, 0, 100)
	header.Complete.Text = `{v7}% Unlocked`
	header.Complete.TextColor3 = count <= count2 and Color3.fromRGB(255, 243, 153) or Color3.fromRGB(255, 255, 255)
end

local HarpoonsEquipment = {}

local function createSkinSlot(p: string, name: string)
	local record = getRecord(p) -- equivalent call inferred; original call site unknown

	if not record then
		return nil
	end

	local v7 = name == "Default"
	local v8

	if v7 then
		v8 = `Default/{p}` or name
	else
		v8 = name
	end

	local v9 = v7 and {} or HarpoonGunSkins.Skins[name] or {}
	local harpoonGun = harpoonGuns[p]
	local v10 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "HarpoonGunSkins", v8 }) == true
	local clone = UI.SkinTemplate:Clone()
	clone.Name = name
	local harpoonInfo = clone.Harpoon.HarpoonInfo
	harpoonInfo.skinImage.Text = v9.DisplayText or name
	harpoonInfo.desc.Text = v9.Description or ""
	harpoonInfo.desc.RichText = v9.DescriptionRich == true
	clone.SkinImage.Image = v9.Icon or v7 and harpoonGun and harpoonGun.Icon or ""

	if v7 or not v9.Rarity then
		clone.Rarity.Visible = false
	else
		local rarity = HarpoonGunSkins.Rarities[v9.Rarity]
		clone.Rarity.Text = v9.Rarity
		clone.Rarity.TextColor3 = rarity.Color
		clone.UIStroke.Color = rarity.Color
		clone.Gradient.BackgroundColor3 = rarity.Color
	end

	local equip = clone.Equip

	if (record.skin or "Default") == name then
		equip.UIStroke.Color = color4
		equip.Label.TextColor3 = color4
		equip.Label.Text = "[Equipped]"
	else
		equip.UIStroke.Color = color3
		equip.Label.TextColor3 = color3
		equip.Label.Text = "[Equip]"
		maid:Connect(equip.Activated, function()
			if localPlayer:GetAttribute("HarpoonSkinEquipInProgress") then
				return
			end

			localPlayer:SetAttribute("HarpoonSkinEquipInProgress", true)
			equip.UIStroke.Color = color4
			equip.Label.TextColor3 = color4
			equip.Label.Text = "..."
			local v13

			if not v7 then
				v13 = name
			end

			remoteFunction2:InvokeServer(p, v13)
			localPlayer:SetAttribute("HarpoonSkinEquipInProgress", false)
		end)
	end

	local favorite = clone.HarpoonOptions.favorite
	favorite.Image = v10 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
	favorite.ImageTransparency = v10 and 0.25 or 0.5
	favorite.ImageColor3 = v10 and Color3.fromRGB(255, 162, 0) or Color3.fromRGB(255, 255, 255)
	maid:Connect(favorite.Activated, function()
		v10 = not v10
		remoteFunction4:InvokeServer("HarpoonGunSkins", v8, v10)
	end)
	maid:Add(clone)
	clone.Parent = skins.ScrollingFrame
	return clone
end

function HarpoonsEquipment:UpdateSkins(p: string)
	maid:Clean()
	v3 = p

	if not playerDataReplicator:TryIndex({ "HarpoonGuns", "Owned", p }) then
		return
	end

	skins.HarpoonName.Text = `{p} Skins`
	local v7 = playerDataReplicator:TryIndex({ "HarpoonGunSkins" }) or {}
	local v8 = playerDataReplicator:TryIndex({ "FavoritedEquipment", "HarpoonGunSkins" }) or {}

	local function isOwned(p2: string)
		local v9 = v7[p2]
		return v9 ~= nil and v9.stack ~= nil and v9.stack > 0
	end

	local v9 = {}

	for k in HarpoonGunSkins.GunsSkins[p] or {} do
		local v10 = v7[k]
		local v11

		if v10 == nil or v10.stack == nil then
			v11 = false
		else
			v11 = v10.stack > 0
		end

		if v11 then
			table.insert(v9, k)
		end
	end

	for k in HarpoonGunSkins.GunsSkins.All or {} do
		local v10 = v7[k]
		local v11

		if v10 == nil or v10.stack == nil then
			v11 = false
		else
			v11 = v10.stack > 0
		end

		if not v11 or table.find(v9, k) then
			continue
		end

		table.insert(v9, k)
	end

	table.sort(v9, function(a, b)
		local v10 = v8[a] == true

		if v10 ~= (v8[b] == true) then
			return v10
		end

		local weight = HarpoonGunSkins.Rarities[HarpoonGunSkins.Skins[a].Rarity].Weight
		local weight2 = HarpoonGunSkins.Rarities[HarpoonGunSkins.Skins[b].Rarity].Weight

		if weight == weight2 then
			return a < b
		end

		return weight2 < weight
	end)
	local skinSlot = createSkinSlot(p, "Default")

	if skinSlot then
		skinSlot.LayoutOrder = -1
	end

	for k, v10 in v9 do
		local skinSlot2 = createSkinSlot(p, v10)

		if skinSlot2 then
			skinSlot2.LayoutOrder = k
		end
	end

	maid:Add(playerDataReplicator:Listen({ "FavoritedEquipment", "HarpoonGunSkins" }, function()
		HarpoonsEquipment:UpdateSkins(p)
	end))
	maid:Add(playerDataReplicator:ListenKeys({ "HarpoonGunSkins" }, function()
		HarpoonsEquipment:UpdateSkins(p)
	end))
	maid:Connect(skins.Back.Activated, function()
		skins.Visible = false
		main.Visible = true
		v3 = nil
		maid:Clean()
	end)
end

local function loadGun(name: string)
	local harpoonGun = harpoonGuns[name]

	if not harpoonGun or entries[name] then
		return
	end

	local record = getRecord(name) -- equivalent call inferred; original call site unknown

	if not record then
		return
	end

	local maid2 = Trove.new()
	local clone = UI.Template:Clone()
	clone.AnchorPoint = Vector2.new(0, 0.5)
	clone.Name = name
	clone.Parent = folder
	local clone2 = UI.GridTemplate:Clone()
	clone2.AnchorPoint = Vector2.new(0, 0)
	clone2.Name = name
	clone2.Parent = folder
	local color5 = harpoonGun.Color or Color3.fromRGB(255, 255, 255)
	local harpoonInfo = clone.Harpoon.HarpoonInfo
	harpoonInfo.harpoonTitle.Text = `[{name}]`
	clone.UIStroke.Color = color5
	clone.Gradient.BackgroundColor3 = color5
	clone.HarpoonImage.Image = harpoonGun.Icon or ""
	clone2.harpoonTitle.Text = `[{name}]`
	clone2.UIStroke.Color = color5
	clone2.Gradient.BackgroundColor3 = color5
	clone2.HarpoonImage.Image = harpoonGun.Icon or ""
	local modify = harpoonInfo.modify
	local description = harpoonGun.Description or ""
	local v7 = "Less"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDescriptionMode(p: string)
		local text = description

		if p == "Less" then
			text = string.sub(text, 1, 75) .. "..."
		end

		harpoonInfo.desc.Text = text
		modify.Text = p == "Less" and "[More]" or "[Less]"
		clone.HarpoonImage.ImageTransparency = (p == "Less" or not modify.Visible) and 0 or 0.75
		clone.Stats.Visible = p == "Less" or not modify.Visible
	end

	local v8 = #description <= 75
	modify.Visible = not v8

	if v8 then
		harpoonInfo.desc.Text = description
	else
		local text = string.sub(description, 1, 75) .. "..."
		harpoonInfo.desc.Text = text
		modify.Text = "[More]"
		clone.HarpoonImage.ImageTransparency = 0
		clone.Stats.Visible = true
		maid2:Connect(modify.Activated, function()
			v7 = v7 == "Less" and "More" or "Less"
			updateDescriptionMode(v7) -- equivalent call inferred; original call site unknown
		end)
	end

	local v9 = {
		Frame = clone,
		gridFrame = clone2,
		key = name,
		mounted = false,
		searchVisible = true,
		cachedIndex = nil,
		favorited = record.favorited == true,
		trove = maid2,
		statTexts = {}
	}

	function v9.changeStatDisplay(p)
		for _, frame in clone.Stats:GetChildren() do
			if not (frame:IsA("Frame") and frame:FindFirstChild("Label")) then
				continue
			end

			frame.Label.Position = UDim2.fromScale(p == "Icons" and 0.18 or 0, 0.5)
			frame.Label.Visible = p ~= "Disabled"
			frame.Icon.Visible = p == "Icons"
			local statText = v9.statTexts[frame.Name]

			if not statText then
				continue
			end

			local label = frame.Label
			local text

			if p == "Names" then
				text = `{v4[statText.name] or statText.name}: {statText.value}`
			else
				text = statText.value
			end

			label.Text = text
		end
	end

	local function tryEquip()
		if playerDataReplicator:TryIndex({ "HarpoonGuns", "Equipped" }) == name then
			return
		end

		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, scrollingFrame, false)
		remoteFunction:InvokeServer(name)
	end

	maid2:Connect(clone.Equip.Activated, tryEquip)
	maid2:Connect(clone2.Activated, tryEquip)

	local function skinActivated()
		HarpoonsEquipment:UpdateSkins(name)
		main.Visible = false
		skins.Visible = true
	end

	maid2:Connect(clone.HarpoonOptions.skin.Activated, skinActivated)
	local skin = clone2.HarpoonOptions:FindFirstChild("skin")

	if skin then
		maid2:Connect(skin.Activated, skinActivated)
	end

	local flag = false

	local function tryFavorite()
		if flag then
			return
		end

		flag = true
		v9.favorited = not v9.favorited
		updateFavorited(v9)

		if not remoteFunction3:InvokeServer(name, v9.favorited) then
			v9.favorited = not v9.favorited
			updateFavorited(v9)
		end

		v6:Rebuild()
		flag = false
	end

	maid2:Connect(clone.HarpoonOptions.favorite.Activated, tryFavorite)
	local favorite = clone2.HarpoonOptions:FindFirstChild("favorite")

	if favorite then
		maid2:Connect(favorite.Activated, tryFavorite)
	end

	local clone3 = table.clone(record)
	maid2:Add(playerDataReplicator:Listen({ "HarpoonGuns", "Owned", name }, function(p)
		if not p then
			return
		end

		local diff = patch.diff(clone3, p)
		clone3 = table.clone(p)

		if diff.favorited ~= nil then
			v9.favorited = p.favorited == true
			v6:ScheduleUpdate(name, "favorited")
			v6:Rebuild()
		end

		if diff.skin ~= nil then
			v6:ScheduleUpdate(name, "stats")

			if v3 == name and skins.Visible then
				HarpoonsEquipment:UpdateSkins(name)
			end
		end

		if diff.caught ~= nil then
			v6:ScheduleUpdate(name, "stats")
		end

		if diff.enchant ~= nil or diff.secondaryEnchant ~= nil then
			v6:ScheduleUpdate(name, "enchant")
			v6:ScheduleUpdate(name, "stats")
		end
	end))
	updateFavorited(v9)
	updateStats(v9)
	updateEnchant(v9)
	v6:AddEntry(name, v9)
	v6:Rebuild()
	updatePercent()
	updateEquipped()
end

local function removeGun(p: string)
	local entry = entries[p]

	if not entry then
		return
	end

	if v2 == entry then
		v2 = nil
	end

	entry.trove:Destroy()
	entry.Frame:Destroy()

	if entry.gridFrame then
		entry.gridFrame:Destroy()
	end

	v6:RemoveEntry(p)
	updatePercent()
	v6:Rebuild()
end

local function harpoonMatchesQuery(entry, query)
	local harpoonGun = harpoonGuns[entry.key]
	local v8 = playerDataReplicator:TryIndex({ "HarpoonGuns", "Owned", entry.key })

	if query.key then
		if table.find({
			"favorited",
			"favourited",
			"favorite",
			"favourite",
			"fav"
		}, query.key) ~= nil then
			return entry.favorited and EquipmentSearch.parseBoolean(query.val)
		end

		if query.key == "skin" then
			return (v8 and v8.skin or "Default"):lower():find(query.val, 1, true) ~= nil
		end

		if query.key == "enchant" then
			local lower = (not v8 and "" or v8.enchant or ""):lower()
			local secondaryEnchant = (v8 and v8.secondaryEnchant or ""):lower()
			local val = query.val
			return lower:find(val, 1, true) ~= nil or secondaryEnchant:find(val, 1, true) ~= nil
		elseif query.key == "from" then
			if harpoonGun and harpoonGun.From then
				return harpoonGun.From:lower():find(query.val, 1, true) ~= nil
			end

			return false
		end
	elseif entry.key:lower():find(query.raw, 1, true) then
		return true
	end

	for _, frame in entry.Frame.Stats:GetChildren() do
		if not (frame:IsA("Frame") and frame.Visible and frame:FindFirstChild("Label")) then
			continue
		end

		local name = frame.Name:lower()
		local text = frame.Label.Text:lower()
		local v9 = text:gsub(",", "")

		if query.key then
			if name:find(query.key, 1, true) then
				if query.compare then
					local number = EquipmentSearch.extractNumber(v9)

					if number and query.compare(number) then
						return true
					end
				elseif text:find(query.val, 1, true) or v9:find(query.val, 1, true) then
					return true
				end
			end
		elseif name:find(query.raw, 1, true) or text:find(query.raw, 1, true) then
			return true
		end
	end

	return false
end

HarpoonsEquipment.TabName = "Harpoon Guns"
HarpoonsEquipment.SearchTip = [[
Example harpoon gun queries:
• <b>power</b>:&gt;20 - show results with more than 20% power
• <b>range</b>:&gt;=30 - show results with 10 studs of range or more
• <b>reload</b>:=30 - show results with exactly 5 seconds of reload time
• <b>enchant</b>:weighted - show results with a matching enchantment
• <b>favorited</b>:yes - show only favorited results
• use <b>commas</b> to combine searches - fav: yes, luck: &gt;50
• use &gt; &gt;= &lt;= = != to compare numbers]]
HarpoonsEquipment.Container = harpoonGuns2
HarpoonsEquipment.MainFrame = main
HarpoonsEquipment.ShowsCompletion = true

function HarpoonsEquipment.UpdateHeader(_)
	updatePercent(true)
end

function HarpoonsEquipment:SetActive(flag: boolean)
	v6:SetActive(flag)
end

function HarpoonsEquipment:SetLayout(p: string)
	v6:SetLayout(p)
end

function HarpoonsEquipment:UpdateSearch(value: string)
	v5 = value or ""
	local queries = EquipmentSearch.buildQueries(v5)

	for _, entry in entries do
		if queries then
			local searchVisible = true

			for _, query in queries do
				if harpoonMatchesQuery(entry, query) then
					continue
				end

				searchVisible = false
				break
			end

			entry.searchVisible = searchVisible
		else
			entry.searchVisible = true
		end
	end

	v6:Rebuild()
end

function HarpoonsEquipment.Init(_)
	local flag = false
	playerDataReplicator:ObserveKeys({ "HarpoonGuns", "Owned" }, function(name, p2)
		if p2 then
			loadGun(name)
		else
			removeGun(name)
		end

		if flag then
			task.spawn(function()
				HarpoonsEquipment:UpdateSearch(v5)
			end)
		end
	end)
	v6:Rebuild()
	flag = true
	playerDataReplicator:Listen({ "HarpoonGuns", "Equipped" }, updateEquipped)
	task.defer(updateEquipped)

	local function updateStatAllDisplayTypes()
		if SettingsController:GetSettingValue("rodStatDisplay") == settingValue then
			return
		end

		settingValue = SettingsController:GetSettingValue("rodStatDisplay")

		for k, entry in entries do
			if entry.mounted then
				task.spawn(entry.changeStatDisplay, settingValue)
			else
				v6:ScheduleUpdate(k, "display")
			end
		end
	end

	SettingsController:GetSettingChangedSignal("rodStatDisplay"):Connect(updateStatAllDisplayTypes)
	task.defer(updateStatAllDisplayTypes)
end

return HarpoonsEquipment