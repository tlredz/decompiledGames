local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientModulesLoaded") do
	workspace:GetAttributeChangedSignal("ClientModulesLoaded"):Wait()
end

local LTM = require(ReplicatedStorage.Shared.LTM)
local currentLTM = LTM.getCurrentLTM()
local ServerInfo = require(ReplicatedStorage.ServerInfo)

if ServerInfo.isLTMServer() and currentLTM and currentLTM.Id == "Flying" then
	return
end

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character
local red = localPlayer.PlayerGui:WaitForChild("Hotbar").Ability.Red
red.Visible = false

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	red.Visible = character and (character:GetAttribute("PULSED") and true or false)
end

ReplicatedStorage.Remotes.ClientPulse.OnClientEvent:Connect(function(duration)
	if localPlayer.Character then
		red.Visible = true
		task.wait(duration)
		update() -- equivalent call inferred; original call site unknown
	end
end)
character:GetAttributeChangedSignal("PULSED"):Connect(update)
update() -- equivalent call inferred; original call site unknown