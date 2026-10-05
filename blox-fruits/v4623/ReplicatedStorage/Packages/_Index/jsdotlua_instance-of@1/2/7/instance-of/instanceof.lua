local __DEV__ = _G.__DEV__

local function instanceof(metatable, p)
	if __DEV__ then
		assert(typeof(p) == "table", "Received a non-table as the second argument for instanceof")
	end

	if typeof(metatable) ~= "table" then
		return false
	end

	local success, result = pcall(function()
		return p.new ~= nil and metatable.new == p.new
	end)

	if success and result then
		return true
	end

	local v = {
		[metatable] = true
	}

	while metatable and typeof(metatable) == "table" do
		metatable = getmetatable(metatable)

		if typeof(metatable) == "table" then
			metatable = metatable.__index

			if metatable == p then
				return true
			end
		end

		if typeof(metatable) ~= "table" then
			continue
		end

		if v[metatable] then
			return false
		else
			v[metatable] = true
		end
	end

	return false
end

return instanceof