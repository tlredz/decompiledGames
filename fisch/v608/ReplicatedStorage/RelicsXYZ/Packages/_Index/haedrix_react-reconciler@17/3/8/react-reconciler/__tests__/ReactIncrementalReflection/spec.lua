local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local Shared = require(parent.Shared)
local console = Shared.console
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest
describe("ReactIncrementalReflection", function()
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
		local _, _, children = ...
		return {
			type = "div",
			children = children,
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

	it("handles isMounted even when the initial render is deferred", function()
		local v4 = {}
		local extended = v.Component:extend("Component")

		function extended:_isMounted()
			return self.__updater.isMounted(self)
		end

		function extended:UNSAFE_componentWillMount()
			table.insert(v4, self)
			v3.unstable_yieldValue("componentWillMount: " .. tostring(self:_isMounted()))
		end

		function extended:componentDidMount()
			v3.unstable_yieldValue("componentDidMount: " .. tostring(self:_isMounted()))
		end

		function extended.render(_)
			return v.createElement("span")
		end

		local function Foo()
			return v.createElement(extended)
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushAndYieldThrough({ "componentWillMount: false" })
		expect(v4[1]:_isMounted()).toBe(false)
		expect(function()
			return expect(v3).toFlushAndYield({ "componentDidMount: true" })
		end).toErrorDev("Using UNSAFE_componentWillMount in strict mode is not recommended", {
			withoutStack = true
		})
		expect(v4[1]:_isMounted()).toBe(true)
	end)
	it("handles isMounted when an unmount is deferred", function()
		local v4 = {}
		local extended = v.Component:extend("Component")

		function extended:init()
			self.state = {}
		end

		function extended:_isMounted()
			return self.__updater.isMounted(self)
		end

		function extended.UNSAFE_componentWillMount(p)
			table.insert(v4, p)
		end

		function extended:componentWillUnmount()
			v3.unstable_yieldValue("componentWillUnmount: " .. tostring(self:_isMounted()))
		end

		function extended.render(_)
			v3.unstable_yieldValue("Component")
			return v.createElement("span")
		end

		local function Other()
			v3.unstable_yieldValue("Other")
			return v.createElement("span")
		end

		local function Foo(p)
			if p.mount then
				return v.createElement(extended)
			end

			return v.createElement(Other)
		end

		v2.render(v.createElement(Foo, {
			mount = true
		}))
		expect(function()
			return expect(v3).toFlushAndYield({ "Component" })
		end).toErrorDev("Using UNSAFE_componentWillMount in strict mode is not recommended", {
			withoutStack = true
		})
		expect(v4[1]:_isMounted()).toBe(true)
		v2.render(v.createElement(Foo, {
			mount = false
		}))
		expect(v3).toFlushAndYieldThrough({ "Other" })
		expect(v4[1]:_isMounted()).toBe(true)
		expect(v3).toFlushAndYield({ "componentWillUnmount: true" })
		expect(v4[1]:_isMounted()).toBe(false)
	end)
	xit("finds no node before insertion and correct node before deletion", function()
		local v4 = nil

		local function findInstance(p)
			local error2 = console.error
			console.error = nil
			local success, result = pcall(function()
				return v2.findInstance(p)
			end)
			console.error = error2

			if success then
				return result
			end

			error(result)
		end

		local extended = v.Component:extend("Component")

		function extended.UNSAFE_componentWillMount(p)
			v4 = p
			v3.unstable_yieldValue({ "componentWillMount", findInstance(p) })
		end

		function extended.componentDidMount(p)
			v3.unstable_yieldValue({ "componentDidMount", findInstance(p) })
		end

		function extended.UNSAFE_componentWillUpdate(p)
			v3.unstable_yieldValue({ "componentWillUpdate", findInstance(p) })
		end

		function extended.componentDidUpdate(p)
			v3.unstable_yieldValue({ "componentDidUpdate", findInstance(p) })
		end

		function extended.componentWillUnmount(p)
			v3.unstable_yieldValue({ "componentWillUnmount", findInstance(p) })
		end

		function extended:render()
			v3.unstable_yieldValue("render")
			return function()
				if self.props.step < 2 then
					return v.createElement(span, {
						ref = function(span2)
							self.span = span2
							return span2
						end
					})
				end

				if self.props.step == 2 then
					return v.createElement(div, {
						ref = function(div2)
							self.div = div2
							return div2
						end
					})
				end

				if self.props.step == 3 then
					return nil
				end

				if self.props.step == 4 then
					return v.createElement(div, {
						ref = function(span2)
							self.span = span2
							return span2
						end
					})
				end

				return nil
			end
		end

		local function Sibling()
			v3.unstable_yieldValue("render sibling")
			return v.createElement(span)
		end

		local function Foo(p)
			return { v.createElement(extended, {
					key = "a",
					step = p.step
				}), v.createElement(Sibling, {
					key = "b"
				}) }
		end

		v2.render(v.createElement(Foo, {
			step = 0
		}))
		expect(v3).toFlushAndYieldThrough({
			{ "componentWillMount", nil },
			"render",
			"render sibling"
		})
		expect(v4).toBeDefined()
		expect(findInstance(v4)).toBe(nil)
		expect(function()
			return expect(v3).toFlushAndYield({
				{ "componentDidMount", span(nil) }
			})
		end).toErrorDev({
			"Using UNSAFE_componentWillMount in strict mode is not recommended",
			"Using UNSAFE_componentWillUpdate in strict mode is not recommended"
		}, {
			withoutStack = true
		})
		local span2 = v4.span
		expect(span2).toBeDefined()
		expect(findInstance(v4)).toBe(span2)
		v2.render(v.createElement(Foo, {
			step = 1
		}))
		expect(v3).toFlushAndYield({
			{ "componentWillUpdate", span2 },
			"render",
			"render sibling",
			{ "componentDidUpdate", span2 }
		})
		expect(v2.findInstance(v4)).toBe(span2)
		v2.render(v.createElement(Foo, {
			step = 2
		}))
		expect(v3).toFlushAndYieldThrough({
			{ "componentWillUpdate", span2 },
			"render",
			"render sibling"
		})
		expect(v2.findInstance(v4)).toBe(span2)
		expect(v3).toFlushAndYield({
			{ "componentDidUpdate", div() }
		})
		local div2 = v4.div
		expect(div2).toBeDefined()
		expect(span2).never.toBe(div2)
		expect(v2.findInstance(v4)).toBe(div2)
		v2.render(v.createElement(Foo, {
			step = 3
		}))
		expect(v3).toFlushAndYieldThrough({
			{ "componentWillUpdate", div2 },
			"render",
			"render sibling"
		})
		expect(v2.findInstance(v4)).toBe(div2)
		expect(v3).toFlushAndYield({
			{ "componentDidUpdate", nil }
		})
		expect(v2.findInstance(v4)).toBe(nil)
		v2.render(v.createElement(Foo, {
			step = 4
		}))
		expect(v3).toFlushAndYield({
			{ "componentWillUpdate", nil },
			"render",
			"render sibling",
			{ "componentDidUpdate", div() }
		})
		v2.render({})
		expect(v3).toFlushAndYield({
			{ "componentWillUnmount", div2 }
		})
	end)
end)