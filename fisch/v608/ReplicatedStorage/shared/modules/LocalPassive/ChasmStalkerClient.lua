local ChasmStalkerClient = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("HttpService")
require(ReplicatedStorage.packages.Trove)
local fx = require(ReplicatedStorage.shared.modules.fx)
local module = require("./PassiveHandler")
local loop = script:WaitForChild("loop")

function ChasmStalkerClient:StartWhirlpool()
	local config = self.config
	local current = self.current
	local halfWidth = config.Width / 2
	local v2 = math.max(config.Duration - config.RampTime, 0.01)
	self.active = true
	self.pulling = true
	self.whirlpoolId += 1
	self.center = self.random:NextNumber(halfWidth, 1 - halfWidth)
	self.swirl = self.random:NextNumber(0, 6.283185307179586)
	self.maxControlLoss = math.min(
		config.MaxControlLoss,
		(math.max(current.stats.Control + self.controlModifier.Value, 0))
	)
	self.drainRate = self.maxControlLoss / v2
	self.controlLost = 0
	current.core.fish:ForceMoveTo(self.center, config.PullInTime)
	current.core.fish:DelayNextMovement(v2)
	local clone = script.whirlpool:Clone()
	clone.AnchorPoint = Vector2.new(0.5, 0.5)
	clone.Size = UDim2.fromScale(config.Width, 1)
	clone.Position = UDim2.fromScale(self.center, 0.5)
	local uIScale = clone:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Scale = 0
	uIScale.Parent = clone
	self.scale = uIScale
	local whirl = clone:FindFirstChild("Whirl")

	if whirl and whirl:IsA("GuiObject") then
		self.whirl = whirl
		self.whirlOrigin = whirl.Position
		self.floatTime = self.random:NextNumber(0, 100)
	end

	clone.Parent = self.reel
	self.whirlpoolTrove:Add(clone)
	local modifier = current:CreateModifier("progressefficiency", "force_add")
	self.forcedProgress = self.whirlpoolTrove:Add(modifier)
	self.forcedProgressPeak = (config.ForcedProgressSpeed + config.ForcedProgressSpeedPerLevel * self.level) / 100
	local tweenInfo = TweenInfo.new(config.RampTime, Enum.EasingStyle.Quad)
	current.logicTweens:CreateAndPlay(uIScale, tweenInfo, {
		Scale = 1
	})
	current.logicTweens:CreateAndPlay(modifier, tweenInfo, {
		Value = self.forcedProgressPeak
	})
	fx:PlaySound(script.spawn, clone, true)
	loop.Volume = 0
	loop.PlaybackSpeed = 0.7
	loop.Playing = true
	current.logicTweens:CreateAndPlay(loop, tweenInfo, {
		Volume = 0.15,
		PlaybackSpeed = 0.9
	})
	self.whirlpoolTrove:Add(function()
		loop.Playing = false
	end)
	self.trove:Add(current.OnMinigameEnd:Connect(function()
		loop.Playing = false
	end))
	local whirlpoolId = self.whirlpoolId
	current:DelayLogic(v2, function()
		if self.active and self.whirlpoolId == whirlpoolId then
			self:FadeWhirlpool()
		end
	end)
end

function ChasmStalkerClient:FadeWhirlpool()
	local config = self.config
	local tweenInfo = TweenInfo.new(config.RampTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	self.pulling = false
	local fish = self.current.core.fish
	fish:CancelMovement(true)
	fish:MoveRandom()

	if self.scale then
		self.current.logicTweens:CreateAndPlay(self.scale, tweenInfo, {
			Scale = 0
		})
	end

	if self.forcedProgress then
		self.current.logicTweens:CreateAndPlay(self.forcedProgress, tweenInfo, {
			Value = 0
		})
	end

	self.current.logicTweens:CreateAndPlay(self.residualProgress, tweenInfo, {
		Value = self.residualProgress.Value + self.forcedProgressPeak * config.ResidualShare
	})
	self.current.logicTweens:CreateAndPlay(self.controlModifier, tweenInfo, {
		Value = self.controlModifier.Value + self.controlLost * config.ControlRefund
	}):Play()
	self.current.logicTweens:CreateAndPlay(loop, tweenInfo, {
		Volume = 0,
		PlaybackSpeed = 0.7
	})
	local whirlpoolId = self.whirlpoolId
	self.current:DelayLogic(config.RampTime, function()
		if self.active and self.whirlpoolId == whirlpoolId then
			self:EndWhirlpool()
		end
	end)
end

function ChasmStalkerClient:EndWhirlpool()
	self.active = false
	self.pulling = false
	self.forcedProgress = nil
	self.scale = nil
	self.whirl = nil
	self.whirlOrigin = nil
	self.whirlpoolTrove:Clean()
end

function ChasmStalkerClient:TickRender_Rod(object, p: number)
	if not self.active then
		return
	end

	local config = self.config

	if self.pulling then
		self.swirl += p * config.SwirlSpeed
		object.core.fish.CurrentTarget = math.clamp(
			self.center + math.sin(self.swirl) * (config.Width / 2) * config.SwirlRadius,
			object.minFishPosition,
			object.maxFishPosition
		)

		if self.controlLost < self.maxControlLoss and object:IsInBar(self.center, config.Width) then
			local v = math.min(self.drainRate * p, self.maxControlLoss - self.controlLost)
			self.controlLost += v
			self.controlModifier.Value -= v
		end

		object:IsInBar(self.center, config.Width)
	end

	local whirl = self.whirl
	local whirlOrigin = self.whirlOrigin

	if whirl and whirlOrigin then
		self.floatTime += p
		local floatTime = self.floatTime
		local v = math.sin(floatTime * 1.7) * 0.05 + math.sin(floatTime * 2.9) * 0.022 + math.sin(floatTime * 0.63) * 0.018
		local v2 = math.sin(floatTime * 2.3) * 0.045 + math.cos(floatTime * 3.7) * 0.02 + math.cos(floatTime * 0.91) * 0.015
		whirl.Position = whirlOrigin + UDim2.fromScale(v, v2)
	end
end

function ChasmStalkerClient:Morph(_, object2)
	self.random = object2:GetRandom(21)
	self.level = tonumber(object2.data.ChasmStalkerLevel) or 0
	self.baseBarSize = object2.stats.Control + 0.3
	self.active = false
	self.pulling = false
	self.controlLost = 0
	self.controlModifier = object2:CreateModifier("barSize", "add")
	self.residualProgress = object2:CreateModifier("progressefficiency", "force_add")
	self.current:Preload({ script })
	self.reelTrove:Add(task.spawn(function()
		while true do
			object2:WaitLogic(self.config.AttemptInterval)

			if self.active or not object2.active or object2.isPaused or not (self.random:NextNumber(0, 100) < self.config.TriggerChance) then
				continue
			end

			self:StartWhirlpool()
		end
	end))
	self.reelTrove:Add(function()
		self.active = false
		self.pulling = false
		self.forcedProgress = nil
		self.scale = nil
		self.whirl = nil
		self.whirlOrigin = nil
	end)
end

function ChasmStalkerClient.new(p, p2, p3)
	local v = module.new(p, p2, p3)
	v.whirlpoolTrove = v.reelTrove:Extend()
	v.level = 0
	v.baseBarSize = 0.4
	v.active = false
	v.pulling = false
	v.whirlpoolId = 0
	v.controlLost = 0
	v.maxControlLoss = 0
	v.drainRate = 0
	v.forcedProgressPeak = 0
	v.floatTime = 0
	return v
end

setmetatable(ChasmStalkerClient, module)
return ChasmStalkerClient