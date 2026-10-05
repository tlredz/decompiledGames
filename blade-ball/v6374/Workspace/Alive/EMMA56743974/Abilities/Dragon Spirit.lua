local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer;
(localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
game:GetService("Debris")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Replion = require(ReplicatedStorage3.Packages.Replion)
local Utils = require(ReplicatedStorage.Common.Utils)
local _ = workspace.CurrentCamera.FieldOfView
local v = false
local v2 = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local v3 = 3
local value = localPlayer:WaitForChild("Upgrades"):WaitForChild(script.Name).Value
local v4 = 2 + value
local playerGui = localPlayer:WaitForChild("PlayerGui")
local vector = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
require(ReplicatedStorage3.Shared.Abilities[script.Name])
Replion.Client:AwaitReplion("Data", function(object)
	local function updateIcon()
		local child = ReplicatedStorage3.Misc.DataAbilities:FindFirstChild(script.Name)

		if not child then
			return
		end

		local attributes = child:GetAttributes()
		local v5 = object:Get({ "AbilityUpgrades", script.Name })
		local icon = attributes.Icon

		for i = 1, v5 or 0 do
			icon = attributes["Icon" .. i] or attributes.Icon
		end

		vector.Image = icon or ""
	end

	object:OnChange({ "AbilityUpgrades", script.Name }, function()
		updateIcon()
	end)
	updateIcon()
end)

local function updateRemainingLabel(p)
	local counts = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("ready"):WaitForChild("counts")

	if counts then
		counts.Text = tostring(p)
	end
end

task.defer(updateRemainingLabel, v4)
workspace.Dead.ChildAdded:Connect(function(child)
	if child == game.Players.LocalPlayer.Character then
		value = localPlayer.Upgrades[script.Name].Value
		v4 = 2 + value
	end
end)
localPlayer.Upgrades[script.Name].Changed:Connect(function()
	v4 = localPlayer.Upgrades[script.Name].Value + 2
end)
ReplicatedStorage3.Remotes.ParrySuccess.OnClientEvent:Connect(function()
	v = false
end)

local function ability()
	if v4 <= 0 then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	local children = workspace.Balls:GetChildren()

	if #children < 1 then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	for _, v5 in next, children, nil do
		if not v5:GetAttribute("realBall") or v5:GetAttribute("target") then
			continue
		end

		ReplicatedStorage3.Misc.error:Play()
		return
	end

	if localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false or (v or v2) then
		return
	end

	v = true
	local goldenAbilities = workspace:GetAttribute("GoldenAbilities")
	local _ = workspace.ShowdownActive.Value
	v3 = 3

	if goldenAbilities then
		v3 = 0.5
		v4 = 999
	end

	local _ = localPlayer.Upgrades[script.Name].Value

	if ReplicatedStorage3.Remotes.PlrDragonSummoned:InvokeServer() then
		if v4 - 1 > 0 then
			ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, v3)
			v2 = true
			task.delay(v3, function()
				ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, 1 - v3)
				v2 = false
			end)
		else
			ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, 1)
		end

		if not goldenAbilities then
			v4 -= 1
		end

		task.defer(updateRemainingLabel, v4)
		thread = task.delay(1, function()
			v = false
			thread = nil
		end)
	end
end

ReplicatedStorage3.Remotes.SyncDragonSpirit.OnClientEvent:Connect(function(p)
	v4 = p
	task.defer(updateRemainingLabel, v4)
end)
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
	v = false

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