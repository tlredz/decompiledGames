local Players = game:GetService("Players")
local localPlayer = game.Players.LocalPlayer
local Icon = require(game.ReplicatedStorage.Modules:WaitForChild("Icon"))
local Money = require(game.ReplicatedStorage.Modules.Money)
local UI = require(game.ReplicatedStorage.Modules.UI)
game:GetService("UserInputService")
local v = Icon.new()
v:setOrder(10)
v:setImage("rbxassetid://15644273951")
v:oneClick()

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	v:setLabel(Money(localPlayer:GetAttribute("Credits") or 0, true) .. " Credits")
end

v:bindEvent("deselected", function()
	local shop = Players.LocalPlayer.PlayerGui.Neighbors.Shop
	shop.Visible = true
	shop.Pages.SetPage:Fire(shop.Pages.Robux)
	shop.Pages.Robux.CanvasPosition = Vector2.new(0, 0)
end)

if UI:GetDeviceType() == "Mobile" then
	v:setEnabled(false)
end

update() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("Credits"):connect(update)