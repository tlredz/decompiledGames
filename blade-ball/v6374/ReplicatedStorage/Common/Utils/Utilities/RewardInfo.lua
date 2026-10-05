local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Shared.Inventory.InventoryTypes)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v = require3(ReplicatedStorage2.Shared.Statable)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local RewardInfo = {}
local isClient = RunService:IsClient()
local v3 = {
	"Sword",
	"Explosion",
	"Ability",
	"AbilityFreeTrial",
	"Emote",
	"Finisher",
	"SwordAccessory",
	"List",
	"Title"
}

function RewardInfo.playerOwnsItem(p, p2, ...)
	local v4 = require3(ReplicatedStorage2.Shared.Inventory)

	if isClient and p ~= Players.LocalPlayer and p ~= nil then
		return false
	end

	local dataReplion

	if type(p) == "table" then
		dataReplion = p.DataReplion
	elseif isClient then
		dataReplion = v2.Client:GetReplion("Data")
	else
		dataReplion = v2.Server:GetReplionFor(p, "Data")
	end

	if not (dataReplion and table.find(v3, p2.Type)) then
		return false
	end

	if p2.Type == "List" then
		for _, v5 in p2.Value do
			if not RewardInfo.playerOwnsItem(p, v5) then
				return false
			end
		end

		return true
	else
		if p2.Type == "Finisher" then
			return dataReplion:Find("Finishers.Unlocked", p2.Value) and true or false
		end

		if p2.Type == "SwordAccessory" then
			if isClient then
				return #v4.Client:FindItems("Sword", p2.Value, {
					Accessory = true
				}) > 0
			end

			return #v4.Server:FindItems(p, "Sword", p2.Value, {
				Accessory = true
			}) > 0
		else
			if p2.Type == "Title" then
				return dataReplion:Get({ "Titles", p2.Value }) == true
			end

			local type2 = p2.Type
			local v5 = type2 == "AbilityFreeTrial" and "Ability" or type2
			local v6

			if isClient then
				v6 = v4.Client:FindItems(v5, p2.Value)
			else
				v6 = v4.Server:FindItems(p, v5, p2.Value)
			end

			return #v6 > 0
		end
	end
end

local v4 = {}
setmetatable(v4, {
	__mode = "k"
})

local function watchInventory(p, p2)
	local states = v4[p]

	if not states then
		states = {}
		v4[p] = states
	end

	local type2 = p2.Type
	local formatted = `{type2}/InventoryListener`

	if states[formatted] then
		return states[formatted]
	end

	local state = v.State(nil)
	local v5 = require3(ReplicatedStorage2.Shared.Inventory.Shared)

	if p == Players.LocalPlayer then
		p = nil
	end

	local function updateState()
		state:Set(v5:Get(p, type2) or {})
	end

	states[formatted] = state
	task.spawn(updateState)
	v5:OnEquip(p, type2, updateState)
	v5:OnInventoryChange(p, type2, updateState)
	return state
end

function RewardInfo.getItemOwnershipState(p, p2)
	local computeds = v4[p]

	if not computeds then
		computeds = {}
		v4[p] = computeds
	end

	local formatted = `{p2.Type}/{p2.Value}`
	local v5 = computeds[formatted]

	if v5 then
		return v5
	end

	require3(ReplicatedStorage2.Shared.Inventory)
	local computed = v.Computed(function(callback)
		callback((watchInventory(p, p2)))
		return RewardInfo.playerOwnsItem(p, p2)
	end)
	computeds[formatted] = computed
	return computed
end

return RewardInfo