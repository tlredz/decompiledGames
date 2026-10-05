local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local Net = require(ReplicatedStorage.Packages.Net)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
local v = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local remoteEvent = Net:RemoteEvent("PlayBotParticles")
local vector2 = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""

local function ability()
	if localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false or (v or not character:IsDescendantOf(workspace.Alive)) then
		return
	end

	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	v = true
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	ReplicatedStorage.Remotes.BotAbility:FireServer()
	thread = task.delay(abilityCooldown, function()
		v = false
		thread = nil
	end)
end

local function getParticleLifetime(folder)
	local max = -1e999

	for _, emitter in ipairs(folder:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") and max < emitter.Lifetime.Max then
			max = emitter.Lifetime.Max
		end
	end

	return max
end

local function playVFXFromContainer(child, p: number, cFrame: CFrame)
	local raycastParams

	if child:FindFirstChild("GROUND", true) then
		raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.IgnoreWater = true
		raycastParams.RespectCanCollide = true
		raycastParams.FilterDescendantsInstances = { workspace:WaitForChild("Map") }
	end

	local particleLifetime = getParticleLifetime(child)
	local clone = child:Clone()
	clone.CFrame = cFrame
	clone.Parent = workspace.CurrentCamera

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "GROUND" then
			local raycastResult

			if raycastParams then
				raycastResult = workspace:Raycast(cFrame.Position, createVector(-0, -100, -0), raycastParams)
			end

			if raycastResult then
				descendant.Position = raycastResult.Position
			end
		elseif descendant:IsA("ParticleEmitter") then
			local emitCount = descendant:GetAttribute("EmitCount") or 0
			local emitDelay = descendant:GetAttribute("EmitDelay") or 0

			if emitDelay > 0 then
				local v2 = descendant
				local v3 = emitCount
				task.delay(emitDelay, function()
					v2:Emit(v3)
				end)
			else
				descendant:Emit(emitCount)
			end
		end
	end

	Debris:AddItem(clone, p)
	return particleLifetime
end

ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

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
remoteEvent.OnClientEvent:Connect(function(childName: string, p: number, cframe: CFrame)
	local child = ReplicatedStorage.Assets.Abilities[script.Name]:FindFirstChild(childName)

	if child then
		playVFXFromContainer(child, p, cframe)
	end
end)