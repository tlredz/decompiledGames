return {
	Name = "krd",
	Aliases = { "kdebug", "keycapdebug" },
	Description = "Toggle the keycap render debug window (map + stats).",
	Group = "DefaultDebug",
	Args = {},
	ClientRun = function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local KeycapRenderDebug = require(ReplicatedStorage:WaitForChild("Utilities"):WaitForChild("KeycapsRendering"):WaitForChild("KeycapRenderDebug"))
		KeycapRenderDebug.Toggle()

		if KeycapRenderDebug.IsVisible() then
			return "Keycap render debug: open"
		end

		return "Keycap render debug: closed"
	end
}