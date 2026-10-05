local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Updates = require(ReplicatedStorage.Shared.Updates)
local Timer = require(ReplicatedStorage.Packages.Timer)
local FFlags = require(ReplicatedStorage.Packages.FFlags)
local ServerData = require(ReplicatedStorage.Datas.ServerData)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local v = nil
local parent = script.Parent.Parent.Parent.Parent
local pivot = parent:GetPivot()
Timer.Simple(1, function()
	local v2 = FFlags:GetInstant("HauntedFuseTeaser", true) and not (ServerData.IsJumpLTMServer() or ServerData.IsDuelsServer() or ServerData.IsTsunamiServer() or Updates.Methods.IsEnabled("Update-10/03/2026"))

	if v2 ~= v then
		v = v2

		if v2 then
			parent:PivotTo(pivot)
		else
			parent:PivotTo(CFrame.new(100000, 100000, 100000))
		end
	end

	script.Parent.Text = `Coming in {TimeUtils:E((math.max(Updates.Methods.GetTimeLeft("Update-10/03/2026"), 0)))}`
end, true)