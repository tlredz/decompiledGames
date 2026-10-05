local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
JestGlobals.describe("ReactTopLevelText", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)
	it("should render a component returning strings directly from render", function()
		v2.render(v.createElement(function(p)
			return p.value
		end, {
			value = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput("foo")
	end)
	it("should render a component returning numbers directly from renderß", function()
		v2.render(v.createElement(function(p)
			return p.value
		end, {
			value = 10
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput("10")
	end)
end)