local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local v = {
	70,
	315,
	0.55,
	0.6
}
local v2 = {
	50,
	225,
	0.56,
	0.62
}
local v3 = {
	50,
	80,
	0.6,
	0.55
}
local v4 = {
	{ 0.04, 0.3333333333333333 },
	{ 0.1, 1 },
	{ 0.25, 0.75 },
	{ 0.25, 0.75 }
}
local GuiService = game:GetService("GuiService")
local guiInset = GuiService:GetGuiInset()
local v5 = math.max(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
local v6 = math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y) - guiInset.Y

if guiInset.Y == 0 then
	GuiService:GetPropertyChangedSignal("TopbarInset"):Once(function()
		guiInset = GuiService:GetGuiInset()
		v5 = math.max(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)
		v6 = math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y) - guiInset.Y
	end)
end

local pianoController = nil
local v7 = nil
local v8 = nil
local v9 = nil
local v10 = nil
local GuiModule = {
	Enabled = false,
	Minimized = false,
	DoubleLayout = false,
	_holding = nil,
	_sliderDown = nil,
	_connections = {},
	_glissando = false
}
local parent = script.Parent
GuiModule.MobilePianoGui = {
	Gui = parent,
	LayoutFrame = parent.LayoutFrame,
	MainFrame = parent.MainFrame,
	TopbarFrame = parent.MainFrame.TopbarFrame,
	SoundFontButton = parent.MainFrame.TopbarFrame.InsetFrame.LeftBar.SoundFont,
	SustainButton = parent.MainFrame.TopbarFrame.InsetFrame.LeftBar.Sustain,
	LayoutButton = parent.MainFrame.TopbarFrame.InsetFrame.LeftBar.Layout,
	LCDFrame = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.LCDFrame,
	SoundFontLabel = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.LCDFrame.InnerFrame.SoundFontLabel,
	VolumeFrame = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.VolumeFrame,
	VolumeHead = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.VolumeFrame.SliderFrame.Head,
	ExitButton = parent.MainFrame.TopbarFrame.InsetFrame.Exit,
	KeyFrame = parent.MainFrame.KeyFrame,
	OctaveFrame = parent.MainFrame.OctaveFrame,
	TranspositionFrame = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.TranspositionFrame,
	TopbarInsetFrame = parent.MainFrame.TopbarFrame.InsetFrame,
	OctaveInsetFrame = parent.MainFrame.OctaveFrame.InsetFrame,
	HitboxTemplate = parent.MainFrame.HitboxTemplate,
	SlideButton = parent.MainFrame.TopbarFrame.InsetFrame.CenterFrame.SlideButton
}
GuiModule.ColorSettings = {
	InactiveButtonColor = Color3.fromRGB(255, 255, 255),
	ActiveButtonColor = Color3.fromRGB(51, 160, 255),
	ActiveWhiteKeyColor = Color3.fromRGB(0, 255, 0),
	ActiveBlackKeyColor = Color3.fromRGB(0, 255, 0),
	WhiteKeyColor = Color3.fromRGB(255, 255, 255),
	BlackKeyColor = Color3.fromRGB(0, 0, 0)
}

if v6 <= 420 then
	v = v3
elseif v6 <= 731 then
	v = v2
end

GuiModule._whiteKeyWidth = v[1] / v5
GuiModule._whiteKeyHeight = v[2] / (v6 - GuiModule.MobilePianoGui.TopbarFrame.AbsoluteSize.Y - GuiModule.MobilePianoGui.OctaveFrame.AbsoluteSize.Y)
GuiModule._blackKeyWidth = v[3]
GuiModule._blackKeyHeight = v[4]

local function getHardwareHorizontalInset()
	local playerGui = game.Players.LocalPlayer.PlayerGui
	assert(playerGui)
	local v13 = playerGui:FindFirstChild("_FullscreenTestGui")

	if not v13 then
		v13 = Instance.new("ScreenGui")
		v13.Name = "_FullscreenTestGui"
		v13.Parent = playerGui
		v13.ScreenInsets = Enum.ScreenInsets.None
	end

	local v14 = playerGui:FindFirstChild("_DeviceTestGui")

	if not v14 then
		v14 = Instance.new("ScreenGui")
		v14.Name = "_DeviceTestGui"
		v14.Parent = playerGui
		v14.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	end

	local v15 = v14.AbsolutePosition - v13.AbsolutePosition
	local v16 = v13.AbsolutePosition + v13.AbsoluteSize - (v14.AbsolutePosition + v14.AbsoluteSize)
	return v15.X + v16.X
end

local function IsBlack(p: number)
	local v13 = (p - 1) % 12 + 1

	if v13 % 12 == 2 or v13 % 12 == 5 or v13 % 12 == 7 or v13 % 12 == 10 or v13 % 12 == 0 then
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
	self.MobilePianoGui.Gui.Enabled = self.Enabled
end

function GuiModule:ToggleMinimized(minimized, p)
	if not p and type(minimized) == "boolean" and minimized == self.Minimized then
		return
	end

	if minimized == nil then
		minimized = not self.Minimized
	end

	self.Minimized = minimized
	v10:Play(self.MobilePianoGui.MainFrame, tweenInfo, {
		AnchorPoint = Vector2.new(0.5, self.Minimized and 0 or 1),
		Position = UDim2.new(0.5, 0, 1, not self.Minimized and 0 or -self.MobilePianoGui.TopbarFrame.AbsoluteSize.Y)
	})
end

function GuiModule:ToggleDoubleLayout(doubleLayout, p)
	if not p and type(doubleLayout) == "boolean" and doubleLayout == self.DoubleLayout then
		return
	end

	if doubleLayout == nil then
		doubleLayout = not self.DoubleLayout
	end

	self.DoubleLayout = doubleLayout
	self.MobilePianoGui.KeyFrame.BottomKeyFrame.Visible = self.DoubleLayout
	self.MobilePianoGui.OctaveFrame.InsetFrame.BottomOctaveFrame.Visible = self.DoubleLayout
	self:_updateKeys()
end

function GuiModule:ToggleLayoutFrame(visible)
	local layoutFrame = self.MobilePianoGui.LayoutFrame

	if visible == nil then
		visible = not self.MobilePianoGui.LayoutFrame.Visible
	end

	layoutFrame.Visible = visible
	local icon = self.MobilePianoGui.LayoutButton.Icon
	local imageColor

	if self.MobilePianoGui.LayoutFrame.Visible then
		imageColor = self.ColorSettings.ActiveButtonColor
	else
		imageColor = self.ColorSettings.InactiveButtonColor
	end

	icon.ImageColor3 = imageColor
end

function GuiModule:_initializeLayoutFrame()
	local layoutFrame = self.MobilePianoGui.LayoutFrame
	local layoutBar = layoutFrame.LayoutBar
	layoutBar.SingleLayoutButton.Activated:Connect(function()
		self:ToggleDoubleLayout(false)
	end)
	layoutBar.DoubleLayoutButton.Activated:Connect(function()
		self:ToggleDoubleLayout(true)
	end)
	local keySliderFrame = layoutFrame.KeySliderFrame
	local v13 = {
		"_whiteKeyWidth",
		"_whiteKeyHeight",
		"_blackKeyWidth",
		"_blackKeyHeight"
	}

	for k, v14 in {
		keySliderFrame.WhiteKeyWidthSlider,
		keySliderFrame.WhiteKeyHeightSlider,
		keySliderFrame.BlackKeyWidthSlider,
		keySliderFrame.BlackKeyHeightSlider
	} do
		local sliderDown = k
		v14.MouseButton1Down:Connect(function()
			self._sliderDown = sliderDown
		end)
		local v16 = k
		local v17 = v14
		v14.MouseMoved:Connect(function(p, p2)
			if self._sliderDown ~= v16 then
				return
			end

			local v18 = (p - v17.AbsolutePosition.X) / v17.AbsoluteSize.X
			self[v13[v16]] = math.clamp(v4[v16][1] + (v4[v16][2] - v4[v16][1]) * v18, v4[v16][1], v4[v16][2])
			self:_updateLayoutSliders()
			self:_updateKeys()
		end)
	end

	local buttonBar = layoutFrame.ButtonBar
	buttonBar.ResetButton.Activated:Connect(function()
		self:_resetKeys()
	end)
	buttonBar.CloseButton.Activated:Connect(function()
		self:ToggleLayoutFrame(false)
	end)
	self:_updateLayoutSliders()
end

function GuiModule:_updateLayoutSliders()
	local keySliderFrame = self.MobilePianoGui.LayoutFrame.KeySliderFrame
	keySliderFrame.WhiteKeyWidthSlider.SliderFrame.Head.Position = UDim2.fromScale(
		math.clamp((self._whiteKeyWidth - v4[1][1]) / (v4[1][2] - v4[1][1]), 0, 1),
		0.5
	)
	keySliderFrame.WhiteKeyHeightSlider.SliderFrame.Head.Position = UDim2.fromScale(
		math.clamp((self._whiteKeyHeight - v4[2][1]) / (v4[2][2] - v4[2][1]), 0, 1),
		0.5
	)
	keySliderFrame.BlackKeyWidthSlider.SliderFrame.Head.Position = UDim2.fromScale(
		math.clamp((self._blackKeyWidth - v4[3][1]) / (v4[3][2] - v4[3][1]), 0, 1),
		0.5
	)
	keySliderFrame.BlackKeyHeightSlider.SliderFrame.Head.Position = UDim2.fromScale(
		math.clamp((self._blackKeyHeight - v4[4][1]) / (v4[4][2] - v4[4][1]), 0, 1),
		0.5
	)
end

function GuiModule:AnimateKeyDown(instance, childName)
	local child = instance:FindFirstChild(childName)

	if not child then
		return
	end

	local v13 = (childName - 1) % 12 + 1
	local backgroundColor

	if v13 % 12 == 2 or v13 % 12 == 5 or v13 % 12 == 7 or v13 % 12 == 10 or v13 % 12 == 0 then
		backgroundColor = self.ColorSettings.ActiveBlackKeyColor
	else
		backgroundColor = self.ColorSettings.ActiveWhiteKeyColor
	end

	child.BackgroundColor3 = backgroundColor
end

function GuiModule:AnimateKeyUp(instance, childName)
	local child = instance:FindFirstChild(childName)

	if not child then
		return
	end

	local v13 = (childName - 1) % 12 + 1
	local backgroundColor

	if v13 % 12 == 2 or v13 % 12 == 5 or v13 % 12 == 7 or v13 % 12 == 10 or v13 % 12 == 0 then
		backgroundColor = self.ColorSettings.BlackKeyColor
	else
		backgroundColor = self.ColorSettings.WhiteKeyColor
	end

	child.BackgroundColor3 = backgroundColor
end

function GuiModule:ResetKeys()
	for _, scrollingFrame in ipairs(self.MobilePianoGui.KeyFrame:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		for _, child in ipairs(scrollingFrame:GetChildren()) do
			local name = tonumber(child.Name)

			if not name then
				continue
			end

			local v13 = (name - 1) % 12 + 1
			local backgroundColor

			if v13 % 12 == 2 or v13 % 12 == 5 or v13 % 12 == 7 or v13 % 12 == 10 or v13 % 12 == 0 then
				backgroundColor = self.ColorSettings.BlackKeyColor
			else
				backgroundColor = self.ColorSettings.WhiteKeyColor
			end

			child.BackgroundColor3 = backgroundColor
		end
	end
end

function GuiModule:_resetKeys()
	self._whiteKeyWidth = v[1] / v5
	self._whiteKeyHeight = v[2] / (v6 - GuiModule.MobilePianoGui.TopbarFrame.AbsoluteSize.Y - GuiModule.MobilePianoGui.OctaveFrame.AbsoluteSize.Y)
	self._blackKeyWidth = v[3]
	self._blackKeyHeight = v[4]
	self:_updateKeys(true)
end

function GuiModule:_updateSlideHitboxes(p2, p3, p4)
	for _, scrollingFrame in ipairs(self.MobilePianoGui.KeyFrame:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		for i = 1, 88 do
			local child = scrollingFrame:FindFirstChild(i)

			if not child then
				continue
			end

			local v13 = (i - 1) % 12 + 1

			if not (v13 % 12 ~= 2 and v13 % 12 ~= 5 and v13 % 12 ~= 7 and v13 % 12 ~= 10) then
				continue
			end

			if v13 % 12 == 0 then
				continue
			end

			local child2 = scrollingFrame:FindFirstChild((tostring(i - 1)))
			local child3 = scrollingFrame:FindFirstChild((tostring(i + 1)))
			local slideTop = child:FindFirstChild("SlideTop") or self.MobilePianoGui.HitboxTemplate:Clone()
			local v14 = (i - 1 - 1) % 12 + 1
			local v15 = (v14 % 12 ~= 2 and v14 % 12 ~= 5 and v14 % 12 ~= 7 and v14 % 12 ~= 10 and v14 % 12 ~= 0 or not child2) and 0 or p3 - (child.Position.X.Offset - child2.Position.X.Offset)
			local v16

			if child3 then
				v16 = child3.Position.X.Offset - child.Position.X.Offset - v15
			else
				v16 = v15 + p2
			end

			slideTop.Name = "SlideTop"
			slideTop.Position = UDim2.fromOffset(v15, 0)
			slideTop.Size = UDim2.fromOffset(v16, p4)
			slideTop.Visible = true
			slideTop.Parent = child
			local slideBot = child:FindFirstChild("SlideBot") or self.MobilePianoGui.HitboxTemplate:Clone()
			slideBot.Name = "SlideBot"
			slideBot.AnchorPoint = Vector2.new(0, 1)
			slideBot.Position = UDim2.fromScale(0, 1)
			slideBot.Size = UDim2.new(1, 0, 1, 1 - p4)
			slideBot.Visible = true
			slideBot.Parent = child
		end
	end
end

function GuiModule:_updateKeys(p)
	local v13 = self._whiteKeyWidth * v5
	local v14 = self._whiteKeyHeight / (self.DoubleLayout and 2 or 1) * (v6 - (GuiModule.MobilePianoGui.TopbarFrame.AbsoluteSize.Y + GuiModule.MobilePianoGui.OctaveFrame.AbsoluteSize.Y))
	local v15 = v13 * self._blackKeyWidth
	local v16 = v14 * self._blackKeyHeight

	for _, scrollingFrame in ipairs(self.MobilePianoGui.KeyFrame:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		local v17 = 1
		local count = 0

		for i = 1, 88 do
			local child = scrollingFrame:FindFirstChild(i)

			if not child then
				continue
			end

			local v18 = (i - 1) % 12 + 1

			if v18 % 12 == 2 or v18 % 12 == 5 or v18 % 12 == 7 or v18 % 12 == 10 or v18 % 12 == 0 then
				child.Size = UDim2.new(0, v15, 0, v16)

				if v17 == 1 or v17 == 3 then
					child.Position = UDim2.new(0, count * v13 - 0.4 * v15, 0, 0)
				elseif v17 == 2 or v17 == 4 then
					child.Position = UDim2.new(0, count * v13 - (v15 + 2) + 0.4 * v15, 0, 0)
				elseif v17 == 5 then
					child.Position = UDim2.new(0, count * v13 - (0.5 * v15 + 2), 0, 0)
				end

				child.Name = i
				v17 += 1

				if v17 == 6 then
					v17 = 1
				end
			else
				count += 1
				child.Size = UDim2.new(0, v13, 0, v14)
				child.Position = UDim2.new(0, (count - 1) * v13, 0, 0)
				child.Name = i
			end
		end

		scrollingFrame.CanvasSize = UDim2.new(0, v13 * count, 0, 0)
	end

	if p then
		local v17 = 22.5 * v13 - v5 / 2
		self.MobilePianoGui.KeyFrame.TopKeyFrame.CanvasPosition = Vector2.new(v17, 0)
		self.MobilePianoGui.KeyFrame.BottomKeyFrame.CanvasPosition = Vector2.new(v17, 0)
	end

	self:_updateOctaveFrame(
		self.MobilePianoGui.OctaveFrame.InsetFrame.TopOctaveFrame,
		self.MobilePianoGui.KeyFrame.TopKeyFrame
	)
	self:_updateOctaveFrame(
		self.MobilePianoGui.OctaveFrame.InsetFrame.BottomOctaveFrame,
		self.MobilePianoGui.KeyFrame.BottomKeyFrame
	)
	self:_updateSlideHitboxes(v13, v15, v16)
end

function GuiModule:_updateSoundFontLabel()
	self.MobilePianoGui.SoundFontLabel.Text = v9[pianoController.SoundFont].Name
end

function GuiModule:_updateVolumeFrame()
	local v13 = (pianoController.Volume - v8.MIN_VOLUME) / (v8.MAX_VOLUME - v8.MIN_VOLUME)
	self.MobilePianoGui.VolumeHead.Position = UDim2.fromScale(math.clamp(v13, 0, 1), 0.5)
end

function GuiModule:_connectVolumeFrame()
	local volumeFrame = self.MobilePianoGui.VolumeFrame
	local _ = pianoController.Volume
	return { "volume", volumeFrame.MouseButton1Down:Connect(function()
			self._sliderDown = "volume"
		end), volumeFrame.MouseMoved:Connect(function(p, _)
			if self._sliderDown ~= "volume" then
				return
			end

			local v13 = (p - volumeFrame.AbsolutePosition.X) / volumeFrame.AbsoluteSize.X
			pianoController:ChangeVolume(
				math.clamp(v8.MIN_VOLUME + (v8.MAX_VOLUME - v8.MIN_VOLUME) * v13, 0.1, 2),
				true
			)
		end) }
end

function GuiModule:_updateOctaveFrame(p2, data)
	local head = p2.Head
	head.Size = UDim2.new(1 / self._whiteKeyWidth / 52, 0, 1, -2)
	local v13 = data.CanvasPosition.X / (data.AbsoluteCanvasSize.X - data.AbsoluteWindowSize.X)
	head.Position = UDim2.new(math.clamp(v13 * (1 - head.Size.X.Scale), 0, 1 - head.Size.X.Scale), 0, 0.5, 0)
end

function GuiModule:_connectOctaveFrame(sliderDown, state)
	local head = sliderDown.Head
	return { "octave", sliderDown.MouseButton1Down:Connect(function()
			self._sliderDown = sliderDown
		end), sliderDown.MouseMoved:Connect(function(p2, _)
			if self._sliderDown ~= sliderDown then
				return
			end

			local v13 = (p2 - sliderDown.AbsolutePosition.X) / sliderDown.AbsoluteSize.X
			state.CanvasPosition = Vector2.new((math.clamp(
				(v13 - head.Size.X.Scale / 2) * state.AbsoluteCanvasSize.X,
				0,
				state.AbsoluteCanvasSize.X - state.AbsoluteWindowSize.X
			)))
		end) }
end

function GuiModule:ConnectPianoController()
	if self:IsConnected() then
		warn("[MobilePianoGui]: Found preexisting PianoController connections, disconnecting")
		self:DisconnectPianoController()
	end

	local connections = {
		self.MobilePianoGui.SoundFontButton.Activated:Connect(function()
			v7:ToggleEnabled()
		end),
		self:_connectVolumeFrame(),
		self.MobilePianoGui.SustainButton.Activated:Connect(function()
			pianoController:ToggleSustain()
		end),
		self.MobilePianoGui.LayoutButton.Activated:Connect(function()
			self:ToggleLayoutFrame()
		end),
		self.MobilePianoGui.LCDFrame.Activated:Connect(function()
			self:ToggleMinimized()
		end),
		self.MobilePianoGui.ExitButton.Activated:Connect(function()
			pianoController:Deactivate()
		end),
		self:_connectOctaveFrame(
			self.MobilePianoGui.OctaveFrame.InsetFrame.TopOctaveFrame,
			self.MobilePianoGui.KeyFrame.TopKeyFrame
		),
		self:_connectOctaveFrame(
			self.MobilePianoGui.OctaveFrame.InsetFrame.BottomOctaveFrame,
			self.MobilePianoGui.KeyFrame.BottomKeyFrame
		),
		self.MobilePianoGui.KeyFrame.TopKeyFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:_updateOctaveFrame(
				self.MobilePianoGui.OctaveFrame.InsetFrame.TopOctaveFrame,
				self.MobilePianoGui.KeyFrame.TopKeyFrame
			)
		end),
		self.MobilePianoGui.KeyFrame.BottomKeyFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			self:_updateOctaveFrame(
				self.MobilePianoGui.OctaveFrame.InsetFrame.BottomOctaveFrame,
				self.MobilePianoGui.KeyFrame.BottomKeyFrame
			)
		end),
		pianoController.KeyPressed:Connect(function(value)
			if type(value) ~= "string" then
				return
			end

			local v14 = string.sub(value, 1, 1)

			if v14 ~= "t" and v14 ~= "b" then
				return
			end

			local v15 = tonumber((string.sub(value, 2)))

			if not v15 then
				return
			end

			if v14 == "t" then
				self:AnimateKeyDown(self.MobilePianoGui.KeyFrame.TopKeyFrame, v15)
			elseif v14 == "b" then
				self:AnimateKeyDown(self.MobilePianoGui.KeyFrame.BottomKeyFrame, v15)
			end
		end),
		self.MobilePianoGui.TranspositionFrame.TranspositionUp.Activated:Connect(function()
			pianoController:ChangeTransposition(1)
		end),
		self.MobilePianoGui.TranspositionFrame.TranspositionDown.Activated:Connect(function()
			pianoController:ChangeTransposition(-1)
		end),
		pianoController.KeyReleased:Connect(function(value)
			if type(value) ~= "string" then
				return
			end

			local v14 = string.sub(value, 1, 1)

			if v14 ~= "t" and v14 ~= "b" then
				return
			end

			local v15 = tonumber((string.sub(value, 2)))

			if not v15 then
				return
			end

			if v14 == "t" then
				self:AnimateKeyUp(self.MobilePianoGui.KeyFrame.TopKeyFrame, v15)
			elseif v14 == "b" then
				self:AnimateKeyUp(self.MobilePianoGui.KeyFrame.BottomKeyFrame, v15)
			end
		end),
		pianoController.SustainChanged:Connect(function(p, _)
			local icon = self.MobilePianoGui.SustainButton.Icon
			local imageColor

			if p then
				imageColor = self.ColorSettings.ActiveButtonColor
			else
				imageColor = self.ColorSettings.InactiveButtonColor
			end

			icon.ImageColor3 = imageColor
		end),
		(pianoController.TranspositionChanged:Connect(function(text)
			self.MobilePianoGui.TranspositionFrame.TranspositionLabel.Text = text
		end))
	}
	local soundFontChangedConnection = pianoController.SoundFontChanged:Connect(function()
		self:_updateSoundFontLabel()
	end)
	local volumeChangedConnection = pianoController.VolumeChanged:Connect(function()
		self:_updateVolumeFrame()
	end)
	local activatedConnection = pianoController.Activated:Connect(function()
		self:ResetKeys()
		self:ToggleEnabled(true)
	end)
	local deactivatedConnection = pianoController.Deactivated:Connect(function()
		self:ToggleEnabled(false)
		self:ResetKeys()
	end)
	local UserInputService = game:GetService("UserInputService")
	local touchEndedConnection = UserInputService.TouchEnded:Connect(function(_, p)
		if p or not self:IsConnected() or self._holding == nil then
			return
		end

		self._holding = nil
	end)
	local UserInputService2 = game:GetService("UserInputService")
	do local _values = table.pack(soundFontChangedConnection, volumeChangedConnection, activatedConnection, deactivatedConnection, touchEndedConnection, UserInputService2.InputEnded:Connect(function(input, _)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch and self._sliderDown then
		self._sliderDown = nil
	end
end)); for _k = 1, _values.n do connections[16 + _k] = _values[_k] end end
	self._connections = connections

	for _, child in ipairs(self.MobilePianoGui.KeyFrame.TopKeyFrame:GetChildren()) do
		local name = tonumber(child.Name)

		if name then
			local v14 = false
			local v15 = name

			local function HoverKey()
				if not self._glissando or (not pianoController.Active or v14 == true) or self.MobilePianoGui.LayoutFrame.Visible == true then
					return
				end

				v14 = true
				pianoController:PressClientKey("t" .. v15, v15 - 15)
			end

			local v16 = name

			local function ReleaseKey()
				if not self.MobilePianoGui.KeyFrame.TopKeyFrame.Visible or (not pianoController.Active or v14 == false) then
					return
				end

				v14 = false
				pianoController:ReleaseClientKey("t" .. v16)
			end

			local v17 = (name - 1) % 12 + 1

			if v17 % 12 == 2 or v17 % 12 == 5 or v17 % 12 == 7 or v17 % 12 == 10 or v17 % 12 == 0 then
				table.insert(self._connections, child.MouseEnter:Connect(HoverKey))
			else
				local slideTop = child:FindFirstChild("SlideTop")
				local slideBot = child:FindFirstChild("SlideBot")
				table.insert(self._connections, slideTop.MouseEnter:Connect(HoverKey))
				table.insert(self._connections, slideBot.MouseEnter:Connect(HoverKey))
			end

			local v18 = name
			table.insert(self._connections, child.MouseButton1Down:Connect(function()
				if self._glissando or (not pianoController.Active or v14 == true) then
					return
				end

				v14 = true
				pianoController:PressClientKey("t" .. v18, v18 - 15)
			end))
			table.insert(self._connections, child.MouseButton1Up:Connect(ReleaseKey))
			table.insert(self._connections, child.MouseLeave:Connect(ReleaseKey))
		else
			warn("[MobilePianoGui]: Could not get note from key: " .. child.Name)
		end
	end

	for _, child in ipairs(self.MobilePianoGui.KeyFrame.BottomKeyFrame:GetChildren()) do
		local name = tonumber(child.Name)

		if name then
			local v14 = false
			local v15 = name

			local function HoverKey()
				if not self._glissando or (not pianoController.Active or v14 == true) or self.MobilePianoGui.LayoutFrame.Visible == true then
					return
				end

				v14 = true
				pianoController:PressClientKey("b" .. v15, v15 - 15)
			end

			local v16 = name

			local function ReleaseKey()
				if not self.MobilePianoGui.KeyFrame.BottomKeyFrame.Visible or (not pianoController.Active or v14 == false) then
					return
				end

				v14 = false
				pianoController:ReleaseClientKey("b" .. v16)
			end

			local v17 = (name - 1) % 12 + 1

			if v17 % 12 == 2 or v17 % 12 == 5 or v17 % 12 == 7 or v17 % 12 == 10 or v17 % 12 == 0 then
				table.insert(self._connections, child.MouseEnter:Connect(HoverKey))
			else
				local slideTop = child:FindFirstChild("SlideTop")
				local slideBot = child:FindFirstChild("SlideBot")
				table.insert(self._connections, slideTop.MouseEnter:Connect(HoverKey))
				table.insert(self._connections, slideBot.MouseEnter:Connect(HoverKey))
			end

			local v18 = name
			table.insert(self._connections, child.MouseButton1Down:Connect(function()
				if self._glissando or (not pianoController.Active or v14 == true) then
					return
				end

				v14 = true
				pianoController:PressClientKey("b" .. v18, v18 - 15)
			end))
			table.insert(self._connections, child.MouseButton1Up:Connect(ReleaseKey))
			table.insert(self._connections, child.MouseLeave:Connect(ReleaseKey))
		else
			warn("[MobilePianoGui]: Could not get note from key: " .. child.Name)
		end
	end

	self:_updateSoundFontLabel()
	self:_updateVolumeFrame()
end

function GuiModule:DisconnectPianoController()
	for _, _connection in self._connections do
		if type(_connection) == "table" and not _connection.Disconnect then
			for _, connection in _connection do
				if type(connection) ~= "string" then
					connection:Disconnect()
				end
			end
		else
			_connection:Disconnect()
		end
	end

	table.clear(self._connections)
end

function GuiModule:IsConnected()
	return #self._connections > 0
end

function GuiModule.Init(_)
	pianoController = script.Parent.Parent:WaitForChild("PianoController")
	local DefaultSettings = require(pianoController.DefaultSettings)
	v8 = DefaultSettings
	local SoundFonts = require(pianoController.SoundFonts)
	v9 = SoundFonts
	local Tween = require(pianoController.Tween)
	v10 = Tween
	local module = require(pianoController)
	pianoController = module
end

function GuiModule:Start()
	local GuiModule2 = require(script.Parent.Parent:WaitForChild("SoundFontGui"):WaitForChild("GuiModule"))
	v7 = GuiModule2
	local hardwareHorizontalInset = getHardwareHorizontalInset()
	self.MobilePianoGui.MainFrame.Size = UDim2.new(1, hardwareHorizontalInset, 0, 0)
	self.MobilePianoGui.TopbarInsetFrame.Size = UDim2.new(1, -hardwareHorizontalInset, 1, 0)
	self.MobilePianoGui.OctaveInsetFrame.Size = UDim2.new(1, -hardwareHorizontalInset, 1, 0)
	self:ToggleEnabled(false, true)
	self:ToggleMinimized(false, true)
	self:ToggleDoubleLayout(false, true)
	self:ToggleLayoutFrame(false)
	self:_initializeLayoutFrame()
	self:_updateSoundFontLabel()
	self:_updateVolumeFrame()
	self:_updateKeys(true)
	pianoController.DeviceChanged:Connect(function(p)
		if p == "Mobile" then
			if GuiModule:IsConnected() then
				return
			else
				GuiModule:ConnectPianoController()
			end
		elseif p == "Desktop" then
			if not GuiModule:IsConnected() then
				return
			end

			GuiModule:DisconnectPianoController()
		end

		if pianoController.Active then
			self:ToggleEnabled(p == "Mobile", true)
		end
	end)
	self.MobilePianoGui.SlideButton.Activated:Connect(function()
		self._glissando = not self._glissando
		local icon = self.MobilePianoGui.SlideButton.Icon
		local textColor

		if self._glissando then
			textColor = self.ColorSettings.ActiveButtonColor
		else
			textColor = self.ColorSettings.InactiveButtonColor
		end

		icon.TextColor3 = textColor
	end)
end

return GuiModule