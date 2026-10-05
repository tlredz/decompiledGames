game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module = require("./PassiveHandler")
local fx = require(ReplicatedStorage.shared.modules.fx)
local AbaiaBehavior = {}
AbaiaBehavior.__index = AbaiaBehavior

function AbaiaBehavior:Fling()
	local current = self.current
	local config = self.config
	self.flingCount += 1
	self.lastFling = Workspace:GetServerTimeNow()
	local v = self.random:NextNumber(0, 1) < 0.5 and -1 or 1

	if current.core.rod then
		current.core.rod:ApplyImpulse(v * config.FlingPower)

		if config.FlingLockTime and config.FlingLockTime > 0 then
			current.core.rod:LockInput(config.FlingLockTime, v)
		end
	end

	if config.ProgressLoss and config.ProgressLoss > 0 then
		current:AddProgress(-config.ProgressLoss)
	end

	current.renderTweens:CreateAndPlay(
		current.reel_progress.bar,
		TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
		{
			BackgroundColor3 = config.Color
		}
	)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.wave, current.reel, true)
end

function AbaiaBehavior:Bite()
	local current = self.current
	local config = self.config
	self.barSizeLoss.Value -= config.BiteBarSizeLoss
	self.resilienceMult.Value *= config.BiteResilienceMult
	current.fx:SpawnShake(current.reel_bar, 0.2, 0.3, 0.012, false)
	current.renderTweens:CreateAndPlay(
		current.reel_playerbar,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
		{
			BackgroundColor3 = config.Color
		}
	)
	fx:PlaySound(ReplicatedStorage.resources.sounds.sfx.ui.snap, current.reel, true)
end

function AbaiaBehavior:UpdateCamp(p: number)
	local current = self.current
	local config = self.config

	if current.active and not current.isPaused then
		if math.abs(current.barPosition - self.campAnchor) > config.BiteCampRange then
			self.campAnchor = current.barPosition
			self.campTimer = 0
		else
			self.campTimer += p

			if self.campTimer >= config.BiteCampTime then
				self.campTimer = 0
				self.campAnchor = current.barPosition
				self:Bite()
			end
		end
	else
		self.campTimer = 0
		self.campAnchor = current.barPosition
	end
end

function AbaiaBehavior:Morph(_, object2)
	if object2.data.AbaiaBarrier then
		return
	end

	local config = self.config

	if object2.data.AbaiaUnsealed then
		config.ProgressLoss *= 10
		config.FlingChance = 100
		config.FlingCooldown = 0
	end

	self.random = object2:GetRandom(9)
	self.lastFling = 0
	self.flingCount = 0
	self.campAnchor = object2.barPosition
	self.campTimer = 0
	self.barSizeLoss = object2:CreateModifier("barSize", "add")
	self.resilienceMult = object2:CreateModifier("resilience", "multiply")
	object2:AddModifier("minBarSize", "add", (config.BiteBarSizeFloor or 0.08) - object2.minBarSize)
	self.reelTrove:Add(object2.OnLogicStep:Connect(function(p: number)
		self:UpdateCamp(p)
	end))
	self.reelTrove:Add(object2.OnFishMove:Connect(function()
		self:Update()
	end))
end

function AbaiaBehavior:Update()
	local current = self.current
	local config = self.config

	if not current.active or current.isPaused or Workspace:GetServerTimeNow() < self.lastFling + config.FlingCooldown then
		return
	end

	if math.max(config.FlingChance * (1 - self.flingCount * 0.05), config.FlingChance * 0.6) > self.random:NextNumber(
		0,
		100
	) then
		self:Fling()
	end
end

setmetatable(AbaiaBehavior, module)
return AbaiaBehavior