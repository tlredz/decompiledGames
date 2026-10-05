local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Observers = require(ReplicatedStorage.Packages.Observers)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
return Observers.observeTagNoAncestry("LiveSaleFrame", function(instance)
	local _ = instance.Parent
	local v = nil

	if instance:GetAttribute("Priority") then
		local serverTimeNow = workspace:GetServerTimeNow()
		local v2 = instance:GetAttribute("barTweenEndTime") - serverTimeNow

		if v2 > 0 then
			local bar = instance:WaitForChild("Bar"):WaitForChild("Bar")

			if bar and bar.Visible then
				local v3 = 1 * (v2 / instance:GetAttribute("barTweenDuration"))
				bar.Size = UDim2.new(v3, 0, 0, 8)
				v = FastUtils.fastTween(
					bar,
					TweenInfo.new(v2, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 1.5),
					{
						Size = UDim2.new(0, 0, 0, 8)
					}
				)
			end
		end
	end

	instance.Visible = true
	local fastTween = FastUtils.fastTween(instance, TweenInfo.new(1.5), {
		GroupTransparency = 0
	})
	return function()
		if v then
			v:Cancel()
		end

		fastTween:Cancel()
	end
end)