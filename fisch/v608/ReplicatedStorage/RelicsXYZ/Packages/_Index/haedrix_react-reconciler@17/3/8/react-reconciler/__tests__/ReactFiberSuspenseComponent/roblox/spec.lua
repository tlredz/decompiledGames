local parent = script.Parent.Parent
local parent2 = script.Parent.Parent.Parent
local JestGlobals = require(parent2.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local v = nil
describe("ReactFiberSuspenseComponent", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFiberSuspenseComponentnew = require(parent["ReactFiberSuspenseComponent.new"])
		v = ReactFiberSuspenseComponentnew
	end)
	describe("shouldCaptureSuspense", function()
		local shouldCaptureSuspense = nil
		local v2 = nil
		beforeEach(function()
			shouldCaptureSuspense = v.shouldCaptureSuspense
			v2 = {
				memoizedState = nil,
				memoizedProps = {}
			}
		end)
		local generateTest

		generateTest = function(p, p2)
			if p2 == nil then
				generateTest(p, true)
				generateTest(p, false)
			else
				it(
					string.format("is %s if it %s invisible parent", tostring(p), p2 and "does not have" or "has"),
					function()
						expect(shouldCaptureSuspense(v2, p2)).toBe(p)
					end
				)
			end
		end

		describe("with a memoizedState", function()
			beforeEach(function()
				v2.memoizedState = {
					dehydrated = nil
				}
			end)
			describe("memoizedState.dehydrated is not null", function()
				beforeEach(function()
					v2.memoizedState.dehydrated = {}
				end)
				generateTest(true, true)
				generateTest(true, false)
			end)
			describe("memoizedState.dehydrated is null", function()
				generateTest(false, true)
				generateTest(false, false)
			end)
		end)
		describe("with no memoizedState", function()
			describe("without fallback prop", function()
				generateTest(false, true)
				generateTest(false, false)
			end)
			describe("with fallback prop", function()
				beforeEach(function()
					v2.memoizedProps.fallback = {}
				end)
				describe("without flag unstable_avoidThisFallback", function()
					generateTest(true, true)
					generateTest(true, false)
				end)
				describe("with flag unstable_avoidThisFallback", function()
					beforeEach(function()
						v2.memoizedProps.unstable_avoidThisFallback = true
					end)
					local v4 = true
					local v5 = false
					it(string.format("is %s if it %s invisible parent", tostring(false), "does not have"), function()
						expect(shouldCaptureSuspense(v2, v4)).toBe(v5)
					end)
					local v7 = false
					local v8 = true
					it(string.format("is %s if it %s invisible parent", tostring(true), "has"), function()
						expect(shouldCaptureSuspense(v2, v7)).toBe(v8)
					end)
				end)
			end)
		end)
	end)
end)