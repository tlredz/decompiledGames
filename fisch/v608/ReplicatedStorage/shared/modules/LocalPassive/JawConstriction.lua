local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
game:GetService("RunService")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
require(ReplicatedStorage:WaitForChild("packages"):WaitForChild("Trove"))
require(ReplicatedStorage.shared.modules.library.rods)
require(ReplicatedStorage.shared.modules.fx)
require(ReplicatedStorage.shared.modules.library.fish)
local StatusEffectsController = require(ReplicatedStorage.client.legacyControllers.StatusEffectsController)
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local module = require("./PassiveHandler")
ReplicatedStorage:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("fishing")
ReplicatedStorage:WaitForChild("world")
local JawConstriction = {
	MorphSpear = true
}
Random.new()
local uDim = UDim2.fromScale(0.43, 0.869)
local uDim2 = UDim2.fromScale(0, 0.869)

function JawConstriction:GetCurrentConfig()
	self.currentConfig = CompanionController.GetScaledConfig(self.config)
	return self.currentConfig
end

function JawConstriction:ApplyAssets()
	ContentProvider:PreloadAsync({
		self.CurrentAssets.TopTeeth or "",
		self.CurrentAssets.BottomTeeth or "",
		self.CurrentAssets.LurkLeft or "",
		self.CurrentAssets.LurkRight or ""
	})
	self.BiteContainer.topTeeth.Image = self.CurrentAssets.TopTeeth or ""
	self.BiteContainer.bottomTeeth.Image = self.CurrentAssets.BottomTeeth or ""

	if self.LurkingFish then
		self.LurkingFish.faceLeft.Image = self.CurrentAssets.LurkLeft or ""
		self.LurkingFish.faceRight.Image = self.CurrentAssets.LurkRight or ""
	end
end

function JawConstriction:TickLurking(p: number)
	if not self.LurkingFish then
		return
	end

	local v = self._elapsed % 5.5
	local v2 = self._elapsed // 5.5 % 2 == 1
	local lerped = uDim2:Lerp(
		uDim,
		(TweenService:GetValue(
			math.clamp(math.abs((math.map(v, 5, 5.5, 1, -1))), 0, 1),
			Enum.EasingStyle.Circular,
			Enum.EasingDirection.InOut
		))
	)
	local v4 = (v - 5) / 0.5 >= 0.5
	self.LurkingFish.Size = lerped
	self.LurkingFish.faceLeft.Visible = v4 == not v2
	self.LurkingFish.faceRight.Visible = v4 == v2
	local smoothDamp, yVelocity = TweenService:SmoothDamp(
		self.LurkingFish.Position.Y.Scale,
		(self.IsBiting or not self.current.active) and 2 or 1.2,
		self._yVelocity,
		0.5,
		nil,
		p
	)
	self._yVelocity = yVelocity
	local v6 = math.clamp(v / 5, 0, 1)
	TweenService:GetValue(v6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut)
	local v7 = math.map(v6, 0, 1, v2 and 0.8 or 0.2, v2 and 0.2 or 0.8)
	self.LurkingFish.Position = UDim2.fromScale(v7, smoothDamp)
end

function JawConstriction:StartBite()
	self.IsBiting = true
	local currentConfig = self:GetCurrentConfig()
	local v = not self.IsEnhanced and 1 or currentConfig.EnhanceMultiplier or 1
	self._remainingBiteTime = currentConfig.Duration * v + 1
	self._nextBiteAttempt += currentConfig.Cooldown + 0.5
	task.spawn(function()
		self.BiteContainer.topTeeth.ImageTransparency = 1
		self.BiteContainer.topTeeth.Position = UDim2.fromScale(0.5, 0.1)
		self.BiteContainer.bottomTeeth.ImageTransparency = 1
		self.BiteContainer.bottomTeeth.Position = UDim2.fromScale(0.5, 0.9)
		self.current.logicTweens:Create(self.BiteContainer.topTeeth, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
			ImageTransparency = 0,
			Position = UDim2.fromScale(0.5, 0)
		}):Play()
		self.current.logicTweens:Create(self.BiteContainer.bottomTeeth, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
			ImageTransparency = 0,
			Position = UDim2.fromScale(0.5, 1)
		}):Play()
		self.current:WaitLogic(0.5)

		if not (self.current and self.current.active) then
			return
		end

		self.current.logicTweens:Create(self.BiteContainer.topTeeth, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Position = UDim2.fromScale(0.5, 0.5)
		}):Play()
		self.current.logicTweens:Create(
			self.BiteContainer.bottomTeeth,
			TweenInfo.new(0.5, Enum.EasingStyle.Exponential),
			{
				Position = UDim2.fromScale(0.5, 0.5)
			}
		):Play()
		local v2 = self.Random:NextInteger(currentConfig.ProgressSpeedMin, currentConfig.ProgressSpeedMax) * v / 100
		self.current.logicTweens:Create(self._biteProgSpeedModifier, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Value = v2
		}):Play()
		local barAccel = currentConfig.BarAccel

		if barAccel < 1 then
			barAccel /= v
		else
			barAccel *= v
		end

		self.current.logicTweens:Create(self._biteAccelModifier, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
			Value = currentConfig.BarAccel
		}):Play()

		if self.currentConfig.MoveFrequency then
			self.current.logicTweens:Create(self._biteMoveFactorModifier, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Value = self.currentConfig.MoveFrequency
			}):Play()
		end

		self.current.fx:SpawnShake(self.current.reel_bar, 0.5, 2, 0.01, false)
	end)
end

function JawConstriction:EndBite()
	self.IsBiting = false
	local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
	self.current.logicTweens:Create(self.BiteContainer.topTeeth, tweenInfo, {
		Position = UDim2.fromScale(0.5, 0),
		ImageTransparency = 1
	}):Play()
	self.current.logicTweens:Create(self.BiteContainer.bottomTeeth, tweenInfo, {
		Position = UDim2.fromScale(0.5, 1),
		ImageTransparency = 1
	}):Play()
	self.current.logicTweens:Create(self._biteProgSpeedModifier, tweenInfo, {
		Value = 0
	}):Play()
	self.current.logicTweens:Create(self._biteAccelModifier, tweenInfo, {
		Value = 1
	}):Play()
	self.current.logicTweens:Create(self._biteMoveFactorModifier, tweenInfo, {
		Value = 1
	}):Play()
end

function JawConstriction:TickBite(p: number)
	if self.IsBiting then
		self._remainingBiteTime -= p

		if self._remainingBiteTime <= 0 then
			self:EndBite()
			p = -self._remainingBiteTime
			self._remainingBiteTime = 0
		else
			return
		end
	end

	self._nextBiteAttempt -= p

	if self._nextBiteAttempt <= 0 then
		self._nextBiteAttempt += self.currentConfig.AttemptInterval

		if self.Random:NextNumber(0, 100) < self.currentConfig.TriggerChance then
			self:StartBite()
		end
	end
end

function JawConstriction:UpdateEnhanced(flag: boolean?)
	self:GetCurrentConfig()
	self.IsEnhanced = self.currentConfig.EnhanceStatus ~= nil and StatusEffectsController:HasStatusOfType(self.currentConfig.EnhanceStatus)
	self.CurrentAssets = self.IsEnhanced and self.currentConfig.EnhancedAssets or self.currentConfig.Assets

	if not flag then
		self:ApplyAssets()
	end
end

function JawConstriction:Morph(_, p)
	self.Random = self.current:GetRandom(11)
	self:GetCurrentConfig()
	self:UpdateEnhanced(true)
	self._elapsed = 0
	self._yVelocity = 0
	self._remainingBiteTime = 0
	self._nextBiteAttempt = not self.currentConfig.AttemptImmediate and 0 or self.currentConfig.AttemptInterval or 0
	self.IsBiting = false
	self._biteAccelModifier = self.current:CreateModifier("accel", "multiply")
	self._biteProgSpeedModifier = self.current:CreateModifier("progressefficiency", "add")
	self._biteMoveFactorModifier = self.current:CreateModifier("moveIntervalFactor", "multiply")
	self.BiteContainer = script.biteContainer:Clone()
	self.BiteContainer.Archivable = false

	if self.CurrentAssets.LurkLeft then
		self.LurkingContainer = script.lurkingContainer:Clone()
		self.LurkingFish = self.LurkingContainer.lurking
		self.current.PreMinigameEnd:Connect(function(p2)
			if not p2 and self.LurkingContainer then
				self.LurkingContainer:Destroy()
				self.LurkingContainer = nil
				self.LurkingFish = nil
			end
		end)
	elseif self.LurkingContainer then
		self.LurkingContainer:Destroy()
		self.LurkingContainer = nil
		self.LurkingFish = nil
	end

	self:ApplyAssets()
	self.BiteContainer.bottomTeeth.ImageTransparency = 1
	self.BiteContainer.bottomTeeth.Position = UDim2.fromScale(0.5, 1)
	self.BiteContainer.topTeeth.ImageTransparency = 1
	self.BiteContainer.topTeeth.Position = UDim2.fromScale(0.5, 0)
	self.BiteContainer.Parent = self.current.reel_playerbar

	if self.LurkingFish and self.LurkingContainer then
		self.LurkingFish.Size = uDim
		self.LurkingFish.Position = UDim2.fromScale(0.2, 2)
		self.LurkingFish.faceLeft.Visible = false
		self.LurkingFish.faceRight.Visible = true
		self.LurkingContainer.Parent = self.current.reel_bar
	end

	self.reelTrove:Add(function()
		self.LurkingContainer = nil
		self.LurkingFish = nil
		self.IsBiting = false
		self._biteAccelModifier = nil
		self._biteProgSpeedModifier = nil
		self._biteMoveFactorModifier = nil
	end)
	self.reelTrove:Add(p.OnLogicStep:Connect(function(p2: number)
		if not self.current or self.current.isPaused then
			return
		end

		self._elapsed += p2

		if self.current.active then
			self:TickBite(p2)
		end

		if self.LurkingFish then
			self:TickLurking(p2)
		end
	end))

	if self.currentConfig.EnhanceStatus ~= nil then
		self.reelTrove:Add(StatusEffectsController.StatusAdded:Connect(function(p2)
			if p2.Id == self.currentConfig.EnhanceStatus then
				self:UpdateEnhanced()
			end
		end))
		self.reelTrove:Add(StatusEffectsController.StatusRemoved:Connect(function()
			self:UpdateEnhanced()
		end))
	end
end

setmetatable(JawConstriction, module)
return JawConstriction