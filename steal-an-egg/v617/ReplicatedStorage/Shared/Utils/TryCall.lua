local function onError(p)
	return debug.traceback(tostring(p), 2)
end

return function(callback, ...)
	local v = table.pack(xpcall(callback, onError, ...))

	if v[1] then
		return true, table.unpack(v, 2, v.n)
	end

	warn("protected call failed: " .. tostring(v[2]))
	return false, v[2]
end