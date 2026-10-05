local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
local parent = script.Parent
local _ = parent.Parent.Parent
local LaserGunsShared = require(ReplicatedStorage.Shared.LaserGunsShared)
local v = -1e999
parent.Activated:Connect(function()
	local serverTimeNow = workspace:GetServerTimeNow()

	if serverTimeNow - v < LaserGunsShared.Settings.Cooldown:Get() then
		return
	end

	v = serverTimeNow
	LaserGunsShared.ShootLocal()
end)