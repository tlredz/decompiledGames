local v = {
	__index = function(items, p)
		for k, item in pairs(items) do
			if k ~= "__isparenttable" and item[p] then
				return item[p]
			end
		end

		return nil
	end
}
class = setmetatable({
	__baseclass = {}
}, {
	__index = function(p, p2)
		if rawget(p, "__baseclass") then
			return p.__baseclass[p2]
		end

		return nil
	end,
	__call = function(object, ...)
		return object:new(...)
	end,
	__add = function(object, p)
		return object:addparent(p)
	end,
	__eq = function(p, p2)
		if not p2.__baseclass or p2.__baseclass ~= p.__baseclass then
			return false
		end

		for k, _ in pairs(p) do
			if not p2[k] then
				return false
			end
		end

		for k, _ in pairs(p2) do
			if not p[k] then
				return false
			end
		end

		return true
	end,
	__lt = function(p, p2)
		if not p2.__baseclass then
			return false
		end

		if rawget(p2.__baseclass, "__isparenttable") then
			for _, v2 in pairs(p2.__baseclass) do
				if p == v2 or getmetatable(p).__lt(p, v2) then
					return true
				end
			end
		elseif p == p2.__baseclass or getmetatable(p).__t(p, p2.__baseclass) then
			return true
		end

		return false
	end,
	__le = function(p, p2)
		return p < p2 or p == p2
	end
})

function class:new(...)
	local v2 = {
		__baseclass = self
	}
	setmetatable(v2, (getmetatable(self)))

	if v2.init then
		v2:init(...)
	end

	return v2
end

function class.convert(baseclass, p)
	p.__baseclass = baseclass
	setmetatable(p, (getmetatable(baseclass)))
	return p
end

function class:addparent(...)
	if not rawget(self.__baseclass, "__isparenttable") then
		self.__baseclass = setmetatable({
			__isparenttable = true,
			self.__baseclass,
			...
		}, v)
		return self
	end

	for _, v2 in ipairs({ ... }) do
		table.insert(self.__baseclass, v2)
	end

	return self
end

function class.setmetamethod(p, p2, p3)
	local metatable = getmetatable(p)
	local class2 = {}

	for k, v2 in pairs(metatable) do
		class2[k] = v2
	end

	class2[p2] = p3
	setmetatable(p, class2)
end

return class