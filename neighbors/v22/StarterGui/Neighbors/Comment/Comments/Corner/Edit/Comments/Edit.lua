local localPlayer = game.Players.LocalPlayer
local UI = require(game.ReplicatedStorage.Modules.UI)
local parent = script.Parent
local button = parent.Button
button.MouseButton1Click:Connect(function()
	localPlayer.PlayerGui.Prompts.CommentBackground.Visible = true
end)
UI:Bind(button)
UI:AddShadowOnHover(parent)