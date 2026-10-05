return {
	Name = "krender",
	Aliases = { "keycaprender", "krdrender" },
	Description = "Enable/disable client keycap MeshPart rendering (debug). Omit arg to toggle.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "boolean",
			Name = "enabled",
			Description = "true = render keycaps, false = unload all live keycaps (records stay).",
			Optional = true
		}
	},
	ClientRun = function(_, p)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local KeycapRenderDebug = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("KeycapsRendering"):WaitForChild("KeycapRenderDebug"))

		if KeycapRenderDebug.SetRenderingEnabled(p) then
			return "Keycap rendering: ON"
		end

		return "Keycap rendering: OFF"
	end
}