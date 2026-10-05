local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Utils = require(ReplicatedStorage.Common.Utils)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
local remoteFunction = Net:RemoteFunction("WaterDragon")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local ability = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local child = localPlayer:WaitForChild("Upgrades"):WaitForChild(script.Name)
local v = false
local thread = nil

local function getMaxUsesLeft()
	return 2 + child.Value
end

local waterDragonUses = character:GetAttribute("WaterDragonUses") or 2 + child.Value
Replion.Client:AwaitReplion("Data", function(object)
	local function updateIcon()
		local child2 = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

		if not child2 then
			return
		end

		local attributes = child2:GetAttributes()
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

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRemainingLabel()
	local hotbar = playerGui:FindFirstChild("Hotbar")
	local ability2 = hotbar and hotbar:FindFirstChild("Ability")
	local ready = ability2 and ability2:FindFirstChild("ready")
	local counts = ready and ready:FindFirstChild("counts")

	if counts then
		counts.Text = tostring(waterDragonUses)
	end
end

updateRemainingLabel() -- equivalent call inferred; original call site unknown

local function ability2()
	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	if waterDragonUses <= 0 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	local children = workspace.Balls:GetChildren()

	if #children < 1 then
		ReplicatedStorage.Misc.error:Play()
		return
	end

	for _, v2 in children do
		if not v2:GetAttribute("realBall") or v2:GetAttribute("target") then
			continue
		end

		ReplicatedStorage.Misc.error:Play()
		return
	end

	v = true
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1)
	thread = task.delay(1, function()
		v = false
	end)
	waterDragonUses -= 1
	updateRemainingLabel() -- equivalent call inferred; original call site unknown
	xpcall(function()
		remoteFunction:InvokeServer()
	end, warn)
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0.05)
	waterDragonUses = math.clamp(waterDragonUses + 1, 0, 2 + child.Value)
	updateRemainingLabel() -- equivalent call inferred; original call site unknown
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
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)