local Server = require(game.ReplicatedStorage.Modules.Server)
local UI = require(game.ReplicatedStorage.Modules.UI)
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local button = parent.Button

if Server:IsAdultServer() then
	script.Parent.Button.Text = "Regular Servers"
	script.Parent.ActiveColor.Color = script.Regular.Color
end

UI:Bind(button)
UI:AddShadowOnHover(parent)
button.MouseButton1Click:Connect(function()
	localPlayer.PlayerGui.Prompts.AdultServer.Visible = true
end)