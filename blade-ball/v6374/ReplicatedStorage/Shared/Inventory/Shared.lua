local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.ServerInfo)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Freeze)
local v5 = require3(ReplicatedStorage2.Packages.Observers)
local v6 = require3(ReplicatedStorage2.Packages.JSONDencode)
require3(ReplicatedStorage2.Shared.Trading.TradeInfo)
require3(script.Parent.InventoryTypes)
local v7 = require3(script.FakeReplion)
local v8 = require3(script.Parent.Internal.Limits)
local v9 = require3(script.ArrayJSON)
local v10 = require3(script.Parent.Internal.VirtualInventory)
local isServer = RunService:IsServer()
local isClient = RunService:IsClient()
RunService:IsStudio()
local v11 = {}

if RunService:IsServer() then
	v5.observePlayer(function(instance)
		local v12 = v.Server:WaitReplionFor(instance, "Data")

		if not v12 then
			return
		end

		v11[instance] = {
			UseNewInventory = v12:Get("ExperimentalNewInventory")
		}
		instance:SetAttribute("UseNewInventory", v12:Get("ExperimentalNewInventory"))
		instance:SetAttribute("IsInventoryLoaded", true)
		return function()
			v11[instance] = nil
		end
	end)
else
	v5.observePlayer(function(instance)
		while not instance:GetAttribute("IsInventoryLoaded") and instance:IsDescendantOf(Players) do
			task.wait()
		end

		v11[instance] = {
			UseNewInventory = instance:GetAttribute("UseNewInventory")
		}
		return function()
			v11[instance] = nil
		end
	end)
end

local function getReplionFor(instance, p: string)
	if instance == nil or type(instance) ~= "table" then
		if instance == nil then
			assert(isClient, "You are running Client.GetReplion on Server???")
			local replion = v.Client:GetReplion(p)

			if not replion and not Players.LocalPlayer:GetAttribute("__isTeleporting") and (v2.isTestGame() or RunService:IsStudio()) then
				warn((`[!!!] [Client] [Inventory] getReplionFor failed for replion "{p}"\n{debug.traceback()}`))
			end

			return replion
		else
			assert(isServer, "You are running Server.GetReplionFor on Client???")
			local replionFor = v.Server:GetReplionFor(instance, p)

			if not replionFor and not instance:GetAttribute("__isTeleporting") and (v2.isTestGame() or RunService:IsStudio()) then
				warn((`[!!!] [Server] [Inventory] getReplionFor failed for replion "{p}", player {instance.UserId} is not loaded\n{debug.traceback()}`))
			end

			return replionFor
		end
	elseif p == "Data" and instance.DataReplion ~= nil then
		return instance.DataReplion
	else
		return instance.Replion
	end
end

local v12 = {
	Sword = "SwordSkins",
	Explosion = "ExplosionSkins",
	Emote = "Emotes",
	Ability = "Abilities",
	Booth = "Booths"
}
local Shared = {
	GetReplionPathFor = function(self, p, p2)
		if type(p) ~= "table" then
			return p2
		end

		if p.ModifyPath then
			return (p.ModifyPath(p2))
		end

		return p2
	end,
	GetInventoryVersion = function(self, _, _)
		return "New"
	end,
	InventoryTypes = {
		"Sword",
		"Explosion",
		"Emote",
		"Ability",
		"Booth"
	},
	SafeGetLegacyInventoryPath = function(_, p)
		return v12[p] or p
	end,
	GetLegacyInventoryPath = function(self, p)
		return assert(v12[p], (`Unknown inventory type: "{p}"`))
	end,
	OwnsItem = function(self, p, p2, p3)
		return self:GetItem(p, p2, p3) ~= nil
	end,
	BuildLegacyItem = function(self, p, p2, p3)
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		local v13 = {
			Name = p3,
			Id = p3,
			TradeLock = {
				Type = "Permanent",
				Value = true
			}
		}

		if p2 == "Sword" then
			if replionFor:Find("Finishers.Unlocked", p3) ~= nil then
				v13.Finisher = true
			end
		elseif p2 == "Ability" then
			v13.Upgrade = replionFor:Get({ "AbilityUpgrades", p3 }) or 0
		end

		return v13
	end,
	GetItem = function(self, p, p2, p3)
		if self:GetInventoryVersion(p) == "Old" then
			local replionFor = getReplionFor(p, "Data")

			if not replionFor then
				return nil
			end

			if p2 == "Emote" then
				if not replionFor:Get({ self:GetLegacyInventoryPath("Emote"), "Unlocked", p3 }) then
					return nil
				end
			elseif not replionFor:Find({ self:GetLegacyInventoryPath(p2), "Unlocked" }, p3) then
				return nil
			end

			return self:BuildLegacyItem(p, p2, p3)
		else
			local replionFor = getReplionFor(p, "Inventory")

			if not (replionFor and p3) then
				return nil
			end

			local v13 = replionFor:Get(self:GetReplionPathFor(p, { "Inventory", p2, p3 }))

			if v13 then
				return v13
			end

			if v10:IsEnabledFor(p) then
				return v10:GetItem(p, p2, p3)
			end

			return nil
		end
	end
}
local hasAttributes

hasAttributes = function(p, items)
	for k, item in items do
		if typeof(item) == "table" and typeof(p[k]) == "table" then
			if not hasAttributes(p[k], item) then
				return false
			end
		elseif item ~= p[k] and (item ~= nil or p[k] ~= v4.None) and (p[k] ~= nil or item ~= v4.None) then
			return false
		end
	end

	return true
end

function Shared:FindItemsRaw(p, p2, p3, p4, callback)
	local result = {}
	local raw = self:GetRaw(p, p2, p3)

	if raw then
		if type(callback) == "table" then
			for k, v13 in raw do
				if v13.Name == p4 and hasAttributes(v13, callback) then
					table.insert(result, k)
				end
			end
		elseif type(callback) == "function" then
			for k, v13 in raw do
				if v13.Name == p4 and callback(v13) then
					table.insert(result, k)
				end
			end
		elseif callback == nil then
			for k, v13 in raw do
				if v13.Name == p4 then
					table.insert(result, k)
				end
			end
		end

		if #result == 0 and v10:IsEnabledFor(p) then
			return v10:FindItems(p, p3, p4)
		end

		return result
	elseif v10:IsEnabledFor(p) then
		return v10:FindItems(p, p3, p4)
	else
		return {}
	end
end

function Shared:FindItems(p, p2, p3, p4)
	local replionFor = getReplionFor(p, "Inventory")

	if replionFor then
		return self:FindItemsRaw(p, replionFor.Data, p2, p3, p4)
	end

	return {}
end

function Shared:FindItemsWithKey(p, p2, p3)
	local stringToItem = self:StringToItem(p, p3)
	local tradeLock

	if stringToItem.TradeLock == nil then
		tradeLock = v.None
	else
		tradeLock = stringToItem.TradeLock
	end

	local serial

	if stringToItem.Serial == nil then
		serial = v.None
	else
		serial = stringToItem.Serial
	end

	local v13 = {
		TradeLock = tradeLock,
		Serial = serial
	}

	if p2 == "Ability" then
		local upgrade = stringToItem.Upgrade or 0

		if upgrade == 0 then
			upgrade = v.None
		end

		v13.Upgrade = upgrade
	elseif p2 == "Sword" then
		local finisher = stringToItem.Finisher

		if finisher == nil then
			finisher = v.None
		end

		v13.Finisher = finisher
		local accessory = stringToItem.Accessory

		if accessory == nil then
			accessory = v.None
		end

		v13.Accessory = accessory
		local kills = stringToItem.Kills

		if kills == nil then
			kills = v.None
		end

		v13.Kills = kills
	end

	return self:FindItems(p, p2, stringToItem.Name, v13)
end

function Shared:GetRaw(p, p2, p3)
	local v13 = v4.Dictionary.getIn(p2, self:GetReplionPathFor(p, { "Inventory", p3 }))
	local result = isClient and v10:IsEnabledFor(p) and v10:BuildInventory(p, p3)

	if not result then
		return v13
	end

	if v13 then
		for k, v14 in v13 do
			result[k] = v14
		end
	end

	return result
end

function Shared:Get(p, p2)
	local replionFor = getReplionFor(p, "Inventory")

	if replionFor then
		return self:GetRaw(p, replionFor.Data, p2)
	end

	return nil
end

function Shared:GetInventoryRaw(p, p2)
	return v4.Dictionary.getIn(p2, self:GetReplionPathFor(p, { "Inventory" }))
end

function Shared:GetInventory(p)
	local replionFor = getReplionFor(p, "Inventory")

	if replionFor then
		return self:GetInventoryRaw(p, replionFor.Data)
	end

	return nil
end

function Shared:GetEquipped(p, p2)
	assert(p2 ~= "Emote", (`Invalid inventory type for GetEquipped, got "{p2}"`))

	if self:GetInventoryVersion(p) == "Old" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		local v13 = replionFor:Get({ self:GetLegacyInventoryPath(p2), "CurrentlySelected" })

		if v13 then
			return {
				Id = v13,
				Name = v13
			}
		end

		return nil
	else
		local replionFor = getReplionFor(p, "Inventory")

		if replionFor then
			return replionFor:Get(self:GetReplionPathFor(p, { "Equipped", p2 }))
		end

		return nil
	end
end

function Shared:GetEquippedList(p, p2)
	assert(p2 == "Emote", (`Invalid inventory type for GetEquippedList, got "{p2}", expected Emote`))

	if self:GetInventoryVersion(p) == "Old" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		local expect = replionFor:GetExpect({ self:GetLegacyInventoryPath(p2), "Equipped" })
		local result = table.create(#expect)

		for k, v13 in expect do
			result[tonumber(k)] = {
				Name = v13,
				Id = v13
			}
		end

		return result
	else
		local replionFor = getReplionFor(p, "Inventory")

		if replionFor then
			return (v4.Dictionary.map(
				replionFor:GetExpect(self:GetReplionPathFor(p, { "EquippedList", p2 })),
				function(p3, p4)
					return p3, (tonumber(p4))
				end
			))
		end

		return nil
	end
end

function Shared:OnChange(p, p2, callback)
	if self:GetInventoryVersion(p) == "Old" and p2 ~= "Emote" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		local maid = v3.new()

		if p2 == "Sword" then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function fireChange(p3)
				local item = self:GetItem(p, p2, p3)

				if item then
					callback(item, "Change", item)
				end
			end

			maid:Add(replionFor:OnArrayInsert({ "Finishers", "Unlocked" }, function(_: number, p3)
				fireChange(p3) -- equivalent call inferred; original call site unknown
			end))
			maid:Add(replionFor:OnArrayRemove({ "Finishers", "Unlocked" }, function(_: number, p3)
				fireChange(p3) -- equivalent call inferred; original call site unknown
			end))
		elseif p2 == "Ability" then
			-- equivalent calls inferred from this helper; original call sites unknown
			local function fireChange(p3)
				local item = self:GetItem(p, p2, p3)

				if item then
					callback(item, "Change", item)
				end
			end

			maid:Add(replionFor:OnArrayInsert({ "AbilityUpgrades" }, function(_: number, p3)
				fireChange(p3) -- equivalent call inferred; original call site unknown
			end))
			maid:Add(replionFor:OnArrayRemove({ "AbilityUpgrades" }, function(_: number, p3)
				fireChange(p3) -- equivalent call inferred; original call site unknown
			end))
			maid:Add(replionFor:OnDescendantChange({ "AbilityUpgrades" }, function(value, _, _)
				if type(value) == "string" then
					value = string.split(value, ".")
				end

				assert(type(value) == "table")
				local v13 = value[#value]
				local item = v13 and self:GetItem(p, p2, v13)

				if item then
					callback(item, "Change", item)
				end
			end))
		end

		maid:Add(replionFor:OnArrayInsert({ self:GetLegacyInventoryPath(p2), "Unlocked" }, function(_: number, p3)
			local item = self:GetItem(p, p2, p3)

			if item then
				callback(item, "Insert", nil)
			end
		end))
		maid:Add(replionFor:OnArrayRemove({ self:GetLegacyInventoryPath(p2), "Unlocked" }, function(_: number, p3)
			local legacyItem = self:BuildLegacyItem(p, p2, p3)

			if legacyItem then
				callback(legacyItem, "Remove", nil)
			end
		end))
		return maid
	elseif getReplionFor(p, "Inventory") then
		return self:OnInventoryChange(p, p2, function(items, items2)
			if items2 and v4.Dictionary.equals(items, items2) then
				return
			end

			for k, item in items do
				if items2 and items2[k] and v4.Dictionary.equals(items2[k], item) then
					continue
				end

				if items2 and items2[k] then
					local item2 = self:GetItem(p, p2, k)

					if item2 then
						callback(item2, "Change", items2[k])
					end
				else
					local item2 = self:GetItem(p, p2, k)

					if item2 then
						callback(item2, "Insert", nil)
					end
				end
			end

			if items2 then
				for k, item in items2 do
					if items[k] or self:GetInventoryVersion(p) ~= "New" then
						continue
					end

					local clone = table.clone(item)
					clone.Id = k
					callback(clone, "Remove", nil)
				end
			end
		end)
	else
		return nil
	end
end

function Shared:OnInventoryChange(p, p2, callback)
	if self:GetInventoryVersion(p) == "Old" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		local maid = v3.new()

		if p2 == "Sword" then
			maid:Add(replionFor:OnDescendantChange("Finishers", function()
				local v13 = self:Get(p, p2)
				callback(v13, v13)
			end))
		elseif p2 == "Ability" then
			maid:Add(replionFor:OnDescendantChange("AbilityUpgrades", function()
				local v13 = self:Get(p, p2)
				callback(v13, v13)
			end))
		end

		maid:Add(replionFor:OnChange({ self:GetLegacyInventoryPath(p2), "Unlocked" }, callback))
		return maid
	else
		local replionFor = getReplionFor(p, "Inventory")

		if replionFor then
			return replionFor:OnChange(self:GetReplionPathFor(p, { "Inventory", p2 }), callback)
		end

		return nil
	end
end

function Shared.OnItemChange(object, p, p2, p3, callback)
	if object:GetInventoryVersion(p) == "Old" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		if p2 == "Sword" then
			return replionFor:OnDescendantChange({ "Finishers" }, function(list, p4, p5)
				if typeof(list) ~= "table" then
					return
				end

				local v13 = p5[p3]
				local v14 = p4[p3]

				if list[2] == "Equipped" and v14 ~= v13 then
					callback(v14, v13)
				elseif list[2] == "Unlocked" then
					local index = table.find(v13, p3)
					local index2 = table.find(v14, p3)

					if index ~= index2 then
						callback(index, index2)
					end
				end
			end)
		elseif p2 == "Ability" then
			return replionFor:OnChange({ "AbilityUpgrades", p3 }, callback)
		end

		return nil
	else
		local replionFor = getReplionFor(p, "Inventory")

		if replionFor then
			return replionFor:OnChange(object:GetReplionPathFor(p, { "Inventory", p2, p3 }), callback)
		end

		return nil
	end
end

function Shared:OnEquip(p, p2, callback)
	if self:GetInventoryVersion(p) == "Old" then
		local replionFor = getReplionFor(p, "Data")

		if not replionFor then
			return nil
		end

		if p2 == "Emote" then
			return replionFor:OnChange({ self:GetLegacyInventoryPath("Emote"), "Equipped" }, callback)
		end

		return replionFor:OnChange({ self:GetLegacyInventoryPath(p2), "CurrentlySelected" }, function(p3, p4)
			return callback(p3 ~= nil and {
				Name = p3,
				Id = p3
			} or nil, p4 ~= nil and {
				Name = p4,
				Id = p4
			} or nil)
		end)
	else
		local replionFor = getReplionFor(p, "Inventory")

		if not replionFor then
			return nil
		end

		if p2 == "Emote" then
			return replionFor:OnChange(self:GetReplionPathFor(p, { "EquippedList", "Emote" }), callback)
		end

		return replionFor:OnChange(self:GetReplionPathFor(p, { "Equipped", p2 }), callback)
	end
end

local toArray

toArray = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		table.insert(result, { k, toArray(item) })
	end

	table.sort(result, function(a, b)
		return tostring(a[1]) < tostring(b[1])
	end)
	return result
end

local function encode(p)
	return (v6.Encode((toArray(p))))
end

local toDictionary

toDictionary = function(list)
	if type(list) ~= "table" then
		return list
	end

	for i = #list, 1, -1 do
		local v13 = list[i]
		list[v13[1]] = toDictionary(v13[2])
		list[i] = nil
	end

	return list
end

local function decode(p)
	return (v9.decode(p))
end

function Shared:UUIDToString(p, p2, p3, p4, p5)
	local item = self:GetItem(p, p2, p3)

	if type(item) == "table" then
		return self:ItemToString(p2, item, p4, p5)
	end

	return nil
end

Shared.UUIDToKey = Shared.UUIDToString

function Shared:ItemToString(_, p, callback, p2)
	local clone = table.clone(p)

	if clone.CreatedAt and not p2 then
		clone.CreatedAt = nil
	end

	if type(callback) == "table" then
		for _, item in callback do
			clone[item] = nil
		end
	elseif type(callback) == "function" then
		clone = callback(p)
	end

	return (v6.Encode((toArray(clone))))
end

Shared.ItemToKey = Shared.ItemToString

function Shared:StringToItem(_, p)
	return (v9.decode(p))
end

Shared.KeyToItem = Shared.StringToItem

function Shared.CreateFakeReplion(_, p)
	return v7.new(p)
end

function Shared:GetInventorySize(p, p2)
	if not getReplionFor(p, "Inventory") then
		return nil
	end

	local v13 = self:Get(p, p2) or {}
	local count = 0

	for k in pairs(v13) do
		if not v10:IsVirtualId(k) then
			count += 1
		end
	end

	return count
end

function Shared.GetInventoryLimit(_, p)
	return v8[p]
end

return Shared