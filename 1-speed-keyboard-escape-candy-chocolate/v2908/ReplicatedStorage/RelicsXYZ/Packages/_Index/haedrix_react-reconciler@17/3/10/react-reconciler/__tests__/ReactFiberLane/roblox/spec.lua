local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local ReactFiberSchedulerPrioritiesroblox = require(script.Parent.Parent["ReactFiberSchedulerPriorities.roblox"])
local immediatePriority = ReactFiberSchedulerPrioritiesroblox.ImmediatePriority
local normalPriority = ReactFiberSchedulerPrioritiesroblox.NormalPriority
local noPriority = ReactFiberSchedulerPrioritiesroblox.NoPriority
local userBlockingPriority = ReactFiberSchedulerPrioritiesroblox.UserBlockingPriority
local v = nil
beforeEach(function()
	jest.resetModules()
	local ReactFiberLane = require(script.Parent.Parent.ReactFiberLane)
	v = ReactFiberLane
end)
describe("lanePriorityToSchedulerPriority", function()
	for k, v2 in {
		SyncLanePriority = immediatePriority,
		SyncBatchedLanePriority = immediatePriority,
		InputDiscreteLanePriority = userBlockingPriority,
		InputContinuousLanePriority = userBlockingPriority,
		DefaultLanePriority = normalPriority,
		TransitionPriority = normalPriority,
		NoLanePriority = noPriority
	} do
		local v3 = k
		local v4 = v2
		it(string.format("returns the expected priority (%d) for lane %s", v2, k), function()
			local v5 = v[v3]
			expect(v5).toBeDefined()
			expect(v.lanePriorityToSchedulerPriority(v5)).toBe(v4)
		end)
	end

	it("throws when giving an invalid lane priority", function()
		expect(function()
			v.lanePriorityToSchedulerPriority(999)
		end).toThrow(string.format("Invalid update priority: %s. This is a bug in React", (tostring(999))))
	end)
end)
describe("getHighestPriorityPendingLanes", function()
	it("returns the Sync lane and sets the sync lane priority", function()
		local v2 = {
			pendingLanes = v.SyncLane
		}
		expect((v.getHighestPriorityPendingLanes(v2))).toBe(v.SyncLane)
		expect((v.returnNextLanesPriority())).toBe(v.SyncLanePriority)
	end)
end)
describe("getNextLanes", function()
	describe("given no pending lanes", function()
		local v2 = nil
		beforeEach(function()
			v2 = {
				pendingLanes = v.NoLanes
			}
		end)
		it("returns no lanes", function()
			expect(v.getNextLanes(v2, v.NoLanes)).toBe(v.NoLanes)
		end)
		it("sets the highest lane priority to no lane", function()
			v.getNextLanes(v2, v.NoLanes)
			expect(v.returnNextLanesPriority()).toBe(v.NoLanePriority)
		end)
	end)
	describe("given expired lanes", function()
		local v2 = nil
		beforeEach(function()
			v2 = {
				pendingLanes = v.SyncLane,
				expiredLanes = v.SyncLane,
				suspendedLanes = v.NoLanes,
				pingedLanes = v.NoLanes,
				entangledLanes = v.NoLanes
			}
		end)
		describe("no entangled lanes", function()
			describe("pending lanes with higher priority than expired lanes", function()
				beforeEach(function()
					v2 = object.assign(v2, {
						pendingLanes = v.mergeLanes(v.SomeRetryLane, v.DefaultHydrationLane),
						expiredLanes = v.DefaultLanes
					})
				end)
				it("returns the lanes above or equal to the priority of the expired lanes", function()
					expect((v.getNextLanes(v2, v.NoLanes))).toBe(v.DefaultHydrationLane)
				end)
				it("sets the highest lane priority to sync lane", function()
					v.getNextLanes(v2, v.NoLanes)
					expect(v.returnNextLanesPriority()).toBe(v.SyncLanePriority)
				end)
			end)
			describe("pending lanes with lower priority than expired lanes", function()
				beforeEach(function()
					v2 = object.assign(v2, {
						pendingLanes = v.SyncBatchedLane,
						expiredLanes = v.SyncLane
					})
				end)
				it("returns no lanes", function()
					expect((v.getNextLanes(v2, v.NoLanes))).toBe(v.NoLanes)
				end)
				it("sets the highest lane priority to sync lane", function()
					v.getNextLanes(v2, v.NoLanes)
					expect(v.returnNextLanesPriority()).toBe(v.SyncLanePriority)
				end)
			end)
		end)
		it("sets the highest lane priority to sync lane", function()
			expect((v.getNextLanes(v2, v.NoLanes))).toBe(v.SyncLane)
			expect(v.returnNextLanesPriority()).toBe(v.SyncLanePriority)
		end)
		it("sets the highest lane priority to sync lane 2", function()
			v2 = object.assign(v2, {
				expiredLanes = v.SyncBatchedLane
			})
			expect((v.getNextLanes(v2, v.NoLanes))).toBe(v.SyncLane)
			expect(v.returnNextLanesPriority()).toBe(v.SyncLanePriority)
		end)
	end)
end)
describe("includesNonIdleWork", function()
	for _, v2 in {
		"SyncLane",
		"SyncBatchedLane",
		"InputDiscreteHydrationLane",
		"DefaultHydrationLane",
		"SomeRetryLane",
		"SelectiveHydrationLane"
	} do
		local v3 = v2
		it(string.format("is true for %s", v2), function()
			local v4 = v[v3]
			expect(v4).toBeDefined()
			expect(v.includesNonIdleWork(v4)).toBe(true)
		end)
	end

	for _, v2 in { "NoLane", "OffscreenLane", "IdleHydrationLane" } do
		local v3 = v2
		it(string.format("is false for %s", v2), function()
			local v4 = v[v3]
			expect(v4).toBeDefined()
			expect(v.includesNonIdleWork(v4)).toBe(false)
		end)
	end
end)
describe("includesOnlyRetries", function()
	it("is true for a retry lane", function()
		expect(v.includesOnlyRetries(v.SomeRetryLane)).toBe(true)
	end)
	it("is false for the sync lane", function()
		expect(v.includesOnlyRetries(v.SyncLane)).toBe(false)
	end)
	it("is false for a retry lane merged with another lane", function()
		local mergeLanes = v.mergeLanes(v.SyncLane, v.SomeRetryLane)
		expect(v.includesOnlyRetries(mergeLanes)).toBe(false)
	end)
end)
describe("includesSomeLane", function()
	it("is true given the same lane", function()
		local syncLane = v.SyncLane
		expect(v.includesSomeLane(syncLane, syncLane)).toBe(true)
	end)
	it("is true given lanes that includes the other", function()
		local syncLane = v.SyncLane
		local mergeLanes = v.mergeLanes(syncLane, v.DefaultHydrationLane)
		expect(v.includesSomeLane(mergeLanes, syncLane)).toBe(true)
	end)
	it("is false for two seperate lanes", function()
		expect(v.includesSomeLane(v.SyncLane, v.DefaultHydrationLane)).toBe(false)
	end)
end)
describe("isSubsetOfLanes", function()
	it("is true given the same lane", function()
		local syncLane = v.SyncLane
		expect(v.isSubsetOfLanes(syncLane, syncLane)).toBe(true)
	end)
	it("is true given lanes that includes the other", function()
		local mergeLanes = v.mergeLanes(v.SyncLane, v.DefaultHydrationLane)
		local mergeLanes2 = v.mergeLanes(mergeLanes, v.SyncBatchedLane)
		expect(v.includesSomeLane(mergeLanes2, mergeLanes)).toBe(true)
	end)
	it("is false for two seperate lanes", function()
		expect(v.includesSomeLane(v.SyncLane, v.DefaultHydrationLane)).toBe(false)
	end)
end)
describe("mergeLanes", function()
	it("returns a lane that includes both inputs", function()
		local syncLane = v.SyncLane
		local defaultHydrationLane = v.DefaultHydrationLane
		local mergeLanes = v.mergeLanes(syncLane, defaultHydrationLane)
		expect(v.includesSomeLane(mergeLanes, syncLane)).toBe(true)
		expect(v.includesSomeLane(mergeLanes, defaultHydrationLane)).toBe(true)
	end)
	it("returns the same lane given two identical lanes", function()
		local syncLane = v.SyncLane
		expect(v.mergeLanes(syncLane, syncLane)).toBe(syncLane)
	end)
end)
describe("removeLanes", function()
	it("returns the lanes without the given lane", function()
		local syncLane = v.SyncLane
		local defaultHydrationLane = v.DefaultHydrationLane
		local mergeLanes = v.mergeLanes(syncLane, defaultHydrationLane)
		expect(v.removeLanes(mergeLanes, syncLane)).toBe(defaultHydrationLane)
		expect(v.removeLanes(mergeLanes, defaultHydrationLane)).toBe(syncLane)
	end)
	it("returns the same lane when removing a lane not included", function()
		local mergeLanes = v.mergeLanes(v.SyncLane, v.DefaultHydrationLane)
		expect(v.removeLanes(mergeLanes, v.SyncBatchedLane)).toBe(mergeLanes)
	end)
end)
describe("higherPriorityLane", function()
	it("returns the other lane if one is NoLane", function()
		local syncLane = v.SyncLane
		expect(v.higherPriorityLane(v.NoLane, syncLane)).toBe(syncLane)
		expect(v.higherPriorityLane(syncLane, v.NoLane)).toBe(syncLane)
	end)
	it("returns the higher priority lane", function()
		local syncLane = v.SyncLane
		local offscreenLane = v.OffscreenLane
		expect(v.higherPriorityLane(syncLane, offscreenLane)).toBe(syncLane)
		expect(v.higherPriorityLane(offscreenLane, syncLane)).toBe(syncLane)
	end)
end)
describe("higherLanePriority", function()
	it("returns the other priority if one is NoLanePriority", function()
		local defaultLanePriority = v.DefaultLanePriority
		expect(v.higherLanePriority(v.NoLanePriority, defaultLanePriority)).toBe(defaultLanePriority)
		expect(v.higherLanePriority(defaultLanePriority, v.NoLanePriority)).toBe(defaultLanePriority)
	end)
	it("returns the higher lane priority", function()
		local syncLanePriority = v.SyncLanePriority
		local transitionPriority = v.TransitionPriority
		expect(v.higherLanePriority(syncLanePriority, transitionPriority)).toBe(syncLanePriority)
		expect(v.higherLanePriority(transitionPriority, syncLanePriority)).toBe(syncLanePriority)
	end)
end)