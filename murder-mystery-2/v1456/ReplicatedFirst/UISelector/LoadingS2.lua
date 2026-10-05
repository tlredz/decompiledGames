local localPlayer = game.Players.LocalPlayer
local loading = script:WaitForChild("Loading")
loading.Parent = localPlayer.PlayerGui
local loadingScript = loading:WaitForChild("LoadingScript")
loadingScript.Enabled = true