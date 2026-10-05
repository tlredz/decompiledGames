local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local controllers = ReplicatedStorage.Controllers
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local name = script.Name
local Abilities = require(shared.Abilities)
local FastUtils = require(shared.FastUtils)
local Net = require(packages.Net)
local Replion = require(packages.Replion)
local SettingsController = require(controllers.SettingsController)
local Trove = require(packages.Trove)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
character:WaitForChild("Humanoid")
local v = false
local mouseButton2 = Enum.UserInputType.MouseButton2
local thread = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local remoteEvent = Net:RemoteEvent("PhaseBypass/ApplyEffects")
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
local maid = Trove.new()

local function applyEffects()
	local cFrame = humanoidRootPart.CFrame
	local cc2 = Lighting:FindFirstChild("cc2")

	if cc2 then
		cc2.Enabled = true
	end

	local fieldOfView = workspace.CurrentCamera.FieldOfView
	FastUtils.fastTween(workspace.CurrentCamera, TweenInfo.new(0.25, Enum.EasingStyle.Linear), {
		FieldOfView = fieldOfView * 1.2
	})
	maid:Add(function()
		ReplicatedStorage.Remotes.ResetFOV:Fire(true)

		if cc2 then
			cc2.Enabled = false
		end

		if character.Parent == workspace.Alive then
			humanoidRootPart.CFrame = cFrame
		end
	end)
end

local function ability2()
	if v or character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	v = true
	Abilities.getAbilityCooldown(localPlayer, name)
	local _ = workspace.CurrentCamera.FieldOfView
	local v3, v4 = remoteFunction:InvokeServer(name)

	if not (v3 and v4 and v4.cooldown) then
		return
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, v4.cooldown)
	maid:Clean()
	thread = task.delay(v4.cooldown or 3, function()
		v = false
		thread = nil
	end)
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
ReplicatedStorage.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)
remoteEvent.OnClientEvent:Connect(applyEffects)
script.AncestryChanged:Connect(function()
	if not script:IsDescendantOf(game) then
		maid:Destroy()
	end
end)