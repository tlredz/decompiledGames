local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local FrostwyrmBehavior = {}
FrostwyrmBehavior.__index = FrostwyrmBehavior
FrostwyrmBehavior.MorphSpear = true
FrostwyrmBehavior.MorphHarpoon = true
local v = {
	reel = "accel",
	stab = "power",
	harpoon = "movementfactor"
}

function FrostwyrmBehavior:Morph(_, object2)
	self.lastFreeze = 0
	self.freezeCount = 0
	self.freezeActive = false
	self.freezeTween = nil
	self.iceEffect = nil
	self.slowModifier = object2:CreateModifier(v[object2.type], "multiply")
	self.freezeModifier = object2:CreateModifier("progress", "add")
	self.random = object2:GetRandom(5)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function FrostwyrmBehavior:Update(object)
	local config = self.config

	if not object.active then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastFreeze + config.Cooldown then
		return
	end

	if math.max(config.BaseChance * (1 - self.freezeCount * 0.1), config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) and not self.freezeActive then
		self.freezeCount += 1
		self.lastFreeze = serverTimeNow
		self.freezeActive = true
		local color = config.Color

		if self.freezeTween then
			self.freezeTween:Cancel()
			self.freezeTween = nil
		end

		self.freezeTween = object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				BackgroundColor3 = color,
				BackgroundTransparency = 0.3
			}
		)
		self.freezeTween:Play()

		if self.iceEffect and self.iceEffect.Parent then
			self.iceEffect:Destroy()
		end

		self.iceEffect = Instance.new("Frame")
		self.iceEffect.Name = "FrostWyrmIceOverlay"
		self.iceEffect.Size = UDim2.fromScale(1, 1)
		self.iceEffect.BackgroundColor3 = color
		self.iceEffect.BackgroundTransparency = 0.7
		self.iceEffect.BorderSizePixel = 0
		self.iceEffect.ZIndex = 5
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 230, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
		})
		uIGradient.Rotation = 45
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 0.6),
			NumberSequenceKeypoint.new(1, 0.8)
		})
		uIGradient.Parent = self.iceEffect
		self.iceEffect.Parent = object.reel_playerbar
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.cryogenic, object.reel, true)
		self.slowModifier.Value = config.AccelMultiply
		self.freezeModifier.Value = object.progress * -config.ProgressLossRatio
		fx:ShakeScreen(Players.LocalPlayer, 1.5, config.FreezeDuration)
		task.spawn(function()
			for _ = 1, 3 do
				if not (object.active and self.iceEffect) then
					break
				end

				local frame = Instance.new("Frame")
				frame.Name = "FrostParticle"
				frame.Size = UDim2.fromScale(0.02, 0.1)
				frame.Position = UDim2.fromScale(math.random(), math.random())
				frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				frame.BackgroundTransparency = 0.3
				frame.BorderSizePixel = 0
				frame.ZIndex = 6
				frame.Parent = self.iceEffect
				local v2 = object.logicTweens:Create(frame, TweenInfo.new(1, Enum.EasingStyle.Linear), {
					Position = UDim2.fromScale(math.random(), math.random()),
					BackgroundTransparency = 1
				})
				v2:Play()
				v2.Completed:Connect(function()
					if frame then
						frame:Destroy()
					end
				end)
				object:WaitLogic(0.3)
			end
		end)
		object:DelayLogic(config.FreezeDuration, function()
			if not object.active then
				return
			end

			object.logicTweens:Create(
				object.reel_progress.bar,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0
				}
			):Play()

			if self.iceEffect then
				local v2 = object.logicTweens:Create(
					self.iceEffect,
					TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundTransparency = 1
					}
				)
				v2:Play()
				v2.Completed:Connect(function()
					if self.iceEffect then
						self.iceEffect:Destroy()
						self.iceEffect = nil
					end
				end)
			end

			self.slowModifier.Value = 1
			self.freezeModifier.Value = 0
			self.freezeActive = false
			object:DelayLogic(0.5, function()
				if object.active then
					object:AddProgress(-2)
				end
			end)
		end)
	end
end

setmetatable(FrostwyrmBehavior, module)
return FrostwyrmBehavior