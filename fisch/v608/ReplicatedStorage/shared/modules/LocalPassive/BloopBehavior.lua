local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local BloopBehavior = {}
BloopBehavior.__index = BloopBehavior
BloopBehavior.MorphSpear = true

function BloopBehavior:Morph(_, object2)
	self.lastProgress = 0
	self._chargeVel = 0
	self.currentCharge = 100
	self.displayCharge = 100
	self.targetCharge = 100
	self.currentScale = 1
	self.bloopBar = nil
	self.bloopChargeBar = nil
	self.lastExtremeEvent = 0
	self.isExtremeActive = false
	self.recentProgressChanges = {}
	self.progressHistorySize = 10
	self.bloopBarResizer = object2:CreateModifier("barSize", "multiply")
	self.bloopProgressDrainer = object2:CreateModifier("progress", "add")
	self:CreateBloopBar()
	self.reelTrove:Add(object2.OnLogicStep:Connect(function(p)
		self:SmoothUpdate(p)
	end))
	object2.OnFishMove:Connect(function()
		self:Update()
	end)
end

function BloopBehavior:CreateBloopBar()
	local frame = Instance.new("Frame")
	frame.Name = "BloopChargeBar"
	frame.Size = UDim2.new(1, 0, 0.1, 6)
	frame.Position = UDim2.new(0, 0, 1.05, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 1
	frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
	frame.Visible = true
	frame.ZIndex = 5
	local frame2 = Instance.new("Frame")
	frame2.Name = "Background"
	frame2.Size = UDim2.new(1, -4, 1, -4)
	frame2.Position = UDim2.new(0, 2, 0, 2)
	frame2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	frame2.BorderSizePixel = 0
	frame2.ZIndex = 6
	frame2.Parent = frame
	local frame3 = Instance.new("Frame")
	frame3.Name = "Charge"
	frame3.Size = UDim2.new(1, 0, 1, 0)
	frame3.Position = UDim2.new(0, 0, 0, 0)
	frame3.AnchorPoint = Vector2.new(0, 0)
	frame3.BackgroundColor3 = self.config.Color
	frame3.BackgroundTransparency = 0.1
	frame3.BorderSizePixel = 0
	frame3.ZIndex = 7
	frame3.Parent = frame2
	local frame4 = Instance.new("Frame")
	frame4.Name = "SmoothFill"
	frame4.Size = UDim2.new(1, 0, 1, 0)
	frame4.Position = UDim2.new(0, 0, 0, 0)
	frame4.BackgroundColor3 = self.config.Color:Lerp(Color3.new(1, 1, 1), 0.1)
	frame4.BackgroundTransparency = 0
	frame4.BorderSizePixel = 0
	frame4.ZIndex = 8
	frame4.Parent = frame3
	local frame5 = Instance.new("Frame")
	frame5.Name = "WarningOverlay"
	frame5.Size = UDim2.new(1, 0, 1, 0)
	frame5.Position = UDim2.new(0, 0, 0, 0)
	frame5.BackgroundColor3 = self.config.Color:Lerp(Color3.new(0, 0, 0), 0.5)
	frame5.BackgroundTransparency = 0.9
	frame5.Visible = false
	frame5.BorderSizePixel = 0
	frame5.ZIndex = 9
	frame5.Parent = frame3
	local uIStroke = Instance.new("UIStroke")
	uIStroke.Name = "Glow"
	uIStroke.Color = self.config.Color:Lerp(Color3.new(1, 1, 1), 0.4)
	uIStroke.Thickness = 2
	uIStroke.Transparency = 1
	uIStroke.Enabled = false
	uIStroke.Parent = frame
	frame.Parent = self.current.reel_playerbar
	self.warningTween = self.current.renderTweens:Create(
		frame5,
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			BackgroundTransparency = 0.7
		}
	)
	self.glowTween = self.current.renderTweens:Create(
		uIStroke,
		TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{
			Transparency = 0.3
		}
	)
	self.bloopBar = frame
	self.bloopChargeBar = frame3
	self.smoothFill = frame4
	self.warningOverlay = frame5
	self.glowEffect = uIStroke
end

function BloopBehavior:Update()
	if not self.current.active then
		return
	end

	local progress = self.current.progress
	local v = progress - self.lastProgress
	self.lastProgress = progress
	table.insert(self.recentProgressChanges, v)

	if #self.recentProgressChanges > self.progressHistorySize then
		table.remove(self.recentProgressChanges, 1)
	end

	local total = 0

	for _, recentProgressChange in ipairs(self.recentProgressChanges) do
		total += recentProgressChange
	end

	local v2 = total / #self.recentProgressChanges

	if v2 > 0.01 then
		local v3 = self.config.DrainRate * 0.0125 * math.min(1, v2 * 2)
		self.targetCharge = math.max(0, self.targetCharge - v3)
	elseif v2 < -0.01 then
		local v3 = self.config.ChargeRate * 0.0125 * math.min(1, math.abs(v2) * 2)
		self.targetCharge = math.min(100, self.targetCharge + v3)
	else
		self.targetCharge = math.min(100, self.targetCharge + 0.25)
	end

	self.targetCharge = math.clamp(self.targetCharge, 0, 100)
	self.currentCharge += (self.targetCharge - self.currentCharge) * self.config.SmoothingFactor
	local serverTimeNow = Workspace:GetServerTimeNow()

	if self.currentCharge <= self.config.ExtremeThreshold and self.lastExtremeEvent + self.config.ExtremeCooldown < serverTimeNow and not self.isExtremeActive then
		self:TriggerExtremeEvent()
	end
end

function BloopBehavior:SmoothUpdate(p)
	if not self.current.active then
		return
	end

	local v = self.currentCharge - self.displayCharge
	local v2 = p * 8

	if math.abs(v) > 0.1 then
		self.displayCharge += v * v2
	else
		self.displayCharge = self.currentCharge
	end

	self.displayCharge = math.clamp(self.displayCharge, 0, 100)

	if self.bloopChargeBar and self.smoothFill then
		local v3 = self.displayCharge / 100
		local smoothDamp, chargeVel = TweenService:SmoothDamp(self.currentScale, v3, self._chargeVel, 0.25, nil, p)
		self.currentScale = smoothDamp
		self._chargeVel = chargeVel
		self.smoothFill.Size = UDim2.fromScale(self.currentScale, 1)
		local backgroundColor3 = self.bloopChargeBar.BackgroundColor3
		local color

		if v3 < 0.25 then
			color = Color3.fromRGB(0, 0, 0)

			if not self.warningTween.PlaybackState then
				self.warningTween:Play()
				self.warningOverlay.Visible = true
				self.glowEffect.Enabled = true
				self.glowTween:Play()
			end
		else
			if v3 < 0.5 then
				color = Color3.fromRGB(127, 127, 127)
			else
				color = Color3.fromRGB(255, 255, 255)
			end

			self.warningTween:Pause()
			self.warningOverlay.Visible = false
			self.glowTween:Pause()
			self.glowEffect.Enabled = false
		end

		if backgroundColor3 ~= color and math.abs(backgroundColor3.R - color.R) + math.abs(backgroundColor3.G - color.G) + math.abs(backgroundColor3.B - color.B) > 0.05 then
			TweenService:Create(
				self.bloopChargeBar,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = color
				}
			):Play()
		end

		if v3 < 0.3 then
			local v5 = (0.3 - v3) / 0.3
			self.glowEffect.Transparency = 0.7 - v5 * 0.4
		end
	end
end

function BloopBehavior:TriggerExtremeEvent()
	self.isExtremeActive = true
	self.lastExtremeEvent = Workspace:GetServerTimeNow()
	local current = self.current
	local config = self.config
	self.targetCharge = -20
	current:DelayLogic(0.5, function()
		if current.active then
			self.targetCharge = config.ExtremeChargeReset
		end
	end)
	fx:ShakeScreen(Players.LocalPlayer, 5, config.ExtremeDuration)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui["break"], current.reel, true)

	for i = 1, 3 do
		current:DelayRender((i - 1) * 0.2, function()
			if current.active then
				self.current.renderTweens:CreateAndPlay(
					current.reel_progress.bar,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
					{
						BackgroundColor3 = config.Color
					}
				)
			end
		end)
	end

	current:AddProgress(-(current.progress * config.ExtremeProgressLossRatio))
	self.bloopBarResizer.Value = 1 - config.ExtremeControlReduce
	self.current.renderTweens:Create(
		self.bloopBar,
		TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{
			BackgroundColor3 = config.Color
		}
	):Play()
	local v = math.random() < 0.5
	local v2 = v and -1 or 1
	current.core.rod:LockInput(config.ExtremeDuration, v2)
	current.core.rod:ApplyImpulse(v2 * config.ExtremeFlingPower)
	local frame = Instance.new("Frame")
	frame.Name = "BloopLockCue"
	frame.Size = UDim2.fromScale(0.1, 1)
	frame.Position = v and UDim2.fromScale(0, 0) or UDim2.fromScale(0.9, 0)
	frame.BackgroundColor3 = config.Color
	frame.BackgroundTransparency = 0.5
	frame.ZIndex = 10
	frame.Parent = current.reel_playerbar
	self.current.logicTweens:Create(
		self.bloopProgressDrainer,
		TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Value = self.bloopProgressDrainer.Value - config.ExtremeProgressLossFlat
		}
	):Play()
	current:DelayLogic(config.ExtremeDuration, function()
		if current.active then
			self.isExtremeActive = false
			self.bloopBarResizer.Value = 1
			current.renderTweens:Create(
				self.bloopBar,
				TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = Color3.fromRGB(20, 20, 20)
				}
			):Play()

			if frame and frame.Parent then
				current.renderTweens:Create(
					frame,
					TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundTransparency = 1
					}
				):Play()
				current:DelayRender(0.3, function()
					if frame and frame.Parent then
						frame:Destroy()
					end
				end)
			end
		end
	end)
end

setmetatable(BloopBehavior, module)
return BloopBehavior