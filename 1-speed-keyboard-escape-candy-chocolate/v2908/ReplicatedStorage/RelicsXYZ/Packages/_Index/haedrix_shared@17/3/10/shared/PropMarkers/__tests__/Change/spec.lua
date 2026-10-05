local parent = script.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local it = JestGlobals.it
local Typeroblox = require(script.Parent.Parent.Parent["Type.roblox"])
local Change = require(script.Parent.Parent.Change)
it("should yield change listener objects when indexed", function()
	expect(Typeroblox.of(Change.Text)).toBe(Typeroblox.HostChangeEvent)
	expect(Typeroblox.of(Change.Selected)).toBe(Typeroblox.HostChangeEvent)
end)
it("should yield the same object when indexed again", function()
	local text = Change.Text
	local text2 = Change.Text
	local selected = Change.Selected
	expect(text).toBe(text2)
	expect(text).never.toBe(selected)
end)