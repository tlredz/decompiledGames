return {
	Clearance = 7,
	Keys = {
		{
			Type = "Action",
			Name = "Action",
			Required = false,
			Suggester = { "Toggle", "Open", "Close" },
			Completer = function(p: string)
				if p == nil or p == "" then
					return nil
				end

				return p
			end
		}
	},
	Client = function(_, _, value: string?)
		local runtimeExplorerHooks = game.ReplicatedStorage:FindFirstChild("RuntimeExplorerHooks")

		if runtimeExplorerHooks == nil then
			error("Explorer: RuntimeExplorerHooks is missing, the RuntimeExplorer server script isn't running in this place")
		end

		local module = require(runtimeExplorerHooks)
		local v = value == nil and "toggle" or string.lower(value) or "toggle"
		local toggleTool = nil

		if v == "toggle" then
			toggleTool = module.Client.ToggleTool
		elseif v == "open" then
			toggleTool = module.Client.OpenTool
		elseif v == "close" then
			toggleTool = module.Client.CloseTool
		else
			error((`Explorer: unknown action "{v}" (Toggle, Open, Close)`))
		end

		if not pcall(toggleTool, module.Client) then
			error("Explorer: the explorer client isn't mounted for you (check RuntimeExplorer Permissions, or it's still loading)")
		end
	end
}