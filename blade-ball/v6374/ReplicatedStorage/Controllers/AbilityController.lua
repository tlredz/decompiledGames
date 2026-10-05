local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
local v2 = require3(ReplicatedStorage2.Common.Utils)
local localPlayer = Players.LocalPlayer
local v3 = require3(ReplicatedStorage2.Packages.Replion)
local v4 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v5 = require3(ReplicatedStorage2.Controllers.SettingsController)
local client = require3(ReplicatedStorage2.Shared.Inventory).Client
local v6 = require3(ReplicatedStorage2.ServerInfo)
local v7 = require3(ReplicatedStorage2.Shared.RegionalTournament.RegionalTournamentData)
local v8 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local v9 = require3(ReplicatedStorage2.Shared.LTM)
local v10 = require3(ReplicatedStorage2.Shared.UseBall2)
local v11 = require3(ReplicatedStorage2.Shared.AbilityUtils)
local v12 = require3(ReplicatedStorage2.Shared.HuntData)
local AbilityController = {}

local function UTC()
	return workspace:GetServerTimeNow()
end

function AbilityController.IsAbilitiesBlocked(_, instance)
	return (instance and instance:GetAttribute("PULSED")) ~= nil
end

function AbilityController.IsBlockedBy(_, instance, p)
	return (instance and instance:GetAttribute((`AbilityLock_{p}`))) == true
end

function AbilityController:NotifyAbilityBlocked(value)
	local currentLTM = v9.getCurrentLTM()

	if v6.isLTMServer() and currentLTM and currentLTM.getGameMode() == "Flying" or workspace:GetAttribute("CurrentlySelectedMode") == "Hovergoal" then
		return
	end

	if v6.isNoAbilityRankedMatchServer() or v6.isDungeonsMatchServer() or v6.isDungeonsLobbyServer() then
		v4.sendNotification("Abilities are disabled in this game mode", value or 6)
	else
		v4.sendNotification("Chosen ability is disabled, please choose another", value or 6)
	end
end

function AbilityController.IsAbilityAllowed(_, p)
	if v6.isLTMServer() then
		local currentLTM = v9.getCurrentLTM()

		if currentLTM and currentLTM.AllAbilitiesDisabled and (currentLTM.Id ~= "OneAbility" or p == workspace:GetAttribute("SelectedAbility") or p == "Dash") then
			return false
		end

		return not table.find(currentLTM.getDisabledAbilities(), p)
	elseif v6.isDuelMatchServer() then
		local v13 = v3.Client:WaitReplion("DuelMatch")
		local v14

		if v13 then
			v14 = v13:Get("NoAbilities")
		end

		return v14 == false
	else
		if v6.isNoAbilityRankedMatchServer() then
			return false
		end

		if v6.isRankedMatchServer() then
			local bannedAbilities = v3.Client:WaitReplion("AbilityBanVoting"):Get("BannedAbilities") or {}
			return not table.find(bannedAbilities, p)
		end

		if v6.isHuntPrivateServer() then
			return table.find(v12.EnabledAbilities, p) ~= nil
		end

		if v6.isRegionalTournamentMatch() then
			return table.find(v7.EnabledAbilities, p) ~= nil
		end

		if v6.isTournamentEventServer() and v8.EnabledAbilities then
			return table.find(v8.EnabledAbilities, p) ~= nil or v8.ForcedAbility == p
		end

		return true
	end
end

function AbilityController:GetRemainingTrialTime(p)
	local replionFor = v3.Server:GetReplionFor(localPlayer, "Data")

	if not replionFor then
		return 0
	end

	local v13 = replionFor:Get({ "Trials", "Abilities", p })

	if v13 then
		return (math.max(0, v13 - workspace:GetServerTimeNow()))
	end

	return 0
end

function AbilityController:IsTrialActive(p)
	if v3.Server:GetReplionFor(localPlayer, "Data") then
		return self:GetRemainingTrialTime(p) > 0
	end

	return false
end

function AbilityController:SetAbility(childName)
	if not childName or v6.isElementalServer() then
		return
	end

	local v13 = v10()
	local abilities = localPlayer.Character and localPlayer.Character:FindFirstChild("Abilities")

	if not abilities then
		return false
	end

	local trainingServer = require3(ReplicatedStorage2.ServerInfo).isTrainingServer()

	if localPlayer.Character and localPlayer.Character:IsDescendantOf(workspace.Alive) and workspace:GetAttribute("CurrentlySelectedMode") ~= "Randomizer" and workspace:GetAttribute("CurrentlySelectedMode") ~= "AbilityGame" and workspace:GetAttribute("CurrentlySelectedMode") ~= "CrownClash" and not (Players.CharacterAutoLoads or trainingServer or self.AbilitiesRandomizer) then
		return
	end

	for _, script2 in pairs(abilities:GetChildren()) do
		if script2:IsA("LocalScript") then
			script2.Enabled = false
		end
	end

	local child = not v13 and abilities:FindFirstChild(childName)

	if child then
		child.Enabled = true
		ReplicatedStorage2.Remotes.kebaind:FireServer()
		return true
	end

	return false
end

function AbilityController:IsOwned(p)
	if not v3.Server:GetReplionFor(localPlayer, "Data") then
		return false
	end

	return not not self:IsUnlocked(p) and not self:IsTrialActive(p)
end

function AbilityController:IsUnlocked(p)
	return #client:FindItems("Ability", p) > 0
end

function AbilityController:GetEquipped()
	local equippedAbility = v11.getEquippedAbility(localPlayer)
	return equippedAbility and equippedAbility.Name or "Dash"
end

function AbilityController:Start()
	v3.Client:AwaitReplion("Data", function(object2)
		v2.PlayerMaids.Client.CharacterAdded:Connect(function()
			v2.PlayerMaids.Client.RespawnAbility = v2.Thread.Every(1, function()
				if AbilityController:SetAbility(self:GetEquipped()) then
					v2.PlayerMaids.Client.RespawnAbility = nil
				end
			end)
		end)
		v2.PlayerMaids.Client.AbilitySelected = v11.onEquip(localPlayer, function()
			AbilityController:SetAbility(self:GetEquipped())
		end)
		self.AbilitiesRandomizer = object2:Get("Settings.Misc.AbilitiesRandomizer.Current")
		v2.PlayerMaids.Client.AbilitiesRandomizer = object2:OnChange(
			"Settings.Misc.AbilitiesRandomizer.Current",
			function(abilitiesRandomizer)
				self.AbilitiesRandomizer = abilitiesRandomizer
			end
		)
	end)

	local function notifyBlockedAbility(p: number?)
		if v10() then
			return
		end

		local character = localPlayer.Character

		if not character then
			return
		end

		if character:GetAttribute("PULSED") and (character:GetAttribute("AbilityBlockedByLTM") or character:GetAttribute("AbilityBlockedByRanked") or character:GetAttribute("HuntPS") or character:GetAttribute("AbilityBlockedByNoAbilityDuel") or character:GetAttribute("AbilityBlockedByNoAbilityRanked") or character:GetAttribute("AbilityBlockedByDungeons") or character:GetAttribute("AbilityBlockedByRegionalTournament")) then
			self:NotifyAbilityBlocked(p)
			return true
		else
			return false
		end
	end

	ReplicatedStorage2.Remotes.AbilityButtonPress.Event:Connect(notifyBlockedAbility)
	ReplicatedStorage2.Remotes.RequestAbilityUse.OnClientEvent:Connect(function()
		ReplicatedStorage2.Remotes.AbilityButtonPress:Fire()
	end)
	v.InputBegan:Connect(function(input, gameProcessed)
		if v10() or gameProcessed then
			return
		end

		if v5:UseBind(input, "Ability") then
			notifyBlockedAbility()
		end
	end)
	task.spawn(function()
		if v10() then
			return
		end

		if not localPlayer.Character then
			localPlayer.CharacterAdded:Wait()
		end

		notifyBlockedAbility(10)

		for _ = 1, 10 do
			task.wait(0.1)

			if notifyBlockedAbility(10) then
				break
			end
		end
	end)
end

return AbilityController