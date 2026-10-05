game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local _ = ReplicatedStorage.Assets
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local name = script.Name
local Abilities = require(shared.Abilities)
require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
localPlayer:WaitForChild("Upgrades")
local flag = false
local mouseButton2 = Enum.UserInputType.MouseButton2
local thread = nil
local v = false
local flag2 = false
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local v2 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v3 = v2:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v3 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v2:OnChange({ "AbilityUpgrades", name }, updateIcon)

local function activateBasic()
	if flag or not workspace:GetAttribute("GameActive") or (character.Parent ~= workspace.Alive or ability.Red.Visible ~= false) then
		return
	end

	if character:GetAttribute("Dead") then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, name)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	ReplicatedStorage.Remotes.PlrBunnyLeaped:FireServer()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
end

local function activateHop(flag3: boolean)
	if flag or not workspace:GetAttribute("GameActive") or (character.Parent ~= workspace.Alive or ability.Red.Visible ~= false) then
		return
	end

	if character:GetAttribute("Dead") then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, name)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	ReplicatedStorage.Remotes.PlrBunnyLeaped:FireServer(flag3)
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
end

local function activateSlam()
	if not character:GetAttribute("CAN_BUNNY_SLAM") or not workspace:GetAttribute("GameActive") or (character.Parent ~= workspace.Alive or ability.Red.Visible ~= false) then
		return
	end

	if character:GetAttribute("Dead") then
		return
	end

	ReplicatedStorage.Remotes.PlrBunnyCancelled:FireServer()
end

local function ability2(flag3: boolean)
	if v2:Get({ "AbilityUpgrades", name }) < 1 then
		if flag3 then
			activateBasic()
		end
	elseif flag3 then
		v = false
		flag2 = true
		task.wait(0.1)
		flag2 = false
		activateHop(v)
	elseif flag2 then
		v = true
	else
		activateSlam()
	end
end

local v3 = true
script.Destroying:Connect(function()
	v3 = false

	if thread then
		Utils.Thread.SafeCancel(thread)
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2(true)
	end
end)
UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		if v2:Get({ "AbilityUpgrades", name }) < 1 then
			return
		end

		if flag2 then
			v = true
		else
			activateSlam()
		end
	end
end)
ReplicatedStorage.Remotes.AbilityButtonHold.Event:Connect(function(p)
	if p == nil then
		return
	end

	ability2(p)
end)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
ReplicatedStorage.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)