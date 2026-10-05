local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local module = require("./PassiveHandler")
require(ReplicatedStorage.client.legacyControllers.ReelController.Types)
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local object = setmetatable({}, {
	__index = module
})
object.NoMock = true

function object:BuildUi()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TutorialReelOverlay"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 1000
	screenGui.Parent = playerGui
	self.reelTrove:Add(screenGui)
	local screenGui2 = Instance.new("ScreenGui")
	screenGui2.Name = "TutorialReelSpotlight"
	screenGui2.ResetOnSpawn = false
	screenGui2.IgnoreGuiInset = false
	screenGui2.DisplayOrder = 999
	screenGui2.Parent = playerGui
	self.reelTrove:Add(screenGui2)
	local _ = script.TutorialLabel
	local clone = script.TutorialLabel:Clone()
	clone.Text = ""
	clone.Visible = false
	clone.Parent = screenGui
	local clone2 = script.TutorialButton:Clone()
	clone2.Parent = screenGui
	self._overlay = screenGui
	self._spotlightOverlay = screenGui2
	self._label = clone
	self._button = clone2
end

function object:SetText(text: string?)
	local _label = self._label

	if not _label then
		return
	end

	if text and text ~= "" then
		_label.Text = text
		_label.Visible = true
		_label.MaxVisibleGraphemes = 0
		TweenService:Create(_label, TweenInfo.new(0.35, Enum.EasingStyle.Linear), {
			MaxVisibleGraphemes = #_label.ContentText
		}):Play()
		local position = _label.Position
		_label.Position = position + UDim2.fromScale(0, 0.025)
		TweenService:Create(_label, TweenInfo.new(0.35, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
			Position = position
		}):Play()
	else
		_label.Visible = false
		_label.Text = ""
	end
end

function object:ResolveTarget(value: string?)
	if not (value and self.current) then
		return nil
	end

	local reel = self.current.reel

	for _, childName in string.split(value, ".") do
		if not reel then
			return nil
		end

		reel = reel:FindFirstChild(childName)
	end

	if reel and reel:IsA("GuiObject") then
		return reel
	end

	return nil
end

function object:Spotlight(instance, udim: UDim2?)
	local v = udim or UDim2.new()
	local frame = Instance.new("Frame")
	frame.Name = "Spotlight"
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.ZIndex = 10
	local numberValue = Instance.new("NumberValue")
	numberValue.Value = 200
	numberValue.Parent = frame
	TweenService:Create(numberValue, TweenInfo.new(1, Enum.EasingStyle.Circular, Enum.EasingDirection.Out), {
		Value = 0
	}):Play()
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Thickness = 2000
	uIStroke.Color = Color3.fromRGB(0, 0, 0)
	uIStroke.Transparency = 0.2
	uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uIStroke.Parent = frame
	frame.Parent = self._spotlightOverlay
	local renderSteppedConnection = RunService.RenderStepped:Connect(function()
		local parent = instance.Parent

		if not (parent and parent:IsA("GuiObject")) then
			return
		end

		local absolutePosition = parent.AbsolutePosition
		local absoluteSize = parent.AbsoluteSize
		local absoluteSize2 = instance.AbsoluteSize
		local v2 = absolutePosition.X + instance.Position.X.Scale * absoluteSize.X + instance.Position.X.Offset + (0.5 - instance.AnchorPoint.X) * absoluteSize2.X
		local v3 = absolutePosition.Y + instance.Position.Y.Scale * absoluteSize.Y + instance.Position.Y.Offset + (0.5 - instance.AnchorPoint.Y) * absoluteSize2.Y
		local screenGui = instance:FindFirstAncestorOfClass("ScreenGui")

		if screenGui and screenGui.IgnoreGuiInset then
			v3 += GuiService:GetGuiInset().Y
		end

		frame.Size = UDim2.fromOffset(absoluteSize2.X, absoluteSize2.Y) + UDim2.fromOffset(
			numberValue.Value,
			numberValue.Value
		) + v
		frame.Position = UDim2.fromOffset(v2, v3)
	end)
	frame.Destroying:Connect(function()
		renderSteppedConnection:Disconnect()
	end)
	return frame
end

function object:SetPaused(isPaused: boolean)
	local current = self.current

	if not current then
		return
	end

	current.isPaused = isPaused
end

function object:WaitForNext(value: string?)
	local _button = self._button

	if not _button then
		return self._alive == true
	end

	local v = false
	local flag = false
	_button.Label.Text = value or "Next"
	_button.Visible = true
	local activatedConnection = _button.Activated:Connect(function()
		if flag then
			v = true
		end
	end)
	local inputBeganConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.KeyCode == Enum.KeyCode.ButtonX and flag then
			v = true
		end
	end)
	task.delay(0.5, function()
		flag = true
	end)

	while not v and self._alive and self.current do
		task.wait()
	end

	activatedConnection:Disconnect()
	inputBeganConnection:Disconnect()

	if _button.Parent then
		_button.Visible = false
	end

	return v
end

function object:WaitForTrigger(p2)
	local trigger = p2.Trigger

	if trigger then
		local type = trigger.Type

		if type == "Ready" then
			if self.current and not self.current.ready then
				self.current:WaitUntilReady()
			end
		elseif type == "Delay" then
			task.wait(trigger.Value or 0)
		elseif type == "Progress" then
			while self._alive and self.current and self.current.progress < (trigger.Value or 0) do
				task.wait()
			end
		elseif type == "FishOnBar" then
			while self._alive and self.current and not self.current.onbar do
				task.wait()
			end
		elseif type == "FishOffBar" then
			while self._alive and self.current and self.current.onbar do
				task.wait()
			end
		end

		return self._alive == true and self.current ~= nil
	else
		return self._alive == true and self.current ~= nil
	end
end

function object:RunStep(data)
	local target = self:ResolveTarget(data.Spotlight)
	local v

	if target then
		local spotlightPadding = data.SpotlightPadding
		local v2

		if spotlightPadding then
			v2 = UDim2.fromOffset(spotlightPadding[1] or 0, spotlightPadding[2] or spotlightPadding[1] or 0)
		end

		v = self:Spotlight(target, v2)
	end

	self:SetText(data.Text)

	if data.Pause then
		self:SetPaused(true)
		self:WaitForNext(data.ButtonText)
		self:SetPaused(false)
	elseif data.Duration then
		task.wait(data.Duration)
	end

	if v then
		v:Destroy()
	end

	self:SetText(nil)
end

function object:Run()
	local steps = self.config and self.config.Steps

	if not steps then
		return
	end

	for _, step in steps do
		if self._alive and self.current then
			if not self:WaitForTrigger(step) then
				break
			end

			self:RunStep(step)
		else
			break
		end
	end
end

function object:Morph(reel, current)
	self.reel = reel
	self.current = current

	if self._started then
		return
	end

	self._started = true
	self._alive = true
	self:BuildUi()
	self.reelTrove:Add(function()
		self._alive = false

		if self.current then
			self.current.isPaused = false
		end
	end)
	self.reelTrove:Add(current.OnMinigameEnd:Connect(function()
		self._alive = false

		if self.current then
			self.current.isPaused = false
		end
	end))
	self.reelTrove:Add(task.spawn(function()
		self:Run()
	end))
end

function object:Cleanup()
	self._alive = false
	self._started = false

	if self.current then
		self.current.isPaused = false
	end

	if self.reelTrove then
		self.reelTrove:Clean()
	end

	self._overlay = nil
	self._spotlightOverlay = nil
	self._label = nil
	self._button = nil
	self.current = nil
end

function object:Destroy()
	self._alive = false

	if self.current then
		self.current.isPaused = false
	end

	self.trove:Destroy()
	table.clear(self)
end

return object