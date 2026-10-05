local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local ThreadSafeTargetingHelper = require(ReplicatedStorage3.Shared.ThreadSafeTargetingHelper)
local Utils = require(ReplicatedStorage.Common.Utils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	if workspace.ShowdownActive.Value then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	local playerTeam = ThreadSafeTargetingHelper.GetPlayerTeam(localPlayer)

	if playerTeam then
		local charactersOnTeam = ThreadSafeTargetingHelper.GetCharactersOnTeam(playerTeam)
		local count = #charactersOnTeam

		for _, v in charactersOnTeam do
			if v:GetAttribute("Invisible") then
				count -= 1
			end
		end

		if count <= 1 then
			return
		end
	end

	flag = true
	local v = Abilities.getAbilityCooldown(localPlayer, script.Name) + 1
	ReplicatedStorage3.Remotes.PlrInvisibilityd:FireServer()
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, v)
	thread = task.delay(v, function()
		flag = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage3.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
ReplicatedStorage3.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)