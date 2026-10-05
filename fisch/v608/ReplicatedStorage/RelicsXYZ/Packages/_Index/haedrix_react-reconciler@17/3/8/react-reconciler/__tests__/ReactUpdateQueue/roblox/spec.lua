local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local v6 = nil
local v7 = nil
local noLane = nil
local v8 = nil
local v9 = nil
local v10 = {
	userName = "Dan"
}
local payload = {
	myVariable = 90210
}
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactUpdateQueuenew = require(script.Parent.Parent["ReactUpdateQueue.new"])
	v2 = ReactUpdateQueuenew
	local ReactFibernew = require(script.Parent.Parent["ReactFiber.new"])
	v3 = ReactFibernew
	local ReactFiberLane = require(script.Parent.Parent.ReactFiberLane)
	v4 = ReactFiberLane
	v6 = v.Component:extend("fundamental")
	v5 = v3.createFiberFromFundamental(v6)
	noLane = v4.NoLane
	v7 = v2.createUpdate(0, noLane)
	v8 = false
	v7.payload = payload

	function v7.callback()
		v8 = true
	end

	v7.lane = noLane
end)
describe("new ReactUpdateQueue", function()
	it("does not have force update", function()
		expect(v2.checkHasForceUpdateAfterProcessing()).toEqual(false)
	end)
	it("enqueue before initialize is a no-op", function()
		v9 = v3.createWorkInProgress(v5, {})
		v2.enqueueUpdate(v9, v7)
		expect(v9.updateQueue).toEqual(nil)
	end)
end)
describe("initialized ReactUpdateQueue", function()
	beforeEach(function()
		v2.initializeUpdateQueue(v9)
	end)
	it("initializes fiber", function()
		expect(v9.updateQueue).toBeDefined()
	end)
	it("enqueues first update", function()
		expect(v7.tag).toBe(0)
		v2.enqueueUpdate(v9, v7)
		expect(v7.next).toBe(v7)
		expect(v9.updateQueue.shared.pending).toBe(v7)
	end)
	it("enqueues same update twice", function()
		v2.enqueueUpdate(v9, v7)
		v2.enqueueUpdate(v9, v7)
		expect(v7.next).toBe(v7)
		expect(v7.next.next).toBe(v7)
		expect(v9.updateQueue.shared.pending).toBe(v7)
	end)
end)
describe("processUpdateQueue", function()
	beforeEach(function()
		v2.initializeUpdateQueue(v5)
		v9 = v3.createWorkInProgress(v5, v10)
	end)
	it("with empty queue", function()
		v2.processUpdateQueue(v9, v10, v6, v4.NoLanes)
		expect(v9.memoizedState).toBe(nil)
	end)
	it("with non-empty queue", function()
		v2.enqueueUpdate(v9, v7)
		expect(v9.memoizedState).toBe(nil)
		v2.processUpdateQueue(v9, v10, v6, v4.NoLanes)
		expect(v8).toBe(false)
		expect(v9.memoizedState).toEqual(payload)
	end)
end)
describe("commitUpdateQueue", function()
	beforeEach(function()
		noLane = v4.SomeRetryLane
		v7 = v2.createUpdate(0, noLane)
		v8 = false
		v7.payload = payload

		function v7.callback()
			v8 = true
		end

		v7.lane = noLane
		v2.initializeUpdateQueue(v5)
		v9 = v3.createWorkInProgress(v5, v10)
	end)
	it("with non-empty queue", function()
		v2.enqueueUpdate(v9, v7)
		expect(v9.memoizedState).toBe(nil)
		v2.processUpdateQueue(v9, v10, v6, v4.RetryLanes)
		expect(v5.updateQueue.effects).never.toBe(nil)
		v2.commitUpdateQueue(v9, v5.updateQueue, v6)
		expect(v8).toBe(true)
	end)
end)
describe("enqueueCapturedUpdate", function()
	beforeEach(function()
		noLane = v4.NoLane
		v7 = v2.createUpdate(0, noLane)
		v7.tag = v2.CaptureUpdate
		v7.lane = noLane
		v2.initializeUpdateQueue(v5)
		v9 = v3.createWorkInProgress(v5, v10)
		local ReactFiberFlags = require(script.Parent.Parent.ReactFiberFlags)
		v9.flags = bit32.bor(0, ReactFiberFlags.ShouldCapture)
	end)
	it("sets lastBaseUpdate", function()
		v2.enqueueCapturedUpdate(v9, v7)
		expect(v9.updateQueue.lastBaseUpdate).toEqual(v7)
	end)
end)