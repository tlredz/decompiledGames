local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local Promise = require(parent.Promise)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
end)
it("can use act to flush effects", function()
	local function App(p)
		v.useEffect(p.callback)
		return nil
	end

	local v4 = {}
	v2.act(function()
		v2.render(v.createElement(App, {
			callback = function()
				table.insert(v4, #v4)
			end
		}))
	end)
	expect(v3).toFlushWithoutYielding()
	expect(v4).toEqual({ 0 })
end)
it("should work with async/await", function()
	local function App()
		local state, setState = v.useState(0)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function someAsyncFunction()
			v3.unstable_yieldValue("stage 1")
			v3.unstable_yieldValue("stage 2")
			setState(1)
		end

		v.useEffect(function()
			someAsyncFunction() -- equivalent call inferred; original call site unknown
		end, {})
		return state
	end

	Promise.try(function()
		v2.act(function()
			v2.render(v.createElement(App))
		end)
	end):await()
	expect(v3).toHaveYielded({ "stage 1", "stage 2" })
	expect(v3).toFlushWithoutYielding()
	expect(v2.getChildren()).toEqual({
		{
			text = "1",
			hidden = false
		}
	})
end)