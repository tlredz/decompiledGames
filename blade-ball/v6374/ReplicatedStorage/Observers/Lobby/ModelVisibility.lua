local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
local Replion = require(ReplicatedStorage.Packages.Replion)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Utils = require(ReplicatedStorage.Common.Utils)
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local Policy = require(ReplicatedStorage.Shared.Policy)
local localPlayer = Players.LocalPlayer
return Observers.observeTagNoAncestry("ModelVisibility", function(instance)
	local policyInfo

	if RunService:IsClient() then
		policyInfo = Policy:GetPolicyInfo() or Policy.PolicyInfoAdded:Wait()
	else
		policyInfo = Policy:GetPolicyInfo()
	end

	if (instance:GetAttribute("HasPaidRandomItems") or instance:HasTag("HasPaidRandomItems")) and policyInfo and policyInfo.ArePaidRandomItemsRestricted then
		instance:Destroy()
		return nil
	end

	if instance:GetAttribute("ShowInLTM") and not ServerInfo.isMedalServer() then
		if not ServerInfo.isLTMServer() then
			instance:Destroy()
		end

		return nil
	elseif instance:GetAttribute("ShowInLTM") and not ServerInfo.isMedalServer() then
		if not ServerInfo.isLTMServer() then
			instance:Destroy()
		end

		return nil
	else
		if instance:GetAttribute("HideInElemental") and ServerInfo.isElementalServer() or instance:GetAttribute("HideInLTM") and ServerInfo.isLTMServer() or instance:GetAttribute("HideInTutorial") and ServerInfo.isTutorialServer() or instance:GetAttribute("HideInNewPlayerLobby") and (ServerInfo.isNewPlayerLobbyServer() or ServerInfo.isNewPlayerLobbyTestServer()) or instance:GetAttribute("HideInRanked") and ServerInfo.isRankedMatchServer() or instance:GetAttribute("HideInTest") and ServerInfo.isTestGame() or (instance:GetAttribute("HideInDuelMatch") or instance:HasTag("HideInDuelMatch")) and ServerInfo.isDuelMatchServer() or instance:GetAttribute("HideInTournamentEvent") and ServerInfo.isTournamentEventServer() or (instance:GetAttribute("HideInMedal") or instance:HasTag("HideInMedal")) and ServerInfo.isMedalServer() or (instance:GetAttribute("HideInBossFight") or instance:HasTag("HideInBossFight")) and ServerInfo.isBossFightServer() or (instance:GetAttribute("HideInRegionalTournament") or instance:HasTag("HideInRegionalTournament")) and ServerInfo.isRegionalTournamentMatch() or (instance:GetAttribute("HideInRBBattles") or instance:HasTag("HideInRBBattles")) and ServerInfo.isRBBattlesServer() or instance:GetAttribute("HideModel") or instance:GetAttribute("HideInTradingPlaza") and ServerInfo.isTradingPlazaServer() or instance:GetAttribute("HideInDuelLobby") and ServerInfo.isDuelLobbyServer() then
			instance:Destroy()
			return nil
		end

		local v = Replion.Client:WaitReplion("Data")

		if not v then
			return nil
		end

		local maid = Trove.new()
		local time = instance:GetAttribute("Time")
		maid:Add(instance:GetAttributeChangedSignal("Time"):Connect(function()
			time = instance:GetAttribute("Time")
		end))
		local wins = instance:GetAttribute("Wins")
		maid:Add(instance:GetAttributeChangedSignal("Wins"):Connect(function()
			wins = instance:GetAttribute("Wins")
		end))
		local kills = instance:GetAttribute("Kills")
		maid:Add(instance:GetAttributeChangedSignal("Kills"):Connect(function()
			kills = instance:GetAttribute("Kills")
		end))
		local tournamentTickets = instance:GetAttribute("TournamentTickets")
		maid:Add(instance:GetAttributeChangedSignal("TournamentTickets"):Connect(function()
			tournamentTickets = instance:GetAttribute("TournamentTickets")
		end))
		local startTime = instance:GetAttribute("StartTime")
		maid:Add(instance:GetAttributeChangedSignal("StartTime"):Connect(function()
			startTime = instance:GetAttribute("StartTime")
		end))
		local endTime = instance:GetAttribute("EndTime")
		maid:Add(instance:GetAttributeChangedSignal("EndTime"):Connect(function()
			endTime = instance:GetAttribute("EndTime")
		end))
		local attributesByAttributeName = {}
		local needPlayerAttribute = instance:GetAttribute("NeedPlayerAttribute")

		local function updateAttributes()
			if not needPlayerAttribute then
				return
			end

			table.clear(attributesByAttributeName)
			local v2 = string.split(needPlayerAttribute, ";")

			for _, attributeName in v2 do
				if instance:GetAttribute(attributeName) ~= nil then
					attributesByAttributeName[attributeName] = instance:GetAttribute(attributeName)
				end
			end
		end

		updateAttributes()
		maid:Add(instance:GetAttributeChangedSignal("NeedPlayerAttribute"):Connect(function()
			needPlayerAttribute = instance:GetAttribute("NeedPlayerAttribute")
			updateAttributes()
		end))
		local parent = instance.Parent

		local function updateParent()
			local v2 = wins

			if v2 then
				local v3 = v:Get("TotalStats.Wins") or 0
				v2 = wins <= v3
			end

			local v3 = kills

			if v3 then
				local v4 = v:Get("TotalStats.Kills") or 0
				v3 = kills <= v4
			end

			local v4 = tournamentTickets

			if v4 then
				local tournamentTickets2 = v:Get("TournamentTickets") or 0
				v4 = tournamentTickets <= tournamentTickets2
			end

			local v5 = time and (v:Get("TimePlayed") or 0) + (workspace:GetServerTimeNow() - (localPlayer:GetAttribute("JoinedTimestamp") or 0)) >= tonumber(time)
			local flag = true

			if needPlayerAttribute then
				for attributeName, v7 in attributesByAttributeName do
					if localPlayer:GetAttribute(attributeName) == v7 then
						continue
					end

					flag = false
					break
				end
			end

			if not v2 and not v3 and not v5 and not v4 and (wins or v3 or time or tournamentTickets) or endTime and not (workspace:GetServerTimeNow() < endTime) then
				instance.Parent = ReplicatedStorage
			elseif startTime then
				local serverTimeNow = workspace:GetServerTimeNow()

				if not (startTime <= serverTimeNow) then
					instance.Parent = ReplicatedStorage
				elseif flag then
					instance.Parent = parent
				else
					instance.Parent = ReplicatedStorage
				end
			elseif flag then
				instance.Parent = parent
			else
				instance.Parent = ReplicatedStorage
			end
		end

		maid:Add(Utils.Thread.Every(1, updateParent))
		return function()
			maid:Destroy()
		end
	end
end)