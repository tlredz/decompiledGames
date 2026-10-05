local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
game:GetService("RunService")
local localPlayer = Players.LocalPlayer

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local parentModule = require(script.Parent)
local UseBall2 = require(ReplicatedStorage.Shared.UseBall2)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
ReplicatedStorage.Remotes.ActivateAbility.OnClientEvent:Connect(function(p, p2)
	if not UseBall2() then
		return
	end

	parentModule.activateCharacterAbility(p, true, p2)
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not UseBall2() or gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		parentModule.activateCharacterAbility(localPlayer.Character, nil, nil, {
			inputType = "Input"
		})
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(function()
	if not UseBall2() then
		return
	end

	parentModule.activateCharacterAbility(localPlayer.Character, nil, nil, {
		inputType = "ButtonPress"
	})
end)
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")

-- equivalent calls inferred from this helper; original call sites unknown
local function update()
	if not UseBall2() then
		return
	end

	local characterAbility = parentModule.getCharacterAbility(localPlayer.Character)
	local abilityInfoUnsafe = parentModule.getAbilityInfoUnsafe(characterAbility)
	vector.Image = abilityInfoUnsafe and abilityInfoUnsafe.iconId or ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function onCharacter(character)
	update() -- equivalent call inferred; original call site unknown
	parentModule.getCharacterAbilityChangedSignal(character):Connect(update)
end

if localPlayer.Character then
	onCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(onCharacter)