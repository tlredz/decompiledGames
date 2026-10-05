local LineCastBar = {
	__components = nil,
	__loadOrder = 0,
	__maid = nil,
	__state = nil,
	Gui = nil,
	Bar = nil,
	CastStrength = 0,
	state = nil
}
LineCastBar.__index = LineCastBar
local _ = {
	Perfect = 4,
	Great = 3,
	Nice = 2,
	Normal = 1
}

-- equivalent calls inferred from this helper; original call sites unknown
local function getColorFromValue(castStrength)
	local v = math.clamp(castStrength, 0, 100)

	if v <= 50 then
		local v2 = v / 50
		return (Color3.new(1, v2, 0))
	end

	local v2 = 1 - (v - 50) / 50
	return (Color3.new(v2, 1, 0))
end

function LineCastBar:StartCasting()
	self.__components:Get("RodController"):StartCasting()
	self.CastAction = {}
	self.CastStrength = 0
	self.Sign = 1
	local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	local _ = game.Players.LocalPlayer.Character.Humanoid
	local v = 60 + math.random(-10, 10)
	local __maid = self.__maid
	local RunService = game:GetService("RunService")
	__maid.UpdateBar = RunService.Heartbeat:Connect(function(dt)
		if not self.Modal then
			self.__maid.UpdateBar = nil
			return
		end

		local v2 = self.Sign * dt * v * (math.max(0, self.CastStrength - 50) / 20 + 2)
		self.CastStrength = math.clamp(self.CastStrength + v2, 0, 100)

		if self.CastStrength == 100 then
			self.Sign = -1
			v = 60 + math.random(-10, 10)
		elseif self.CastStrength == 0 then
			self.Sign = 1
			v = 60 + math.random(-10, 10)
		end

		local barFill = self.BarFill
		local colorFromValue = getColorFromValue(self.CastStrength) -- equivalent call inferred; original call site unknown
		barFill.BackgroundColor3 = colorFromValue
		self:UpdateBarHeight(self.CastStrength)
	end)
	local __maid2 = self.__maid
	local RunService2 = game:GetService("RunService")
	__maid2.UpdateModal = RunService2.RenderStepped:Connect(function(_)
		local modal = self.Modal

		if not modal then
			self.__maid.UpdateModal = nil
			return
		end

		local cFrame = workspace.CurrentCamera.CFrame
		local dot = (humanoidRootPart.Position - cFrame.Position):Dot(cFrame.LookVector)

		if dot - 6 < 3 then
			modal.CFrame = cFrame + cFrame.LookVector * 7.5 + cFrame.RightVector * -8 + cFrame.UpVector * -1
		else
			modal.CFrame = cFrame.Rotation + humanoidRootPart.Position + cFrame.RightVector * -3 + cFrame.LookVector * (-dot / 5)
		end
	end)
	self:Show()
end

function LineCastBar:CancelCasting()
	self.__components:Get("RodController"):CancelCasting()
	self.__maid.UpdateBar = nil
	self.__maid.UpdateModal = nil
	self:Hide()
end

function LineCastBar:GetQuality()
	if self.CastStrength >= 98 then
		return 4, "PERFECT!"
	end

	if self.CastStrength >= 75 then
		return 1, ""
	end

	if self.CastStrength >= 50 then
	end

	return 1, ""
end

function LineCastBar:FinishCasting()
	self.__components:Get("RodController"):ReleaseCasting()
	self.__maid.UpdateBar = nil
	self:DisplayResult()
	local castAction = self.CastAction
	task.delay(4, function()
		if castAction == self.CastAction then
			self.__maid.UpdateModal = nil
			self:Hide()
		end
	end)
end

function LineCastBar:DisplayResult()
	local feedback = self.Feedback
	local bar = self.Bar
	local frame = bar.Frame
	local quality, text = self:GetQuality()

	if quality == 1 then
		task.delay(1.25, function()
			bar.Visible = false
		end)
		return
	end

	feedback.TextLabel.Text = text
	local textLabel = feedback.TextLabel
	local brush = feedback.Brush
	textLabel.Visible = true
	brush.Visible = true
	self.__maid.PerfectCastDisplay = task.spawn(function()
		local WAIT_INTERVAL = 0.016666666666666666
		local lastTime = tick()

		while tick() - lastTime < 1.25 do
			task.wait(WAIT_INTERVAL)
			feedback.TextLabel.Position = UDim2.new(
				feedback.TextLabel.Position.X.Scale,
				0,
				feedback.TextLabel.Position.Y.Scale - 0.0033333333333333335,
				0
			)
			feedback.Brush.Position = UDim2.new(
				feedback.Brush.Position.X.Scale,
				0,
				feedback.Brush.Position.Y.Scale - 0.0033333333333333335,
				0
			)
		end

		bar.Visible = false
		local lastTime2 = tick()

		while tick() - lastTime2 < 0.25 do
			task.wait(WAIT_INTERVAL)
			feedback.TextLabel.Position = UDim2.new(
				feedback.TextLabel.Position.X.Scale,
				0,
				feedback.TextLabel.Position.Y.Scale - 0.0033333333333333335,
				0
			)
			feedback.Brush.Position = UDim2.new(
				feedback.Brush.Position.X.Scale,
				0,
				feedback.Brush.Position.Y.Scale - 0.0033333333333333335,
				0
			)
		end

		for _ = 1, 10 do
			task.wait(WAIT_INTERVAL)
			feedback.TextLabel.Position = UDim2.new(
				feedback.TextLabel.Position.X.Scale,
				0,
				feedback.TextLabel.Position.Y.Scale - 0.0033333333333333335,
				0
			)
			feedback.Brush.Position = UDim2.new(
				feedback.Brush.Position.X.Scale,
				0,
				feedback.Brush.Position.Y.Scale - 0.0033333333333333335,
				0
			)
			feedback.Brush.BackgroundTransparency += 0.1
			feedback.Brush.ImageTransparency += 0.1
			feedback.TextLabel.TextTransparency += 0.1
			feedback.TextLabel.UIStroke.Transparency += 0.1
			bar.BackgroundTransparency += 0.1
			frame.BackgroundTransparency += 0.1
			bar.ImageTransparency += 0.1
		end

		feedback.Brush.Visible = false
		feedback.TextLabel.Visible = false
	end)
end

function LineCastBar:Hide()
	if self.Modal then
		self.Modal:Destroy()
		self.Modal = nil
		self.Gui = nil
		self.Bar = nil
		self.BarFill = nil
	end
end

function LineCastBar:Show()
	self:Hide()

	if not self.Modal then
		self.Modal = script["Fishing_Cast Meter"]:Clone()
		local modal = self.Modal
		self.__maid:GiveTask(modal)
		self.Modal.Parent = game.Players.LocalPlayer.Character
		self.Modal.Anchored = true
		self.Gui = self.Modal.CastMeter
		self.Bar = self.Gui.Bar
		self.BarFill = self.Bar.Frame
		self.Feedback = self.Modal.Feedback
		self.Feedback.Brush.Visible = false
		self.Feedback.TextLabel.Visible = false
	end
end

function LineCastBar:UpdateBarHeight(p2: number)
	if self.Gui then
		self.BarFill.Size = UDim2.new(0.775, 0, math.min(p2 / 100, 0.98), 0)
		self.BarFill.Position = UDim2.new(0.5, 0, 0.99, 0)
	end
end

function LineCastBar.Construct(p)
	return (setmetatable(p, LineCastBar))
end

function LineCastBar.Setup() end

return LineCastBar