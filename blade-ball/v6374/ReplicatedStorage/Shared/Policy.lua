local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("Players")
local RunService = game:GetService("RunService")
local PolicyService = game:GetService("PolicyService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Promise)
local v2 = require3(ReplicatedStorage2.Packages.Signal)
local v3 = {
	AreAdsAllowed = false,
	ArePaidRandomItemsRestricted = false,
	AllowedExternalLinkReferences = 0,
	IsPaidItemTradingAllowed = true,
	IsSubjectToChinaPolicies = false,
	USING_DEFAULT_POLICY = true
}
v3.AllowedExternalLinkReferences = {}
local Policy = {
	PolicyInfoAdded = v2.new()
}
local promisify = v.promisify(function(p)
	return PolicyService:GetPolicyInfoForPlayerAsync(p)
end)

function Policy.GetPolicyInfo(_)
	return v3
end

function Policy:GetPlayerPolicyInfo(p)
	return v.retryWithDelay(promisify, 10, 5, p)
end

if RunService:IsClient() then
	Policy:GetPlayerPolicyInfo(Players.LocalPlayer):andThen(function(p)
		v3 = p
		Policy.PolicyInfoAdded:Fire(p)
	end):catch(function(p: string)
		warn("[Policy] Failed to get LocalPlayer policy! Error: " .. p)
	end)
end

return Policy