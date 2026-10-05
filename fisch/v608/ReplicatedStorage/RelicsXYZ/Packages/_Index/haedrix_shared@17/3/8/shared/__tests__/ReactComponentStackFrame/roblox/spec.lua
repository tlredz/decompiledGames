local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local string2 = LuauPolyfill.String
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function assertStringContains(value: string, p)
	assert(string.find(value, p, 1, true), string.format("could not find %q in %q", p, value))
end

describe("describeNativeComponentFrame", function()
	local describeNativeComponentFrame = nil
	beforeEach(function()
		jest.resetModules()
		local ReactComponentStackFrame = require(script.Parent.Parent.ReactComponentStackFrame)
		v = ReactComponentStackFrame
		describeNativeComponentFrame = v.describeNativeComponentFrame
	end)
	it("finds the appropriate line in the stack trace", function()
		local function FooComponent()
			error("some error")
		end

		local v2 = describeNativeComponentFrame(FooComponent, false)
		expect(v2).toBeDefined()
		local parts = string2.trim(v2):split("\n")
		expect(#parts).toBe(1)
		assertStringContains(parts[1], "FooComponent") -- equivalent call inferred; original call site unknown
	end)
end)
describe("with enableComponentStackLocations to false", function()
	beforeEach(function()
		jest.resetModules()
		local ReactFeatureFlags = require(script.Parent.Parent.ReactFeatureFlags)
		jest.mock(script.Parent.Parent.ReactFeatureFlags, function()
			return object.assign({}, ReactFeatureFlags, {
				enableComponentStackLocations = false
			})
		end)
		local ReactComponentStackFrame = require(script.Parent.Parent.ReactComponentStackFrame)
		v = ReactComponentStackFrame
	end)
	describe("describeBuiltInComponentFrame", function()
		it("shows only the component name if there is no source", function()
			assertStringContains(v.describeBuiltInComponentFrame("SomeComponent"), "SomeComponent") -- equivalent call inferred; original call site unknown
		end)
		local count = 0

		for k, v2 in {
			[""] = "",
			["/"] = "",
			["\\"] = "",
			Foo = "Foo",
			["Bar/Foo"] = "Foo",
			["Bar\\Foo"] = "Foo",
			["Baz/Bar/Foo"] = "Foo",
			["Baz\\Bar\\Foo"] = "Foo",
			["Foo.lua"] = "Foo.lua",
			["/Foo.lua"] = "Foo.lua",
			["\\Foo.lua"] = "Foo.lua",
			["Bar/Foo.lua"] = "Foo.lua",
			["Bar\\Foo.lua"] = "Foo.lua",
			["/Bar/Foo.lua"] = "Foo.lua",
			["\\Bar\\Foo.lua"] = "Foo.lua",
			["Bar/Baz/Foo.lua"] = "Foo.lua",
			["Bar\\Baz\\Foo.lua"] = "Foo.lua",
			["/Bar/Baz/Foo.lua"] = "Foo.lua",
			["\\Bar\\Baz\\Foo.lua"] = "Foo.lua",
			["C:\\funny long (path)/Foo.lua"] = "Foo.lua",
			["init.lua"] = "init.lua",
			["/init.lua"] = "init.lua",
			["\\init.lua"] = "init.lua",
			["Bar/init.lua"] = "Bar/init.lua",
			["Bar\\init.lua"] = "Bar/init.lua",
			["/Bar/init.lua"] = "Bar/init.lua",
			["\\Bar\\init.lua"] = "Bar/init.lua",
			["Bar/Baz/init.lua"] = "Baz/init.lua",
			["Bar\\Baz\\init.lua"] = "Baz/init.lua",
			["/Bar/Baz/init.lua"] = "Baz/init.lua",
			["\\Bar\\Baz\\init.lua"] = "Baz/init.lua",
			["C:\\funny long (path)/init.lua"] = "funny long (path)/init.lua"
		} do
			count += 1
			local fileName = k
			local v4 = v2
			it(string.format("converts the file name %q", k), function()
				local describeBuiltInComponentFrame = v.describeBuiltInComponentFrame("SomeComponent", {
					fileName = fileName,
					lineNumber = count
				}, nil)

				if not ReactGlobals.__DEV__ then
					assertStringContains(describeBuiltInComponentFrame, "SomeComponent") -- equivalent call inferred; original call site unknown
					return
				end

				assertStringContains(
					describeBuiltInComponentFrame,
					string.format("%s (at %s:%d)", "SomeComponent", v4, count)
				) -- equivalent call inferred; original call site unknown
			end)
		end
	end)
end)
describe("with enableComponentStackLocations to true", function()
	local describeBuiltInComponentFrame = nil
	beforeEach(function()
		jest.resetModules()
		local ReactFeatureFlags = require(script.Parent.Parent.ReactFeatureFlags)
		jest.mock(script.Parent.Parent.ReactFeatureFlags, function()
			return object.assign({}, ReactFeatureFlags, {
				enableComponentStackLocations = true
			})
		end)
		local ReactComponentStackFrame = require(script.Parent.Parent.ReactComponentStackFrame)
		v = ReactComponentStackFrame
		describeBuiltInComponentFrame = v.describeBuiltInComponentFrame
	end)
	describe("describeBuiltInComponentFrame", function()
		it("has the component name", function()
			assertStringContains(describeBuiltInComponentFrame("foo", {
				fileName = "file name",
				lineNumber = 7
			}), "foo") -- equivalent call inferred; original call site unknown
		end)
	end)
end)
describe("DEV warning stack trace", function()
	local v2 = nil
	local describeUnknownElementTypeFrameInDEV = nil
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.Dev.React)
		v2 = React
		local ReactComponentStackFrame = require(script.Parent.Parent.ReactComponentStackFrame)
		describeUnknownElementTypeFrameInDEV = ReactComponentStackFrame.describeUnknownElementTypeFrameInDEV
	end)
	it("should accept class component to describeUnknownElementTypeFrameInDev", function()
		local extended = v2.Component:extend("TestDevStackComponent")

		function extended.render(p)
			if p.state.isFrame then
				return (v2.createElement("Frame"))
			end

			return (v2.createElement("TextLabel", {
				Text = "Hello!"
			}))
		end

		local function DevParent()
			return v2.createElement("Frame")
		end

		local v3 = describeUnknownElementTypeFrameInDEV(v2.createElement(extended).type, {
			fileName = "TestDev-file.lua",
			lineNumber = 20
		}, DevParent)

		if ReactGlobals.__DEV__ then
			expect(v3).toEqual("\n    in TestDevStackComponent (at TestDev-file.lua:20)")
		else
			expect(v3).toEqual("")
		end
	end)
	it("should accept function component in describeUnknownElementTypeFrameInDev", function()
		local function DevStackFunctionComponent()
			error("Thrown Error")
			return v2.createElement("Frame")
		end

		local function DevParent()
			return v2.createElement("Frame")
		end

		local v3 = describeUnknownElementTypeFrameInDEV(v2.createElement(DevStackFunctionComponent).type, {
			fileName = "TestDevFunction-file.lua",
			lineNumber = 15
		}, DevParent)

		if ReactGlobals.__DEV__ then
			expect(v3).toEqual("\n    in DevStackFunctionComponent (at TestDevFunction-file.lua:15)")
		else
			expect(v3).toEqual("")
		end
	end)
end)