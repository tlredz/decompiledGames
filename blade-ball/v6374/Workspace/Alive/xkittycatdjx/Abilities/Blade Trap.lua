local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local remoteFunction = Net:RemoteFunction("BladeTrap")
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
localPlayer:WaitForChild("Upgrades"):WaitForChild(script.Name)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
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

	local v2 = workspace.Map:GetChildren()[1]
	local bottomCircle = v2 and (v2:FindFirstChild("BottomCircle") or v2:FindFirstChild("BALLSPAWN"))

	if bottomCircle and (character:GetPivot().Position - createVector(0, 2, 0) - bottomCircle.Position).Magnitude <= 10 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	if humanoid.FloorMaterial == Enum.Material.Air then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	v = true
	local v3, v4 = xpcall(function()
		return remoteFunction:InvokeServer()
	end, warn)

	if v3 and v4 == false then
		v = false
		return
	end

	local abilityCooldown = Abilities.getAbilityCooldown(nil, script.Name)

	if v3 and type(v4) == "number" then
		abilityCooldown = v4
	end

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
	task.spawn(function()
		v = false

		if thread and coroutine.status(thread) == "suspended" then
			pcall(task.cancel, thread)
			thread = nil
		end
	end)
end)