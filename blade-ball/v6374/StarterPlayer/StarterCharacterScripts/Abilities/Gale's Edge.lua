local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
require(ReplicatedStorage.Shared.Abilities["Gale's Edge"])
local localPlayer = Players.LocalPlayer
local humanoid = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator") or humanoid
local remoteFunction = Net:RemoteFunction("GalesEdge")
local currentCamera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
localPlayer:WaitForChild("Upgrades"):WaitForChild(script.Name)
local track = animator:LoadAnimation(script:WaitForChild("attempt"))
local flag = false
local thread = nil
Replion.Client:AwaitReplion("Data", function(object)
	local function updateIcon()
		local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

		if not child then
			return
		end

		local attributes = child:GetAttributes()
		local v = object:Get({ "AbilityUpgrades", script.Name })
		local icon = attributes.Icon

		for i = 1, v or 0 do
			icon = attributes[`Icon{i}`] or attributes.Icon
		end

		local vector = ability:WaitForChild("Vector")
		vector.Image = icon or ""
	end

	updateIcon()
	object:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)
end)
local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = "LockedParts"
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {
	workspace.Runtime,
	workspace.Alive,
	workspace.Dead,
	workspace.Balls,
	workspace.TrainingBalls
}

local function getRotationYaw()
	if localPlayer:GetAttribute("IsShiftlockActive") or UserInputService.TouchEnabled then
		return nil
	end

	local character = localPlayer.Character

	if not character then
		return nil
	end

	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local viewportPointToRay = currentCamera:ViewportPointToRay(mouse.X, mouse.Y)
	local origin = viewportPointToRay.Origin
	local v = viewportPointToRay.Direction * 100
	local raycastResult = workspace:Raycast(origin, v, raycastParams)
	local v2

	if raycastResult then
		v2 = raycastResult.Position
	else
		v2 = origin + v
	end

	local unit = (humanoidRootPart.Position - v2).Unit
	return (math.atan2(unit.X, unit.Z))
end

local function ability2(flag2: boolean?)
	if flag then
		task.spawn(function()
			remoteFunction:InvokeServer(false)
		end)
	end

	if flag or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	flag = true
	local v, v2 = xpcall(function()
		local v3

		if not flag2 then
			v3 = getRotationYaw()
		end

		return remoteFunction:InvokeServer(true, v3)
	end, warn)

	if v and v2 == false then
		flag = false
		return
	end

	local v3 = AbilityUtils.playAnimationTrack(track, script.Name, 1)
	task.delay(0.8, function()
		v3(0.2)
	end)
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)

	if v and type(v2) == "number" then
		abilityCooldown = v2
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	thread = task.delay(abilityCooldown, function()
		flag = false
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
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(function()
	ability2(true)
end)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	task.spawn(function()
		flag = false

		if thread and coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
			thread = nil
		end
	end)
end)