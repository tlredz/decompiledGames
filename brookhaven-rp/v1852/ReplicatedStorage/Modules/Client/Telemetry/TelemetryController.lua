local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local TelemetryController = {}

function TelemetryController.SendClientInteraction(p: string, p2)
	Remotes.fireServer("TelemetryClientInteraction", p, p2)
end

function TelemetryController.FrameworkInit() end

function TelemetryController.FrameworkStart() end

return TelemetryController