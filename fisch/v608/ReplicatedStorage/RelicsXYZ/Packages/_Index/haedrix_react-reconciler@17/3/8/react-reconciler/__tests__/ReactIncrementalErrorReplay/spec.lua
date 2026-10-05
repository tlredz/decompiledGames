local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local it = JestGlobals.it
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
end)
it("should ignore error if it doesn't throw on retry", function()
	local v4 = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function badLazyInit()
		local v5 = not v4
		v4 = true

		if v5 then
			error("Hi")
		end
	end

	local extended = v.Component:extend("App")

	function extended.render(_)
		badLazyInit() -- equivalent call inferred; original call site unknown
		return v.createElement("TextLabel", {
			Text = "Hello"
		})
	end

	v2.render(v.createElement(extended))
	expect(v3).toFlushWithoutYielding()
end)