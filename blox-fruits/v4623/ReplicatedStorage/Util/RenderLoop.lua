local RunService = game:GetService("RunService")
local RenderLoop = {}
RenderLoop.__index = RenderLoop

function RenderLoop.new(startTime: number, value2: number, value3: number, value4: number)
	assert(typeof(startTime) == "number", "[RenderLoop] The startTime provided during loop creation was not a number")
	assert(typeof(value2) == "number", "[RenderLoop] The activeLife provided during loop creation was not a number")
	assert(typeof(value3) == "number", "[RenderLoop] The fullLife provided during loop creation was not a number")
	assert(typeof(value4) == "number", "[RenderLoop] The fps provided during loop creation was not a number")
	return (setmetatable({
		active = false,
		stopped = false,
		activeLife = value2,
		fullLife = value3,
		startTime = startTime,
		loopFPS = value4,
		dt = 1 / value4,
		stopFunction = nil,
		tickOperations = {},
		activeInstances = {},
		instanceFunctions = {}
	}, RenderLoop))
end

function RenderLoop:SetFPS(loopFPS: number)
	assert(typeof(loopFPS) == "number", "[RenderLoop] Attempted to set loop FPS to a non-number")
	self.loopFPS = loopFPS
	self.dt = 1 / loopFPS
end

function RenderLoop.AddTick(p, value: string, value2: number, callback)
	assert(typeof(value) == "string", "[RenderLoop] The taskName provided during AddTick was not a string")
	assert(typeof(value2) == "number", "[RenderLoop] The taskInterval provided during AddTick was not a number")
	assert(typeof(callback) == "function", "[RenderLoop] The taskFunc provided during AddTick was not a function")
	p.tickOperations[value] = { tick(), value2, callback }
end

function RenderLoop.AddInstance(p, value: string, instance, p2)
	assert(typeof(value) == "string", "[RenderLoop] The groupName provided during AddInstance was not a string")
	assert(typeof(instance) == "Instance", "[RenderLoop] Attempted to add non-Instance type to loop via AddInstance")

	if not p.activeInstances[value] then
		p.activeInstances[value] = {}
	end

	table.insert(p.activeInstances[value], {
		instance,
		tick(),
		value,
		p2 or nil
	})
end

function RenderLoop.SetGroupFunction(p, value: string, callback)
	assert(typeof(value) == "string", "[RenderLoop] The groupName provided during SetGroupFunction was not a string")
	assert(
		typeof(callback) == "function",
		"[RenderLoop] The groupFunc provided during SetGroupFunction was not a function"
	)
	p.instanceFunctions[value] = callback
end

function RenderLoop:SetEndFunction(stopFunction)
	self.stopFunction = stopFunction
end

function RenderLoop.Start(object)
	object.active = true
	object.dt = 1 / object.loopFPS
	task.spawn(function()
		while true do
			local now = tick()
			local _ = object.dt * object.loopFPS
			local v = math.max(now - object.startTime, 0.001)

			if not object.active or object.fullLife < v then
				break
			end

			local v2 = v / object.activeLife

			if v <= object.activeLife and object.stopped == false then
				for _, nows in pairs(object.tickOperations) do
					if not (now - nows[1] > nows[2]) then
						continue
					end

					nows[3](v2, v)
					nows[1] = tick()
				end
			end

			object.dt = RunService.RenderStepped:Wait()
		end

		if object.stopFunction then
			object.stopFunction()
		end

		object.active = false
		object:FlushInstances()
		object = nil
	end)
end

function RenderLoop:FlushInstances()
	if #self.activeInstances > 0 then
		for _, list in pairs(self.activeInstances) do
			if not (#list > 0) then
				continue
			end

			for k, v in pairs(list) do
				if v[1] == nil then
					continue
				end

				table.remove(list, k)
				v[1]:Destroy()
			end
		end
	end

	self.activeInstances = nil
end

function RenderLoop:Stop()
	self.stopped = true
end

function RenderLoop:FullStop()
	self.active = false
	self:FlushInstances()
end

return RenderLoop