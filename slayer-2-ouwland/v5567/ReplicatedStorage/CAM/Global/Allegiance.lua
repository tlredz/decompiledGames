local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local MinigameSettings = require(ReplicatedStorage.CAM.Global.MinigameSettings)
local Types = require(ReplicatedStorage.Communication.ServerAndClient.PrivateServer.Types)
local Worlds = require(ReplicatedStorage.CAM.Worlds)
local Locator = require(ReplicatedStorage.CAM.Global.Subsets.Areas.AreaLocator.Locator)
local CombatMode = require(ReplicatedStorage.CAM.Global.CombatMode)
local isServer = RunService:IsServer()
local Allegiance = {}
local pvpAttribute = Types.PvpAttribute
Allegiance.PvpPref = {
	Path = "Misc/Pvp",
	Default = true
}
local v = Worlds.ById[game.PlaceId]
local pvpSwitchWorldOff

if v == nil then
	pvpSwitchWorldOff = false
else
	pvpSwitchWorldOff = v.NoPvpSwitch == true
end

Allegiance.PvpSwitchWorldOff = pvpSwitchWorldOff
local v3 = {}

for k in string.gmatch(Allegiance.PvpPref.Path, "[^/]+") do
	table.insert(v3, k)
end

local v4 = nil

local function partyWatcher()
	if not isServer then
		return nil
	end

	if v4 ~= nil then
		return v4
	end

	local SAM = ServerStorage:FindFirstChild("SAM")
	local services = SAM and SAM:FindFirstChild("Services")
	local serverPartyWatcher = services and services:FindFirstChild("ServerPartyWatcher")

	if serverPartyWatcher == nil then
		return nil
	end

	local module = require(serverPartyWatcher)
	v4 = module
	return v4
end

local function dataRootOf(p)
	local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
	local data

	if player_Service ~= nil then
		data = player_Service:FindFirstChild("Data")
	end

	if data == nil then
		return nil
	end

	return data:FindFirstChild(p.Name) or data:FindFirstChild(p.Name .. "-Studio")
end

local function playerBehind(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter ~= nil then
		return playerFromCharacter
	end

	local clone_Owner = instance:FindFirstChild("Clone_Owner")

	if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
		return nil
	end

	return Players:FindFirstChild(clone_Owner.Value)
end

Allegiance.PlayerBehind = playerBehind

local function partyStateOf(instance)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		local clone_Owner = instance:FindFirstChild("Clone_Owner")

		if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
			playerFromCharacter = nil
		else
			playerFromCharacter = Players:FindFirstChild(clone_Owner.Value)
		end
	end

	if playerFromCharacter == nil then
		return nil, false
	end

	local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
	local data

	if player_Service ~= nil then
		data = player_Service:FindFirstChild("Data")
	end

	local v5

	if data ~= nil then
		v5 = data:FindFirstChild(playerFromCharacter.Name) or data:FindFirstChild(playerFromCharacter.Name .. "-Studio")
	end

	local partyInfo

	if v5 ~= nil then
		partyInfo = v5:FindFirstChild("partyInfo")
	end

	local partyId

	if partyInfo ~= nil then
		partyId = partyInfo:FindFirstChild("partyId")
	end

	if partyId == nil then
		local partyId2 = instance:GetAttribute("partyId")

		if type(partyId2) ~= "string" or partyId2 == "" then
			partyId2 = nil
		end

		return partyId2, instance:GetAttribute("Pvp") == true
	else
		local pvp = partyInfo:FindFirstChild("pvp")
		local current

		if pvp ~= nil then
			current = pvp:FindFirstChild("Current")
		end

		local value = partyId.Value

		if value == "" then
			value = nil
		end

		return value, current ~= nil and current.Value == true
	end
end

local function pvpOn(playerFromCharacter)
	if Allegiance.PvpSwitchWorldOff then
		return true
	end

	local player_Service = ReplicatedStorage:FindFirstChild("Player_Service")
	local data

	if player_Service ~= nil then
		data = player_Service:FindFirstChild("Data")
	end

	local v5

	if data ~= nil then
		v5 = data:FindFirstChild(playerFromCharacter.Name) or data:FindFirstChild(playerFromCharacter.Name .. "-Studio")
	end

	if v5 == nil then
		return Allegiance.PvpPref.Default
	end

	local slotEquipped = v5:FindFirstChild("slotEquipped")
	local slots = v5:FindFirstChild("slots")

	if slotEquipped == nil or slots == nil then
		return Allegiance.PvpPref.Default
	end

	local valueBase = slots:FindFirstChild("Slot" .. tostring(slotEquipped.Value))

	for _, childName in v3 do
		if valueBase == nil then
			break
		else
			valueBase = valueBase:FindFirstChild(childName)
		end
	end

	if valueBase == nil or not valueBase:IsA("ValueBase") then
		return Allegiance.PvpPref.Default
	end

	if valueBase.Value ~= false then
		return true
	end

	local character = playerFromCharacter.Character
	local humanoidRootPart

	if character ~= nil then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	if humanoidRootPart == nil then
		return false
	end

	local position = humanoidRootPart.Position
	return select(7, Locator.Find(Vector2.new(position.X, position.Z), Locator.Areas, position.Y)) == true
end

local function ownerOf(instance)
	local clone_Owner = instance:FindFirstChild("Clone_Owner")

	if clone_Owner == nil or not clone_Owner:IsA("StringValue") or clone_Owner.Value == "" then
		return nil
	end

	return clone_Owner.Value
end

function Allegiance.SameOwner(instance, instance2)
	if instance == nil or instance2 == nil then
		return false
	end

	local clone_Owner = instance:FindFirstChild("Clone_Owner")
	local value

	if not (clone_Owner == nil or not clone_Owner:IsA("StringValue") or clone_Owner.Value == "") then
		value = clone_Owner.Value
	end

	local clone_Owner2 = instance2:FindFirstChild("Clone_Owner")
	local value2

	if not (clone_Owner2 == nil or not clone_Owner2:IsA("StringValue") or clone_Owner2.Value == "") then
		value2 = clone_Owner2.Value
	end

	if value ~= nil and value == instance2.Name then
		return true
	end

	return value2 ~= nil and value2 == instance.Name or value ~= nil and value2 ~= nil and value == value2
end

function Allegiance.SameTeam(character, character2)
	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local playerFromCharacter2 = Players:GetPlayerFromCharacter(character2)

	if playerFromCharacter == nil or playerFromCharacter2 == nil or (playerFromCharacter.Team == nil or playerFromCharacter2.Team == nil) then
		return false
	end

	return playerFromCharacter.Team == playerFromCharacter2.Team
end

function Allegiance.SameParty(character, character2)
	local v5 = partyWatcher()

	if v5 == nil then
		return false
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local playerFromCharacter2 = Players:GetPlayerFromCharacter(character2)

	if playerFromCharacter == nil or playerFromCharacter2 == nil then
		return false
	end

	if playerFromCharacter == playerFromCharacter2 then
		return true
	end

	local partyId = v5.GetPartyId(playerFromCharacter)
	local partyId2 = v5.GetPartyId(playerFromCharacter2)
	return partyId ~= nil and partyId2 ~= nil and partyId ~= "" and partyId == partyId2
end

function Allegiance.PartyProtected(character, character2)
	if character == nil or character2 == nil or character == character2 then
		return false
	end

	if Allegiance.SameTeam(character, character2) then
		return true
	end

	local v5, v6 = partyStateOf(character)

	if v5 == nil then
		return false
	end

	local v7, v8 = partyStateOf(character2)

	if v5 ~= v7 then
		return false
	end

	if MinigameSettings.Get("ForcePartyProtection") ~= true then
		return not (v6 and v8)
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(character)
	local playerFromCharacter2 = Players:GetPlayerFromCharacter(character2)
	return playerFromCharacter.Team == nil or playerFromCharacter2.Team == nil or playerFromCharacter.Team == playerFromCharacter2.Team
end

function Allegiance.ServerPvpOff()
	return workspace:GetAttribute(pvpAttribute) == false
end

function Allegiance.GeneralPvpOff(instance, instance2)
	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

	if playerFromCharacter == nil then
		local clone_Owner = instance:FindFirstChild("Clone_Owner")

		if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
			playerFromCharacter = nil
		else
			playerFromCharacter = Players:FindFirstChild(clone_Owner.Value)
		end
	end

	local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance2)

	if playerFromCharacter2 == nil then
		local clone_Owner = instance2:FindFirstChild("Clone_Owner")

		if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
			playerFromCharacter2 = nil
		else
			playerFromCharacter2 = Players:FindFirstChild(clone_Owner.Value)
		end
	end

	if playerFromCharacter == nil or playerFromCharacter2 == nil or playerFromCharacter == playerFromCharacter2 or CombatMode.InPvPMode(playerFromCharacter) and CombatMode.InPvPMode(playerFromCharacter2) then
		return false
	end

	return not (pvpOn(playerFromCharacter) and pvpOn(playerFromCharacter2))
end

function Allegiance.Protected(instance, instance2)
	if instance == nil or instance2 == nil or instance == instance2 then
		return false
	end

	if Allegiance.ServerPvpOff() then
		local playerFromCharacter = Players:GetPlayerFromCharacter(instance)

		if playerFromCharacter == nil then
			local clone_Owner = instance:FindFirstChild("Clone_Owner")

			if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
				playerFromCharacter = nil
			else
				playerFromCharacter = Players:FindFirstChild(clone_Owner.Value)
			end
		end

		if playerFromCharacter ~= nil then
			local playerFromCharacter2 = Players:GetPlayerFromCharacter(instance2)

			if playerFromCharacter2 == nil then
				local clone_Owner = instance2:FindFirstChild("Clone_Owner")

				if clone_Owner == nil or not clone_Owner:IsA("StringValue") then
					playerFromCharacter2 = nil
				else
					playerFromCharacter2 = Players:FindFirstChild(clone_Owner.Value)
				end
			end

			if playerFromCharacter2 ~= nil then
				return true
			end
		end
	end

	if Allegiance.GeneralPvpOff(instance, instance2) then
		return true
	end

	return Allegiance.PartyProtected(instance, instance2)
end

function Allegiance.AreFriendly(p, p2)
	if p == nil or p2 == nil then
		return false
	end

	if p == p2 then
		return true
	end

	return Allegiance.SameOwner(p, p2) or Allegiance.SameTeam(p, p2) or Allegiance.SameParty(p, p2)
end

function Allegiance.Allied(p, p2)
	if p == nil or p2 == nil then
		return false
	end

	if p == p2 or (Allegiance.SameOwner(p, p2) or Allegiance.SameTeam(p, p2)) then
		return true
	end

	local v5 = partyStateOf(p)
	return v5 ~= nil and v5 == partyStateOf(p2)
end

return Allegiance