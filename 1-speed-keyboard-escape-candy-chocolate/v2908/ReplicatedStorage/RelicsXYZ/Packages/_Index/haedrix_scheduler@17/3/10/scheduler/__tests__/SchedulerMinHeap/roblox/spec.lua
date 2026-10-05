local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local SchedulerMinHeap = require(script.Parent.Parent.SchedulerMinHeap)

local function verifyOrder(list)
	for i = 2, #list do
		local v = math.floor(i / 2)
		expect(list[i].sortIndex).toBeGreaterThan(list[v].sortIndex)
	end
end

local count = 0

local function getIncrement()
	count += 1
	return count
end

local function makeNode(sortIndex: number, id: number?)
	if not id then
		count += 1
		id = count
	end

	return {
		sortIndex = sortIndex,
		id = id
	}
end

describe("push", function()
	it("should add a value to the minHeap", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 42,
			id = count
		})
		verifyOrder(v)
	end)
	it("properly sort a minHeap each time", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 2,
			id = count
		})
		verifyOrder(v)
		local push2 = SchedulerMinHeap.push
		count += 1
		push2(v, {
			sortIndex = 1,
			id = count
		})
		verifyOrder(v)
		local push3 = SchedulerMinHeap.push
		count += 1
		push3(v, {
			sortIndex = 3,
			id = count
		})
		verifyOrder(v)
	end)
end)
describe("peek", function()
	it("should return nil from an empty minHeap", function()
		local v = {}
		expect(SchedulerMinHeap.peek(v)).never.toBeDefined()
		verifyOrder(v)
	end)
	it("return the only value on a minHeap of one element", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 42,
			id = count
		})
		verifyOrder(v)
		expect(SchedulerMinHeap.peek(v).sortIndex).toBe(42)
	end)
	it("return the smaller value on a minHeap of two elements", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 42,
			id = count
		})
		verifyOrder(v)
		local push2 = SchedulerMinHeap.push
		count += 1
		push2(v, {
			sortIndex = 1,
			id = count
		})
		verifyOrder(v)
		expect(SchedulerMinHeap.peek(v).sortIndex).toBe(1)
	end)
	it("return the smallest value on a minHeap of 10 elements", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 10,
			id = count
		})
		local push2 = SchedulerMinHeap.push
		count += 1
		push2(v, {
			sortIndex = 7,
			id = count
		})
		local push3 = SchedulerMinHeap.push
		count += 1
		push3(v, {
			sortIndex = 1,
			id = count
		})
		local push4 = SchedulerMinHeap.push
		count += 1
		push4(v, {
			sortIndex = 5,
			id = count
		})
		local push5 = SchedulerMinHeap.push
		count += 1
		push5(v, {
			sortIndex = 6,
			id = count
		})
		local push6 = SchedulerMinHeap.push
		count += 1
		push6(v, {
			sortIndex = 9,
			id = count
		})
		local push7 = SchedulerMinHeap.push
		count += 1
		push7(v, {
			sortIndex = 8,
			id = count
		})
		local push8 = SchedulerMinHeap.push
		count += 1
		push8(v, {
			sortIndex = 4,
			id = count
		})
		local push9 = SchedulerMinHeap.push
		count += 1
		push9(v, {
			sortIndex = 2,
			id = count
		})
		local push10 = SchedulerMinHeap.push
		count += 1
		push10(v, {
			sortIndex = 3,
			id = count
		})
		verifyOrder(v)
		expect(SchedulerMinHeap.peek(v).sortIndex).toBe(1)
	end)
end)
describe("pop", function()
	it("remove the smallest element on a minHeap of 5 elements", function()
		local v = {}
		local push = SchedulerMinHeap.push
		count += 1
		push(v, {
			sortIndex = 1,
			id = count
		})
		local push2 = SchedulerMinHeap.push
		count += 1
		push2(v, {
			sortIndex = 2,
			id = count
		})
		local push3 = SchedulerMinHeap.push
		count += 1
		push3(v, {
			sortIndex = 3,
			id = count
		})
		local push4 = SchedulerMinHeap.push
		count += 1
		push4(v, {
			sortIndex = 4,
			id = count
		})
		local push5 = SchedulerMinHeap.push
		count += 1
		push5(v, {
			sortIndex = 5,
			id = count
		})
		local v7 = SchedulerMinHeap.pop(v)
		verifyOrder(v)
		expect(v7.sortIndex).toBe(1)
		expect(SchedulerMinHeap.peek(v).sortIndex).toBe(2)
	end)
end)