local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(84, 84, 84)
local color3 = Color3.fromRGB(255, 192, 64)
local UserInputService = game:GetService("UserInputService")
local pianoController = nil
local v = nil
local parent = script.Parent
local GuiModule = {}
GuiModule.Enabled = false
GuiModule._activeSoundFontButton = nil
GuiModule._soundFontButtons = nil
GuiModule.SoundFontGui = {
	Gui = parent,
	MainFrame = parent.MainFrame,
	TitleLabel = parent.MainFrame.TitleLabel,
	CloseButton = parent.MainFrame.CloseButton,
	BodyFrame = parent.MainFrame.BodyFrame,
	SoundFontFrame = parent.MainFrame.BodyFrame.SoundFontFrame,
	ListFrame = parent.MainFrame.BodyFrame.SoundFontFrame.ListFrame,
	ListLayout = parent.MainFrame.BodyFrame.SoundFontFrame.ListFrame.UIListLayout,
	ListPadding = parent.MainFrame.BodyFrame.SoundFontFrame.ListFrame.UIPadding,
	SoundFontTemplate = parent.MainFrame.BodyFrame.SoundFontFrame.ListFrame.SoundFontTemplate
}

function GuiModule:ToggleEnabled(enabled, p)
	if not p and type(enabled) == "boolean" and enabled == self.Enabled then
		return
	end

	if enabled == nil then
		enabled = not self.Enabled
	end

	self.Enabled = enabled
	self.SoundFontGui.Gui.Enabled = self.Enabled
end

function GuiModule:_initializeGuiButtons()
	local clones = {}

	for i, v2 in ipairs(v) do
		if v2 == false then
			continue
		end

		local name = v2.Name
		local _ = v2.Category
		local _ = v2.Uploader or "???"
		local clone = self.SoundFontGui.SoundFontTemplate:Clone()
		local nameLabel = clone:WaitForChild("NameLabel")
		nameLabel.Text = name
		clone.Name = name
		local v3 = i
		clone.Activated:Connect(function()
			pianoController:ChangeSoundFont(v3)
		end)
		self.SoundFontGui.SoundFontTemplate.Visible = false
		clone.Visible = true
		clone.Parent = self.SoundFontGui.ListFrame
		clones[i] = clone

		if not v2.Highlight then
			continue
		end

		local textColor

		if typeof(v2.Highlight) == "Color3" then
			textColor = v2.Highlight
		else
			textColor = color3
		end

		nameLabel.TextColor3 = textColor
	end

	self._soundFontButtons = clones
end

function GuiModule:_updateSoundFontCanvasSize()
	local listFrame = self.SoundFontGui.ListFrame
	listFrame.CanvasSize = UDim2.fromOffset(0, self.SoundFontGui.ListLayout.AbsoluteContentSize.Y)
	self.SoundFontGui.ListPadding.PaddingRight = UDim.new(
		0,
		listFrame.AbsoluteCanvasSize.Y > listFrame.AbsoluteSize.Y and 7 or 0
	)
end

function GuiModule:_setActiveSoundFontButton(p)
	if self._activeSoundFontButton then
		self._activeSoundFontButton.BorderColor3 = color2
	end

	self._activeSoundFontButton = self._soundFontButtons[p]
	self._activeSoundFontButton.BorderColor3 = color
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

function GuiModule:Init()
	pianoController = script.Parent.Parent:WaitForChild("PianoController")
	local SoundFonts = require(pianoController.SoundFonts)
	v = SoundFonts
	local module = require(pianoController)
	pianoController = module
	self:ToggleEnabled(false, true)
end

function GuiModule:Start()
	self.SoundFontGui.MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Enabled then
			self:DragFrame(self.SoundFontGui.MainFrame, input)
		end
	end)
	self.SoundFontGui.CloseButton.Activated:Connect(function()
		self:ToggleEnabled(false, true)
	end)
	self:_initializeGuiButtons()
	pianoController.SoundFontChanged:Connect(function(p)
		self:_setActiveSoundFontButton(p)
	end)
	pianoController.Deactivated:Connect(function()
		self:ToggleEnabled(false, true)
	end)
	self:_setActiveSoundFontButton(pianoController.SoundFont)
	self.SoundFontGui.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_updateSoundFontCanvasSize()
	end)
end

return GuiModule