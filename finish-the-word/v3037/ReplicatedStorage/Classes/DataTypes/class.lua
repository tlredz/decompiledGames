local Class = {}

local function inheritNonMeta(p, class)
	p._Class = class
	p._ClassModule = class._Module

	for k, v in pairs(class) do
		if k:sub(1, 2) ~= "__" then
			p[k] = v
		end
	end

	setmetatable(p, {
		__index = class
	})
end

local function inheritMeta(p, items)
	local metatable = getmetatable(p)

	for k, item in pairs(items) do
		if k:sub(1, 2) == "__" then
			metatable[k] = item
		end
	end
end

local function inherit(p, _ClassModule)
	inheritNonMeta(p, _ClassModule)
	inheritMeta(p, _ClassModule)
end

function Class:reinherit()
	if type(self) ~= "table" then
		return
	end

	for _, v in pairs(self) do
		Class.reinherit(v)
	end

	if self._IsInstance then
		inherit(self, require(self._ClassModule))
	end
end

function Class.__index(_, p)
	return p ~= "new" and p ~= "__index" and Class[p]
end

function Class.__call(class, ...)
	local v = {
		_IsInstance = true
	}
	inheritNonMeta(v, class)

	if class.new then
		class.new(v, ...)
	end

	inheritMeta(v, class)
	return v
end

function Class:isSubclass(p2)
	for _, _Super in pairs(self._Supers) do
		if _Super == p2 then
			return true
		end

		local subclass = Class.isSubclass(_Super, p2)

		if subclass then
			return subclass
		end
	end
end

function Class:isInstance(p2)
	local __Class = self.__Class
	return __Class == p2 or __Class and Class.isSubclass(__Class, p2)
end

function Class.new(...)
	local self = setmetatable({
		_Supers = { ... },
		_Module = getfenv(0).script
	}, Class)

	for _, _Super in pairs(self._Supers) do
		for k, v in pairs(_Super) do
			self[k] = self[k] or v
		end
	end

	return self
end

return Class