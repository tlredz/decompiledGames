local function spy()
	local v = nil

	local function handle(...)
		v.calls += 1
		v.arguments[v.calls] = { ... }
	end

	v = {
		calls = 0,
		arguments = {},
		handle = handle
	}
	return v
end

return spy