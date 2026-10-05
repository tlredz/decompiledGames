local localPlayer = game.Players.LocalPlayer
game:GetService("UserInputService")
local UI = require(game.ReplicatedStorage.Modules.UI)
local Money = require(game.ReplicatedStorage.Modules.Money)
local label = script.Parent.Label

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	label.Text = Money(localPlayer:GetAttribute("Credits") or 0, true) .. " Credits"
end

update() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("Credits"):Connect(update)
script.Parent.Visible = UI:GetDeviceType() == "Mobile"