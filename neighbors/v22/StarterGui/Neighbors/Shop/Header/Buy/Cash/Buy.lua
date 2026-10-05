local UI = require(game.ReplicatedStorage.Modules.UI)
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
UI:AddShadowOnHover(parent)
UI:Bind(parent)
parent.MouseButton1Click:Connect(function()
	local shop = localPlayer.PlayerGui.Neighbors.Shop
	shop.Pages.SetPage:Fire(shop.Pages.Robux)
	shop.Pages.Robux.CanvasPosition = Vector2.new(0, 0)
end)