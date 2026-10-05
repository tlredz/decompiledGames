local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "ContinuousTweenedCFrame"
})

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:TurnedOpaque(flag: boolean)
	local tweenDuration = self.Instance:GetAttribute("TweenDuration")
	task.spawn(function()
		while self.active and self.Instance and self.Instance:HasTag("ContinuousTweenedCFrame") and self.Instance:IsDescendantOf(workspace) and (not flag or self.Instance.Transparency < 1) do
			TweenService:Create(
				self.Instance,
				TweenInfo.new(tweenDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0),
				{
					CFrame = self.Instance.CFrame * self.Instance:GetAttribute("OffsetPerTween")
				}
			):Play()
			task.wait(tweenDuration)
		end
	end)
end

function v:Start()
	self.active = true

	if self.Instance:GetAttribute("TweenWhileInvisible") then
		self:TurnedOpaque(false)
	else
		self._Janitor:Add(self.Instance:GetPropertyChangedSignal("Transparency"):Connect(function()
			if self.Instance.Transparency < 1 then
				self:TurnedOpaque(true)
			end
		end))

		if self.Instance.Transparency < 1 then
			self:TurnedOpaque(true)
		end
	end
end

function v:Stop()
	self.active = false
end

return v