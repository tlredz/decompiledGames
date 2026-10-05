local parent = script.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local folder = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local Shared = require(parent.Shared)
	Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	folder = Instance.new("Folder")
	v3 = v2.createRoot(folder)
	local Scheduler = require(parent.Scheduler)
	v4 = Scheduler
end)
it("should provide a useful error when initial prop assignment fails", function()
	v3:render(v.createElement("Frame", {}, {
		Root = v.createElement("TextLabel", {
			AbsentProp = 1
		})
	}))
	expect(function()
		expect(v4.unstable_flushAllWithoutAsserting).toErrorDev("Error applying initial props to Roblox Instance 'Root' (TextLabel)")
	end).toThrow()
end)
it("should provide a useful error when a props update fails", function()
	v3:render(v.createElement("Frame", {}, {
		Root = v.createElement("TextLabel", {
			Text = "Okay!"
		})
	}))
	v4.unstable_flushAllWithoutAsserting()
	v3:render(v.createElement("Frame", {}, {
		Root = v.createElement("TextLabel", {
			Text = "Not good",
			AbsentProp = 1
		})
	}))
	expect(function()
		expect(v4.unstable_flushAllWithoutAsserting).toErrorDev("Error updating props on Roblox Instance 'Root' (TextLabel):")
	end).toThrow()
end)
it("should provide a useful error when a binding update fails", function()
	local binding, v5 = v.createBinding(nil)
	v3:render(v.createElement("Frame", {}, {
		Root = v.createElement("TextLabel", {
			NextSelectionLeft = binding
		})
	}))
	v4.unstable_flushAllWithoutAsserting()
	expect(function()
		expect(function()
			v5("not an Instance")
		end).toErrorDev("Error updating binding or ref assigned to key NextSelectionLeft of 'Root' (TextLabel).", {
			withoutStack = true
		})
	end).toThrow()
end)