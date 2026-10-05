local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Datas.Items)
local tradableOrder = {
	"Santa's Sleigh",
	"Cupid's Wings",
	"Witch's Broom",
	"Waverider",
	"Yin Yang Slap",
	"Cursed Slap",
	"Cyber Slap",
	"Phantom Slap",
	"Crystal Slap",
	"Divine Slap",
	"Bloodmoon Slap",
	"Radioactive Slap",
	"Rainbow Slap",
	"Crystal Hammer",
	"Rainbow Hammer",
	"Bloodmoon Hammer",
	"Radioactive Airstrike",
	"Yin Yang Lamp",
	"Demon's Head",
	"Lava Slap",
	"Lava Blaster",
	"Alien Slap",
	"Blackhole Bomb",
	"Candy Slap",
	"Candy Sentry"
}
local v2 = {}
local v3 = {
	["Santa's Sleigh"] = "rbxassetid://106575011463424",
	["Cupid's Wings"] = "rbxassetid://125592127726740",
	["Witch's Broom"] = "rbxassetid://118466141203194",
	Waverider = "rbxassetid://125399512921257",
	["Flying Bee"] = "rbxassetid://73337449365932",
	["Radioactive Airstrike"] = "rbxassetid://73753077277254",
	["Yin Yang Lamp"] = "rbxassetid://106398585307279",
	["Demon's Head"] = "rbxassetid://98312790037177",
	["Lava Blaster"] = "rbxassetid://204508521",
	["Blackhole Bomb"] = "rbxassetid://27295735"
}

for _, v4 in tradableOrder do
	v2[v4] = true
end

local clone = table.clone(tradableOrder)
table.insert(clone, "Flying Bee")
local v4 = {}

for _, v5 in clone do
	v4[v5] = true
end

local claimOnceOrder = {
	"Yin Yang Slap",
	"Cursed Slap",
	"Cyber Slap",
	"Phantom Slap",
	"Crystal Slap",
	"Eclipse Slap",
	"Divine Slap",
	"Bloodmoon Slap",
	"Radioactive Slap",
	"Rainbow Slap",
	"Crystal Hammer",
	"Eclipse Hammer",
	"Rainbow Hammer",
	"Bloodmoon Hammer",
	"Radioactive Airstrike",
	"Yin Yang Lamp",
	"Demon's Head"
}
local v6 = {}

for _, v7 in claimOnceOrder do
	v6[v7] = true
end

local v7 = {
	TradableOrder = tradableOrder,
	InventoryManagedOrder = clone,
	ClaimOnceOrder = claimOnceOrder,
	IsTradable = function(p: string)
		return v2[p] == true
	end,
	IsInventoryManaged = function(p: string)
		return v4[p] == true
	end,
	IsClaimOnce = function(p: string)
		return v6[p] == true
	end,
	HasClaimed = function(object, p: string)
		return object:Get((`ClaimedGears.{p}`)) == true
	end,
	MarkClaimed = function(object, p: string)
		if typeof(object:Get("ClaimedGears")) ~= "table" then
			object:Set("ClaimedGears", {})
		end

		if object:Get((`ClaimedGears.{p}`)) ~= true then
			object:InsertOnDictionary("ClaimedGears", p, true)
		end
	end
}

function v7.AlreadyObtained(object, p: string)
	return object:Get((`Items.{p}`)) == true or v7.IsClaimOnce(p) and v7.HasClaimed(object, p)
end

function v7.OwnsInData(p, p2: string)
	if typeof(p.GearInventory) == "table" then
		for _, v8 in p.GearInventory do
			if typeof(v8) == "table" and v8.GearName == p2 then
				return true
			end
		end
	end

	return typeof(p.Items) == "table" and p.Items[p2] == true
end

function v7.GetImage(p: string)
	local v8 = v3[p]

	if typeof(v8) == "string" and v8 ~= "" then
		return v8
	end

	local item = Items[p]

	if item then
		local icon = item.Icon

		if typeof(icon) == "string" and icon ~= "" and icon ~= "rbxassetid://0" then
			return icon
		end
	end

	return nil
end

function v7.GetDisplayName(p: string)
	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getInventory(object)
	local gearInventory = object:Get("GearInventory")

	if typeof(gearInventory) == "table" then
		return gearInventory
	end

	return {}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ownsViaItemsFlag(object, p: string)
	return object:Get((`Items.{p}`)) == true
end

function v7.GetOwnedEntries(object, p: string)
	local result = {}
	local gearInventory = object:Get("GearInventory")

	if typeof(gearInventory) ~= "table" then
		gearInventory = {}
	end

	for k, v10 in gearInventory, nil, nil do
		if not (typeof(k) == "string" and typeof(v10) == "table" and v10.GearName == p) then
			continue
		end

		result[k] = v10
	end

	return result
end

local function getInventoryCount(p, p2: string)
	local count = 0

	for _ in v7.GetOwnedEntries(p, p2) do
		count += 1
	end

	return count
end

function v7.GetOwnedCount(object, p: string)
	local count = 0

	for _ in v7.GetOwnedEntries(object, p) do
		count += 1
	end

	if count > 0 then
		return count
	end

	if ownsViaItemsFlag(object, p) then
		return 1
	end

	return 0
end

function v7.GetTotalCount(object)
	local count = 0
	local gearInventory = object:Get("GearInventory")

	if typeof(gearInventory) ~= "table" then
		gearInventory = {}
	end

	for k, v10 in gearInventory, nil, nil do
		if not (typeof(k) == "string" and typeof(v10) == "table") then
			continue
		end

		count += 1
	end

	return count
end

function v7.Owns(p, p2: string)
	return v7.GetOwnedCount(p, p2) > 0
end

function v7.ListOwned(object)
	local result = {}

	for _, gearName in tradableOrder do
		local ownedEntries = v7.GetOwnedEntries(object, gearName)
		local v9 = false

		for k, ownedEntry in ownedEntries do
			table.insert(result, {
				GearName = gearName,
				UUID = k,
				Source = ownedEntry.Source,
				CreatedAt = ownedEntry.CreatedAt
			})
			v9 = true
		end

		if v9 or not ownsViaItemsFlag(object, gearName) then
			continue
		end

		table.insert(result, {
			GearName = gearName
		})
	end

	return result
end

function v7.ResolveOwnedRef(object, p)
	if typeof(p) ~= "table" then
		return nil
	end

	local gearName = p.GearName

	if typeof(gearName) ~= "string" or not v7.IsTradable(gearName) then
		return nil
	end

	local UUID = p.UUID

	if typeof(UUID) == "string" then
		local v8 = (getInventory(object))[UUID]

		if typeof(v8) == "table" and v8.GearName == gearName then
			return {
				GearName = gearName,
				UUID = UUID
			}
		end

		return nil
	else
		local count = 0

		for _ in v7.GetOwnedEntries(object, gearName) do
			count += 1
		end

		if count > 0 then
			return nil
		end

		if ownsViaItemsFlag(object, gearName) then
			return {
				GearName = gearName
			}
		end

		return nil
	end
end

function v7.Escrow(object, p)
	if typeof(p) ~= "table" or typeof(p.GearName) ~= "string" then
		return nil
	end

	local gearName = p.GearName
	local UUID = p.UUID
	local v8

	if typeof(UUID) == "string" then
		local v9 = (getInventory(object))[UUID]

		if typeof(v9) ~= "table" or v9.GearName ~= gearName then
			return nil
		end

		object:RemoveFromDictionary("GearInventory", UUID)
		v8 = {
			GearName = gearName,
			UUID = UUID,
			Source = v9.Source,
			CreatedAt = v9.CreatedAt
		}
		local count = 0

		for _ in v7.GetOwnedEntries(object, gearName) do
			count += 1
		end

		if count ~= 0 then
			return v8
		end

		object:RemoveFromDictionary("Items", gearName)
		return v8
	else
		if object:Get((`Items.{gearName}`)) ~= true then
			return nil
		end

		object:RemoveFromDictionary("Items", gearName)
		return {
			GearName = gearName
		}
	end
end

function v7.Grant(object, gearName: string, source: string?, value: string?, value2: number?, flag: boolean?)
	if not (v7.IsInventoryManaged(gearName) or flag) then
		return false, nil
	end

	if typeof(object:Get("GearInventory")) ~= "table" then
		object:Set("GearInventory", {})
	end

	if typeof(value) ~= "string" then
		value = HttpService:GenerateGUID(false)

		while object:Get((`GearInventory.{value}`)) ~= nil do
			value = HttpService:GenerateGUID(false)
		end
	end

	object:InsertOnDictionary("GearInventory", value, {
		GearName = gearName,
		Source = source,
		CreatedAt = typeof(value2) == "number" and value2 or DateTime.now().UnixTimestamp
	})

	if object:Get((`Items.{gearName}`)) ~= true then
		object:InsertOnDictionary("Items", gearName, true)
	end

	return true, value
end

function v7:GrantToData(gearName: string, source: string?)
	if not v7.IsInventoryManaged(gearName) then
		return false, nil
	end

	if typeof(self.GearInventory) ~= "table" then
		self.GearInventory = {}
	end

	for _, v8 in self.GearInventory do
		if typeof(v8) == "table" and v8.GearName == gearName then
			return false, nil
		end
	end

	local GUID = HttpService:GenerateGUID(false)

	while self.GearInventory[GUID] ~= nil do
		GUID = HttpService:GenerateGUID(false)
	end

	self.GearInventory[GUID] = {
		GearName = gearName,
		Source = source,
		CreatedAt = DateTime.now().UnixTimestamp
	}

	if typeof(self.Items) ~= "table" then
		self.Items = {}
	end

	self.Items[gearName] = true
	return true, GUID
end

function v7:Restore(data)
	if typeof(data) ~= "table" or typeof(data.GearName) ~= "string" then
		return
	end

	local gearName = data.GearName

	if typeof(data.UUID) == "string" then
		if typeof(self.GearInventory) ~= "table" then
			self.GearInventory = {}
		end

		self.GearInventory[data.UUID] = {
			GearName = gearName,
			Source = data.Source,
			CreatedAt = data.CreatedAt
		}
	end

	if typeof(self.Items) ~= "table" then
		self.Items = {}
	end

	self.Items[gearName] = true
end

return table.freeze(v7)