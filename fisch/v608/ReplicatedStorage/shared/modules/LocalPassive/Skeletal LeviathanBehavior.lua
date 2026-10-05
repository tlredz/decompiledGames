game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local SkeletalLeviathanBehavior = {}
SkeletalLeviathanBehavior.__index = SkeletalLeviathanBehavior
SkeletalLeviathanBehavior.MorphSpear = true

function SkeletalLeviathanBehavior:Morph(_, object2)
	self.whipCount = 0
	self.lastWhip = 0
	self.barResizer = object2:CreateModifier("barSize", "multiply")
	self.accelMultiply = object2:CreateModifier("accel", "multiply")
	self.random = object2:GetRandom(7)
	self.lastReverse = 0
	self.reverseActive = false
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function SkeletalLeviathanBehavior:Update(object)
	if not object.active then
		return
	end

	local config = self.config
	local serverTimeNow = Workspace:GetServerTimeNow()

	if self.lastWhip + config.Cooldown <= serverTimeNow and object.progress >= (config.MinimumProgress or 0) and math.max(
		config.BaseChance * (1 - self.whipCount * 0.1),
		config.BaseChance * 0.5
	) > self.random:NextNumber(0, 100) then
		self.whipCount += 1
		self.lastWhip = serverTimeNow
		object:AddProgress(object.progress * -config.ProgressLoss)
		fx:ShakeScreen(Players.LocalPlayer, 3, config.Duration)
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.growl, object.reel, true)
		TweenService:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				BackgroundColor3 = config.Color
			}
		):Play()
		local tweenInfo = TweenInfo.new(config.AnimTime, Enum.EasingStyle.Quart)
		object.logicTweens:Create(self.barResizer, tweenInfo, {
			Value = 1 - config.ControlReduce
		}):Play()
		task.spawn(function()
			local tweenInfo2 = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

			for _ = 1, 25 do
				local rotation = math.random(-4, 4)
				local tween = TweenService:Create(object.reel_playerbar, tweenInfo2, {
					Rotation = rotation
				})
				tween:Play()
				tween.Completed:Wait()
			end

			TweenService:Create(object.reel_playerbar, TweenInfo.new(0.2), {
				Rotation = 0
			}):Play()
		end)
		self.accelMultiply.Value = 0.6
		object:DelayLogic(config.Duration, function()
			object.logicTweens:Create(self.barResizer, tweenInfo, {
				Value = 1
			}):Play()
			self.accelMultiply.Value = 1
		end)
	end

	if self.reverseActive then
		return
	end

	if self.lastReverse + config.ReverseCooldown <= serverTimeNow and object.progress >= (config.ReverseMinProgress or 0) and self.random:NextNumber(
		0,
		100
	) < config.ReverseChance then
		self.reverseActive = true
		self.lastReverse = serverTimeNow
		TweenService:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				BackgroundColor3 = config.ReverseColor
			}
		):Play()
		fx:ShakeScreen(Players.LocalPlayer, 1.5, config.ReverseDuration)
		local connection = nil
		connection = self.reelTrove:Add(object.OnLogicStep:Connect(function(p)
			if object.active and self.reverseActive then
				object:AddProgress(-config.ReverseDrain * p)
			else
				connection:Disconnect()
			end
		end))
		object:DelayLogic(config.ReverseDuration, function()
			self.reverseActive = false

			if connection then
				connection:Disconnect()
			end

			if object.active then
				TweenService:Create(
					object.reel_progress.bar,
					TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					}
				):Play()
			end
		end)
	end
end

setmetatable(SkeletalLeviathanBehavior, module)
return SkeletalLeviathanBehavior