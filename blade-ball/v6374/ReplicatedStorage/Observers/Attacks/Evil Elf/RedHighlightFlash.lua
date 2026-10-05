local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("RedHighlightFlash", function(parent)
	local maid = Trove.new()
	local highlightDuration = parent:GetAttribute("HighlightDuration") or 100000
	local v = math.max(
		0.2,
		1.5 * (math.max((parent:GetAttribute("EndTime") or 0) - workspace:GetServerTimeNow(), 0) / highlightDuration)
	)
	local total = 0
	local v2 = maid:Add(parent:FindFirstChildWhichIsA("Highlight", true) or Instance.new("Highlight"))
	v2.FillColor = parent:GetAttribute("HighlightColor") or Color3.fromRGB(255, 0, 0)
	v2.OutlineColor = Color3.fromRGB(255, 255, 255)
	v2.FillTransparency = 0.2
	v2.OutlineTransparency = 0
	v2.DepthMode = Enum.HighlightDepthMode.Occluded
	v2.Parent = parent
	local clone = maid:Clone(ReplicatedStorage.Assets.Sounds.CupidBoss.Tick)
	clone.Parent = parent
	local v3 = true
	maid:Add(RunService.Heartbeat:Connect(function(dt)
		total += dt
		local v4 = total

		if v / 2 <= v4 then
			if v3 then
				v2.FillTransparency = v3 and 0.2 or 1
				v2.OutlineTransparency = 0
			else
				v2.OutlineTransparency = v3 and 0.2 or 1
				v2.FillTransparency = 1
			end

			clone:Play()
			v3 = not v3
			total = 0
		end
	end))
	return function()
		maid:Destroy()
	end
end)