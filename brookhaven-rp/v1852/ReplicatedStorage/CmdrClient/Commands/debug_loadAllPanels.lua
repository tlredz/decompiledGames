return {
	Name = "debug_loadAllPanels",
	Aliases = {},
	Description = "Loads all panels for the sender",
	Group = "Debug",
	Args = {},
	ClientRun = function(object)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local LazyPanels = require(ReplicatedStorage.Modules.Client.UI.LazyPanels)
		local PanelController = require(ReplicatedStorage.Modules.Client.UI.PanelController)

		for k, panel in LazyPanels.Panels do
			for k2, _ in panel do
				if PanelController.LoadLazy(k, k2, false) then
					object:Reply((`Loaded panel {k2} in context {k}`))
				end
			end
		end

		return "Loaded all panels"
	end
}