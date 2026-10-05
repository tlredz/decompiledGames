local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RaceConfig = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("RaceConfig"))
local RaceFormat = require(ReplicatedStorage.Services.RaceFormat)
local RaceController = require(script.Parent.RaceController)
local TAG_CHRONO_TOGGLE = RaceConfig.TAG_CHRONO_TOGGLE
local TAG_CHRONO_LABEL = RaceConfig.TAG_CHRONO_LABEL
local COLOR_AHEAD = RaceConfig.COLOR_AHEAD
local COLOR_BEHIND = RaceConfig.COLOR_BEHIND
local COLOR_GOLD = RaceConfig.COLOR_GOLD
local formatTime = RaceFormat.FormatTime
local formatDelta = RaceFormat.FormatDelta
local raceChrono = RaceController.GetRaceChrono()
local v = false
local localPlayer = Players.LocalPlayer

-- equivalent calls inferred from this helper; original call sites unknown
local function forEachTagged(TAG_CHRONO_LABEL2: string, wireLabel)
	for _, v2 in CollectionService:GetTagged(TAG_CHRONO_LABEL2) do
		wireLabel(v2)
	end
end

local function deltaMarkup(p: number?, flag: boolean)
	if not p then
		return ""
	end

	local v2

	if flag then
		v2 = COLOR_GOLD
	elseif p < 0 then
		v2 = COLOR_AHEAD
	else
		v2 = COLOR_BEHIND
	end

	return string.format("  <font color=\"%s\">(%s)%s</font>", v2, formatDelta(p), flag and " ★GOLD" or "")
end

local function buildLabelText()
	local bestTime = raceChrono:GetBestTime()
	local v2 = string.format("Personal Best: %s", bestTime and formatTime(bestTime) or RaceConfig.TIME_PLACEHOLDER)
	local liveState = RaceController.GetLiveState()

	if not liveState.running then
		return v2
	end

	local v3 = string.format("Chrono: %s%s", formatTime(liveState.cumElapsed), deltaMarkup(liveState.cumDelta, false))
	local v4 = string.format(
		"Seg %d: %s%s",
		liveState.segIndex,
		formatTime(liveState.segElapsed),
		deltaMarkup(liveState.segDelta, liveState.segIsGold)
	)
	return string.format([[
%s
%s
%s]], v3, v4, v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshLabel()
	for _, v2 in CollectionService:GetTagged(TAG_CHRONO_LABEL) do
		v2.Text = v and buildLabelText() or ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function wireLabel(label)
	if not label:IsA("TextLabel") then
		return
	end

	label.RichText = true
end

local heartbeatConnection = nil

local function setHeartbeat(flag: boolean)
	if flag and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(refreshLabel)
	elseif not flag and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

forEachTagged(TAG_CHRONO_LABEL, wireLabel) -- equivalent call inferred; original call site unknown
CollectionService:GetInstanceAddedSignal(TAG_CHRONO_LABEL):Connect(wireLabel)

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshToggle(button)
	button.BackgroundColor3 = v and Color3.fromHex(COLOR_AHEAD) or Color3.fromHex(RaceConfig.COLOR_TOGGLE_OFF)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshAllToggles()
	for _, button in CollectionService:GetTagged(TAG_CHRONO_TOGGLE) do
		if not button:IsA("GuiButton") then
			continue
		end

		refreshToggle(button) -- equivalent call inferred; original call site unknown
	end
end

local function wireButton(button)
	if not button:IsA("GuiButton") then
		return
	end

	refreshToggle(button) -- equivalent call inferred; original call site unknown
	button.Activated:Connect(function()
		localPlayer:SetAttribute("SpeedrunChronoEnabled", not v)
	end)
end

for _, button in CollectionService:GetTagged(TAG_CHRONO_TOGGLE) do
	if not button:IsA("GuiButton") then
		continue
	end

	refreshToggle(button) -- equivalent call inferred; original call site unknown
	button.Activated:Connect(function()
		localPlayer:SetAttribute("SpeedrunChronoEnabled", not v)
	end)
end

CollectionService:GetInstanceAddedSignal(TAG_CHRONO_TOGGLE):Connect(wireButton)

local function syncFromAttribute()
	local speedrunChronoEnabled = localPlayer:GetAttribute("SpeedrunChronoEnabled") == true

	if speedrunChronoEnabled == v then
		return
	end

	v = speedrunChronoEnabled
	RaceController.SetEnabled(v)
	local v2 = v

	if v2 and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(refreshLabel)
	elseif not v2 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	refreshAllToggles() -- equivalent call inferred; original call site unknown
	refreshLabel() -- equivalent call inferred; original call site unknown
end

localPlayer:GetAttributeChangedSignal("SpeedrunChronoEnabled"):Connect(syncFromAttribute)
local speedrunChronoEnabled = localPlayer:GetAttribute("SpeedrunChronoEnabled") == true

if speedrunChronoEnabled ~= v then
	v = speedrunChronoEnabled
	RaceController.SetEnabled(v)
	local v2 = v

	if v2 and not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(refreshLabel)
	elseif not v2 and heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	refreshAllToggles() -- equivalent call inferred; original call site unknown

	for _, v3 in CollectionService:GetTagged(TAG_CHRONO_LABEL) do
		v3.Text = not v and "" or buildLabelText() or ""
	end
end

raceChrono.NewBestTime:Connect(function()
	refreshLabel() -- equivalent call inferred; original call site unknown
end)

for _, v2 in CollectionService:GetTagged(TAG_CHRONO_LABEL) do
	v2.Text = not v and "" or buildLabelText() or ""
end

return {}