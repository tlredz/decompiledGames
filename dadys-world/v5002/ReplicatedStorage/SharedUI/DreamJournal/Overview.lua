local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("MyDataController"))
local Achievements = require(ReplicatedStorage.SharedData.Achievements)
local Stickers = require(ReplicatedStorage.SharedData.Stickers)
local localPlayer = Players.LocalPlayer
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local v = {
	[Enum.PlaybackState.Completed] = true,
	[Enum.PlaybackState.Cancelled] = true
}

local function hasArtwork(p)
	if type(p) ~= "table" then
		return false
	end

	if type(p.Image) == "string" and p.Image ~= "" then
		return true
	elseif type(p.DisplayImage) == "string" then
		return p.DisplayImage ~= ""
	else
		return false
	end
end

local count = 0
local v2 = {
	MedalProgress = "Medals",
	CollectionProgress = "Collection",
	Profile = "Profiles"
}

for _, sticker in pairs(Stickers) do
	local v3

	if type(sticker) == "table" then
		if type(sticker.Image) == "string" and sticker.Image ~= "" then
			v3 = true
		elseif type(sticker.DisplayImage) == "string" then
			v3 = sticker.DisplayImage ~= ""
		else
			v3 = false
		end
	else
		v3 = false
	end

	if v3 then
		count += 1
	end
end

local function stickersOwned(data)
	local stickersOwned2 = data and data.StickersOwned

	if type(stickersOwned2) ~= "table" then
		return 0
	end

	local v3 = {}
	local count2 = 0

	for _, v4 in pairs(stickersOwned2) do
		if type(v4) ~= "string" or v3[v4] then
			continue
		end

		local sticker = Stickers[v4]
		local v5

		if type(sticker) == "table" then
			if type(sticker.Image) == "string" and sticker.Image ~= "" then
				v5 = true
			elseif type(sticker.DisplayImage) == "string" then
				v5 = sticker.DisplayImage ~= ""
			else
				v5 = false
			end
		else
			v5 = false
		end

		if not v5 then
			continue
		end

		v3[v4] = true
		count2 += 1
	end

	return count2
end

local function medalCounts(data)
	local standard = Achievements.All and Achievements.All.Standard

	if type(standard) ~= "table" then
		return 0, 0
	end

	local dreamJournal = data and data.DreamJournal
	local achievements = dreamJournal and dreamJournal.Achievements
	local v3 = type(achievements) ~= "table" and {} or achievements
	local count2 = 0
	local count3 = 0

	for k, v4 in pairs(standard) do
		local v5 = v3[k]
		local v6 = (type(v5) ~= "table" or type(v5.Progress) ~= "number") and 0 or v5.Progress or 0
		local v7 = type(v4.Requirement) ~= "number" and 0 or v4.Requirement or 0
		local v8

		if v7 > 0 then
			v8 = v7 <= v6
		else
			v8 = false
		end

		if not (v8 or not v4.Hidden) then
			continue
		end

		count2 += 1

		if v8 then
			count3 += 1
		end
	end

	return count3, count2
end

local function tileScale(parent)
	local v3 = parent:FindFirstChildOfClass("UIScale")

	if not v3 then
		v3 = Instance.new("UIScale")
		v3.Parent = parent
	end

	return v3
end

local function tileButton(button)
	if button:IsA("GuiButton") then
		return button
	end

	local textButton = button:FindFirstChildWhichIsA("TextButton")

	if textButton then
		return textButton
	end

	local textButton2 = Instance.new("TextButton")
	textButton2.Name = "Button"
	textButton2.BackgroundTransparency = 1
	textButton2.Text = ""
	textButton2.AutoButtonColor = false
	textButton2.BorderSizePixel = 0
	textButton2.AnchorPoint = Vector2.new(0.5, 0.5)
	textButton2.Position = UDim2.fromScale(0.5, 0.5)
	textButton2.Size = UDim2.fromScale(1, 1)
	textButton2.ZIndex = 10
	textButton2.Parent = button
	return textButton2
end

local function streakValue(p)
	local statistics = p and p.Statistics
	local currentDailyStreak = type(statistics) == "table" and statistics.CurrentDailyStreak or nil
	return type(currentDailyStreak) == "number" and currentDailyStreak or 0
end

return function(object)
	local page = object:FindPage("Overview")

	if not page then
		warn("[Overview] no Overview page frame found")
		return
	end

	local margin = page:FindFirstChild("Margin")

	if not margin then
		warn("[Overview] no Margin frame found")
		return
	end

	local function progressLabel(childName: string)
		local child = margin:FindFirstChild(childName)
		local progress = child and child:FindFirstChild("Progress")

		if progress and progress:IsA("TextLabel") then
			return progress
		end

		warn(("[Overview] %s has no Progress TextLabel"):format(childName))
		return nil
	end

	local v3 = progressLabel("MedalProgress")
	local v4 = progressLabel("CollectionProgress")
	local v5 = nil

	if object:IsCapabilityEnabled("dailyStreak") then
		v5 = progressLabel("DailyLoginProgress")
	else
		local dailyLoginProgress = margin:FindFirstChild("DailyLoginProgress")

		if dailyLoginProgress and dailyLoginProgress:IsA("GuiObject") then
			dailyLoginProgress.Visible = false
		end
	end

	local username = margin:FindFirstChild("Username") or page:FindFirstChild("Username")

	if username and username:IsA("TextLabel") then
		username.Text = localPlayer.Name
	else
		warn("[Overview] no Username TextLabel found")
	end

	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopTile(p)
		local tween = p.tween
		p.tween = nil

		if tween and not v[tween.PlaybackState] then
			tween:Cancel()
			tween:Destroy()
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function playTile(p, p2, scale: number)
		stopTile(p) -- equivalent call inferred; original call site unknown
		p.tween = object.tweens.playTween(p.scale, p2, {
			Scale = scale
		})
	end

	local function bindTile(childName: string, p: string)
		local guiObject = margin:FindFirstChild(childName)

		if not (guiObject and guiObject:IsA("GuiObject")) then
			warn(("[Overview] %s frame not found; no shortcut bound"):format(childName))
			return
		end

		if not object:_isPageEnabled(p) then
			guiObject.Visible = false
			return
		end

		local v7 = {
			scale = 0,
			tween = nil
		}
		local scale = guiObject:FindFirstChildOfClass("UIScale")

		if not scale then
			scale = Instance.new("UIScale")
			scale.Parent = guiObject
		end

		v7.scale = scale
		local v9 = tileButton(guiObject)
		table.insert(v6, v7)
		local v10 = false
		v9.MouseEnter:Connect(function()
			v10 = true
			playTile(v7, tweenInfo, 1.04) -- equivalent call inferred; original call site unknown
		end)
		v9.MouseLeave:Connect(function()
			v10 = false
			playTile(v7, tweenInfo2, 1) -- equivalent call inferred; original call site unknown
		end)
		v9.MouseButton1Down:Connect(function()
			playTile(v7, tweenInfo3, 0.97) -- equivalent call inferred; original call site unknown
		end)
		v9.MouseButton1Up:Connect(function()
			playTile(v7, tweenInfo, v10 and 1.04 or 1) -- equivalent call inferred; original call site unknown
		end)
		object:BindTab(v9, p)
	end

	for k, v7 in pairs(v2) do
		bindTile(k, v7)
	end

	page:GetPropertyChangedSignal("Visible"):Connect(function()
		if page.Visible then
			return
		end

		for _, v7 in ipairs(v6) do
			stopTile(v7) -- equivalent call inferred; original call site unknown
			v7.scale.Scale = 1
		end
	end)
	MyDataController:onReplicaReady(function(object2)
		local function refresh()
			local data = object2.Data

			if v3 then
				local v7, v8 = medalCounts(data)
				v3.Text = string.format("%d/%d", v7, v8)
			end

			if v4 then
				v4.Text = string.format("%d/%d", stickersOwned(data), count)
			end

			if v5 then
				local v7 = v5
				local statistics = data and data.Statistics
				local currentDailyStreak

				if type(statistics) == "table" then
					currentDailyStreak = statistics.CurrentDailyStreak or nil
				end

				v7.Text = tostring(type(currentDailyStreak) == "number" and currentDailyStreak or 0)
			end
		end

		object2:ListenToArrayInsert("StickersOwned", refresh)
		object2:ListenToChange("StickersOwned", refresh)

		if v5 then
			object2:ListenToChange("Statistics.CurrentDailyStreak", refresh)
		end

		page:GetPropertyChangedSignal("Visible"):Connect(function()
			if page.Visible and object.gui.Visible then
				refresh()
			end
		end)
		object.gui:GetPropertyChangedSignal("Visible"):Connect(function()
			if object.gui.Visible and page.Visible then
				refresh()
			end
		end)
		refresh()
	end, function()
		warn("[Overview] replica unavailable; counters left as authored")
	end)
end