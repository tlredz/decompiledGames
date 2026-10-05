local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local _ = {
	QuestsPerSet = 3,
	GoNowStepTime = 0.22,
	GoNowSteps = 6,
	AutoClaimDelay = 0.45,
	SetSwapDelay = 0.35,
	OpenOnStart = true
}
local v = {
	"Steal 1x Egg from Desert Zone",
	"Hatch a Scorpion",
	"Steal 10x Eggs",
	"Hatch a Desert Drake",
	"Win 3x Zone Battles",
	"Steal 25x Eggs",
	"Reach Level 10",
	"Hatch a Legendary",
	"Steal 50x Eggs",
	"Unlock the Volcano Zone",
	"Hatch 5x Rare Pets",
	"Steal 100x Eggs"
}
local v2 = { 1, 1, 10 }
local parent = script.Parent
local rescueDragonAPI = parent:WaitForChild("RescueDragonAPI")

-- equivalent calls inferred from this helper; original call sites unknown
local function event(childName)
	return rescueDragonAPI:WaitForChild(childName)
end

local v3 = event("Open") -- equivalent call inferred; original call site unknown
local v4 = event("Close") -- equivalent call inferred; original call site unknown
local v5 = event("LoadQuestSet") -- equivalent call inferred; original call site unknown
local v6 = event("SetQuest") -- equivalent call inferred; original call site unknown
local v7 = event("ClaimQuest") -- equivalent call inferred; original call site unknown
local v8 = event("ResetAll") -- equivalent call inferred; original call site unknown
local v9 = event("ClaimClicked") -- equivalent call inferred; original call site unknown
local v10 = event("GoNowClicked") -- equivalent call inferred; original call site unknown
local v11 = event("CloseClicked") -- equivalent call inferred; original call site unknown
local v12 = event("LockUnlocked") -- equivalent call inferred; original call site unknown
local v13 = event("AllLocksUnlocked") -- equivalent call inferred; original call site unknown
local fTUEQuestMain = parent:WaitForChild("FTUEQuestMain")

local function countLocks()
	local count = 0

	for _, child in ipairs(fTUEQuestMain:GetChildren()) do
		if child.Name:match("^Lock%d+$") then
			count += 1
		end
	end

	return count
end

local v14 = countLocks()
local v15 = {
	sets = {},
	setIndex = 1,
	menuOpen = false,
	autoFinishing = false,
	busyRows = {}
}

local function buildSets()
	v15.sets = {}

	for i = 1, v14 do
		local v16 = {}

		for i2 = 1, 3 do
			v16[i2] = {
				Title = v[((i - 1) * 3 + i2 - 1) % #v + 1],
				Current = 0,
				Goal = v2[(i2 - 1) % #v2 + 1],
				State = "InProgress"
			}
		end

		v15.sets[i] = v16
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function currentSet()
	return v15.sets[v15.setIndex]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function loadCurrentSet()
	local v16 = currentSet() -- equivalent call inferred; original call site unknown

	if v16 then
		v5:Fire(v16)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startDemo(menuOpen)
	buildSets()
	v15.setIndex = 1
	v15.autoFinishing = false
	v15.busyRows = {}
	v8:Fire()
	loadCurrentSet() -- equivalent call inferred; original call site unknown

	if menuOpen then
		v3:Fire()
		v15.menuOpen = true
	end
end

local function runQuestProgress(p)
	local v16 = currentSet() -- equivalent call inferred; original call site unknown
	local v17 = v16 and v16[p]

	if not v17 or v17.State ~= "InProgress" or v15.busyRows[p] then
		return
	end

	v15.busyRows[p] = true
	local v18 = math.max(1, (math.ceil(v17.Goal / 6)))

	while v17.Current < v17.Goal do
		v17.Current = math.min(v17.Current + v18, v17.Goal)
		v6:Fire(p, {
			Current = v17.Current,
			Goal = v17.Goal
		})
		task.wait(0.22)
	end

	v17.State = "Claimable"
	v6:Fire(p, {
		Current = v17.Current,
		Goal = v17.Goal,
		State = "Claimable"
	})
	v15.busyRows[p] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function claim(i)
	local v16 = currentSet() -- equivalent call inferred; original call site unknown
	local v17 = v16 and v16[i]

	if not v17 or v17.State == "Claimed" then
		return
	end

	v17.Current = v17.Goal
	v17.State = "Claimed"
	v7:Fire(i)
end

local function finishCurrentSet()
	local v16 = currentSet() -- equivalent call inferred; original call site unknown

	if not v16 then
		return
	end

	for i, v17 in ipairs(v16) do
		if v17.State == "Claimed" then
			continue
		end

		claim(i) -- equivalent call inferred; original call site unknown
		task.wait(0.45)
	end
end

v10.Event:Connect(function(p)
	task.spawn(runQuestProgress, p)
end)
v9.Event:Connect(function(p)
	local v16 = currentSet() -- equivalent call inferred; original call site unknown
	local v17 = v16 and v16[p]

	if v17 then
		if v17.State == "Claimed" then
			return
		end

		v17.Current = v17.Goal
		v17.State = "Claimed"
		v7:Fire(p)
	end
end)
v11.Event:Connect(function()
	v15.menuOpen = false
end)
v12.Event:Connect(function()
	if v15.setIndex >= #v15.sets then
		return
	end

	v15.setIndex += 1
	task.wait(0.35)
	loadCurrentSet() -- equivalent call inferred; original call site unknown

	if v15.autoFinishing then
		task.wait(0.35)
		finishCurrentSet()
	end
end)
v13.Event:Connect(function()
	v15.autoFinishing = false
	print("[RescueDragonUIDemo] All locks unlocked - dragon freed.")
end)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RescueDragonDemoControls"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 1000
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.AnchorPoint = Vector2.new(0, 1)
frame.Position = UDim2.new(0, 16, 1, -16)
frame.Size = UDim2.fromOffset(220, 148)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui
local uICorner = Instance.new("UICorner")
uICorner.CornerRadius = UDim.new(0, 10)
uICorner.Parent = frame
local uIPadding = Instance.new("UIPadding")
uIPadding.PaddingTop = UDim.new(0, 8)
uIPadding.PaddingBottom = UDim.new(0, 8)
uIPadding.PaddingLeft = UDim.new(0, 8)
uIPadding.PaddingRight = UDim.new(0, 8)
uIPadding.Parent = frame
local uIListLayout = Instance.new("UIListLayout")
uIListLayout.FillDirection = Enum.FillDirection.Vertical
uIListLayout.Padding = UDim.new(0, 6)
uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uIListLayout.Parent = frame
local textLabel = Instance.new("TextLabel")
textLabel.Name = "Title"
textLabel.LayoutOrder = 0
textLabel.Size = UDim2.new(1, 0, 0, 18)
textLabel.BackgroundTransparency = 1
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 12
textLabel.TextColor3 = Color3.fromRGB(150, 150, 175)
textLabel.TextXAlignment = Enum.TextXAlignment.Left
textLabel.Text = "RESCUE DRAGON - UI DEMO"
textLabel.Parent = frame

local function makeButton(layoutOrder, text, backgroundColor, fn)
	local textButton = Instance.new("TextButton")
	textButton.Name = text:gsub("%s", "")
	textButton.LayoutOrder = layoutOrder
	textButton.Size = UDim2.new(1, 0, 0, 30)
	textButton.BackgroundColor3 = backgroundColor
	textButton.BorderSizePixel = 0
	textButton.AutoButtonColor = false
	textButton.Font = Enum.Font.GothamBold
	textButton.TextSize = 13
	textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	textButton.Text = text
	textButton.Parent = frame
	local uICorner2 = Instance.new("UICorner")
	uICorner2.CornerRadius = UDim.new(0, 6)
	uICorner2.Parent = textButton
	local uIScale = Instance.new("UIScale")
	uIScale.Parent = textButton

	local function tweenScale(scale)
		TweenService:Create(uIScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	textButton.MouseEnter:Connect(function()
		tweenScale(1.04)
	end)
	textButton.MouseLeave:Connect(function()
		tweenScale(1)
	end)
	textButton.MouseButton1Down:Connect(function()
		tweenScale(0.95)
	end)
	textButton.MouseButton1Up:Connect(function()
		tweenScale(1.04)
	end)
	textButton.MouseButton1Click:Connect(function()
		task.spawn(fn)
	end)
	return textButton
end

makeButton(1, "Reset All State", Color3.fromRGB(60, 64, 92), function()
	startDemo(v15.menuOpen or true)
end)
makeButton(2, "Finish All Quests", Color3.fromRGB(46, 130, 78), function()
	if v15.autoFinishing then
		return
	end

	v15.autoFinishing = true
	finishCurrentSet()
end)
makeButton(3, "Toggle Menu", Color3.fromRGB(52, 56, 80), function()
	if v15.menuOpen then
		v4:Fire()
		v15.menuOpen = false
	else
		v3:Fire()
		v15.menuOpen = true
	end
end)
task.defer(function()
	startDemo(false) -- equivalent call inferred; original call site unknown
	v3:Fire()
	v15.menuOpen = true
end)