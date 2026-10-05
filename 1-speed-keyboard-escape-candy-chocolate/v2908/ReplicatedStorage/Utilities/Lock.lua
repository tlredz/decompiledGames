local Lock = {}
Lock.__index = Lock

function Lock.new()
	return (setmetatable({
		_held = {},
		_count = 0
	}, Lock))
end

function Lock:SetLock(p: string, flag: boolean)
	local v = self._held[p] == true
	local v2 = flag == true

	if v == v2 then
		return false
	end

	local v3 = self._count > 0

	if v2 then
		self._held[p] = true
		self._count += 1
	else
		self._held[p] = nil
		self._count -= 1
	end

	return v3 ~= (self._count > 0)
end

function Lock:IsLocked()
	return self._count > 0
end

function Lock:Reset()
	local v = self._count > 0
	table.clear(self._held)
	self._count = 0
	return v
end

return Lock