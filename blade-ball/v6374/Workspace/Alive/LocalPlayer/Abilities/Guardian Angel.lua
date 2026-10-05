local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local GuardianAngel = require(ReplicatedStorage.Shared.Abilities["Guardian Angel"])
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local vector = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
vector.Image = GuardianAngel.iconId or ""

local function update()
	local guardianAngelParriesLeft = character:GetAttribute("GuardianAngelParriesLeft") or math.min(
		localPlayer.Upgrades:WaitForChild("Guardian Angel").Value,
		1
	) + 1
	local guardianAngelNextUse = character:GetAttribute("GuardianAngelNextUse")

	if guardianAngelParriesLeft <= 0 or workspace.ShowdownActive.Value and not ServerInfo.isTrainingServer() then
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
		guardianAngelParriesLeft = 0
	elseif guardianAngelNextUse then
		local v = guardianAngelNextUse - workspace:GetServerTimeNow()

		if v > 0 then
			ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, v)
		else
			ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1, true)
		end
	end

	local counts = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("ready"):WaitForChild("counts")

	if counts then
		counts.Text = tostring(guardianAngelParriesLeft)
	end
end

task.spawn(update)
workspace.ShowdownActive:GetPropertyChangedSignal("Value"):Connect(update)
character:GetAttributeChangedSignal("GuardianAngelParriesLeft"):Connect(update)
character:GetAttributeChangedSignal("GuardianAngelNextUse"):Connect(update)