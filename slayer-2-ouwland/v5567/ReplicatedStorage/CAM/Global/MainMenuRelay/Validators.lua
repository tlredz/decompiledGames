local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HudGrid = require(ReplicatedStorage.CAM.HudGrid)
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
local Ranked = require(ReplicatedStorage.CAM.Global.Ranked)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local Validators = {}
local isServer = RunService:IsServer()
local ServerPartyWatcher

if isServer then
	local ServerStorage = game:GetService("ServerStorage")
	ServerPartyWatcher = require(ServerStorage.SAM.Services.ServerPartyWatcher)
else
	ServerPartyWatcher = require(ReplicatedStorage.CAM.Client.Modules.PartyWatcher)
end

local id = Worlds.ByName["Main Menu"].Id

local function partySize(p)
	local v

	if isServer then
		v = ServerPartyWatcher.GetMembersInPlace(p, id)
	else
		v = ServerPartyWatcher.GetMembersInPlace(id)
	end

	return (math.max(#v, 1))
end

function Validators.HudGamemode(value: string, p, flag: boolean?)
	local v

	if typeof(value) == "string" then
		v = HudGrid.ByName[value]
	end

	if v == nil or v.Ignore == true or v.RequiredGroup ~= nil and not Worlds.MeetsRequirements(p, v) then
		return false, "Invalid gamemode"
	end

	if v.UnlockQuest ~= nil and Quests.GetPlayerQuestState(p, v.UnlockQuest) ~= "Done" then
		return false
	end

	local v2

	if isServer then
		v2 = ServerPartyWatcher.GetMembersInPlace(p, id)
	else
		v2 = ServerPartyWatcher.GetMembersInPlace(id)
	end

	if math.max(#v2, 1) > v.Players then
		return false, "Party is too large"
	end

	if flag ~= true and v.RankedOnly ~= true then
		return true
	end

	if v.Ranked ~= true then
		return false, "No ranked play in this mode"
	end

	local setting = MinigameSettings.Settings[v.Minigame]
	local ranked

	if setting ~= nil then
		ranked = setting.Ranked
	end

	if ranked == nil then
		return false, "No ranked play in this mode"
	end

	if ranked.Solo == true then
		local v3

		if isServer then
			v3 = ServerPartyWatcher.GetMembersInPlace(p, id)
		else
			v3 = ServerPartyWatcher.GetMembersInPlace(id)
		end

		if math.max(#v3, 1) > 1 then
			return false, "Ranked is played solo"
		end
	end

	local data, v3 = Utility.GetData(p)
	local reason = Ranked.Reason
	local verified = Ranked.Verified(p, v.Minigame)
	local v5

	if ranked.DodgeLocks ~= nil then
		v5 = Ranked.LockedUntil(v3)
	end

	local v6 = reason(verified, nil, v5)

	if v6 ~= nil then
		return false, v6
	end

	if value == Ranked.TOURNEY and Ranked.BucketOf(data) == nil then
		return false, "Zenith needs a Breathing or Demon Art"
	end

	return true
end

function Validators.PartyMatchMode(p)
	local v

	if isServer then
		v = ServerPartyWatcher.GetMembersInPlace(p, id)
	else
		v = ServerPartyWatcher.GetMembersInPlace(id)
	end

	local v2 = math.max(#v, 1)

	if v2 < 2 then
		return nil
	end

	local v3 = math.ceil(v2 / 2)
	local v4 = nil

	for k, v5 in HudGrid.ByName do
		if v5.PartyFriendly ~= true or v5.Ignore == true or v5.Players < v3 or not (v5.UnlockQuest == nil or Quests.GetPlayerQuestState(
			p,
			v5.UnlockQuest
		) == "Done") then
			continue
		end

		if not (v4 == nil or v5.Players < HudGrid.ByName[v4].Players) then
			continue
		end

		v4 = k
	end

	return v4
end

return Validators