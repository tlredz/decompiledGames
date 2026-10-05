local createVector = vector.create
require(script.Parent.Types)
local Config = require(script.Parent.Config)
local Warn = require(script.Parent.Warn)
local v = nil
Config._WaitForLock(function()
	v = Config._GetConfig("MAX_SNAPSHOT_COUNT")
end)

local function GetBufferIndex(p: number, p2: number)
	return (p + p2 - 2) % v + 1
end

local function BinarySearchInsertionPoint(data, p: number)
	local count = data.count

	if count == 0 then
		return 1
	end

	local cache = data.cache
	local head = data.head
	local v2 = 1

	while v2 <= count do
		local v3 = (v2 + count) // 2

		if cache[(head + v3 - 2) % v + 1].t < p then
			v2 = v3 + 1
		else
			count = v3 - 1
		end
	end

	return v2
end

local function ShiftElementsRight(state, p: number, count: number)
	local cache = state.cache
	local head = state.head

	for i = count, p, -1 do
		local v2 = (head + i - 2) % v + 1
		cache[(head + (i + 1) - 2) % v + 1] = cache[v2]
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetLatest(data)
	if data.count == 0 then
		return nil
	end

	local v2 = (data.head + data.count - 2) % v + 1
	return data.cache[v2]
end

local function Push(state, p: number, p2, velocity)
	local v2 = {
		t = p,
		value = p2,
		velocity = velocity
	}

	if state.count == 0 then
		state.cache[state.head] = v2
		state.count = 1
	else
		local binarySearchInsertionPoint = BinarySearchInsertionPoint(state, p)

		if state.count < binarySearchInsertionPoint then
			if state.count < v then
				local v4 = (state.head + (state.count + 1) - 2) % v + 1
				state.cache[v4] = v2
				state.count += 1
			else
				local head = state.head
				state.cache[head] = v2
				state.head = state.head % v + 1
			end
		elseif state.count < v then
			ShiftElementsRight(state, binarySearchInsertionPoint, state.count)
			local v4 = (state.head + binarySearchInsertionPoint - 2) % v + 1
			state.cache[v4] = v2
			state.count += 1
		else
			for i = 1, binarySearchInsertionPoint - 1 do
				local v4 = (state.head + (i + 1) - 2) % v + 1
				local v5 = (state.head + i - 2) % v + 1
				state.cache[v5] = state.cache[v4]
			end

			local v4 = (state.head + binarySearchInsertionPoint - 2) % v + 1
			state.cache[v4] = v2
		end
	end
end

local function PushWithCheck(data, p: number, p2, velocity, p4: number)
	local latest = GetLatest(data) -- equivalent call inferred; original call site unknown

	if latest then
		local v3 = p - latest.t

		if p4 * 3 < v3 and Config.FLAGS.SNAPSHOT_INTERPOLATION_FIX then
			Push(data, p - p4, latest.value, createVector(0, 0, 0), true)
		end
	end

	Push(data, p, p2, velocity)
end

local function GetAt(data, p: number, flag: boolean?)
	local count = data.count

	if count == 0 then
		return nil
	elseif count == 1 then
		local v2 = (data.head + 1 - 2) % v + 1
		return data.cache[v2].value
	end

	if p < 0 then
		local latest = GetLatest(data) -- equivalent call inferred; original call site unknown
		return latest and latest.value or nil
	else
		local cache = data.cache
		local head = data.head
		local lerp = data.Lerp
		local lockedTime = data.lockedTime

		if p < lockedTime and not flag then
			p = lockedTime
		end

		local binarySearchInsertionPoint = BinarySearchInsertionPoint(data, p)
		local v3 = binarySearchInsertionPoint - 1
		local v4 = nil
		local v5

		if v3 >= 1 and v3 <= count then
			v5 = cache[(head + v3 - 2) % v + 1]
		end

		if binarySearchInsertionPoint >= 1 and binarySearchInsertionPoint <= count then
			v4 = cache[(head + binarySearchInsertionPoint - 2) % v + 1]
		end

		if v5 and v4 then
			local v6 = v4.t - v5.t

			if v6 == 0 then
				return v5.value
			end

			local v7 = (p - v5.t) / v6
			local lerped = lerp(v5.value.Position, v4.value.Position, v5.velocity, v4.velocity, v7, v6)
			local lerped2 = v5.value:Lerp(v4.value, v7)
			return CFrame.new(lerped) * lerped2.Rotation
		else
			if v5 then
				Warn.low("Tried to fetch a time that was ahead of snapshot storage!")
				return v5.value
			end

			if not v4 then
				return nil
			end

			Warn.low("Tried to fetch a time that was behind snapshot storage!")
			return v4.value
		end
	end
end

local function Clear(p)
	p.head = 1
	p.count = 0
	p.lockedTime = 0
end

local function New(lerp)
	local cache = table.create(v)

	for i = 1, v do
		cache[i] = {
			t = 0,
			value = nil,
			velocity = nil
		}
	end

	return {
		cache = cache,
		head = 1,
		count = 0,
		lockedTime = 0,
		Lerp = lerp,
		Push = Push,
		PushWithCheck = PushWithCheck,
		GetLatest = GetLatest,
		GetAt = GetAt,
		Clear = Clear
	}
end

return New