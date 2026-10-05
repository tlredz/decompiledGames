local Effect = {}
Effect.__index = Effect

function Effect.new(renderable)
	return (setmetatable({
		_renderable = renderable,
		_triggers = {},
		_startingFn = nil,
		_stoppingFn = nil,
		_renderSteppedFn = nil
	}, Effect))
end

function Effect:setTrigger(p2: string)
	self._triggers[p2] = true
	return self
end

function Effect:onStarting(startingFn)
	self._startingFn = startingFn
	return self
end

function Effect:onStopping(stoppingFn)
	self._stoppingFn = stoppingFn
	return self
end

function Effect:onRenderStepped(renderSteppedFn)
	self._renderSteppedFn = renderSteppedFn
	return self
end

function Effect:start()
	if self._startingFn then
		self._startingFn(self)
	end
end

function Effect:stop()
	if self._stoppingFn then
		self._stoppingFn(self)
	end
end

function Effect:renderStepped(p2: number)
	if self._renderSteppedFn then
		self._renderSteppedFn(self, p2)
	end
end

local v = {
	ShakeOnHover = function(object)
		object:setTrigger("Hover")
	end
}

function Effect.create(p, value)
	local v2 = Effect.new(p)

	if typeof(value) ~= "string" then
		value(v2)
		return v2
	end

	local v3 = v[value]
	assert(v3 ~= nil, (`unknown preset effect "{value}"`))
	v3(v2)
	return v2
end

return Effect