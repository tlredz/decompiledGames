local v = nil
local reactFeatureFlags = nil
local v2 = nil
local v3 = nil
local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local it = JestGlobals.it
local xit = JestGlobals.xit
describe("ReactDeprecationWarnings", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
		reactFeatureFlags.warnAboutDefaultPropsOnFunctionComponents = true
		reactFeatureFlags.warnAboutStringRefs = true
	end)
	afterEach(function()
		reactFeatureFlags.warnAboutDefaultPropsOnFunctionComponents = false
		reactFeatureFlags.warnAboutStringRefs = false
	end)
	xit("should warn when given defaultProps", function()
		local function FunctionalComponent(_)
			return nil
		end

		v2.render(v.createElement(FunctionalComponent))
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toErrorDev("Warning: FunctionalComponent: Support for defaultProps will be removed from function components in a future major release. Use JavaScript default parameters instead.")
	end)
	it("should warn when given string refs", function()
		local extended = v.Component:extend("RefComponent")

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Component")

		function extended2.render(_)
			return v.createElement(extended, {
				ref = "refComponent"
			})
		end

		v2.render(v.createElement(extended2))
		local v4 = ReactGlobals.__DEV__ and "Component" or "<enable __DEV__ mode for component names>"
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toThrow("Component \"" .. v4 .. "\" contains the string ref \"refComponent\". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref")
	end)
	xit("should not warn when owner and self are the same for string refs", function()
		reactFeatureFlags.warnAboutStringRefs = false
		local extended = v.Component:extend("RefComponent")

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("")

		function extended2.render(p)
			return v.createElement(extended, {
				ref = "refComponent",
				__self = p
			})
		end

		v2.renderLegacySyncRoot(v.createElement(extended2))
		expect(v3).toFlushWithoutYielding()
	end)
	it("should warn when owner and self are different for string refs", function()
		local extended = v.Component:extend("RefComponent")

		function extended.render(_)
			return nil
		end

		local extended2 = v.Component:extend("Component")

		function extended2.render(_)
			return v.createElement(extended, {
				ref = "refComponent",
				__self = {}
			})
		end

		v2.render(v.createElement(extended2))
		local v4 = ReactGlobals.__DEV__ and "Component" or "<enable __DEV__ mode for component names>"
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toThrow("Component \"" .. v4 .. "\" contains the string ref \"refComponent\". Support for string refs has been removed. We recommend using useRef() or createRef() instead. Learn more about using refs safely here: https://reactjs.org/link/strict-mode-string-ref")
	end)
end)