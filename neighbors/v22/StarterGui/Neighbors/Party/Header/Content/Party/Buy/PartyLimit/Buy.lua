local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UI = require(ReplicatedStorage.Modules.UI)
local GamepassUtil = require(ReplicatedStorage.Modules.GamepassUtil)
local PartyClient = require(ReplicatedStorage.Modules.PartyClient)
local localPlayer = Players.LocalPlayer
local parent = script.Parent
local button = parent.Button
UI:AddShadowOnHover(parent)
UI:Bind(button)

local function update()
	local parent2 = parent
	local visible = PartyClient:IsPlayerInParty(localPlayer) or not PartyClient:IsPlayerInParty(localPlayer)

	if visible then
		local verified = localPlayer:GetAttribute("MegaParty") and localPlayer:GetAttribute("Verified")
		visible = not verified
	end

	parent2.Visible = visible
end

button.MouseButton1Click:Connect(function()
	if localPlayer:GetAttribute("Verified") then
		GamepassUtil:DisplayGamepassInfo("MegaParty")
	else
		GamepassUtil:DisplayGamepassInfo("Verified")
	end
end)
local visible2 = PartyClient:IsPlayerInParty(localPlayer) or not PartyClient:IsPlayerInParty(localPlayer)

if visible2 then
	local verified = localPlayer:GetAttribute("MegaParty") and localPlayer:GetAttribute("Verified")
	visible2 = not verified
end

parent.Visible = visible2
localPlayer:GetAttributeChangedSignal("MegaParty"):Connect(update)
localPlayer:GetAttributeChangedSignal("Verified"):Connect(update)
localPlayer:GetAttributeChangedSignal("PartyId"):Connect(update)