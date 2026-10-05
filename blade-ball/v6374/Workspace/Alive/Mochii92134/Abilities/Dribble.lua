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
local currentCamera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local AbilityUtils = require(shared.AbilityUtils)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Utils = require(common.Utils)
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local hotbar = playerGui:WaitForChild("Hotbar")
local vector = hotbar:WaitForChild("Ability"):WaitForChild("Vector")
local v = Replion.Client:WaitReplion("Data")
local v2 = AbilityUtils.getAbilityUpgrade(localPlayer, name) or 0
local v3 = 2 + v2
local v4 = false

local function UpdateIcon()
	local v5 = v:Get({ "AbilityUpgrades", name }) or 0
	v3 = v5 + 2
	local child = misc.DataAbilities:FindFirstChild(name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local icon = attributes.Icon

	for i = 1, v5 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	vector.Image = icon or ""
end

UpdateIcon()
v:OnChange({ "AbilityUpgrades", name }, function()
	UpdateIcon()
end)

local function updateRemainingLabel(p)
	local counts = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("ready"):WaitForChild("counts")

	if counts then
		counts.Text = tostring(p)
	end
end

task.defer(updateRemainingLabel, v3)
workspace.Dead.ChildAdded:Connect(function(child)
	if child == localPlayer.Character then
		v2 = AbilityUtils.getAbilityUpgrade(localPlayer, name) or 0
		v3 = 2 + v2
	end
end)
remotes.ParrySuccess.OnClientEvent:Connect(function()
	task.wait(0.5)
	flag = false
end)

local function ability()
	if v3 <= 0 then
		misc.error:Play()
		return
	end

	if character.Parent ~= workspace.Alive or hotbar.Ability.Red.Visible ~= false or flag then
		return
	end

	flag = true
	thread = task.delay(1, function()
		flag = false
		thread = nil
	end)
	v2 = AbilityUtils.getAbilityUpgrade(localPlayer, name) or 0
	v3 -= 1
	task.defer(updateRemainingLabel, v3)
	task.spawn(function()
		v4 = true
		task.wait(13.5)
		v4 = false
		v3 += 1
		v3 = math.clamp(v3, 0, 2 + v2)
		task.defer(updateRemainingLabel, v3)
		remotes.VisualBindableCD:Fire(false, true, 0.01)
	end)
	remoteFunction:InvokeServer(name, currentCamera.CFrame)
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
remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)