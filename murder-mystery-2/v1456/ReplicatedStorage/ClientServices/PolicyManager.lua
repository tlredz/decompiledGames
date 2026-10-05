local PolicyManager = {}
local localPlayer = game.Players.LocalPlayer
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local v = RunService:IsStudio() and false

local function onInitialize()
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
	end)

	while not success do
		task.wait(1)
		success, result = pcall(function()
			return PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)
		end)
	end

	local v2 = v and {
		IsPaidItemTradingAllowed = false,
		ArePaidRandomItemsRestricted = true
	} or result
	PolicyManager.IsPaidItemTradingAllowed = v2.IsPaidItemTradingAllowed == true
	PolicyManager.ArePaidRandomItemsRestricted = v2.ArePaidRandomItemsRestricted == true
end

onInitialize()
return PolicyManager