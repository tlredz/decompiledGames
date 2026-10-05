local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
describe("ReactIncrementalSideEffects", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)

	local function div(...)
		local _, _, v4 = ...
		return {
			type = "div",
			children = v4 or {},
			prop = nil,
			hidden = false
		}
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function span(prop)
		return {
			type = "span",
			children = {},
			prop = prop,
			hidden = false
		}
	end

	local function text(text2)
		return {
			text = text2,
			hidden = false
		}
	end

	it("can delete a child when it unmounts inside a portal", function()
		local function Bar(p)
			return v.createElement("span", {
				prop = p.children
			})
		end

		local rootContainer = v2.getOrCreateRootContainer("portalContainer")

		local function Foo(p)
			return v2.createPortal(p.show and { v.createElement("div", {
					key = "a"
				}), v.createElement(Bar, {
					key = "b"
				}, "Hello"), "World" }, rootContainer)
		end

		v2.render(v.createElement("div", {}, v.createElement(Foo, {
			show = true
		})))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({ div() })
		expect(v2.getChildren("portalContainer")).toEqual({
			div(),
			span("Hello"),
			{
				text = "World",
				hidden = false
			}
		})
		v2.render(v.createElement("div", {}, v.createElement(Foo, {
			show = false
		})))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({ div() })
		expect(v2.getChildren("portalContainer")).toEqual({})
		v2.render(v.createElement("div", {}, v.createElement(Foo, {
			show = true
		})))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({ div() })
		expect(v2.getChildren("portalContainer")).toEqual({
			div(),
			span("Hello"),
			{
				text = "World",
				hidden = false
			}
		})
		v2.render(nil)
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({})
		v2.render(v.createElement(Foo, {
			show = false
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({})
		v2.render(v.createElement(Foo, {
			show = true
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({
			div(),
			span("Hello"),
			{
				text = "World",
				hidden = false
			}
		})
		v2.render(nil)
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({})
	end)
	it("can delete a child when it unmounts with a portal", function()
		local function Bar(p)
			return v.createElement("span", {
				prop = p.children
			})
		end

		local rootContainer = v2.getOrCreateRootContainer("portalContainer")

		local function Foo(_)
			return v2.createPortal({ v.createElement("div", {
					key = "a"
				}), v.createElement(Bar, {
					key = "b"
				}, "Hello"), "World" }, rootContainer)
		end

		v2.render(v.createElement("div", {}, v.createElement(Foo)))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({ div() })
		expect(v2.getChildren("portalContainer")).toEqual({
			div(),
			span("Hello"),
			{
				text = "World",
				hidden = false
			}
		})
		v2.render(nil)
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({})
		v2.render(v.createElement(Foo))
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({
			div(),
			span("Hello"),
			{
				text = "World",
				hidden = false
			}
		})
		v2.render(nil)
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren()).toEqual({})
		expect(v2.getChildren("portalContainer")).toEqual({})
	end)
end)