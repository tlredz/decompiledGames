local function init()
	local v = {
		root = {},
		options = {
			noreduce = {}
		}
	}
	v._stack = { v.root }
	return v
end

local v = init()

function v.new(p)
	local v2 = init()
	v2.__index = p
	setmetatable(v2, p)
	return v2
end

function v:reduce(p, p2, p3)
	for k, v2 in pairs(p) do
		if type(v2) == "table" then
			self:reduce(v2, k, p)
		end
	end

	if #p == 1 and not self.options.noreduce[p2] and p._attr == nil then
		p3[p2] = p[1]
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function convertObjectToArray(list)
	if #list ~= 0 then
		return list
	end

	local lists = {}
	table.insert(lists, list)
	return lists
end

function v:starttag(p2)
	local v2 = {}

	if self.parseAttributes == true then
		v2._attr = p2.attrs
	end

	local v3 = self._stack[#self._stack]

	if v3[p2.name] then
		local v5 = convertObjectToArray(v3[p2.name]) -- equivalent call inferred; original call site unknown
		table.insert(v5, v2)
		v3[p2.name] = v5
	else
		v3[p2.name] = { v2 }
	end

	table.insert(self._stack, v2)
end

function v:endtag(p, _)
	local v2 = self._stack[#self._stack - 1]
	local _ = v2[p.name]

	if v2 == self.root then
		self:reduce(v2, nil, nil)
	end

	table.remove(self._stack)
end

function v:text(p2)
	table.insert(self._stack[#self._stack], p2)
end

v.cdata = v.text
v.__index = v
return v