local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
require(ReplicatedStorage.Modules.Stats)
local localPlayer = Players.LocalPlayer
local prompts2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Prompts2")
local parent = script.Parent
local header = parent.Header
local bottom = parent.Inner.Bottom
local invite = header.Content.Invite

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCount()
	invite.Label.Text = localPlayer:GetAttribute("MatchRequestInvites") or 0
	bottom.RequestQueue.Button.Text = `Request Match ({localPlayer:GetAttribute("MatchRequestInvites") or 0})`
end

invite.Buy.Button.Activated:Connect(function()
	prompts2.PurchaseInvite.Visible = true
end)
UI:AddShadowOnHover(invite.Buy)
UI:Bind(invite.Buy.Button)
localPlayer:GetAttributeChangedSignal("MatchRequestInvites"):Connect(updateCount)
updateCount() -- equivalent call inferred; original call site unknown