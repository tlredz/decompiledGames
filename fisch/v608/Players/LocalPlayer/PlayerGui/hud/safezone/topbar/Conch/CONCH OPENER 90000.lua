local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local conch_standalone = require(ReplicatedStorage.packages.conch_standalone)
script.Parent.Activated:Connect(function()
	local v = not conch_standalone.ui.opened()
	conch_standalone.ui.opened(v)
	conch_standalone.ui.focused(v)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	local v = UserInputService.PreferredInput ~= Enum.PreferredInput.KeyboardAndMouse
	local v2 = localPlayer:GetAttribute("FullConchAccess") ~= nil
	local v3 = script.Parent.Parent:FindFirstChild("Admin") == nil
	script.Parent.Visible = v2 and v and v3
end

UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateVisibility)
localPlayer:GetAttributeChangedSignal("FullConchAccess"):Connect(updateVisibility)
script.Parent.Parent.ChildAdded:Connect(updateVisibility)
updateVisibility() -- equivalent call inferred; original call site unknown