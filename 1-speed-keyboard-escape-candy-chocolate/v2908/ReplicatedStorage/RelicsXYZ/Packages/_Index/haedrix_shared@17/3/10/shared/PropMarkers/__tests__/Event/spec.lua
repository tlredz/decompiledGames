local parent = script.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local it = JestGlobals.it
local Typeroblox = require(script.Parent.Parent.Parent["Type.roblox"])
local Event = require(script.Parent.Parent.Event)
it("should yield event objects when indexed", function()
	expect(Typeroblox.of(Event.MouseButton1Click)).toBe(Typeroblox.HostEvent)
	expect(Typeroblox.of(Event.Touched)).toBe(Typeroblox.HostEvent)
end)
it("should yield the same object when indexed again", function()
	local mouseButton1Click = Event.MouseButton1Click
	local mouseButton1Click2 = Event.MouseButton1Click
	local touched = Event.Touched
	expect(mouseButton1Click).toBe(mouseButton1Click2)
	expect(mouseButton1Click).never.toBe(touched)
end)