local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local v = nil
local reactFeatureFlags = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
describe("ReactComponentYielding", function()
	local function NoYieldingComponent()
		return v.createElement("div")
	end

	local function YieldingComponent()
		task.wait()
		return v.createElement("div")
	end

	local function NoYieldingHook()
		v.useEffect(function() end, {})
		return v.createElement("div")
	end

	local function YieldingHook()
		v.useEffect(function()
			task.wait()
		end, {})
		return v.createElement("div")
	end

	if ReactGlobals.__DEV__ then
		describe("when yield catching enabled", function()
			beforeEach(function()
				jest.resetModules()
				local Shared = require(parent.Shared)
				reactFeatureFlags = Shared.ReactFeatureFlags
				reactFeatureFlags.catchYieldingInDEV = true
				local React = require(parent.React)
				v = React
				local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
				v2 = ReactNoopRenderer
				local Scheduler = require(parent.Scheduler)
				v3 = Scheduler
			end)
			it("throws if a component yields", function()
				v2.render(v.createElement(YieldingComponent))
				expect(function()
					expect(v3).toFlushAndYield({})
				end).toThrow("Yielding is not allowed inside components or hooks.")
			end)
			it("does not throw if a component does not yield", function()
				v2.render(v.createElement(NoYieldingComponent))
				expect(function()
					expect(v3).toFlushAndYield({})
				end).never.toThrow()
			end)
			it("throws if a hook yields", function()
				v2.render(v.createElement(YieldingHook))
				expect(function()
					expect(v3).toFlushAndYield({})
				end).toThrow("Yielding is not allowed inside components or hooks.")
			end)
			it("does not throw if a hook does not yield", function()
				v2.render(v.createElement(NoYieldingHook))
				expect(function()
					expect(v3).toFlushAndYield({})
				end).never.toThrow()
			end)
		end)
	end

	describe("when yield catching disabled", function()
		beforeEach(function()
			jest.resetModules()
			local Shared = require(parent.Shared)
			reactFeatureFlags = Shared.ReactFeatureFlags
			reactFeatureFlags.catchYieldingInDEV = false
			local React = require(parent.React)
			v = React
			local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
			v2 = ReactNoopRenderer
			local Scheduler = require(parent.Scheduler)
			v3 = Scheduler
		end)
		it("does not throw if a component yields", function()
			v2.render(v.createElement(YieldingComponent))
			expect(function()
				expect(v3).toFlushAndYield({})
			end).never.toThrow()
		end)
		it("does not throw if a component does not yield", function()
			v2.render(v.createElement(NoYieldingComponent))
			expect(function()
				expect(v3).toFlushAndYield({})
			end).never.toThrow()
		end)
		it("does not throw if a hook yields", function()
			v2.render(v.createElement(YieldingHook))
			expect(function()
				expect(v3).toFlushAndYield({})
			end).never.toThrow()
		end)
		it("does not throw if a hook does not yield", function()
			v2.render(v.createElement(NoYieldingHook))
			expect(function()
				expect(v3).toFlushAndYield({})
			end).never.toThrow()
		end)
	end)
end)