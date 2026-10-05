local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local modules = ReplicatedStorage.client.modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local localPlayer = Players.LocalPlayer
local ABNoRainController = {
	Start = function(object)
		if legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_timesjoined").Value < 1 then
			task.defer(function()
				object:Begin()
			end)
		end
	end
}

function ABNoRainController:Begin()
	local flag = false

	local function onAttribute()
		if flag or not localPlayer:GetAttribute("FirstTimeNoRainExperiment") then
			return
		end

		flag = true
		return ABNoRainController._Effect()
	end

	if localPlayer:GetAttribute("FirstTimeNoRainExperiment") ~= nil then
		return onAttribute()
	end

	local firstTimeNoRainExperimentChangedConnection = localPlayer:GetAttributeChangedSignal("FirstTimeNoRainExperiment"):Once(onAttribute)

	local function onAnalyticsTimeoutCheck()
		if firstTimeNoRainExperimentChangedConnection then
			firstTimeNoRainExperimentChangedConnection:Disconnect()
			firstTimeNoRainExperimentChangedConnection = nil
		end
	end

	task.delay(15, onAnalyticsTimeoutCheck)
end

function ABNoRainController._Effect()
	local aBNoRainFirstTime = ReplicatedStorage.client.legacy.StarterPlayerScripts.Weather.ABNoRainFirstTime

	if not aBNoRainFirstTime then
		return
	end

	aBNoRainFirstTime.Value = true
end

return ABNoRainController