local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local expect = JestGlobals.expect
describe("ReactStrictMode", function()
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = true
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	it("should invoke precommit lifecycle methods twice", function()
		local v4 = {}
		local v5 = false
		local extended = v.Component:extend("ClassComponent")

		function extended.getDerivedStateFromProps()
			table.insert(v4, "getDerivedStateFromProps")
			return nil
		end

		function extended:init()
			self.state = {}
			table.insert(v4, "constructor")
		end

		function extended.componentDidMount(_)
			table.insert(v4, "componentDidMount")
		end

		function extended.componentDidUpdate(_)
			table.insert(v4, "componentDidUpdate")
		end

		function extended.componentWillUnmount(_)
			table.insert(v4, "componentWillUnmount")
		end

		function extended.shouldComponentUpdate(_)
			table.insert(v4, "shouldComponentUpdate")
			return v5
		end

		function extended.render(_)
			table.insert(v4, "render")
			return nil
		end

		v2.act(function()
			v2.render(v.createElement(v.StrictMode, nil, v.createElement(extended)))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"constructor",
				"constructor",
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"render",
				"render",
				"componentDidMount"
			})
		else
			expect(v4).toEqual({
				"constructor",
				"getDerivedStateFromProps",
				"render",
				"componentDidMount"
			})
		end

		v4 = {}
		v5 = true
		v2.act(function()
			v2.render(v.createElement(v.StrictMode, nil, v.createElement(extended)))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"shouldComponentUpdate",
				"render",
				"render",
				"componentDidUpdate"
			})
		else
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"render",
				"componentDidUpdate"
			})
		end

		v4 = {}
		v5 = false
		v2.act(function()
			v2.render(v.createElement(v.StrictMode, nil, v.createElement(extended)))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"shouldComponentUpdate"
			})
		else
			expect(v4).toEqual({ "getDerivedStateFromProps", "shouldComponentUpdate" })
		end
	end)
	it("should invoke setState callbacks twice", function()
		local v4 = nil
		local extended = v.Component:extend("ClassComponent")

		function extended:init()
			self.state = {
				count = 1
			}
		end

		function extended.render(p)
			v4 = p
			return nil
		end

		local count = 0
		v2.act(function()
			v2.render(v.createElement(v.StrictMode, nil, v.createElement(extended)))
		end)
		v2.flushSync(function()
			v4:setState(function(p)
				count += 1
				return {
					count = p.count + 1
				}
			end)
		end)
		expect(count).toEqual(ReactGlobals.__DEV__ and 2 or 1)
		expect(v4.state.count).toEqual(2)
	end)
	it("should invoke precommit lifecycle methods twice in DEV", function()
		local strictMode = v.StrictMode
		local v4 = {}
		local v5 = false
		local extended = v.Component:extend("ClassComponent")

		function extended:init(_)
			self.state = {}
			table.insert(v4, "constructor")
		end

		function extended.getDerivedStateFromProps()
			table.insert(v4, "getDerivedStateFromProps")
			return nil
		end

		function extended.componentDidMount(_)
			table.insert(v4, "componentDidMount")
		end

		function extended.componentDidUpdate(_)
			table.insert(v4, "componentDidUpdate")
		end

		function extended.componentWillUnmount(_)
			table.insert(v4, "componentWillUnmount")
		end

		function extended.shouldComponentUpdate(_)
			table.insert(v4, "shouldComponentUpdate")
			return v5
		end

		function extended.render(_)
			table.insert(v4, "render")
			return nil
		end

		local function Root()
			return v.createElement(strictMode, nil, v.createElement(extended))
		end

		v2.act(function()
			v2.render(v.createElement(Root))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"constructor",
				"constructor",
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"render",
				"render",
				"componentDidMount"
			})
		else
			expect(v4).toEqual({
				"constructor",
				"getDerivedStateFromProps",
				"render",
				"componentDidMount"
			})
		end

		v4 = {}
		v5 = true
		v2.act(function()
			v2.render(v.createElement(Root))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"shouldComponentUpdate",
				"render",
				"render",
				"componentDidUpdate"
			})
		else
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"render",
				"componentDidUpdate"
			})
		end

		v4 = {}
		v5 = false
		v2.act(function()
			v2.render(v.createElement(Root))
		end)

		if ReactGlobals.__DEV__ then
			expect(v4).toEqual({
				"getDerivedStateFromProps",
				"getDerivedStateFromProps",
				"shouldComponentUpdate",
				"shouldComponentUpdate"
			})
		else
			expect(v4).toEqual({ "getDerivedStateFromProps", "shouldComponentUpdate" })
		end
	end)
	it("should invoke setState callbacks twice in DEV", function()
		local strictMode = v.StrictMode
		local v4 = nil
		local extended = v.Component:extend("ClassComponent")

		function extended:init()
			self.state = {
				count = 1
			}
		end

		function extended.render(p)
			v4 = p
			return nil
		end

		local count = 0
		v2.act(function()
			v2.render(v.createElement(strictMode, nil, v.createElement(extended)))
		end)
		v2.flushSync(function()
			v4:setState(function(p)
				count += 1
				return {
					count = p.count + 1
				}
			end)
		end)
		expect(count).toEqual(ReactGlobals.__DEV__ and 2 or 1)
		expect(v4.state.count).toEqual(2)
	end)
end)
describe("Concurrent Mode", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	it("should warn about unsafe legacy lifecycle methods anywhere in the tree", function()
		local function Wrapper(p)
			local children = p.children
			return v.createElement("div", nil, children)
		end

		local extended = v.Component:extend("Foo")

		function extended.UNSAFE_componentWillReceiveProps(_) end

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Bar")

		function extended2.UNSAFE_componentWillReceiveProps(_) end

		function extended2.render(_)
			return nil
		end

		local extended3 = v.Component:extend("AsyncRoot")

		function extended3.UNSAFE_componentWillMount(_) end

		function extended3.UNSAFE_componentWillUpdate(_) end

		function extended3.render(_)
			return v.createElement(
				"div",
				nil,
				v.createElement(Wrapper, nil, v.createElement(extended)),
				v.createElement("div", nil, v.createElement(extended2), v.createElement(extended))
			)
		end

		local root = v2.createRoot()
		root.render(v.createElement(extended3))
		expect(function()
			return v3.unstable_flushAll()
		end).toErrorDev({ [[
Warning: Using UNSAFE_componentWillMount in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.

Please update the following components: AsyncRoot]], [[
Warning: Using UNSAFE_componentWillReceiveProps in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state

Please update the following components: Bar, Foo]], [[
Warning: Using UNSAFE_componentWillUpdate in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.

Please update the following components: AsyncRoot]] }, {
			withoutStack = true
		})
		root.render(v.createElement(extended3))
		v3.unstable_flushAll()
	end)
	it("should coalesce warnings by lifecycle name", function()
		local extended = v.Component:extend("Child")

		function extended.UNSAFE_componentWillReceiveProps(_) end

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Parent")

		function extended2.componentWillMount(_) end

		function extended2.componentWillUpdate(_) end

		function extended2.componentWillReceiveProps(_) end

		function extended2.render(_)
			return v.createElement(extended)
		end

		local extended3 = v.Component:extend("AsyncRoot")

		function extended3.UNSAFE_componentWillMount(_) end

		function extended3.UNSAFE_componentWillUpdate(_) end

		function extended3.render(_)
			return v.createElement(extended2)
		end

		local root = v2.createRoot()
		root.render(v.createElement(extended3))
		expect(function()
			expect(function()
				return v3.unstable_flushAll()
			end).toErrorDev({ [[
Warning: Using UNSAFE_componentWillMount in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.

Please update the following components: AsyncRoot]], [[
Warning: Using UNSAFE_componentWillReceiveProps in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state

Please update the following components: Child]], [[
Warning: Using UNSAFE_componentWillUpdate in strict mode is not recommended and may indicate bugs in your code. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.

Please update the following components: AsyncRoot]] }, {
				withoutStack = true
			})
		end).toWarnDev({ [[
Warning: componentWillMount has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.
* Rename componentWillMount to UNSAFE_componentWillMount to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: Parent]], [[
Warning: componentWillReceiveProps has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state
* Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: Parent]], [[
Warning: componentWillUpdate has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* Rename componentWillUpdate to UNSAFE_componentWillUpdate to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: Parent]] }, {
			withoutStack = true
		})
		root.render(v.createElement(extended3))
		v3.unstable_flushAll()
	end)
	it("should warn about components not present during the initial render", function()
		local extended = v.Component:extend("Foo")

		function extended.UNSAFE_componentWillMount(_) end

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Bar")

		function extended2.UNSAFE_componentWillMount(_) end

		function extended2.render(_)
			return nil
		end

		local extended3 = v.Component:extend("AsyncRoot")

		function extended3.render(p)
			return (function()
				if p.props.foo then
					return v.createElement(extended)
				end

				return v.createElement(extended2)
			end)()
		end

		local root = v2.createRoot()
		root.render(v.createElement(extended3, {
			foo = true
		}))
		expect(function()
			return v3.unstable_flushAll()
		end).toErrorDev("Using UNSAFE_componentWillMount in strict mode is not recommended", {
			withoutStack = true
		})
		root.render(v.createElement(extended3, {
			foo = false
		}))
		expect(function()
			return v3.unstable_flushAll()
		end).toErrorDev("Using UNSAFE_componentWillMount in strict mode is not recommended", {
			withoutStack = true
		})
		root.render(v.createElement(extended3, {
			foo = true
		}))
		v3.unstable_flushAll()
		root.render(v.createElement(extended3, {
			foo = false
		}))
		v3.unstable_flushAll()
	end)
	it("should also warn inside of \"strict\" mode trees", function()
		local strictMode = v.StrictMode
		local extended = v.Component:extend("Foo")

		function extended.UNSAFE_componentWillReceiveProps(_) end

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Bar")

		function extended2.UNSAFE_componentWillReceiveProps(_) end

		function extended2.render(_)
			return nil
		end

		local function Wrapper(_)
			return v.createElement("div", nil, v.createElement(extended2), v.createElement(extended))
		end

		local extended3 = v.Component:extend("SyncRoot")

		function extended3.UNSAFE_componentWillMount(_) end

		function extended3.UNSAFE_componentWillUpdate(_) end

		function extended3.UNSAFE_componentWillReceiveProps(_) end

		function extended3.render(_)
			return v.createElement(strictMode, nil, v.createElement(Wrapper))
		end

		local legacyRoot = v2.createLegacyRoot()
		expect(function()
			return legacyRoot.render(v.createElement(extended3))
		end).toErrorDev("Using UNSAFE_componentWillReceiveProps in strict mode is not recommended", {
			withoutStack = true
		})
		legacyRoot.render(v.createElement(extended3))
	end)
end)
describe("symbol checks", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	it("should switch from StrictMode to a Fragment and reset state", function()
		local fragment = v.Fragment
		local strictMode = v.StrictMode
		local extended = v.Component:extend("ChildComponent")

		function extended:init()
			self.state = {
				count = 0
			}
		end

		function extended.getDerivedStateFromProps(_, p)
			return {
				count = p.count + 1
			}
		end

		function extended.render(p)
			return string.format("count:%s", p.state.count)
		end

		local function ParentComponent(p)
			local useFragment = p.useFragment
			return (function()
				if useFragment then
					return v.createElement(fragment, nil, v.createElement(extended))
				end

				return v.createElement(strictMode, nil, v.createElement(extended))
			end)()
		end

		v2.act(function()
			v2.render(v.createElement(ParentComponent, {
				useFragment = false
			}))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:1")
		v2.act(function()
			v2.render(v.createElement(ParentComponent, {
				useFragment = true
			}))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:1")
	end)
	it("should switch from a Fragment to StrictMode and reset state", function()
		local fragment = v.Fragment
		local strictMode = v.StrictMode
		local extended = v.Component:extend("ChildComponent")

		function extended:init()
			self.state = {
				count = 0
			}
		end

		function extended.getDerivedStateFromProps(_, p)
			return {
				count = p.count + 1
			}
		end

		function extended.render(p)
			return string.format("count:%s", p.state.count)
		end

		local function ParentComponent(p)
			local useFragment = p.useFragment
			return (function()
				if useFragment then
					return v.createElement(fragment, nil, v.createElement(extended))
				end

				return v.createElement(strictMode, nil, v.createElement(extended))
			end)()
		end

		v2.act(function()
			v2.render(v.createElement(ParentComponent, {
				useFragment = false
			}))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:1")
		v2.act(function()
			v2.render(v.createElement(ParentComponent, {
				useFragment = true
			}))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:1")
	end)
	it("should update with StrictMode without losing state", function()
		local strictMode = v.StrictMode
		local extended = v.Component:extend("ChildComponent")

		function extended:init()
			self.state = {
				count = 0
			}
		end

		function extended.getDerivedStateFromProps(_, p)
			return {
				count = p.count + 1
			}
		end

		function extended.render(p)
			return string.format("count:%s", p.state.count)
		end

		local function ParentComponent()
			return v.createElement(strictMode, nil, v.createElement(extended))
		end

		v2.act(function()
			v2.render(v.createElement(ParentComponent))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:1")
		v2.act(function()
			v2.render(v.createElement(ParentComponent))
		end)
		expect(v2.getChildren()[1].text).toEqual("count:2")
	end)
end)
describe("string refs", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	xit("should warn within a strict tree", function() end)
	xit("should warn within a strict tree 2", function() end)
end)
describe("context legacy", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	xit("should warn if the legacy context API have been used in strict mode", function() end)
end)