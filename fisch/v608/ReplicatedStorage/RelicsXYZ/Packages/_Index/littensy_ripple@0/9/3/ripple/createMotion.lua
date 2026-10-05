local RunService = game:GetService("RunService")
require(script.Parent.types)
local immediate = require(script.Parent.solvers.immediate)
local linear = require(script.Parent.solvers.linear)
local spring = require(script.Parent.solvers.spring)
local tween = require(script.Parent.solvers.tween)
local intermediate = require(script.Parent.utils.intermediate)
local assign = require(script.Parent.utils.assign)
local merge = require(script.Parent.utils.merge)
local defaults = {
	heartbeat = RunService.Heartbeat,
	start = false
}

local function createMotion(p, options)
	local v2 = merge(defaults, options or {})
	local typeName = typeof(p)
	local state = {}
	local heartbeatConnection = nil
	local v4 = {}
	local v5 = false
	local v6 = nil
	local v7 = {}
	local v8 = {}
	local v9 = 1

	for k, v10 in intermediate.to(p) do
		state[k] = {
			value = v10,
			complete = true
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stop()
		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end
	end

	local v10 = {
		state = state,
		start = function(object)
			if heartbeatConnection then
				return stop
			end

			heartbeatConnection = v2.heartbeat:Connect(function(p2)
				object:step(p2)
			end)
			return stop
		end,
		stop = stop,
		get = function()
			local v10 = {}

			for k, v11 in state do
				v10[k] = v11.value
			end

			return intermediate.from(v10, typeName)
		end,
		set = function(_, p2)
			local v10 = intermediate.to(p2)

			for k, v11 in state do
				local v12 = v10[k]

				if not v12 then
					continue
				end

				v11.value = v12
				v11.complete = false
			end
		end,
		getVelocity = function()
			local velocities = {}

			for k, v10 in state do
				velocities[k] = v10.velocity or 0
			end

			return intermediate.from(velocities, typeName)
		end,
		setVelocity = function(_, p2)
			local v10 = intermediate.to(p2)

			for k, velocity in v10 do
				local v12 = state[k]

				if not (v12 and v12.velocity) then
					continue
				end

				v12.complete = false
				v12.velocity = velocity
			end
		end,
		impulse = function(_, value)
			if type(value) == "number" then
				for _, v10 in state do
					if not v10.velocity then
						continue
					end

					v10.complete = false
					v10.velocity += value
				end
			else
				local v10 = intermediate.to(value)

				for k, v11 in v10 do
					local v12 = state[k]

					if not (v12 and v12.velocity) then
						continue
					end

					v12.complete = false
					v12.velocity += v11
				end
			end
		end,
		patch = function(_, p2)
			for k, v10 in state do
				local v11 = p2[k]

				if not v11 then
					continue
				end

				v10.complete = false
				assign(v10, v11)
			end
		end,
		to = function(_, callback)
			if type(callback) == "function" then
				for k, v11 in state do
					if v11.destructor then
						v11.destructor()
						v11.destructor = nil
					end

					v11.complete = false

					if callback(k, v11, 0) ~= false then
						v4[k] = callback
					end
				end
			else
				for k, v11 in callback do
					local v12 = state[k]

					if not v12 then
						continue
					end

					if v12.destructor then
						v12.destructor()
						v12.destructor = nil
					end

					v12.complete = false

					if v11(k, v12, 0) ~= false then
						v4[k] = v11
					end
				end
			end
		end,
		immediate = function(object, p2)
			object:to(immediate(p2))
		end,
		linear = function(object, p2, p3)
			object:to(linear(p2, p3))
		end,
		spring = function(object, p2, p3)
			object:to(spring(p2, p3))
		end,
		tween = function(object, p2, p3)
			object:to(tween(p2, p3))
		end,
		step = function(object, p2)
			for k, v10 in v4 do
				local v11 = state[k]

				if not v11 or v11.complete then
					continue
				end

				v10(k, v11, p2)
			end

			local v10 = object:get()
			local complete = object:isComplete()

			if not complete or not v5 or v6 ~= v10 then
				for _, callback in v7 do
					task.spawn(callback, v10, p2)
				end
			end

			if complete and (not v5 or v6 ~= v10) then
				for _, callback in v8 do
					task.spawn(callback, v10)
				end
			end

			v5 = complete
			v6 = v10
			return v10
		end,
		isComplete = function()
			for _, v11 in state do
				if not v11.complete then
					return false
				end
			end

			return true
		end,
		onComplete = function(_, p2)
			local v10 = v9
			v9 += 1
			v8[v10] = p2
			return function()
				v8[v10] = nil
			end
		end,
		onStep = function(_, p2)
			local v10 = v9
			v9 += 1
			v7[v10] = p2
			return function()
				v7[v10] = nil
			end
		end,
		destroy = function()
			v5 = false
			v9 = 1
			stop() -- equivalent call inferred; original call site unknown
			table.clear(v7)
			table.clear(v8)
			table.clear(v4)

			for _, v10 in state do
				if not v10.destructor then
					continue
				end

				v10.destructor()
				v10.destructor = nil
			end
		end
	}

	if v2.start then
		v10:start()
	end

	return v10
end

return createMotion