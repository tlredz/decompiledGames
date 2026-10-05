Color3.fromRGB(255, 255, 255)
Color3.fromRGB(84, 84, 84)
Color3.fromRGB(255, 192, 64)
local UserInputService = game:GetService("UserInputService")
local pianoController = nil
local v = nil
local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local parent = script.Parent
local GuiModule = {}
GuiModule.Enabled = false
GuiModule.SettingsGui = {
	Gui = parent,
	MainFrame = parent.MainFrame,
	TitleLabel = parent.MainFrame.TitleLabel,
	CloseButton = parent.MainFrame.CloseButton,
	BodyFrame = parent.MainFrame.BodyFrame,
	ListFrame = parent.MainFrame.BodyFrame.ListFrame,
	SettingTemplate = parent.MainFrame.BodyFrame.ListFrame.SettingTemplate
}

function GuiModule:ToggleEnabled(enabled, p)
	if not p and type(enabled) == "boolean" and enabled == self.Enabled then
		return
	end

	if enabled == nil then
		enabled = not self.Enabled
	end

	self.Enabled = enabled
	self.SettingsGui.Gui.Enabled = self.Enabled
end

function GuiModule:DragFrame(p2, data)
	self._dragging = true
	local changedConnection = nil
	local position = data.Position
	local position2 = p2.Position
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self._dragging then
			if input.Position.X + input.Position.Y == 0 then
				return
			end

			local v2 = input.Position - position
			p2.Position = UDim2.new(
				position2.X.Scale,
				position2.X.Offset + v2.X,
				position2.Y.Scale,
				position2.Y.Offset + v2.Y
			)
		end
	end)
	changedConnection = data.Changed:Connect(function()
		if data.UserInputState == Enum.UserInputState.End then
			self._dragging = false
			inputChangedConnection:Disconnect()
			changedConnection:Disconnect()
		end
	end)
end

function GuiModule:_createSettingButton(p2, p3, p4)
	local clone = self.SettingsGui.SettingTemplate:Clone()
	local textLabel = clone:WaitForChild("TextLabel")
	textLabel.Text = p4 or p3
	local toggleButton = clone:WaitForChild("ToggleButton")
	local buttonHead = toggleButton:WaitForChild("ButtonHead")
	toggleButton.Activated:Connect(function()
		pianoController[p2][p3] = not pianoController[p2][p3]
		local v2 = pianoController[p2][p3]
		local v3 = v
		local backgroundColor

		if v2 then
			backgroundColor = Color3.fromRGB(51, 160, 255)
		else
			backgroundColor = Color3.fromRGB(128, 128, 128)
		end

		v3:Play(toggleButton, tweenInfo, {
			BackgroundColor3 = backgroundColor
		})
		v:Play(buttonHead, tweenInfo, {
			AnchorPoint = Vector2.new(v2 and 1 or 0, 0.5),
			Position = UDim2.fromScale(v2 and 1 or 0, 0.5)
		})
	end)
	local v2 = pianoController[p2][p3]
	local backgroundColor2

	if v2 then
		backgroundColor2 = Color3.fromRGB(51, 160, 255)
	else
		backgroundColor2 = Color3.fromRGB(128, 128, 128)
	end

	toggleButton.BackgroundColor3 = backgroundColor2
	buttonHead.AnchorPoint = Vector2.new(v2 and 1 or 0, 0.5)
	buttonHead.Position = UDim2.fromScale(v2 and 1 or 0, 0.5)
	clone.Visible = true
	clone.Parent = self.SettingsGui.ListFrame
end

function GuiModule:Init()
	pianoController = script.Parent.Parent:WaitForChild("PianoController")
	local Tween = require(pianoController.Tween)
	v = Tween
	local module = require(pianoController)
	pianoController = module
	self:ToggleEnabled(false, true)
end

function GuiModule:Start()
	self.SettingsGui.MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Enabled then
			self:DragFrame(self.SettingsGui.MainFrame, input)
		end
	end)
	self.SettingsGui.CloseButton.Activated:Connect(function()
		self:ToggleEnabled(false, true)
	end)
	pianoController.Deactivated:Connect(function()
		self:ToggleEnabled(false, true)
	end)
	self:_createSettingButton("PianoSettings", "MIDI88", "ctrl key")
	self:_createSettingButton("PianoSettings", "MIDIVelocity", "alt key")
	self:_createSettingButton("PianoSettings", "EnableSustainHotkey", "spacebar")
	self:_createSettingButton("PianoSettings", "EnableShiftLockHotkey", "enter key")
end

return GuiModule