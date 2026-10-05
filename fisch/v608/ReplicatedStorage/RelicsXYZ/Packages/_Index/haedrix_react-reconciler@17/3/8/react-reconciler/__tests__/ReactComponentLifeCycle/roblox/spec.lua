local HttpService = game:GetService("HttpService")
local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil
local v2 = nil
local v3 = {
	hasWillMountCompleted = false,
	hasRenderCompleted = false,
	hasDidMountCompleted = false,
	hasWillUnmountCompleted = false
}
local v4 = {
	hasWillMountCompleted = true,
	hasRenderCompleted = false,
	hasDidMountCompleted = false,
	hasWillUnmountCompleted = false
}
local v5 = {
	hasWillMountCompleted = true,
	hasRenderCompleted = true,
	hasDidMountCompleted = false,
	hasWillUnmountCompleted = false
}
local v6 = {
	hasWillMountCompleted = true,
	hasRenderCompleted = true,
	hasDidMountCompleted = true,
	hasWillUnmountCompleted = false
}
local v7 = {
	hasWillMountCompleted = true,
	hasDidMountCompleted = true,
	hasRenderCompleted = true,
	hasWillUnmountCompleted = false
}
local v8 = {
	hasWillMountCompleted = true,
	hasDidMountCompleted = true,
	hasRenderCompleted = true,
	hasWillUnmountCompleted = true
}

local function getLifeCycleState(p)
	if p.__updater.isMounted(p) then
		return "MOUNTED"
	end

	return "UNMOUNTED"
end

local __COMPAT_WARNINGS__ = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	__COMPAT_WARNINGS__ = ReactGlobals.__COMPAT_WARNINGS__
	ReactGlobals.__COMPAT_WARNINGS__ = false
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Shared = require(parent.Shared)
	Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
end)
afterEach(function()
	ReactGlobals.__COMPAT_WARNINGS__ = __COMPAT_WARNINGS__
end)
it("should correctly determine if a component is mounted", function()
	local fn
	local extended = v.Component:extend("Component")

	function extended:init()
		fn = function()
			return self.__updater.isMounted(self)
		end
	end

	function extended.UNSAFE_componentWillMount(_)
		expect(fn()).toBe(false)
	end

	function extended.didMount(p)
		expect(p).never.toEqual(nil)
		expect(fn()).toBe(true)
	end

	function extended.render(_)
		expect(fn()).toBe(false)
		return v.createElement("div")
	end

	local element = v.createElement(extended)
	expect(function()
		v2.act(function()
			v2.render(element)
		end)
		expect(fn()).toBe(true)
	end).toErrorDev({
		"Component is accessing isMounted inside its render()",
		"UNSAFE_componentWillMount in strict mode is not recommended"
	}, {
		withoutStack = 1
	})
end)
it("should correctly determine if a nil component is mounted", function()
	local fn
	local extended = v.Component:extend("Component")

	function extended:init()
		fn = function()
			return self.__updater.isMounted(self)
		end
	end

	function extended.UNSAFE_componentWillMount(_)
		expect(fn()).toBe(false)
	end

	function extended.didMount(_)
		expect(fn()).toBe(true)
	end

	function extended.render(_)
		expect(fn()).toBe(false)
		return nil
	end

	local element = v.createElement(extended)
	expect(function()
		v2.act(function()
			v2.render(element)
		end)
		expect(fn()).toBe(true)
	end).toErrorDev({
		"Component is accessing isMounted inside its render()",
		"UNSAFE_componentWillMount in strict mode is not recommended"
	}, {
		withoutStack = 1
	})
end)
it("should carry through each of the phases of setup", function()
	local v9 = {}
	local fn
	local fn2
	local extended = v.Component:extend("LifeCycleComponent")

	function extended:init()
		local state = {
			hasWillMountCompleted = false,
			hasDidMountCompleted = false,
			hasRenderCompleted = false,
			hasWillUnmountCompleted = false
		}

		fn = function()
			local v11 = self

			if v11.__updater.isMounted(v11) then
				return "MOUNTED"
			end

			return "UNMOUNTED"
		end

		fn2 = function()
			return self.state
		end

		v9.returnedFromGetInitialState = HttpService:JSONDecode(HttpService:JSONEncode(state))
		v9.lifeCycleAtStartOfGetInitialState = fn()
		self.state = state
	end

	function extended.UNSAFE_componentWillMount(p)
		v9.stateAtStartOfWillMount = HttpService:JSONDecode(HttpService:JSONEncode(p.state))
		v9.lifeCycleAtStartOfWillMount = fn()
		p.state.hasWillMountCompleted = true
	end

	function extended.didMount(object)
		v9.stateAtStartOfDidMount = HttpService:JSONDecode(HttpService:JSONEncode(object.state))
		v9.lifeCycleAtStartOfDidMount = fn()
		object:setState({
			hasDidMountCompleted = true
		})
	end

	function extended.render(p)
		if p.state.hasRenderCompleted then
			v9.stateInLaterRender = HttpService:JSONDecode(HttpService:JSONEncode(p.state))
			v9.lifeCycleInLaterRender = fn()
		else
			v9.stateInInitialRender = HttpService:JSONDecode(HttpService:JSONEncode(p.state))
			v9.lifeCycleInInitialRender = fn()
		end

		p.state.hasRenderCompleted = true
		return v.createElement("TextLabel", {
			Text = "I am the inner DIV"
		})
	end

	function extended.willUnmount(p)
		expect(p).never.toEqual(nil)
		v9.stateAtStartOfWillUnmount = HttpService:JSONDecode(HttpService:JSONEncode(p.state))
		v9.lifeCycleAtStartOfWillUnmount = fn()
		p.state.hasWillUnmountCompleted = true
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended))
		end)
	end).toErrorDev({
		"LifeCycleComponent is accessing isMounted inside its render() function",
		"UNSAFE_componentWillMount in strict mode is not recommended"
	}, {
		withoutStack = 1
	})
	expect(v9.returnedFromGetInitialState).toEqual(v3)
	expect(v9.lifeCycleAtStartOfGetInitialState).toBe("UNMOUNTED")
	expect(v9.stateAtStartOfWillMount).toEqual(v9.returnedFromGetInitialState)
	expect(v9.lifeCycleAtStartOfWillMount).toBe("UNMOUNTED")
	expect(v9.stateAtStartOfDidMount).toEqual(v5)
	expect(v9.lifeCycleAtStartOfDidMount).toBe("MOUNTED")
	expect(v9.stateInInitialRender).toEqual(v4)
	expect(v9.lifeCycleInInitialRender).toBe("UNMOUNTED")
	expect(fn()).toBe("MOUNTED")
	v2.act(function()
		v2.render(v.createElement(extended))
	end)
	expect(v9.stateInLaterRender).toEqual(v6)
	expect(v9.lifeCycleInLaterRender).toBe("MOUNTED")
	expect(fn()).toBe("MOUNTED")
	v2.act(function()
		v2.render(nil)
	end)
	expect(v9.stateAtStartOfWillUnmount).toEqual(v7)
	expect(v9.lifeCycleAtStartOfWillUnmount).toBe("MOUNTED")
	expect(fn()).toBe("UNMOUNTED")
	expect(fn2()).toEqual(v8)
end)
it("should allow state updates in didMount", function()
	local fn
	local extended = v.Component:extend("SetStateInComponentDidMount")

	function extended:init()
		self.state = {
			stateField = self.props.valueToUseInitially
		}

		fn = function()
			return self.state
		end
	end

	function extended.didMount(object)
		object:setState({
			stateField = object.props.valueToUseAfterMount
		})
	end

	function extended.render(_)
		return v.createElement("div")
	end

	local element = v.createElement(extended, {
		valueToUseInitially = "hello",
		valueToUseAfterMount = "goodbye"
	})
	v2.act(function()
		v2.render(element)
	end)
	expect(fn().stateField).toBe("goodbye")
end)
it("should call nested legacy lifecycle methods in the right order", function()
	local v9 = nil
	local extended = v.Component:extend("Outer")
	local extended2 = v.Component:extend("Inner")
	local v10 = "outer componentWillMount"

	function extended.UNSAFE_componentWillMount()
		table.insert(v9, v10)
		return true
	end

	local v11 = "outer didMount"

	function extended.didMount()
		table.insert(v9, v11)
		return true
	end

	local v12 = "outer componentWillReceiveProps"

	function extended.UNSAFE_componentWillReceiveProps()
		table.insert(v9, v12)
		return true
	end

	local v13 = "outer shouldUpdate"

	function extended.shouldUpdate()
		table.insert(v9, v13)
		return true
	end

	local v14 = "outer willUpdate"

	function extended.willUpdate()
		table.insert(v9, v14)
		return true
	end

	local v15 = "outer didUpdate"

	function extended.didUpdate()
		table.insert(v9, v15)
		return true
	end

	local v16 = "outer willUnmount"

	function extended.willUnmount()
		table.insert(v9, v16)
		return true
	end

	function extended.render(p)
		return v.createElement("Frame", {}, v.createElement(extended2, {
			x = p.props.x
		}))
	end

	local v17 = "inner componentWillMount"

	function extended2.UNSAFE_componentWillMount()
		table.insert(v9, v17)
		return true
	end

	local v18 = "inner didMount"

	function extended2.didMount()
		table.insert(v9, v18)
		return true
	end

	local v19 = "inner componentWillReceiveProps"

	function extended2.UNSAFE_componentWillReceiveProps()
		table.insert(v9, v19)
		return true
	end

	local v20 = "inner shouldUpdate"

	function extended2.shouldUpdate()
		table.insert(v9, v20)
		return true
	end

	local v21 = "inner willUpdate"

	function extended2.willUpdate()
		table.insert(v9, v21)
		return true
	end

	local v22 = "inner didUpdate"

	function extended2.didUpdate()
		table.insert(v9, v22)
		return true
	end

	local v23 = "inner willUnmount"

	function extended2.willUnmount()
		table.insert(v9, v23)
		return true
	end

	function extended2.render(p)
		return v.createElement("TextLabel", {
			Text = p.props.x
		})
	end

	v9 = {}
	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended, {
				x = 1
			}))
		end)
	end).toErrorDev({
		"Using UNSAFE_componentWillMount in strict mode is not recommended",
		"Using UNSAFE_componentWillReceiveProps in strict mode is not recommended",
		"Using UNSAFE_componentWillUpdate in strict mode is not recommended"
	}, {
		withoutStack = true
	})
	expect(v9).toEqual({
		"outer componentWillMount",
		"inner componentWillMount",
		"inner didMount",
		"outer didMount"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 2
		}))
	end)
	expect(v9).toEqual({
		"outer componentWillReceiveProps",
		"outer shouldUpdate",
		"outer willUpdate",
		"inner componentWillReceiveProps",
		"inner shouldUpdate",
		"inner willUpdate",
		"inner didUpdate",
		"outer didUpdate"
	})
	v9 = {}
	v2.act(function()
		v2.render(nil)
	end)
	expect(v9).toEqual({ "outer willUnmount", "inner willUnmount" })
end)
it("should call nested new lifecycle methods in the right order", function()
	local v9 = nil
	local extended = v.Component:extend("Outer")
	local extended2 = v.Component:extend("Inner")

	function extended:init()
		self.state = {}
	end

	function extended.getDerivedStateFromProps(_, _)
		table.insert(v9, "outer getDerivedStateFromProps")
		return nil
	end

	local v10 = "outer didMount"

	function extended.didMount()
		table.insert(v9, v10)
		return true
	end

	local v11 = "outer shouldUpdate"

	function extended.shouldUpdate()
		table.insert(v9, v11)
		return true
	end

	local v12 = "outer getSnapshotBeforeUpdate"

	function extended.getSnapshotBeforeUpdate()
		table.insert(v9, v12)
		return true
	end

	local v13 = "outer didUpdate"

	function extended.didUpdate()
		table.insert(v9, v13)
		return true
	end

	local v14 = "outer willUnmount"

	function extended.willUnmount()
		table.insert(v9, v14)
		return true
	end

	function extended.render(p)
		return v.createElement("Frame", {}, v.createElement(extended2, {
			x = p.props.x
		}))
	end

	function extended2:init()
		self.state = {}
	end

	function extended2.getDerivedStateFromProps(_, _)
		table.insert(v9, "inner getDerivedStateFromProps")
		return nil
	end

	local v15 = "inner didMount"

	function extended2.didMount()
		table.insert(v9, v15)
		return true
	end

	local v16 = "inner shouldUpdate"

	function extended2.shouldUpdate()
		table.insert(v9, v16)
		return true
	end

	local v17 = "inner getSnapshotBeforeUpdate"

	function extended2.getSnapshotBeforeUpdate()
		table.insert(v9, v17)
		return true
	end

	local v18 = "inner didUpdate"

	function extended2.didUpdate()
		table.insert(v9, v18)
		return true
	end

	local v19 = "inner willUnmount"

	function extended2.willUnmount()
		table.insert(v9, v19)
		return true
	end

	function extended2.render(p)
		return v.createElement("TextLabel", {
			Text = p.props.x
		})
	end

	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 1
		}))
	end)
	expect(v9).toEqual({
		"outer getDerivedStateFromProps",
		"inner getDerivedStateFromProps",
		"inner didMount",
		"outer didMount"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 2
		}))
	end)
	expect(v9).toEqual({
		"outer getDerivedStateFromProps",
		"outer shouldUpdate",
		"inner getDerivedStateFromProps",
		"inner shouldUpdate",
		"inner getSnapshotBeforeUpdate",
		"outer getSnapshotBeforeUpdate",
		"inner didUpdate",
		"outer didUpdate"
	})
	v9 = {}
	v2.act(function()
		v2.render(nil)
	end)
	expect(v9).toEqual({ "outer willUnmount", "inner willUnmount" })
end)
it("should warn if state is not initialized before getDerivedStateFromProps", function()
	local extended = v.Component:extend("MyComponent")

	function extended.getDerivedStateFromProps()
		return nil
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended))
		end)
	end).toErrorDev("`MyComponent` uses `getDerivedStateFromProps` but its initial state has not been initialized. This is not recommended. Instead, define the initial state by passing an object to `self:setState` in the `init` method of `MyComponent`. This ensures that `getDerivedStateFromProps` arguments have a consistent shape.")
	v2.act(function()
		v2.render(v.createElement(extended))
	end)
end)
it("should pass the return value from getSnapshotBeforeUpdate to didUpdate", function()
	local v9 = {}
	local extended = v.Component:extend("MyComponent")

	function extended:init()
		self.state = {
			value = 0
		}
	end

	function extended.getDerivedStateFromProps(_, p)
		return {
			value = p.value + 1
		}
	end

	function extended.getSnapshotBeforeUpdate(_, p, p2)
		table.insert(v9, string.format("getSnapshotBeforeUpdate() prevProps:%s prevState:%s", p.value, p2.value))
		return "abc"
	end

	function extended.didUpdate(_, p, p2, p3)
		table.insert(v9, string.format("didUpdate() prevProps:%s prevState:%s snapshot:%s", p.value, p2.value, p3))
	end

	function extended.render(_)
		table.insert(v9, "render")
		return nil
	end

	v2.act(function()
		v2.render(v.createElement("Frame", {}, v.createElement(extended, {
			value = "foo"
		})))
	end)
	expect(v9).toEqual({ "render" })
	v9 = {}
	v2.act(function()
		v2.render(v.createElement("Frame", {}, v.createElement(extended, {
			value = "bar"
		})))
	end)
	expect(v9).toEqual({
		"render",
		"getSnapshotBeforeUpdate() prevProps:foo prevState:1",
		"didUpdate() prevProps:foo prevState:1 snapshot:abc"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement("Frame", {}, v.createElement(extended, {
			value = "baz"
		})))
	end)
	expect(v9).toEqual({
		"render",
		"getSnapshotBeforeUpdate() prevProps:bar prevState:2",
		"didUpdate() prevProps:bar prevState:2 snapshot:abc"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement("Frame"))
	end)
	expect(v9).toEqual({})
end)
it("should pass previous state to shouldUpdate even with getDerivedStateFromProps", function()
	local ref = v.createRef()
	local value = nil
	local extended = v.Component:extend("SimpleComponent")

	function extended:init(p2)
		self.state = {
			value = p2.value
		}
	end

	function extended.getDerivedStateFromProps(p, p2)
		if p.value == p2.value then
			return nil
		end

		return {
			value = p.value
		}
	end

	function extended.shouldUpdate(p, _, p2)
		return p2.value ~= p.state.value
	end

	function extended.render(p)
		value = p.state.value
		return v.createElement("Frame", {
			ref = ref
		}, v.createElement("TextLabel", {
			Text = p.state.value
		}))
	end

	v2.act(function()
		v2.render(v.createElement(extended, {
			value = "initial"
		}))
	end)
	expect(value).toBe("initial")
	v2.act(function()
		v2.render(v.createElement(extended, {
			value = "updated"
		}))
	end)
	expect(value).toBe("updated")
end)
it("should warn if getSnapshotBeforeUpdate is defined with no componentDidUpdate", function()
	local extended = v.Component:extend("MyComponent")

	function extended.getSnapshotBeforeUpdate(_)
		return nil
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended))
		end)
	end).toErrorDev("MyComponent: getSnapshotBeforeUpdate() should be used with componentDidUpdate(). This component defines getSnapshotBeforeUpdate() only.")
	v2.act(function()
		v2.render(v.createElement(extended))
	end)
end)
describe("Naming conventions", function()
	local __COMPAT_WARNINGS__2 = nil
	beforeEach(function()
		__COMPAT_WARNINGS__2 = ReactGlobals.__COMPAT_WARNINGS__
		ReactGlobals.__COMPAT_WARNINGS__ = true
		jest.resetModules()
		jest.useFakeTimers()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Shared = require(parent.Shared)
		Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	end)
	afterEach(function()
		ReactGlobals.__COMPAT_WARNINGS__ = __COMPAT_WARNINGS__2
	end)

	local function testWithComponentKind(p: string)
		it("should warn if using old Roact didMount naming in " .. p, function()
			local extended = v[p]:extend("Foo")
			expect(function()
				function extended.didMount(_) end
			end).toWarnDev([[
Foo is using method 'didMount', which is no longer supported and should be updated to 'componentDidMount'
File: ReactComponentLifeCycle.roblox.spec:]], {
				withoutStack = true
			})
		end)
		it("should warn if using old Roact shouldUpdate naming in " .. p, function()
			local extended = v[p]:extend("Foo")
			expect(function()
				function extended.shouldUpdate(_) end
			end).toWarnDev([[
Foo is using method 'shouldUpdate', which is no longer supported and should be updated to 'shouldComponentUpdate'
File: ReactComponentLifeCycle.roblox.spec:]], {
				withoutStack = true
			})
		end)
		it("should warn if using old Roact willUpdate naming in " .. p, function()
			local extended = v[p]:extend("Foo")
			expect(function()
				function extended.willUpdate(_) end
			end).toWarnDev([[
Foo is using method 'willUpdate', which is no longer supported and should be updated to 'UNSAFE_componentWillUpdate'
File: ReactComponentLifeCycle.roblox.spec:]], {
				withoutStack = true
			})
		end)
		it("should warn if using old Roact didUpdate naming in " .. p, function()
			local extended = v[p]:extend("Foo")
			expect(function()
				function extended.didUpdate(_) end
			end).toWarnDev([[
Foo is using method 'didUpdate', which is no longer supported and should be updated to 'componentDidUpdate'
File: ReactComponentLifeCycle.roblox.spec:]], {
				withoutStack = true
			})
		end)
		it("should warn if using old Roact willUnmount naming in " .. p, function()
			local extended = v[p]:extend("Foo")
			expect(function()
				function extended.willUnmount(_) end
			end).toWarnDev([[
Foo is using method 'willUnmount', which is no longer supported and should be updated to 'componentWillUnmount'
File: ReactComponentLifeCycle.roblox.spec:]], {
				withoutStack = true
			})
		end)
		it("should warn if both didMount and componentDidMount are defined on the same " .. p, function()
			local extended = v[p]:extend("Foo")

			function extended.componentDidMount(_) end

			expect(function()
				function extended.didMount(_) end
			end).toWarnDev("Warning: Foo already defined 'componentDidMount', but it also defining the deprecated Roact method 'didMount'. Foo should only implement one of these methods, preferably using the non-deprecated name.", {
				withoutStack = true
			})
		end)
		it("should warn if both shouldUpdate and shouldComponentUpdate are defined on the same " .. p, function()
			local extended = v[p]:extend("Foo")

			function extended.shouldComponentUpdate(_) end

			expect(function()
				function extended.shouldUpdate(_) end
			end).toWarnDev("Warning: Foo already defined 'shouldComponentUpdate', but it also defining the deprecated Roact method 'shouldUpdate'. Foo should only implement one of these methods, preferably using the non-deprecated name.", {
				withoutStack = true
			})
		end)
		it("should warn if both willUpdate and componentWillUpdate are defined on the same " .. p, function()
			local extended = v[p]:extend("Foo")

			function extended.componentWillUpdate(_) end

			expect(function()
				function extended.willUpdate(_) end
			end).toWarnDev("Warning: Foo already defined 'UNSAFE_componentWillUpdate', but it also defining the deprecated Roact method 'willUpdate'. Foo should only implement one of these methods, preferably using the non-deprecated name.", {
				withoutStack = true
			})
			local extended2 = v[p]:extend("Bar")

			function extended2.UNSAFE_componentWillUpdate(_) end

			expect(function()
				function extended2.willUpdate(_) end
			end).toWarnDev("Warning: Bar already defined 'UNSAFE_componentWillUpdate', but it also defining the deprecated Roact method 'willUpdate'. Bar should only implement one of these methods, preferably using the non-deprecated name.", {
				withoutStack = true
			})
		end)
		it("should worn if both didUpdate and componentDidUpdate are defined on the same " .. p, function()
			local extended = v[p]:extend("Foo")

			function extended.componentDidUpdate(_) end

			expect(function()
				function extended.didUpdate(_) end
			end).toWarnDev("Warning: Foo already defined 'componentDidUpdate', but it also defining the deprecated Roact method 'didUpdate'. Foo should only implement one of these methods, preferably using the non-deprecated name.", {
				withoutStack = true
			})
		end)
		it("should warn if both willUnmount and componentWillUnmount are defined on the same " .. p, function()
			local extended = v[p]:extend("Foo")

			function extended.componentWillUnmount(_) end

			expect(function()
				function extended.willUnmount(_) end
			end).toWarnDev("Warning: Foo already defined 'componentWillUnmount', but it also defining the deprecated Roact method 'willUnmount'. Foo should only implement one of these methods, preferably using the non-deprecated name", {
				withoutStack = true
			})
		end)
	end

	testWithComponentKind("Component")
	testWithComponentKind("PureComponent")
end)