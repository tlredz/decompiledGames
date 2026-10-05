local GuiService = game:GetService("GuiService")
local localPlayer = game.Players.LocalPlayer
local SFX = game.SoundService:WaitForChild("SFX")
local main = localPlayer.PlayerGui:WaitForChild("Main")
local menu = localPlayer.PlayerGui:WaitForChild("Menu")
GuiService.MenuOpened:Connect(function()
	SFX.UI.Notification:Play()
	main.Enabled = false
	menu.Enabled = true
end)
GuiService.MenuClosed:Connect(function()
	main.Enabled = true
	menu.Enabled = false
end)