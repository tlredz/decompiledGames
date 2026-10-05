local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local ColossalDragonBehavior = {}
ColossalDragonBehavior.__index = ColossalDragonBehavior
ColossalDragonBehavior.MorphSpear = true
ColossalDragonBehavior.MorphHarpoon = true

function ColossalDragonBehavior:Morph(_, object2)
	self.lastPulse = 0
	self.pulseCount = 0
	self.progressValue = object2:CreateModifier("progress", "add")
	self.gainTween = nil
	self.lossTween = nil
	self.random = object2:GetRandom(5)
	object2.OnFishMove:Connect(function()
		self:Update(object2)
	end)
end

function ColossalDragonBehavior:Update(object)
	local config = self.config

	if not object.active then
		return
	end

	local serverTimeNow = Workspace:GetServerTimeNow()

	if serverTimeNow < self.lastPulse + config.Cooldown then
		return
	end

	if math.max(config.BaseChance * (1 - self.pulseCount * 0.15), config.BaseChance * 0.5) > self.random:NextNumber(
		0,
		100
	) then
		self.pulseCount += 1
		self.lastPulse = serverTimeNow

		if self.gainTween then
			self.gainTween:Cancel()
		end

		self.gainTween = object.logicTweens:Create(
			self.progressValue,
			TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{
				Value = self.progressValue.Value + 20
			}
		)
		self.gainTween:Play()
		object.logicTweens:Create(
			object.reel_progress.bar,
			TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
			{
				BackgroundColor3 = config.Color
			}
		):Play()
		fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.wave, object.reel, true)
		object:DelayLogic(config.LossDelay, function()
			if not object.active then
				return
			end

			local v = object.progress * config.ProgressLossRatio

			if self.lossTween then
				self.lossTween:Cancel()
			end

			self.lossTween = object.logicTweens:Create(
				self.progressValue,
				TweenInfo.new(config.LossTime, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
				{
					Value = self.progressValue.Value - v
				}
			)
			self.lossTween:Play()
		end)
	end
end

setmetatable(ColossalDragonBehavior, module)
return ColossalDragonBehavior