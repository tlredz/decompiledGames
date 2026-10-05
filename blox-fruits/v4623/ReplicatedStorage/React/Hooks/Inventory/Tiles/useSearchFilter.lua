local React = require(game.ReplicatedStorage.Packages.React)
local ItemReplicationService = require(game.ReplicatedStorage.ItemReplicationService)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local AccessoriesShared = require(game.ReplicatedStorage.AccessoriesShared)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
return function(items, value: string?)
	local state, setState = React.useState({})
	local ref = React.useRef(state)
	React.useEffect(function()
		if not ItemReplicationService.IsInitialized then
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function tryUpdate(p: number, p2: string, p3)
			assert(p2, (`bad uid: {p}`))
			local formatted = `{p}-{p2}`
			local v = ref.current[formatted]

			local function setValue(p4)
				local clone

				if p4 then
					clone = table.clone(p4.Modifiers)
				end

				if clone then
					table.sort(clone)
					table.freeze(clone)
				end

				ref.current[formatted] = clone
				local clone2 = table.clone(ref.current)
				table.freeze(clone2)
				setState(clone2)
			end

			if v then
				if p3 then
					if #v ~= #p3.Modifiers then
						setValue(p3)
						return
					end

					for _, modifier in p3.Modifiers do
						if table.find(v, modifier) ~= nil then
							continue
						end

						setValue(p3)
						return
					end
				else
					ref.current[formatted] = nil
					local clone = table.clone(ref.current)
					table.freeze(clone)
					setState(clone)
				end
			elseif p3 then
				setValue(p3)
			end
		end

		assert(ItemReplicationService.IS_CLIENT, "bad service")
		local v = ItemReplicationService:ConnectOnKeyChanged(
			ItemReplicationService.KEYS.ACCESSORY_MODIFIERS,
			function(p: number, p2: string?, p3)
				local v2

				if p2 then
					v2 = AccessoriesShared.getReplicatedAccessoryItem(p, p2) or nil
				end

				if p3 and v2 then
					tryUpdate(p, p2, v2)
				elseif not p3 then
					tryUpdate(p, p2) -- equivalent call inferred; original call site unknown
				end
			end
		)
		local items2 = ItemReplicationService:GetItems(ItemReplicationService.KEYS.ACCESSORY_MODIFIERS)

		if items2 then
			for _, item in items2 do
				local value2 = item.Value
				local itemId = item.ItemId
				local networkedUID = item.NetworkedUID
				local v2

				if networkedUID then
					v2 = AccessoriesShared.getReplicatedAccessoryItem(itemId, networkedUID) or nil
				end

				if value2 and v2 then
					tryUpdate(itemId, networkedUID, v2)
				elseif not value2 then
					tryUpdate(itemId, networkedUID) -- equivalent call inferred; original call site unknown
				end
			end
		end

		return function()
			v()
		end
	end, { ItemReplicationService.IsInitialized })
	return React.useMemo(function()
		if not value or value:len() == 0 then
			return items
		end

		local v = value:lower():gsub("%s+", "")
		local result = {}

		for _, item in items do
			local unwrapped = ItemConfig.match(item.ItemId):unwrap()

			if (unwrapped.Display.Name or unwrapped.Index.StorageKey):lower():gsub("%s+", ""):find(v, 1, true) then
				table.insert(result, item)
			elseif unwrapped.Display.Category and unwrapped.Display.Category:lower():gsub("%s+", ""):find(v, 1, true) then
				table.insert(result, item)
			else
				local v2 = state[`{item.ItemId}-{item.NetworkedUID}`]

				if v2 then
					for _, v4 in v2 do
						if not v4:lower():gsub("%s+", ""):find(v, 1, true) then
							continue
						end

						table.insert(result, item)
						break
					end
				end
			end
		end

		return result
	end, { items, value, state })
end