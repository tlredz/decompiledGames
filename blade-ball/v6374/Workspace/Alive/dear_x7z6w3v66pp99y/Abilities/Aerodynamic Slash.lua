local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local localPlayer = Players.LocalPlayer
local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator") or humanoid
local remoteFunction = Net:RemoteFunction("AerodynamicSlash")
local currentCamera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
localPlayer:WaitForChild("Upgrades"):WaitForChild(script.Name)
local track = animator:LoadAnimation(script:WaitForChild("attempt"))
local track2 = animator:LoadAnimation(script:WaitForChild("success"))
local v = false
local thread = nil
Replion.Client:AwaitReplion("Data", function(object)
	local function updateIcon()
		local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

		if not child then
			return
		end

		local attributes = child:GetAttributes()
		local v2 = object:Get({ "AbilityUpgrades", script.Name })
		local icon = attributes.Icon

		for i = 1, v2 or 0 do
			icon = attributes[`Icon{i}`] or attributes.Icon
		end

		local vector = ability:WaitForChild("Vector")
		vector.Image = icon or ""
	end

	updateIcon()
	object:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)
end)

local function ability2()
	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	v = true
	local v2 = {}

	for _, child in workspace.Alive:GetChildren() do
		v2[child.Name] = currentCamera:WorldToScreenPoint(child:GetPivot().Position)
	end

	local v3, v4 = xpcall(function()
		return remoteFunction:InvokeServer(currentCamera.CFrame, v2, { mouse.X, mouse.Y })
	end, warn)

	if v3 and v4 == false then
		v = false
		return
	end

	local v5 = AbilityUtils.playAnimationTrack(track, script.Name, 1)
	task.delay(0.8, function()
		v5(0.2)
	end)
	local v6 = 30

	if v3 and type(v4) == "number" then
		v6 = v4
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, v6)
	thread = task.delay(v6, function()
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
	task.spawn(function()
		v = false

		if thread and coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
			thread = nil
		end
	end)
end)
Net:RemoteEvent("AerodynamicSlashEvent").OnClientEvent:Connect(function()
	track:Stop(0)
	AbilityUtils.playAnimationTrack(track2, script.Name, 0.8)
end)