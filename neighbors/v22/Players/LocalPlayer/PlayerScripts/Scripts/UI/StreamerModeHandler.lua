local Players = game:GetService("Players")
game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local v = nil

local function update()
	v = localPlayer:GetAttribute("StreamerMode") == nil or localPlayer:GetAttribute("StreamerMode")
	pcall(function()
		game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not v)
	end)
end

localPlayer:GetAttributeChangedSignal("StreamerMode"):Connect(update)