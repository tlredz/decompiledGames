local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local React = require(game.ReplicatedStorage.Packages.React)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local KEYS = require(game.ReplicatedStorage.ItemReplicationService.KEYS)
local ItemReplicationOverride = require(game.ReplicatedStorage.React.Contexts.ItemReplicationOverride)
local useMockState = require(game.ReplicatedStorage.React.Hooks.useMockState)
local useMockStateWriter = require(game.ReplicatedStorage.React.Hooks.useMockStateWriter)

function getFullKey(itemId, p: string?)
	if type(itemId) == "table" then
		itemId = itemId.ItemId
	end

	return (`{itemId}_{p}`)
end

function getMockKey(p, p2: number?, p3: string?)
	return (`REP_{p}_{p2}_{p3}`)
end

local ItemReplication = {}
ItemReplication.KEYS = KEYS

function ItemReplication.useMockDataWriter(p)
	return function(p2: number?, p3: string?, p4)
		useMockStateWriter(getMockKey(p, p2, p3), p4)
	end
end

function ItemReplication.use(p, callback, data)
	local v

	if data and data.Type == "ItemSpecific" then
		v = {}
		assert(v, "bad fields")

		for _, value in data.Values do
			v[getFullKey(value, value.NetworkedUID)] = value.Value
		end
	else
		v = nil
	end

	local value

	if data and data.Type == "All" then
		value = data.Value or nil
	else
		value = nil
	end

	return function(value2, p2, p3: string?)
		if type(value2) == "number" then
			p3 = p2
		end

		local v2 = nil

		if type(value2) == "number" then
			v2 = value2
		elseif type(value2) == "string" then
			v2 = ItemId.getId(value2, p2):asNullable()
		end

		local v3 = React.useContext(ItemReplicationOverride)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function readRaw()
			if ItemReplicationService.IsInitialized and ItemReplicationService.IS_CLIENT and v2 then
				return ItemReplicationService:ReadItem(p, v2, p3)
			end

			return nil
		end

		local function decode(p4)
			if callback then
				return callback(p4)
			end

			return p4
		end

		local ref = React.useRef(nil)
		local state, setState = React.useState(function()
			local current = readRaw() -- equivalent call inferred; original call site unknown
			ref.current = current
			return decode(current)
		end)
		local v4 = React.useMemo(function()
			if not v3 then
				return nil
			end

			local result = {}

			for _, v5 in v3 do
				if v5.Key == p then
					table.insert(result, v5)
				end
			end

			table.freeze(result)
			return result
		end, { v3, p })
		local v5 = React.useMemo(function()
			if not (v2 and v4) then
				return nil
			end

			for _, v6 in v4 do
				if v6.ItemId == v2 and v6.NetworkedUID == p3 then
					return v6
				end
			end

			return nil
		end, { v4, v2, p3 })
		React.useEffect(function()
			-- equivalent calls inferred from this helper; original call sites unknown
			local function apply(current)
				if current == ref.current then
					return
				end

				ref.current = current
				setState(decode(current))
			end

			if ItemReplicationService.IsInitialized and v2 then
				assert(ItemReplicationService.IS_CLIENT, "bad service")
				local v6 = ItemReplicationService:ConnectOnItemKeyChanged(p, v2, p3, function(current)
					if current == ref.current then
						return
					end

					ref.current = current
					setState(decode(current))
				end)
				local thread = task.spawn(function()
					apply(ItemReplicationService:ReadItem(p, v2, p3)) -- equivalent call inferred; original call site unknown
				end)
				return function()
					task.cancel(thread)
					v6()
				end
			else
				if ref.current == nil then
					return
				end

				ref.current = nil
				setState(decode(nil))
			end
		end, {
			p,
			v2,
			p3,
			ItemReplicationService.IsInitialized
		})
		local mockKey = getMockKey(p, v2, p3)
		local v7

		if v2 then
			if value then
				v7 = value
			elseif v then
				v7 = v[getFullKey(v2, p3)]
			end
		end

		local v8 = useMockState(mockKey, v7)

		if v8 then
			return v8:get()
		end

		if v5 then
			return v5.Value
		end

		return state
	end
end

function ItemReplication.useAll(p, callback)
	return function(p2)
		local state, setState = React.useState(table.freeze({}))
		local ref = React.useRef(state)
		ref.current = state
		local v = React.useContext(ItemReplicationOverride)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getIfFiltered(p3: number)
			return p2 ~= nil and not ItemConfig.Query.check(p3, p2)
		end

		local v2 = React.useMemo(function()
			if p2 and v then
				local clones = {}

				for _, v3 in v do
					if v3.Key ~= p then
						continue
					end

					-- equivalent call inferred; original call site unknown
					if not getIfFiltered(v3.ItemId) then
						table.insert(clones, table.freeze(table.clone(v3)))
					end
				end

				table.freeze(clones)
				return clones
			else
				if not v then
					return nil
				end

				local clones = {}

				for _, v3 in v do
					if v3.Key == p then
						table.insert(clones, table.freeze(table.clone(v3)))
					end
				end

				table.freeze(clones)
				return clones
			end
		end, { v })
		local v3 = React.useMemo(function()
			local v4

			if v2 then
				local clone = table.clone(state)

				for _, v5 in v2 do
					clone[getFullKey(v5, v5.NetworkedUID)] = {
						ItemId = v5.ItemId,
						NetworkedUID = v5.NetworkedUID,
						Value = v5.Value
					}
				end

				v4 = TableUtil.values(clone)
			else
				v4 = TableUtil.values(state)
			end

			table.freeze(v4)
			return v4
		end, { state, v2 })
		React.useEffect(function()
			if not ItemReplicationService.IsInitialized then
				return function() end
			end

			assert(ItemReplicationService.IS_CLIENT, "bad service")

			local function tryUpdate(itemId: number, networkedUID: string?, p5)
				-- equivalent call inferred; original call site unknown
				if getIfFiltered(itemId) then
					return
				end

				if callback then
					p5 = callback(p5) or p5
				end

				local v4 = {
					ItemId = itemId,
					NetworkedUID = networkedUID,
					Value = p5
				}
				table.freeze(v4)
				local fullKey = getFullKey(itemId, networkedUID)
				local clone = table.clone(ref.current)
				clone[fullKey] = v4
				ref.current = clone
				table.freeze(clone)
				setState(clone)
			end

			local v4 = ItemReplicationService:ConnectOnKeyChanged(p, function(itemId: number, networkedUID: string?, p5)
				tryUpdate(itemId, networkedUID, p5)
			end)
			local flag = false
			task.spawn(function()
				local items = ItemReplicationService:GetItems(p)

				if items then
					for _, item in items do
						if flag then
							break
						end

						tryUpdate(item.ItemId, item.NetworkedUID, item.Value)
					end
				end
			end)
			return function()
				flag = true
				v4()
			end
		end, { ItemReplicationService.IsInitialized })
		return v3
	end
end

return ItemReplication