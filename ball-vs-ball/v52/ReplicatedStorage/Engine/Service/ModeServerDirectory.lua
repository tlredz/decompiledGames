local function shardFor(value)
	local v = 0

	for i = 1, #value do
		v = (v * 31 + string.byte(value, i)) % 16
	end

	return v + 1
end

return {
	new = function(data)
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {}
		local clock = data.clock
		local wallTime = data.wallTime
		local random = data.random

		local function shardMap(p, p2)
			return data.getMap("ModeServersV2_" .. p .. "_" .. tostring(p2))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function legacyMap(p)
			local v6 = p == "standard" and "ModeTeleport_StandardLobbiesV1" or p .. "_ReservedServerRegistryV1"
			return data.getMap(v6)
		end

		local function eligible(item, p)
			if type(item) ~= "table" or item.admissionVersion ~= 1 or not item.ready then
				return false
			end

			if type(item) ~= "table" or type(item.jobId) ~= "string" or item.jobId == "" or item.jobId == data.jobId then
				return false
			end

			if type(item.privateServerId) ~= "string" then
				return false
			end

			if item.privateServerId ~= "" then
				if item.privateServerId == data.privateServerId or (type(item.accessCode) ~= "string" or item.accessCode == "") then
					return false
				end
			end

			local v6 = wallTime() - (tonumber(item.updatedAt) or 0)

			if v6 < 0 or v6 > 60 then
				return false
			end

			local maxPlayers

			if item.pool == "standard" then
				maxPlayers = tonumber(item.maxPlayers)
			else
				maxPlayers = math.min(24, tonumber(item.maxPlayers) or 24)
			end

			if (maxPlayers or 0) < (tonumber(item.playerCount) or 1e999) + p then
				return false
			end

			local accessCode = item.accessCode or item.jobId
			return (v5[accessCode] or 0) <= clock()
		end

		local function choose(items, p)
			local v6 = {}

			for _, item in items do
				if eligible(item, p) then
					table.insert(v6, item)
				end
			end

			if #v6 == 0 then
				return nil
			end

			if v6[1].pool == "standard" then
				return v6[random(1, #v6)]
			end

			local v7 = 0

			for _, v8 in v6 do
				v7 = math.max(v7, tonumber(v8.playerCount) or 0)
			end

			local v8 = {}

			for _, v9 in v6 do
				local playerCount = tonumber(v9.playerCount) or 0

				if v7 - 3 <= playerCount then
					table.insert(v8, v9)
				end
			end

			v6 = v8
			return v6[random(1, #v6)]
		end

		local function read(object, pool)
			local rangeAsync = object:GetRangeAsync(Enum.SortDirection.Descending, 20)
			local clones = {}

			for _, v6 in rangeAsync do
				if type(v6.value) ~= "table" then
					continue
				end

				local clone = table.clone(v6.value)
				clone.pool = pool
				table.insert(clones, clone)
			end

			return clones
		end

		local function refresh(pool, p2)
			local result = {}
			local v6 = random(1, 16)
			local v7 = random(1, 15)

			if v6 <= v7 then
				v7 += 1
			end

			for _, v8 in { v6, v7 } do
				for _, v9 in read(data.getMap("ModeServersV2_" .. pool .. "_" .. tostring(v8)), pool) do
					table.insert(result, v9)
				end

				if choose(result, p2) then
					return result
				end
			end

			local v8 = v3[pool]

			if not v8 or v8.expires <= clock() then
				v8 = {
					rows = 0,
					expires = 0
				}
				v8.rows = read(legacyMap(pool), pool)
				v8.expires = clock() + 30
				v3[pool] = v8
			end

			for _, row in v8.rows do
				table.insert(result, row)
			end

			return result
		end

		return {
			pick = function(p, p2)
				local v6 = v2[p]

				if not v6 or v6.expires <= clock() then
					local v7 = v4[p]

					if v7 then
						v7.Event:Wait()
						v6 = v2[p]
					else
						local signal = data.newSignal()
						v4[p] = signal
						local success, result = pcall(refresh, p, p2)
						v6 = {
							rows = not success and {} or result,
							error = 0,
							expires = 0
						}
						local error

						if not success then
							error = tostring(result)
						end

						v6.error = error
						v6.expires = clock() + 10
						v2[p] = v6
						v4[p] = nil
						signal:Fire()
						signal:Destroy()
					end
				end

				if v6.error then
					return nil, v6.error
				end

				return choose(v6.rows, p2), nil
			end,
			exclude = function(p)
				local accessCode = p.accessCode or p.jobId

				if accessCode then
					v5[accessCode] = clock() + 30
				end

				for k, v6 in v5 do
					if v6 <= clock() then
						v5[k] = nil
					end
				end
			end,
			publish = function(p, p2)
				local jobId = p2.jobId
				local v6 = 0
				local v7 = {}

				for i = 1, #jobId do
					v6 = (v6 * 31 + string.byte(jobId, i)) % 16
				end

				local v8 = v6 + 1
				do local _values = table.pack(data.getMap("ModeServersV2_" .. p .. "_" .. tostring(v8)), legacyMap(p)); for _k = 1, _values.n do v7[_k] = _values[_k] end end
				local v9 = {}

				for _, v10 in v7 do
					local success, result = pcall(v10.SetAsync, v10, p2.jobId, p2, 90, p2.updatedAt)

					if not success then
						table.insert(v9, (tostring(result)))
					end
				end

				if #v9 > 0 then
					return false, table.concat(v9, "; ")
				end

				return true
			end,
			remove = function(p, value)
				local v6 = 0
				local v7 = {}

				for i = 1, #value do
					v6 = (v6 * 31 + string.byte(value, i)) % 16
				end

				local v8 = v6 + 1
				do local _values = table.pack(data.getMap("ModeServersV2_" .. p .. "_" .. tostring(v8)), legacyMap(p)); for _k = 1, _values.n do v7[_k] = _values[_k] end end

				for _, v9 in v7 do
					pcall(v9.RemoveAsync, v9, value)
				end
			end
		}
	end
}