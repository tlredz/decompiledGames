local TestEnum = require(script.Parent.TestEnum)
local Expectation = require(script.Parent.Expectation)

local function newEnvironment(object, extraEnvironment)
	local result = {}

	if extraEnvironment then
		if type(extraEnvironment) ~= "table" then
			error(("Bad argument #2 to newEnvironment. Expected table, got %s"):format((typeof(extraEnvironment))), 2)
		end

		for k, item in pairs(extraEnvironment) do
			result[k] = item
		end
	end

	local function addChild(p, callback, p2, p3)
		local v = object:addChild(p, p2, p3)
		v.callback = callback

		if p2 == TestEnum.NodeType.Describe then
			v:expand()
		end

		return v
	end

	function result.describeFOCUS(p, callback)
		addChild(p, callback, TestEnum.NodeType.Describe, TestEnum.NodeModifier.Focus)
	end

	function result.describeSKIP(p, callback)
		addChild(p, callback, TestEnum.NodeType.Describe, TestEnum.NodeModifier.Skip)
	end

	function result.describe(p, callback, _)
		addChild(p, callback, TestEnum.NodeType.Describe, TestEnum.NodeModifier.None)
	end

	function result.itFOCUS(p, callback)
		addChild(p, callback, TestEnum.NodeType.It, TestEnum.NodeModifier.Focus)
	end

	function result.itSKIP(p, callback)
		addChild(p, callback, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)
	end

	function result.itFIXME(p, callback)
		local v = addChild(p, callback, TestEnum.NodeType.It, TestEnum.NodeModifier.Skip)
		warn("FIXME: broken test", v:getFullName())
	end

	function result.it(p, callback, _)
		addChild(p, callback, TestEnum.NodeType.It, TestEnum.NodeModifier.None)
	end

	local v = {
		[TestEnum.NodeType.BeforeAll] = "beforeAll",
		[TestEnum.NodeType.AfterAll] = "afterAll",
		[TestEnum.NodeType.BeforeEach] = "beforeEach",
		[TestEnum.NodeType.AfterEach] = "afterEach"
	}
	local count = 0

	for k, v2 in pairs(v) do
		local v3 = v2
		local v4 = k

		result[v2] = function(callback)
			addChild(v3 .. "_" .. tostring(count), callback, v4, TestEnum.NodeModifier.None)
			count += 1
		end
	end

	function result.FIXME(value)
		warn("FIXME: broken test", object:getFullName(), value or "")
		object.modifier = TestEnum.NodeModifier.Skip
	end

	function result.FOCUS()
		object.modifier = TestEnum.NodeModifier.Focus
	end

	function result.SKIP()
		object.modifier = TestEnum.NodeModifier.Skip
	end

	function result.HACK_NO_XPCALL()
		warn("HACK_NO_XPCALL is deprecated. It is now safe to yield in an xpcall, so this is no longer necessary. It can be safely deleted.")
	end

	result.fit = result.itFOCUS
	result.xit = result.itSKIP
	result.fdescribe = result.describeFOCUS
	result.xdescribe = result.describeSKIP
	result.expect = setmetatable({
		extend = function(...)
			error("Cannot call \"expect.extend\" from within a \"describe\" node.")
		end
	}, {
		__call = function(_, ...)
			return Expectation.new(...)
		end
	})
	return result
end

local class = {}
class.__index = class

function class.new(plan, phrase, p3, p4)
	local v = {
		plan = plan,
		phrase = phrase,
		type = p3,
		modifier = p4 or TestEnum.NodeModifier.None,
		children = {},
		callback = nil,
		parent = nil
	}
	v.environment = newEnvironment(v, plan.extraEnvironment)
	return (setmetatable(v, class))
end

local function getModifier(value, testNamePattern, p)
	if not testNamePattern or p ~= nil and p ~= TestEnum.NodeModifier.None then
		return p
	end

	if value:match(testNamePattern) then
		return TestEnum.NodeModifier.Focus
	end

	return TestEnum.NodeModifier.Skip
end

function class:addChild(p, p2, p3)
	if p2 == TestEnum.NodeType.It then
		for _, v in pairs(self.children) do
			if v.phrase == p then
				error("Duplicate it block found: " .. v:getFullName())
			end
		end
	end

	local modifier = getModifier(self:getFullName() .. " " .. p, self.plan.testNamePattern, p3)
	local v2 = class.new(self.plan, p, p2, modifier)
	v2.parent = self
	table.insert(self.children, v2)
	return v2
end

function class:getFullName()
	local v = self.parent and self.parent:getFullName()

	if v then
		return v .. " " .. self.phrase
	end

	return self.phrase
end

function class:expand()
	local v = getfenv(self.callback)
	local object = setmetatable({}, {
		__index = v
	})

	for k, v2 in pairs(self.environment) do
		object[k] = v2
	end

	object.script = v.script
	setfenv(self.callback, object)
	local v2, loadError = xpcall(self.callback, function(p)
		return debug.traceback(tostring(p), 2)
	end)

	if not v2 then
		self.loadError = loadError
	end
end

local TestPlan = {}
TestPlan.__index = TestPlan

function TestPlan.new(testNamePattern, extraEnvironment)
	return (setmetatable({
		children = {},
		testNamePattern = testNamePattern,
		extraEnvironment = extraEnvironment
	}, TestPlan))
end

function TestPlan:addChild(p2, p3, p4)
	local modifier = getModifier(p2, self.testNamePattern, p4)
	local v = class.new(self, p2, p3, modifier)
	table.insert(self.children, v)
	return v
end

function TestPlan.addRoot(object, list, callback)
	for i = #list, 1, -1 do
		local v = nil

		for _, v3 in ipairs(object.children) do
			if v3.phrase ~= list[i] then
				continue
			end

			v = v3
			break
		end

		if v == nil then
			v = object:addChild(list[i], TestEnum.NodeType.Describe)
		end

		object = v
	end

	object.callback = callback
	object:expand()
end

function TestPlan:visitAllNodes(callback, p, value)
	local v = value or 0

	for _, v2 in ipairs((p or self).children) do
		callback(v2, v)
		self:visitAllNodes(callback, v2, v + 1)
	end
end

function TestPlan:visualize()
	local v = {}
	self:visitAllNodes(function(p, p2)
		table.insert(v, (" "):rep(3 * p2) .. p.phrase)
	end)
	return table.concat(v, "\n")
end

function TestPlan:findNodes(callback)
	local v = {}
	self:visitAllNodes(function(p)
		if callback(p) then
			table.insert(v, p)
		end
	end)
	return v
end

return TestPlan