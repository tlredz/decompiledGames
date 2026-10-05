local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
require(ReplicatedStorage.Common.Utils)
local PolicyService = game:GetService("PolicyService")
return Observers.observeTagNoAncestry("ShowOnPolicyDisabled", function(instance)
	local success, result = pcall(function()
		return PolicyService:GetPolicyInfoForPlayerAsync(Players.LocalPlayer)
	end)

	if not (success and result) then
		instance.Visible = false
		return nil
	end

	if not result then
		return nil
	end

	local policyType = instance:GetAttribute("PolicyType") or "ArePaidRandomItemsRestricted"

	if result[policyType] == nil then
		warn((`Invalid PolicyType "{policyType}" on {instance:GetFullName()}`))
	end

	instance.Visible = result[policyType] == true
	return nil
end)