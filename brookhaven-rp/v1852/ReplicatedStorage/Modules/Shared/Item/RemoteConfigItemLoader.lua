local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local ItemRegistry = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistry)
local ItemRegistryMiddleware = require(ReplicatedStorage.Modules.Shared.Item.ItemRegistryMiddleware)
local RemoteConfig = require(ReplicatedStorage.Modules.Shared.RemoteConfig)
local t = require(ReplicatedStorage.Packages.t)
local RemoteConfigItemLoader = {}

function RemoteConfigItemLoader.Load()
	local expect = RemoteConfig.getLiveOpsPath("Items/Files"):expect()
	local clones = {}

	for k, _ in expect do
		local v = k
		local v2 = k
		xpcall(function()
			local expect2 = RemoteConfig.getLiveOpsPath(v):expect()

			for k2, v3 in expect2 do
				table.insert(clones, table.clone(v3))
			end
		end, function()
			warn(debug.traceback("Failed to load config " .. v2 .. ": "))
		end)
	end

	for _, v in RemoteConfigItemLoader.Join(clones) do
		local name = v.Name
		local v2 = v
		local name2 = name
		xpcall(function()
			local deserializeMut = ItemDeserializer.DeserializeMut(v2)
			local registries = v2.Registries or {}
			v2.Registries = nil
			local v5 = ItemRegistryMiddleware.ApplyMiddleware(v2, deserializeMut)

			for k, v6 in v2 do
				error((`Unknown parameter on item {name}: {k} = '{v6}'`))
			end

			ItemRegistry.RegisterItem(v5, RemoteConfigItemLoader.DeserializeRegistries(registries))
		end, function(p)
			warn(debug.traceback("Failed to load item: " .. name2 .. "\n" .. p))
		end)
	end

	ItemRegistry.Freeze()
end

function RemoteConfigItemLoader.Join(items)
	local v = {}
	local v2 = {}

	for _, item in items do
		local name = item.Name

		if name == nil or name == "" then
			error("Item exists with no name")
		end

		if v[name] then
			warn((`Skipping additional duplicate item: {name}`))
		else
			local v3 = v2[name]

			if v3 == nil then
				v2[name] = item
			elseif item.Join and v3.Join then
				local flag = false

				for k, v5 in item do
					if not (k ~= "Name" and k ~= "Join") then
						continue
					end

					if v3[k] == nil then
						v3[k] = v5
					else
						warn((`Keys may not be duplicated: Key {k} for item {name}.`))
						flag = true
						break
					end
				end

				if flag then
					v2[name] = nil
					v[name] = true
				end
			else
				warn((`Duplicate items specified: {name}. Set "Join" to true if this is intentional and you want to merge their values`))
				v2[name] = nil
				v[name] = true
			end
		end
	end

	local result = {}

	for _, v3 in v2 do
		v3.Join = nil
		table.insert(result, v3)
	end

	return result
end

function RemoteConfigItemLoader.DeserializeRegistries(items)
	assert(t.table(items))
	local result = {}

	for _, item in items do
		local parts = item:split("=")

		if #parts == 2 then
			result[parts[1]] = assert(tonumber(parts[2]), (`{parts[2]} must be a number`))
		elseif #parts == 1 then
			result[parts[1]] = 0
		else
			assert(false, "registry invalid, must contain 0 or 1 equals signs")
		end
	end

	return result
end

return RemoteConfigItemLoader