local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local LotUtil = require(ReplicatedStorage.Modules.Shared.Housing.LotUtil)
local PlayerBagUtil = require(ReplicatedStorage.Modules.Shared.PlayerData.PlayerBagUtil)
return {
	Click = function(interaction: string)
		local lot = PlayerBagUtil.GetPlayerBagInstance(Players.LocalPlayer, "HouseNumber").Value
		local propertyRoot = LotUtil.GetPropertyRoot(lot)

		if not propertyRoot then
			return
		end

		TelemetryController.SendClientInteraction("houseControls", {
			houseId = propertyRoot:GetDisplayName(),
			interaction = interaction,
			lot = lot
		})
	end
}