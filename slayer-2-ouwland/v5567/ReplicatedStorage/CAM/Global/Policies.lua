local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")
local RunService = game:GetService("RunService")
local Policies = {
	ArePaidRandomItemsRestricted = true,
	AllowedExternalLinkReferences = {},
	IsContentSharingAllowed = false,
	IsEligibleToPurchaseSubscription = false,
	IsPaidItemTradingAllowed = false,
	IsSubjectToChinaPolicies = false,
	CanSpin = false,
	Loaded = false,
	Test = {
		ArePaidRandomItemsRestricted = true
	}
}
local isStudio = RunService:IsStudio()

-- equivalent calls inferred from this helper; original call sites unknown
local function derive()
	Policies.CanSpin = not Policies.ArePaidRandomItemsRestricted
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTest()
	if isStudio then
		for k, v in Policies.Test do
			Policies[k] = v
		end
	end

	derive() -- equivalent call inferred; original call site unknown
end

Policies.Apply = applyTest
local fetch

fetch = function()
	local localPlayer = Players.LocalPlayer

	if localPlayer == nil then
		return
	end

	local success, policyInfoForPlayerAsync = pcall(
		PolicyService.GetPolicyInfoForPlayerAsync,
		PolicyService,
		localPlayer
	)

	if success and typeof(policyInfoForPlayerAsync) == "table" then
		for k, v in policyInfoForPlayerAsync do
			Policies[k] = v
		end

		Policies.Loaded = true
		applyTest() -- equivalent call inferred; original call site unknown
	else
		warn((`Policies: fetch failed ({tostring(policyInfoForPlayerAsync)}), retrying in {5}s`))
		task.delay(5, fetch)
	end
end

applyTest() -- equivalent call inferred; original call site unknown

if RunService:IsClient() then
	task.spawn(fetch)
end

local v = {}

function Policies.Of(p)
	local v2 = v[p]

	if v2 ~= nil then
		return v2
	end

	local success, policyInfoForPlayerAsync = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, p)

	if not success or typeof(policyInfoForPlayerAsync) ~= "table" then
		warn((`Policies: fetch failed for {p.Name} ({tostring(policyInfoForPlayerAsync)})`))
		return Policies
	end

	if isStudio then
		for k, v3 in Policies.Test do
			policyInfoForPlayerAsync[k] = v3
		end
	end

	v[p] = policyInfoForPlayerAsync
	return policyInfoForPlayerAsync
end

if RunService:IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
	end)
end

return Policies