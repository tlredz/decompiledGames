local ReplicatedStorage = game:GetService("ReplicatedStorage")
local modules = ReplicatedStorage.client.modules
local legacyLocalPlayerData = require(modules.legacyLocalPlayerData)
local Players = game:GetService("Players")
local ABResilienceController = {
	_SessionResilience = 30,
	_Eligible = false
}

function ABResilienceController.Start(_)
	if legacyLocalPlayerData.fetch():WaitForChild("Stats"):WaitForChild("tracker_timesjoined").Value < 2 then
		ABResilienceController._Eligible = true
	end
end

function ABResilienceController.GetResilienceFromAB(_)
	if not ABResilienceController._Eligible or not Players.LocalPlayer:GetAttribute("ResilienceExperiment") or ABResilienceController._SessionResilience <= 0 or ABResilienceController._SessionResilience > 30 then
		return 0
	end

	return ABResilienceController._SessionResilience
end

function ABResilienceController.OnSuccess(_)
	if not ABResilienceController._Eligible or not Players.LocalPlayer:GetAttribute("ResilienceExperiment") or ABResilienceController._SessionResilience <= 0 or ABResilienceController._SessionResilience > 30 then
		return
	end

	ABResilienceController._SessionResilience -= 5
end

return ABResilienceController