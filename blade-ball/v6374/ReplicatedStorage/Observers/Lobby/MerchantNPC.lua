local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Observers = require(ReplicatedStorage.Packages.Observers)
local MerchantShopData = require(ReplicatedStorage.Shared.Merchant.MerchantShopData)
local Replion = require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local ReplionUtils = require(ReplicatedStorage.Shared.ReplionUtils)
local Utils = require(ReplicatedStorage.Common.Utils)
return Observers.observeTagNoAncestry("MerchantNPC", function(instance)
	if not ReplicatedStorage.FeaturesToggle.Merchant.Value then
		task.defer(instance.Destroy, instance)
		return
	end

	local v = Replion.Client:WaitReplion("MerchantShop")
	local merchant = instance.Merchant
	local time = merchant.HumanoidRootPart.BillboardGui.Timer.Time

	if not v then
		return
	end

	if ServerInfo.isTutorialServer() or ServerInfo.isNewPlayerLobbyServer() then
		instance:SetAttribute("EndTime", 0)
		return
	end

	local connection = ReplionUtils.observeReplionPath(v, "Active", function(p)
		instance:SetAttribute("EndTime", p and 1e999 or 0)

		if p then
			local items = v:Get("Items") or {}
			local item = items[#items]
			local v2 = item and MerchantShopData.Items[#items][item.ItemID]

			if v2 then
				local v3

				if v2.Reward.Type == "Sword" then
					v3 = v2.Reward.Value
				else
					v3 = MerchantShopData.DefaultNPCSword
				end

				merchant:SetAttribute("LobbySwordName", v3)
				merchant:AddTag("GiveSwordNPC")
			end
		end
	end)
	Utils.Thread.Every(1, function()
		local v2 = v:Get("ArrivalTime") + MerchantShopData.Duration - workspace:GetServerTimeNow()
		time.Text = Utils.ValueConvertor:FormatTimeHHMMSS(v2)
	end)
	return function()
		if connection then
			connection:Disconnect()
		end
	end
end)