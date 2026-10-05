local ReplicatedStorage = game:GetService("ReplicatedStorage")
return {
	Name = "ad_enableTelemetryDebug",
	Aliases = { "ad_debugTelemetry" },
	Description = "Enables debug visualization for ads telemetry on your client.",
	Group = "Ads",
	Args = {
		{
			Type = "boolean",
			Name = "enable",
			Description = "Whether to enable ads telemetry debug mode or not.",
			Default = true,
			Optional = true
		}
	},
	ClientRun = function(_, flag: boolean?)
		local v = flag == nil or flag
		local AdsTelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.AdsTelemetryController)
		AdsTelemetryController.SetDebugEnabled(v)
		return (`Ads complex visualization telemetry debug is now {v and "enabled" or "disabled"}`)
	end
}