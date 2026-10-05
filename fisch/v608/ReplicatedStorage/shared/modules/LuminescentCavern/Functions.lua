local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local TableUtil = require(packages.TableUtil)
local DataService

if RunService:IsServer() then
	local ServerScriptService = game:GetService("ServerScriptService")
	local legacyServices = ServerScriptService.server.legacyServices
	DataService = require(legacyServices.DataService)
else
	local legacyControllers = ReplicatedStorage.client.legacyControllers
	DataService = require(legacyControllers.DataController)
end

require("./Types")

-- equivalent calls inferred from this helper; original call sites unknown
local function uidToNumber(value: string)
	return (tonumber(string.byte(value) - 65 + 1))
end

local function getSortedKeystoneRequirements(keystoneSeed: number, copy)
	local result = {}

	for k, _ in pairs(copy) do
		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		local v = (keystoneSeed + string.byte(a, 1)) % 1000
		local v2 = (keystoneSeed + string.byte(b, 1)) % 1000

		if v == v2 then
			return a < b
		end

		return v < v2
	end)
	return result
end

local Functions = {}

function Functions.GetData(p)
	if RunService:IsServer() then
		local v = DataService:WaitProfile(p)

		if not v then
			return nil, false
		end

		local luminescentCavern = v.Data.NewFormat.LuminescentCavern

		if luminescentCavern then
			return luminescentCavern, true
		end

		return nil, false
	else
		local fetched = DataService.fetch("LuminescentCavern")

		if fetched then
			return fetched, true
		end

		return nil, false
	end
end

function Functions.GetProximityPrompt(data)
	local _ = {
		ActionText = "Interact",
		ObjectText = "???",
		HoldDuration = 0.5,
		MaxActivationDistance = 12,
		RequiresLineOfSight = false
	}
	assert(data.Parent ~= nil, "Must at least establish a prompt parent.")
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = data.ActionText or "Interact"
	proximityPrompt.ObjectText = data.ObjectText or "???"
	proximityPrompt.HoldDuration = data.HoldDuration or 0.5
	proximityPrompt.MaxActivationDistance = data.MaxActivationDistance or 12
	proximityPrompt.RequiresLineOfSight = data.RequiresLineOfSight or false
	proximityPrompt.Parent = data.Parent
	return proximityPrompt
end

function Functions.GetPedestalItemRequirement(value: string, p)
	assert(p and p.KeystoneData.RequiredKeystones)
	assert(p.KeystoneData.KeystoneSeed)
	local copy = TableUtil.Copy(p.KeystoneData.RequiredKeystones)
	local v = uidToNumber(value) -- equivalent call inferred; original call site unknown
	return getSortedKeystoneRequirements(p.KeystoneData.KeystoneSeed, copy)[v]
end

return Functions