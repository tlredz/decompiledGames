local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Common.Utils)

local function lerp(p, p2, p3: number)
	return p + (p2 - p) * p3
end

return Observers.observeTag("CupidHeartWall", function(instance)
	local maid = Trove.new()
	local targetScale = instance:GetAttribute("TargetScale") or 2
	local travelTime = instance:GetAttribute("TravelTime") or 10
	local targetPosition = instance:GetAttribute("TargetPosition")

	if not targetPosition then
		return
	end

	local position = instance:GetPivot().Position
	local rotation = instance:GetPivot().Rotation
	local scale = instance:GetScale()
	local total = 0
	local v = false
	local v2 = nil
	v2 = maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local v3 = total / travelTime

		if not v then
			total += dt
		end

		local _ = total / travelTime
		local lerped = position:Lerp(targetPosition, v3)
		local v4 = scale
		instance:ScaleTo(v4 + (targetScale - v4) * v3)
		instance:PivotTo(CFrame.new(lerped) * rotation)

		if travelTime <= total and not (maid._cleaning or v) then
			if v2 then
				maid:Remove(v2)
				v2 = nil
			end

			v = true
			maid:Clean()
		end
	end))
	return function()
		maid:Destroy()
	end
end, { workspace })