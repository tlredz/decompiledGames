local parent = script.Parent
local BattleConfig = require(parent:WaitForChild("BattleConfig"))
local BattleSimulation = require(parent:WaitForChild("BattleSimulation"))
local BattleReplayBuilder = require(parent:WaitForChild("BattleReplayBuilder"))
local DeterminismParityTest = {}
local v = {
	"position",
	"direction",
	"hp",
	"currentSpeed",
	"radius",
	"team",
	"roleId"
}

-- equivalent calls inferred from this helper; original call sites unknown
local function describeValue(p)
	if typeof(p) == "Vector2" then
		return string.format("(%.9f, %.9f)", p.X, p.Y)
	end

	return (tostring(p))
end

local function valuesEqual(value, p)
	if typeof(value) ~= typeof(p) then
		return false
	end

	if typeof(value) == "number" then
		return math.abs(value - p) <= 1e-9
	end

	if typeof(value) ~= "Vector2" then
		return value == p
	end

	return math.abs(value.X - p.X) <= 1e-9 and math.abs(value.Y - p.Y) <= 1e-9
end

local function countKeys(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count
end

local function runLockstep(BattleConfig2, p: number, data)
	local fixedDt = data and data.fixedDt or BattleConfig2.replay.fixedDt
	local v2 = math.max(1, (math.ceil((data and data.maxDuration or BattleConfig2.replay.maxDuration) / fixedDt)))
	local new = BattleSimulation.new
	local selectedRoles

	if data then
		selectedRoles = data.selectedRoles or nil
	end

	local selectedSecondaryTraits

	if data then
		selectedSecondaryTraits = data.selectedSecondaryTraits or nil
	end

	local v3

	if data then
		v3 = data.statLevels or nil
	end

	local v4 = new(BattleConfig2, p, selectedRoles, selectedSecondaryTraits, v3, data and data.initialDirections or nil)
	local state = v4:getState()
	local count = 0

	for _ = 1, v2 do
		state = v4:step(fixedDt)
		count += 1

		if state.finished then
			break
		end
	end

	if not state.finished then
		state.finished = true
		state.winner = "Draw"
	end

	return state, count
end

function DeterminismParityTest.runCase(blue: string, yellow: string, p3: number, options)
	assert(BattleConfig.roles[blue] ~= nil, string.format("[DeterminismParityTest] 未知球角色: %s", blue))
	assert(BattleConfig.roles[yellow] ~= nil, string.format("[DeterminismParityTest] 未知球角色: %s", yellow))
	local v2 = options or {}
	local v3 = {
		fixedDt = BattleConfig.replay.fixedDt,
		snapshotInterval = BattleConfig.replay.snapshotInterval,
		maxDuration = BattleConfig.replay.maxDuration,
		selectedRoles = {
			Blue = blue,
			Yellow = yellow
		},
		statLevels = v2.statLevels,
		selectedSecondaryTraits = v2.selectedSecondaryTraits,
		initialDirections = v2.initialDirections
	}
	local replay = BattleReplayBuilder.buildReplay(BattleConfig, p3, v3)
	local state = replay.snapshots[#replay.snapshots].state
	local v4 = runLockstep(BattleConfig, p3, v3)
	local failures = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fail(p4: string)
		table.insert(failures, p4)
	end

	if replay.winner ~= v4.winner then
		fail(string.format("winner 不一致: buildReplay=%s lockstep=%s", tostring(replay.winner), (tostring(v4.winner)))) -- equivalent call inferred; original call site unknown
	end

	if not valuesEqual(replay.duration, v4.elapsed) then
		fail(string.format("duration 不一致: buildReplay=%.9f lockstep=%.9f", replay.duration, v4.elapsed)) -- equivalent call inferred; original call site unknown
	end

	local count = 0

	for _ in state.balls do
		count += 1
	end

	local count2 = 0

	for _ in v4.balls do
		count2 += 1
	end

	if count == count2 then
		for k, ball in state.balls do
			local ball2 = v4.balls[k]

			if ball2 then
				for _, v6 in v do
					if valuesEqual(ball[v6], ball2[v6]) then
						continue
					end

					local v8 = tostring(k)
					local v10 = describeValue(ball[v6]) -- equivalent call inferred; original call site unknown
					fail(string.format(
						"球 %s 的 %s 不一致: buildReplay=%s lockstep=%s",
						v8,
						v6,
						v10,
						describeValue(ball2[v6])
					)) -- equivalent call inferred; original call site unknown
				end
			else
				fail(string.format("lockstep 末帧缺少球: %s", (tostring(k)))) -- equivalent call inferred; original call site unknown
			end
		end
	else
		fail(string.format("末帧球数不一致: buildReplay=%d lockstep=%d", count, count2)) -- equivalent call inferred; original call site unknown
	end

	local passed = #failures == 0
	print(string.format(
		"[DeterminismParityTest] %s %s vs %s seed=%d winner=%s duration=%.3f",
		passed and "PASS" or "FAIL",
		blue,
		yellow,
		p3,
		tostring(replay.winner),
		replay.duration
	))

	for _, v7 in failures do
		warn("[DeterminismParityTest]   " .. v7)
	end

	return {
		passed = passed,
		failures = failures,
		winner = replay.winner,
		duration = replay.duration
	}
end

function DeterminismParityTest.runAll(options)
	local v2 = options or {}
	local seed = v2.seed or BattleConfig.seed.value
	local v3 = math.max(1, v2.yieldEvery or 4)
	local rolePool = BattleConfig.battle.rolePool
	assert(#rolePool >= 2, "[DeterminismParityTest] 角色池不足 2 个")
	local count = 0
	local count2 = 0
	local failedCases = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function runOne(p: string, p2: string, p3: number, p4, p5: string)
		count += 1

		if DeterminismParityTest.runCase(p, p2, p3, p4).passed then
			count2 += 1
		else
			table.insert(failedCases, p5)
		end

		if count % v3 == 0 then
			task.wait()
		end
	end

	for i, v5 in ipairs(rolePool) do
		local v6 = rolePool[i % #rolePool + 1]
		runOne(v5, v6, seed + i, nil, string.format("%s vs %s", v5, v6)) -- equivalent call inferred; original call site unknown
		runOne(v5, v6, seed + i, {
			initialDirections = {
				Blue = Vector2.new(0.6, 0.8),
				Yellow = Vector2.new(-0.8, -0.6)
			}
		}, string.format("%s vs %s (带发射方向)", v5, v6)) -- equivalent call inferred; original call site unknown
	end

	print(string.format(
		"[DeterminismParityTest] SUMMARY total=%d passed=%d failed=%d status=%s",
		count,
		count2,
		count - count2,
		count2 == count and "PASS" or "FAIL"
	))

	for _, v5 in failedCases do
		warn("[DeterminismParityTest] FAILED CASE: " .. v5)
	end

	return {
		total = count,
		passed = count2,
		failed = count - count2,
		failedCases = failedCases
	}
end

return DeterminismParityTest