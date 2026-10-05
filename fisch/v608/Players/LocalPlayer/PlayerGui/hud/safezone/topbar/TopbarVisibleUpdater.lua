local ReplicatedStorage = game:GetService("ReplicatedStorage")
local legacyUiLoader = require(ReplicatedStorage.client.legacy.legacyUiLoader)
script.Parent.Interactable = legacyUiLoader.PlayerGui.backpack.Enabled
legacyUiLoader.PlayerGui.backpack:GetPropertyChangedSignal("Enabled"):Connect(function()
	script.Parent.Interactable = legacyUiLoader.PlayerGui.backpack.Enabled
end)