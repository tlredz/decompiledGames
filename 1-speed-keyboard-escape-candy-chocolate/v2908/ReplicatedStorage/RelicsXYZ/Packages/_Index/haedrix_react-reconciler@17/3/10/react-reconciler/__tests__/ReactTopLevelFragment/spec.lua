local parent = script.Parent.Parent.Parent
require(parent.LuauPolyfill)
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
beforeEach(function()
	jest.resetModules()
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
end)
it("should render a simple fragment at the top of a component", function()
	local function Fragment()
		return { v.createElement("TextLabel", {
				key = "a",
				Text = "Hello"
			}), v.createElement("TextLabel", {
				key = "b",
				Text = "World"
			}) }
	end

	v2.render(v.createElement(Fragment))
	expect(v3).toFlushWithoutYielding()
end)
it("should preserve state when switching from a single child", function()
	local v4 = nil
	local extended = v.Component:extend("Stateful")

	function extended.render(p)
		v4 = p
		return v.createElement("TextLabel", {
			Text = "Hello"
		})
	end

	local function Fragment(p)
		if p.condition then
			return v.createElement(extended, {
				key = "a"
			})
		end

		return { v.createElement(extended, {
				key = "a"
			}), v.createElement("Frame", {
				key = "b"
			}, v.createElement("TextLabel", {
				Text = "World"
			})) }
	end

	v2.render(v.createElement(Fragment))
	expect(v3).toFlushWithoutYielding()
	local v5 = v4
	expect(v5).never.toBe(nil)
	v2.render(v.createElement(Fragment, {
		condition = true
	}))
	expect(v3).toFlushWithoutYielding()
	expect(v4).toBe(v5)
end)
it("should not preserve state when switching to a nested array", function()
	local v4 = nil
	local extended = v.Component:extend("Stateful")

	function extended.render(p)
		v4 = p
		return v.createElement("TextLabel", {
			Text = "Hello"
		})
	end

	local function Fragment(p)
		if p.condition then
			return v.createElement(extended, {
				key = "a"
			})
		end

		return {
			{ v.createElement(extended, {
					key = "a"
				}), v.createElement("Frame", {
					key = "b"
				}, v.createElement("TextLabel", {
					Text = "World"
				})) },
			v.createElement("Frame", {
				key = "c"
			})
		}
	end

	v2.render(v.createElement(Fragment))
	expect(v3).toFlushWithoutYielding()
	local v5 = v4
	expect(v5).never.toBe(nil)
	v2.render(v.createElement(Fragment, {
		condition = true
	}))
	expect(v3).toFlushWithoutYielding()
	expect(v4).never.toBe(v5)
end)
it("preserves state if an implicit key slot switches from/to nil", function()
	local v4 = nil
	local extended = v.Component:extend("Stateful")

	function extended.render(p)
		v4 = p
		return v.createElement("TextLabel", {
			Text = "World"
		})
	end

	local function Fragment(p)
		if p.condition then
			return { nil, v.createElement(extended, {
					key = "a"
				}) }
		end

		return { v.createElement("Frame", {
				key = "b"
			}, v.createElement("TextLabel", {
				Text = "Hello"
			})), v.createElement(extended, {
				key = "a"
			}) }
	end

	v2.render(v.createElement(Fragment))
	expect(v3).toFlushWithoutYielding()
	local v5 = v4
	expect(v5).never.toBe(nil)
	v2.render(v.createElement(Fragment, {
		condition = true
	}))
	expect(v3).toFlushWithoutYielding()
	expect(v4).toBe(v5)
	v2.render(v.createElement(Fragment, {
		condition = false
	}))
	expect(v3).toFlushWithoutYielding()
	expect(v4).toBe(v5)
end)
it("should preserve state in a reorder", function()
	local v4 = nil
	local extended = v.Component:extend("Stateful")

	function extended.render(p)
		v4 = p
		return v.createElement("TextLabel", {
			Text = "Hello"
		})
	end

	local function Fragment(p)
		if p.condition then
			return {
				{ v.createElement("Frame", {
						key = "b"
					}, v.createElement("TextLabel", {
						Text = "World"
					})), v.createElement(extended, {
						key = "a"
					}) }
			}
		end

		return {
			{ v.createElement(extended, {
					key = "a"
				}), v.createElement("Frame", {
					key = "b"
				}, v.createElement("TextLabel", {
					Text = "World"
				})) },
			v.createElement("Frame", {
				key = "c"
			})
		}
	end

	v2.render(v.createElement(Fragment))
	expect(v3).toFlushWithoutYielding()
	local v5 = v4
	expect(v5).never.toBe(nil)
	v2.render(v.createElement(Fragment, {
		condition = true
	}))
	expect(v3).toFlushWithoutYielding()
	expect(v4).toBe(v5)
end)