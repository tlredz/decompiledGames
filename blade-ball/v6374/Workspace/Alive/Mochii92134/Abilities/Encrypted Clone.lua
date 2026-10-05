local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local ThreadSafeTargetingHelper = require(ReplicatedStorage.Shared.ThreadSafeTargetingHelper)
local Utils = require(ReplicatedStorage.Common.Utils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
local v = false
local thread = nil
local remoteEvent = Net:RemoteEvent("EncryptedClone")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local module = require(ReplicatedStorage.Shared.Abilities[script.Name])
local vector = ability:WaitForChild("Vector")
vector.Image = not module and "" or module.iconId

local function ability2()
	if v and character.Parent == workspace.Alive and localPlayer.Upgrades[script.Name].Value >= 1 then
		local v2 = nil

		for _, child in workspace.Alive:GetChildren() do
			if not (child:GetAttribute("IsEncryptedClone") and child:GetAttribute("EncryptedCloneOwner") == localPlayer.Name) then
				continue
			end

			v2 = child
			break
		end

		if v2 then
			remoteEvent:FireServer(true)
			return
		end
	end

	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	local v2 = nil

	for _, child in workspace.Alive:GetChildren() do
		if child:GetAttribute("IsEncryptedClone") or not ThreadSafeTargetingHelper.AreCharactersEnemies(
			character,
			child
		) then
			continue
		end

		v2 = true
		break
	end

	if not v2 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	v = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	remoteEvent:FireServer()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	thread = task.delay(abilityCooldown, function()
		v = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)