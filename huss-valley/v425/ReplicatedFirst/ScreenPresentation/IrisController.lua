local TweenService = game:GetService("TweenService")
local IrisController = {}
IrisController.__index = IrisController

function IrisController.new(gui, config)
	local object = setmetatable({
		gui = gui,
		config = config,
		sequence = 0
	}, IrisController)
	object.value = Instance.new("NumberValue")
	object.value.Value = 0
	object.panels = {}

	for _, frame in gui.Mask:GetChildren() do
		if frame:IsA("Frame") then
			table.insert(object.panels, frame)
		end
	end

	object.changed = object.value.Changed:Connect(function()
		object:draw()
	end)
	object.resized = gui.Mask:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		object:draw()
	end)
	object:draw()
	return object
end

function IrisController:draw()
	local absoluteSize = self.gui.Mask.AbsoluteSize
	local v = math.max(absoluteSize.Magnitude, 1)
	local v2 = self.value.Value * v * 0.53

	for _, panel in self.panels do
		local angle = panel:GetAttribute("Angle")
		panel.Size = UDim2.fromOffset(v * 2, v * 2)
		panel.Position = UDim2.fromOffset(
			absoluteSize.X * 0.5 + math.cos(angle) * (v2 + v),
			absoluteSize.Y * 0.5 + math.sin(angle) * (v2 + v)
		)
	end

	self.gui.Blackout.Visible = self.value.Value <= 0.001
end

function IrisController:animate(p)
	self.sequence += 1
	local sequence = self.sequence

	if self.tween then
		self.tween:Cancel()
	end

	self.gui.Enabled = true
	self.gui.InputBlocker.Visible = true
	self.gui.Mask.Visible = true

	local function step(p2, duration, p3, p4)
		self.tween = TweenService:Create(self.value, TweenInfo.new(duration, p3, p4), {
			Value = p2
		})
		local tween = self.tween
		local v = false
		local completedConnection = tween.Completed:Connect(function()
			v = true
		end)
		tween:Play()
		local v2 = os.clock() + duration + 1

		while sequence == self.sequence and not v and os.clock() < v2 do
			task.wait()
		end

		completedConnection:Disconnect()

		if sequence == self.sequence then
			if not v then
				tween:Cancel()
			end

			self.value.Value = p2
		end

		return sequence == self.sequence
	end

	if p then
		if not step(0.55, self.config.OpenTime * 0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out) then
			return false
		end

		if not step(1, self.config.OpenTime * 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) then
			return false
		end
	elseif not step(0, self.config.CloseTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In) then
		return false
	end

	if not p then
		return true
	end

	self.gui.Mask.Visible = false
	self.gui.Blackout.Visible = false
	self.gui.InputBlocker.Visible = false
	self.gui.Enabled = false
	return true
end

function IrisController:forceOpen()
	self.sequence += 1

	if self.tween then
		self.tween:Cancel()
	end

	self.value.Value = 1
	self.gui.Enabled = false
	self.gui.Mask.Visible = false
	self.gui.Blackout.Visible = false
	self.gui.InputBlocker.Visible = false
end

function IrisController:destroy()
	self:forceOpen()
	self.changed:Disconnect()
	self.resized:Disconnect()
	self.value:Destroy()
	self.gui:Destroy()
end

return IrisController