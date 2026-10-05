local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PurchasableInfoController = require(ReplicatedStorage.Modules.Client.Data.PurchasableInfoController)
local Gamepasses = require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
return {
	GetSmallIcon = function(p)
		if p == Gamepasses.VIP then
			return "rbxassetid://18248037214"
		end

		if p == Gamepasses.PREMIUM then
			return "rbxassetid://6010710098"
		end

		local gamepassInfo = PurchasableInfoController.GetGamepassInfo(p)

		if gamepassInfo == nil then
			return nil
		end

		return "rbxassetid://" .. gamepassInfo.IconImageAssetId
	end
}