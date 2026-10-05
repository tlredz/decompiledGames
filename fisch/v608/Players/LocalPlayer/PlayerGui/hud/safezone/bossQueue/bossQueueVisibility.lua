local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
script.Parent.Visible = false
localPlayer:GetAttributeChangedSignal("inBossQueue"):Connect(function()
	script.Parent.Visible = localPlayer:GetAttribute("inBossQueue")
end)