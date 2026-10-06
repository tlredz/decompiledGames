return {
	new = function(p)
		local map = p.map
		local now = p.now

		local function clean(p2)
			p2.leases = p2.leases or {}

			for k, leas in p2.leases do
				if leas.expires <= now() then
					p2.leases[k] = nil
				end
			end

			return p2
		end

		local function count(p2)
			local count2 = 0

			for _ in p2.online or {} do
				count2 += 1
			end

			for _, leas in p2.leases do
				for _ in leas.users do
					count2 += 1
				end
			end

			return count2
		end

		local v = {
			publish = function(p2, online, p4, ready, value)
				return map:UpdateAsync("server:" .. p2, function(p6)
					local v2 = clean(p6 or {
						leases = {}
					})
					v2.rosters = v2.rosters or {}

					if value then
						v2.rosters.boot = nil
					end

					v2.rosters[value or "boot"] = {
						online = online,
						ready = ready,
						updatedAt = now()
					}
					local online2 = {}
					local ready2 = false

					for k, roster in v2.rosters do
						if now() - roster.updatedAt > 90 then
							v2.rosters[k] = nil
						else
							for k2 in roster.online do
								online2[k2] = true
							end

							ready2 = ready2 or roster.ready
						end
					end

					v2.online = online2
					v2.capacity = math.min(24, p4)
					v2.ready = ready2
					v2.updatedAt = now()

					for k, leas in v2.leases do
						for k2 in leas.users do
							if online2[k2] then
								leas.users[k2] = nil
							end
						end

						if next(leas.users) == nil then
							v2.leases[k] = nil
						end
					end

					return v2
				end, 120)
			end,
			claim = function(p2, p3, list)
				local v2 = map:UpdateAsync("server:" .. p2, function(p4)
					if not p4 then
						return nil
					end

					local v3 = clean(p4)

					if not v3.ready or now() - (v3.updatedAt or 0) > 45 then
						return nil
					end

					if v3.leases[p3] then
						return v3
					end

					local users = {}
					local count2 = 0

					for _, v5 in list do
						local v6 = tostring(v5)
						local v7 = v3.online and v3.online[v6]

						for _, leas in v3.leases do
							if leas.users[v6] then
								v7 = true
							end
						end

						if v7 then
							continue
						end

						users[v6] = true
						count2 += 1
					end

					if count2 ~= #list or count(v3) + count2 > v3.capacity then
						return nil
					end

					v3.leases[p3] = {
						users = users,
						expires = now() + 75
					}
					return v3
				end, 120)
				return v2 and v2.leases and v2.leases[p3] ~= nil
			end,
			release = function(p2, p3, items)
				map:UpdateAsync("server:" .. p2, function(p4)
					if not p4 then
						return nil
					end

					local v2 = clean(p4)
					local leas = v2.leases[p3]

					if leas and items then
						for _, item in items do
							leas.users[tostring(item)] = nil
						end

						if next(leas.users) == nil then
							v2.leases[p3] = nil
							return v2
						end
					else
						v2.leases[p3] = nil
					end

					return v2
				end, 120)
			end
		}

		function v.create(p2, p3, owner, callback)
			local v2 = "create:" .. p2 .. ":" .. tostring(p3)
			local v3 = map:UpdateAsync(v2, function(p5)
				if p5 and p5.expires > now() then
					return p5
				end

				return {
					owner = owner,
					expires = now() + 20
				}
			end, 45)

			if v3.code then
				return v3.code, v3.privateId
			end

			if v3.owner ~= owner then
				return nil
			end

			local code, privateId = callback()
			local v6 = map:UpdateAsync(v2, function(p5)
				if p5 and p5.owner == owner then
					return {
						owner = owner,
						code = code,
						privateId = privateId,
						expires = now() + 30
					}
				end

				return nil
			end, 45)

			if not v6 or v6.code ~= code then
				return nil
			end

			v.publish(code, {}, 24, true)
			return code, privateId
		end

		return v
	end
}