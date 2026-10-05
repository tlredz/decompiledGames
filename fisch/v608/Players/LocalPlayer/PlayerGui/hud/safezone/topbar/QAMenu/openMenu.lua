local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local qAMenu = localPlayer:WaitForChild("PlayerGui"):WaitForChild("QAMenu", 1e999)
require(ReplicatedStorage.packages.conch_standalone)
script.Parent.Activated:Connect(function()
	qAMenu.menu2.Visible = not qAMenu.menu2.Visible
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	local visible = localPlayer:GetAttribute("FullConchAccess") ~= nil
	script.Parent.Visible = visible
end

localPlayer:GetAttributeChangedSignal("FullConchAccess"):Connect(updateVisibility)
updateVisibility() -- equivalent call inferred; original call site unknown