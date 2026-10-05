local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("UI_Spinner", function(p)
	local tween = TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {
		Rotation = 359.9
	})
	tween:Play()
	return function()
		if tween.PlaybackState == Enum.PlaybackState.Playing then
			tween:Cancel()
		end

		tween:Destroy()
	end
end)