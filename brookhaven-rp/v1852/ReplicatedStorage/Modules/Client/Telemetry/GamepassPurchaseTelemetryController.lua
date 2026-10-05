local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetProductInfo = require(ReplicatedStorage.Modules.Shared.Utils.GetProductInfo)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
return {
	FrameworkStart = function()
		Remotes.connect("GamepassTransactionCompleted", function(purchaseId: string, p2: number)
			local v, v2 = GetProductInfo(p2, Enum.InfoType.GamePass, 0)

			if not v then
				return
			end

			TelemetryController.SendClientInteraction("clientTransactionCompleted", {
				purchaseId = purchaseId,
				PriceDiscountDetails = v2.PriceDiscountDetails or {},
				UserBasePriceInRobux = v2.UserBasePriceInRobux,
				PriceInRobux = v2.PriceInRobux
			})
		end)
	end
}