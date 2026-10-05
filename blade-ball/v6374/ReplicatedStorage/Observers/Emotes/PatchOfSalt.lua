local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("PatchOfSalt", function(p)
	local tween = TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
		Transparency = 0
	})
	tween:Play()
	return function()
		tween:Cancel()
		tween:Destroy()
	end
end)