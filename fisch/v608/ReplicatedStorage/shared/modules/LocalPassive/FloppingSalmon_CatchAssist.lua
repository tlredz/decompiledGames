local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CompanionController = require(ReplicatedStorage.client.legacyControllers.CompanionController)
local Net = require(ReplicatedStorage.packages.Net)
local module = require("./PassiveHandler")
local remoteEvent = Net:RemoteEvent("FloppingSalmon/StartBuffs")
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint)
local tweenInfo2 = TweenInfo.new(0.5, Enum.EasingStyle.Quint)
local FloppingSalmonCatchAssist = {
	MorphSpear = true,
	GetCurrentConfig = function(self)
		self.currentConfig = CompanionController.GetScaledConfig(self.config)
		return self.currentConfig
	end,
	StartBoost = function(self)
		if self.IsActive then
			return
		end

		self.IsActive = true
		local currentConfig = self:GetCurrentConfig()
		self.current.logicTweens:CreateAndPlay(self._progressModifier, tweenInfo, {
			Value = currentConfig.ProgressSpeedBoost / 100
		})
		self.current.logicTweens:CreateAndPlay(self._resilienceModifier, tweenInfo, {
			Value = currentConfig.ResilienceBoost
		})
	end,
	EndBoost = function(self)
		if not self.IsActive then
			return
		end

		self.IsActive = false

		if self._progressModifier then
			self.current.logicTweens:CreateAndPlay(self._progressModifier, tweenInfo2, {
				Value = 0
			})
		end

		if self._resilienceModifier then
			self.current.logicTweens:CreateAndPlay(self._resilienceModifier, tweenInfo2, {
				Value = 0
			})
		end
	end,
	Morph = function(self, _, object2)
		self:GetCurrentConfig()
		self.IsActive = false
		self._progressModifier = object2:CreateModifier("progressefficiency", "add")
		self._resilienceModifier = object2:CreateModifier("resilience", "add")
		self.reelTrove:Add(remoteEvent.OnClientEvent:Connect(function()
			self:StartBoost()
		end))
		self.reelTrove:Add(object2.PreMinigameEnd:Connect(function()
			self:EndBoost()
		end))
		self.reelTrove:Add(function()
			self.IsActive = false
			self._progressModifier = nil
			self._resilienceModifier = nil
		end)
	end
}
setmetatable(FloppingSalmonCatchAssist, module)
return FloppingSalmonCatchAssist