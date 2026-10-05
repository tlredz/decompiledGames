TablesLibrary = {}

function TablesLibrary.DeepCopy(items)
	local v = {}

	for k, item in items do
		if typeof(item) == "table" then
			v[k] = TablesLibrary.DeepCopy(item)
		else
			v[k] = item
		end
	end

	return (setmetatable(v, (getmetatable(items))))
end

function TablesLibrary.DeepCopyPaste(items, p)
	for k, item in items do
		if typeof(item) == "table" then
			if typeof(p[k]) ~= "table" then
				p[k] = {}
			end

			TablesLibrary.DeepCopyPaste(item, p[k])
		else
			p[k] = item
		end
	end

	setmetatable(p, (getmetatable(items)))
end

function TablesLibrary.LockKeyInTable(p, p2)
	local metatable = getmetatable(p) or {}
	local __index = metatable.__index

	function metatable.__index(p3, p4)
		if p4 == p2 then
			error((`Attempt to read locked key: {p4}`))
			return
		end

		if type(__index) == "function" then
			return __index(p3, p4)
		end

		if type(__index) == "table" then
			return __index[p4]
		end
	end

	function metatable.__newindex(p3, p4, p5)
		if p4 == p2 then
			error((`Attempt to modify locked key: {p4}`))
		else
			rawset(p3, p4, p5)
		end
	end

	setmetatable(p, metatable)
end

function TablesLibrary.RemoveMetatable(p)
	setmetatable(p, nil)
end

return TablesLibrary