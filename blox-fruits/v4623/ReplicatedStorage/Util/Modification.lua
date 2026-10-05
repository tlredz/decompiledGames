local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Type = require(game.ReplicatedStorage.Packages.Type)
local Result = require(game.ReplicatedStorage.Packages.Result)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local TypeUtil = require(game.ReplicatedStorage.Util.TypeUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local PriceService = require(game.ReplicatedStorage.PriceService)
local Appearance = require(game.ReplicatedStorage.Definitions.Skin.Appearance)
local IdMap = require(game.ReplicatedStorage.IdMap)
require(script.Types)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("Modifications"):tag("Util"):display():traceback():build()
local isClient = RunService:IsClient()
local GUID = HttpService:GenerateGUID(false)
local v2 = {
	Accessories = {
		Owned = {},
		Equipped = {}
	},
	Skins = {
		Owned = {},
		Equipped = {}
	},
	Mutations = {
		Owned = {},
		Equipped = {}
	}
}

function getName(p, flag: boolean, p2: string?)
	local title = p.Display.Title or p.Display.Name or p.Index.StorageKey

	if p2 then
		title = `<Color={p2}>{title}<Color=/>`
	end

	return title .. (not flag and "" or ` {(p.Display.Category or p.Index.IdType):lower()}`)
end

function reconcile(p, items)
	for k, item in items do
		if p[k] == nil then
			if type(item) == "table" then
				p[k] = TableUtil.deepCopy(item)
			else
				p[k] = item
			end
		elseif type(p[k]) == "table" and type(item) == "table" then
			reconcile(p[k], item)
		end
	end
end

function encodeItemIdArray(buf: buffer, list, value: number?)
	local v3 = value or 0
	assert(v3, "bad offset")
	assert(#list < 65535, (`itemId array too long: #{#list}`))
	buffer.writeu16(buf, v3, #list)

	for i = 1, #list do
		buffer.writeu16(buf, v3 + 2 + (i - 1) * 2, list[i])
	end

	return buf
end

function decodeItemIdArray(buf: buffer, value: number?)
	local v3 = value or 0
	assert(v3, "bad offset")
	local v4 = buffer.readu16(buf, v3)
	local result = table.create(v4)

	for i = 1, v4 do
		result[i] = buffer.readu16(buf, v3 + 2 + (i - 1) * 2)
	end

	return result
end

function decodeBufferIntoItemIdArrays(buf: buffer, value: number?, p: number?)
	local v3 = value or 0
	assert(v3, "bad offset")
	local result = {}

	repeat
		local v4 = decodeItemIdArray(buf, v3)
		v3 += #v4 * 2 + 2
		table.insert(result, v4)
	until p and #result == p or buffer.len(buf) <= v3

	return result
end

function encodeBufferItemIdArrays(buf: buffer, value: number?, list)
	local v3 = value or 0
	assert(v3, "bad offset")

	for i = 1, #list do
		local v4 = list[i]
		encodeItemIdArray(buf, v4, v3)
		v3 += #v4 * 2 + 2
	end
end

function decodeModificationData(buf)
	if type(buf) == "table" then
		if buf.Type == "DecodeCache" then
			return buf.getModificationData(GUID)
		end

		return {
			Preferred = table.clone(buf.Preferred),
			Unlocked = table.clone(buf.Unlocked)
		}
	else
		debug.profilebegin("decode mod-data")
		local v3 = buffer.readu8(buf, 0)

		if v3 ~= 0 then
			error((`unknown encoding version "{v3}"`))
			return
		end

		local v4 = decodeBufferIntoItemIdArrays(buf, 1, 2)
		assert(#v4 == 2, (`decoding expected 2 arrays, received {#v4}`))
		debug.profileend()
		return {
			Unlocked = v4[1],
			Preferred = v4[2]
		}
	end
end

function encodeModificationData(p)
	debug.profilebegin("encode mod-data")
	local buf = buffer.create(#p.Unlocked * 2 + 2 + 1 + (#p.Preferred * 2 + 2))
	buffer.writeu8(buf, 0, 0)
	encodeBufferItemIdArrays(buf, 1, { p.Unlocked, p.Preferred })
	debug.profileend()
	return buf
end

function decodeAdorneeData(buf)
	if type(buf) == "table" then
		if buf.Type == "DecodeCache" then
			return buf.getAdorneeData(GUID)
		end

		return {
			Owned = table.clone(buf.Owned),
			Equipped = table.clone(buf.Equipped)
		}
	else
		debug.profilebegin("decode adornee data")
		local v3 = buffer.readu8(buf, 0)

		if v3 ~= 0 then
			error((`unknown encoding version "{v3}"`))
			return
		end

		local v4 = decodeBufferIntoItemIdArrays(buf, 1, 2)
		assert(#v4 == 2, (`decoding expected 2 arrays, received {#v4}`))
		debug.profileend()
		return {
			Owned = v4[1],
			Equipped = v4[2]
		}
	end
end

function encodeAdorneeData(p)
	debug.profilebegin("encode adornee data")
	local buf = buffer.create(#p.Owned * 2 + 2 + 1 + (#p.Equipped * 2 + 2))
	buffer.writeu8(buf, 0, 0)
	encodeBufferItemIdArrays(buf, 1, { p.Owned, p.Equipped })
	debug.profileend()
	return buf
end

function newDecodeCache(p, p2)
	local v3 = {}
	return {
		Type = "DecodeCache",
		getAdorneeData = function(p3: string)
			assert(p3 == GUID, "invalid passkey")
			return {
				Equipped = table.clone(p2.Equipped),
				Owned = table.clone(p2.Owned)
			}
		end,
		getModificationData = function(p3)
			assert(p3 == GUID, "invalid passkey")
			return {
				Unlocked = table.clone(p.Unlocked),
				Preferred = table.clone(p.Preferred)
			}
		end,
		loadPerm = function(p3: number, p4: string)
			local v4 = v3[p3]

			if v4 then
				return v4[p4]
			end

			return nil
		end,
		savePerm = function(p3: number, p4: string, flag: boolean?)
			if not v3[p3] then
				v3[p3] = {}
			end

			v3[p3][p4] = flag
		end
	}
end

function findCachedPerm(p: number, p2: string, p3, p4)
	if p3 == p4 and type(p3) == "table" and p3.Type == "DecodeCache" then
		return p3.loadPerm(p, p2)
	end

	return nil
end

function setCachedPerm(p: number, p2: string, flag: boolean, p3, p4)
	if p3 == p4 and type(p3) == "table" and p3.Type == "DecodeCache" then
		p3.savePerm(p, p2, flag)
	end
end

local Modification = {
	ADORNEE_ID_TYPES = { "Moveset", "Ability" },
	MODIFICATION_ID_TYPES = { "Skin", "Mutation", "Equipment" },
	Type = {}
}
Modification.Type.ModificationId = TypeUtil.Types.ItemId(table.unpack(Modification.MODIFICATION_ID_TYPES))
Modification.Type.ClientRequest = TypeUtil.Types.BetterUnion({
	GetData = Type.strictInterface({
		Type = Type.literal("GetData")
	}),
	SetEquip = Type.strictInterface({
		Type = Type.literal("SetEquip"),
		ItemId = Modification.Type.ModificationId,
		IsEquipped = Type.boolean
	})
})
Modification.Type.ModificationLog = Type.strictInterface({
	Type = Type.literal("Received", "Migrated"),
	ItemId = Modification.Type.ModificationId,
	UTC = Type.integer,
	Version = Type.string
})
Modification.Type.ModificationData = Type.strictInterface({
	Preferred = Type.array(Modification.Type.ModificationId),
	Unlocked = Type.array(Modification.Type.ModificationId)
})
Modification.Type.ServerEvent = TypeUtil.Types.BetterUnion({
	DataChanged = Type.strictInterface({
		Type = Type.literal("DataChanged"),
		Data = Type.buffer
	})
})
Modification.Type.ServerResponse = TypeUtil.Types.BetterUnion({
	GetData = Type.strictInterface({
		Type = Type.literal("GetData"),
		Data = Type.buffer
	}),
	Generic = Type.strictInterface({
		Type = Type.literal("Generic"),
		Message = Type.optional(Type.string),
		Success = Type.boolean
	})
})
local v3 = FunctionCache.new(function(p: number)
	local match = ItemConfig.match(p)

	if match:isErr() then
		return false
	end

	local unwrapped = match:unwrap()

	if table.find(Modification.MODIFICATION_ID_TYPES, unwrapped.Index.IdType) then
		return true
	end

	return false
end, function(p: number)
	return (tostring(p))
end)

function Modification.getIfModification(p: number)
	return v3:call(p)
end

local v4 = FunctionCache.new(function(p: number)
	local match = ItemConfig.match(p)

	if match:isErr() then
		return Result.err((`bad modificationId: {match:unwrapErr()}`))
	end

	local unwrapped = match:unwrap()

	if not table.find(Modification.MODIFICATION_ID_TYPES, unwrapped.Index.IdType) then
		return Result.err((`unsupported modification id type "{unwrapped.Index.IdType}" for "{unwrapped.Index.DebugLabel}"`))
	end

	local adornee

	if unwrapped.Index.IdType == "Mutation" then
		adornee = unwrapped.Mutation and unwrapped.Mutation.Adornee
	elseif unwrapped.Index.IdType == "Skin" then
		adornee = unwrapped.Skin and unwrapped.Skin.Adornee
	elseif unwrapped.Index.IdType == "Equipment" then
		adornee = unwrapped.Equipment and unwrapped.Equipment.Adornee
	else
		return Result.err((`unsupported id-type "{unwrapped.Index.IdType}" for "{unwrapped.Index.DebugLabel}"`))
	end

	if adornee then
		return Result.ok(adornee)
	end

	return Result.err((`non-moddable item "{unwrapped.Index.DebugLabel}"`))
end, function(p: number)
	return (tostring(p))
end)

function Modification.matchAdornee(p: number)
	return v4:call(p)
end

local v5 = FunctionCache.new(function(p: number?, p2)
	local itemIds = {}

	for _, idType in Modification.MODIFICATION_ID_TYPES do
		if not (not p2 or idType == p2) then
			continue
		end

		if p then
			for _, v7 in ItemConfig.Query.join({
				Index = {
					IdType = idType
				}
			}) do
				if Modification.matchAdornee(v7.Index.ItemId):unwrap() ~= p then
					continue
				end

				table.insert(itemIds, v7.Index.ItemId)
			end
		else
			for _, v7 in ItemConfig.Query.select({
				Index = {
					IdType = idType
				}
			}) do
				table.insert(itemIds, v7.Index.ItemId)
			end
		end
	end

	TableUtil.deduplicate(itemIds)
	table.sort(itemIds)
	return itemIds
end, function(p: number?, p2)
	return (`{p}_{p2}`)
end)

function Modification.getAllModifications(p: number?, p2)
	return table.clone(v5:call(p, p2))
end

local v6 = FunctionCache.new(function(p: number)
	return #Modification.getAllModifications(p) > 0
end, function(p: number)
	return (tostring(p))
end)

function Modification.getIfAdornee(p: number)
	return v6:call(p)
end

local v7 = FunctionCache.new(function(p, p2)
	local itemIds = {}

	for _, idType in p and { p } or Modification.ADORNEE_ID_TYPES do
		for _, v9 in ItemConfig.Query.select({
			Index = {
				IdType = idType
			}
		}) do
			local allModifications = Modification.getAllModifications(v9.Index.ItemId, p2)

			if not (#allModifications > 0) then
				continue
			end

			for _, _ in allModifications do
				table.insert(itemIds, v9.Index.ItemId)
			end
		end
	end

	TableUtil.deduplicate(itemIds)
	table.sort(itemIds)
	return itemIds
end, function(p, p2)
	return (`{p}_{p2}`)
end)

function Modification.getPossibleAdornees(p, _)
	return table.clone(v7:call(p))
end

local v8 = FunctionCache.new(function(p: number)
	for _, v9 in Modification.getAllModifications(p, "Skin") do
		local unwrapped = ItemConfig.match(v9):unwrap()

		if unwrapped.Skin and unwrapped.Skin.IsDefault then
			return Result.ok(v9)
		end
	end

	return Result.err((`no default found for adornee #"{p}"`))
end, function(p: number)
	return (tostring(p))
end)

function Modification.matchDefaultSkin(p: number)
	return v8:call(p)
end

local v9 = FunctionCache.new(function(p: number)
	local unwrapped = ItemConfig.match(p):unwrap()
	local unwrapped2 = Modification.matchAdornee(p):unwrap()
	return unwrapped.Index.IdType ~= "Skin" or Modification.matchDefaultSkin(unwrapped2):asNullable() ~= unwrapped.Index.ItemId
end, function(p: number)
	return (tostring(p))
end)

function Modification.getIfCanSave(p: number)
	return v9:call(p)
end

Modification.Data = {}

function Modification.Data.refreshAsync() end

local function cleanEncodeAdorneeData(p)
	local clone = table.clone(p.Equipped)
	local clone2 = table.clone(p.Owned)

	local function appendVariants(list, variantOf: number)
		table.insert(list, variantOf)

		for _, v10 in ItemConfig.Query.select({
			Variant = {
				VariantOf = variantOf,
				Mutation = {
					Operation = "EQ",
					Value = nil
				}
			}
		}) do
			table.insert(list, v10.Index.ItemId)
		end
	end

	local v10 = {
		Equipped = {},
		Owned = {}
	}

	for _, v11 in clone do
		appendVariants(v10.Equipped, v11)
	end

	for _, v11 in clone2 do
		appendVariants(v10.Owned, v11)
	end

	for _, v11 in ItemConfig.map(v10.Equipped) do
		if v11.Variant.VariantOf and v11.Variant.Mutation then
			table.insert(v10.Equipped, v11.Variant.VariantOf)
		end
	end

	for _, v11 in ItemConfig.map(v10.Equipped) do
		if v11.Index.IdType ~= "Moveset" then
			continue
		end

		for _, v12 in ItemConfig.Query.select({
			Index = {
				IdType = v11.Index.IdType
			},
			Moveset = {
				SkillRedirect = v11.Index.ItemId
			}
		}) do
			table.insert(v10.Equipped, v12.Index.ItemId)
		end
	end

	for _, v11 in ItemConfig.map(v10.Owned) do
		if v11.Index.IdType ~= "Moveset" then
			continue
		end

		for _, v12 in ItemConfig.Query.select({
			Index = {
				IdType = v11.Index.IdType
			},
			Moveset = {
				SkillRedirect = v11.Index.ItemId
			}
		}) do
			table.insert(v10.Owned, v12.Index.ItemId)
		end
	end

	TableUtil.deduplicate(v10.Equipped)
	TableUtil.deduplicate(v10.Owned)
	table.sort(v10.Equipped)
	table.sort(v10.Owned)
	local v11 = encodeAdorneeData(v10)
	local v12 = decodeAdorneeData(v11)
	assert(
		#v10.Equipped == #v12.Equipped,
		(`decoded Equipped array size mismatch, got {#v12.Equipped}, expected #{v10.Equipped}`)
	)
	assert(#v10.Owned == #v12.Owned, (`decoded Equipped array size mismatch, got {#v12.Owned}, expected #{v10.Owned}`))

	for k, v13 in v10.Equipped do
		assert(v13 == v12.Equipped[k], (`mismatch at Equipped index #{k}: expected {v13}, received {v12.Equipped[k]}`))
	end

	for k, v13 in v10.Owned do
		assert(v13 == v12.Owned[k], (`mismatch at Owned index #{k}: expected {v13}, received {v12.Owned[k]}`))
	end

	return v11
end

Modification.Data.Adornee = {}

function Modification.Data.Adornee.debug(p)
	local v10 = decodeAdorneeData(p)
	local debugLabels = {}

	for _, v11 in v10.Owned do
		table.insert(debugLabels, ItemConfig.match(v11):unwrap().Index.DebugLabel)
	end

	local debugLabels2 = {}

	for _, v11 in v10.Equipped do
		table.insert(debugLabels2, ItemConfig.match(v11):unwrap().Index.DebugLabel)
	end

	return {
		["Owned Adornees"] = debugLabels,
		["Equipped Adornees"] = debugLabels2
	}
end

function Modification.Data.Adornee.new(p, p2)
	return (cleanEncodeAdorneeData({
		Equipped = table.clone(p2),
		Owned = table.clone(p)
	}))
end

function Modification.Data.Adornee.empty()
	return Modification.Data.Adornee.new({}, {})
end

function Modification.Data.Adornee.fromPlayerData(data)
	debug.profilebegin("ModUtil Adornee.fromPlayerData")
	local extended = v.extend(".Data.Adornee.fromPlayerData", true, "WARN")
	extended.info("fn called: (partialPlayerData)")
	extended.trace(function()
		local v11 = {
			Items = data.Items,
			RobuxFruits = data.RobuxFruits,
			Stored = data.Stored,
			FruitMovesetId = data.FruitMovesetId,
			Abilities = 0
		}
		local buso

		if data.Abilities then
			buso = data.Abilities.Buso
		end

		v11.Abilities = {
			Buso = buso
		}
		return "partialPlayerData", v11
	end)
	local equipped = {}

	if data.FruitMovesetId then
		table.insert(equipped, data.FruitMovesetId)
	end

	local owned = {}

	if not data.Abilities then
		extended.fatal(function()
			return "partialPlayerData", data
		end)
	end

	if data.Abilities and data.Abilities.Buso then
		table.insert(equipped, IdMap.Ability.Aura)
		table.insert(owned, IdMap.Ability.Aura)
	end

	if data.Items then
		for k, item in data.Items do
			if not item then
				continue
			end

			local nullable = ItemConfig.match(k, "Moveset"):asNullable()

			if not (nullable and #Modification.getAllModifications(nullable.Index.ItemId) ~= 0) then
				continue
			end

			table.insert(owned, nullable.Index.ItemId)

			if not data.Stored or data.Stored[nullable.Index.StorageKey] then
				continue
			end

			table.insert(equipped, nullable.Index.ItemId)
		end
	end

	if data.RobuxFruits then
		for k, robuxFruit in data.RobuxFruits do
			if robuxFruit ~= true then
				continue
			end

			local nullable = ItemConfig.match(k, "Moveset"):asNullable()

			if not nullable then
				continue
			end

			table.insert(owned, nullable.Index.ItemId)

			if nullable.Index.ItemId == data.FruitMovesetId then
				table.insert(equipped, nullable.Index.ItemId)
			end
		end
	end

	TableUtil.deduplicate(equipped)
	TableUtil.deduplicate(owned)
	table.sort(equipped)
	table.sort(owned)
	local v12 = {
		Equipped = equipped,
		Owned = owned
	}
	extended.trace(function()
		return "returning", v12
	end)
	debug.profileend()
	return (cleanEncodeAdorneeData(v12))
end

function Modification.Data.Adornee.fromItemReplication(p)
	debug.profilebegin("ModUtil Adornee.fromRep")
	local extended = v.extend(".Data.Adornee.fromItemReplication", true, "WARN")

	if ItemReplicationService.IsInitialized then
		local items, items2

		if isClient then
			assert(ItemReplicationService.IS_CLIENT, "bad ItemReplicationService")
			extended.trace("is client")
			items = ItemReplicationService:GetItems(ItemReplicationService.KEYS.IS_EQUIPPED) or {}
			items2 = ItemReplicationService:GetItems(ItemReplicationService.KEYS.IS_OWNED) or {}
		else
			extended.trace("is server")
			assert(ItemReplicationService.IS_SERVER, "bad ItemReplicationService")
			items = ItemReplicationService:GetItems(p.UserId, ItemReplicationService.KEYS.IS_EQUIPPED) or {}
			items2 = ItemReplicationService:GetItems(p.UserId, ItemReplicationService.KEYS.IS_OWNED) or {}
		end

		assert(items, "bad equipped items")
		assert(items2, "bad owned items")

		local function filterNonAdornees(items3)
			local itemIds = {}

			for _, item in items3 do
				local nullable = ItemConfig.match(item.ItemId):asNullable()

				if not nullable then
					continue
				end

				if item.Value == true then
					if table.find(Modification.ADORNEE_ID_TYPES, nullable.Index.IdType) then
						if nullable.Moveset and nullable.Moveset.Type == "Fruit" or #Modification.getAllModifications(nullable.Index.ItemId) ~= 0 then
							table.insert(itemIds, nullable.Index.ItemId)
						else
							extended.trace((`couldn't find {nullable.Index.DebugLabel} has no modifications, skipping`))
						end
					else
						extended.trace((`couldn't find {nullable.Index.DebugLabel} in valid adornee types, skipping`))
					end
				else
					extended.trace((`{nullable.Index.DebugLabel} in false, skipping`))
				end
			end

			TableUtil.deduplicate(itemIds)
			table.sort(itemIds)
			return itemIds
		end

		extended.trace(function()
			local result = {}

			for _, item in items2 do
				result[ItemConfig.match(item.ItemId):unwrap().Index.DebugLabel] = item.Value
			end

			return "unfiltered owned items", result
		end)
		extended.trace(function()
			local result = {}

			for _, item in items do
				result[ItemConfig.match(item.ItemId):unwrap().Index.DebugLabel] = item.Value
			end

			return "unfiltered equipped items", result
		end)
		local owned = filterNonAdornees(items2)
		local equipped = filterNonAdornees(items)
		extended.trace(function()
			return "equipped item ids", equipped
		end)
		extended.trace(function()
			return "owned item ids", owned
		end)
		local v12 = {
			Equipped = equipped,
			Owned = owned
		}
		extended.trace(function()
			return "returning", v12
		end)
		local buf = cleanEncodeAdorneeData(v12)
		debug.profileend()
		return buf
	else
		extended.trace("not initialized")
		local buf = cleanEncodeAdorneeData({
			Equipped = {},
			Owned = {}
		})
		debug.profileend()
		return buf
	end
end

Modification.Data.Modification = {}

function Modification.Data.Modification.toUTF8(buf: buffer)
	local v10 = buffer.tostring(buf)
	local v11 = {}

	for i = 1, #v10 do
		v11[i] = string.byte(v10, i)
	end

	return utf8.char(unpack(v11))
end

function Modification.Data.Modification.fromUTF8(p: string)
	local v10 = ""

	for _, v11 in utf8.codes(p) do
		v10 ..= string.char(v11)
	end

	return buffer.fromstring(v10)
end

function Modification.Data.Modification.debug(p)
	local v10 = decodeModificationData(p)
	local debugLabels = {}

	for _, v11 in v10.Unlocked do
		table.insert(debugLabels, ItemConfig.match(v11):unwrap().Index.DebugLabel)
	end

	local debugLabels2 = {}

	for _, v11 in v10.Preferred do
		table.insert(debugLabels2, ItemConfig.match(v11):unwrap().Index.DebugLabel)
	end

	return {
		["Unlocked Mods"] = debugLabels,
		["Preferred Mods"] = debugLabels2
	}
end

function cleanEncodeModificationData(p)
	local v10 = {
		Preferred = table.clone(p.Preferred),
		Unlocked = table.clone(p.Unlocked)
	}
	TableUtil.deduplicate(v10.Preferred)
	TableUtil.deduplicate(v10.Unlocked)
	table.sort(v10.Preferred)
	table.sort(v10.Unlocked)
	local v11 = encodeModificationData(v10)
	local v12 = decodeModificationData(v11)
	assert(
		#v10.Preferred == #v12.Preferred,
		(`decoded Preferred array size mismatch, got {#v12.Preferred}, expected #{v10.Preferred}`)
	)
	assert(
		#v10.Unlocked == #v12.Unlocked,
		(`decoded Unlocked array size mismatch, got {#v12.Unlocked}, expected #{v10.Unlocked}`)
	)

	for k, v13 in v10.Preferred do
		assert(
			v13 == v12.Preferred[k],
			(`mismatch at Preferred index #{k}: expected {v13}, received {v12.Preferred[k]}`)
		)
	end

	for k, v13 in v10.Unlocked do
		assert(v13 == v12.Unlocked[k], (`mismatch at Unlocked index #{k}: expected {v13}, received {v12.Unlocked[k]}`))
	end

	local UTF8 = Modification.Data.Modification.toUTF8(v11)
	assert(
		Modification.Data.Modification.toUTF8(Modification.Data.Modification.fromUTF8(UTF8)) == UTF8,
		"invalid encoding"
	)
	HttpService:JSONEncode({
		EncodedModifications = UTF8
	})
	return v11
end

function Modification.Data.Modification.empty()
	return cleanEncodeModificationData({
		Preferred = {},
		Unlocked = {}
	})
end

function Modification.Data.Modification.setPreferred(p: number, buf: buffer, flag: boolean)
	local v10 = decodeModificationData(buf)
	local unwrapped = ItemConfig.match(p):unwrap()
	local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
	local itemIds = {}

	if flag then
		table.insert(itemIds, unwrapped.Index.ItemId)
	end

	for _, v11 in ItemConfig.map(v10.Preferred) do
		if not (v11.Index.IdType ~= unwrapped.Index.IdType or Modification.matchAdornee(v11.Index.ItemId):unwrap() ~= unwrapped2) then
			continue
		end

		table.insert(itemIds, v11.Index.ItemId)
	end

	v10.Preferred = itemIds
	return cleanEncodeModificationData(v10)
end

function Modification.Data.Modification.setUnlock(p: number, buf: buffer, flag: boolean)
	local v10 = decodeModificationData(buf)

	if table.find(v10.Unlocked, p) and not flag then
		table.remove(v10.Unlocked, table.find(v10.Unlocked, p))
		return cleanEncodeModificationData(v10)
	end

	if table.find(v10.Unlocked, p) or not flag then
		return buf
	end

	table.insert(v10.Unlocked, p)
	return cleanEncodeModificationData(v10)
end

function Modification.Data.Modification.fix(buf: buffer)
	debug.profilebegin("ModUtil Mod.fix")
	local v10 = decodeModificationData(buf)
	local extended = v.extend("Data.Modification.fix", nil, "WARN")
	extended.trace("call fn(data)")
	extended.trace(function()
		return "data", v10
	end)
	local v11 = {
		Unlocked = {},
		Preferred = {}
	}

	for _, v12 in v10.Unlocked do
		local itemId = ItemConfig.match(v12):unwrap().Index.ItemId

		if Modification.getIfCanSave(itemId) then
			table.insert(v11.Unlocked, itemId)
		end
	end

	for _, v12 in v10.Preferred do
		local unwrapped = ItemConfig.match(v12):unwrap()
		local itemId = unwrapped.Index.ItemId

		if not Modification.getIfCanSave(itemId) then
			continue
		end

		if not (unwrapped.Index.IdType ~= "Mutation" or not ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap().Variant.IsFoundation) then
			continue
		end

		table.insert(v11.Preferred, itemId)
	end

	TableUtil.deduplicate(v11.Preferred)
	TableUtil.deduplicate(v11.Unlocked)
	table.sort(v11.Unlocked)
	table.sort(v11.Preferred)
	extended.trace(function()
		return "pre-check out", v11
	end)
	local modificationData, v12 = Modification.Type.ModificationData(v11)

	if not modificationData then
		extended.fatal(function()
			return `type check failed: {v12}`, v11
		end)
	end

	assert(modificationData, v12)
	extended.trace("passed check")
	local v13 = cleanEncodeModificationData(v11)
	debug.profileend()
	return v13
end

function Modification.Data.Modification.fromItemReplication(p)
	debug.profilebegin("ModUtil Mod.fromRep")
	local extended = v.extend(".Data.Modification.fromItemReplication", true, "WARN")

	if ItemReplicationService.IsInitialized then
		local items, items2

		if isClient then
			extended.trace("is client")
			assert(ItemReplicationService.IS_CLIENT, "bad ItemReplicationService")
			items = ItemReplicationService:GetItems(ItemReplicationService.KEYS.IS_PREFERRED) or {}
			items2 = ItemReplicationService:GetItems(ItemReplicationService.KEYS.IS_OWNED) or {}
		else
			extended.trace("is server")
			assert(ItemReplicationService.IS_SERVER, "bad ItemReplicationService")
			items = ItemReplicationService:GetItems(p.UserId, ItemReplicationService.KEYS.IS_PREFERRED) or {}
			items2 = ItemReplicationService:GetItems(p.UserId, ItemReplicationService.KEYS.IS_OWNED) or {}
		end

		assert(items, "bad equipped items")
		assert(items2, "bad owned items")

		local function filterNonModifications(items3)
			local itemIds = {}

			for _, item in items3 do
				local nullable = ItemConfig.match(item.ItemId):asNullable()

				if not nullable then
					continue
				end

				if item.Value == true then
					if table.find(Modification.MODIFICATION_ID_TYPES, nullable.Index.IdType) then
						if Modification.getIfCanSave(nullable.Index.ItemId) then
							table.insert(itemIds, nullable.Index.ItemId)
						else
							extended.trace((`{nullable.Index.DebugLabel} can't be saved`))
						end
					else
						extended.trace((`couldn't find {nullable.Index.DebugLabel} in valid mod types, skipping`))
					end
				else
					extended.trace((`{nullable.Index.DebugLabel} in false, skipping`))
				end
			end

			TableUtil.deduplicate(itemIds)
			table.sort(itemIds)
			return itemIds
		end

		extended.trace(function()
			local result = {}

			for _, item in items2 do
				result[ItemConfig.match(item.ItemId):unwrap().Index.DebugLabel] = item.Value
			end

			return "unfiltered owned items", result
		end)
		extended.trace(function()
			local result = {}

			for _, item in items do
				result[ItemConfig.match(item.ItemId):unwrap().Index.DebugLabel] = item.Value
			end

			return "unfiltered preferred items", result
		end)
		local unlocked = filterNonModifications(items2)
		local preferred = filterNonModifications(items)
		extended.trace(function()
			return "preferred item ids", preferred
		end)
		extended.trace(function()
			return "unlocked item ids", unlocked
		end)
		local v12 = {
			Unlocked = unlocked,
			Preferred = preferred
		}
		extended.trace(function()
			return "returning", v12
		end)
		local v13 = cleanEncodeModificationData(v12)
		debug.profileend()
		return v13
	else
		extended.trace("not initialized")
		local v10 = cleanEncodeModificationData({
			Unlocked = {},
			Preferred = {}
		})
		debug.profileend()
		return v10
	end
end

function Modification.Data.Modification.fromPlayerData(data)
	local extended = v.extend(".Data.Modification.fromPlayerData", true, "WARN")
	extended.info("fn called: (partialPlayerData)")
	extended.trace(function()
		return "partialPlayerData", {
			FruitCustomizer = data.FruitCustomizer,
			EncodedModifications = `#{data.EncodedModifications and data.EncodedModifications:len()}`,
			OwnedColors = data.OwnedColors,
			DarkBladeSkin = data.DarkBladeSkin,
			DarkBladeSkinDisabled = data.DarkBladeSkinDisabled,
			BusoColor = data.BusoColor,
			BusoColorFade = data.BusoColorFade
		}
	end)

	if data.EncodedModifications then
		extended.trace("has pre-existing modififications")
		return Modification.Data.Modification.fromUTF8(data.EncodedModifications)
	end

	local unlocked = {}
	local preferred = {}
	local fruitCustomizer = data.FruitCustomizer or TableUtil.deepCopy(v2)
	assert(fruitCustomizer, "bad legacyData")
	reconcile(fruitCustomizer, v2)
	extended.trace("processing legacy data")

	local function process(p, p2)
		for k, v12 in p.Owned do
			if v12 ~= true then
				continue
			end

			local nullable = ItemConfig.match(k, p2):asNullable()

			if nullable then
				table.insert(unlocked, nullable.Index.ItemId)
			end
		end

		for _, v12 in p.Equipped do
			local nullable = ItemConfig.match(v12, p2):asNullable()

			if nullable then
				table.insert(preferred, nullable.Index.ItemId)
			end
		end
	end

	if fruitCustomizer.Mutations then
		process(fruitCustomizer.Mutations, "Mutation")
	end

	process(fruitCustomizer.Skins, "Skin")

	local function process2(accessories, p)
		for k, v12 in accessories.Owned do
			if v12 ~= true then
				continue
			end

			local nullable = ItemConfig.match(k, p):asNullable()

			if nullable then
				table.insert(unlocked, nullable.Index.ItemId)
			end
		end

		for _, v12 in accessories.Equipped do
			assert(v12, "bad prefer table")

			for k, v13 in v12 do
				if v13 ~= true then
					continue
				end

				local nullable = ItemConfig.match(k, p):asNullable()

				if nullable then
					table.insert(preferred, nullable.Index.ItemId)
				end
			end
		end
	end

	process2(fruitCustomizer.Accessories, "Equipment")
	extended.trace((`found #{#unlocked} owned items and #{#preferred} equipped items`))
	local ownedColors = data.OwnedColors or {}
	assert(ownedColors, "bad legacyOwnedColors")
	extended.trace(function()
		return "legacy OwnedColors", ownedColors
	end)
	local idFromColorSetValues = Appearance.getIdFromColorSetValues(data.BusoColor, data.BusoColorFade)

	for k, ownedColor in ownedColors do
		if ownedColor ~= true then
			continue
		end

		local nullable = ItemConfig.match(k, "Skin"):asNullable()

		if not nullable then
			continue
		end

		table.insert(unlocked, nullable.Index.ItemId)

		if idFromColorSetValues and idFromColorSetValues.Index.ItemId == nullable.Index.ItemId then
			table.insert(preferred, nullable.Index.ItemId)
		end
	end

	local darkBladeSkin = data.DarkBladeSkin
	extended.trace((`legacyDarkBladeSkin: {darkBladeSkin}`))

	if darkBladeSkin then
		extended.trace("they have the skin! giving them the dark blade skin")
		local dARKBLADESKINslayer = IdMap.Skin.DARKBLADESKINslayer
		table.insert(unlocked, dARKBLADESKINslayer)
		local darkBladeSkinDisabled = data.DarkBladeSkinDisabled
		extended.trace((`legacyDarkBladeSkin disabled: {darkBladeSkinDisabled}`))

		if not darkBladeSkinDisabled then
			extended.trace("equipping dark blade skin")
			table.insert(preferred, dARKBLADESKINslayer)
		end
	end

	TableUtil.deduplicate(preferred)
	TableUtil.deduplicate(unlocked)
	table.sort(preferred)
	table.sort(unlocked)
	local v12 = {
		Preferred = preferred,
		Unlocked = unlocked
	}
	local fix = Modification.Data.Modification.fix(cleanEncodeModificationData(v12))
	extended.trace(function()
		return "returning", v12
	end)
	return fix
end

function Modification.getIfUnlocked(p: number, p2, p3)
	v.extend(".getIfUnlocked", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local cachedPerm = findCachedPerm(p, "Unlocked", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local unwrapped = Modification.matchAdornee(p):unwrap()
	local v10 = decodeAdorneeData(p3)
	local v11 = decodeModificationData(p2)

	if table.find(v11.Unlocked, p) then
		setCachedPerm(p, "Unlocked", true, p2, p3)
		return true
	end

	local unwrapped2 = ItemConfig.match(p):unwrap()

	if unwrapped2.Index.IdType == "Skin" then
		if unwrapped2.Skin and unwrapped2.Skin.IsDefault then
			local unwrapped3 = ItemConfig.match(unwrapped):unwrap()

			if unwrapped3.Variant.Mutation and table.find(v11.Unlocked, unwrapped3.Variant.Mutation) then
				setCachedPerm(p, "Unlocked", true, p2, p3)
				return true
			end

			if table.find(v10.Owned, unwrapped) then
				setCachedPerm(p, "Unlocked", true, p2, p3)
				return true
			end
		end
	elseif unwrapped2.Index.IdType == "Mutation" then
		if ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped2.Index.ItemId
			}
		}):unwrap().Index.ItemId == unwrapped then
			if table.find(v10.Owned, unwrapped) then
				setCachedPerm(p, "Unlocked", true, p2, p3)
				return true
			end

			setCachedPerm(p, "Unlocked", false, p2, p3)
			return false
		else
			local selected = table.find(v11.Unlocked, p) ~= nil
			setCachedPerm(p, "Unlocked", selected, p2, p3)
			return selected
		end
	end

	setCachedPerm(p, "Unlocked", false, p2, p3)
	return false
end

function Modification.getUnlocked(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getUnlocked")
	v.extend(".getPermanentUnlocksForAdornee", true, "WARN").info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfUnlocked(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	debug.profileend()
	return result
end

function Modification.getIfPreferred(p: number, p2, p3)
	v.extend(".getIfPreferred", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local cachedPerm = findCachedPerm(p, "Preferred", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	local unwrapped2 = Modification.matchAdornee(p):unwrap()
	local v10 = decodeModificationData(p2)

	if table.find(v10.Preferred, p) then
		setCachedPerm(p, "Preferred", true, p2, p3)
		return true
	end

	if unwrapped.Index.IdType == "Skin" then
		if unwrapped.Skin and unwrapped.Skin.IsDefault then
			for _, v11 in v10.Preferred do
				if Modification.matchAdornee(v11):unwrap() ~= unwrapped2 then
					continue
				end

				setCachedPerm(p, "Preferred", false, p2, p3)
				return false
			end

			setCachedPerm(p, "Preferred", true, p2, p3)
			return true
		end
	elseif unwrapped.Index.IdType == "Mutation" then
		if ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap().Variant.IsFoundation then
			for _, v11 in ItemConfig.map(Modification.getAllModifications(unwrapped2, unwrapped.Index.IdType)) do
				if not (v11.Index.ItemId ~= unwrapped.Index.ItemId and table.find(v10.Preferred, v11.Index.ItemId)) then
					continue
				end

				setCachedPerm(p, "Preferred", false, p2, p3)
				return false
			end

			if Modification.getIfUnlocked(unwrapped.Index.ItemId, p2, p3) then
				local v11 = table.find(v10.Preferred, unwrapped.Index.ItemId) ~= nil
				setCachedPerm(p, "Preferred", v11, p2, p3)
				return v11
			end
		else
			local v11 = table.find(v10.Preferred, unwrapped.Index.ItemId) ~= nil
			setCachedPerm(p, "Preferred", v11, p2, p3)
			return v11
		end
	end

	setCachedPerm(p, "Preferred", false, p2, p3)
	return false
end

function Modification.getPreferred(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getPreferred")
	v.extend(".getPermanentUnlocksForAdornee", true, "WARN").info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfPreferred(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	debug.profileend()
	return result
end

function Modification.getIfEquipped(p: number, p2, p3)
	v.extend(".getIfEquipped", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local cachedPerm = findCachedPerm(p, "Equipped", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	local unwrapped2 = Modification.matchAdornee(p):unwrap()
	local v10 = decodeAdorneeData(p3)
	local v11 = decodeModificationData(p2)

	if unwrapped.Index.IdType == "Mutation" then
		local unwrapped3 = ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap()

		if unwrapped3.Index.ItemId == unwrapped2 then
			local v12 = true

			for _, v14 in ItemConfig.map(Modification.getAllModifications(unwrapped2, "Mutation")) do
				if v14.Index.ItemId == unwrapped.Index.ItemId then
					continue
				end

				local unwrapped4 = ItemConfig.Query.selectOne({
					Variant = {
						Mutation = v14.Index.ItemId
					}
				}):unwrap()

				if not table.find(v10.Equipped, unwrapped4.Index.ItemId) then
					continue
				end

				v12 = false
				break
			end

			if not v12 then
				setCachedPerm(p, "Equipped", false, p2, p3)
				return false
			end

			local v14 = table.find(v10.Equipped, unwrapped3.Index.ItemId) ~= nil
			setCachedPerm(p, "Equipped", v14, p2, p3)
			return v14
		else
			local v12 = table.find(v10.Equipped, unwrapped3.Index.ItemId) ~= nil
			setCachedPerm(p, "Equipped", v12, p2, p3)
			return v12
		end
	else
		if not table.find(v10.Equipped, unwrapped2) then
			setCachedPerm(p, "Equipped", false, p2, p3)
			return false
		end

		if table.find(v11.Preferred, p) then
			setCachedPerm(p, "Equipped", true, p2, p3)
			return true
		end

		if unwrapped.Index.IdType ~= "Skin" or not (unwrapped.Skin and unwrapped.Skin.IsDefault) then
			setCachedPerm(p, "Equipped", false, p2, p3)
			return false
		end

		for _, v12 in v11.Preferred do
			if Modification.matchAdornee(v12):asNullable() ~= unwrapped2 then
				continue
			end

			setCachedPerm(p, "Equipped", false, p2, p3)
			return false
		end

		setCachedPerm(p, "Equipped", true, p2, p3)
		return true
	end
end

function Modification.getIfCanUnlock(p: number, p2, p3)
	local extended = v.extend(".getIfCanUnlock", true, "WARN")
	local cachedPerm = findCachedPerm(p, "Unlockable", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local unwrapped = ItemConfig.match(p):unwrap()
	extended.info((`fn called: (modId={unwrapped.Index.DebugLabel}, modificationData, adorneeData)`))
	local v10 = decodeAdorneeData(p3)
	extended.trace(function()
		return "adorneeData", Modification.Data.Adornee.debug(p3)
	end)
	local unwrapped2 = ItemConfig.match(Modification.matchAdornee(p):unwrap()):unwrap()
	extended.trace((`adornee: {unwrapped2.Index.DebugLabel}`))

	if unwrapped2.Moveset and unwrapped2.Moveset.SkillRedirect then
		local unwrapped3 = ItemConfig.match(unwrapped2.Moveset.SkillRedirect):unwrap()
		extended.trace(function()
			return (`has redirect: {unwrapped3.Index.DebugLabel}`)
		end)
		local v11 = false

		for _, v13 in ItemConfig.Query.select({
			Moveset = {
				SkillRedirect = unwrapped2.Moveset.SkillRedirect
			}
		}) do
			local v14 = table.find(v10.Owned, v13.Index.ItemId) ~= nil
			local v15 = table.find(v10.Equipped, v13.Index.ItemId) ~= nil

			if v14 == false and v15 == false then
				local v16 = v13
				local v17 = false
				local v18 = false
				extended.trace(function()
					return (` - not usable: {v16.Index.DebugLabel}: owned={v17}, equipped={v18}`)
				end)
			else
				extended.trace((`usable! {v13.Index.DebugLabel}`))
				v11 = true
				break
			end
		end

		if not v11 then
			extended.trace("returning, nothing was usable")
			setCachedPerm(p, "Unlockable", false, p2, p3)
			return
				false,
				(`You need to own or equip {getName(unwrapped3, false, "Yellow")} to equip {getName(unwrapped, true, "Yellow")}`)
		end
	elseif not (table.find(v10.Owned, unwrapped2.Index.ItemId) or table.find(v10.Equipped, unwrapped2.Index.ItemId)) then
		extended.trace("returning, couldn't find adornee in equip or own")
		setCachedPerm(p, "Unlockable", false, p2, p3)
		return
			false,
			(`You need to own or equip {getName(unwrapped2, false, "Yellow")} to equip {getName(unwrapped, true, "Yellow")}`)
	end

	local v11 = decodeModificationData(p2)

	if table.find(v11.Unlocked, unwrapped.Index.ItemId) then
		extended.trace("returning, mod is already unlocked")
		setCachedPerm(p, "Unlockable", false, p2, p3)
		return false, (`You need already have {getName(unwrapped, true, "Yellow")} unlocked`)
	else
		if unwrapped.Index.IdType == "Mutation" then
			local unwrapped3 = ItemConfig.Query.selectOne({
				Variant = {
					Mutation = unwrapped.Index.ItemId
				}
			}):unwrap()

			if unwrapped3.Variant.IsFoundation and table.find(v10.Owned, unwrapped3.Index.ItemId) then
				extended.trace("you unlocked it via adornee access")
				setCachedPerm(p, "Unlockable", false, p2, p3)
				return false, (`You need already have {getName(unwrapped, true, "Yellow")} unlocked`)
			end
		elseif not Modification.getIfCanSave(p) then
			extended.trace("returning, can't save")
			setCachedPerm(p, "Unlockable", false, p2, p3)
			return false
		end

		extended.trace("returning true")
		setCachedPerm(p, "Unlockable", true, p2, p3)
		return true
	end
end

function Modification.getUnlockable(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getUnlockable")
	v.extend(".getPermanentUnlocksForAdornee", true, "WARN").info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfCanUnlock(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	debug.profileend()
	return result
end

function Modification.getIfCanUse(p: number, p2, p3)
	local cachedPerm = findCachedPerm(p, "Usable", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local v10 = decodeAdorneeData(p3)
	local v11 = decodeModificationData(p2)
	local v12 = Modification.getIfCanEquip(p, v11, v10) or Modification.getIfEquipped(p, v11, v10) or Modification.getIfUnlocked(
		p,
		v11,
		v10
	)

	if not v12 then
		local unwrapped = ItemConfig.match(p):unwrap()
		local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()

		if unwrapped.Index.IdType == "Skin" and unwrapped.Skin and unwrapped.Skin.IsDefault then
			for _, v13 in v11.Unlocked do
				local unwrapped3 = ItemConfig.match(v13):unwrap()

				if not (unwrapped3.Index.IdType == "Skin" and Modification.matchAdornee(unwrapped3.Index.ItemId):unwrap() == unwrapped2) then
					continue
				end

				setCachedPerm(p, "Usable", true, p2, p3)
				return true
			end

			for _, v13 in v11.Preferred do
				local unwrapped3 = ItemConfig.match(v13):unwrap()

				if not (unwrapped3.Index.IdType == "Skin" and Modification.matchAdornee(unwrapped3.Index.ItemId):unwrap() == unwrapped2) then
					continue
				end

				setCachedPerm(p, "Usable", true, p2, p3)
				return true
			end
		end
	end

	setCachedPerm(p, "Usable", v12, p2, p3)
	return v12
end

function Modification.getUsable(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getUsable")
	local extended = v.extend(".getUsable", true, "WARN")
	extended.info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfCanUse(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	extended.trace(function()
		return "returning", ItemConfig.mapDebug(result)
	end)
	debug.profileend()
	return result
end

function Modification.getIfCanPurchase(p: number, p2, p3)
	local unwrapped = ItemConfig.match(p):unwrap()
	local purchaseWith = unwrapped.Economy and unwrapped.Economy.PurchaseWith

	if not (purchaseWith and PriceService.getPrice(purchaseWith)) then
		return false
	end

	local cachedPerm = findCachedPerm(p, "Purchasable", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	v.extend(".getIfCanPurchase", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local isGiftable = false

	if unwrapped.Economy and unwrapped.Economy.PurchaseWith then
		local unwrapped2 = ItemConfig.match(unwrapped.Economy.PurchaseWith):unwrap()

		if unwrapped2.Economy and unwrapped2.Economy.IsGiftable then
			isGiftable = unwrapped2.Economy.IsGiftable
		end
	end

	local unwrapped2 = Modification.matchAdornee(p):unwrap()
	local v10 = decodeAdorneeData(p3)
	local v11 = decodeModificationData(p2)

	if unwrapped.Index.IdType == "Skin" then
		if table.find(v10.Owned, unwrapped2) or table.find(v10.Equipped, unwrapped2) then
			if table.find(v11.Unlocked, p) and not isGiftable then
				setCachedPerm(p, "Purchasable", false, p2, p3)
				return false
			end
		else
			setCachedPerm(p, "Purchasable", false, p2, p3)
			return false
		end
	elseif unwrapped.Index.IdType == "Mutation" then
		if ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap().Index.ItemId == unwrapped2 then
			setCachedPerm(p, "Purchasable", false, p2, p3)
			return false
		end

		if not table.find(v10.Owned, unwrapped2) then
			setCachedPerm(p, "Purchasable", false, p2, p3)
			return false
		end

		if table.find(v11.Unlocked, p) and not isGiftable then
			setCachedPerm(p, "Purchasable", false, p2, p3)
			return false
		end
	elseif unwrapped.Index.IdType == "Equipment" then
		if not table.find(v10.Owned, unwrapped2) then
			setCachedPerm(p, "Purchasable", false, p2, p3)
			return false
		end

		if table.find(v11.Unlocked, p) and not isGiftable then
		end

		setCachedPerm(p, "Purchasable", false, p2, p3)
		return false
	else
		error((`unknown mod type: {unwrapped.Index.IdType}`))
	end

	setCachedPerm(p, "Purchasable", true, p2, p3)
	return true
end

function Modification.getPurchasable(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getPurchasable()")
	v.extend(".getPurchasable", true, "WARN").info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfCanPurchase(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	debug.profileend()
	return result
end

function Modification.getIfCanUnequip(p: number, p2, p3)
	v.extend(".getIfCanEquip", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local cachedPerm = findCachedPerm(p, "Unequippable", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local unwrapped = ItemConfig.match(p):unwrap()

	if unwrapped.Index.IdType == "Mutation" then
		local unwrapped2 = ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap()

		if unwrapped2.Variant.IsFoundation then
			return false, (`{getName(unwrapped, false, "Yellow")} is the base mutation and can't be unequipped.`)
		end

		if unwrapped2.Variant.VariantOf then
			local v10 = decodeAdorneeData(p3)
			local v11 = decodeModificationData(p2)
			local unwrapped3 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
			local unwrapped4 = ItemConfig.match(unwrapped3):unwrap()
			assert(unwrapped4.Variant.Mutation, (`bad mutation for {unwrapped4.Index.DebugLabel}`))

			if not (table.find(v10.Owned, unwrapped3) or table.find(v11.Unlocked, unwrapped4.Variant.Mutation)) then
				return
					false,
					(`You need ownership of {getName(unwrapped4, false, "Yellow")} to equip the base mutation.`)
			end
		end
	elseif unwrapped.Index.IdType == "Skin" and unwrapped.Skin and unwrapped.Skin.IsDefault then
		return false, (`{getName(unwrapped, false, "Yellow")} is the default skin and can't be unequipped.`)
	end

	if not Modification.getIfEquipped(unwrapped.Index.ItemId, p2, p3) then
		return false, (`{getName(unwrapped, false, "Yellow")} is already unequipped.`)
	end

	setCachedPerm(p, "Unequippable", true, p2, p3)
	return true
end

function Modification.getIfCanEquip(p: number, p2, p3)
	v.extend(".getIfCanEquip", true, "WARN").info((`fn called: (modId={p}, modificationData, adorneeData)`))
	local cachedPerm = findCachedPerm(p, "Equippable", p2, p3)

	if cachedPerm ~= nil then
		return cachedPerm
	end

	local v10 = decodeModificationData(p2)
	local unwrapped = ItemConfig.match(p):unwrap()

	-- [DEDUP] synthesized from 2 duplicated terminal regions
	local function deduplicatedTail()
		if table.find(v10.Unlocked, unwrapped.Index.ItemId) == nil then
			return false, (`You need to unlock the {getName(unwrapped, true, "Yellow")} before you can equip it`)
		end

		setCachedPerm(p, "Equippable", true, p2, p3)
		return true
	end

	local unwrapped2 = Modification.matchAdornee(unwrapped.Index.ItemId):unwrap()
	local v11 = decodeAdorneeData(p3)

	if unwrapped.Index.IdType == "Mutation" then
		local unwrapped3 = ItemConfig.Query.selectOne({
			Variant = {
				Mutation = unwrapped.Index.ItemId
			}
		}):unwrap()

		if unwrapped3.Index.ItemId == unwrapped2 then
			if not (table.find(v11.Owned, unwrapped2) or table.find(v10.Unlocked, unwrapped.Index.ItemId)) then
				return false, (`You need to unlock {getName(unwrapped, false, "Yellow")} to equip it`)
			end

			local flag = false

			for _, v13 in ItemConfig.map(Modification.getAllModifications(unwrapped2, "Mutation")) do
				if v13.Index.ItemId == unwrapped.Index.ItemId then
					continue
				end

				local unwrapped4 = ItemConfig.Query.selectOne({
					Variant = {
						Mutation = v13.Index.ItemId
					}
				}):unwrap()

				if not table.find(v11.Equipped, unwrapped4.Index.ItemId) then
					continue
				end

				flag = true
				break
			end

			if flag then
				setCachedPerm(p, "Equippable", true, p2, p3)
				return true
			end

			local unwrapped4 = ItemConfig.match(unwrapped2):unwrap()
			return false, (`You have already equipped the base mutation for {getName(unwrapped4, false, "Yellow")}`)
		else
			if table.find(v11.Equipped, unwrapped2) == nil or table.find(v11.Equipped, unwrapped3.Index.ItemId) ~= nil then
				local unwrapped4 = ItemConfig.match(unwrapped2):unwrap()
				return
					false,
					(`You need to own or equip {getName(unwrapped4, false, "Yellow")} to equip the the {getName(unwrapped, true, "Yellow")}`)
			end

			return deduplicatedTail()
		end
	elseif unwrapped.Index.IdType == "Skin" then
		if table.find(v10.Preferred, unwrapped.Index.ItemId) ~= nil then
			return false, (`You've already equipped the {getName(unwrapped, true, "Yellow")}`)
		end

		if table.find(v11.Equipped, unwrapped2) == nil then
			local unwrapped3 = ItemConfig.match(unwrapped2):unwrap()
			return false, (`You've need to equip {getName(unwrapped3, false, "Yellow")} before you can change skins.`)
		end

		if unwrapped.Skin and unwrapped.Skin.IsDefault then
			for _, v12 in ItemConfig.map(v10.Preferred) do
				if v12.Index.IdType == "Skin" and v12.Skin and v12.Skin.Adornee == unwrapped2 and v12.Index.ItemId ~= unwrapped.Index.ItemId then
					return true
				end
			end

			local unwrapped3 = ItemConfig.match(unwrapped2):unwrap()
			return false, (`You've already equipped the default skin for {getName(unwrapped3, false, "Yellow")}`)
		else
			return deduplicatedTail()
		end
	else
		if unwrapped.Index.IdType ~= "Equipment" then
			error((`unsupported mod id-type: {unwrapped.Index.IdType}`))
			return
		end

		if table.find(v10.Preferred, unwrapped.Index.ItemId) ~= nil then
			setCachedPerm(p, "Equippable", false, p2, p3)
			return false
		end

		if not table.find(v11.Equipped, unwrapped2) then
			setCachedPerm(p, "Equippable", false, p2, p3)
			return false
		end

		if table.find(v10.Unlocked, p) then
			setCachedPerm(p, "Equippable", true, p2, p3)
			return true
		end

		setCachedPerm(p, "Equippable", false, p2, p3)
		return false
	end
end

function Modification.getEquippable(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getEquippable()")
	v.extend(".getEquippable", true, "WARN").info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfCanEquip(v12, v11, v10) then
			table.insert(result, v12)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	debug.profileend()
	return result
end

function Modification.getEquipped(p, p2, p3: number?, p4)
	debug.profilebegin("ModUtil.getEquipped()")
	local extended = v.extend(".getEquipped", true, "WARN")
	extended.info((`fn called: (modificationData, adorneeData, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local result = {}

	for _, v12 in Modification.getAllModifications(p3, p4) do
		if Modification.getIfEquipped(v12, v11, v10) then
			local v13 = v12
			extended.trace(function()
				return (` - {ItemConfig.match(v13):unwrap().Index.DebugLabel} is equipped`)
			end)
			table.insert(result, v12)
		else
			local v13 = v12
			extended.trace(function()
				return (` - {ItemConfig.match(v13):unwrap().Index.DebugLabel} is not equipped`)
			end)
		end
	end

	TableUtil.deduplicate(result)
	table.sort(result)
	extended.trace(function()
		return "out", ItemConfig.mapDebug(ItemConfig.map(result))
	end)
	debug.profileend()
	return result
end

function Modification.getIfCanEat(physical: number, p2, p3, flag: boolean)
	local extended = v.extend(".getIfCanEat", true, "WARN")
	extended.info((`fn called: (physicalId={ItemConfig.match(physical):unwrap().Index.DebugLabel}, modificationData, adorneeData, isInCombat={flag})`))
	local v10 = nil
	local nullable = ItemConfig.Query.selectOne({
		Index = {
			IdType = "Mutation"
		},
		Mutation = {
			Physical = physical
		}
	}):asNullable()
	local trace = extended.trace
	local v12

	if nullable then
		v12 = nullable.Index.DebugLabel or nil
	end

	trace((`mutationConfig: {v12}`))
	local nullable2 = ItemConfig.Query.selectOne({
		Index = {
			IdType = "Skin"
		},
		Skin = {
			Physical = physical
		}
	}):asNullable()
	local trace2 = extended.trace
	local v14

	if nullable2 then
		v14 = nullable2.Index.DebugLabel or nil
	end

	trace2((`skinConfig: {v14}`))
	local v15

	if nullable == nil then
		v15 = nullable2 == nil
	else
		v15 = false
	end

	local flag2 = false
	local flag3 = false
	extended.trace((`isBoringFruit-1: {v15}`))

	if not v15 then
		if nullable then
			local unwrapped = ItemConfig.Query.selectOne({
				Variant = {
					Mutation = nullable.Index.ItemId
				}
			}):unwrap()

			if unwrapped.Variant.IsFoundation then
				extended.trace((`mutation variant "{unwrapped.Index.DebugLabel}" is boring`))
				flag3 = true
			end
		else
			flag3 = not nullable or false
		end

		if nullable2 and nullable2.Skin and nullable2.Skin.IsDefault then
			extended.trace("is just a boring default skin")
			flag2 = true
		else
			flag2 = not nullable2 or false
		end

		if flag3 or not flag then
			if flag2 and flag3 then
				extended.trace((`boring skin: {flag2}, boring mutation: {flag3}`))
				v15 = true
			end
		else
			return false, "<Color=Red>Cannot change Mutation while in combat.<Color=/>"
		end
	end

	if v15 then
		return true
	end

	if not flag3 and nullable then
		if Modification.getIfUnlocked(nullable.Index.ItemId, p2, p3) then
			v10 = `You have already unlocked the {getName(nullable, true, "Yellow")}`
		else
			extended.trace("mutated fruit, and you haven't unlocked it")
			return true
		end
	end

	if not flag2 and nullable2 then
		if Modification.getIfUnlocked(nullable2.Index.ItemId, p2, p3) then
			v10 = `You have already unlocked the {getName(nullable2, true, "Yellow")}`
		else
			extended.trace("skinned fruit, and you haven't unlocked it")
			return true
		end
	end

	extended.trace("nothing matched, returning false")
	return false, v10
end

function Modification.getEdibles(p, p2, flag: boolean, p3: number?, p4)
	debug.profilebegin("ModUtil.getEdibles()")
	v.extend(".getEdibles", true, "WARN").info((`fn called: (modificationData, adorneeData, isInComabt={flag}, adorneeId={p3}, modIdType={p4})`))
	local v10 = decodeAdorneeData(p2)
	local v11 = decodeModificationData(p)
	local physicals = {}

	for _, v12 in ItemConfig.Query.join({
		Skin = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	}, {
		Mutation = {
			Physical = {
				Operation = "NEQ",
				Value = nil
			}
		}
	}) do
		if v12.Mutation and v12.Mutation.Physical and Modification.getIfCanEat(v12.Mutation.Physical, v11, v10, flag) then
			table.insert(physicals, v12.Mutation.Physical)
		end

		if not (v12.Skin and v12.Skin.Physical and Modification.getIfCanEat(v12.Skin.Physical, v11, v10, flag)) then
			continue
		end

		table.insert(physicals, v12.Skin.Physical)
	end

	TableUtil.deduplicate(physicals)
	debug.profileend()
	return physicals
end

function Modification.getIfAdorneeEquipped(variantOf: number, p2)
	local v10 = decodeAdorneeData(p2)
	local v11 = ItemConfig.Query.select({
		Variant = {
			VariantOf = variantOf
		}
	})

	if #v11 > 0 then
		for _, v12 in v11 do
			if table.find(v10.Equipped, v12.Index.ItemId) then
				return false
			end
		end
	end

	return table.find(v10.Equipped, variantOf) ~= nil
end

function Modification.getEquippedAdornees(p)
	debug.profilebegin("ModUtil.getEquippedAdornees()")
	local v10 = decodeAdorneeData(p)
	local result = {}

	for _, v11 in Modification.getPossibleAdornees() do
		if Modification.getIfAdorneeEquipped(v11, v10) then
			table.insert(result, v11)
		end
	end

	debug.profileend()
	return result
end

function Modification.getOwnedAdornees(p)
	return table.clone(decodeAdorneeData(p).Owned)
end

function Modification.getUsableAdornees(p)
	local equippedAdornees = Modification.getEquippedAdornees(p)

	for _, v10 in Modification.getOwnedAdornees(p) do
		table.insert(equippedAdornees, v10)
	end

	TableUtil.deduplicate(equippedAdornees)
	table.sort(equippedAdornees)
	return equippedAdornees
end

function Modification.getEquippedModification(p: number, p2, p3, p4)
	for _, v10 in Modification.getAllModifications(p, p2) do
		if Modification.getIfEquipped(v10, p3, p4) then
			return v10
		end
	end

	return nil
end

function Modification.getPreferredModification(p: number, p2, p3, p4)
	for _, v10 in Modification.getAllModifications(p, p2) do
		if Modification.getIfPreferred(v10, p3, p4) then
			return v10
		end
	end

	return nil
end

function Modification.connectOnModificationPreferredForAdornee(p, p2: number, callback, p3, p4)
	local extended = v.extend(".connectOnSkinEquipped", true, "WARN")
	extended.info((`fn called: (player={p}, callback,cleanupOnDestroy={p3})`))
	assert(callback)
	assert(ItemReplicationService.IsInitialized, "ItemReplicationService is not initialized yet")
	local EQUIPPED_SKIN = nil
	local mutation = nil

	if p4 == "Skin" then
		EQUIPPED_SKIN = ItemReplicationService.KEYS.EQUIPPED_SKIN
		mutation = Modification.matchDefaultSkin(p2):asNullable()
	elseif p4 == "Mutation" then
		EQUIPPED_SKIN = ItemReplicationService.KEYS.PREFERRED_MUTATION
		local nullable = ItemConfig.match(p2):asNullable()

		if nullable then
			mutation = nullable.Variant.Mutation
		end
	else
		extended.warn((`unsupported mod type: {p4}`))
	end

	local callback2 = nil

	if ItemReplicationService.IS_CLIENT then
		callback2 = ItemReplicationService:ConnectOnItemKeyChanged(
			EQUIPPED_SKIN,
			p2,
			nil,
			function(p5: number?, _: number?)
				callback(p5 or mutation)
			end
		)
	elseif ItemReplicationService.IS_SERVER then
		callback2 = ItemReplicationService:ConnectOnItemKeyChanged(
			p,
			EQUIPPED_SKIN,
			p2,
			nil,
			function(p5: number?, _: number?)
				callback(p5 or mutation)
			end
		)
	end

	return function()
		if callback2 then
			callback2()
		end
	end
end

function Modification.connectOnModificationEquippedForEquippedAdornee(p, p2: number, callback, p3, p4)
	v.extend(".connectOnSkinEquipped", true, "WARN").info((`fn called: (player={p}, callback,cleanupOnDestroy={p3})`))
	assert(callback)
	assert(ItemReplicationService.IsInitialized, "ItemReplicationService is not initialized yet")
	local EQUIPPED_SKIN = nil

	if p4 == "Skin" then
		EQUIPPED_SKIN = ItemReplicationService.KEYS.EQUIPPED_SKIN
	elseif p4 == "Mutation" then
		EQUIPPED_SKIN = ItemReplicationService.KEYS.PREFERRED_MUTATION
	else
		warn((`unsupported mod type: {p4}`))
	end

	local flag = nil

	local function updateEquip()
		if ItemReplicationService.IS_CLIENT then
			flag = ItemReplicationService:ReadItem(ItemReplicationService.KEYS.IS_EQUIPPED, p2, nil)
		elseif ItemReplicationService.IS_SERVER then
			flag = ItemReplicationService:ReadItem(p, ItemReplicationService.KEYS.IS_EQUIPPED, p2, nil)
		end
	end

	if ItemReplicationService.IS_CLIENT then
		flag = ItemReplicationService:ReadItem(ItemReplicationService.KEYS.IS_EQUIPPED, p2, nil)
	elseif ItemReplicationService.IS_SERVER then
		flag = ItemReplicationService:ReadItem(p, ItemReplicationService.KEYS.IS_EQUIPPED, p2, nil)
	end

	local callback2 = nil
	local callback3 = nil

	if ItemReplicationService.IS_CLIENT then
		callback2 = ItemReplicationService:ConnectOnItemKeyChanged(
			EQUIPPED_SKIN,
			p2,
			nil,
			function(p5: number?, _: number?)
				if flag then
					callback(p5)
				end
			end
		)
		callback3 = ItemReplicationService:ConnectOnItemKeyChanged(
			ItemReplicationService.KEYS.IS_EQUIPPED,
			p2,
			nil,
			function(flag2: boolean?, _: boolean?)
				flag = flag2

				if flag then
					callback((ItemReplicationService:ReadItem(EQUIPPED_SKIN, p2, nil)))
				end
			end
		)
	elseif ItemReplicationService.IS_SERVER then
		callback2 = ItemReplicationService:ConnectOnItemKeyChanged(
			p,
			EQUIPPED_SKIN,
			p2,
			nil,
			function(p5: number?, _: number?)
				if flag then
					callback(p5)
				end
			end
		)
		callback3 = ItemReplicationService:ConnectOnItemKeyChanged(
			p,
			ItemReplicationService.KEYS.IS_EQUIPPED,
			p2,
			nil,
			function(flag2: boolean?, _: boolean?)
				flag = flag2

				if flag then
					callback((ItemReplicationService:ReadItem(p, EQUIPPED_SKIN, p2, nil)))
				end
			end
		)
	end

	return function()
		if callback2 then
			callback2()
		end

		if callback3 then
			callback3()
		end
	end
end

function Modification.getDecodeCache(buf: buffer, buf2: buffer)
	return newDecodeCache(decodeModificationData(buf), decodeAdorneeData(buf2))
end

return Modification