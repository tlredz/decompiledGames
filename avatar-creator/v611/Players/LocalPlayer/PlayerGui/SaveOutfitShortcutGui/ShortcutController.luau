local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local current = playerGui:WaitForChild("WearingGui").Root.Panel.Current
local robloxSaveOutfitGui = playerGui:WaitForChild("RobloxSaveOutfitGui")
current:WaitForChild("SaveOutfit").Activated:Connect(function()
	MenuFade.Set(robloxSaveOutfitGui, "Enabled", true)
end)