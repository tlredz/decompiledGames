local RunService = game:GetService("RunService")
local Result = require(game.ReplicatedStorage.Packages.Result)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local Display = require(game.ReplicatedStorage.Packages.Display)
local Types = require(script.Parent.Types)
local Bake = require(script.Parent.Bake)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local TempIds = require(game.ReplicatedStorage.Economy.ItemId.TempIds)
local Index = require(script.Parent.Data.Index)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local TempConfigs = require(script.Parent.TempConfigs)
local FunctionCache = require(game.ReplicatedStorage.Util.FunctionCache)
local LoggerBuilder = require(game.ReplicatedStorage.Util.LoggerBuilder)
local v = LoggerBuilder.new():tag("ItemConfig"):display():traceback():minLevel("WARN"):build()
local isServer = RunService:IsServer()
local v2 = false
local generated = script.Parent:FindFirstChild("Generated")
local configs

if generated then
	configs = generated:FindFirstChild("Configs")
end

local module

if configs then
	module = require(configs)
end

local loaded

if module and Bake.isFresh(module) then
	loaded = Bake.load(module)
	v2 = true
else
	if module then
		warn("ItemConfig.Generated.Configs is stale, parsing raw item config data instead - rerun the data build")
	end

	loaded = Bake.parse()
end

local function getKey(p: string, p2: string)
	return (`"{p}"_{p2}`)
end

local itemIds = {}

for _, v3 in loaded do
	if not v3:isOk() then
		continue
	end

	local unwrapped = v3:unwrap()
	itemIds[`"{unwrapped.Index.StorageKey}"_{unwrapped.Index.IdType}`] = unwrapped.Index.ItemId
end

local tempConfigs = {}

for k, tempConfig in TempConfigs do
	local itemId = #loaded + 1
	local tempId = TempIds[k]

	if tempId then
		if tempConfig.Index.StorageKey == tempId.StorageKey then
			if tempConfig.Index.IdType == tempId.Type then
				tempConfig.Index.ItemId = itemId
				local formatted = `{tempConfig.Index.StorageKey} [{tempConfig.Index.IdType}-{itemId}]`
				tempConfig.Index.DebugLabel = formatted
				assert(tempConfig.State, (`state field is required for temp config "{formatted}"`))
				assert(
					tempConfig.State.StorageMethod,
					(`State.StorageMethod field is required for temp config "{formatted}"`)
				)
				itemIds[`"{tempConfig.Index.StorageKey}"_{tempConfig.Index.IdType}`] = tempConfig.Index.ItemId
				loaded[itemId] = Result.ok(tempConfig)
				tempConfigs[itemId] = tempConfig
			else
				loaded[itemId] = Result.err((`Temp ItemId {itemId} Type mismatch: expected {tempId.Type}, got {tempConfig.Index.IdType}`))
			end
		else
			loaded[itemId] = Result.err((`Temp ItemId {itemId} StorageKey mismatch: expected {tempId.StorageKey}, got {tempConfig.Index.StorageKey}`))
		end
	else
		loaded[itemId] = Result.err((`Temp ItemId {itemId} does not exist in TempItemIds`))
	end
end

for _, v3 in tempConfigs do
	Bake.swapSprites(v3)
	local v4 = v3

	local function swapItemIdRef(p, p2)
		if not p then
			return
		end

		local v5 = p[p2]

		if not v5 then
			return
		end

		assert(type(v5) == "table", (`expected table, received "{type(v5)}" for {v4.Index.DebugLabel}`))
		local v6 = itemIds[`"{v5.StorageKey}"_{v5.IdType}`]
		assert(
			type(v6) == "number",
			(`bad item-id reference "{v5.StorageKey}" of type "{v5.IdType}" for {v4.Index.DebugLabel}`)
		)
		p[p2] = v6
	end

	swapItemIdRef(v3.Skin, "Physical")
	swapItemIdRef(v3.Skin, "Adornee")
	swapItemIdRef(v3.Moveset, "Physical")
	swapItemIdRef(v3.Moveset, "SkillRedirect")
	swapItemIdRef(v3.Variant, "VariantOf")
	swapItemIdRef(v3.Mutation, "Mutation")
	swapItemIdRef(v3.Equipment, "Adornee")
	swapItemIdRef(v3.Economy, "PurchaseWith")
	swapItemIdRef(v3.Mutation, "Adornee")
	swapItemIdRef(v3.Mutation, "Physical")
	local quality = v3.Quality
	local rarityValue

	if v3.Quality.Rarity then
		rarityValue = PseudoEnum.getValueFromEnumItem("Rarity", v3.Quality.Rarity) or nil
	end

	quality.RarityValue = rarityValue

	if isServer then
		if v3.Index.IdType == "PhysicalMoveset" then
			local child = game.ServerStorage.Fruits:FindFirstChild(v3.Index.StorageKey)

			if child then
				child:SetAttribute("ItemId", v3.Index.ItemId)
			end
		else
			local child = (v3.State.StorageMethod == "Items" or v3.State.StorageMethod == "Accessories") and game.ServerStorage.Items:FindFirstChild(v3.Index.StorageKey)

			if child then
				child:SetAttribute("ItemId", v3.Index.ItemId)
			end
		end
	end

	Types.finalize(v3)
end

for k, _ in TempIds do
	local v3 = #Index + k

	if not loaded[v3] then
		loaded[v3] = Result.err((`Temp ItemId {v3} does not have a matching config in TempConfigs`))
	end
end

table.freeze(loaded)
local Storage = {}

local function fn(itemId, value2)
	if typeof(itemId) ~= "number" then
		local v3 = typeof(itemId) == "string"
		local v5

		if type(itemId) == "table" then
			v5 = Display.JSON.new():display(itemId)
		else
			v5 = itemId
		end

		assert(v3, (`expected storage key to be a string, received {v5} (type "{type(itemId)}")`))
		assert(
			type(value2) == "string",
			`expected idType for key "{itemId}" to be a string, received ` .. typeof(value2)
		)
		local id = ItemId.getId(itemId, value2)

		if not id:isOk() then
			return Result.err((`StorageKey {itemId} of type {value2} encountered "{id:unwrapErr().Type}" error`))
		end

		itemId = id:unwrap()
	end

	assert(itemId, "bad itemId")

	if loaded[itemId] then
		return loaded[itemId]
	end

	local dataFromId = ItemId.getDataFromId(itemId)

	if not dataFromId:isOk() then
		return Result.err((`ItemId {itemId} does not exist`))
	end

	local v3 = {
		Index = {
			ItemId = itemId,
			StorageKey = dataFromId:unwrap().StorageKey,
			IdType = dataFromId:unwrap().Type,
			DoNotUse = false,
			DebugLabel = `{dataFromId:unwrap().StorageKey} [{dataFromId:unwrap().Type}]`
		},
		Display = {},
		Inventory = {
			Category = "Tool",
			Groups = { "Backpack" },
			Brackets = { "Gear" },
			Actions = {},
			Tags = {},
			TileOverlays = {},
			OutlineAppearance = PseudoEnum.InventoryOutlineAppearance.Solid,
			TileAppearance = PseudoEnum.InventoryTileAppearance.Elevated
		},
		Quality = {
			Rarity = "Common",
			RarityValue = 0
		},
		State = {
			StorageMethod = PseudoEnum.ItemStorageMethod.StoredFruits
		},
		Variant = {}
	}
	TableUtil.deepFreeze(v3)
	return Result.ok(v3)
end

local v3 = FunctionCache.new(function(p, p2)
	return fn(p, p2)
end, function(p, p2)
	return (`{p}_{p2}`)
end)

function Storage.match(value, p)
	local extended = v.extend(".match", nil, "FATAL")
	extended.info(function()
		if type(value) == "number" and type(p) == "nil" then
			return (`call fn (itemId={value})`)
		end

		return (`call fn (storageKey={value}, idType={p})`)
	end)
	local v4 = v3:call(value, p)

	if v4:isOk() then
		extended.trace(function()
			return (`returned item config "{v4:unwrap().Index.DebugLabel}"`)
		end)
		return v4
	end

	extended.error(function()
		return (`returning error {v4:unwrapErr()}`)
	end)
	return v4
end

function Storage.map(list)
	local extended = v.extend(".map", nil, "INFO")
	extended.info(function()
		return (`called fn (itemIds=#{#list})`)
	end)
	extended.trace(function()
		return "itemIds", list
	end)
	local result = {}

	for _, v4 in list do
		table.insert(result, Storage.match(v4):unwrap())
	end

	extended.trace(function()
		local debugLabels = {}

		for _, v4 in result do
			table.insert(debugLabels, v4.Index.DebugLabel)
		end

		return "returning", debugLabels
	end)
	return result
end

function Storage.mapIds(list)
	local extended = v.extend(".map", nil, "INFO")
	extended.info(function()
		return (`called fn (itemConfigs=#{#list})`)
	end)
	extended.trace(function()
		local debugLabels = {}

		for _, v4 in list do
			table.insert(debugLabels, v4.Index.DebugLabel)
		end

		return "itemConfigs", debugLabels
	end)
	local itemIds2 = {}

	for _, v4 in list do
		table.insert(itemIds2, v4.Index.ItemId)
	end

	extended.trace(function()
		return "returning ", itemIds2
	end)
	return itemIds2
end

function Storage.tryGet(p, p2)
	return Storage.match(p, p2):asNullable()
end

function Storage.usesBakedConfigs()
	return v2
end

local v4 = FunctionCache.new(function()
	return Bake.collectItems(loaded)
end, function()
	return ""
end)

function Storage.dumpItems()
	return table.clone(v4:call())
end

local v5 = FunctionCache.new(function()
	local result = {}

	for _, v6 in loaded do
		if v6:isErr() then
			table.insert(result, v6:unwrapErr())
		end
	end

	return result
end, function()
	return ""
end)

function Storage.dumpErrors()
	return table.clone(v5:call())
end

return Storage