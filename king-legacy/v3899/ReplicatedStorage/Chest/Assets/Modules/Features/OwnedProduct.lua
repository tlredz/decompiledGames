local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
return {
	IsOwned = function(_, data, p)
		local checkAwake = _G.CheckAwake

		if RunService:IsClient() then
			checkAwake = _G.CheckAwakeClient
		end

		if p == "NightBlade" then
			if data.Inventory:FindFirstChild("Night Blade") or MarketplaceService:UserOwnsGamePassAsync(
				data.UserId,
				7929804
			) then
				return true
			end
		elseif p == "FruitNotifier" then
			if checkAwake(data, "FruitNotifier") or MarketplaceService:UserOwnsGamePassAsync(data.UserId, 7936106) then
				return true
			end
		elseif p == "Conqueror" then
			if data.PlayerStats.haogamepass.Value == "HAOYOUHAVEIT" or data.PlayerStats.HAOHAKI.Value == "HAOYOUHAVEIT" or MarketplaceService:UserOwnsGamePassAsync(
				data.UserId,
				8287391
			) then
				return true
			end
		elseif p == "BeliX2" then
			if data.PlayerStats.RealBeliX2.Value == 2 or checkAwake(data, "BeliX2") or MarketplaceService:UserOwnsGamePassAsync(
				data.UserId,
				8114853
			) then
				return true
			end
		elseif p == "DropX2" then
			if data.PlayerStats.RealDropX2.Value == 2 or checkAwake(data, "DropX2") or MarketplaceService:UserOwnsGamePassAsync(
				data.UserId,
				18044132
			) then
				return true
			end
		elseif p == "LegacyPose" then
			if checkAwake(data, "LegacyPose") or MarketplaceService:UserOwnsGamePassAsync(data.UserId, 18399361) then
				return true
			end
		else
			if p ~= "CoffinBoat" then
				return
			end

			if data.PlayerStats.CoffinBoat.Value == "true" or MarketplaceService:UserOwnsGamePassAsync(
				data.UserId,
				9876237
			) then
				return true
			end
		end
	end
}