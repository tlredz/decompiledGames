local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AdminPermissions = require(ReplicatedStorage._FRAMEWORK.Features.Admins.AdminPermissions)
AdminPermissions.linkCommandToPermission("movedebug", "cmdr")
return {
	Name = "movedebug",
	Aliases = { "raydebug", "mvdebug" },
	Description = "Toggle the movement raycast viewer: wall climb and wall ride probes drawn as parts (green = miss, red = hit).",
	Group = "Debug",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Description = "true = draw the probes, false = hide them. Omit to toggle.",
			Optional = true
		}
	},
	ClientRun = function(_, p)
		local MovementDebug = require(ReplicatedStorage._FRAMEWORK.Features.MovementDebug)

		if p == nil then
			p = MovementDebug.toggle()
		else
			MovementDebug.setEnabled(p)
		end

		if p then
			return "Movement raycast viewer: on"
		end

		return "Movement raycast viewer: off"
	end
}