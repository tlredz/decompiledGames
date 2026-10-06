local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GameFlags = require(ReplicatedStorage.GameFlags)
local Net = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"))
local service = ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service")
local PlayerData = require(service:WaitForChild("PlayerData"))
local WinStreakDisplay = require(service:WaitForChild("WinStreakDisplay"))
local DevProductService = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Market"):WaitForChild("DevProductService"))
local KeepStreakService = {
	server = {}
}
local remoteEvent = Net:RemoteEvent("KeepStreakOffer")
local flag = false

function KeepStreakService.server.offer(player, p: number)
	if p < 3 or GameFlags.feature["弹保持连胜"] == false then
		return
	end

	remoteEvent:FireClient(player, p)
end

local function init()
	if flag then
		return
	end

	flag = true
	DevProductService.server.bindProduct("Keep Streak", function(p)
		local lastStreak = PlayerData.server[p.plr].lastStreak()
		WinStreakDisplay.setStreak(p.plr, lastStreak)
	end)
end

KeepStreakService.server.init = init
return KeepStreakService