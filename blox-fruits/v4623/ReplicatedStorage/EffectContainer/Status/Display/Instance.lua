local currentCamera = workspace.CurrentCamera
local Settings = require(script.Settings)
local Instance = {
	Frame = script:FindFirstChild("Frame"),
	Queue = {}
}
local Players = game:GetService("Players")
Instance.Settings = {
	Parent = Players.LocalPlayer.PlayerGui:WaitForChild("Gui", 10),
	TextSize = 50,
	ViewDistance = 75,
	TextAnimation = {
		FadeIn = {
			Revolutions = 2,
			Offset = {
				X = 3,
				Y = 2
			},
			SpinDuration = 0.5,
			Duration = 0.25
		},
		FreezeDuration = 0.1,
		FadeOut = {
			Duration = 0.25
		}
	}
}
Instance.Methods = {}
Instance.Methods.__index = Instance.Methods

function Instance.Methods:GetIndex()
	if self.Destroyed then
		return
	end

	for k, v2 in next, Instance.Queue, nil do
		if v2 == self then
			return k
		end
	end
end

function Instance.Methods:Destroy()
	table.remove(Instance.Queue, self:GetIndex())
	self.Frame:Destroy()
	setmetatable(self, nil)
end

function Instance.Methods:Play()
	if self.Played then
		return
	end

	for k, v2 in next, { self.Frame.Type, self.Frame.Shadow }, nil do
		v2.Text = self.Data.Text

		if k == 1 then
			v2.TextColor3 = self.Data.TextColor
		end
	end

	self.Frame.Parent = Instance.Settings.Parent
	self.Start = tick()
	table.insert(Instance.Queue, self)
	self.Played = true
end

function Instance.Methods:Stop()
	self.Stopped = true
end

function Instance.Methods:Update()
	local now = tick()
	local frame = self.Frame
	local _ = self.Data
	local v2 = now - self.Start
	local v3 = math.max(
		Instance.Settings.TextAnimation.FadeIn.SpinDuration,
		Instance.Settings.TextAnimation.FadeIn.Duration
	)
	local freezeDuration = Instance.Settings.TextAnimation.FreezeDuration
	local v4 = math.max(Instance.Settings.TextAnimation.FadeOut.Duration)

	if v3 + freezeDuration + v4 < v2 then
		self:Destroy()
		return
	end

	local _CFrame = self._CFrame or CFrame.new()

	if not self._CFrame then
		local typeName = typeof(self.Anchor)

		if typeName == "Instance" then
			_CFrame = self.Anchor.CFrame
		elseif typeName == "CFrame" then
			_CFrame = self.Anchor
			self._CFrame = _CFrame
		elseif typeName == "Vector3" then
			_CFrame = CFrame.new(self.Anchor)
			self._CFrame = _CFrame
		end
	end

	local magnitude = (currentCamera.CFrame.p - _CFrame.p).magnitude

	if self.UpdateOnce and Instance.Settings.ViewDistance < magnitude then
		return
	end

	self.UpdateOnce = true
	local vector = Vector3.new()
	local v5 = _CFrame * CFrame.new(0, (#Instance.Queue - 1) * 2 + 3, 0)
	local textSize = Instance.Settings.TextSize

	if v3 + freezeDuration < v2 then
		local textTransparency = math.min(1, (v2 - (v3 + freezeDuration)) / v4)
		textSize = Instance.Settings.TextSize * (1 - textTransparency)

		for _, v7 in next, { frame.Type, frame.Shadow }, nil do
			v7.TextTransparency = textTransparency
			v7.TextSize = textSize
		end
	elseif v3 < v2 then
		math.min(1, (v2 - v3) / freezeDuration)
	else
		local v6 = math.min(1, v2 / Instance.Settings.TextAnimation.FadeIn.Duration)
		local v7 = math.min(1, v2 / Instance.Settings.TextAnimation.FadeIn.SpinDuration)

		for _, v8 in next, { frame.Type, frame.Shadow }, nil do
			v8.TextTransparency = 1 - v6
		end

		local v8 = math.sin(Instance.Settings.TextAnimation.FadeIn.Revolutions * -3.141592653589793 * 2 * v7)
		local v9 = math.cos(Instance.Settings.TextAnimation.FadeIn.Revolutions * -3.141592653589793 * 2 * v7)
		vector = Vector3.new(
			Instance.Settings.TextAnimation.FadeIn.Offset.X * (1 - v7) * v8,
			Instance.Settings.TextAnimation.FadeIn.Offset.Y * (1 - v7) * v9,
			0
		)
	end

	local worldToScreenPoint, visible = currentCamera:WorldToScreenPoint(v5 * vector)
	frame.Visible = visible
	local v7 = math.clamp(1 - magnitude / Instance.Settings.ViewDistance, 0, 1)
	frame.Position = UDim2.new(
		0,
		worldToScreenPoint.X - frame.Size.X.Offset / 2,
		0,
		worldToScreenPoint.Y - frame.Size.Y.Offset / 2
	)

	for _, v8 in next, { frame.Type, frame.Shadow }, nil do
		v8.TextSize = textSize * v7
	end

	frame.Shadow.Position = UDim2.new(v7 * 0.015, 0, v7 * 0.015, 0)
end

function Instance.new(p)
	return (setmetatable({
		Frame = Instance.Frame:Clone(),
		Data = Settings[p] or {},
		Anchor = CFrame.new()
	}, Instance.Methods))
end

local RunService = game:GetService("RunService")
RunService:BindToRenderStep("StatusDisplay", 10032, function()
	for _, v2 in next, Instance.Queue, nil do
		v2:Update()
	end
end)
return Instance