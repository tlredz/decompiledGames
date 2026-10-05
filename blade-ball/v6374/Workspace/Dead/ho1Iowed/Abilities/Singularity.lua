game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local controllers = ReplicatedStorage:WaitForChild("Controllers")
local packages = ReplicatedStorage:WaitForChild("Packages")
local shared = ReplicatedStorage:WaitForChild("Shared")
local name = script.Name
local Abilities = require(shared.Abilities)
local Net = require(packages.Net)
local NotificationController = require(controllers.NotificationController)
local Replion = require(packages.Replion)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local SettingsController = require(controllers.SettingsController)
local Utils = require(ReplicatedStorage.Common.Utils)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
character:WaitForChild("Humanoid")
local flag = false
local thread = nil
local v = nil
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
local v2 = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v3 = v2:Get({ "AbilityUpgrades", script.Name })
	local icon = attributes.Icon

	for i = 1, v3 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	ability.Vector.Image = icon or ""
end

task.spawn(updateIcon)
v2:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)

-- equivalent calls inferred from this helper; original call sites unknown
local function getRank()
	if v then
		return v
	end

	local success, rankInGroup = pcall(localPlayer.GetRankInGroup, localPlayer, game.CreatorId)

	if success then
		v = rankInGroup
	end

	return v or 0
end

local function ability2()
	if flag then
		return
	end

	if ServerInfo.isTestGame() then
		local rank = getRank() -- equivalent call inferred; original call site unknown

		if rank < Utils.FFlag.GetInstantFFlag("SingulariyyMinGroupRank", 4) then
			ReplicatedStorage.Misc.error:Play()
			NotificationController:SendNotification("This ability is currently disabled!")
			return
		end
	end

	if character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)

	if not remoteFunction:InvokeServer(name) then
		flag = false
		return
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
	task.wait(0.25)

	if character:GetAttribute("IS_EVENT_SINGULARITY") then
		repeat
			task.wait()
		until not (character.Parent and character:GetAttribute("IS_EVENT_SINGULARITY") and script.Parent and script.Enabled)
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
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)