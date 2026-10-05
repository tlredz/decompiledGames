local parent = script.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local folder = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local Shared = require(parent.Shared)
	Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	local Scheduler = require(parent.Scheduler)
	v5 = Scheduler
	local ReactRobloxComponentTree = require(script.Parent.Parent.ReactRobloxComponentTree)
	v4 = ReactRobloxComponentTree
	folder = Instance.new("Folder")
	v3 = v2.createRoot(folder)
end)
it("getClosestInstanceFromNode should return a cached instance", function()
	v3:render(v.createElement("Frame", {}, {
		Label = v.createElement("TextLabel", {
			Text = "Hello"
		})
	}))
	v5.unstable_flushAllWithoutAsserting()
	expect(v4.getClosestInstanceFromNode(folder.Frame.Label).memoizedProps.Text).toEqual("Hello")
end)
it("getClosestInstanceFromNode should return portaled instances", function()
	local frame = Instance.new("Frame")
	local frame2 = Instance.new("Frame")
	local frame3 = Instance.new("Frame")
	v3:render({ v.createElement("TextLabel", {
			key = "a",
			Text = "normal[0]"
		}), v2.createPortal({
			v.createElement("TextLabel", {
				key = "b",
				Text = "portal1[0]"
			}),
			v2.createPortal(v.createElement("TextLabel", {
				key = "c",
				Text = "portal2[0]"
			}), frame2),
			v2.createPortal(v.createElement("TextLabel", {
				key = "d",
				Text = "portal3[0]"
			}), frame3),
			v.createElement("TextLabel", {
				key = "e",
				Text = "portal1[1]"
			})
		}, frame), v.createElement("TextLabel", {
			key = "f",
			Text = "normal[1]"
		}) })
	v5.unstable_flushAllWithoutAsserting()
	expect(v4.getClosestInstanceFromNode(frame3:GetChildren()[1]).memoizedProps.Text).toEqual("portal3[0]")
end)