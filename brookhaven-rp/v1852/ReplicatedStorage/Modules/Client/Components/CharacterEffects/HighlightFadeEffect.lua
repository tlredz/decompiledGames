local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "HighlightFadeEffect"
})
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine)
local tweenInfo2 = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self.shouldLoop = self.Instance:GetAttribute("ShouldLoop") or false
	self.highlight = self.Instance
	self.highlight.FillTransparency = 1
	self.tween = TweenService:Create(self.highlight, tweenInfo, {
		FillTransparency = 0.8
	})
	self.tween2 = TweenService:Create(self.highlight, tweenInfo2, {
		FillTransparency = 1
	})
	self._Janitor:Add(self.tween2)
	self._Janitor:Add(self.tween)
	self.tween:Play()
	self.tween.Completed:Connect(function()
		if not self.shouldLoop then
			return
		end

		self.tween2:Play()
	end)

	if self.shouldLoop then
		self.tween2.Completed:Connect(function()
			if not self.shouldLoop then
				return
			end

			self.tween:Play()
		end)
	end
end

function v:Stop()
	self._Janitor:Destroy()
	self.shouldLoop = false
end

return v