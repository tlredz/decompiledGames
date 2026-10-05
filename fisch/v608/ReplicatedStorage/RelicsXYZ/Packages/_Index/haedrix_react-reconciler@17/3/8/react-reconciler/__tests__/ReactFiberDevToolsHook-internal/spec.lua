local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeAll = JestGlobals.beforeAll
local afterAll = JestGlobals.afterAll
local it = JestGlobals.it
local LuauPolyfill = require(parent.LuauPolyfill)
local map = LuauPolyfill.Map
local v = nil
local v2 = nil
beforeEach(function()
	jest.resetModules()
	local ReactFiberDevToolsHooknew = require(script.Parent.Parent["ReactFiberDevToolsHook.new"])
	v = ReactFiberDevToolsHooknew
	local ReactDevtoolsShared = require(parent.Dev.ReactDevtoolsShared)
	v2 = ReactDevtoolsShared
end)
describe("DevTools hook detection", function()
	local __REACT_DEVTOOLS_GLOBAL_HOOK__ = nil
	beforeAll(function()
		__REACT_DEVTOOLS_GLOBAL_HOOK__ = ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__
	end)
	afterAll(function()
		ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ = __REACT_DEVTOOLS_GLOBAL_HOOK__
	end)
	local v3

	if ReactGlobals.__DEV__ then
		v3 = it
	else
		v3 = it.skip
	end

	v3("should log an error when fibers aren't supported", function()
		ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ = {
			isDisabled = false,
			supportsHooks = false
		}
		expect(function()
			expect((v.injectInternals({}))).toBe(true)
		end).toErrorDev("The installed version of React DevTools is too old", {
			withoutStack = true
		})
	end)
	it("attaches renderers", function()
		local renderer = {
			findFiberByHostInstance = function() end
		}
		local renderer2 = {
			findFiberByHostInstance = function() end
		}
		local v6 = {
			renderers = map.new({
				{ 123, renderer },
				{ 456, renderer2 }
			}),
			rendererInterfaces = map.new(),
			emit = jest.fn(),
			sub = jest.fn()
		}
		local v7 = {
			addListener = jest.fn()
		}
		ReactGlobals.__REACT_DEVTOOLS_GLOBAL_HOOK__ = v6
		v2.backend.initBackend(v6, v7, {})
		expect(v6.emit).toHaveBeenCalledTimes(3)
		expect(v6.emit).toHaveBeenNthCalledWith(1, "renderer-attached", {
			id = 123,
			renderer = renderer,
			rendererInterface = expect.anything()
		})
		expect(v6.emit).toHaveBeenNthCalledWith(2, "renderer-attached", {
			id = 456,
			renderer = renderer2,
			rendererInterface = expect.anything()
		})
		expect(v6.emit).toHaveBeenNthCalledWith(3, "react-devtools", v7)
	end)
end)