local v = {
	CompassUnlocked = false,
	CanUnlockCompass = false
}
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)
local TextUtil = require(ReplicatedStorage.Modules.Util.TextUtil)
local TrackedQuestFrame = require(script.Parent.ReactComponents.TrackedQuestFrame)
local BonusMomentsGuide = require(ReplicatedStorage.BonusMomentsGuide)
local Signal = require(game.ReplicatedStorage.Modules.Util.Signal)
local onUpdate = Signal.new()
task.defer(function()
	local Net = require(game.ReplicatedStorage.Modules.Net)
	local remoteFunction = Net:RemoteFunction("GuideDataUpdate")
	Net:RemoteEvent("GuideDataUpdate").OnClientEvent:Connect(function(items)
		for k, item in items do
			v[k] = item
			onUpdate:Fire(k, item)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function getCompassTracker()
		local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
		return CompassTracker
	end

	local function normalizeTrackerOptions(p)
		local target = p.Target

		if typeof(target) == "Instance" and target:IsA("Vector3Value") then
			function p.Target()
				return target.Value
			end
		end

		return p
	end

	Net:RemoteEvent("GuideTracker").OnClientEvent:Connect(function(p: string, p2, p3)
		if typeof(p2) == "table" then
			p3 = p2
			p2 = "Create"
		end

		local compassTracker = getCompassTracker() -- equivalent call inferred; original call site unknown

		if p2 == "Create" or p2 == "Update" then
			local createTracker = compassTracker.createTracker
			local target = p3.Target

			if typeof(target) == "Instance" and target:IsA("Vector3Value") then
				function p3.Target()
					return target.Value
				end
			end

			createTracker(p, p3)
		elseif p2 == "Destroy" or p2 == "Remove" then
			compassTracker.removeTracker(p)
		elseif p2 == "SetDefaultOverride" then
			local setDefaultOverride = compassTracker.setDefaultOverride
			local target = p3.Target

			if typeof(target) == "Instance" and target:IsA("Vector3Value") then
				function p3.Target()
					return target.Value
				end
			end

			setDefaultOverride(p, p3)
		elseif p2 == "ClearDefaultOverride" then
			compassTracker.clearDefaultOverride(p)
		end
	end)
	task.spawn(function()
		local v3 = remoteFunction:InvokeServer("GetGuideData")

		if v3 then
			for k, v4 in v3 do
				v[k] = v4
				onUpdate:Fire(k, v4)
			end
		end

		local rewardTracker = BonusMomentsGuide.getRewardTracker()

		if rewardTracker then
			local setDefaultOverride = (getCompassTracker()).setDefaultOverride
			local ownerId = rewardTracker.OwnerId
			local options = rewardTracker.Options
			local target = options.Target

			if typeof(target) == "Instance" and target:IsA("Vector3Value") then
				function options.Target()
					return target.Value
				end
			end

			setDefaultOverride(ownerId, options)
		end
	end)
end)
local v3 = nil
local v4 = nil
local v5 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function getSideCompass()
	return require(script.Parent.SideCompass)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateTrackedQuestEnabled()
	if v3 then
		v3.Enabled = not v5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatNumber(value)
	if typeof(value) == "number" then
		return TextUtil.commaValue(value)
	end

	return (tostring(value))
end

local function pluralize(p: string, value)
	if typeof(value) == "number" and value > 1 then
		return p .. "s"
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getTaskAmount(value)
	if typeof(value) == "number" then
		return value
	end

	if typeof(value) == "table" and typeof(value.Amount) == "number" then
		return value.Amount
	end

	return nil
end

local function getTaskText(p, k: string, amount)
	if typeof(amount) == "table" and typeof(amount.text) == "string" then
		return amount.text
	end

	if typeof(amount) ~= "number" then
		if typeof(amount) == "table" and typeof(amount.Amount) == "number" then
			amount = amount.Amount
		else
			amount = nil
		end
	end

	local v6 = not p.Info.Predicate and "" or p.Info.Predicate .. " "

	if p.Info.Job then
		return k
	end

	if p.Info.CustomTasks or p.Info.NoEdit then
		local v8

		if amount and amount ~= 1 then
			local v9 = formatNumber(amount) -- equivalent call inferred; original call site unknown
			v8 = v9 .. " "
		else
			v8 = ""
		end

		if typeof(amount) == "number" and amount > 1 then
			k ..= "s"
		end

		return (`{v8}{k}`)
	else
		local v8

		if amount and amount ~= 1 then
			local v9 = formatNumber(amount) -- equivalent call inferred; original call site unknown
			v8 = v9 .. " "
		else
			v8 = ""
		end

		if typeof(amount) == "number" and amount > 1 then
			k ..= "s"
		end

		return (`{v6}Defeat {v8}{k}`)
	end
end

local function buildQuestProgress(p)
	local result = p.Info.Job and not p.Info.HideProgress and {} or nil
	local total = 0
	local total2 = 0

	for k, v6 in p.Info.Task do
		local taskAmount = getTaskAmount(v6) -- equivalent call inferred; original call site unknown
		local v7 = p.Progress[k]
		local max = not (taskAmount and taskAmount > 0) and 1 or taskAmount
		local current

		if v7 == true then
			current = max
		else
			current = (not taskAmount or not (taskAmount > 0) or typeof(v7) ~= "number") and 0 or math.clamp(v7, 0, max)
		end

		total += current
		total2 += max

		if not result then
			continue
		end

		local v10 = {
			Key = k,
			Text = getTaskText(p, k, v6),
			Current = current,
			Max = max,
			Deadline = 0
		}
		local deadline

		if typeof(v6) == "table" then
			deadline = v6.timer
		end

		v10.Deadline = deadline
		table.insert(result, v10)
	end

	if result then
		table.sort(result, function(a, b)
			return a.Key < b.Key
		end)
	end

	local v6 = ""

	if p.Info.HideProgress then
		v6 = ""
	elseif p.Info.DisplayProgressAsPercentage and total2 > 0 then
		v6 = `{math.floor(total / total2 * 100)}%`
	elseif total2 > 0 then
		local v8 = formatNumber(total) -- equivalent call inferred; original call site unknown
		local v9 = formatNumber(total2) -- equivalent call inferred; original call site unknown
		v6 = `{v8}/{v9}`
	end

	return total, total2, v6, result
end

local function buildQuestTitle(p)
	local v6 = {}

	for k, v7 in p.Info.Task do
		table.insert(v6, (getTaskText(p, k, v7)))
	end

	if #v6 == 0 then
		return p.Info.CustomTitle or p.Info.Name or p.InternalQuestName or "Quest"
	end

	return table.concat(v6, "\n")
end

local function buildQuestRewards(p)
	local v6 = {}
	local reward = p.Info.Reward or {}

	if reward.Beli then
		table.insert(v6, {
			Key = "money",
			Text = "$" .. TextUtil.commaValue(reward.Beli),
			Icon = "rbxassetid://11854849691",
			TextColor = Color3.fromRGB(168, 255, 148),
			AccentColor = Color3.fromRGB(126, 195, 106)
		})
	end

	if reward.Exp then
		table.insert(v6, {
			Key = "experience",
			Text = TextUtil.commaValue(reward.Exp) .. " EXP",
			Icon = "rbxassetid://11850730223",
			TextColor = Color3.fromRGB(255, 230, 53),
			AccentColor = Color3.fromRGB(255, 214, 49),
			IconProps = {
				Position = UDim2.fromScale(0.015, 0.507),
				Size = UDim2.fromScale(0.211318, 1.047)
			},
			TextProps = {
				Position = UDim2.fromScale(0.2, 0.5),
				Size = UDim2.fromScale(0.763559, 0.75)
			}
		})
	end

	if reward.Custom then
		table.insert(v6, {
			Key = "custom",
			Text = reward.Custom,
			TextColor = Color3.new(1, 1, 1),
			IconProps = {
				Visible = false
			},
			TextProps = {
				Position = UDim2.fromScale(0.02, 0.5),
				Size = UDim2.fromScale(0.95, 0.75)
			}
		})
	end

	return v6
end

local function getTrackedQuestRoot()
	if v4 and v3 and v3.Parent then
		return v4
	end

	if v4 then
		v4:unmount()
		v4 = nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TrackedQuestFrame"
	screenGui.DisplayOrder = 0
	screenGui.IgnoreGuiInset = true
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = not v5
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	v3 = screenGui
	v4 = ReactRoblox.createRoot(screenGui)
	return v4
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unmountTrackedQuest()
	if v4 then
		v4:unmount()
		v4 = nil
	end

	if v3 then
		v3:Destroy()
		v3 = nil
	end

	local sideCompass = getSideCompass() -- equivalent call inferred; original call site unknown
	sideCompass.setTrackedQuestVisible(false)
end

local function mountTrackedQuest(questData)
	local questProgress, progressMax, progressText, objectives = buildQuestProgress(questData)
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local sideCompass = getSideCompass() -- equivalent call inferred; original call site unknown
	sideCompass.setTrackedQuestVisible(true)
	updateTrackedQuestEnabled() -- equivalent call inferred; original call site unknown
	local trackedQuestRoot = getTrackedQuestRoot()
	local createElement = React.createElement
	local title

	if objectives then
		title = questData.Info.CustomTitle or questData.Info.Name
	else
		title = buildQuestTitle(questData)
	end

	trackedQuestRoot:render(createElement(TrackedQuestFrame, {
		Title = title,
		Description = questData.Info.CustomTitle or questData.Info.Name or questData.InternalQuestName or "",
		ProgressCurrent = questProgress,
		ProgressMax = progressMax,
		ProgressText = progressText,
		Objectives = objectives,
		Rewards = buildQuestRewards(questData),
		OnAbandonQuest = function()
			unmountTrackedQuest() -- equivalent call inferred; original call site unknown
			task.spawn(function()
				remotes:WaitForChild("CommF_"):InvokeServer("AbandonQuest")
			end)
		end
	}))
end

task.spawn(function()
	ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("QuestUpdate").OnClientEvent:Connect(function(questData, _)
		if questData then
			v.QuestData = questData
			onUpdate:Fire("QuestData", questData)
			mountTrackedQuest(questData)
		else
			v.QuestData = nil
			onUpdate:Fire("QuestData", nil)
			unmountTrackedQuest() -- equivalent call inferred; original call site unknown
		end
	end)
end)
local GuideData = {}
GuideData.OnUpdate = onUpdate
GuideData.Data = v

function GuideData.setMenuHidden(flag: boolean)
	v5 = flag
	updateTrackedQuestEnabled() -- equivalent call inferred; original call site unknown
end

function GuideData.HandleUpdate(p: string, callback)
	onUpdate:Connect(function(p2, p3)
		if p2 == p then
			callback(p3)
		end
	end)

	if v[p] ~= nil then
		task.spawn(callback, v[p])
	end
end

return GuideData