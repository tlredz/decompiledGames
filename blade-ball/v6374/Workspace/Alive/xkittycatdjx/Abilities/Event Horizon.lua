local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local common = ReplicatedStorage.Common
local controllers = ReplicatedStorage.Controllers
local misc = ReplicatedStorage.Misc
local packages = ReplicatedStorage.Packages
local remotes = ReplicatedStorage.Remotes
local shared = ReplicatedStorage.Shared
local name = script.Name
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local _ = workspace.CurrentCamera
local flag = false
local thread = nil
local Abilities = require(shared.Abilities)
require(shared.AbilityUtils)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(common.Utils)
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local hotbar = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar")
local vector = hotbar:WaitForChild("Ability"):WaitForChild("Vector")
local v = Replion.Client:WaitReplion("Data")

local function UpdateIcon()
	local child = misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v2 = v:Get({ "AbilityUpgrades", name })
	local icon = attributes.Icon

	for i = 1, v2 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	vector.Image = icon or ""
end

UpdateIcon()
v:OnChange({ "AbilityUpgrades", name }, function()
	UpdateIcon()
end)

local function ability()
	if flag or (character.Parent ~= workspace.Alive or hotbar.Ability.Red.Visible ~= false) or workspace:GetAttribute("EventHorizonInUse") then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	remoteFunction:InvokeServer(name)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)