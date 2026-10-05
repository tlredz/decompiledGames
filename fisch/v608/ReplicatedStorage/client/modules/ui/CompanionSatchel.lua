local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local HudController = require(ReplicatedStorage.client.legacyControllers.HudController)
local fx = require(ReplicatedStorage.shared.modules.fx)
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local levelConfig = require(ReplicatedStorage.shared.modules.library.companions.levelConfig)
local ProgressCircle = require(ReplicatedStorage.shared.utils.ProgressCircle)
local localPlayer = Players.LocalPlayer
local companions2 = HudController:GetSafeZone():WaitForChild("companions")
local companions3 = companions2:WaitForChild("companions")
local safezone = companions3:WaitForChild("scroll"):WaitForChild("safezone")
local companionskins = companions2:WaitForChild("companionskins")
local safezone2 = companionskins:WaitForChild("scroll"):WaitForChild("safezone")
local skinstitle = companionskins:WaitForChild("skinstitle")
local customName = companionskins:WaitForChild("customName")
local saveButton = customName:WaitForChild("saveButton")
local textBox = customName:WaitForChild("textBox")
local passiveToggle = customName:WaitForChild("passiveToggle")
local back = companions2:WaitForChild("buttons"):WaitForChild("back")
local textBox2 = companions2:WaitForChild("Search"):WaitForChild("TextBox")
local close = companions2:WaitForChild("Close")
local percent = companions2:WaitForChild("percent")
local template = script:WaitForChild("template")
local skinTemplate = script:WaitForChild("skinTemplate")
local ui = ReplicatedStorage.resources.sounds.sfx.ui
local remoteFunction = Net:RemoteFunction("Companion/Equip")
local remoteFunction2 = Net:RemoteFunction("Companion/Favorite")
local remoteFunction3 = Net:RemoteFunction("Companion/ChangeSkin")
local remoteFunction4 = Net:RemoteFunction("Companion/ChangeNickname")
local color = Color3.fromRGB(255, 162, 0)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(162, 234, 166)
local color4 = Color3.fromRGB(81, 81, 81)
local color5 = Color3.fromRGB(234, 116, 118)
local MAX_LEVEL = levelConfig.MAX_LEVEL
local color6 = Color3.fromRGB(66, 66, 66)
local color7 = Color3.fromRGB(220, 220, 220)
local v = {}
local v2 = {}
local v3 = {}
local v4 = nil
local maid = Trove.new()
local flag = false
local skinSlots = {}
local maid2 = Trove.new()
local v5 = nil
local flag2 = false
local xpForLevel = levelConfig.xpForLevel

local function updatePercent()
	local count = 0

	for k in pairs(v) do
		if not companions.Companions[k] or companions.Companions[k].Unregistered then
			continue
		end

		count += 1
	end

	local registeredCount = companions.RegisteredCount
	percent.Text = `{not (registeredCount > 0) and 0 or math.clamp(math.floor(count / registeredCount * 100), 0, 100)}% Unlocked`

	if registeredCount > 0 and registeredCount <= count then
		percent.TextColor3 = Color3.fromRGB(200, 192, 106)
	else
		percent.TextColor3 = Color3.fromRGB(120, 120, 120)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyEquippedState(p: string, p2)
	local equip = p2.petFrame.equip

	if v4 == p then
		equip.Text = "[Unequip]"
		equip.TextColor3 = color5

		if equip:FindFirstChild("border") then
			equip.border.Color = color5
		end
	else
		equip.Text = "[Equip]"
		equip.TextColor3 = color3

		if equip:FindFirstChild("border") then
			equip.border.Color = color3
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyFavoriteState(p, flag3: boolean)
	local favorite = p.companionOptions.favorite
	favorite.Image = flag3 and "rbxassetid://104522512885034" or "rbxassetid://85452306516270"
	favorite.ImageTransparency = flag3 and 0.25 or 0.75
	local imageColor

	if flag3 then
		imageColor = color
	else
		imageColor = color2
	end

	favorite.ImageColor3 = imageColor
	local petName = p.petName
	local textColor

	if flag3 then
		textColor = color
	else
		textColor = Color3.fromRGB(255, 255, 255)
	end

	petName.TextColor3 = textColor
end

local function applyLevelState(p: string, p2: number, p3: number)
	local v6 = v3[p]

	if not v6 then
		return
	end

	v6.levelLabel.Text = tostring(p2)

	if MAX_LEVEL <= p2 then
		v6.circle.Progress = 100
		return
	end

	local v7 = xpForLevel(p2)
	local v8 = v7 > 0 and p3 / v7 * 100 or 0
	v6.circle.Progress = math.clamp(v8, 0, 100)
end

local function updateSearch()
	local v6 = textBox2.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")

	for k, v7 in pairs(v) do
		if v6 == "" then
			v7.Visible = true
		else
			v7.Visible = k:lower():find(v6, 1, true) ~= nil
		end
	end
end

local function resortTiles()
	local v6 = {}

	for k in pairs(v) do
		table.insert(v6, k)
	end

	table.sort(v6, function(a, b)
		local v7 = v[a].companionOptions.favorite.ImageTransparency ~= 0.75

		if v7 == (v[b].companionOptions.favorite.ImageTransparency ~= 0.75) then
			return a < b
		end

		return v7
	end)

	for i, v7 in ipairs(v6) do
		v[v7].LayoutOrder = i
	end
end

local function createLevelBadge(p: string, clone, maid3)
	local circle = ProgressCircle.new({
		Position = UDim2.fromOffset(5, 5),
		AnchorPoint = Vector2.new(0, 0),
		Size = 0.08,
		Thickness = 0.22,
		CircleSize = 0.85,
		Color = color7,
		BGColor = color6,
		BGRoundness = 1,
		Progress = 0,
		Rotation = 0
	})
	local parent = circle.Instance.Parent
	circle.Instance.Size = UDim2.fromOffset(38, 38)
	circle.Instance.Parent = clone.petFrame
	circle.Instance.ZIndex = 10

	if parent and parent:IsA("ScreenGui") and parent.Name == "CircularProgress" then
		parent:Destroy()
	end

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "LevelLabel"
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Position = UDim2.fromScale(0.5, 0.5)
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Text = "1"
	textLabel.ZIndex = 100
	textLabel.TextStrokeTransparency = 0.5
	textLabel.Parent = circle.Instance
	local uIPadding = Instance.new("UIPadding")
	uIPadding.PaddingTop = UDim.new(0.25, 0)
	uIPadding.PaddingBottom = UDim.new(0.25, 0)
	uIPadding.PaddingLeft = UDim.new(0.25, 0)
	uIPadding.PaddingRight = UDim.new(0.25, 0)
	uIPadding.Parent = textLabel
	v3[p] = {
		circle = circle,
		levelLabel = textLabel
	}
	maid3:Add(function()
		circle:Destroy()
		v3[p] = nil
	end)
end

local function applySkinEquippedState(instance, flag3: boolean)
	local equip = instance:FindFirstChild("equip")

	if not equip then
		return
	end

	if flag3 then
		equip.Text = "[Equipped]"
		equip.TextColor3 = color4

		if equip:FindFirstChild("border") then
			equip.border.Color = color4
		end
	else
		equip.Text = "[Equip]"
		equip.TextColor3 = color3

		if equip:FindFirstChild("border") then
			equip.border.Color = color3
		end
	end
end

local function createSkinSlot(p: string, name: string, flag3: boolean, skin: string)
	local clone = skinTemplate:Clone()
	clone.Name = name
	clone.Visible = true
	local companion = companions.Companions[p]
	local v6

	if not flag3 then
		v6 = skins.Skins[name] or nil
	end

	local companiontitle = clone:FindFirstChild("companiontitle")

	if companiontitle then
		if flag3 then
			companiontitle.Text = "Default"
		else
			local text

			if v6 then
				text = v6.DisplayText or name
			else
				text = name
			end

			companiontitle.Text = text
		end
	end

	local desc = clone:FindFirstChild("desc")

	if desc then
		desc.Text = not v6 and "" or v6.Description or ""
	end

	local icon = clone:FindFirstChild("icon")

	if icon then
		if flag3 then
			icon.Image = companion.Icon or ""
		else
			icon.Image = v6 and v6.Icon or companion.Icon or ""
		end
	end

	local rarity = clone:FindFirstChild("rarity")
	local bg2 = clone:FindFirstChild("bg2")

	if flag3 then
		if rarity then
			rarity.Visible = false
		end

		if bg2 then
			bg2.BackgroundColor3 = companion.Color
		end
	else
		local v7 = v6 and skins.Rarities[v6.Rarity]

		if rarity then
			if v7 and v6 then
				rarity.Visible = true
				rarity.Text = string.upper(v6.Rarity)
				rarity.TextColor3 = v7.Color
			else
				rarity.Visible = false
			end
		end

		if bg2 then
			bg2.BackgroundColor3 = v7 and v7.Color or companion.Color
		end
	end

	local bg = clone:FindFirstChild("bg")

	if bg then
		bg.BackgroundColor3 = companion.Color
	end

	applySkinEquippedState(clone, name == skin)
	local equip = clone:FindFirstChild("equip")

	if equip then
		maid2:Add(equip.MouseEnter:Connect(function()
			fx:PlaySound(ui.select, equip, false)
		end))
		maid2:Add(equip.Activated:Connect(function()
			if flag2 then
				return
			end

			flag2 = true
			fx:PlaySound(ui.click2, equip, false)
			equip.Text = "..."
			equip.TextColor3 = color4
			remoteFunction3:InvokeServer(p, name)
			task.wait(0.3)
			flag2 = false
		end))
	end

	return clone
end

local function cleanupSkinView()
	maid2:Clean()

	for _, v6 in pairs(skinSlots) do
		v6:Destroy()
	end

	skinSlots = {}
	v5 = nil
end

local fn

fn = function(p: string)
	cleanupSkinView()
	v5 = p
	local companion = companions.Companions[p]

	if not companion then
		return
	end

	skinstitle.Text = "Customize"
	local index = DataController.PlayerDataReplicator:Index({ "Companions", "Owned", p })
	local skin = index and index.Skin or companion.Skins[1]
	local v6 = DataController.PlayerDataReplicator:Index({ "Companions", "Skins" }) or {}
	local skin2 = companion.Skins[1]
	local skinSlot = createSkinSlot(p, skin2, true, skin)
	skinSlot.LayoutOrder = 1
	skinSlot.Parent = safezone2
	skinSlots[skin2] = skinSlot
	local skins2 = {}

	for i = 2, #companion.Skins do
		local skin3 = companion.Skins[i]

		if v6[skin3] then
			table.insert(skins2, skin3)
		end
	end

	table.sort(skins2, function(a, b)
		local skin3 = skins.Skins[a]
		local skin4 = skins.Skins[b]
		local v7 = skin3 and skins.Rarities[skin3.Rarity]
		local v8 = skin4 and skins.Rarities[skin4.Rarity]
		return (v7 and v7.Weight or 0) > (v8 and v8.Weight or 0)
	end)

	for i, v7 in ipairs(skins2) do
		local skinSlot2 = createSkinSlot(p, v7, false, skin)
		skinSlot2.LayoutOrder = i + 1
		skinSlot2.Parent = safezone2
		skinSlots[v7] = skinSlot2
	end

	maid2:Add(DataController.PlayerDataReplicator:Observe({ "Companions", "Owned", p }, function(p2)
		if v5 ~= p then
			return
		end

		local skin3 = p2 and p2.Skin or companion.Skins[1]

		for k, v7 in pairs(skinSlots) do
			applySkinEquippedState(v7, k == skin3)
		end
	end))
	local flag3 = true
	maid2:Add(DataController.PlayerDataReplicator:ObserveKeys({ "Companions", "Skins" }, function()
		if flag3 then
			return
		end

		if v5 == p then
			fn(p)
		end
	end))
	flag3 = false
end

local function refreshPassiveToggle(p: string?)
	local v6 = p and companions.Companions[p]
	local passiveToggle2 = v6 and v6.PassiveToggle

	if not passiveToggle2 then
		passiveToggle.Visible = false
		return
	end

	local v7 = DataController.PlayerDataReplicator:TryIndex(passiveToggle2.DataPath) ~= false
	local v8

	if v7 then
		v8 = color3
	else
		v8 = color5
	end

	passiveToggle.Text = `[{passiveToggle2.Label}: {v7 and "ON" or "OFF"}]`
	passiveToggle.TextColor3 = v8
	passiveToggle.borderStroke.Color = v8
	passiveToggle.Visible = true
end

local function togglePassive()
	local v6 = v5 and companions.Companions[v5]
	local passiveToggle2 = v6 and v6.PassiveToggle

	if not passiveToggle2 then
		return
	end

	local v7 = DataController.PlayerDataReplicator:TryIndex(passiveToggle2.DataPath) ~= false
	Net:RemoteEvent(passiveToggle2.Remote):FireServer(not v7)
	fx:PlaySound(ui.click2, passiveToggle, false)
end

local function openSkinView(p: string)
	companionskins.customName.textBox.Text = DataController.PlayerDataReplicator:TryIndex({
		"Companions",
		"Owned",
		p,
		"DisplayName"
	}) or ""
	refreshPassiveToggle(p)
	companions3.Visible = false
	companionskins.Visible = true
	back.Visible = true
	fn(p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function closeSkinView()
	cleanupSkinView()
	companions3.Visible = true
	companionskins.Visible = false
	back.Visible = false
end

local function createTile(p: string)
	if v[p] then
		return
	end

	local companion = companions.Companions[p]

	if not companion then
		warn((`[CompanionSatchel] No library entry for "{p}"`))
		return
	end

	local clone = template:Clone()
	clone.Name = p
	clone.Visible = true
	clone.petName.Text = p
	clone.petFrame.icon.Image = companion.Icon or ""
	clone.petFrame.desc.Text = companion.Description or ""

	if clone.petFrame:FindFirstChild("bg") then
		clone.petFrame.bg.BackgroundColor3 = companion.Color
	end

	if clone.petFrame:FindFirstChild("bg2") then
		clone.petFrame.bg2.BackgroundColor3 = companion.Color
	end

	local maid3 = Trove.new()
	v2[p] = maid3
	createLevelBadge(p, clone, maid3)
	local equip = clone.petFrame.equip
	maid3:Add(equip.MouseEnter:Connect(function()
		fx:PlaySound(ui.select, equip, false)
	end))
	maid3:Add(equip.Activated:Connect(function()
		if flag then
			return
		end

		flag = true
		fx:PlaySound(ui.click2, equip, false)
		equip.Text = "..."
		equip.TextColor3 = color4
		remoteFunction:InvokeServer(p)
		task.wait(0.3)
		flag = false
	end))
	local favorite = clone.companionOptions.favorite
	maid3:Add(favorite.MouseEnter:Connect(function()
		fx:PlaySound(ui.select, favorite, false)
	end))
	maid3:Add(favorite.Activated:Connect(function()
		fx:PlaySound(ui.click1, favorite, false)
		local v6 = remoteFunction2:InvokeServer(p)

		if v6 ~= nil then
			applyFavoriteState(clone, v6) -- equivalent call inferred; original call site unknown
			resortTiles()
		end
	end))
	local skin = clone.companionOptions:FindFirstChild("skin")

	if skin then
		maid3:Add(skin.MouseEnter:Connect(function()
			fx:PlaySound(ui.select, skin, false)
		end))
		maid3:Add(skin.Activated:Connect(function()
			fx:PlaySound(ui.click2, skin, false)
			openSkinView(p)
		end))
	end

	applyEquippedState(p, clone) -- equivalent call inferred; original call site unknown
	local index = DataController.PlayerDataReplicator:Index({ "Companions", "Owned", p })

	if index then
		local favorited = index.Favorited or false
		applyFavoriteState(clone, favorited) -- equivalent call inferred; original call site unknown
		local level = index.Level or 1
		local XP = index.XP or 0
		local v6 = v3[p]

		if v6 then
			v6.levelLabel.Text = tostring(level)

			if MAX_LEVEL <= level then
				v6.circle.Progress = 100
			else
				local v7 = xpForLevel(level)
				local v8 = v7 > 0 and XP / v7 * 100 or 0
				v6.circle.Progress = math.clamp(v8, 0, 100)
			end
		end
	end

	clone.Parent = safezone
	v[p] = clone
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeTile(p: string)
	local v6 = v2[p]

	if v6 then
		v6:Destroy()
		v2[p] = nil
	end

	local v7 = v[p]

	if v7 then
		v7:Destroy()
		v[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unloadTiles()
	for k in pairs(v) do
		removeTile(k) -- equivalent call inferred; original call site unknown
	end

	maid:Clean()
end

local function setupObservers()
	local playerDataReplicator = DataController.PlayerDataReplicator
	playerDataReplicator:WaitForLoaded()
	updatePercent()
	maid:Add(playerDataReplicator:ObserveKeys({ "Companions", "Owned" }, function(p, data)
		if data then
			if v[p] then
				local v6 = v[p]
				local favorited = data.Favorited or false
				applyFavoriteState(v6, favorited) -- equivalent call inferred; original call site unknown
				local level = data.Level or 1
				local XP = data.XP or 0
				local v7 = v3[p]

				if v7 then
					v7.levelLabel.Text = tostring(level)

					if MAX_LEVEL <= level then
						v7.circle.Progress = 100
					else
						local v8 = xpForLevel(level)
						local v9 = v8 > 0 and XP / v8 * 100 or 0
						v7.circle.Progress = math.clamp(v9, 0, 100)
					end
				end

				resortTiles()
			else
				createTile(p)
				resortTiles()
				updatePercent()
				updateSearch()
			end
		else
			removeTile(p) -- equivalent call inferred; original call site unknown
			updatePercent()
		end
	end))
	maid:Add(playerDataReplicator:Observe({ "Companions", "Equipped" }, function(p)
		local v6 = v4

		if p == "" then
			p = nil
		end

		v4 = p

		if v6 and v[v6] then
			applyEquippedState(v6, v[v6]) -- equivalent call inferred; original call site unknown
		end

		if v4 and v[v4] then
			applyEquippedState(v4, v[v4]) -- equivalent call inferred; original call site unknown
		end
	end))
end

local flag3 = false

local function updateNickname()
	if not v5 or flag3 then
		return
	end

	flag3 = true
	saveButton.Text = "[...]"
	saveButton.TextColor3 = color4
	saveButton.borderStroke.Color = color4
	local v6, text = remoteFunction4:InvokeServer(v5, textBox.Text)
	textBox.Text = text
	flag3 = false
	saveButton.Text = "[Submit]"
	saveButton.TextColor3 = color3
	saveButton.borderStroke.Color = color3

	if v6 then
		fx:PlaySound(ui.equip, saveButton, false)
	else
		fx:PlaySound(ui.boowomp, saveButton, false)
	end
end

return {
	init = function()
		companions2:GetPropertyChangedSignal("Visible"):Connect(function()
			if companions2.Visible then
				setupObservers()
				return
			end

			unloadTiles() -- equivalent call inferred; original call site unknown
		end)
		close.Activated:Connect(function()
			fx:PlaySound(ui.click2, close, false)
			local character = localPlayer.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")

			if humanoid then
				humanoid:UnequipTools()
			end
		end)
		back.Activated:Connect(function()
			fx:PlaySound(ui.click2, back, false)
			closeSkinView() -- equivalent call inferred; original call site unknown
		end)
		textBox2:GetPropertyChangedSignal("Text"):Connect(updateSearch)
		saveButton.Activated:Connect(updateNickname)
		passiveToggle.Activated:Connect(togglePassive)
		DataController.PlayerDataReplicator:Observe({ "Skycrest", "SacrificialEnabled" }, function()
			if companionskins.Visible then
				refreshPassiveToggle(v5)
			end
		end)
		textBox.FocusLost:Connect(function(p)
			if p then
				updateNickname()
			end
		end)
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			if #textBox.Text > 32 then
				textBox.Text = textBox.Text:sub(1, 32)
			end
		end)
	end
}