local HitCooldown = {}
HitCooldown.__index = HitCooldown

function HitCooldown.new(value: number?)
	return (setmetatable({
		_default = value or 1,
		_last = setmetatable({}, {
			__mode = "k"
		})
	}, HitCooldown))
end

function HitCooldown:Ready(p2, p3: number?)
	if p2 == nil then
		return false
	end

	local v = p3 or self._default

	if v <= 0 then
		return true
	end

	local v2 = self._last[p2]
	return v2 == nil or v <= os.clock() - v2
end

function HitCooldown:Take(p, p2: number?)
	if not self:Ready(p, p2) then
		return false
	end

	self._last[p] = os.clock()
	return true
end

function HitCooldown:Clear(p2)
	if p2 == nil then
		table.clear(self._last)
	else
		self._last[p2] = nil
	end
end

return HitCooldown