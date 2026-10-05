local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ClientState = require(ReplicatedStorage:WaitForChild("ClientState"))
local BonusManager = require(ReplicatedStorage:WaitForChild("BonusManager"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))
local BonusDisplay = {}
local v = { "XP", "Wins" }
local v2 = {
	XP = {
		icon = "⚡",
		color = Color3.fromRGB(100, 200, 255),
		label = "XP"
	},
	Wins = {
		icon = "🏆",
		color = Color3.fromRGB(255, 215, 0),
		label = Config.GetWinsLabel()
	}
}
local v3 = {
	AdminAbuse = {
		label = "Admin",
		sortOrder = 1,
		color = Color3.fromRGB(255, 215, 0)
	},
	EventBoost = {
		label = "Event",
		sortOrder = 2
	},
	LuckyMinute = {
		label = "Lucky Minute",
		sortOrder = 3,
		color = Color3.fromRGB(255, 226, 70)
	},
	ChocolateHunt = {
		label = "Chocolate Hunt",
		sortOrder = 4,
		color = Color3.fromRGB(255, 190, 95)
	},
	ServerBoost = {
		label = "Server Boost",
		sortOrder = 5
	},
	EventRsvp = {
		label = "Event RSVP",
		sortOrder = 6
	},
	CC = {
		label = "CC",
		sortOrder = 7,
		color = Color3.fromRGB(190, 120, 255)
	},
	Default = {
		label = "Bonus",
		sortOrder = 99
	}
}
local parent = nil
local v5 = {}
local flag = false
local flag2 = false
local v6 = false

local function formatTime(remainingTime: number)
	if remainingTime <= 0 then
		return "0:00"
	end

	local v7 = math.floor(remainingTime / 3600)
	local v8 = math.floor(remainingTime % 3600 / 60)
	local v9 = remainingTime % 60

	if v7 > 0 then
		return string.format("%d:%02d:%02d", v7, v8, v9)
	end

	return string.format("%d:%02d", v8, v9)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBoostKindLabel(kind: string?)
	if not kind then
		return "Bonus"
	end

	local v7 = v3[kind]

	if v7 then
		return v7.label
	end

	return (tostring(kind or "Bonus"))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getBoostKindSortOrder(p: string?)
	if not p then
		return 50
	end

	local v7 = v3[p]

	if v7 then
		return v7.sortOrder
	end

	return 50
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSourceLayoutOrder(bonusType: string, kind: string)
	local v7 = bonusType == "XP" and 0 or 1000
	local boostKindSortOrder = getBoostKindSortOrder(kind) -- equivalent call inferred; original call site unknown
	return v7 + boostKindSortOrder
end

local function getSourceKey(p: string, p2: string)
	return p .. "_" .. p2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSourceTextColor(p: string, kind: string)
	local v7 = v2[p]

	if p == "XP" then
		return v7.color
	end

	local v8 = v3[kind]

	if v8 and v8.color then
		return v8.color
	end

	return v7.color
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getRemainingTime(endTime: number?)
	return BonusManager:GetRemainingTime(endTime)
end

local function formatSourceRowText(p: string, data)
	local v7 = v2[p]
	local remainingTime = getRemainingTime(data.endTime) -- equivalent call inferred; original call site unknown
	local icon = v7.icon
	local boostKindLabel = getBoostKindLabel(data.kind) -- equivalent call inferred; original call site unknown
	return icon .. " " .. boostKindLabel .. " " .. v7.label .. " x" .. data.mult .. "  " .. formatTime(remainingTime)
end

local function setupGui()
	if parent and parent.Parent or not RunService:IsClient() then
		return
	end

	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local bonusDisplayGUI = playerGui:FindFirstChild("BonusDisplayGUI")

	if bonusDisplayGUI then
		bonusDisplayGUI:Destroy()
	end

	v5 = {}
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "BonusDisplayGUI"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.Name = "BonusContainer"
	frame.Size = UDim2.new(0, 300, 0, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Position = UDim2.new(1, -15, 1, -15)
	frame.AnchorPoint = Vector2.new(1, 1)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	local uIListLayout = Instance.new("UIListLayout")
	uIListLayout.Padding = UDim.new(0, 4)
	uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	uIListLayout.Parent = frame
	parent = frame
end

local function createSourceRow(bonusType: string, source, layoutOrder: number)
	if not (v2[bonusType] and parent) then
		return nil
	end

	local frame = Instance.new("Frame")
	frame.Name = bonusType .. "_" .. source.kind
	frame.LayoutOrder = layoutOrder
	frame.Size = UDim2.new(1, 0, 0, 22)
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = parent
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "BonusText"
	textLabel.Size = UDim2.new(1, -16, 1, 0)
	textLabel.Position = UDim2.new(0, 8, 0, 0)
	textLabel.BackgroundTransparency = 1
	local v7 = v2[bonusType]
	local remainingTime = getRemainingTime(source.endTime) -- equivalent call inferred; original call site unknown
	local icon = v7.icon
	local boostKindLabel = getBoostKindLabel(source.kind) -- equivalent call inferred; original call site unknown
	textLabel.Text = icon .. " " .. boostKindLabel .. " " .. v7.label .. " x" .. source.mult .. "  " .. formatTime(remainingTime)
	local sourceTextColor = getSourceTextColor(bonusType, source.kind) -- equivalent call inferred; original call site unknown
	textLabel.TextColor3 = sourceTextColor
	textLabel.TextSize = 16
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Right
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.Parent = frame
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = 18
	uITextSizeConstraint.Parent = textLabel
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2
	uIStroke.Color = Color3.fromRGB(0, 0, 0)
	uIStroke.Parent = textLabel
	local uIScale = Instance.new("UIScale")
	uIScale.Scale = 1
	uIScale.Parent = frame
	return frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateSourceRow(instance, bonusType: string, source, layoutOrder: number)
	instance.LayoutOrder = layoutOrder
	local bonusText = instance:FindFirstChild("BonusText")

	if bonusText and bonusText:IsA("TextLabel") then
		local v7 = v2[bonusType]
		local remainingTime = getRemainingTime(source.endTime) -- equivalent call inferred; original call site unknown
		local icon = v7.icon
		local boostKindLabel = getBoostKindLabel(source.kind) -- equivalent call inferred; original call site unknown
		bonusText.Text = icon .. " " .. boostKindLabel .. " " .. v7.label .. " x" .. source.mult .. "  " .. formatTime(remainingTime)
		local sourceTextColor = getSourceTextColor(bonusType, source.kind) -- equivalent call inferred; original call site unknown
		bonusText.TextColor3 = sourceTextColor
	end
end

local function removeSourceRow(k: string)
	local v7 = v5[k]

	if not v7 then
		return
	end

	local uIScale = v7:FindFirstChildOfClass("UIScale")

	if uIScale then
		TweenService:Create(uIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		task.delay(0.35, function()
			if v7 and v7.Parent then
				v7:Destroy()
			end
		end)
	else
		v7:Destroy()
	end

	v5[k] = nil
end

local function collectActiveSources()
	local localPlayer = Players.LocalPlayer
	local result = {}

	for _, bonusType in ipairs(v) do
		local xPMultiplier, v8

		if bonusType == "XP" then
			local v9
			xPMultiplier, v9, v8 = BonusManager:GetXPMultiplier(localPlayer)
		else
			local v9
			xPMultiplier, v9, v8 = BonusManager:GetWinsMultiplier(localPlayer)
		end

		if not (xPMultiplier > 1 and type(v8) == "table") then
			continue
		end

		for _, source in ipairs(v8) do
			if not (type(source) == "table" and source.kind and source.mult > 1 and BonusManager:GetRemainingTime(source.endTime) > 0) then
				continue
			end

			table.insert(result, {
				bonusType = bonusType,
				source = source
			})
		end
	end

	table.sort(result, function(a, b)
		if a.source.endTime ~= b.source.endTime then
			return a.source.endTime > b.source.endTime
		end

		local sourceLayoutOrder = getSourceLayoutOrder(a.bonusType, a.source.kind) -- equivalent call inferred; original call site unknown
		return sourceLayoutOrder < getSourceLayoutOrder(b.bonusType, b.source.kind)
	end)
	return result
end

local function getBonusFromManager(p: string)
	local xPMultiplier, endTime, sources

	if p == "XP" then
		xPMultiplier, endTime, sources = BonusManager:GetXPMultiplier(Players.LocalPlayer)
	else
		xPMultiplier, endTime, sources = BonusManager:GetWinsMultiplier(Players.LocalPlayer)
	end

	if xPMultiplier <= 1 or BonusManager:GetRemainingTime(endTime) <= 0 then
		return nil
	end

	return {
		mult = xPMultiplier,
		endTime = endTime,
		sources = sources
	}
end

local function hasAnyActive()
	return #collectActiveSources() > 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function copyBonus(data)
	return {
		mult = data.mult,
		endTime = data.endTime,
		sources = data.sources
	}
end

local function updateDisplay()
	setupGui()
	local v7 = collectActiveSources()
	local v8 = {}

	for i, v9 in ipairs(v7) do
		local v10 = v9.bonusType .. "_" .. v9.source.kind
		v8[v10] = true
		local v11 = v5[v10]

		if v11 and v11.Parent then
			updateSourceRow(v11, v9.bonusType, v9.source, i) -- equivalent call inferred; original call site unknown
		else
			v5[v10] = createSourceRow(v9.bonusType, v9.source, i)
		end
	end

	for k in pairs(v5) do
		if not v8[k] then
			removeSourceRow(k)
		end
	end
end

local function syncClientState()
	local xPMultiplier, endTime, sources = BonusManager:GetXPMultiplier(Players.LocalPlayer)
	local v9 = not (xPMultiplier <= 1 or BonusManager:GetRemainingTime(endTime) <= 0) and {
		mult = xPMultiplier,
		endTime = endTime,
		sources = sources
	} or nil
	local winsMultiplier, endTime2, sources2 = BonusManager:GetWinsMultiplier(Players.LocalPlayer)
	local v12 = not (winsMultiplier <= 1 or BonusManager:GetRemainingTime(endTime2) <= 0) and {
		mult = winsMultiplier,
		endTime = endTime2,
		sources = sources2
	} or nil
	ClientState:Update({
		BonusXPMultiplier = v9 and v9.mult or 1,
		BonusWinsMultiplier = v12 and v12.mult or 1
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureTimerRunning()
	if flag then
		return
	end

	flag = true
	task.spawn(function()
		while #collectActiveSources() > 0 do
			updateDisplay()
			syncClientState()
			task.wait(1)
		end

		updateDisplay()
		syncClientState()
		flag = false
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshFromBonusManager()
	syncClientState()
	updateDisplay()
	ensureTimerRunning() -- equivalent call inferred; original call site unknown
end

function BonusDisplay.Init()
	if flag2 then
		return
	end

	flag2 = true
	assert(RunService:IsClient(), "BonusDisplay.Init may only be called on the client")
	setupGui()

	if not v6 then
		v6 = true
		BonusManager.Changed:Connect(function()
			task.defer(refreshFromBonusManager)
		end)
	end

	refreshFromBonusManager() -- equivalent call inferred; original call site unknown
	syncClientState()
	updateDisplay()
end

function BonusDisplay.GetBonus(p: string)
	local bonusFromManager = getBonusFromManager(p)

	if bonusFromManager then
		return copyBonus(bonusFromManager)
	end

	return nil
end

function BonusDisplay.GetCurrentBonuses()
	local bonuses = {}

	for _, v7 in ipairs(v) do
		local bonus = BonusDisplay.GetBonus(v7)

		if bonus then
			bonuses[v7] = bonus
		end
	end

	return bonuses
end

function BonusDisplay.GetMultiplier(p: string)
	local bonus = BonusDisplay.GetBonus(p)

	if bonus then
		return bonus.mult
	end

	return 1
end

function BonusDisplay.GetXPMultiplier()
	return BonusDisplay.GetMultiplier("XP")
end

function BonusDisplay.GetWinsMultiplier()
	return BonusDisplay.GetMultiplier("Wins")
end

return BonusDisplay