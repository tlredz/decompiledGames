local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local LuauPolyfill2 = require(parent.LuauPolyfill)
local object = LuauPolyfill2.Object
local v = nil
local reactFeatureFlags = nil
local v2 = nil
local v3 = nil
beforeEach(function()
	jest.resetModules()
	local Shared = require(parent.Shared)
	reactFeatureFlags = Shared.ReactFeatureFlags
	reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = false
	local parentModule = require(script.Parent.Parent)
	v = parentModule
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Dev.Scheduler)
	v3 = Scheduler
end)
it("should work without a ref to be forwarded", function()
	local extended = v.Component:extend("Child")

	function extended.render(p)
		v3.unstable_yieldValue(p.props.value)
		return nil
	end

	local function Wrapper(p)
		return v.createElement(extended, object.assign({}, p, {
			ref = p.forwardedRef
		}))
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		return v.createElement(Wrapper, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)
	v2.render(v.createElement(forwardRef, {
		value = 123
	}))
	expect(v3).toFlushAndYield({ 123 })
end)
it("should forward a ref for a single child", function()
	local extended = v.Component:extend("Child")

	function extended.render(p)
		v3.unstable_yieldValue(p.props.value)
		return nil
	end

	local function Wrapper(p)
		return v.createElement(extended, object.assign({}, p, {
			ref = p.forwardedRef
		}))
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		return v.createElement(Wrapper, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)
	local ref = v.createRef()
	v2.render(v.createElement(forwardRef, {
		ref = ref,
		value = 123
	}))
	expect(v3).toFlushAndYield({ 123 })
	expect(getmetatable(ref.current).__index).toBe(extended)
end)
it("should forward a ref for multiple children", function()
	local extended = v.Component:extend("Child")

	function extended.render(p)
		v3.unstable_yieldValue(p.props.value)
		return nil
	end

	local function Wrapper(p)
		return v.createElement(extended, object.assign({}, p, {
			ref = p.forwardedRef
		}))
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		return v.createElement(Wrapper, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)
	local ref = v.createRef()
	v2.render(v.createElement("div", {}, v.createElement("div"), v.createElement(forwardRef, {
		ref = ref,
		value = 123
	}), v.createElement("div")))
	expect(v3).toFlushAndYield({ 123 })
	expect(getmetatable(ref.current).__index).toBe(extended)
end)
it("should maintain child instance and ref through updates", function()
	local extended = v.Component:extend("Child")

	function extended.render(p)
		v3.unstable_yieldValue(p.props.value)
		return nil
	end

	local function Wrapper(p)
		return v.createElement(extended, object.assign({}, p, {
			ref = p.forwardedRef
		}))
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		return v.createElement(Wrapper, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)
	local count = 0
	local v4 = nil

	local function fn(p)
		count += 1
		v4 = p
	end

	v2.render(v.createElement(forwardRef, {
		ref = fn,
		value = 123
	}))
	expect(v3).toFlushAndYield({ 123 })
	expect(getmetatable(v4).__index).toBe(extended)
	expect(count).toBe(1)
	v2.render(v.createElement(forwardRef, {
		ref = fn,
		value = 456
	}))
	expect(v3).toFlushAndYield({ 456 })
	expect(getmetatable(v4).__index).toBe(extended)
	expect(count).toBe(1)
end)
it("should not break lifecycle error handling", function()
	local extended = v.Component:extend("ErrorBoundary")

	function extended:init()
		self.state = {
			error = nil
		}
	end

	function extended.componentDidCatch(object2, error3)
		v3.unstable_yieldValue("ErrorBoundary.componentDidCatch")
		object2:setState({
			error = error3
		})
	end

	function extended.render(p)
		if p.state.error then
			v3.unstable_yieldValue("ErrorBoundary.render: catch")
			return nil
		end

		v3.unstable_yieldValue("ErrorBoundary.render: try")
		return p.props.children
	end

	local extended2 = v.Component:extend("BadRender")

	function extended2.render(_)
		v3.unstable_yieldValue("BadRender throw")
		error(error2.new("oops!"))
	end

	local function Wrapper(p)
		local forwardedRef = p.forwardedRef
		v3.unstable_yieldValue("Wrapper")
		return v.createElement(extended2, object.assign({}, p, {
			ref = forwardedRef
		}))
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		return v.createElement(Wrapper, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)
	local ref = v.createRef()
	v2.render(v.createElement(extended, nil, v.createElement(forwardRef, {
		ref = ref
	})))
	expect(v3).toFlushAndYield({
		"ErrorBoundary.render: try",
		"Wrapper",
		"BadRender throw",
		"ErrorBoundary.render: try",
		"Wrapper",
		"BadRender throw",
		"ErrorBoundary.componentDidCatch",
		"ErrorBoundary.render: catch"
	})
	expect(ref.current).toBe(nil)
end)
it("should not re-run the render callback on a deep setState", function()
	local v4 = nil
	local extended = v.Component:extend("Inner")

	function extended.render(p)
		v3.unstable_yieldValue("Inner")
		v4 = p
		return v.createElement("div", {
			ref = p.props.forwardedRef
		})
	end

	local function Middle(p)
		v3.unstable_yieldValue("Middle")
		return v.createElement(extended, p)
	end

	local forwardRef = v.forwardRef(function(p, forwardedRef)
		v3.unstable_yieldValue("Forward")
		return v.createElement(Middle, object.assign({}, p, {
			forwardedRef = forwardedRef
		}))
	end)

	local function App()
		v3.unstable_yieldValue("App")
		return v.createElement(forwardRef)
	end

	v2.render(v.createElement(App))
	expect(v3).toFlushAndYield({
		"App",
		"Forward",
		"Middle",
		"Inner"
	})
	v4:setState({})
	expect(v3).toFlushAndYield({ "Inner" })
end)