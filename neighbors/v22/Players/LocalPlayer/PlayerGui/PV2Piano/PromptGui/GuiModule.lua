local pianoController = nil
local v = nil
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint)
local parent = script.Parent
local GuiModule = {}
GuiModule._tweenTimestamp = nil
GuiModule.PromptGui = {
	Gui = parent,
	MainFrame = parent.MainFrame,
	MobileButton = parent.MainFrame.MobileButton,
	MobileConfirm = parent.MainFrame.MobileButton.ConfirmFrame,
	DesktopButton = parent.MainFrame.DesktopButton,
	DesktopConfirm = parent.MainFrame.DesktopButton.ConfirmFrame
}

function GuiModule:ToggleEnabled(enabled, p)
	if not p and type(enabled) == "boolean" and enabled == self.Enabled then
		return
	end

	if enabled == nil then
		enabled = not self.Enabled
	end

	self.Enabled = enabled
	local now = os.clock()
	self._tweenTimestamp = now

	if p then
		self.PromptGui.MainFrame.Position = self.Enabled and UDim2.new(0.5, 0, 0.6, 0) or UDim2.new(0.5, 0, 1.5, 0)
	end

	if self.Enabled then
		self.PromptGui.Gui.Enabled = self.Enabled
		v:Play(self.PromptGui.MainFrame, tweenInfo, {
			Position = UDim2.new(0.5, 0, 0.6, 0)
		})
	else
		v:Play(self.PromptGui.MainFrame, tweenInfo, {
			Position = UDim2.new(0.5, 0, 1.5, 0)
		})
		task.delay(0.4, function()
			if self._tweenTimestamp == now then
				self.PromptGui.Gui.Enabled = self.Enabled
				self.PromptGui.DesktopConfirm.Visible = false
				self.PromptGui.MobileConfirm.Visible = false
			end
		end)
	end
end

function GuiModule:Init()
	pianoController = script.Parent.Parent:WaitForChild("PianoController")
	local Tween = require(pianoController.Tween)
	v = Tween
	local module = require(pianoController)
	pianoController = module
	self.PromptGui.MainFrame.Position = UDim2.new(0.5, 0, 1.5, 0)
	self:ToggleEnabled(false, true)
end

function GuiModule:Start()
	self.PromptGui.DesktopButton.Activated:Connect(function()
		if self.PromptGui.DesktopConfirm.Visible then
			pianoController:ChangeDevice("Desktop")
			self:ToggleEnabled(false)
		else
			self.PromptGui.DesktopConfirm.Visible = true
			self.PromptGui.MobileConfirm.Visible = false
		end
	end)
	self.PromptGui.MobileButton.Activated:Connect(function()
		if self.PromptGui.MobileConfirm.Visible then
			pianoController:ChangeDevice("Mobile")
			self:ToggleEnabled(false)
		else
			self.PromptGui.MobileConfirm.Visible = true
			self.PromptGui.DesktopConfirm.Visible = false
		end
	end)
end

return GuiModule