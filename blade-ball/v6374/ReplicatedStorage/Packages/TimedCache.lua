local TimedCache = {}
TimedCache.__index = TimedCache

function TimedCache.new(value: number?)
	local object = setmetatable({
		_cache = {},
		_checkInterval = value or 10
	}, TimedCache)
	task.spawn(function()
		while true do
			object:_checkExpiry()
			task.wait(object._checkInterval)
		end
	end)
	return object
end

function TimedCache:_checkExpiry()
	local now = os.clock()

	for k, v in self._cache do
		if v[3] <= now then
			self._cache[k] = nil
		end
	end
end

function TimedCache:Set(p2, p3, p4: number?)
	if p3 == nil then
		self._cache[p2] = nil
	else
		self._cache[p2] = { p3, p4, os.clock() + (p4 or self._defaultDuration) }
	end
end

function TimedCache:Get(p2, flag: boolean?)
	local v = self._cache[p2]

	if not v then
		return nil
	end

	local now = os.clock()

	if now < v[3] then
		if not flag then
			v[3] = now + v[2]
		end

		return v[1]
	else
		self._cache[p2] = nil
	end

	return nil
end

return TimedCache