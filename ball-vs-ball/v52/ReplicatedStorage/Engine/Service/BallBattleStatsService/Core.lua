local Core = {
	empty = function()
		return {
			opponents = {},
			mirror = {
				games = 0,
				draws = 0
			}
		}
	end
}

function Core.merge(p, p2)
	local clone = p and table.clone(p) or Core.empty()
	clone.opponents = table.clone(clone.opponents)
	clone.mirror = table.clone(clone.mirror)

	for k, opponent in pairs(p2.opponents) do
		local v = clone.opponents[k] or {
			wins = 0,
			losses = 0,
			draws = 0
		}
		clone.opponents[k] = {
			wins = v.wins + opponent.wins,
			losses = v.losses + opponent.losses,
			draws = v.draws + opponent.draws
		}
	end

	clone.mirror.games += p2.mirror.games
	clone.mirror.draws += p2.mirror.draws
	return clone
end

function Core.summarize(p)
	local total = 0
	local total2 = 0
	local total3 = 0

	for _, opponent in pairs(p.opponents) do
		total += opponent.wins
		total2 += opponent.losses
		total3 += opponent.draws
	end

	local games = total + total2 + total3
	local v2 = {
		opponents = p.opponents,
		mirror = 0,
		wins = 0,
		losses = 0,
		draws = 0,
		games = 0,
		winRate = 0,
		drawRate = 0
	}
	local mirror = {
		games = p.mirror.games,
		draws = p.mirror.draws,
		drawRate = 0
	}
	local drawRate

	if p.mirror.games > 0 then
		drawRate = p.mirror.draws / p.mirror.games
	end

	mirror.drawRate = drawRate
	v2.mirror = mirror
	v2.wins = total
	v2.losses = total2
	v2.draws = total3
	v2.games = games
	local winRate

	if games > 0 then
		winRate = total / games
	end

	v2.winRate = winRate
	local drawRate2

	if games > 0 then
		drawRate2 = total3 / games
	end

	v2.drawRate = drawRate2
	return v2
end

function Core.new(callback, callback2)
	local v = {}
	local v2 = {}
	local v3 = 1
	local count = 0
	local v4 = false
	local flag = false
	local v5 = {}

	local function getBall(p)
		if not v[p] then
			v[p] = Core.empty()
		end

		return v[p]
	end

	function v5.record(p, p2, p3)
		if flag or p3 ~= "ball1Win" and p3 ~= "ball2Win" and p3 ~= "draw" then
			return false
		end

		if p == p2 then
			if not v[p] then
				v[p] = Core.empty()
			end

			local mirror = v[p].mirror
			mirror.games += 1

			if p3 == "draw" then
				mirror.draws += 1
			end

			return true
		else
			-- equivalent calls inferred from this helper; original call sites unknown
			local function add(p4, p5, p6)
				if not v[p4] then
					v[p4] = Core.empty()
				end

				local v6 = v[p4]
				local opponent = v6.opponents[p5]

				if not opponent then
					opponent = {
						wins = 0,
						losses = 0,
						draws = 0
					}
					v6.opponents[p5] = opponent
				end

				opponent[p6] += 1
			end

			add(p, p2, p3 == "draw" and "draws" or p3 == "ball1Win" and "wins" or "losses") -- equivalent call inferred; original call site unknown
			add(p2, p, p3 == "draw" and "draws" or p3 == "ball2Win" and "wins" or "losses") -- equivalent call inferred; original call site unknown
			return true
		end
	end

	function v5.enqueue()
		local v6 = v
		v = {}
		local v7 = {}

		for k in pairs(v6) do
			table.insert(v7, k)
		end

		table.sort(v7)

		for _, id in ipairs(v7) do
			count += 1
			v2[count] = {
				id = id,
				delta = v6[id]
			}
		end

		return #v7
	end

	function v5.step()
		if v4 or count < v3 then
			return false
		end

		local v6 = v2[v3]
		v2[v3] = nil
		v3 += 1
		v4 = true
		local success, result = pcall(callback, v6.id, v6.delta)
		v4 = false

		if count < v3 then
			v3 = 1
			count = 0
		end

		if not success then
			if not flag then
				v[v6.id] = Core.merge(v[v6.id], v6.delta)
			end

			callback2(v6.id, result, not flag)
		end

		return true
	end

	function v5.close()
		flag = true
		v5.enqueue()
	end

	function v5.hasWork()
		return v4 or v3 <= count
	end

	return v5
end

return Core