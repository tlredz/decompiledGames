local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("BeamTweenWidth", function(instance)
	local tween = TweenService:Create(
		instance,
		TweenInfo.new(instance:GetAttribute("TargetDuration") or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
		{
			Width0 = instance:GetAttribute("TargetWidth0") or 0,
			Width1 = instance:GetAttribute("TargetWidth1") or 0
		}
	)
	tween:Play()
	return function()
		tween:Cancel()
		tween:Destroy()
		tween = nil
	end
end)