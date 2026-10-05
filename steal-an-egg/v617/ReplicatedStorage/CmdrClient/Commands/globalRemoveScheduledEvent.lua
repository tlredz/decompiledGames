game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
return {
	Name = "globalRemoveScheduledEvent",
	Description = "Schedules an event in all servers",
	Group = "Moderator",
	Args = { function(p)
			local v

			if RunService:IsServer() then
				local AdminAbuseService = require(ServerScriptService.Controllers.AdminAbuseService)
				v = AdminAbuseService.GetScheduledEvents()
			else
				local ReplicatedStorage = game:GetService("ReplicatedStorage")
				v = require(ReplicatedStorage.Shared.Remotes).LiveEvents.FetchScheduled:InvokeServer()
			end

			local v2 = {}

			for k in v do
				table.insert(v2, k)
			end

			return {
				Type = p.Cmdr.Util.MakeEnumType("scheduleEventKey", v2),
				Name = "ScheduledEventKey"
			}
		end }
}