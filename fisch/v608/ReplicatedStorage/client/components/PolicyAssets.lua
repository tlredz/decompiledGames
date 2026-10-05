local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.packages.Component)
local localPlayer = Players.LocalPlayer
local v = Component.new({
	Tag = "PolicyAssets",
	Ancestors = { workspace }
})
local policyInfoForPlayerAsync = PolicyService:GetPolicyInfoForPlayerAsync(localPlayer)

function v.Construct(_) end

function v.Start(p)
	if p.Instance:GetAttribute("ArePaidRandomItemsRestricted") then
		if policyInfoForPlayerAsync.ArePaidRandomItemsRestricted then
			p.Instance.Parent = nil
		end
	elseif p.Instance:GetAttribute("AreAdsAllowed") and not policyInfoForPlayerAsync.AreAdsAllowed then
		p.Instance.Parent = nil
	end
end

function v.Stop(_) end

return v