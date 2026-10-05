local Network = require(game.ReplicatedStorage.Modules.Network)
local UI = require(game.ReplicatedStorage.Modules.UI)
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent
local button = parent.Button
local donation = parent.Parent.Donation
local donationHistory = parent.Parent.DonationHistory

local function update()
	parent.Visible = not (donation.Visible or donationHistory.Visible) and localPlayer.Character and localPlayer.Character:FindFirstChild("Donation Tool")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function registerCharacter(character)
	character.ChildAdded:Connect(update)
	character.ChildRemoved:Connect(update)
end

localPlayer.CharacterAdded:Connect(registerCharacter)

if localPlayer.Character then
	registerCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

donation:GetPropertyChangedSignal("Visible"):Connect(update)
donationHistory:GetPropertyChangedSignal("Visible"):Connect(update)
button.MouseButton1Click:Connect(function()
	Network:fire("RequestMyDonations")
end)
UI:AddShadowOnHover(parent)
UI:Bind(button)