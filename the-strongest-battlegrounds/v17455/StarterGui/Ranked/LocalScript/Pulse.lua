local RunService = game:GetService("RunService")
local nowsBySyncGroup = {}

local function now()
	return os.clock()
end

local function clamp(p, p2, p3)
	if p < p2 then
		return p2
	end

	if p3 < p then
		return p3
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smoothPulse01(p)
	return 0.5 - math.cos(p) * 0.5
end

local function isAlive(instance)
	return typeof(instance) == "Instance" and instance.Parent ~= nil
end

local v = {}
local Pulse = {}

function Pulse.start(list, options)
	assert(type(list) == "table", "PulseTransparency.start expects a table of instances")
	local v2 = options or {}
	local property = v2.property or "ImageTransparency"
	local min = tonumber(v2.min) or 0
	local minT = min < 0 and 0 or min > 1 and 1 or min
	local max = tonumber(v2.max) or 1
	local maxT = max < 0 and 0 or max > 1 and 1 or max

	if maxT < minT then
		maxT, minT = minT, maxT
	end

	local speed = tonumber(v2.speed) or 1
	local perItemPhase = v2.perItemPhase == true
	local phaseSpread = tonumber(v2.phaseSpread) or 3.141592653589793
	local randomizeStart = v2.randomizeStart == true
	local syncGroup = v2.syncGroup or "global"

	if nowsBySyncGroup[syncGroup] == nil then
		nowsBySyncGroup[syncGroup] = os.clock()
	end

	local t0 = nowsBySyncGroup[syncGroup]
	local targets = {}

	for _, v7 in ipairs(list) do
		local v8

		if typeof(v7) == "Instance" then
			v8 = v7.Parent ~= nil
		else
			v8 = false
		end

		if v8 and v7[property] ~= nil then
			table.insert(targets, v7)
		end
	end

	if #targets == 0 then
		warn(("PulseTransparency.start: no valid GUI objects with property '%s' were provided."):format(property))
		return function() end
	end

	local v7 = randomizeStart and math.random() * 2 * 3.141592653589793 or 0
	local phases = table.create(#targets, v7)

	if perItemPhase and #targets > 1 then
		for i = 1, #targets do
			phases[i] = v7 + ((i - 1) / (#targets - 1) - 0.5) * phaseSpread
		end
	end

	local v9 = {
		alive = true,
		conn = nil,
		targets = targets,
		prop = property,
		minT = minT,
		maxT = maxT,
		speed = speed,
		phases = phases,
		t0 = t0
	}
	table.insert(v, v9)
	v9.conn = RunService.RenderStepped:Connect(function()
		if not v9.alive then
			return
		end

		local v10 = os.clock() - v9.t0
		local v11 = 6.283185307179586 * v9.speed * v10
		local v12 = v9.maxT - v9.minT
		local v13 = false

		for i = #v9.targets, 1, -1 do
			local target = v9.targets[i]
			local v14

			if typeof(target) == "Instance" then
				v14 = target.Parent ~= nil
			else
				v14 = false
			end

			if v14 and target[v9.prop] ~= nil then
				local v15 = smoothPulse01(v11 + v9.phases[i]) -- equivalent call inferred; original call site unknown
				target[v9.prop] = v9.minT + v12 * v15
				v13 = true
			else
				table.remove(v9.targets, i)
				table.remove(v9.phases, i)
			end
		end

		if not v13 then
			v9.alive = false

			if v9.conn then
				v9.conn:Disconnect()
				v9.conn = nil
			end
		end
	end)

	local function stop()
		if not v9.alive then
			return
		end

		v9.alive = false

		if v9.conn then
			v9.conn:Disconnect()
			v9.conn = nil
		end

		for i, v10 in ipairs(v) do
			if v10 ~= v9 then
				continue
			end

			table.remove(v, i)
			break
		end
	end

	return stop
end

function Pulse.stopAll()
	for i = #v, 1, -1 do
		local v2 = v[i]

		if v2.conn then
			v2.conn:Disconnect()
		end

		v[i] = nil
	end
end

return Pulse