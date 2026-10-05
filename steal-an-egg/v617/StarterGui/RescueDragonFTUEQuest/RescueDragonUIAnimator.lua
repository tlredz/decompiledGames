local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if ReplicatedStorage:WaitForChild("Data"):FindFirstChild("OnboardingQuestline") == nil then
	script.Parent.Enabled = false
	return
end

local _ = {
	OpenTime = 0.34,
	OpenScaleFrom = 0.66,
	OpenFadeTime = 0.22,
	CloseTime = 0.18,
	CloseScaleTo = 0.8,
	RowStagger = 0.075,
	RowTime = 0.36,
	RowDelay = 0.1,
	RowScaleFrom = 0.84,
	RowRotationFrom = -5,
	HoverScale = 1.07,
	PressScale = 0.93,
	HoverTime = 0.12,
	ClaimPulseScale = 1.05,
	ClaimPulseTime = 0.55,
	CheckmarkTime = 0.34,
	CheckmarkSpin = 25,
	ButtonSwapTime = 0.18,
	RowBarTime = 0.28,
	KeyBarTime = 0.35,
	KeyIconPunch = 1.22,
	KeyIconPunchTime = 0.18,
	KeyFlightTime = 0.75,
	KeyFlightArc = -0.3,
	KeyFlightSpin = 540,
	KeyFlightPop = 0.55,
	KeyFlightZIndex = 500,
	KeyHatchTime = 0.18,
	LockPunchScale = 1.3,
	LockPunchTime = 0.12,
	LockFadeOutTime = 0.28,
	LockFadeOutScale = 1.45,
	PostUnlockDelay = 0.15,
	DisableGuiWhenClosed = true,
	KeyIconFloat = true,
	KeyIconFloatAmount = 0.006,
	KeyIconFloatSpeed = 1.6,
	ViewportModelName = nil,
	ViewportFieldOfView = 40,
	ViewportFit = 1.25,
	ViewportYaw = 180,
	ViewportElevation = 6,
	ViewportHeightOffset = 0.1,
	ViewportSway = 7,
	ViewportSwaySpeed = 0.5,
	ViewportBob = 0.012,
	ViewportBobSpeed = 1.1,
	PlaceholderRows = 3
}
local parent = script.Parent
local fTUEQuestMain = parent:WaitForChild("FTUEQuestMain")
local content = fTUEQuestMain:WaitForChild("Content")
local questHolder = content:WaitForChild("QuestHolder")
local template = questHolder:WaitForChild("Template")
local keyProgressHolder = content:WaitForChild("KeyProgressHolder")
local progressBar = keyProgressHolder:WaitForChild("ProgressBar")
local progressLabel = keyProgressHolder:WaitForChild("ProgressLabel")
local icon = content:WaitForChild("Icon")
local close = fTUEQuestMain:WaitForChild("Close")
local viewportFrame = fTUEQuestMain:FindFirstChild("ViewportFrame")
local lockUnlocked = parent:WaitForChild("Assets"):WaitForChild("LockUnlocked")
local fullScale = progressBar:GetAttribute("FullScale") or 1
local fullScale2 = template.ProgressHolder.ProgressBar:GetAttribute("FullScale") or 1
local position = icon.Position
local v = {
	Frame = { "BackgroundTransparency" },
	ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
	ImageButton = { "BackgroundTransparency", "ImageTransparency" },
	TextLabel = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
	TextButton = { "BackgroundTransparency", "TextTransparency", "TextStrokeTransparency" },
	ViewportFrame = { "BackgroundTransparency", "ImageTransparency" },
	ScrollingFrame = { "BackgroundTransparency", "ScrollBarImageTransparency" },
	CanvasGroup = { "BackgroundTransparency", "GroupTransparency" },
	UIStroke = { "Transparency" }
}

local function newFadeGroup(folder)
	local v2 = {}

	local function record(instance)
		local v3 = v[instance.ClassName]

		if not v3 then
			return
		end

		for _, prop in ipairs(v3) do
			v2[#v2 + 1] = {
				inst = instance,
				prop = prop,
				base = instance[prop]
			}
		end
	end

	record(folder)

	for _, descendant in ipairs(folder:GetDescendants()) do
		record(descendant)
	end

	return {
		apply = function(p)
			for _, v3 in ipairs(v2) do
				if v3.inst.Parent then
					v3.inst[v3.prop] = v3.base + (1 - v3.base) * p
				end
			end
		end
	}
end

local function tweenNumber(p, p2, tweenInfo, onChanged)
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = p
	onChanged(p)
	local changedConnection = numberValue.Changed:Connect(onChanged)
	local tween = TweenService:Create(numberValue, tweenInfo, {
		Value = p2
	})
	tween.Completed:Connect(function()
		changedConnection:Disconnect()
		numberValue:Destroy()
	end)
	tween:Play()
	return tween
end

local function getScale(parent2)
	local v2 = parent2:FindFirstChild("AnimScale")

	if not v2 then
		v2 = Instance.new("UIScale")
		v2.Name = "AnimScale"
		v2.Parent = parent2
	end

	return v2
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenTo(p, tweenInfo, p2)
	local tween = TweenService:Create(p, tweenInfo, p2)
	tween:Play()
	return tween
end

local v2 = {}
local renderSteppedConnection = nil

local function startAmbient()
	if renderSteppedConnection or #v2 == 0 then
		return
	end

	renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		for _, v3 in ipairs(v2) do
			v3(dt)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopAmbient()
	if renderSteppedConnection then
		renderSteppedConnection:Disconnect()
		renderSteppedConnection = nil
	end
end

local OnboardingQuestline = require(ReplicatedStorage.Data.OnboardingQuestline)
local sounds = OnboardingQuestline.Sounds
local Audio = require(ReplicatedStorage.Shared.Audio)

local function playCue(p)
	local sound = sounds[p]
	assert(sound ~= nil, ("no sound slot named %q in OnboardingQuestline.Sounds"):format((tostring(p))))

	if sound ~= 0 then
		Audio.Play(sound, script, {})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function centreInParent(p, p2)
	local v3 = p.AbsolutePosition + p.AbsoluteSize * 0.5
	local absolutePosition = p2.AbsolutePosition
	local absoluteSize = p2.AbsoluteSize
	return Vector2.new(
		(v3.X - absolutePosition.X) / math.max(absoluteSize.X, 1),
		(v3.Y - absolutePosition.Y) / math.max(absoluteSize.Y, 1)
	)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function safeDivide(p, p2)
	if p2 and not (p2 <= 0) then
		return (math.clamp(p / p2, 0, 1))
	end

	return 0
end

local function collectLocks()
	local result = {}

	for _, guiObject in ipairs(fTUEQuestMain:GetChildren()) do
		local match = guiObject.Name:match("^Lock(%d+)$")

		if match and guiObject:IsA("GuiObject") then
			result[#result + 1] = {
				index = tonumber(match),
				frame = guiObject
			}
		end
	end

	table.sort(result, function(a, b)
		return a.index < b.index
	end)
	return result
end

local v3 = collectLocks()

for _, v4 in ipairs(v3) do
	v4.fade = newFadeGroup(v4.frame)
end

local parent3 = parent:FindFirstChild("RescueDragonAPI")

if not parent3 then
	parent3 = Instance.new("Folder")
	parent3.Name = "RescueDragonAPI"
	parent3.Parent = parent
end

local function getEvent(name)
	local v7 = parent3:FindFirstChild(name)

	if not v7 then
		v7 = Instance.new("BindableEvent")
		v7.Name = name
		v7.Parent = parent3
	end

	return v7
end

local v7 = {}

for _, childName in ipairs({
	"Open",
	"Close",
	"LoadQuestSet",
	"SetQuest",
	"ClaimQuest",
	"SetKeyProgress",
	"UnlockNextLock",
	"ResetAll"
}) do
	local v8 = parent3:FindFirstChild(childName)

	if not v8 then
		v8 = Instance.new("BindableEvent")
		v8.Name = childName
		v8.Parent = parent3
	end

	v7[childName] = v8
end

for _, childName in ipairs({
	"ClaimClicked",
	"GoNowClicked",
	"CloseClicked",
	"LockUnlocked",
	"AllLocksUnlocked"
}) do
	local v8 = parent3:FindFirstChild(childName)

	if not v8 then
		v8 = Instance.new("BindableEvent")
		v8.Name = childName
		v8.Parent = parent3
	end

	v7[childName] = v8
end

local v8 = {
	isOpen = false,
	rows = {},
	keyCurrent = 0,
	keyTotal = 0,
	locksUnlocked = 0,
	flightRunning = false,
	introToken = 0,
	generation = 0
}

local function bindHover(parent2, value)
	local v9 = parent2:FindFirstChild("AnimScale")

	if not v9 then
		v9 = Instance.new("UIScale")
		v9.Name = "AnimScale"
		v9.Parent = parent2
	end

	local v10 = false
	local v11 = false

	local function refresh()
		local scale = v11 and 0.93 or v10 and 1.07 or 1
		TweenService:Create(v9, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = scale
		}):Play()
	end

	parent2.MouseEnter:Connect(function()
		v10 = true
		playCue("ButtonHover")
		refresh()
	end)
	parent2.MouseLeave:Connect(function()
		v10 = false
		v11 = false
		refresh()
	end)
	parent2.MouseButton1Down:Connect(function()
		v11 = true
		playCue(value or "ButtonClick")
		refresh()
	end)
	parent2.MouseButton1Up:Connect(function()
		v11 = false
		refresh()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPulse(state)
	if state.pulseTween then
		state.pulseTween:Cancel()
		state.pulseTween = nil
	end

	local claim = state.claim
	local v9 = claim:FindFirstChild("AnimScale")

	if not v9 then
		v9 = Instance.new("UIScale")
		v9.Name = "AnimScale"
		v9.Parent = claim
	end

	v9.Scale = 1
end

local function startPulse(state)
	stopPulse(state) -- equivalent call inferred; original call site unknown
	local claim = state.claim
	local v9 = claim:FindFirstChild("AnimScale")

	if not v9 then
		v9 = Instance.new("UIScale")
		v9.Name = "AnimScale"
		v9.Parent = claim
	end

	v9.Scale = 1
	state.pulseTween = tweenTo(v9, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		Scale = 1.05
	})
end

local function setRowBar(data, current, goal, p)
	local v9 = safeDivide(current, goal) -- equivalent call inferred; original call site unknown
	local uDim = UDim2.new(fullScale2 * v9, 0, data.bar.Size.Y.Scale, data.bar.Size.Y.Offset)

	if p and v8.isOpen then
		TweenService:Create(data.bar, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = uDim
		}):Play()
	else
		data.bar.Size = uDim
	end

	if data.barLabel then
		data.barLabel.Text = data.data.ProgressText or string.format("%d/%d", current, goal)
	end
end

local function setRowState(state, state2, p)
	state.state = state2

	if state2 == "Claimable" then
		state.inProgress.Visible = false
		state.checkmark.Visible = false

		if not state.claim.Visible then
			state.claim.Visible = true

			if not (p and v8.isOpen) then
				startPulse(state)
				return
			end

			local claim = state.claim
			local v9 = claim:FindFirstChild("AnimScale")

			if not v9 then
				v9 = Instance.new("UIScale")
				v9.Name = "AnimScale"
				v9.Parent = claim
			end

			v9.Scale = 0.4
			;(tweenTo(v9, TweenInfo.new(0.288, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1
			})).Completed:Connect(function()
				if state.state == "Claimable" then
					startPulse(state)
				end
			end)
		end
	elseif state2 == "Claimed" then
		stopPulse(state) -- equivalent call inferred; original call site unknown
		state.claim.Visible = false
		state.inProgress.Visible = false
		state.checkmark.Visible = true
		local checkmark = state.checkmark
		local v9 = checkmark:FindFirstChild("AnimScale")

		if not v9 then
			v9 = Instance.new("UIScale")
			v9.Name = "AnimScale"
			v9.Parent = checkmark
		end

		if p and v8.isOpen then
			v9.Scale = 0
			state.checkmark.Rotation = -25
			local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			TweenService:Create(v9, tweenInfo, {
				Scale = 1
			}):Play()
			TweenService:Create(state.checkmark, tweenInfo, {
				Rotation = 0
			}):Play()
		else
			v9.Scale = 1
			state.checkmark.Rotation = 0
		end
	else
		stopPulse(state) -- equivalent call inferred; original call site unknown
		state.claim.Visible = false
		state.checkmark.Visible = false
		state.inProgress.Visible = true
		local inProgress = state.inProgress
		local v9 = inProgress:FindFirstChild("AnimScale")

		if not v9 then
			v9 = Instance.new("UIScale")
			v9.Name = "AnimScale"
			v9.Parent = inProgress
		end

		v9.Scale = 1
	end
end

local function applyQuestData(row, items, p)
	for k, item in pairs(items) do
		row.data[k] = item
	end

	local data = row.data
	data.Goal = data.Goal or 1
	data.Current = data.Current or 0

	if data.Title then
		row.title.Text = data.Title
	end

	if not data.State then
		data.State = data.Current >= data.Goal and "Claimable" or "InProgress"
	end

	setRowBar(row, data.Current, data.Goal, p)

	if row.state ~= data.State then
		setRowState(row, data.State, p)
	end
end

local function destroyRows()
	for _, row in ipairs(v8.rows) do
		stopPulse(row) -- equivalent call inferred; original call site unknown
		row.frame:Destroy()
	end

	table.clear(v8.rows)
end

local function buildRow(layoutOrder)
	local clone = template:Clone()
	clone.Name = "Quest" .. layoutOrder
	clone.LayoutOrder = layoutOrder
	clone.Visible = true
	local v9 = {
		index = layoutOrder,
		frame = clone,
		title = clone:WaitForChild("Info1"),
		claim = clone:WaitForChild("Claim"),
		inProgress = clone:WaitForChild("InProgress"),
		checkmark = clone:WaitForChild("CompletedCheckmark"),
		bar = clone.ProgressHolder:WaitForChild("ProgressBar"),
		barLabel = clone.ProgressHolder:FindFirstChild("ProgressLabel"),
		state = nil,
		data = {}
	}
	v9.checkmark.Visible = false
	v9.claim.Visible = false
	v9.inProgress.Visible = true
	clone.Parent = questHolder
	v9.fade = newFadeGroup(clone)
	bindHover(v9.claim)
	bindHover(v9.inProgress)
	v9.claim.MouseButton1Click:Connect(function()
		v7.ClaimClicked:Fire(v9.index)
	end)
	v9.inProgress.MouseButton1Click:Connect(function()
		v7.GoNowClicked:Fire(v9.index)
	end)
	return v9
end

local function hideRowsForIntro()
	for _, row in ipairs(v8.rows) do
		row.fade.apply(1)
		local frame = row.frame
		local v9 = frame:FindFirstChild("AnimScale")

		if not v9 then
			v9 = Instance.new("UIScale")
			v9.Name = "AnimScale"
			v9.Parent = frame
		end

		v9.Scale = 0.84
		row.frame.Rotation = -5
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRowIntro()
	v8.introToken += 1
	local introToken = v8.introToken
	hideRowsForIntro()
	task.spawn(function()
		task.wait(0.1)

		for i, row in ipairs(v8.rows) do
			if introToken ~= v8.introToken then
				break
			end

			local v10 = row
			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tweenInfo2 = TweenInfo.new(0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				tweenNumber(1, 0, tweenInfo, function(p)
					v10.fade.apply(p)
				end)
				local frame = v10.frame
				local v11 = frame:FindFirstChild("AnimScale")

				if not v11 then
					v11 = Instance.new("UIScale")
					v11.Name = "AnimScale"
					v11.Parent = frame
				end

				TweenService:Create(v11, tweenInfo2, {
					Scale = 1
				}):Play()
				TweenService:Create(v10.frame, tweenInfo2, {
					Rotation = 0
				}):Play()
			end)

			if i < #v8.rows then
				task.wait(0.075)
			end
		end
	end)
end

local function punchKeyIcon()
	local parent2 = icon
	local v10 = parent2:FindFirstChild("AnimScale")

	if not v10 then
		v10 = Instance.new("UIScale")
		v10.Name = "AnimScale"
		v10.Parent = parent2
	end

	v10.Scale = 1.22
	TweenService:Create(v10, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshKeyBar(p)
	local v9 = safeDivide(v8.keyCurrent, v8.keyTotal) -- equivalent call inferred; original call site unknown
	local uDim = UDim2.new(fullScale * v9, 0, progressBar.Size.Y.Scale, progressBar.Size.Y.Offset)

	if p and v8.isOpen then
		TweenService:Create(progressBar, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = uDim
		}):Play()
	else
		progressBar.Size = uDim
	end

	progressLabel.Text = string.format("%d/%d", v8.keyCurrent, v8.keyTotal)
end

local function isKeyBarFull()
	return v8.keyTotal > 0 and v8.keyCurrent >= v8.keyTotal
end

-- equivalent calls inferred from this helper; original call sites unknown
local function nextLock()
	return v3[v8.locksUnlocked + 1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearUnlockSprite(frame)
	local lockUnlockedAnim = frame:FindFirstChild("LockUnlockedAnim")

	if lockUnlockedAnim then
		lockUnlockedAnim:Destroy()
	end
end

local function playUnlockSprite(frame)
	local lockIdle = frame:FindFirstChild("LockIdle")
	local clone = lockUnlocked:Clone()
	clone.Name = "LockUnlockedAnim"
	local playSprite = clone:FindFirstChild("PlaySprite")
	local cells = playSprite and playSprite:GetAttribute("Cells") or Vector2.new(1, 1)
	local v9 = not playSprite and 15 or playSprite:GetAttribute("FPS") or 15

	if playSprite then
		playSprite:Destroy()
	end

	if lockIdle then
		clone.AnchorPoint = lockIdle.AnchorPoint
		clone.Position = lockIdle.Position
		clone.Size = lockIdle.Size
		clone.ScaleType = lockIdle.ScaleType
		clone.SizeConstraint = lockIdle.SizeConstraint
		clone.ZIndex = lockIdle.ZIndex + 1
	else
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Position = UDim2.fromScale(0.5, 0.5)
		clone.Size = UDim2.fromScale(1, 1)
	end

	clone.ImageRectOffset = Vector2.zero
	clone.Parent = frame

	if lockIdle then
		lockIdle.Visible = false
	end

	local v10 = math.max(1, (math.floor(cells.X * cells.Y)))
	local v11 = 1 / math.max(v9, 1)

	for i = 0, v10 - 1 do
		local v12 = i % cells.X
		local v13 = math.floor(i / cells.X)
		clone.ImageRectOffset = Vector2.new(clone.ImageRectSize.X * v12, clone.ImageRectSize.Y * v13)
		task.wait(v11)
	end

	return clone
end

local function flyKeyTo(frame)
	local v11 = centreInParent(icon, fTUEQuestMain) -- equivalent call inferred; original call site unknown
	local v13 = centreInParent(frame, fTUEQuestMain) -- equivalent call inferred; original call site unknown
	local clone = icon:Clone()
	clone.Name = "FlyingKey"
	clone:ClearAllChildren()
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.ZIndex = 500
	clone.Size = UDim2.fromScale(
		icon.AbsoluteSize.X / math.max(fTUEQuestMain.AbsoluteSize.X, 1),
		icon.AbsoluteSize.Y / math.max(fTUEQuestMain.AbsoluteSize.Y, 1)
	)
	clone.Position = UDim2.fromScale(v11.X, v11.Y)
	clone.Rotation = icon.Rotation
	clone.Parent = fTUEQuestMain
	local uIScale = Instance.new("UIScale")
	uIScale.Name = "AnimScale"
	uIScale.Scale = 0.4
	uIScale.Parent = clone
	TweenService:Create(uIScale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	punchKeyIcon()
	local v14 = (v11 + v13) * 0.5 + Vector2.new(0, -0.3)
	local rotation = clone.Rotation
	local total = 0
	local renderSteppedConnection2 = nil
	renderSteppedConnection2 = RunService.RenderStepped:Connect(function(dt)
		total += dt
		local v15 = math.clamp(total / 0.75, 0, 1)
		local value = TweenService:GetValue(v15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
		local v16 = 1 - value
		local v17 = v11 * (v16 * v16) + v14 * (2 * v16 * value) + v13 * (value * value)
		clone.Position = UDim2.fromScale(v17.X, v17.Y)
		clone.Rotation = rotation + 540 * value
		uIScale.Scale = 1 + 0.55 * math.sin(3.141592653589793 * value)

		if v15 >= 1 then
			renderSteppedConnection2:Disconnect()
		end
	end)
	task.wait(0.75)
	local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(uIScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Scale = 0.2
	}):Play()
	TweenService:Create(clone, tweenInfo2, {
		ImageTransparency = 1,
		Rotation = clone.Rotation + 90
	}):Play()
	task.wait(0.18)
	clone:Destroy()
end

local function unlockLock(data, generation)
	local frame = data.frame
	local v9 = frame:FindFirstChild("AnimScale")

	if not v9 then
		v9 = Instance.new("UIScale")
		v9.Name = "AnimScale"
		v9.Parent = frame
	end

	local fade = data.fade
	local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(v9, tweenInfo, {
		Scale = 1.3
	}):Play()
	task.wait(0.12)

	if generation ~= v8.generation then
		return false
	end

	TweenService:Create(v9, tweenInfo, {
		Scale = 1
	}):Play()
	clearUnlockSprite(frame) -- equivalent call inferred; original call site unknown
	local v10 = playUnlockSprite(frame)

	if generation ~= v8.generation then
		return false
	end

	TweenService:Create(v9, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
		Scale = 1.45
	}):Play()
	TweenService:Create(v10, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		ImageTransparency = 1
	}):Play()
	tweenNumber(0, 1, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), function(p)
		fade.apply(p)
	end)
	task.wait(0.28)

	if generation ~= v8.generation then
		return false
	end

	frame.Visible = false
	v9.Scale = 1
	fade.apply(0)
	v8.locksUnlocked += 1
	v7.LockUnlocked:Fire(data.index)

	if v8.locksUnlocked >= #v3 then
		v7.AllLocksUnlocked:Fire()
	end

	return true
end

local function runKeyFlight()
	if v8.flightRunning then
		return
	end

	local lock = nextLock() -- equivalent call inferred; original call site unknown

	if not lock then
		return
	end

	v8.flightRunning = true
	local generation = v8.generation

	if v8.isOpen then
		flyKeyTo(lock.frame)

		if generation == v8.generation then
			if unlockLock(lock, generation) then
				task.wait(0.15)
			end
		else
			v8.flightRunning = false
			return
		end
	else
		local lockIdle = lock.frame:FindFirstChild("LockIdle")

		if lockIdle then
			lockIdle.Visible = false
		end

		lock.frame.Visible = false
		v8.locksUnlocked += 1
		v7.LockUnlocked:Fire(lock.index)

		if v8.locksUnlocked >= #v3 then
			v7.AllLocksUnlocked:Fire()
		end
	end

	v8.flightRunning = false
end

local v9 = fTUEQuestMain:FindFirstChild("AnimScale")

if not v9 then
	v9 = Instance.new("UIScale")
	v9.Name = "AnimScale"
	v9.Parent = fTUEQuestMain
end

local v10 = newFadeGroup(fTUEQuestMain)

local function openMenu()
	if v8.isOpen then
		return
	end

	v8.isOpen = true
	parent.Enabled = true

	if not renderSteppedConnection and #v2 ~= 0 then
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			for _, v11 in ipairs(v2) do
				v11(dt)
			end
		end)
	end

	fTUEQuestMain.Visible = true
	v9.Scale = 0.66
	v10.apply(1)
	hideRowsForIntro()
	TweenService:Create(v9, TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	tweenNumber(1, 0, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), function(p)
		v10.apply(p)
	end)
	playRowIntro() -- equivalent call inferred; original call site unknown
end

local function closeMenu()
	if not v8.isOpen then
		return
	end

	v8.isOpen = false
	v8.introToken += 1
	TweenService:Create(v9, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.8
	}):Play()
	tweenNumber(0, 1, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), function(p)
		v10.apply(p)
	end)
	task.delay(0.18, function()
		if not v8.isOpen then
			fTUEQuestMain.Visible = false
			v10.apply(0)
			v9.Scale = 1
			stopAmbient() -- equivalent call inferred; original call site unknown
			parent.Enabled = false
		end
	end)
end

local function loadQuestSet(options)
	destroyRows()

	for i, v11 in ipairs(options or {}) do
		local row = buildRow(i)
		v8.rows[i] = row
		applyQuestData(row, v11, false)
	end

	v8.keyTotal = #v8.rows
	v8.keyCurrent = 0

	for _, row in ipairs(v8.rows) do
		if row.state == "Claimed" then
			v8.keyCurrent += 1
		end
	end

	refreshKeyBar(false) -- equivalent call inferred; original call site unknown

	if not v8.isOpen then
		hideRowsForIntro()
		return
	end

	playRowIntro() -- equivalent call inferred; original call site unknown
end

local function claimQuest(p)
	local row = v8.rows[p]

	if not row or row.state == "Claimed" then
		return
	end

	stopPulse(row) -- equivalent call inferred; original call site unknown

	if row.claim.Visible and v8.isOpen then
		local claim = row.claim
		local v11 = claim:FindFirstChild("AnimScale")

		if not v11 then
			v11 = Instance.new("UIScale")
			v11.Name = "AnimScale"
			v11.Parent = claim
		end

		TweenService:Create(v11, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Scale = 0
		}):Play()
		task.wait(0.18)
	end

	row.data.Current = row.data.Goal or row.data.Current
	setRowBar(row, row.data.Current, row.data.Goal, true)
	setRowState(row, "Claimed", true)
	row.data.State = "Claimed"
	v8.keyCurrent = math.min(v8.keyCurrent + 1, v8.keyTotal)
	punchKeyIcon()
	refreshKeyBar(true)
	local v11

	if v8.keyTotal > 0 then
		v11 = v8.keyCurrent >= v8.keyTotal
	else
		v11 = false
	end

	if v11 then
		task.wait(0.35)
		runKeyFlight()
	end
end

local function resetAll()
	v8.introToken += 1
	v8.generation += 1
	v8.flightRunning = false
	v8.locksUnlocked = 0
	v8.keyCurrent = 0

	for _, v13 in ipairs(v3) do
		clearUnlockSprite(v13.frame) -- equivalent call inferred; original call site unknown
		local lockIdle = v13.frame:FindFirstChild("LockIdle")

		if lockIdle then
			lockIdle.Visible = true
		end

		v13.frame.Visible = true
		local frame = v13.frame
		local v14 = frame:FindFirstChild("AnimScale")

		if not v14 then
			v14 = Instance.new("UIScale")
			v14.Name = "AnimScale"
			v14.Parent = frame
		end

		v14.Scale = 1
		v13.fade.apply(0)
	end

	for _, child in ipairs(fTUEQuestMain:GetChildren()) do
		if child.Name == "FlyingKey" then
			child:Destroy()
		end
	end

	destroyRows()

	for i = 1, 3 do
		local row = buildRow(i)
		v8.rows[i] = row
		applyQuestData(row, {
			Current = 0,
			Goal = 1,
			State = "InProgress"
		}, false)
	end

	v8.keyTotal = #v8.rows
	refreshKeyBar(false) -- equivalent call inferred; original call site unknown
	icon.Position = position
	local parent2 = icon
	local v14 = parent2:FindFirstChild("AnimScale")

	if not v14 then
		v14 = Instance.new("UIScale")
		v14.Name = "AnimScale"
		v14.Parent = parent2
	end

	v14.Scale = 1

	if not v8.isOpen then
		hideRowsForIntro()
		return
	end

	playRowIntro() -- equivalent call inferred; original call site unknown
end

local total = 0

v2[#v2 + 1] = function(p)
	total += p * 1.6
	local v11 = math.sin(total) * 0.006
	icon.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale + v11, position.Y.Offset)
end

local function setupViewport()
	if not viewportFrame then
		return
	end

	local rewardAssetId = nil

	if not rewardAssetId then
		local OnboardingQuestline2 = require(ReplicatedStorage.Data.OnboardingQuestline)
		rewardAssetId = OnboardingQuestline2.RewardAssetId
	end

	local assetModels = ReplicatedStorage:WaitForChild("AssetModels", 15)
	local v11 = assetModels and assetModels:FindFirstChild(rewardAssetId) or workspace:FindFirstChild(rewardAssetId)

	if not v11 then
		warn(("[RescueDragonUIAnimator] No model named %q in AssetModels or Workspace, viewport left empty."):format(rewardAssetId))
		return
	end

	local worldModel = viewportFrame:FindFirstChildOfClass("WorldModel")

	if worldModel then
		worldModel:Destroy()
	end

	viewportFrame.BackgroundTransparency = 1
	viewportFrame.Ambient = Color3.fromRGB(150, 150, 165)
	viewportFrame.LightColor = Color3.fromRGB(255, 250, 240)
	viewportFrame.LightDirection = createVector(-0.35, -1, -0.5)
	local worldModel2 = Instance.new("WorldModel")
	worldModel2.Name = "DisplayWorld"
	worldModel2.Parent = viewportFrame
	local clone = v11:Clone()
	clone.Name = "DisplayModel"

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		elseif descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.CanQuery = false
			descendant.CanTouch = false
		end
	end

	clone.Parent = worldModel2
	clone:PivotTo(CFrame.new())
	local boundingBox, v12 = clone:GetBoundingBox()
	local position2 = boundingBox.Position
	local v13 = math.max(v12.X, v12.Y, v12.Z)
	local camera = Instance.new("Camera")
	camera.Name = "DisplayCamera"
	camera.FieldOfView = 40
	camera.Parent = viewportFrame
	viewportFrame.CurrentCamera = camera
	local v14 = v13 * 1.25 / (math.tan(math.rad(camera.FieldOfView) * 0.5) * 2)
	local total2 = 0

	local function place(p)
		total2 += p
		local v15 = 180 + math.sin(total2 * 0.5) * 7
		local v16 = math.sin(total2 * 1.1) * 0.012 * v12.Y
		local v17 = position2 + Vector3.new(0, 0.1 * v12.Y + v16, 0)
		local v18 = CFrame.Angles(0, math.rad(v15), 0) * CFrame.Angles(-0.10471975511965978, 0, 0)
		camera.CFrame = CFrame.lookAt(v17 + v18 * Vector3.new(0, 0, v14), v17)
	end

	place(0)
	v2[#v2 + 1] = place

	if v8.isOpen and not renderSteppedConnection and #v2 ~= 0 then
		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			for _, v15 in ipairs(v2) do
				v15(dt)
			end
		end)
	end
end

task.spawn(setupViewport)
bindHover(close, "CancelPress")
close.MouseButton1Click:Connect(function()
	v7.CloseClicked:Fire()
	closeMenu()
end)
v7.Open.Event:Connect(openMenu)
v7.Close.Event:Connect(closeMenu)
v7.LoadQuestSet.Event:Connect(loadQuestSet)
v7.ResetAll.Event:Connect(resetAll)
v7.UnlockNextLock.Event:Connect(function()
	task.spawn(runKeyFlight)
end)
v7.SetQuest.Event:Connect(function(p, p2)
	local row = v8.rows[p]

	if row and p2 then
		applyQuestData(row, p2, true)
	end
end)
v7.ClaimQuest.Event:Connect(function(p)
	task.spawn(claimQuest, p)
end)
v7.SetKeyProgress.Event:Connect(function(value, p)
	v8.keyTotal = p or #v8.rows
	v8.keyCurrent = math.clamp(value or 0, 0, v8.keyTotal)
	refreshKeyBar(true)
end)
template.Visible = false
fTUEQuestMain.Visible = false
v10.apply(0)
resetAll()
parent.Enabled = false
parent3:SetAttribute("Ready", true)