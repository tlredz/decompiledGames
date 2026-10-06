local v = {
	ball_hit = true,
	blade_hit = true,
	zone_tick = true,
	vampire_tick = true,
	spider_web_hit = true,
	vampire_web_hit = true,
	poison_spike_hit = true,
	poison_tick = true,
	volcano_burn_tick = true
}

local function teamHp(state, p: string)
	local v2 = state.teams and state.teams[p]

	if not v2 then
		local ball = state.balls[p]
		return ball and ball.hp or 0
	end

	local total = 0

	for _, v3 in v2 do
		local ball = state.balls[v3]
		total += ball and ball.hp or 0
	end

	return total
end

local function teamMaxHp(state, winner: string)
	local v2 = state.teams and state.teams[winner]

	if not v2 then
		local ball = state.balls[winner]
		return ball and ball.maxHp or 0
	end

	local total = 0

	for _, v3 in v2 do
		local ball = state.balls[v3]
		total += ball and ball.maxHp or 0
	end

	return total
end

local function countLeadChanges(hpTrack)
	local v2 = 0
	local count = 0

	for _, item in hpTrack do
		local v3 = item.blue - item.yellow
		local v4 = v3 > 0.001 and 1 or v3 < -0.001 and -1 or 0

		if v4 == 0 then
			continue
		end

		if v2 ~= 0 and v4 ~= v2 then
			count += 1
		end

		v2 = v4
	end

	return count
end

local function countActionEvents(items)
	local count = 0

	for _, item in items do
		if v[item.type] then
			count += 1
		end
	end

	return count
end

local function winnerMinHpRatio(hpTrack, winner: string, maxHp: number)
	if maxHp <= 0 then
		return 1
	end

	local v2 = winner == "Blue" and "blue" or "yellow"
	local v3 = 1e999

	for _, item in hpTrack do
		local v4 = item[v2]

		if v4 > 0 and v4 < v3 then
			v3 = v4
		end
	end

	if v3 == 1e999 then
		return 1
	end

	return v3 / maxHp
end

-- equivalent calls inferred from this helper; original call sites unknown
local function durationDesirability(duration: number, excitementSweetSpotDuration: number, maxDuration: number)
	if maxDuration - 0.001 <= duration then
		return 0
	end

	return (math.max(0, 1 - math.abs(duration - excitementSweetSpotDuration) / excitementSweetSpotDuration))
end

return {
	score = function(data, p)
		if data.winner ~= "Blue" and data.winner ~= "Yellow" then
			return -1000
		end

		local hpTrack = data.hpTrack

		if not hpTrack then
			hpTrack = {}

			for _, snapshot in data.snapshots do
				table.insert(hpTrack, {
					blue = teamHp(snapshot.state, "Blue"),
					yellow = teamHp(snapshot.state, "Yellow")
				})
			end
		end

		local maxHp = data.initialMaxHp and data.initialMaxHp[data.winner] or not (data.snapshots and data.snapshots[1]) and 0 or teamMaxHp(
			data.snapshots[1].state,
			data.winner
		) or 0

		if maxHp <= 0 then
			local role = data.roles[data.winner]
			local role2 = p.roles[role]
			maxHp = role2 and role2.maxHp or 100
		end

		local v2 = countLeadChanges(hpTrack)
		local count = 0

		for _, event in data.events do
			if v[event.type] then
				count += 1
			end
		end

		local v3 = count / math.max(data.duration, 1)
		local v4 = 1 - winnerMinHpRatio(hpTrack, data.winner, maxHp)
		local duration = data.duration
		local excitementSweetSpotDuration = p.replay.excitementSweetSpotDuration or 20
		local v5 = durationDesirability(duration, excitementSweetSpotDuration, p.replay.maxDuration) -- equivalent call inferred; original call site unknown
		return v2 * 3 + v3 * 2 + v4 * 5 + v5 * 4
	end
}