local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quint)
local GuiModule = {
	Enabled = false,
	Minimized = false,
	Is88 = false,
	ShowContext = false,
	_dragging = false,
	_resizing = false,
	_animatedKeys = {},
	_connections = {},
	_TRANSPOSITION_INCREMENT = 1,
	_VOLUME_INCREMENT = 0.1,
	_MIN_ANIMATION_DURATION = 0,
	_MAX_ANIMATION_DURATION = 4,
	_BUTTON_EFFECT_DELAY = 0.1,
	ColorSettings = {
		IconColor = Color3.fromRGB(255, 255, 255),
		InactiveButtonColor = Color3.fromRGB(255, 255, 255),
		BacklightColor = Color3.fromRGB(20, 20, 20),
		ActiveButtonColor = Color3.fromRGB(170, 170, 170),
		ActiveBacklightColor = Color3.fromRGB(51, 160, 255),
		ActiveWhiteKeyColor = Color3.fromRGB(0, 255, 0),
		ActiveBlackKeyColor = Color3.fromRGB(0, 255, 0),
		WhiteKeyColor = Color3.fromRGB(255, 255, 255),
		BlackKeyColor = Color3.fromRGB(0, 0, 0)
	}
}
local parent = script.Parent
GuiModule.PianoGui = {
	Gui = parent,
	PianoKeys = {},
	VelocityFrame = parent.MainFrame.TopFrame.VelocityFrame,
	VelocityBar = parent.MainFrame.TopFrame.VelocityFrame.BarFrame.VelocityBar,
	MainFrame = parent.MainFrame,
	MainFrameAspectRatio = parent.MainFrame.UIAspectRatioConstraint,
	TopFrame = parent.MainFrame.TopFrame,
	ShadowFrame = parent.MainFrame.ShadowFrame,
	KeyFrame = parent.MainFrame.TopFrame.KeyFrame,
	Keys = parent.MainFrame.TopFrame.KeyFrame.Keys,
	Border = parent.MainFrame.TopFrame.KeyFrame.Border,
	Toggle88Button = parent.MainFrame.TopFrame.DisplayFrame.Toggle88,
	LCDFrame = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.LCDBorderFrame.LCDFrame,
	MonitorInlayFrame = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.MonitorInlayFrame,
	SheetsButton = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.Sheets.ImageButton,
	SheetsFrame = parent.SheetsFrame,
	ResizeButton = parent.SheetsFrame.Resize,
	HomeButton = parent.SheetsFrame.Home.HomeButton,
	SheetBox = parent.SheetsFrame.SheetsFrame.LEDFrame.ScrollingFrame.SheetBox,
	FontPlusButton = parent.SheetsFrame.ButtonsFrame.FontPlus.ImageButton,
	FontMinusButton = parent.SheetsFrame.ButtonsFrame.FontMinus.ImageButton,
	DeleteButton = parent.SheetsFrame.ButtonsFrame.FontDelete.ImageButton,
	SoundFontButton = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.SoundFont.ImageButton,
	TranspositionDownButton = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.TranspositionDown.ImageButton,
	TranspositionUpButton = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.TranspositionUp.ImageButton,
	TranspositionLabel = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.LCDBorderFrame.LCDFrame.TranspositionLabel,
	TranspositionNumber = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.LCDBorderFrame.LCDFrame.TranspositionLabel.TranspositionNumber,
	TranspositionIcon = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.TranspositionIcon,
	ShiftLockButton = parent.MainFrame.TopFrame.DisplayFrame.LeftButtonFrame.TranspositionIcon.ShiftLock,
	VolumeDownButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.VolumeDown.ImageButton,
	VolumeUpButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.VolumeUp.ImageButton,
	VolumeLabel = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.LCDBorderFrame.LCDFrame.VolumeLabel,
	VolumeNumber = parent.MainFrame.TopFrame.DisplayFrame.MonitorFrame.LCDBorderFrame.LCDFrame.VolumeLabel.VolumeNumber,
	VolumeIcon = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.VolumeIcon,
	SustainButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Sustain.ImageButton,
	SustainLight = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Sustain.SustainLight.Lightblur,
	SettingsButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Settings.ImageButton,
	CameraButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Camera.ImageButton,
	ContextButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Context.ImageButton,
	ExitButton = parent.MainFrame.TopFrame.DisplayFrame.RightButtonFrame.Exit.ImageButton,
	MinimizeButton = parent.MainFrame.TopFrame.Minimize,
	_SHEETS_RESIZE_CONSTRAINT = Vector2.new(200, 200),
	_ORIGINAL_SHEETS_POSITION = parent.SheetsFrame.Position,
	_ORIGINAL_SHEETS_SIZE = parent.SheetsFrame.Size,
	_ORIGINAL_SHEETS_TEXT_SIZE = parent.SheetsFrame.SheetsFrame.LEDFrame.ScrollingFrame.SheetBox.TextSize
}
local v = nil
local pianoController = nil
local v2 = nil
local v3 = nil

for i = 1, 88 do
	table.insert(GuiModule.PianoGui.PianoKeys, GuiModule.PianoGui.KeyFrame.Keys:FindFirstChild(i))
end

GuiModule._buttons = {
	GuiModule.PianoGui.SheetsButton,
	GuiModule.PianoGui.SoundFontButton,
	GuiModule.PianoGui.TranspositionDownButton,
	GuiModule.PianoGui.TranspositionUpButton,
	GuiModule.PianoGui.VolumeDownButton,
	GuiModule.PianoGui.VolumeUpButton,
	GuiModule.PianoGui.SustainButton,
	GuiModule.PianoGui.CameraButton,
	GuiModule.PianoGui.SettingsButton,
	GuiModule.PianoGui.ContextButton,
	GuiModule.PianoGui.ExitButton
}

local function IsBlack(p: number)
	local v4 = (p - 1) % 12 + 1

	if v4 % 12 == 2 or v4 % 12 == 5 or v4 % 12 == 7 or v4 % 12 == 10 or v4 % 12 == 0 then
		return true
	end
end

function GuiModule:ToggleEnabled(enabled, p)
	if not p and type(enabled) == "boolean" and enabled == self.Enabled then
		return
	end

	if enabled == nil then
		enabled = not self.Enabled
	end

	self.Enabled = enabled
	self.PianoGui.Gui.Enabled = self.Enabled
end

function GuiModule:Toggle88Keys(is, p)
	if not p and type(is) == "boolean" and is == self.Is88 then
		return
	end

	if is == nil then
		is = not self.Is88
	end

	self.Is88 = is
	v:Play(self.PianoGui.MainFrameAspectRatio, tweenInfo, {
		AspectRatio = self.Is88 and 4.3 or 3
	})
	v:Play(self.PianoGui.KeyFrame, tweenInfo, {
		Size = UDim2.fromScale(self.Is88 and 0.96 or 0.95, 0.48)
	})
	v:Play(self.PianoGui.Keys, tweenInfo, {
		Position = UDim2.fromScale(self.Is88 and 0.518 or 0.5, 1)
	})
	local pianoKey = self.PianoGui.PianoKeys[77]
	v:Play(pianoKey, tweenInfo, {
		Transparency = self.Is88 and 0 or 1
	})
	v:Play(pianoKey.NoteLabel, tweenInfo, {
		TextTransparency = self.Is88 and 0 or 1
	})
	self.PianoGui.Toggle88Button.ImageColor3 = self.Is88 and self.ColorSettings.ActiveBacklightColor or Color3.fromRGB(
		128,
		128,
		128
	)
	self:ResetKeys()
end

function GuiModule:ToggleMinimized(minimized, p)
	if not p and type(minimized) == "boolean" and minimized == self.Minimized then
		return
	end

	if minimized == nil then
		minimized = not self.Minimized
	end

	self.Minimized = minimized
	local mainFrame = self.PianoGui.MainFrame

	if self.Enabled then
		local v4 = v
		local position

		if self.Minimized then
			position = UDim2.new(0.5, 0, 1, 0)
		else
			position = UDim2.new(0.5, 0, 1, -35)
		end

		v4:Play(mainFrame, tweenInfo, {
			Position = position,
			AnchorPoint = Vector2.new(0.5, self.Minimized and 0 or 1)
		})
	else
		mainFrame.Position = self.Minimized and UDim2.new(0.5, 0, 1, mainFrame.AbsoluteSize.Y) or UDim2.new(
			0.5,
			0,
			1,
			-35
		)
		mainFrame.AnchorPoint = Vector2.new(0.5, self.Minimized and 0 or 1)
	end
end

function GuiModule:ToggleContext(showContext, p)
	if not p and type(showContext) == "boolean" and showContext == self.ShowContext then
		return
	end

	if showContext == nil then
		showContext = not self.ShowContext
	end

	self.ShowContext = showContext

	for _, _button in ipairs(self._buttons) do
		local contextLabel = _button.Parent:FindFirstChild("ContextLabel")

		if contextLabel then
			contextLabel.Visible = self.ShowContext
		end
	end

	self.PianoGui.Toggle88Button.ContextLabel.Visible = self.ShowContext
	self.PianoGui.MinimizeButton.ContextLabel.Visible = self.ShowContext
	self:AnimateButtonToggle(self.PianoGui.ContextButton, self.ShowContext)
end

function GuiModule:AnimateVelocityChange(p2, p3)
	if not self.PianoGui.VelocityFrame.Visible then
		self.PianoGui.VelocityFrame.Visible = true
	end

	v:Play(self.PianoGui.VelocityBar, tweenInfo2, {
		Size = UDim2.new(p2 / p3, 0, 1, 0)
	})
end

function GuiModule:AnimateButtonPress(state)
	local parent2 = state.Parent

	if state.ImageColor3 ~= self.ColorSettings.ActiveButtonColor then
		state.ImageColor3 = self.ColorSettings.ActiveButtonColor
		parent2.ImageColor3 = self.ColorSettings.ActiveBacklightColor
		task.delay(self._BUTTON_EFFECT_DELAY, function()
			state.ImageColor3 = self.ColorSettings.InactiveButtonColor
			parent2.ImageColor3 = self.ColorSettings.BacklightColor
		end)
	end
end

function GuiModule:AnimateButtonToggle(state, p2)
	local parent2 = state.Parent

	if p2 == true or p2 == nil and state.ImageColor3 ~= self.ColorSettings.ActiveButtonColor then
		state.ImageColor3 = self.ColorSettings.ActiveButtonColor
		parent2.ImageColor3 = self.ColorSettings.ActiveBacklightColor
	else
		state.ImageColor3 = self.ColorSettings.InactiveButtonColor
		parent2.ImageColor3 = self.ColorSettings.BacklightColor
	end
end

function GuiModule:AnimateSustainToggle(visible: boolean)
	self.PianoGui.SustainLight.Visible = visible
end

function GuiModule:AnimateShiftLockToggle(visible: boolean)
	self.PianoGui.TranspositionIcon.ImageColor3 = visible and self.ColorSettings.ActiveBacklightColor or self.ColorSettings.IconColor
	self.PianoGui.ShiftLockButton.TextColor3 = visible and self.ColorSettings.ActiveBacklightColor or Color3.fromRGB(
		64,
		64,
		64
	)
	self.PianoGui.ShiftLockButton.Visible = visible
end

function GuiModule:ChangeSheetsTextSize(p2, p3)
	self.PianoGui.SheetBox.TextSize = math.max(1, p2 + self.PianoGui.SheetBox.TextSize * (p3 and 0 or 1))
end

function GuiModule:ClearTextBox()
	self.PianoGui.SheetBox.Text = ""
end

function GuiModule:DragFrame(p, data)
	self._dragging = true
	local changedConnection = nil
	local position = data.Position
	local position2 = p.Position
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self._dragging and not self._resizing then
			if input.Position.X + input.Position.Y == 0 then
				return
			end

			local v4 = input.Position - position
			p.Position = UDim2.new(
				position2.X.Scale,
				position2.X.Offset + v4.X,
				position2.Y.Scale,
				position2.Y.Offset + v4.Y
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

function GuiModule:ResizeSheetsFrame(data)
	local sheetsFrame = self.PianoGui.SheetsFrame
	local _SHEETS_RESIZE_CONSTRAINT = self.PianoGui._SHEETS_RESIZE_CONSTRAINT
	self._resizing = true
	local changedConnection = nil
	local position = data.Position
	local size = sheetsFrame.Size
	local position2 = sheetsFrame.Position
	local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and self._resizing then
			if input.Position.X + input.Position.Y == 0 then
				return
			end

			local v4 = input.Position - position
			sheetsFrame.Size = UDim2.new(
				size.X.Scale,
				size.X.Offset + v4.X > _SHEETS_RESIZE_CONSTRAINT.X and size.X.Offset + v4.X or _SHEETS_RESIZE_CONSTRAINT.X,
				size.Y.Scale,
				size.Y.Offset + v4.Y > _SHEETS_RESIZE_CONSTRAINT.Y and size.Y.Offset + v4.Y or _SHEETS_RESIZE_CONSTRAINT.Y
			)
			sheetsFrame.Position = UDim2.new(
				position2.X.Scale,
				size.X.Offset + v4.X > _SHEETS_RESIZE_CONSTRAINT.X and position2.X.Offset + v4.X / 2 or position2.X.Offset + (_SHEETS_RESIZE_CONSTRAINT.X - size.X.Offset) / 2,
				position2.Y.Scale,
				size.Y.Offset + v4.Y > _SHEETS_RESIZE_CONSTRAINT.Y and position2.Y.Offset + v4.Y / 2 or position2.Y.Offset + (_SHEETS_RESIZE_CONSTRAINT.Y - size.Y.Offset) / 2
			)
		end
	end)
	changedConnection = data.Changed:Connect(function()
		if data.UserInputState == Enum.UserInputState.End then
			self._resizing = false
			inputChangedConnection:Disconnect()
			changedConnection:Disconnect()
		end
	end)
end

function GuiModule:ResetSheetsFrame()
	self.PianoGui.SheetsFrame.Position = self.PianoGui._ORIGINAL_SHEETS_POSITION
	self.PianoGui.SheetsFrame.Size = self.PianoGui._ORIGINAL_SHEETS_SIZE
	self:ChangeSheetsTextSize(self.PianoGui._ORIGINAL_SHEETS_TEXT_SIZE, true)
end

function GuiModule:AnimateKeyDown(p, p2)
	local v4 = math.clamp(p2 + 15, (self.Is88 and 0 or 15) + 1, 88 - (self.Is88 and 0 or 12))
	self._animatedKeys[v4] = p
	local pianoKey = self.PianoGui.PianoKeys[v4]
	local v5 = (v4 - 1) % 12 + 1
	local backgroundColor

	if v5 % 12 == 2 or v5 % 12 == 5 or v5 % 12 == 7 or v5 % 12 == 10 or v5 % 12 == 0 then
		backgroundColor = self.ColorSettings.ActiveBlackKeyColor
	else
		backgroundColor = self.ColorSettings.ActiveWhiteKeyColor
	end

	pianoKey.BackgroundColor3 = backgroundColor
	local total = 0

	while self._animatedKeys[v4] ~= p and total < self._MIN_ANIMATION_DURATION or self._animatedKeys[v4] == p and total < self._MAX_ANIMATION_DURATION do
		total += RunService.Heartbeat:Wait()
	end

	local pianoKey2 = self.PianoGui.PianoKeys[v4]
	local v7 = (v4 - 1) % 12 + 1
	local backgroundColor2

	if v7 % 12 == 2 or v7 % 12 == 5 or v7 % 12 == 7 or v7 % 12 == 10 or v7 % 12 == 0 then
		backgroundColor2 = self.ColorSettings.BlackKeyColor
	else
		backgroundColor2 = self.ColorSettings.WhiteKeyColor
	end

	pianoKey2.BackgroundColor3 = backgroundColor2
end

function GuiModule:AnimateKeyUp(p2)
	for k, _animatedKey in pairs(self._animatedKeys) do
		if _animatedKey == p2 then
			self._animatedKeys[k] = nil
		end
	end
end

function GuiModule:ResetKeys()
	table.clear(self._animatedKeys)

	for i, pianoKey in ipairs(self.PianoGui.PianoKeys) do
		local v4 = (i - 1) % 12 + 1
		pianoKey.BackgroundColor3 = (v4 % 12 == 2 or v4 % 12 == 5 or v4 % 12 == 7 or v4 % 12 == 10 or v4 % 12 == 0 or nil) and self.ColorSettings.BlackKeyColor or self.ColorSettings.WhiteKeyColor
	end
end

function GuiModule:ResetGui()
	self:ToggleEnabled(false, true)
	self:Toggle88Keys(false, true)
	self:ToggleMinimized(false, true)
	self:ToggleContext(false, true)
	self.PianoGui.SheetsFrame.Visible = false
	self:AnimateButtonToggle(self.PianoGui.SheetsButton, false)
	self:AnimateButtonToggle(self.PianoGui.SoundFontButton, false)
	self:ResetSheetsFrame()
	self:ResetKeys()
end

function GuiModule:ConnectPianoController()
	if #self._connections > 0 then
		warn("[PianoGui]: Found preexisting PianoController connections, disconnecting")
		self:DisconnectPianoController()
	end

	self._connections = {
		self.PianoGui.MinimizeButton.Activated:Connect(function()
			self:ToggleMinimized()
		end),
		self.PianoGui.VelocityFrame.Activated:Connect(function()
			pianoController:ChangeVelocity(1, true)
			self.PianoGui.VelocityFrame.Visible = false
		end),
		self.PianoGui.Toggle88Button.Activated:Connect(function()
			self:Toggle88Keys()
		end),
		self.PianoGui.SheetsButton.Activated:Connect(function()
			self.PianoGui.SheetsFrame.Visible = not self.PianoGui.SheetsFrame.Visible
			self:AnimateButtonToggle(self.PianoGui.SheetsButton, self.PianoGui.SheetsFrame.Visible)
		end),
		self.PianoGui.SoundFontButton.Activated:Connect(function()
			v2:ToggleEnabled()
			self:AnimateButtonPress(self.PianoGui.SoundFontButton)
		end),
		self.PianoGui.SheetsFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and self.PianoGui.SheetsFrame.Visible then
				self:DragFrame(self.PianoGui.SheetsFrame, input)
			end
		end),
		self.PianoGui.ResizeButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and self.PianoGui.SheetsFrame.Visible then
				self:ResizeSheetsFrame(input)
			end
		end),
		self.PianoGui.HomeButton.Activated:Connect(function()
			self:ResetSheetsFrame()
		end),
		self.PianoGui.FontPlusButton.Activated:Connect(function()
			self:ChangeSheetsTextSize(1)
		end),
		self.PianoGui.FontMinusButton.Activated:Connect(function()
			self:ChangeSheetsTextSize(-1)
		end),
		self.PianoGui.DeleteButton.Activated:Connect(function()
			self:ClearTextBox()
		end),
		self.PianoGui.TranspositionUpButton.Activated:Connect(function()
			pianoController:ChangeTransposition(self._TRANSPOSITION_INCREMENT)
		end),
		self.PianoGui.TranspositionDownButton.Activated:Connect(function()
			pianoController:ChangeTransposition(-self._TRANSPOSITION_INCREMENT)
		end),
		self.PianoGui.VolumeUpButton.Activated:Connect(function()
			pianoController:ChangeVolume(self._VOLUME_INCREMENT)
		end),
		self.PianoGui.VolumeDownButton.Activated:Connect(function()
			pianoController:ChangeVolume(-self._VOLUME_INCREMENT)
		end),
		self.PianoGui.SustainButton.Activated:Connect(function()
			pianoController:ToggleSustain()
		end),
		self.PianoGui.TranspositionIcon.Activated:Connect(function()
			pianoController:ToggleShiftLock()
		end),
		self.PianoGui.ShiftLockButton.Activated:Connect(function()
			pianoController:ToggleShiftLock()
		end),
		self.PianoGui.SettingsButton.Activated:Connect(function()
			v3:ToggleEnabled()
			self:AnimateButtonPress(self.PianoGui.SettingsButton)
		end),
		self.PianoGui.ContextButton.Activated:Connect(function()
			self:ToggleContext()
		end),
		self.PianoGui.CameraButton.Activated:Connect(function()
			pianoController:ChangeCamera(1)
			self:AnimateButtonPress(self.PianoGui.CameraButton)
		end),
		self.PianoGui.ExitButton.Activated:Connect(function()
			pianoController:Deactivate()
		end),
		pianoController.KeyPressed:Connect(function(p, p2, p3)
			self:AnimateKeyDown(p, p2 + p3)
		end),
		pianoController.KeyReleased:Connect(function(p)
			self:AnimateKeyUp(p)
		end),
		pianoController.TranspositionChanged:Connect(function(text, p)
			if p == 0 then
				return
			end

			self:AnimateButtonPress(p < 0 and self.PianoGui.TranspositionDownButton or self.PianoGui.TranspositionUpButton)
			self.PianoGui.TranspositionNumber.Text = text
		end),
		pianoController.VolumeChanged:Connect(function(p, p2)
			if p2 == 0 then
				return
			end

			self:AnimateButtonPress(p2 < 0 and self.PianoGui.VolumeDownButton or self.PianoGui.VolumeUpButton)
			self.PianoGui.VolumeNumber.Text = math.floor(p * 100 + 0.5) .. "%"
		end),
		pianoController.VelocityChanged:Connect(function(p, _)
			self:AnimateVelocityChange(p, 2)
		end),
		pianoController.SustainChanged:Connect(function(p, _)
			self:AnimateSustainToggle(p)
		end),
		pianoController.ShiftLockChanged:Connect(function(p)
			self:AnimateShiftLockToggle(p)
		end),
		pianoController.Activated:Connect(function()
			self:ResetKeys()
			self:ToggleEnabled(true)
		end),
		pianoController.Deactivated:Connect(function()
			self:ToggleEnabled(false)
			self:ResetKeys()
		end)
	}

	for i, pianoKey in ipairs(self.PianoGui.PianoKeys) do
		local v4 = i
		table.insert(self._connections, pianoKey.MouseButton1Down:Connect(function()
			if not pianoController.Active then
				return
			end

			pianoController:PressClientKey(Enum.UserInputType.MouseButton1, v4 - 15, 0)
		end))
		table.insert(self._connections, pianoKey.InputEnded:Connect(function(input, gameProcessed)
			if gameProcessed or not pianoController.Active then
				return
			end

			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				pianoController:ReleaseClientKey(Enum.UserInputType.MouseButton1)
			end
		end))
	end
end

function GuiModule:DisconnectPianoController()
	for _, _connection in ipairs(self._connections) do
		_connection:Disconnect()
	end

	table.clear(self._connections)
end

function GuiModule:IsConnected()
	return #self._connections > 0
end

function GuiModule:Init()
	pianoController = script.Parent.Parent:WaitForChild("PianoController")
	local Tween = require(pianoController.Tween)
	v = Tween
	local module = require(pianoController)
	pianoController = module
	self:ResetGui()
end

function GuiModule:Start()
	local GuiModule2 = require(script.Parent.Parent:WaitForChild("SoundFontGui"):WaitForChild("GuiModule"))
	v2 = GuiModule2
	local GuiModule3 = require(script.Parent.Parent:WaitForChild("SettingsGui"):WaitForChild("GuiModule"))
	v3 = GuiModule3
	self:ConnectPianoController()
	pianoController.DeviceChanged:Connect(function(p)
		if p == "Desktop" then
			if GuiModule:IsConnected() then
				return
			else
				GuiModule:ConnectPianoController()
			end
		elseif p == "Mobile" then
			if not GuiModule:IsConnected() then
				return
			end

			GuiModule:DisconnectPianoController()
		end

		if pianoController.Active then
			self:ToggleEnabled(p == "Desktop", true)
		end
	end)
end

return GuiModule