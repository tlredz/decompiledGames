while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local GuiHandler = require(game.ReplicatedStorage.ClientGameModules.GuiHandler)
script.Parent.Activated:Connect(function()
	GuiHandler:Open("PlaystationPack")
end)