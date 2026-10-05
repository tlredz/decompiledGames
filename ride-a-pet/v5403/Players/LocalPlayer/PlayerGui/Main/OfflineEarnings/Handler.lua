local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIController = require(ReplicatedStorage2:WaitForChild("UIController"))
local localPlayer = Players.LocalPlayer
local String = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("String"))
local Monetization = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("Monetization"))
local Monetization2 = require(ReplicatedStorage2:WaitForChild("GameData"):WaitForChild("Monetization"))
local offlineEarnings = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("OfflineEarnings")
local parent = script.Parent
local cashAmount = parent:WaitForChild("CashAmount")
local close = parent:WaitForChild("Close")
local claim = parent:WaitForChild("Claim")
local x10OfflineCash = parent:WaitForChild("x10OfflineCash")
parent.Visible = false

local function ClaimAndClose()
	offlineEarnings:FireServer()
	UIController.close(parent)
end

GamepadUI.Watch(parent, ClaimAndClose, close)
close.Activated:Connect(ClaimAndClose)
claim.Activated:Connect(ClaimAndClose)
x10OfflineCash.Activated:Connect(function()
	local x10OfflineCash2 = Monetization2.x10OfflineCash

	if x10OfflineCash2 then
		Monetization:OpenBuyPrompt(localPlayer, x10OfflineCash2)
	end
end)
offlineEarnings.OnClientEvent:Connect(function(value)
	if typeof(value) == "number" then
		cashAmount.Text = String:FormatCurrency(value)
		UIController.open(parent)
	elseif value == "Claimed" then
		UIController.close(parent)
	end
end)