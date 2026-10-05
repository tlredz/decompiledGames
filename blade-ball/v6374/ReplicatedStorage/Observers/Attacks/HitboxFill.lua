local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.ServerInfo)
return Observers.observeTag("HitboxFill", function(instance)
	local red = instance:WaitForChild("Red", 5)
	local fill = instance:WaitForChild("Fill", 5)

	if not (red and fill) then
		return
	end

	local tween = TweenService:Create(
		fill,
		TweenInfo.new((instance:GetAttribute("WaitTime") or 0) + 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			Size = red.Size
		}
	)
	tween:Play()
	local completedConnection = tween.Completed:Once(function()
		TweenService:Create(fill, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		TweenService:Create(red, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
		task.delay(0.5, function()
			fill:Destroy()
			red:Destroy()
		end)
	end)
	return function()
		tween:Cancel()
		tween:Destroy()
		completedConnection:Disconnect()
	end
end, { workspace })