local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local parent = script.Parent

if (localPlayer.Character or localPlayer.CharacterAdded:Wait()):GetAttribute("HighlightToggle") == true then
	parent.Enabled = true
end