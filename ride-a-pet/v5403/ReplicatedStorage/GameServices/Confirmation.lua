local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
assert(RunService:IsClient(), "Confirmation is a client-only module")
local v = nil
local v2 = nil
local v3 = false
local v4 = nil
local completedConnection = nil

local function GetView()
	if v and v.Container.Parent then
		return v
	end

	local choiceGui = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ChoiceGui")

	if choiceGui:IsA("ScreenGui") and choiceGui.DisplayOrder < 5 then
		choiceGui.DisplayOrder = 5
	end

	local container = choiceGui:WaitForChild("Container")
	assert(container:IsA("Frame"), "ChoiceGui.Container must be a Frame")
	local title = container:WaitForChild("TopLeft"):WaitForChild("Title")
	local poll = container:WaitForChild("Poll")
	local mainTitle = poll:WaitForChild("MainTitle")
	local choices = poll:WaitForChild("Choices")
	local yes = choices:WaitForChild("Yes")
	local no = choices:WaitForChild("No")
	local textLabel = yes:WaitForChild("TextLabel")
	local textLabel2 = no:WaitForChild("TextLabel")
	local timer = poll:WaitForChild("Top"):WaitForChild("Timer")
	assert(title:IsA("TextLabel"), "ChoiceGui TopLeft.Title must be a TextLabel")
	assert(mainTitle:IsA("TextLabel"), "ChoiceGui Poll.MainTitle must be a TextLabel")
	assert(yes:IsA("GuiButton"), "ChoiceGui Choices.Yes must be a GuiButton")
	assert(no:IsA("GuiButton"), "ChoiceGui Choices.No must be a GuiButton")
	assert(textLabel:IsA("TextLabel"), "ChoiceGui Choices.Yes.TextLabel must be a TextLabel")
	assert(textLabel2:IsA("TextLabel"), "ChoiceGui Choices.No.TextLabel must be a TextLabel")
	assert(timer:IsA("TextLabel"), "ChoiceGui Top.Timer must be a TextLabel")
	local v5 = {
		Container = container,
		Title = title,
		Question = mainTitle,
		YesButton = yes,
		NoButton = no,
		YesLabel = textLabel,
		NoLabel = textLabel2,
		Timer = timer,
		RestingPosition = container.Position
	}
	v = v5
	container.Visible = false
	timer.Visible = false

	if choiceGui:IsA("ScreenGui") then
		choiceGui.Enabled = true
	end

	return v5
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayClick()
	local SFX = SoundService:FindFirstChild("SFX")
	local click = SFX and SFX:FindFirstChild("Click")

	if click and click:IsA("Sound") then
		click:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelSlide()
	if completedConnection then
		completedConnection:Disconnect()
		completedConnection = nil
	end

	if v4 then
		v4:Cancel()
		v4 = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function HiddenPosition(p)
	local restingPosition = p.RestingPosition
	return UDim2.new(restingPosition.X.Scale, restingPosition.X.Offset, -1 - p.Container.Size.Y.Scale, 0)
end

local function SetShown(p, flag: boolean)
	if v3 == flag then
		return
	end

	v3 = flag
	CancelSlide() -- equivalent call inferred; original call site unknown
	local container = p.Container

	if flag then
		if not container.Visible then
			container.Position = HiddenPosition(p)
		end

		container.Visible = true
	end

	local attribute = container:GetAttribute(flag and "SlideInSeconds" or "SlideOutSeconds")
	local v5 = math.clamp(type(attribute) ~= "number" and (flag and 0.35 or 0.25) or attribute, 0.05, 2)
	local quad = Enum.EasingStyle.Quad
	local v7

	if flag then
		v7 = Enum.EasingDirection.Out
	else
		v7 = Enum.EasingDirection.In
	end

	local tweenInfo = TweenInfo.new(v5, quad, v7)
	local position

	if flag then
		position = p.RestingPosition
	else
		position = HiddenPosition(p)
	end

	local v10 = TweenService:Create(container, tweenInfo, {
		Position = position
	})
	v4 = v10
	completedConnection = v10.Completed:Connect(function(p2)
		if v4 ~= v10 then
			return
		end

		CancelSlide() -- equivalent call inferred; original call site unknown

		if p2 == Enum.PlaybackState.Completed then
			if not v3 then
				container.Visible = false
			end

			container.Position = p.RestingPosition
		end
	end)
	v10:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CancelThread(thread: thread?)
	if thread and thread ~= coroutine.running() and coroutine.status(thread) == "suspended" then
		task.cancel(thread)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ResetLabels(data)
	data.Title.Text = "Confirm"
	data.YesLabel.Text = "Yes"
	data.NoLabel.Text = "No"
	data.Timer.Visible = false
end

local function Resolve(state, flag: boolean, p: string)
	if state.Resolved then
		return
	end

	state.Resolved = true

	for _, connection in state.Connections do
		connection:Disconnect()
	end

	table.clear(state.Connections)
	CancelThread(state.TimeoutThread) -- equivalent call inferred; original call site unknown
	state.TimeoutThread = nil
	CancelThread(state.TimerThread) -- equivalent call inferred; original call site unknown
	state.TimerThread = nil

	if v2 == state then
		v2 = nil
		local v5 = v

		if v5 and v5.Container.Parent then
			ResetLabels(v5) -- equivalent call inferred; original call site unknown
			SetShown(v5, false)
		end
	end

	task.spawn(state.Thread, flag, p)
end

local function StartTimer(p, p2, timeout: number)
	p.Timer.Visible = true
	local v5 = os.clock() + timeout
	p2.TimerThread = task.spawn(function()
		while true do
			local v6 = v5 - os.clock()

			if v6 <= 0 then
				break
			end

			p.Timer.Text = `{math.ceil(v6)}s`
			task.wait((math.min(0.25, v6)))
		end

		p.Timer.Text = "0s"
	end)
	p2.TimeoutThread = task.delay(timeout, function()
		Resolve(p2, false, "Timeout")
	end)
end

local v5 = {}

function v5.Ask(text: string, options)
	assert(type(text) == "string", "Confirmation.Ask: question must be a string")
	local v6 = options or {}
	local timeout = v6.Timeout
	local v7

	if timeout == nil then
		v7 = true
	elseif type(timeout) == "number" then
		v7 = timeout > 0
	else
		v7 = false
	end

	assert(v7, "Confirmation.Ask: Timeout must be a positive number")
	local view = GetView()

	if v2 then
		Resolve(v2, false, "Cancelled")
	end

	local v9 = {
		Thread = coroutine.running(),
		Connections = {},
		Resolved = false
	}
	v2 = v9
	GamepadUI.Watch(view.Container, v5.Cancel, view.NoButton, 20)
	view.Title.Text = v6.Title or "Confirm"
	view.Question.Text = text
	view.YesLabel.Text = v6.YesText or "Yes"
	view.NoLabel.Text = v6.NoText or "No"
	view.Timer.Visible = false
	table.insert(v9.Connections, view.YesButton.Activated:Connect(function()
		PlayClick() -- equivalent call inferred; original call site unknown
		Resolve(v9, true, "Yes")
	end))
	table.insert(v9.Connections, view.NoButton.Activated:Connect(function()
		PlayClick() -- equivalent call inferred; original call site unknown
		Resolve(v9, false, "No")
	end))
	table.insert(v9.Connections, view.Container.Destroying:Connect(function()
		v = nil
		v3 = false
		CancelSlide() -- equivalent call inferred; original call site unknown
		Resolve(v9, false, "Cancelled")
	end))

	if timeout then
		StartTimer(view, v9, timeout)
	end

	SetShown(view, true)
	return coroutine.yield()
end

function v5.Cancel()
	if v2 then
		Resolve(v2, false, "Cancelled")
	end
end

function v5.IsOpen()
	return v2 ~= nil
end

return table.freeze(v5)