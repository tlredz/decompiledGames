local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local Shared = require(parent.Shared)
local reactFeatureFlags = Shared.ReactFeatureFlags
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest

local function textContent(legacyRoot)
	local slice = array.slice(legacyRoot.getChildren())
	local v4 = nil

	while #slice > 0 do
		local v5 = table.remove(slice)

		if v5 and v5.text then
			v4 = v5.text .. (v4 or "")
		end

		if not (v5 and v5.children) then
			continue
		end

		for _, v6 in v5.children do
			table.insert(slice, v6)
		end
	end

	return v4 or ""
end

describe("ReactErrorBoundaries", function()
	local v4 = nil
	local v5 = nil
	local v6 = nil
	local v7 = nil
	local v8 = nil
	local v9 = nil
	local v10 = nil
	local v11 = nil
	local v12 = nil
	local v13 = nil
	local v14 = nil
	local fn
	local fn2
	local v15 = nil
	local v16 = nil
	local v17 = nil
	local v18 = nil
	local v19 = nil
	beforeEach(function()
		jest.resetModules()
		jest.useFakeTimers()
		local Shared2 = require(parent.Shared)
		reactFeatureFlags = Shared2.ReactFeatureFlags
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = false
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
		v4 = v.Component:extend("BrokenConstructor")

		function v4.init(_)
			v3.unstable_yieldValue("BrokenConstructor constructor [!]")
			error("Hello", 0)
		end

		function v4.render(p)
			v3.unstable_yieldValue("BrokenConstructor render")
			return v.createElement("div", nil, p.props.children)
		end

		function v4.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenConstructor componentWillMount")
		end

		function v4.componentDidMount(_)
			v3.unstable_yieldValue("BrokenConstructor componentDidMount")
		end

		function v4.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenConstructor componentWillReceiveProps")
		end

		function v4.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenConstructor componentWillUpdate")
		end

		function v4.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenConstructor componentDidUpdate")
		end

		function v4.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenConstructor componentWillUnmount")
		end

		v5 = v.Component:extend("BrokenComponentWillMount")

		function v5.init(_)
			v3.unstable_yieldValue("BrokenComponentWillMount constructor")
		end

		function v5.render(p)
			v3.unstable_yieldValue("BrokenComponentWillMount render")
			return v.createElement("div", nil, p.props.children)
		end

		function v5.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentWillMount [!]")
			error("Hello", 0)
		end

		function v5.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentDidMount")
		end

		function v5.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentWillReceiveProps")
		end

		function v5.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentWillUpdate")
		end

		function v5.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentDidUpdate")
		end

		function v5.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentWillMount componentWillUnmount")
		end

		v6 = v.Component:extend("BrokenComponentDidMount")

		function v6.init(_)
			v3.unstable_yieldValue("BrokenComponentDidMount constructor")
		end

		function v6.render(p)
			v3.unstable_yieldValue("BrokenComponentDidMount render")
			return v.createElement("div", nil, p.props.children)
		end

		function v6.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentWillMount")
		end

		function v6.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentDidMount [!]")
			error("Hello", 0)
		end

		function v6.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentWillReceiveProps")
		end

		function v6.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentWillUpdate")
		end

		function v6.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentDidUpdate")
		end

		function v6.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentDidMount componentWillUnmount")
		end

		v7 = v.Component:extend("BrokenComponentWillReceiveProps")

		function v7.init(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps constructor")
		end

		function v7.render(p)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps render")
			return v.createElement("div", nil, p.props.children)
		end

		function v7.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentWillMount")
		end

		function v7.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentDidMount")
		end

		function v7.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentWillReceiveProps [!]")
			error("Hello", 0)
		end

		function v7.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentWillUpdate")
		end

		function v7.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentDidUpdate")
		end

		function v7.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentWillReceiveProps componentWillUnmount")
		end

		v8 = v.Component:extend("BrokenComponentWillUpdate")

		function v8.init(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate constructor")
		end

		function v8.render(p)
			v3.unstable_yieldValue("BrokenComponentWillUpdate render")
			return v.createElement("div", nil, p.props.children)
		end

		function v8.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentWillMount")
		end

		function v8.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentDidMount")
		end

		function v8.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentWillReceiveProps")
		end

		function v8.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentWillUpdate [!]")
			error("Hello", 0)
		end

		function v8.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentDidUpdate")
		end

		function v8.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentWillUpdate componentWillUnmount")
		end

		v9 = v.Component:extend("BrokenComponentDidUpdate")

		function v9.init(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate constructor")
		end

		function v9.render(p)
			v3.unstable_yieldValue("BrokenComponentDidUpdate render")
			return v.createElement("div", nil, p.props.children)
		end

		function v9.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentWillMount")
		end

		function v9.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentDidMount")
		end

		function v9.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentWillReceiveProps")
		end

		function v9.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentWillUpdate")
		end

		function v9.componentDidUpdate(p)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentDidUpdate [!]")
			error(p.props.errorText or "Hello", 0)
		end

		function v9.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentDidUpdate componentWillUnmount")
		end

		v10 = v.Component:extend("BrokenComponentWillUnmount")

		function v10.init(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount constructor")
		end

		function v10.render(p)
			v3.unstable_yieldValue("BrokenComponentWillUnmount render")
			return v.createElement("div", nil, p.props.children)
		end

		function v10.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentWillMount")
		end

		function v10.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentDidMount")
		end

		function v10.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentWillReceiveProps")
		end

		function v10.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentWillUpdate")
		end

		function v10.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentDidUpdate")
		end

		function v10.componentWillUnmount(p)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentWillUnmount [!]")
			error(p.props.errorText or "Hello", 0)
		end

		v12 = v.Component:extend("BrokenComponentWillMountErrorBoundary")

		function v12:init()
			self.state = {
				error = nil
			}
			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary constructor")
		end

		function v12.render(p)
			if p.state.error then
				v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary render error")
				return v.createElement("div", nil, "Caught an error: " .. tostring(p.state.error.message))
			end

			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary render success")
			return v.createElement("div", nil, p.props.children)
		end

		function v12.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary componentWillMount [!]")
			error("Hello", 0)
		end

		function v12.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary componentDidMount")
		end

		function v12.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary componentWillUnmount")
		end

		function v12.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("BrokenComponentWillMountErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		v13 = v.Component:extend("BrokenComponentDidMountErrorBoundary")

		function v13:init()
			self.state = {
				error = nil
			}
			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary constructor")
		end

		function v13.render(p)
			if p.state.error then
				v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary render error")
				return v.createElement("div", nil, "Caught an error: " .. tostring(p.state.error.message))
			end

			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary render success")
			return v.createElement("div", nil, p.props.children)
		end

		function v13.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary componentWillMount")
		end

		function v13.componentDidMount(_)
			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary componentDidMount [!]")
			error("Hello", 0)
		end

		function v13.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary componentWillUnmount")
		end

		function v13.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("BrokenComponentDidMountErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		v11 = v.Component:extend("BrokenRenderErrorBoundary")

		function v11:init()
			self.state = {
				error = nil
			}
			v3.unstable_yieldValue("BrokenRenderErrorBoundary constructor")
		end

		function v11.render(p)
			if p.state.error then
				v3.unstable_yieldValue("BrokenRenderErrorBoundary render error [!]")
				error("Hello", 0)
			end

			v3.unstable_yieldValue("BrokenRenderErrorBoundary render success")
			return v.createElement("div", nil, p.props.children)
		end

		function v11.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenRenderErrorBoundary componentWillMount")
		end

		function v11.componentDidMount(_)
			v3.unstable_yieldValue("BrokenRenderErrorBoundary componentDidMount")
		end

		function v11.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenRenderErrorBoundary componentWillUnmount")
		end

		function v11.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("BrokenRenderErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		v14 = v.Component:extend("BrokenRender")

		function v14.init(_)
			v3.unstable_yieldValue("BrokenRender constructor")
		end

		function v14.render(_)
			v3.unstable_yieldValue("BrokenRender render [!]")
			error("Hello", 0)
		end

		function v14.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("BrokenRender componentWillMount")
		end

		function v14.componentDidMount(_)
			v3.unstable_yieldValue("BrokenRender componentDidMount")
		end

		function v14.UNSAFE_componentWillReceiveProps(_)
			v3.unstable_yieldValue("BrokenRender componentWillReceiveProps")
		end

		function v14.UNSAFE_componentWillUpdate(_)
			v3.unstable_yieldValue("BrokenRender componentWillUpdate")
		end

		function v14.componentDidUpdate(_)
			v3.unstable_yieldValue("BrokenRender componentDidUpdate")
		end

		function v14.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenRender componentWillUnmount")
		end

		fn = function(p)
			local children = p.children
			v3.unstable_yieldValue("BrokenUseEffect render")
			v.useEffect(function()
				v3.unstable_yieldValue("BrokenUseEffect useEffect [!]")
				error("Hello", 0)
			end)
			return children
		end

		fn2 = function(p)
			local children = p.children
			v3.unstable_yieldValue("BrokenUseLayoutEffect render")
			v.useLayoutEffect(function()
				v3.unstable_yieldValue("BrokenUseLayoutEffect useLayoutEffect [!]")
				error("Hello", 0)
			end)
			return children
		end

		v17 = v.Component:extend("NoopErrorBoundary")

		function v17.init(_)
			v3.unstable_yieldValue("NoopErrorBoundary constructor")
		end

		function v17.render(_)
			v3.unstable_yieldValue("NoopErrorBoundary render")
			return v.createElement(v14)
		end

		function v17.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("NoopErrorBoundary componentWillMount")
		end

		function v17.componentDidMount(_)
			v3.unstable_yieldValue("NoopErrorBoundary componentDidMount")
		end

		function v17.componentWillUnmount(_)
			v3.unstable_yieldValue("NoopErrorBoundary componentWillUnmount")
		end

		function v17.getDerivedStateFromError()
			v3.unstable_yieldValue("NoopErrorBoundary static getDerivedStateFromError")
			return nil
		end

		v19 = v.Component:extend("Normal")
		v19.defaultProps = {
			logName = "Normal"
		}

		function v19.init(p)
			v3.unstable_yieldValue(p.props.logName .. " constructor")
		end

		function v19.render(p)
			v3.unstable_yieldValue(p.props.logName .. " render")
			return v.createElement("div", nil, p.props.children)
		end

		function v19.UNSAFE_componentWillMount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillMount")
		end

		function v19.componentDidMount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentDidMount")
		end

		function v19.UNSAFE_componentWillReceiveProps(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillReceiveProps")
		end

		function v19.UNSAFE_componentWillUpdate(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillUpdate")
		end

		function v19.componentDidUpdate(p)
			v3.unstable_yieldValue(p.props.logName .. " componentDidUpdate")
		end

		function v19.componentWillUnmount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillUnmount")
		end

		v15 = v.Component:extend("ErrorBoundary")

		function v15:init()
			self.state = {
				error = nil
			}
			v3.unstable_yieldValue(self.props.logName .. " constructor")
		end

		function v15.render(p)
			if p.state.error and not p.props.forceRetry then
				v3.unstable_yieldValue(p.props.logName .. " render error")
				return p.props.renderError(p.state.error, p.props)
			end

			v3.unstable_yieldValue(p.props.logName .. " render success")
			return v.createElement("div", nil, p.props.children)
		end

		function v15.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("ErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		function v15.UNSAFE_componentWillMount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillMount")
		end

		function v15.componentDidMount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentDidMount")
		end

		function v15.UNSAFE_componentWillReceiveProps(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillReceiveProps")
		end

		function v15.UNSAFE_componentWillUpdate(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillUpdate")
		end

		function v15.componentDidUpdate(p)
			v3.unstable_yieldValue(p.props.logName .. " componentDidUpdate")
		end

		function v15.componentWillUnmount(p)
			v3.unstable_yieldValue(p.props.logName .. " componentWillUnmount")
		end

		v15.defaultProps = {
			logName = "ErrorBoundary",
			renderError = function(message, p)
				if typeof(message) == "table" then
					message = message.message
				end

				return v.createElement("div", {
					ref = p.errorMessageRef
				}, "Caught an error: ", message, ".")
			end
		}
		v18 = v.Component:extend("RetryErrorBoundary")

		function v18.init(_)
			v3.unstable_yieldValue("RetryErrorBoundary constructor")
		end

		function v18.render(_)
			v3.unstable_yieldValue("RetryErrorBoundary render")
			return v.createElement(v14)
		end

		function v18.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("RetryErrorBoundary componentWillMount")
		end

		function v18.componentDidMount(_)
			v3.unstable_yieldValue("RetryErrorBoundary componentDidMount")
		end

		function v18.componentWillUnmount(_)
			v3.unstable_yieldValue("RetryErrorBoundary componentWillUnmount")
		end

		function v18.getDerivedStateFromError(_)
			v3.unstable_yieldValue("RetryErrorBoundary static getDerivedStateFromError [!]")
			return {}
		end

		v16 = v.Component:extend("ErrorMessage")

		function v16.init(_)
			v3.unstable_yieldValue("ErrorMessage constructor")
		end

		function v16.UNSAFE_componentWillMount(_)
			v3.unstable_yieldValue("ErrorMessage componentWillMount")
		end

		function v16.componentDidMount(_)
			v3.unstable_yieldValue("ErrorMessage componentDidMount")
		end

		function v16.componentWillUnmount(_)
			v3.unstable_yieldValue("ErrorMessage componentWillUnmount")
		end

		function v16.render(p)
			v3.unstable_yieldValue("ErrorMessage render")
			return v.createElement("div", nil, "Caught an error: " .. tostring(p.props.message))
		end
	end)
	it("does not swallow exceptions on mounting without boundaries", function()
		expect(function()
			v2.act(function()
				v2.render(v.createElement(v14))
			end)
		end).toThrow("Hello")
		expect(function()
			v2.act(function()
				v2.render(v.createElement(v5))
			end)
		end).toThrow("Hello")
		expect(function()
			v2.act(function()
				v2.render(v.createElement(v6))
			end)
		end).toThrow("Hello")
	end)
	it("does not swallow exceptions on updating without boundaries", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v8))
		expect(function()
			legacyRoot.render(v.createElement(v8))
		end).toThrow("Hello")
		legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v7))
		expect(function()
			legacyRoot.render(v.createElement(v7))
		end).toThrow("Hello")
		legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v9))
		expect(function()
			legacyRoot.render(v.createElement(v9))
		end).toThrow("Hello")
	end)
	it("does not swallow exceptions on unmounting without boundaries", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v10))
		expect(function()
			legacyRoot.render(nil)
		end).toThrow("Hello")
	end)
	it("prevents errors from leaking into other roots", function()
		local legacyRoot = v2.createLegacyRoot()
		local legacyRoot2 = v2.createLegacyRoot()
		local legacyRoot3 = v2.createLegacyRoot()
		legacyRoot.render(v.createElement("span", nil, "Before 1"))
		expect(function()
			legacyRoot2.render(v.createElement(v14))
		end).toThrow("Hello")
		legacyRoot3.render(v.createElement(v15, nil, v.createElement(v14)))
		expect(legacyRoot.getChildren()[1].text).toEqual("Before 1")
		expect(legacyRoot2.getChildren()[1]).toEqual(nil)
		expect((textContent(legacyRoot3))).toEqual("Caught an error: Hello.")
		legacyRoot.render(v.createElement("span", nil, "After 1"), legacyRoot)
		legacyRoot2.render(v.createElement("span", nil, "After 2"), legacyRoot2)
		legacyRoot3.render(v.createElement(v15, {
			forceRetry = true
		}, "After 3"), legacyRoot3)
		expect(legacyRoot.getChildren()[1].text).toEqual("After 1")
		expect(legacyRoot2.getChildren()[1].text).toEqual("After 2")
		expect(legacyRoot3.getChildren()[1].text).toEqual("After 3")
		legacyRoot.render(nil)
		legacyRoot2.render(nil)
		legacyRoot3.render(nil)
		expect(legacyRoot.getChildren()[1]).toEqual(nil)
		expect(legacyRoot2.getChildren()[1]).toEqual(nil)
		expect(legacyRoot3.getChildren()[1]).toEqual(nil)
	end)
	it("logs a single error when using error boundary", function()
		local legacyRoot = v2.createLegacyRoot()
		expect(function()
			return legacyRoot.render(v.createElement(v15, nil, v.createElement(v14)))
		end).toErrorDev("The above error occurred in the <BrokenRender> component:", {
			logAllErrors = true
		})
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("renders an error state if child throws in render", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("renders an error state if child throws in constructor", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v4)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenConstructor constructor [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("renders an error state if child throws in componentWillMount", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v5)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenComponentWillMount constructor",
			"BrokenComponentWillMount componentWillMount [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("renders an error state if context provider throws in componentWillMount", function()
		local legacyRoot = v2.createLegacyRoot()
		local extended = v.Component:extend("BrokenComponentWillMountWithContext")

		function extended.getChildContext(_)
			return {
				foo = 42
			}
		end

		function extended.render(p)
			return v.createElement("div", nil, p.props.children)
		end

		function extended.UNSAFE_componentWillMount(_)
			error("Hello", 0)
		end

		extended.childContextTypes = {
			foo = 0
		}
		legacyRoot.render(v.createElement(v15, nil, v.createElement(extended)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
	end)

	if not reactFeatureFlags.disableModulePatternComponents then
		it("renders an error state if module-style context provider throws in componentWillMount", function()
			local legacyRoot = v2.createLegacyRoot()

			local function BrokenComponentWillMountWithContext()
				return {
					getChildContext = function()
						return {
							foo = 42
						}
					end,
					render = function(p)
						return v.createElement("div", nil, p.props.children)
					end,
					UNSAFE_componentWillMount = function()
						error("Hello")
					end
				}
			end

			expect(function()
				return legacyRoot.render(v.createElement(v15, nil, v.createElement(BrokenComponentWillMountWithContext)))
			end).toErrorDev("Warning: The <BrokenComponentWillMountWithContext /> component appears to be a function component that returns a class instance. Change BrokenComponentWillMountWithContext to a class that extends React.Component instead. ")
		end)
	end

	it("mounts the error message if mounting fails", function()
		local function renderError(message)
			if typeof(message) == "table" then
				message = message.message
			end

			return v.createElement(v16, {
				message = message
			})
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			renderError = renderError
		}, v.createElement(v14)))
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorMessage constructor",
			"ErrorMessage componentWillMount",
			"ErrorMessage render",
			"ErrorMessage componentDidMount",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount", "ErrorMessage componentWillUnmount" })
	end)
	it("propagates errors on retry on mounting", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v18, nil, v.createElement(v14))))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"RetryErrorBoundary constructor",
			"RetryErrorBoundary componentWillMount",
			"RetryErrorBoundary render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"RetryErrorBoundary static getDerivedStateFromError [!]",
			"RetryErrorBoundary componentWillMount",
			"RetryErrorBoundary render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("propagates errors inside boundary during componentWillMount", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v12)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenComponentWillMountErrorBoundary constructor",
			"BrokenComponentWillMountErrorBoundary componentWillMount [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("propagates errors inside boundary while rendering error state", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v11, nil, v.createElement(v14))))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRenderErrorBoundary constructor",
			"BrokenRenderErrorBoundary componentWillMount",
			"BrokenRenderErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"BrokenRenderErrorBoundary static getDerivedStateFromError",
			"BrokenRenderErrorBoundary componentWillMount",
			"BrokenRenderErrorBoundary render error [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("does not call componentWillUnmount when aborting initial mount", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v14), v.createElement(v19)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"Normal constructor",
			"Normal componentWillMount",
			"Normal render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"Normal constructor",
			"Normal componentWillMount",
			"Normal render",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("resets callback refs if mounting aborts", function()
		local function childRef(p)
			v3.unstable_yieldValue("Child ref is set to " .. (p and "[object HTMLDivElement]" or "nil"))
		end

		local function errorMessageRef(p)
			v3.unstable_yieldValue("Error message ref is set to " .. (p and "[object HTMLDivElement]" or "nil"))
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			errorMessageRef = errorMessageRef
		}, v.createElement("div", {
			ref = childRef
		}), v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"Error message ref is set to [object HTMLDivElement]",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount", "Error message ref is set to nil" })
	end)
	it("resets object refs if mounting aborts", function()
		local ref = v.createRef()
		local ref2 = v.createRef()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			errorMessageRef = ref2
		}, v.createElement("div", {
			ref = ref
		}), v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidMount"
		})
		expect(string.find(tostring(ref2.current), "table: ") ~= nil).toEqual(true)
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
		expect(ref2.current).toEqual(nil)
	end)
	it("successfully mounts if no error occurs", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement("div", nil, { "Mounted successfully." })))
		expect((textContent(legacyRoot))).toEqual("Mounted successfully.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches if child throws in constructor during update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v19, {
			logName = "Normal2"
		}), v.createElement(v4)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"Normal2 constructor",
			"Normal2 componentWillMount",
			"Normal2 render",
			"BrokenConstructor constructor [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches if child throws in componentWillMount during update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v19, {
			logName = "Normal2"
		}), v.createElement(v5)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"Normal2 constructor",
			"Normal2 componentWillMount",
			"Normal2 render",
			"BrokenComponentWillMount constructor",
			"BrokenComponentWillMount componentWillMount [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches if child throws in componentWillReceiveProps during update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v7)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v7)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"BrokenComponentWillReceiveProps componentWillReceiveProps [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"BrokenComponentWillReceiveProps componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches if child throws in componentWillUpdate during update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v8)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v8)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"BrokenComponentWillUpdate componentWillReceiveProps",
			"BrokenComponentWillUpdate componentWillUpdate [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"BrokenComponentWillUpdate componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches if child throws in render during update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v19, {
			logName = "Normal2"
		}), v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"Normal2 constructor",
			"Normal2 componentWillMount",
			"Normal2 render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("keeps refs up-to-date during updates", function()
		local function child1Ref(p)
			v3.unstable_yieldValue("Child1 ref is set to " .. (p and "[object HTMLDivElement]" or "nil"))
		end

		local function child2Ref(p)
			v3.unstable_yieldValue("Child2 ref is set to " .. (p and "[object HTMLDivElement]" or "nil"))
		end

		local function errorMessageRef(p)
			v3.unstable_yieldValue("Error message ref is set to " .. (p and "[object HTMLDivElement]" or "nil"))
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			errorMessageRef = errorMessageRef
		}, v.createElement("div", {
			ref = child1Ref
		})))
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"Child1 ref is set to [object HTMLDivElement]",
			"ErrorBoundary componentDidMount"
		})
		legacyRoot.render(v.createElement(v15, {
			errorMessageRef = errorMessageRef
		}, v.createElement("div", {
			ref = child1Ref
		}), v.createElement("div", {
			ref = child2Ref
		}), v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Child1 ref is set to nil",
			"Error message ref is set to [object HTMLDivElement]",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount", "Error message ref is set to nil" })
	end)
	it("recovers from componentWillUnmount errors on update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v10), v.createElement(v10), v.createElement(v19)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v10, {
			key = 1
		})))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"BrokenComponentWillUnmount componentWillReceiveProps",
			"BrokenComponentWillUnmount componentWillUpdate",
			"BrokenComponentWillUnmount render",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"Normal componentWillUnmount",
			"BrokenComponentWillUnmount componentDidUpdate",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("recovers from nested componentWillUnmount errors on update", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(
			v15,
			nil,
			v.createElement(v19, nil, v.createElement(v10)),
			v.createElement(v10)
		))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19, {
			key = 1
		}, v.createElement(v10))))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal componentWillReceiveProps",
			"Normal componentWillUpdate",
			"Normal render",
			"BrokenComponentWillUnmount componentWillReceiveProps",
			"BrokenComponentWillUnmount componentWillUpdate",
			"BrokenComponentWillUnmount render",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"BrokenComponentWillUnmount componentDidUpdate",
			"Normal componentDidUpdate",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"Normal componentWillUnmount",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("picks the right boundary when handling unmounting errors", function()
		local function renderInnerError(p)
			return v.createElement("div", nil, "Caught an inner error: ", p.message, ".")
		end

		local function renderOuterError(p)
			return v.createElement("div", nil, "Caught an outer error: ", p.message, ".")
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			logName = "OuterErrorBoundary",
			renderError = renderOuterError
		}, v.createElement(v15, {
			logName = "InnerErrorBoundary",
			renderError = renderInnerError
		}, v.createElement(v10))))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, {
			logName = "OuterErrorBoundary",
			renderError = renderOuterError
		}, v.createElement(v15, {
			logName = "InnerErrorBoundary",
			renderError = renderInnerError
		})))
		expect((textContent(legacyRoot))).toEqual("Caught an inner error: Hello.")
		expect(v3).toHaveYielded({
			"OuterErrorBoundary componentWillReceiveProps",
			"OuterErrorBoundary componentWillUpdate",
			"OuterErrorBoundary render success",
			"InnerErrorBoundary componentWillReceiveProps",
			"InnerErrorBoundary componentWillUpdate",
			"InnerErrorBoundary render success",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"InnerErrorBoundary componentDidUpdate",
			"OuterErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"InnerErrorBoundary componentWillUpdate",
			"InnerErrorBoundary render error",
			"InnerErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({
			"OuterErrorBoundary componentWillUnmount",
			"InnerErrorBoundary componentWillUnmount"
		})
	end)
	it("can recover from error state", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v14)))
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, {
			forceRetry = true
		}, v.createElement(v19)))
		expect((textContent(legacyRoot))).never.toContain("Caught an error")
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"Normal constructor",
			"Normal componentWillMount",
			"Normal render",
			"Normal componentDidMount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount", "Normal componentWillUnmount" })
	end)
	it("can update multiple times in error state", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v14)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		legacyRoot.render(nil)
		legacyRoot.render(v.createElement("div", nil, "Other screen"))
		expect((textContent(legacyRoot))).toEqual("Other screen")
		legacyRoot.render(nil)
	end)
	it("doesn't get into inconsistent state during removals", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v10), v.createElement(v19)))
		legacyRoot.render(v.createElement(v15))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		v3.unstable_clearYields()
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("doesn't get into inconsistent state during additions", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15))
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v19), v.createElement(v14), v.createElement(v19)))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		v3.unstable_clearYields()
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("doesn't get into inconsistent state during reorders", function()
		local flag = false
		local extended = v.Component:extend("MaybeBrokenRender")

		function extended.render(p)
			if flag then
				error("Hello", 0)
			end

			return v.createElement("div", nil, p.props.children)
		end

		local function getAMixOfNormalAndBrokenRenderElements()
			local children = {}

			for i = 1, 1000 do
				table.insert(children, v.createElement(v19, {
					key = i
				}))
			end

			table.insert(children, v.createElement(extended, {
				key = 101
			}))
			local count = #children

			while count ~= 1 do
				local v20 = math.floor(math.random() * count) + 1
				count -= 1
				local v21 = children[count]
				children[count] = children[v20]
				children[v20] = v21
			end

			return children
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, (getAMixOfNormalAndBrokenRenderElements())))
		expect((textContent(legacyRoot))).never.toContain("Caught an error")
		flag = true
		legacyRoot.render(v.createElement(v15, nil, (getAMixOfNormalAndBrokenRenderElements())))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		v3.unstable_clearYields()
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches errors originating downstream", function()
		local flag = false
		local extended = v.Component:extend("Stateful")

		function extended:init()
			self.state = {
				shouldThrow = false
			}
		end

		function extended.render(p)
			if flag then
				v3.unstable_yieldValue("Stateful render [!]")
				error("Hello", 0)
			end

			return v.createElement("div", nil, p.props.children)
		end

		local v20 = nil
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(extended, {
			ref = function(p)
				v20 = p
			end
		})))
		v3.unstable_clearYields()
		expect(function()
			flag = true
			v20:forceUpdate()
		end).never.toThrow()
		expect(v3).toHaveYielded({
			"Stateful render [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches errors in componentDidMount", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(
			v15,
			nil,
			v.createElement(v10, nil, v.createElement(v19)),
			v.createElement(v6),
			v.createElement(v19, {
				logName = "LastChild"
			})
		))
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenComponentWillUnmount constructor",
			"BrokenComponentWillUnmount componentWillMount",
			"BrokenComponentWillUnmount render",
			"Normal constructor",
			"Normal componentWillMount",
			"Normal render",
			"BrokenComponentDidMount constructor",
			"BrokenComponentDidMount componentWillMount",
			"BrokenComponentDidMount render",
			"LastChild constructor",
			"LastChild componentWillMount",
			"LastChild render",
			"Normal componentDidMount",
			"BrokenComponentWillUnmount componentDidMount",
			"BrokenComponentDidMount componentDidMount [!]",
			"LastChild componentDidMount",
			"ErrorBoundary componentDidMount",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"Normal componentWillUnmount",
			"BrokenComponentDidMount componentWillUnmount",
			"LastChild componentWillUnmount",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("catches errors in componentDidUpdate", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v9)))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v9)))
		expect(v3).toHaveYielded({
			"ErrorBoundary componentWillReceiveProps",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render success",
			"BrokenComponentDidUpdate componentWillReceiveProps",
			"BrokenComponentDidUpdate componentWillUpdate",
			"BrokenComponentDidUpdate render",
			"BrokenComponentDidUpdate componentDidUpdate [!]",
			"ErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"BrokenComponentDidUpdate componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	xit("catches errors in useEffect", function()
		local legacyRoot = v2.createLegacyRoot()
		v2.act(function()
			legacyRoot.render(v.createElement(v15, nil, v.createElement(fn, nil, "Initial value")))
			expect(v3).toHaveYielded({
				"ErrorBoundary constructor",
				"ErrorBoundary componentWillMount",
				"ErrorBoundary render success",
				"BrokenUseEffect render",
				"ErrorBoundary componentDidMount"
			})
			expect((textContent(legacyRoot))).toEqual("Initial value")
			v3.unstable_clearYields()
		end)
		expect(v3).toHaveYielded({
			"BrokenUseEffect useEffect [!]",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
	end)
	it("catches errors in useLayoutEffect", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(fn2, nil, "Initial value")))
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenUseLayoutEffect render",
			"BrokenUseLayoutEffect useLayoutEffect [!]",
			"ErrorBoundary componentDidMount",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"ErrorBoundary componentDidUpdate"
		})
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
	end)
	it("propagates errors inside boundary during componentDidMount", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement(v13, {
			renderError = function(p)
				return v.createElement("div", nil, "We should never catch our own error: ", p.message, ".")
			end
		})))
		expect((textContent(legacyRoot))).toEqual("Caught an error: Hello.")
		expect(v3).toHaveYielded({
			"ErrorBoundary constructor",
			"ErrorBoundary componentWillMount",
			"ErrorBoundary render success",
			"BrokenComponentDidMountErrorBoundary constructor",
			"BrokenComponentDidMountErrorBoundary componentWillMount",
			"BrokenComponentDidMountErrorBoundary render success",
			"BrokenComponentDidMountErrorBoundary componentDidMount [!]",
			"ErrorBoundary componentDidMount",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary componentWillUpdate",
			"ErrorBoundary render error",
			"BrokenComponentDidMountErrorBoundary componentWillUnmount",
			"ErrorBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({ "ErrorBoundary componentWillUnmount" })
	end)
	it("calls static getDerivedStateFromError for each error that is captured", function()
		local function renderUnmountError(p)
			return v.createElement("div", nil, "Caught an unmounting error: ", p.message, ".")
		end

		local function renderUpdateError(p)
			return v.createElement("div", nil, "Caught an updating error: ", p.message, ".")
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, {
			logName = "OuterErrorBoundary"
		}, v.createElement(v15, {
			logName = "InnerUnmountBoundary",
			renderError = renderUnmountError
		}, v.createElement(v10, {
			errorText = "E1"
		}), v.createElement(v10, {
			errorText = "E2"
		})), v.createElement(v15, {
			logName = "InnerUpdateBoundary",
			renderError = renderUpdateError
		}, v.createElement(v9, {
			errorText = "E3"
		}), v.createElement(v9, {
			errorText = "E4"
		}))))
		v3.unstable_clearYields()
		legacyRoot.render(v.createElement(v15, {
			logName = "OuterErrorBoundary"
		}, v.createElement(v15, {
			logName = "InnerUnmountBoundary",
			renderError = renderUnmountError
		}), v.createElement(v15, {
			logName = "InnerUpdateBoundary",
			renderError = renderUpdateError
		}, v.createElement(v9, {
			errorText = "E3"
		}), v.createElement(v9, {
			errorText = "E4"
		}))))
		expect((textContent(legacyRoot))).toEqual("Caught an unmounting error: E2.Caught an updating error: E4.")
		expect(v3).toHaveYielded({
			"OuterErrorBoundary componentWillReceiveProps",
			"OuterErrorBoundary componentWillUpdate",
			"OuterErrorBoundary render success",
			"InnerUnmountBoundary componentWillReceiveProps",
			"InnerUnmountBoundary componentWillUpdate",
			"InnerUnmountBoundary render success",
			"InnerUpdateBoundary componentWillReceiveProps",
			"InnerUpdateBoundary componentWillUpdate",
			"InnerUpdateBoundary render success",
			"BrokenComponentDidUpdate componentWillReceiveProps",
			"BrokenComponentDidUpdate componentWillUpdate",
			"BrokenComponentDidUpdate render",
			"BrokenComponentDidUpdate componentWillReceiveProps",
			"BrokenComponentDidUpdate componentWillUpdate",
			"BrokenComponentDidUpdate render",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"BrokenComponentWillUnmount componentWillUnmount [!]",
			"InnerUnmountBoundary componentDidUpdate",
			"BrokenComponentDidUpdate componentDidUpdate [!]",
			"BrokenComponentDidUpdate componentDidUpdate [!]",
			"InnerUpdateBoundary componentDidUpdate",
			"OuterErrorBoundary componentDidUpdate",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary static getDerivedStateFromError",
			"InnerUnmountBoundary componentWillUpdate",
			"InnerUnmountBoundary render error",
			"ErrorBoundary static getDerivedStateFromError",
			"ErrorBoundary static getDerivedStateFromError",
			"InnerUpdateBoundary componentWillUpdate",
			"InnerUpdateBoundary render error",
			"BrokenComponentDidUpdate componentWillUnmount",
			"BrokenComponentDidUpdate componentWillUnmount",
			"InnerUnmountBoundary componentDidUpdate",
			"InnerUpdateBoundary componentDidUpdate"
		})
		legacyRoot.render(nil)
		expect(v3).toHaveYielded({
			"OuterErrorBoundary componentWillUnmount",
			"InnerUnmountBoundary componentWillUnmount",
			"InnerUpdateBoundary componentWillUnmount"
		})
	end)
	it("discards a bad root if the root component fails", function()
		local v20 = nil
		local legacyRoot = v2.createLegacyRoot()
		local success, result = pcall(function()
			expect(function()
				return legacyRoot.render(v.createElement(nil))
			end).toErrorDev("React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: nil.")
		end)

		if success then
			result = nil
		end

		local success2, result2 = pcall(function()
			expect(function()
				return legacyRoot.render(v.createElement(nil))
			end).toErrorDev("React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: nil.")
		end)

		if not success2 then
			v20 = result2
		end

		expect(result.message).toMatch("but got: nil")
		expect(v20.message).toMatch("but got: nil")
	end)
	it("renders empty output if error boundary does not handle the error", function()
		local legacyRoot = v2.createLegacyRoot()
		expect(function()
			return legacyRoot.render(v.createElement(
				"div",
				nil,
				"Sibling",
				v.createElement(v17, nil, v.createElement(v14))
			))
		end).toThrow("Hello")
		expect((textContent(legacyRoot))).toEqual("")
		expect(v3).toHaveYielded({
			"NoopErrorBoundary constructor",
			"NoopErrorBoundary componentWillMount",
			"NoopErrorBoundary render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]",
			"NoopErrorBoundary static getDerivedStateFromError",
			"NoopErrorBoundary render",
			"BrokenRender constructor",
			"BrokenRender componentWillMount",
			"BrokenRender render [!]"
		})
	end)
	it("passes first error when two errors happen in commit", function()
		local v20 = {}
		local extended = v.Component:extend("Child")

		function extended.render(_)
			return v.createElement("div")
		end

		function extended.componentDidMount(_)
			table.insert(v20, "child sad")
			error("child sad")
		end

		local extended2 = v.Component:extend("Parent")

		function extended2.render(_)
			return v.createElement(extended)
		end

		function extended2.componentDidMount(_)
			table.insert(v20, "parent sad")
			error("parent sad")
		end

		local legacyRoot = v2.createLegacyRoot()
		local success, result = pcall(legacyRoot.render, v.createElement(extended2))

		if success then
			result = nil
		elseif result.message ~= "parent sad" and result.message ~= "child sad" then
			error(result)
		end

		expect(v20).toEqual({ "child sad", "parent sad" })
		expect(result.message).toBe("child sad")
	end)
	it("propagates uncaught error inside unbatched initial mount", function()
		local function Foo()
			error("foo error", 0)
		end

		local legacyRoot = v2.createLegacyRoot()
		expect(function()
			v2.batchedUpdates(function()
				legacyRoot.render(v.createElement(Foo))
			end)
		end).toThrow("foo error")
	end)
	it("handles errors that occur in before-mutation commit hook", function()
		local v20 = {}
		local extended = v.Component:extend("Child")

		function extended.getSnapshotBeforeUpdate(_)
			table.insert(v20, "child sad")
			error("child sad")
		end

		function extended.componentDidUpdate(_) end

		function extended.render(_)
			return v.createElement("div")
		end

		local extended2 = v.Component:extend("Parent")

		function extended2.getSnapshotBeforeUpdate(_)
			table.insert(v20, "parent sad")
			error("parent sad")
		end

		function extended2.componentDidUpdate(_) end

		function extended2.render(p)
			return v.createElement(extended, p.props)
		end

		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(extended2, {
			value = 1
		}))
		local success, result = pcall(legacyRoot.render, v.createElement(extended2, {
			value = 2
		}))

		if success then
			result = nil
		elseif string.sub(result.message, -10) ~= "parent sad" and string.sub(result.message, -9) ~= "child sad" then
			error(result)
		end

		expect(v20).toEqual({ "child sad", "parent sad" })
		expect(result.message).toBe("child sad")
	end)
	it("should warn if an error boundary with only componentDidCatch does not update state", function()
		local extended = v.Component:extend("InvalidErrorBoundary")

		function extended.componentDidCatch(_, _, _) end

		function extended.render(p)
			return p.props.children
		end

		local function Throws()
			error("expected")
		end

		local legacyRoot = v2.createLegacyRoot()
		expect(function()
			legacyRoot.render(v.createElement(extended, nil, v.createElement(Throws)))
		end).toErrorDev("InvalidErrorBoundary: Error boundaries should implement getDerivedStateFromError(). In that method, return a state update to display an error message or fallback UI.")
		expect((textContent(legacyRoot))).toEqual("")
	end)
	it("should call both componentDidCatch and getDerivedStateFromError if both exist on a component", function()
		local legacyRoot = v2.createLegacyRoot()
		local v20 = nil
		local v21 = nil
		local extended = v.Component:extend("ErrorBoundaryWithBothMethods")

		function extended:init()
			self.state = {}
		end

		function extended.getDerivedStateFromError(error2)
			v21 = error2
			return {
				error = error2
			}
		end

		function extended.componentDidCatch(_, p, _)
			v20 = p
		end

		function extended.render(p)
			if p.state.error then
				return "ErrorBoundary"
			end

			return p.props.children
		end

		local expected = LuauPolyfill.Error.new("expected")
		legacyRoot.render(v.createElement(extended, nil, v.createElement(function()
			error(expected, 0)
		end)))
		expect((textContent(legacyRoot))).toEqual("ErrorBoundary")
		expect(v20).toEqual(expected)
		expect(v21).toEqual(expected)
	end)
	xit("should catch errors from invariants in completion phase", function()
		local legacyRoot = v2.createLegacyRoot()
		legacyRoot.render(v.createElement(v15, nil, v.createElement("input", nil, v.createElement("div"))))
		expect((textContent(legacyRoot))).toContain("Caught an error: input is a void element tag")
	end)
	it("should catch errors from errors in the throw phase from boundaries", function()
		local legacyRoot = v2.createLegacyRoot()
		local extended = v.Component:extend("EvilErrorBoundary")

		function extended.componentDidCatch(_)
			error("gotta catch em all", 0)
		end

		function extended.render(p)
			return p.props.children
		end

		legacyRoot.render(v.createElement(v15, nil, v.createElement(extended, nil, v.createElement(function()
			error("original error", 0)
		end))))
		expect((textContent(legacyRoot))).toContain("Caught an error: gotta catch em all.")
	end)
	local v20

	if ReactGlobals.__DEV__ then
		v20 = it.skip
	else
		v20 = it
	end

	v20("should protect errors from errors in the stack generation", function()
		local legacyRoot = v2.createLegacyRoot()
		local object = setmetatable({
			message = "gotta catch em all"
		}, {
			__index = function(p, p2)
				if p2 ~= "stack" then
					return p
				end

				error("gotta catch em all")
			end
		})
		local extended = v.Component:extend("Throws")

		function extended.render(_)
			error(object)
		end

		extended = setmetatable(extended, {
			__index = function(_, p)
				if p ~= "displayName" then
					return extended
				end

				error("gotta catch em all", 0)
			end
		})

		local function Wrapper()
			return v.createElement(extended)
		end

		legacyRoot.render(v.createElement(v15, nil, v.createElement(Wrapper)))
		expect((textContent(legacyRoot))).toContain("Caught an error: gotta catch em all.")
	end)
	it("catches errors thrown in componentWillUnmount", function()
		local legacyRoot = v2.createLegacyRoot()
		local extended = v.Component:extend("Component")

		function extended.render(p)
			local id = p.props.id
			v3.unstable_yieldValue("Component render " .. id)
			return id
		end

		local extended2 = v.Component:extend("LocalErrorBoundary")

		function extended2:init()
			self.state = {}
		end

		function extended2.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("ErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		function extended2.render(p)
			local children = p.props.children
			local id = p.props.id
			local fallbackID = p.props.fallbackID

			if p.state.error then
				v3.unstable_yieldValue(string.format("%s render error", id))
				return v.createElement(extended, {
					id = fallbackID
				})
			end

			v3.unstable_yieldValue(string.format("%s render success", id))
			return children or nil
		end

		local extended3 = v.Component:extend("LocalBrokenComponentWillUnmount")

		function extended3.componentWillUnmount(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount componentWillUnmount")
			error("Expected")
		end

		function extended3.render(_)
			v3.unstable_yieldValue("BrokenComponentWillUnmount render")
			return "broken"
		end

		legacyRoot.render(v.createElement(extended2, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, v.createElement(extended, {
			id = "sibling"
		}), v.createElement(extended2, {
			id = "InnerBoundary",
			fallbackID = "InnerFallback"
		}, v.createElement(extended3))))
		expect(legacyRoot.getChildren()[1].text).toEqual("sibling")
		expect(legacyRoot.getChildren()[2].text).toEqual("broken")
		expect(v3).toHaveYielded({
			"OuterBoundary render success",
			"Component render sibling",
			"InnerBoundary render success",
			"BrokenComponentWillUnmount render"
		})
		legacyRoot.render(v.createElement(extended2, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, v.createElement(extended, {
			id = "sibling"
		})))
		expect((textContent(legacyRoot))).toEqual("OuterFallback")
		expect((textContent(legacyRoot))).toEqual("OuterFallback")
		expect(v3).toHaveYielded({
			"OuterBoundary render success",
			"Component render sibling",
			"BrokenComponentWillUnmount componentWillUnmount",
			"ErrorBoundary static getDerivedStateFromError",
			"OuterBoundary render error",
			"Component render OuterFallback"
		})
	end)
	it("catches errors thrown while detaching refs", function()
		local legacyRoot = v2.createLegacyRoot()
		local extended = v.Component:extend("Component")

		function extended.render(p)
			local id = p.props.id
			v3.unstable_yieldValue("Component render " .. id)
			return id
		end

		local extended2 = v.Component:extend("LocalErrorBoundary")

		function extended2:init()
			self.state = {}
		end

		function extended2.getDerivedStateFromError(error2)
			v3.unstable_yieldValue("ErrorBoundary static getDerivedStateFromError")
			return {
				error = error2
			}
		end

		function extended2.render(p)
			local children = p.props.children
			local id = p.props.id
			local fallbackID = p.props.fallbackID

			if p.state.error then
				v3.unstable_yieldValue(string.format("%s render error", id))
				return v.createElement(extended, {
					id = fallbackID
				})
			end

			v3.unstable_yieldValue(string.format("%s render success", id))
			return children or nil
		end

		local extended3 = v.Component:extend("LocalBrokenCallbackRef")

		function extended3._ref(p)
			v3.unstable_yieldValue("LocalBrokenCallbackRef ref " .. tostring(p and true or false))

			if p == nil then
				error("Expected")
			end
		end

		function extended3:render()
			v3.unstable_yieldValue("LocalBrokenCallbackRef render")
			return v.createElement("div", {
				ref = self._ref
			}, "ref")
		end

		legacyRoot.render(v.createElement(extended2, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, v.createElement(extended, {
			id = "sibling"
		}), v.createElement(extended2, {
			id = "InnerBoundary",
			fallbackID = "InnerFallback"
		}, v.createElement(extended3))))
		expect(legacyRoot.getChildren()[1].text).toEqual("sibling")
		expect(legacyRoot.getChildren()[2].text).toEqual("ref")
		expect(v3).toHaveYielded({
			"OuterBoundary render success",
			"Component render sibling",
			"InnerBoundary render success",
			"LocalBrokenCallbackRef render",
			"LocalBrokenCallbackRef ref true"
		})
		legacyRoot.render(v.createElement(extended2, {
			id = "OuterBoundary",
			fallbackID = "OuterFallback"
		}, v.createElement(extended, {
			id = "sibling"
		})))
		local children = legacyRoot.getChildren()
		expect(children[1].text).toEqual("OuterFallback")
		expect(children[#children].text).toEqual("OuterFallback")
		expect(v3).toHaveYielded({
			"OuterBoundary render success",
			"Component render sibling",
			"LocalBrokenCallbackRef ref false",
			"ErrorBoundary static getDerivedStateFromError",
			"OuterBoundary render error",
			"Component render OuterFallback"
		})
	end)
end)