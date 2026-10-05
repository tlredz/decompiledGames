game:GetService("PolicyService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("Players")
local Policy = require(ReplicatedStorage.Shared.Policy)
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTagNoAncestry("CommunityServerDisclaimer", function(instance)
	local communityServerAllowed = instance:GetAttribute("CommunityServerAllowed")
	local communityServerBanned = instance:GetAttribute("CommunityServerBanned")
	local policyInfo = Policy:GetPolicyInfo()

	if policyInfo and policyInfo.USING_DEFAULT_POLICY then
		policyInfo = Policy.PolicyInfoAdded:Wait()
	end

	if policyInfo then
		if table.find(policyInfo.AllowedExternalLinkReferences, "Discord") then
			instance.Text = communityServerAllowed
		else
			instance.Text = communityServerBanned
		end
	end

	return function()
		instance.Text = communityServerBanned
	end
end)