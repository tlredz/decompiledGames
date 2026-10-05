local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Packages.Replion)

function GetAbilityCooldownMultiplier(localPlayer)
	if RunService:IsClient() then
		localPlayer = Players.LocalPlayer
	end

	if not localPlayer then
		return 1
	end

	if workspace:GetAttribute("CurrentlySelectedMode") == "Fates" then
		if localPlayer:GetAttribute("Fates_DecreasedAbilityCooldown") then
			return 0.7
		end

		if localPlayer:GetAttribute("Fates_IncreasedAbilityCooldown") then
			return 1.4285714285714286
		end
	end

	if not v.isDungeonsMatchServer() then
		return 1
	end

	local v3

	if RunService:IsServer() then
		v3 = v2.Server:GetReplionFor(localPlayer, "Data")
	else
		v3 = v2.Client:GetReplion("Data")
	end

	if v3 then
	end

	return 1
end

return GetAbilityCooldownMultiplier