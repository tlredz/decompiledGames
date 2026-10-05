local HttpService = game:GetService("HttpService")
local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local it = JestGlobals.it
local xit = JestGlobals.xit
local beforeEach = JestGlobals.beforeEach
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
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

beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Shared = require(parent.Shared)
	Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
end)
xit("throws when accessing state in componentWillMount", function()
	local extended = v.Component:extend("StatefulComponent")

	function extended.UNSAFE_componentWillMount(p)
		expect(p).never.toEqual(nil)
		return p.state.yada
	end

	function extended.render(p)
		expect(p).never.toEqual(nil)
		return v.createElement("div")
	end

	local element = v.createElement(extended)
	expect(function()
		v2.act(function()
			element = v2.render(element)
		end)
	end).toThrow("yada")
end)
it("should allow update state inside of componentWillMount", function()
	local extended = v.Component:extend("StatefulComponent")

	function extended.UNSAFE_componentWillMount(object)
		object:setState({
			stateField = "something"
		})
	end

	function extended.render(_)
		return v.createElement("div")
	end

	local element = v.createElement(extended)
	expect(function()
		expect(function()
			v2.act(function()
				element = v2.render(element)
			end)
		end).toErrorDev({ "Using UNSAFE_componentWillMount in strict mode is not recommended" }, {
			withoutStack = true
		})
	end).never.toThrow()
end)
it("warns if setting 'self.state = props'", function()
	local extended = v.Component:extend("StatefulComponent")

	function extended:init()
		self.state = self.props
	end

	function extended.render(_)
		return v.createElement("div")
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended))
		end)
	end).toErrorDev("StatefulComponent: It is not recommended to assign props directly to state because updates to props won't be reflected in state. In most cases, it is better to use props directly.")
end)
xit("should not allow update state inside of getInitialState", function()
	local extended = v.Component:extend("StatefulComponent")

	function extended:init()
		self:setState({
			stateField = "something"
		})
		self.state = {
			stateField = "somethingelse"
		}
	end

	function extended.render(_)
		return v.createElement("div")
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended))
		end)
	end).toErrorDev("Warning: Can't call setState on a component that is not yet mounted. This is a no-op, but it might indicate a bug in your application. Instead, assign to `self.state` directly with the desired state in the StatefulComponent component's `init` method.")
	v2.act(function()
		v2.render(v.createElement(extended))
	end)
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

	function extended.componentDidMount(p)
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

	function extended.componentDidMount(_)
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
it("isMounted should return false when unmounted", function()
	local fn
	local extended = v.Component:extend("Component")

	function extended:init()
		fn = function()
			return self.__updater.isMounted(self)
		end
	end

	function extended.render(_)
		return v.createElement("div")
	end

	v2.act(function()
		v2.render(v.createElement(extended))
	end)
	expect(fn()).toBe(true)
	v2.act(function()
		v2.render(nil)
	end)
	expect(fn()).toBe(false)
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

	function extended.componentDidMount(object)
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

	function extended.componentWillUnmount(p)
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
xit("should not throw when updating an auxiliary component", function()
	local extended = v.Component:extend("Tooltip")

	function extended.render(p)
		return v.createElement("div", nil, p.props.children)
	end

	function extended:componentDidMount()
		self.container = "some container"
		self:updateTooltip()
	end

	function extended:componentDidUpdate()
		self:updateTooltip()
	end

	function extended:updateTooltip()
		v2.act(function()
			v2.renderToRootWithID(self.props.tooltip, self.container)
		end)
	end

	local extended2 = v.Component:extend("Component")

	function extended2.render(p)
		return v.createElement(extended, {
			tooltip = v.createElement("div", nil, p.props.tooltipText)
		}, p.props.text)
	end

	v2.act(function()
		v2.render(v.createElement(extended2, {
			text = "uno",
			tooltipText = "one"
		}))
	end)
	v2.act(function()
		v2.render(v.createElement(extended2, {
			text = "dos",
			tooltipText = "two"
		}))
	end)
end)
it("should allow state updates in componentDidMount", function()
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

	function extended.componentDidMount(object)
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

	local v11 = "outer componentDidMount"

	function extended.componentDidMount()
		table.insert(v9, v11)
		return true
	end

	local v12 = "outer componentWillReceiveProps"

	function extended.UNSAFE_componentWillReceiveProps()
		table.insert(v9, v12)
		return true
	end

	local v13 = "outer shouldComponentUpdate"

	function extended.shouldComponentUpdate()
		table.insert(v9, v13)
		return true
	end

	local v14 = "outer componentWillUpdate"

	function extended.UNSAFE_componentWillUpdate()
		table.insert(v9, v14)
		return true
	end

	local v15 = "outer componentDidUpdate"

	function extended.componentDidUpdate()
		table.insert(v9, v15)
		return true
	end

	local v16 = "outer componentWillUnmount"

	function extended.componentWillUnmount()
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

	local v18 = "inner componentDidMount"

	function extended2.componentDidMount()
		table.insert(v9, v18)
		return true
	end

	local v19 = "inner componentWillReceiveProps"

	function extended2.UNSAFE_componentWillReceiveProps()
		table.insert(v9, v19)
		return true
	end

	local v20 = "inner shouldComponentUpdate"

	function extended2.shouldComponentUpdate()
		table.insert(v9, v20)
		return true
	end

	local v21 = "inner componentWillUpdate"

	function extended2.UNSAFE_componentWillUpdate()
		table.insert(v9, v21)
		return true
	end

	local v22 = "inner componentDidUpdate"

	function extended2.componentDidUpdate()
		table.insert(v9, v22)
		return true
	end

	local v23 = "inner componentWillUnmount"

	function extended2.componentWillUnmount()
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
		"inner componentDidMount",
		"outer componentDidMount"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 2
		}))
	end)
	expect(v9).toEqual({
		"outer componentWillReceiveProps",
		"outer shouldComponentUpdate",
		"outer componentWillUpdate",
		"inner componentWillReceiveProps",
		"inner shouldComponentUpdate",
		"inner componentWillUpdate",
		"inner componentDidUpdate",
		"outer componentDidUpdate"
	})
	v9 = {}
	v2.act(function()
		v2.render(nil)
	end)
	expect(v9).toEqual({ "outer componentWillUnmount", "inner componentWillUnmount" })
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

	local v10 = "outer componentDidMount"

	function extended.componentDidMount()
		table.insert(v9, v10)
		return true
	end

	local v11 = "outer shouldComponentUpdate"

	function extended.shouldComponentUpdate()
		table.insert(v9, v11)
		return true
	end

	local v12 = "outer getSnapshotBeforeUpdate"

	function extended.getSnapshotBeforeUpdate()
		table.insert(v9, v12)
		return true
	end

	local v13 = "outer componentDidUpdate"

	function extended.componentDidUpdate()
		table.insert(v9, v13)
		return true
	end

	local v14 = "outer componentWillUnmount"

	function extended.componentWillUnmount()
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

	local v15 = "inner componentDidMount"

	function extended2.componentDidMount()
		table.insert(v9, v15)
		return true
	end

	local v16 = "inner shouldComponentUpdate"

	function extended2.shouldComponentUpdate()
		table.insert(v9, v16)
		return true
	end

	local v17 = "inner getSnapshotBeforeUpdate"

	function extended2.getSnapshotBeforeUpdate()
		table.insert(v9, v17)
		return true
	end

	local v18 = "inner componentDidUpdate"

	function extended2.componentDidUpdate()
		table.insert(v9, v18)
		return true
	end

	local v19 = "inner componentWillUnmount"

	function extended2.componentWillUnmount()
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
		"inner componentDidMount",
		"outer componentDidMount"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 2
		}))
	end)
	expect(v9).toEqual({
		"outer getDerivedStateFromProps",
		"outer shouldComponentUpdate",
		"inner getDerivedStateFromProps",
		"inner shouldComponentUpdate",
		"inner getSnapshotBeforeUpdate",
		"outer getSnapshotBeforeUpdate",
		"inner componentDidUpdate",
		"outer componentDidUpdate"
	})
	v9 = {}
	v2.act(function()
		v2.render(nil)
	end)
	expect(v9).toEqual({ "outer componentWillUnmount", "inner componentWillUnmount" })
end)
it("should not invoke deprecated lifecycles (cWM/cWRP/cWU) if new static gDSFP is present", function()
	local extended = v.Component:extend("Component")

	function extended:init()
		self.state = {}
	end

	function extended.getDerivedStateFromProps()
		return nil
	end

	function extended.componentWillMount(_)
		error(error2("unexpected"))
	end

	function extended.componentWillReceiveProps(p)
		expect(p).never.toEqual(nil)
		error(error2("unexpected"))
	end

	function extended.componentWillUpdate(_)
		error(error2("unexpected"))
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended))
			end)
		end).toErrorDev("Unsafe legacy lifecycles will not be called for components using new component APIs.")
	end).toWarnDev({
		"componentWillMount has been renamed",
		"componentWillReceiveProps has been renamed",
		"componentWillUpdate has been renamed"
	}, {
		withoutStack = true
	})
end)
it("should not invoke deprecated lifecycles (cWM/cWRP/cWU) if new getSnapshotBeforeUpdate is present", function()
	local extended = v.Component:extend("Component")

	function extended:init()
		self.state = {}
	end

	function extended.getSnapshotBeforeUpdate(_)
		return nil
	end

	function extended.componentWillMount(_)
		error(error2("unexpected"))
	end

	function extended.componentWillReceiveProps(_)
		error(error2("unexpected"))
	end

	function extended.componentWillUpdate(p)
		expect(p).never.toEqual(nil)
		error(error2("unexpected"))
	end

	function extended.componentDidUpdate(p)
		expect(p).never.toEqual(nil)
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					value = 1
				}))
			end)
		end).toErrorDev("Unsafe legacy lifecycles will not be called for components using new component APIs.")
	end).toWarnDev({
		"componentWillMount has been renamed",
		"componentWillReceiveProps has been renamed",
		"componentWillUpdate has been renamed"
	}, {
		withoutStack = true
	})
	v2.act(function()
		v2.render(v.createElement(extended, {
			value = 2
		}))
	end)
end)
it("should not invoke new unsafe lifecycles (cWM/cWRP/cWU) if static gDSFP is present", function()
	local extended = v.Component:extend("Component")

	function extended:init()
		self.state = {}
	end

	function extended.getDerivedStateFromProps()
		return nil
	end

	function extended.UNSAFE_componentWillMount(_)
		error(error2("unexpected"))
	end

	function extended.UNSAFE_componentWillReceiveProps(_)
		error(error2("unexpected"))
	end

	function extended.UNSAFE_componentWillUpdate(_)
		error(error2("unexpected"))
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended, {
				value = 1
			}))
		end)
	end).toErrorDev({
		"Unsafe legacy lifecycles will not be called for components using new component APIs.",
		"Using UNSAFE_componentWillMount in strict mode is not recommended",
		"Using UNSAFE_componentWillReceiveProps in strict mode is not recommended",
		"Using UNSAFE_componentWillUpdate in strict mode is not recommended"
	}, {
		withoutStack = 3
	})
	v2.act(function()
		v2.render(v.createElement(extended, {
			value = 2
		}))
	end)
end)
it("should warn about deprecated lifecycles (cWM/cWRP/cWU) if new static gDSFP is present", function()
	local extended = v.Component:extend("AllLegacyLifecycles")

	function extended:init()
		self.state = {}
	end

	function extended.getDerivedStateFromProps()
		return nil
	end

	function extended.componentWillMount(_) end

	function extended.UNSAFE_componentWillReceiveProps(_) end

	function extended.componentWillUpdate(_) end

	function extended.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended))
			end)
		end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

AllLegacyLifecycles uses getDerivedStateFromProps() but also contains the following legacy lifecycles:
  componentWillMount
  UNSAFE_componentWillReceiveProps
  componentWillUpdate

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillReceiveProps in strict mode is not recommended" }, {
			withoutStack = 1
		})
	end).toWarnDev({ "componentWillMount has been renamed", "componentWillUpdate has been renamed" }, {
		withoutStack = true
	})
	local extended2 = v.Component:extend("WillMount")

	function extended2:init()
		self.state = {}
	end

	function extended2.getDerivedStateFromProps()
		return nil
	end

	function extended2.UNSAFE_componentWillMount(_) end

	function extended2.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended2))
		end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillMount uses getDerivedStateFromProps() but also contains the following legacy lifecycles:
  UNSAFE_componentWillMount

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillMount in strict mode is not recommended" }, {
			withoutStack = 1
		})
	end)
	local extended3 = v.Component:extend("WillMountAndUpdate")

	function extended3:init()
		self.state = {}
	end

	function extended3.getDerivedStateFromProps()
		return nil
	end

	function extended3.componentWillMount(_) end

	function extended3.UNSAFE_componentWillUpdate(_) end

	function extended3.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended3))
			end)
		end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillMountAndUpdate uses getDerivedStateFromProps() but also contains the following legacy lifecycles:
  componentWillMount
  UNSAFE_componentWillUpdate

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillUpdate in strict mode is not recommended" }, {
			withoutStack = 1
		})
	end).toWarnDev({ "componentWillMount has been renamed" }, {
		withoutStack = true
	})
	local extended4 = v.Component:extend("WillReceiveProps")

	function extended4:init()
		self.state = {}
	end

	function extended4.getDerivedStateFromProps()
		return nil
	end

	function extended4.componentWillReceiveProps(_) end

	function extended4.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended4))
			end)
		end).toErrorDev([[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillReceiveProps uses getDerivedStateFromProps() but also contains the following legacy lifecycles:
  componentWillReceiveProps

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]])
	end).toWarnDev({ "componentWillReceiveProps has been renamed" }, {
		withoutStack = true
	})
end)
it("should warn about deprecated lifecycles (cWM/cWRP/cWU) if new getSnapshotBeforeUpdate is present", function()
	local extended = v.Component:extend("AllLegacyLifecycles")

	function extended:init()
		self.state = {}
	end

	function extended.getSnapshotBeforeUpdate(_) end

	function extended.componentWillMount(_) end

	function extended.UNSAFE_componentWillReceiveProps(_) end

	function extended.componentWillUpdate(_) end

	function extended.componentDidUpdate(_) end

	function extended.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended))
			end)
		end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

AllLegacyLifecycles uses getSnapshotBeforeUpdate() but also contains the following legacy lifecycles:
  componentWillMount
  UNSAFE_componentWillReceiveProps
  componentWillUpdate

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillReceiveProps in strict mode is not recommended" }, {
			withoutStack = 1
		})
	end).toWarnDev({ "componentWillMount has been renamed", "componentWillUpdate has been renamed" }, {
		withoutStack = true
	})
	local extended2 = v.Component:extend("WillMount")

	function extended2:init()
		self.state = {}
	end

	function extended2.getSnapshotBeforeUpdate(_) end

	function extended2.UNSAFE_componentWillMount(_) end

	function extended2.componentDidUpdate(_) end

	function extended2.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended2))
		end)
	end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillMount uses getSnapshotBeforeUpdate() but also contains the following legacy lifecycles:
  UNSAFE_componentWillMount

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillMount in strict mode is not recommended" }, {
		withoutStack = 1
	})
	local extended3 = v.Component:extend("WillMountAndUpdate")

	function extended3:init()
		self.state = {}
	end

	function extended3.getSnapshotBeforeUpdate(_) end

	function extended3.componentWillMount(_) end

	function extended3.UNSAFE_componentWillUpdate(_) end

	function extended3.componentDidUpdate(_) end

	function extended3.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended3))
			end)
		end).toErrorDev({ [[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillMountAndUpdate uses getSnapshotBeforeUpdate() but also contains the following legacy lifecycles:
  componentWillMount
  UNSAFE_componentWillUpdate

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]], "UNSAFE_componentWillUpdate in strict mode is not recommended" }, {
			withoutStack = 1
		})
	end).toWarnDev({ "componentWillMount has been renamed" }, {
		withoutStack = true
	})
	local extended4 = v.Component:extend("WillReceiveProps")

	function extended4:init()
		self.state = {}
	end

	function extended4.getSnapshotBeforeUpdate(_) end

	function extended4.componentWillReceiveProps(_) end

	function extended4.componentDidUpdate(_) end

	function extended4.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended4))
			end)
		end).toErrorDev([[
Unsafe legacy lifecycles will not be called for components using new component APIs.

WillReceiveProps uses getSnapshotBeforeUpdate() but also contains the following legacy lifecycles:
  componentWillReceiveProps

The above lifecycles should be removed. Learn more about this warning here:
https://reactjs.org/link/unsafe-component-lifecycles]])
	end).toWarnDev({ "componentWillReceiveProps has been renamed" }, {
		withoutStack = true
	})
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
	end).toErrorDev("Warning: `MyComponent` uses `getDerivedStateFromProps` but its initial state has not been initialized. This is not recommended. Instead, define the initial state by passing an object to `self:setState` in the `init` method of `MyComponent`. This ensures that `getDerivedStateFromProps` arguments have a consistent shape.")
	v2.act(function()
		v2.render(v.createElement(extended))
	end)
end)
it("should invoke both deprecated and new lifecycles if both are present", function()
	local v9 = {}
	local extended = v.Component:extend("MyComponent")

	function extended.componentWillMount(_)
		table.insert(v9, "componentWillMount")
	end

	function extended.componentWillReceiveProps(_)
		table.insert(v9, "componentWillReceiveProps")
	end

	function extended.componentWillUpdate(_)
		table.insert(v9, "componentWillUpdate")
	end

	function extended.UNSAFE_componentWillMount(_)
		table.insert(v9, "UNSAFE_componentWillMount")
	end

	function extended.UNSAFE_componentWillReceiveProps(_)
		table.insert(v9, "UNSAFE_componentWillReceiveProps")
	end

	function extended.UNSAFE_componentWillUpdate(_)
		table.insert(v9, "UNSAFE_componentWillUpdate")
	end

	function extended.render(_)
		return nil
	end

	expect(function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					foo = "bar"
				}))
			end)
		end).toWarnDev({
			"componentWillMount has been renamed",
			"componentWillReceiveProps has been renamed",
			"componentWillUpdate has been renamed"
		}, {
			withoutStack = true
		})
	end).toErrorDev({
		"Using UNSAFE_componentWillMount in strict mode is not recommended",
		"Using UNSAFE_componentWillReceiveProps in strict mode is not recommended",
		"Using UNSAFE_componentWillUpdate in strict mode is not recommended"
	}, {
		withoutStack = true
	})
	expect(v9).toEqual({ "componentWillMount", "UNSAFE_componentWillMount" })
	v9 = {}
	v2.act(function()
		v2.render(v.createElement(extended, {
			foo = "baz"
		}))
	end)
	expect(v9).toEqual({
		"componentWillReceiveProps",
		"UNSAFE_componentWillReceiveProps",
		"componentWillUpdate",
		"UNSAFE_componentWillUpdate"
	})
end)
xit("should not override state with stale values if prevState is spread within getDerivedStateFromProps", function()
	local ref = v.createRef()
	local v9 = nil
	local v10 = nil
	local extended = v.Component:extend("Child")

	function extended:init()
		self.state = {
			local_ = 0
		}
	end

	function extended.getDerivedStateFromProps(p, p2)
		p2.remote = p.remote
		return p2
	end

	function extended:updateState()
		self:setState(function(p)
			return {
				local_ = p.local_ + 1
			}
		end)
		self.props.onChange(self, self.state.remote + 1)
	end

	function extended.render(p)
		v10 = "remote:" .. tostring(p.state.remote) .. ", local:" .. tostring(p.state.local_)
		v9 = p
		local element = v.createElement("div", {
			onClick = p.updateState,
			ref = ref
		}, v10)
		ref.current = element
		return element
	end

	local extended2 = v.Component:extend("Parent")

	function extended2:init()
		self.state = {
			value = 0
		}
	end

	function extended2.handleChange(object, p)
		object:setState({
			value = p
		})
	end

	function extended2.render(p)
		return v.createElement(extended, {
			remote = p.state.value,
			onChange = p.handleChange
		})
	end

	v2.act(function()
		v2.render(v.createElement(extended2))
	end)
	expect(v10).toBe("remote:0, local:0")
	v2.act(function()
		v9:updateState()
	end)
	expect(v10).toBe("remote:1, local:1")
	ref.current.click()
	expect(ref.current.textContent).toBe("remote:2, local:2")
end)
it("should pass the return value from getSnapshotBeforeUpdate to componentDidUpdate", function()
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

	function extended.componentDidUpdate(_, p, p2, p3)
		table.insert(
			v9,
			string.format("componentDidUpdate() prevProps:%s prevState:%s snapshot:%s", p.value, p2.value, p3)
		)
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
		"componentDidUpdate() prevProps:foo prevState:1 snapshot:abc"
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
		"componentDidUpdate() prevProps:bar prevState:2 snapshot:abc"
	})
	v9 = {}
	v2.act(function()
		v2.render(v.createElement("Frame"))
	end)
	expect(v9).toEqual({})
end)
it("should pass previous state to shouldComponentUpdate even with getDerivedStateFromProps", function()
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

	function extended.shouldComponentUpdate(p, _, p2)
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
it("warns about deprecated unsafe lifecycles", function()
	local extended = v.Component:extend("MyComponent")

	function extended.componentWillMount(_) end

	function extended.componentWillReceiveProps(_) end

	function extended.componentWillUpdate(_) end

	function extended.render(_)
		return nil
	end

	expect(function()
		v2.act(function()
			v2.render(v.createElement(extended, {
				x = 1
			}))
		end)
	end).toWarnDev({ [[
Warning: componentWillMount has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move code with side effects to componentDidMount, and set initial state in the constructor.
* Rename componentWillMount to UNSAFE_componentWillMount to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: MyComponent]], [[
Warning: componentWillReceiveProps has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* If you're updating state whenever props change, refactor your code to use memoization techniques or move it to static getDerivedStateFromProps. Learn more at: https://reactjs.org/link/derived-state
* Rename componentWillReceiveProps to UNSAFE_componentWillReceiveProps to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: MyComponent]], [[
Warning: componentWillUpdate has been renamed, and is not recommended for use. See https://reactjs.org/link/unsafe-component-lifecycles for details.

* Move data fetching code or side effects to componentDidUpdate.
* Rename componentWillUpdate to UNSAFE_componentWillUpdate to suppress this warning in non-strict mode. In React 18.x, only the UNSAFE_ name will work.

Please update the following components: MyComponent]] }, {
		withoutStack = true
	})
	v2.act(function()
		v2.render(v.createElement(extended, {
			x = 2
		}))
		v2.render(v.createElement(extended, {
			key = "new",
			x = 1
		}))
	end)
end)