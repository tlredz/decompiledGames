local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.Dev.ReactRoblox)
	v3 = ReactRoblox
	local Scheduler = require(parent.Scheduler)
	v2 = Scheduler
	local folder = Instance.new("Folder")
	v4 = v3.createRoot(folder)
end)
it("should allow key property to express identity", function()
	local ref = v.createRef()

	local function Component(p)
		local children = {}

		for i = 1, 500 do
			children[p.invert and tostring(51 - i) or tostring(i)] = v.createElement("TextLabel", {
				Text = i
			})
		end

		return v.createElement("Frame", {
			ref = ref
		}, unpack(children))
	end

	local function childrenByProp(items)
		local result = {}

		for _, item in items do
			result[item.Text] = item
		end

		return result
	end

	v4:render(v.createElement(Component))
	v2.unstable_flushAllWithoutAsserting()
	local children = ref.current:GetChildren()
	local v5 = {}

	for _, v6 in children do
		v5[v6.Text] = v6
	end

	v4:render(v.createElement(Component, {
		invert = true
	}))
	v2.unstable_flushAllWithoutAsserting()
	local children2 = ref.current:GetChildren()
	local v6 = {}

	for _, v7 in children2 do
		v6[v7.Text] = v7
	end

	for i = 1, 500 do
		expect(v5[i]).toBe(v6[51 - i])
		expect(v5[51 - i]).toBe(v6[i])
	end
end)
it("should allow table key to express identity", function()
	local ref = v.createRef()

	local function Component(p)
		local children = {}

		for i = 1, 50 do
			children[p.invert and tostring(51 - i) or tostring(i)] = v.createElement("TextLabel", {
				Text = i
			})
		end

		return v.createElement("Frame", {
			ref = ref
		}, children)
	end

	local function childrenByProp(items)
		local result = {}

		for _, item in items do
			result[item.Text] = item
		end

		return result
	end

	v4:render(v.createElement(Component))
	v2.unstable_flushAllWithoutAsserting()
	local children = ref.current:GetChildren()
	local v5 = {}

	for _, v6 in children do
		v5[v6.Text] = v6
	end

	v4:render(v.createElement(Component, {
		invert = true
	}))
	v2.unstable_flushAllWithoutAsserting()
	local children2 = ref.current:GetChildren()
	local v6 = {}

	for _, v7 in children2 do
		v6[v7.Text] = v7
	end

	for i = 1, 50 do
		expect(v5[i]).toBe(v6[51 - i])
		expect(v5[51 - i]).toBe(v6[i])
	end
end)
it("should use table key to express identity when updating children type", function()
	local ref = v.createRef()

	local function Component(p)
		local children = {}

		for i = 1, p.count do
			children[tostring(i)] = v.createElement("TextLabel", {
				Text = tostring(i)
			})
		end

		if p.count == 0 then
			children.Test = v.createElement("Frame")
		end

		return v.createElement("Frame", {
			ref = ref
		}, children)
	end

	v4:render(v.createElement(Component, {
		count = 0
	}))
	v2.unstable_flushAllWithoutAsserting()
	expect(ref.current:FindFirstChild((tostring("Test")))).never.toBe(nil)
	v4:render(v.createElement(Component, {
		count = 15,
		complexComponents = false
	}))
	v2.unstable_flushAllWithoutAsserting()

	for i = 1, 15 do
		expect(ref.current:FindFirstChild((tostring(i)))).never.toBe(nil)
	end
end)
it("should defer to provided key if both are present", function()
	local ref = v.createRef()

	local function Component(p)
		local children = {}

		for i = 1, 50 do
			local v5 = p.invert and tostring(51 - i) or tostring(i)
			children[tostring(i)] = v.createElement("TextLabel", {
				key = v5,
				Text = i
			})
		end

		return v.createElement("Frame", {
			ref = ref
		}, children)
	end

	local function childrenByProp(items)
		local result = {}

		for _, item in items do
			result[item.Text] = item
		end

		return result
	end

	expect(function()
		v4:render(v.createElement(Component))
		v2.unstable_flushAllWithoutAsserting()
	end).toErrorDev({ "Please provide only one key definition. When both are present, the \"key\" prop will take precedence." })
	local children = ref.current:GetChildren()
	local v5 = {}

	for _, v6 in children do
		v5[v6.Text] = v6
	end

	v4:render(v.createElement(Component, {
		invert = true
	}))
	v2.unstable_flushAllWithoutAsserting()
	local children2 = ref.current:GetChildren()
	local v6 = {}

	for _, v7 in children2 do
		v6[v7.Text] = v7
	end

	for i = 1, 50 do
		expect(v5[i]).toBe(v6[51 - i])
		expect(v5[51 - i]).toBe(v6[i])
	end
end)
it("should use composite identity", function()
	local extended = v.Component:extend("Wrapper")

	function extended:render()
		return v.createElement("Frame", nil, self.props.children)
	end

	local ref = v.createRef()
	local ref2 = v.createRef()
	v4:render(v.createElement(extended, {
		key = "wrap1"
	}, v.createElement("Frame", {
		ref = ref
	})))
	v2.unstable_flushAllWithoutAsserting()
	v4:render(v.createElement(extended, {
		key = "wrap2"
	}, v.createElement("Frame", {
		ref = ref2
	})))
	v2.unstable_flushAllWithoutAsserting()
	expect(ref.current).never.toBe(ref2.current)
end)

local function renderAComponentWithKeyIntoContainer(p, element)
	local ref = v.createRef()
	local extended = v.Component:extend("Wrapper")

	function extended:render()
		return v.createElement("Frame", nil, v.createElement("Frame", {
			ref = ref,
			key = p
		}))
	end

	v4:render(v.createElement(extended), element)
	v2.unstable_flushAllWithoutAsserting()
	expect(ref.current).never.toBe(nil)
end

it("should allow any character as a key, in a detached parent", function()
	renderAComponentWithKeyIntoContainer("<'WEIRD/&\\key'>", v.createElement("Frame"))
end)
it("should allow any character as a key, in an attached parent", function()
	local element = v.createElement("Frame")
	v4:render(element)
	v2.unstable_flushAllWithoutAsserting()
	renderAComponentWithKeyIntoContainer("<'WEIRD/&\\key'>", element)
end)
it("should let restructured components retain their uniqueness", function()
	local element = v.createElement("Frame")
	local element2 = v.createElement("Frame")
	local element3 = v.createElement("Frame")
	local extended = v.Component:extend("TestComponent")

	function extended:render()
		return v.createElement("Frame", nil, element3, self.props.children[1], self.props.children[2])
	end

	local extended2 = v.Component:extend("TestContainer")

	function extended2:render()
		return v.createElement(extended, nil, element, element2)
	end

	expect(function()
		v4:render(v.createElement(extended2))
		v2.unstable_flushAllWithoutAsserting()
	end).never.toThrow()
end)
it("should let nested restructures retain their uniqueness", function()
	local element = v.createElement("Frame")
	local element2 = v.createElement("Frame")
	local element3 = v.createElement("Frame")
	local extended = v.Component:extend("TestComponent")

	function extended:render()
		return v.createElement("Frame", nil, element3, self.props.children[1], self.props.children[2])
	end

	local extended2 = v.Component:extend("TestContainer")

	function extended2:render()
		return v.createElement("Frame", nil, v.createElement(extended, nil, element, element2))
	end

	expect(function()
		v4:render(v.createElement(extended2))
		v2.unstable_flushAllWithoutAsserting()
	end).never.toThrow()
end)
xit("should let text nodes retain their uniqueness", function()
	local extended = v.Component:extend("TestComponent")

	function extended:render()
		return v.createElement("Frame", nil, self.props.children, v.createElement("Frame"))
	end

	local extended2 = v.Component:extend("TestContainer")

	function extended2:render()
		return v.createElement(extended, nil, v.createElement("Frame"), nil, { "second" })
	end

	expect(function()
		v4:render(v.createElement(extended2))
		v2.unstable_flushAllWithoutAsserting()
	end).never.toThrow()
end)
it("should retain key during updates in composite components", function()
	local ref = v.createRef()
	local fn
	local extended = v.Component:extend("TestComponent")

	function extended:render()
		return v.createElement("Frame", {
			ref = ref
		}, self.props.children)
	end

	local extended2 = v.Component:extend("TestContainer")

	function extended2:init()
		self.state = {
			swapped = false
		}

		fn = function()
			self:setState({
				swapped = true
			})
		end
	end

	function extended2:render()
		return v.createElement(
			extended,
			nil,
			self.state.swapped and self.props.second or self.props.first,
			self.state.swapped and self.props.first or self.props.second
		)
	end

	local element = v.createElement("TextLabel", {
		key = "A",
		Text = "Hello"
	})
	local element2 = v.createElement("TextLabel", {
		key = "B",
		Text = "World"
	})

	local function childrenByProp(items)
		local result = {}

		for _, item in items do
			result[item.Text] = item
		end

		return result
	end

	v4:render(v.createElement(extended2, {
		first = element,
		second = element2
	}))
	v2.unstable_flushAllWithoutAsserting()
	local children = ref.current:GetChildren()
	local v5 = {}

	for _, v6 in children do
		v5[v6.Text] = v6
	end

	fn()
	local children2 = ref.current:GetChildren()
	local v6 = {}

	for _, v7 in children2 do
		v6[v7.Text] = v7
	end

	expect(v5.Hello).toBe(v6.Hello)
	expect(v5.World).toBe(v6.World)
end)
it("should not allow implicit and explicit keys to collide", function()
	local function fn(_)
		return v.createElement("Frame", nil, v.createElement("Frame"), v.createElement("Frame", {
			key = "1"
		}))
	end

	expect(function()
		v4:render(v.createElement(fn))
		v2.unstable_flushAllWithoutAsserting()
	end).never.toThrow()
end)