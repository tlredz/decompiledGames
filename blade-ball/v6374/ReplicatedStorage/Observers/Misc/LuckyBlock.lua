local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
game:GetService("Debris")
local _ = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
local Trove = require(ReplicatedStorage.Packages.Trove)
local v = { workspace.Runtime }
return Observers.observeTag("LuckyBlock", function(instance)
	local maid = Trove.new()
	local animationTimeout = instance:GetAttribute("AnimationTimeout")
	local startTime = instance:GetAttribute("StartTime")
	local targetPivot = instance:GetAttribute("TargetPivot")
	local v2 = targetPivot + createVector(0, 150, 0)
	instance:PivotTo(v2)
	local v3 = math.max(animationTimeout - startTime, 0)
	local v4 = false
	local v5 = v2
	local v6 = 0
	maid:Add(RunService.PostSimulation:Connect(function(dt: number)
		local serverTimeNow = workspace:GetServerTimeNow()

		if not v4 then
			local v7 = v3 <= 0 and 1 or (serverTimeNow - startTime) / v3
			v5 = v2:Lerp(targetPivot, (math.clamp(v7, 0, 1)))

			if v7 >= 1 then
				v4 = true
			end
		end

		v6 = (v6 + dt) % 6.283185307179586
		instance:PivotTo(v5 * CFrame.Angles(0, v6, 0) * CFrame.new(0, math.sin(serverTimeNow) + 2, 0))
	end))
	return function()
		maid:Destroy()
	end
end, v)