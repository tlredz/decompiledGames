local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local packages = ReplicatedStorage.packages
local parent = script.Parent
local DataController = require(legacyControllers.DataController)
local HudController = require(legacyControllers.HudController)
local SettingsController = require(legacyControllers.SettingsController)
local spears = require(modules.library.spears)
local spearEnchants = require(modules.library.spears.spearEnchants)
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local character = require(modules.character)
local fx = require(modules.fx)
local Net = require(packages.Net)
local Trove = require(packages.Trove)
local patch = require(packages.patch)
local NumberUtils = require(ReplicatedStorage.shared.utils.NumberUtils)
local HuntNames = require(ReplicatedStorage.shared.data.HuntNames)
local VirtualEquipmentList = require(parent:WaitForChild("VirtualEquipmentList"))
local EquipmentSearch = require(parent:WaitForChild("EquipmentSearch"))
local remoteEvent = Net:RemoteEvent("Spear/Equip")
local remoteFunction = Net:RemoteFunction("EquipmentBag/SetFavorite", -1)
local localPlayer = game.Players.LocalPlayer
local playerDataReplicator = DataController.PlayerDataReplicator
local spear = character.WaitDataFolder(localPlayer):WaitForChild("Stats"):WaitForChild("spear")
local equipment = HudController:GetSafeZone().equipment
local container = equipment.Container
local header = equipment.Header
local spears2 = container.Spears
local main = spears2.Main
local scrollingFrame = main.ScrollingFrame
local UI = script.UI
local color = Color3.fromRGB(162, 234, 166)
local color2 = Color3.fromRGB(81, 81, 81)
local color3 = Color3.fromRGB(175, 175, 175)

local function fmtStat(p)
	return (tostring(math.round((tonumber(p) or 0) * 100) / 100))
end

local folder = Instance.new("Folder")
folder.Name = "the evil spear zone"
folder.Parent = script
local count = 0
local v = {
	Piercing = {
		statKey = "Piercing",
		format = function(_, p, callback)
			return (`Piercing: {tostring(math.round((tonumber(p.Piercing) or 0) * 100) / 100)}{callback("Piercing")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color3
			}
		}
	},
	Power = {
		statKey = "Power",
		format = function(_, p, callback)
			return (`Power: {tostring(math.round((tonumber(p.Power) or 0) * 100) / 100)}{callback("Power")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color3
			}
		}
	},
	Handling = {
		statKey = "Handling",
		format = function(_, p, callback)
			return (`Handling: {tostring(math.round((tonumber(p.Handling) or 0) * 100) / 100)}{callback("Handling")}`)
		end,
		colorBands = {
			{
				threshold = 1e999,
				color = color3
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
				color = color3
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
				color = color3
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
				color = color3
			}
		}
	}
}
local settingValue = "Names"
local v2 = nil
local v3 = {
	Strength = "Max Kg",
	PreferredDisturbance = "Hunt Focus"
}
local v4 = ""

for _, spear2 in spears do
	if not spear2.Unregistered then
		count += 1
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRecord(p: string)
	return playerDataReplicator:TryIndex({ "Spears", p })
end

local function getPatchedStats(key: string)
	local spear2 = spears[key]

	if not spear2 then
		return nil, nil
	end

	local copy = GeneralUtils.copy(spear2, true)
	local record = getRecord(key) -- equivalent call inferred; original call site unknown

	if record then
		spearEnchants:ApplyToStats(copy, { record.enchant, record.secondaryEnchant }, localPlayer)
	end

	return spear2, copy
end

local function addBoostIndicator(p, p2, p3: string)
	local v5 = math.round(((p2[p3] or 0) - (p[p3] or 0)) * 100) / 100

	if v5 == 0 or v5 ~= v5 then
		return ""
	end

	return (` <font color="#ffd43a">({v5 > 0 and "+" or ""}{v5})</font>`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSymbol(p: string)
	local enchant = spearEnchants.Enchants[p]

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
	local v5 = p and spearEnchants.Enchants[p]

	if v5 then
		local symbol = getSymbol(p) -- equivalent call inferred; original call site unknown
		instance.RichText = true
		instance.Text = `{symbol} {spearEnchants:GetRichDisplayName(p)} {symbol}`
		instance.TextColor3 = v5.Color
		instance.Visible = true

		for _, image in { instance:FindFirstChild("bg"), instance:FindFirstChild("bg2") } do
			if image and image:IsA("ImageLabel") then
				image.ImageColor3 = v5.Color
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
	local v6 = playerDataReplicator:TryIndex({ "Spears", p.key })

	if not v6 then
		return
	end

	local enchants = p.Frame.Spear.Enchants
	local detail = enchants:FindFirstChild("detail")
	enchants.Visible = true
	applyEnchantLabel(enchants.enchant, v6.enchant)
	local secondary = detail and detail:FindFirstChild("secondary")

	if secondary and secondary:IsA("TextLabel") then
		applyEnchantLabel(secondary, v6.secondaryEnchant)
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

local function updateFavorited(data)
	local favorited = data.favorited
	local color4 = favorited and Color3.fromRGB(255, 162, 0) or Color3.fromRGB(255, 255, 255)
	local favorite = data.Frame.SpearOptions.favorite
	favorite.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
	favorite.ImageTransparency = favorited and 0.25 or 0.5
	favorite.ImageColor3 = color4
	data.Frame.Spear.SpearInfo.spearTitle.TextColor3 = color4
	local gridFrame = data.gridFrame

	if gridFrame then
		local favorite2 = gridFrame.SpearOptions:FindFirstChild("favorite")

		if favorite2 then
			favorite2.Image = favorited and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
			favorite2.ImageTransparency = favorited and 0.25 or 0.5
			favorite2.ImageColor3 = color4
		end

		gridFrame.spearTitle.TextColor3 = color4
	end
end

local function updateStats(data)
	local patchedStats, v5 = getPatchedStats(data.key)

	if not patchedStats then
		return
	end

	local v7 = playerDataReplicator:TryIndex({ "Spears", data.key })
	v5.Caught = tonumber(v7 and v7.caught) or 0
	local stats = data.Frame.Stats

	local function boosts(p: string)
		local v9 = math.round(((v5[p] or 0) - (patchedStats[p] or 0)) * 100) / 100

		if v9 == 0 or v9 ~= v9 then
			return ""
		end

		return (` <font color="#ffd43a">({v9 > 0 and "+" or ""}{v9})</font>`)
	end

	for childName, v8 in v do
		local child = stats:FindFirstChild(childName)

		if not child then
			continue
		end

		local v9 = v5[v8.statKey]
		local visible

		if v9 == nil then
			visible = false
		else
			visible = not v8.visibleIf or v8.visibleIf(v5)
		end

		child.Visible = visible

		if not visible then
			continue
		end

		child.Label.Text = v8.format(patchedStats, v5, boosts)
		local color4 = color3

		if typeof(v9) == "number" then
			for _, colorBand in v8.colorBands do
				if not (v9 < colorBand.threshold) then
					continue
				end

				color4 = colorBand.color
				break
			end
		end

		child.Label.TextColor3 = color4
		child.Icon.ImageColor3 = color4
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

local v5 = VirtualEquipmentList.new({
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
local entries = v5:GetEntries()

local function updateEquipped()
	if v2 and entries[v2.key] then
		local v6 = v2
		v6.Frame.Equip.UIStroke.Color = color
		v6.Frame.Equip.Label.TextColor3 = color
		v6.Frame.Equip.Label.Text = "[Equip]"

		if v6.gridFrame then
			v6.gridFrame.Equipped.Enabled = false
		end
	end

	v2 = nil
	local entry = entries[spear.Value]

	if entry then
		entry.Frame.Equip.UIStroke.Color = color2
		entry.Frame.Equip.Label.TextColor3 = color2
		entry.Frame.Equip.Label.Text = "[Equipped]"

		if entry.gridFrame then
			entry.gridFrame.Equipped.Enabled = true
		end

		v2 = entry
	end
end

local function updatePercent(flag: boolean?)
	if not (flag or spears2.Visible) then
		return
	end

	local count2 = 0

	for _ in entries do
		count2 += 1
	end

	local v6 = math.clamp(math.round(count2 / count * 1000) / 10, 0, 100)
	header.Complete.Text = `{v6}% Unlocked`
	header.Complete.TextColor3 = count <= count2 and Color3.fromRGB(255, 243, 153) or Color3.fromRGB(255, 255, 255)
end

local function createSpear(name: string)
	local spear2 = spears[name]

	if not spear2 or entries[name] or not playerDataReplicator:TryIndex({ "Spears", name }) then
		return
	end

	local maid = Trove.new()
	local clone = UI.Template:Clone()
	clone.AnchorPoint = Vector2.new(0, 0.5)
	clone.Name = name
	clone.Parent = folder
	local clone2 = UI.GridTemplate:Clone()
	clone2.AnchorPoint = Vector2.new(0, 0)
	clone2.Name = name
	clone2.Parent = folder
	local color4 = spear2.Color or Color3.fromRGB(255, 255, 255)
	local spearInfo = clone.Spear.SpearInfo
	spearInfo.spearTitle.Text = `[{name}]`
	clone.UIStroke.Color = color4
	clone.Gradient.BackgroundColor3 = color4
	clone.SpearImage.Image = spear2.Icon or ""
	clone2.spearTitle.Text = `[{name}]`
	clone2.UIStroke.Color = color4
	clone2.Gradient.BackgroundColor3 = color4
	clone2.SpearImage.Image = spear2.Icon or ""
	local modify = spearInfo.modify
	local description = spear2.Description or ""
	local v6 = "Less"

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateDescriptionMode(p: string)
		local text = description

		if p == "Less" then
			text = string.sub(text, 1, 75) .. "..."
		end

		spearInfo.desc.Text = text
		modify.Text = p == "Less" and "[More]" or "[Less]"
		clone.SpearImage.ImageTransparency = (p == "Less" or not modify.Visible) and 0 or 0.75
		clone.Stats.Visible = p == "Less" or not modify.Visible
	end

	local v7 = #description <= 75
	modify.Visible = not v7

	if v7 then
		spearInfo.desc.Text = description
	else
		local text = string.sub(description, 1, 75) .. "..."
		spearInfo.desc.Text = text
		modify.Text = "[More]"
		clone.SpearImage.ImageTransparency = 0
		clone.Stats.Visible = true
		maid:Connect(modify.Activated, function()
			v6 = v6 == "Less" and "More" or "Less"
			updateDescriptionMode(v6) -- equivalent call inferred; original call site unknown
		end)
	end

	local v8 = {
		Frame = clone,
		gridFrame = clone2,
		key = name,
		mounted = false,
		searchVisible = true,
		cachedIndex = nil,
		favorited = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Spears", name }) == true,
		trove = maid,
		changeStatDisplay = function(p)
			for _, frame in clone.Stats:GetChildren() do
				if not (frame:IsA("Frame") and frame:FindFirstChild("Label")) then
					continue
				end

				local text = string.match(frame.Label.Text, ":%s*(.+)") or frame.Label.Text
				frame.Label.Position = UDim2.fromScale(p == "Icons" and 0.18 or 0, 0.5)
				frame.Label.Visible = p ~= "Disabled"
				frame.Icon.Visible = p == "Icons"

				if p == "Names" then
					frame.Label.Text = `{v3[frame.Name] or frame.Name}: {text}`
				else
					frame.Label.Text = text
				end
			end
		end
	}
	updateStats(v8)
	updateEnchant(v8)

	local function tryEquip()
		if spear.Value == name then
			return
		end

		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.click1, scrollingFrame, false)
		remoteEvent:FireServer(name)
	end

	maid:Connect(clone.Equip.Activated, tryEquip)
	maid:Connect(clone2.Activated, tryEquip)
	local clone3 = table.clone(playerDataReplicator:TryIndex({ "Spears", name }) or {})
	maid:Add(playerDataReplicator:Listen({ "Spears", name }, function(p)
		if not p then
			return
		end

		local diff = patch.diff(clone3, p)
		clone3 = table.clone(p)

		if diff.caught ~= nil then
			v5:ScheduleUpdate(name, "stats")
		end

		if diff.enchant ~= nil or diff.secondaryEnchant ~= nil then
			v5:ScheduleUpdate(name, "enchant")
			v5:ScheduleUpdate(name, "stats")
		end
	end))
	local flag = false

	local function tryFavorite()
		if flag then
			return
		end

		flag = true
		v8.favorited = not v8.favorited
		updateFavorited(v8)

		if not remoteFunction:InvokeServer("Spears", name, v8.favorited) then
			v8.favorited = not v8.favorited
			updateFavorited(v8)
		end

		v5:Rebuild()
		flag = false
	end

	maid:Connect(clone.SpearOptions.favorite.Activated, tryFavorite)
	local favorite = clone2.SpearOptions:FindFirstChild("favorite")

	if favorite then
		maid:Connect(favorite.Activated, tryFavorite)
	end

	updateFavorited(v8)
	v5:AddEntry(name, v8)
	v5:Rebuild()
	updatePercent()
	updateEquipped()
end

local function removeSpear(p: string)
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

	v5:RemoveEntry(p)
	v5:Rebuild()
	updatePercent()
end

local function spearMatchesQuery(entry, query)
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

		if query.key == "enchant" then
			local v7 = playerDataReplicator:TryIndex({ "Spears", entry.key })
			local lower = (not v7 and "" or v7.enchant or ""):lower()
			local secondaryEnchant = (v7 and v7.secondaryEnchant or ""):lower()
			local val = query.val
			return lower:find(val, 1, true) ~= nil or secondaryEnchant:find(val, 1, true) ~= nil
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
		text:gsub(",", "")

		if query.key then
			if name:find(query.key, 1, true) then
				if query.compare then
					local number = EquipmentSearch.extractNumber(text)

					if number and query.compare(number) then
						return true
					end
				elseif text:find(query.val, 1, true) then
					return true
				end
			end
		elseif name:find(query.raw, 1, true) or text:find(query.raw, 1, true) then
			return true
		end
	end

	return false
end

local SpearsEquipment = {
	TabName = "Spears",
	SearchTip = [[
Example spear queries:
• <b>power</b>:&gt;2 - show results with more than 2 power
• <b>handling</b>:&gt;=30 - show results with 30% handling or more
• <b>piercing</b>:=30 - show results with exactly 30 piercing
• <b>enchant</b>:pointy - show results with a matching enchantment
• <b>favorited</b>:yes - show only favorited results
• use <b>commas</b> to combine searches - fav: yes, luck: &gt;50
• use &gt; &gt;= &lt;= = != to compare numbers]],
	Container = spears2,
	MainFrame = main,
	ShowsCompletion = true,
	UpdateHeader = function(_)
		updatePercent(true)
	end,
	SetActive = function(self, flag: boolean)
		v5:SetActive(flag)
	end,
	SetLayout = function(self, p: string)
		v5:SetLayout(p)
	end,
	UpdateSearch = function(self, value: string)
		v4 = value or ""
		local queries = EquipmentSearch.buildQueries(v4)

		for _, entry in entries do
			if queries then
				local searchVisible = true

				for _, query in queries do
					if spearMatchesQuery(entry, query) then
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

		v5:Rebuild()
	end
}

function SpearsEquipment.Init(_)
	if spear.Value ~= "Flimsy Spear" and spear.Value ~= "" and not spears[spear.Value] then
		remoteEvent:FireServer("Flimsy Spear")
	end

	local flag = false
	playerDataReplicator:ObserveKeys({ "Spears" }, function(name, p2)
		if p2 then
			createSpear(name)
		else
			removeSpear(name)
		end

		if flag then
			task.spawn(function()
				SpearsEquipment:UpdateSearch(v4)
			end)
		end
	end)
	flag = true
	spear:GetPropertyChangedSignal("Value"):Connect(updateEquipped)
	task.defer(updateEquipped)
	playerDataReplicator:Listen({ "FavoritedEquipment", "Spears" }, function()
		for k, entry in entries do
			entry.favorited = playerDataReplicator:TryIndex({ "FavoritedEquipment", "Spears", k }) == true
			v5:ScheduleUpdate(k, "favorited")
		end

		v5:Rebuild()
	end)

	local function updateStatAllDisplayTypes()
		if SettingsController:GetSettingValue("rodStatDisplay") == settingValue then
			return
		end

		settingValue = SettingsController:GetSettingValue("rodStatDisplay")

		for k, entry in entries do
			if entry.mounted then
				task.spawn(entry.changeStatDisplay, settingValue)
			else
				v5:ScheduleUpdate(k, "display")
			end
		end
	end

	SettingsController:GetSettingChangedSignal("rodStatDisplay"):Connect(updateStatAllDisplayTypes)
	task.defer(updateStatAllDisplayTypes)
	v5:Rebuild()
end

return SpearsEquipment