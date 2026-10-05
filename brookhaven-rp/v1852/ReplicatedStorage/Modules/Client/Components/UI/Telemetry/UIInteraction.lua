local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "UIInteraction"
})
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:Start()
	self._Janitor:Add(self.Instance.Activated:Connect(function()
		local character = Players.LocalPlayer.Character
		local humanoid

		if character ~= nil then
			humanoid = character:FindFirstChildWhichIsA("Humanoid")
		end

		local seatPart

		if humanoid ~= nil then
			seatPart = humanoid.SeatPart
		end

		local inVehicle

		if seatPart == nil then
			inVehicle = false
		else
			inVehicle = seatPart:HasTag("TrackTimeSpentInVehicleSeat")
		end

		TelemetryController.SendClientInteraction("uiInteraction", {
			buttonName = self.Instance:GetAttribute("ButtonName"),
			inVehicle = inVehicle
		})
	end))
end

function v:Stop()
	self._Janitor:Destroy()
end

return v