local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
end)

local function Text(p)
	v3.unstable_yieldValue(p.text)
	return v.createElement("span", {
		prop = p.text
	})
end

it("regression: setState callback (2nd arg) should only fire once, even after a rebase", function()
	local v4 = nil
	local extended = v.Component:extend("App")

	function extended.init(object)
		object:setState({
			step = 0
		})
	end

	function extended.render(p)
		v4 = p
		return v.createElement(Text, {
			text = p.state.step
		})
	end

	local root = v2.createRoot()
	v2.act(function()
		root.render(v.createElement(extended))
	end)
	expect(v3).toHaveYielded({ 0 })
	v2.act(function()
		v4:setState({
			step = 1
		}, function()
			return v3.unstable_yieldValue("Callback 1")
		end)
		v2.flushSync(function()
			v4:setState({
				step = 2
			}, function()
				return v3.unstable_yieldValue("Callback 2")
			end)
		end)
	end)
	expect(v3).toHaveYielded({
		2,
		"Callback 2",
		2,
		"Callback 1"
	})
end)