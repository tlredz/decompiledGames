local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local parent = script.Parent.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
	local RobloxComponentProps = require(script.Parent.Parent.RobloxComponentProps)
	v4 = RobloxComponentProps
end)

local function getSizeOfMap(items)
	local count = 0

	for _ in items do
		count += 1
	end

	return count
end

it("should clear instanceToBindings map of unmounted instances", function()
	local binding = v.createBinding("Hello world!")

	local function Component()
		return v.createElement("TextLabel", {
			key = "label",
			Text = binding
		})
	end

	local folder = Instance.new("Folder")
	local root = v2.createRoot(folder)
	root:render(v.createElement(Component))
	v3.unstable_flushAllWithoutAsserting()
	local count = 0

	for _ in v4._instanceToBindings do
		count += 1
	end

	expect(count).toBe(1)

	for k in v4._instanceToBindings do
		expect(k:IsDescendantOf(folder)).toBe(true)
	end

	root:unmount()
	v3.unstable_flushAllWithoutAsserting()
	local count2 = 0

	for _ in v4._instanceToBindings do
		count2 += 1
	end

	expect(count2).toBe(0)
end)
it("should clear instanceToEventManager map of unmounted instances", function()
	local function Component()
		return v.createElement("TextButton", {
			key = "button",
			[v2.Event.Activated] = function() end,
			[v2.Change.Text] = function() end
		})
	end

	local folder = Instance.new("Folder")
	local root = v2.createRoot(folder)
	root:render(v.createElement(Component))
	v3.unstable_flushAllWithoutAsserting()
	local count = 0

	for _ in v4._instanceToEventManager do
		count += 1
	end

	expect(count).toBe(1)

	for k in v4._instanceToEventManager do
		expect(k:IsDescendantOf(folder)).toBe(true)
	end

	root:unmount()
	v3.unstable_flushAllWithoutAsserting()
	local count2 = 0

	for _ in v4._instanceToEventManager do
		count2 += 1
	end

	expect(count2).toBe(0)
end)
it("should clear instanceToBindings map of unmounted descendents", function()
	local binding = v.createBinding("Hello world!")

	local function Component()
		return v.createElement("Frame", {}, {
			Label = v.createElement("TextLabel", {
				Text = binding
			}),
			Button = v.createElement("TextButton", {
				Text = binding:map(function(p)
					return p .. " (Button)"
				end)
			})
		})
	end

	local folder = Instance.new("Folder")
	local root = v2.createRoot(folder)
	root:render(v.createElement("ScreenGui", nil, v.createElement(Component)))
	v3.unstable_flushAllWithoutAsserting()
	local count = 0

	for _ in v4._instanceToBindings do
		count += 1
	end

	expect(count).toBe(2)

	for k in v4._instanceToBindings do
		expect(k:IsDescendantOf(folder)).toBe(true)
	end

	root:unmount()
	v3.unstable_flushAllWithoutAsserting()
	local count2 = 0

	for _ in v4._instanceToBindings do
		count2 += 1
	end

	expect(count2).toBe(0)
end)
it("should clear instanceToEventManager map of unmounted descendents", function()
	local function Component()
		return v.createElement("Frame", {}, {
			Button = v.createElement("TextButton", {
				[v2.Event.Activated] = function() end
			}),
			Label = v.createElement("TextLabel", {
				[v2.Change.Text] = function() end
			})
		})
	end

	local folder = Instance.new("Folder")
	local root = v2.createRoot(folder)
	root:render(v.createElement("ScreenGui", nil, v.createElement(Component)))
	v3.unstable_flushAllWithoutAsserting()
	local count = 0

	for _ in v4._instanceToEventManager do
		count += 1
	end

	expect(count).toBe(2)

	for k in v4._instanceToEventManager do
		expect(k:IsDescendantOf(folder)).toBe(true)
	end

	root:unmount()
	v3.unstable_flushAllWithoutAsserting()
	local count2 = 0

	for _ in v4._instanceToEventManager do
		count2 += 1
	end

	expect(count2).toBe(0)
end)