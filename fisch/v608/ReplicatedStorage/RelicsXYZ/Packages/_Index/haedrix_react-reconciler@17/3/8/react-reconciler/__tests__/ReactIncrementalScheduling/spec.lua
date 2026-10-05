local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
describe("ReactIncrementalScheduling", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function span(prop)
		return {
			type = "span",
			children = {},
			prop = prop,
			hidden = false
		}
	end

	it("schedules and flushes deferred work", function()
		v2.render(v.createElement("span", {
			prop = "1"
		}))
		expect(v2.getChildren()).toEqual({})
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = "1"
		}))
	end)
	it("searches for work on other roots once the current root completes", function()
		v2.renderToRootWithID(v.createElement("span", {
			prop = "a:1"
		}), "a")
		v2.renderToRootWithID(v.createElement("span", {
			prop = "b:1"
		}), "b")
		v2.renderToRootWithID(v.createElement("span", {
			prop = "c:1"
		}), "c")
		expect(v3).toFlushWithoutYielding()
		expect(v2.getChildren("a")).toEqual({ span("a:1") })
		expect(v2.getChildren("b")).toEqual({ span("b:1") })
		expect(v2.getChildren("c")).toEqual({ span("c:1") })
	end)
	it("schedules top-level updates in order of priority", function()
		v2.render(v.createElement("span", {
			prop = 1
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 1
		}))
		v2.batchedUpdates(function()
			v2.render(v.createElement("span", {
				prop = 5
			}))
			v2.flushSync(function()
				v2.render(v.createElement("span", {
					prop = 2
				}))
				v2.render(v.createElement("span", {
					prop = 3
				}))
				v2.render(v.createElement("span", {
					prop = 4
				}))
			end)
		end)
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 4
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 4
		}))
	end)
	it("schedules top-level updates with same priority in order of insertion", function()
		v2.render(v.createElement("span", {
			prop = 1
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 1
		}))
		v2.render(v.createElement("span", {
			prop = 2
		}))
		v2.render(v.createElement("span", {
			prop = 3
		}))
		v2.render(v.createElement("span", {
			prop = 4
		}))
		v2.render(v.createElement("span", {
			prop = 5
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 5
		}))
	end)
	it("works on deferred roots in the order they were scheduled", function()
		local useEffect = v.useEffect

		local function Text(p)
			local text = p.text
			useEffect(function()
				v3.unstable_yieldValue(text)
			end, { text })
			return text
		end

		v2.act(function()
			v2.renderToRootWithID(v.createElement(Text, {
				text = "a:1"
			}), "a")
			v2.renderToRootWithID(v.createElement(Text, {
				text = "b:1"
			}), "b")
			v2.renderToRootWithID(v.createElement(Text, {
				text = "c:1"
			}), "c")
		end)
		expect(v3).toHaveYielded({ "a:1", "b:1", "c:1" })
		expect(v2.getChildren("a")[1].text).toEqual("a:1")
		expect(v2.getChildren("b")[1].text).toEqual("b:1")
		expect(v2.getChildren("c")[1].text).toEqual("c:1")
		expect(#v2.getChildren("a")).toEqual(1)
		expect(#v2.getChildren("b")).toEqual(1)
		expect(#v2.getChildren("c")).toEqual(1)
		v2.act(function()
			v2.renderToRootWithID(v.createElement(Text, {
				text = "c:2"
			}), "c")
			v2.renderToRootWithID(v.createElement(Text, {
				text = "b:2"
			}), "b")
			expect(v3).toFlushAndYieldThrough({ "c:2" })
			expect(v2.getChildren("a")[1].text).toEqual("a:1")
			expect(v2.getChildren("b")[1].text).toEqual("b:1")
			expect(v2.getChildren("c")[1].text).toEqual("c:2")
			expect(#v2.getChildren("a")).toEqual(1)
			expect(#v2.getChildren("b")).toEqual(1)
			expect(#v2.getChildren("c")).toEqual(1)
			v2.renderToRootWithID(v.createElement(Text, {
				text = "a:2"
			}), "a")
			expect(v3).toFlushAndYieldThrough({ "b:2" })
			expect(v2.getChildren("a")[1].text).toEqual("a:1")
			expect(v2.getChildren("b")[1].text).toEqual("b:2")
			expect(v2.getChildren("c")[1].text).toEqual("c:2")
			expect(#v2.getChildren("a")).toEqual(1)
			expect(#v2.getChildren("b")).toEqual(1)
			expect(#v2.getChildren("c")).toEqual(1)
			expect(v3).toFlushAndYieldThrough({ "a:2" })
			expect(v2.getChildren("a")[1].text).toEqual("a:2")
			expect(v2.getChildren("b")[1].text).toEqual("b:2")
			expect(v2.getChildren("c")[1].text).toEqual("c:2")
			expect(#v2.getChildren("a")).toEqual(1)
			expect(#v2.getChildren("b")).toEqual(1)
			expect(#v2.getChildren("c")).toEqual(1)
		end)
	end)
	it("schedules sync updates when inside componentDidMount/Update", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				tick = 0
			}
		end

		function extended.componentDidMount(object)
			v3.unstable_yieldValue("componentDidMount (before setState): " .. object.state.tick)
			object:setState({
				tick = 1
			})
			v3.unstable_yieldValue("componentDidMount (after setState): " .. object.state.tick)
		end

		function extended.componentDidUpdate(object)
			v3.unstable_yieldValue("componentDidUpdate: " .. object.state.tick)

			if object.state.tick == 2 then
				v3.unstable_yieldValue("componentDidUpdate (before setState): " .. object.state.tick)
				object:setState({
					tick = 3
				})
				v3.unstable_yieldValue("componentDidUpdate (after setState): " .. object.state.tick)
			end
		end

		function extended.render(p)
			v3.unstable_yieldValue("render: " .. p.state.tick)
			v4 = p
			return v.createElement("span", {
				prop = p.state.tick
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYieldThrough({ "render: 0" })
		expect(v2.flushNextYield()).toEqual({
			"componentDidMount (before setState): 0",
			"componentDidMount (after setState): 0",
			"render: 1",
			"componentDidUpdate: 1"
		})
		v4:setState({
			tick = 2
		})
		expect(v3).toFlushAndYieldThrough({ "render: 2" })
		expect(v2.flushNextYield()).toEqual({
			"componentDidUpdate: 2",
			"componentDidUpdate (before setState): 2",
			"componentDidUpdate (after setState): 2",
			"render: 3",
			"componentDidUpdate: 3"
		})
	end)
	it("can opt-in to async scheduling inside componentDidMount/Update", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				tick = 0
			}
		end

		function extended.componentDidMount(object)
			v2.deferredUpdates(function()
				v3.unstable_yieldValue("componentDidMount (before setState): " .. object.state.tick)
				object:setState({
					tick = 1
				})
				v3.unstable_yieldValue("componentDidMount (after setState): " .. object.state.tick)
			end)
		end

		function extended.componentDidUpdate(object)
			v2.deferredUpdates(function()
				v3.unstable_yieldValue("componentDidUpdate: " .. object.state.tick)

				if object.state.tick == 2 then
					v3.unstable_yieldValue("componentDidUpdate (before setState): " .. object.state.tick)
					object:setState({
						tick = 3
					})
					v3.unstable_yieldValue("componentDidUpdate (after setState): " .. object.state.tick)
				end
			end)
		end

		function extended.render(p)
			v3.unstable_yieldValue("render: " .. p.state.tick)
			v4 = p
			return v.createElement("span", {
				prop = p.state.tick
			})
		end

		v2.flushSync(function()
			v2.render(v.createElement(extended))
		end)
		expect(v3).toHaveYielded({
			"render: 0",
			"componentDidMount (before setState): 0",
			"componentDidMount (after setState): 0"
		})
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 0
		}))
		expect(v3).toFlushAndYield({ "render: 1", "componentDidUpdate: 1" })
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 1
		}))
		v4:setState({
			tick = 2
		})
		expect(v3).toFlushAndYieldThrough({
			"render: 2",
			"componentDidUpdate: 2",
			"componentDidUpdate (before setState): 2",
			"componentDidUpdate (after setState): 2"
		})
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 2
		}))
		expect(v3).toFlushAndYield({ "render: 3", "componentDidUpdate: 3" })
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 3
		}))
	end)
	it("performs Task work even after time runs out", function()
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				step = 1
			}
		end

		function extended.componentDidMount(object)
			object:setState({
				step = 2
			}, function()
				object:setState({
					step = 3
				}, function()
					object:setState({
						step = 4
					}, function()
						object:setState({
							step = 5
						})
					end)
				end)
			end)
		end

		function extended.render(p)
			v3.unstable_yieldValue("Foo")
			return v.createElement("span", {
				prop = p.state.step
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYieldThrough({ "Foo" })
		expect(v2).toMatchRenderedOutput(nil)
		v2.flushNextYield()
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 5
		}))
	end)
	it("can opt-out of batching using unbatchedUpdates", function()
		v2.flushSync(function()
			v2.render(v.createElement("span", {
				prop = 0
			}))
			expect(v2.getChildren()).toEqual({})
			v2.unbatchedUpdates(function()
				v2.render(v.createElement("span", {
					prop = 1
				}))
				expect(v2).toMatchRenderedOutput(v.createElement("span", {
					prop = 1
				}))
				v2.render(v.createElement("span", {
					prop = 2
				}))
				expect(v2).toMatchRenderedOutput(v.createElement("span", {
					prop = 2
				}))
			end)
			v2.render(v.createElement("span", {
				prop = 3
			}))
			expect(v2).toMatchRenderedOutput(v.createElement("span", {
				prop = 2
			}))
		end)
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 3
		}))
	end)
	it("nested updates are always deferred, even inside unbatchedUpdates", function()
		local v4 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				step = 0
			}
		end

		function extended.componentDidUpdate(object)
			v3.unstable_yieldValue("componentDidUpdate: " .. object.state.step)

			if object.state.step == 1 then
				v2.unbatchedUpdates(function()
					object:setState({
						step = 2
					})
				end)
				expect(v3).toHaveYielded({ "render: 1", "componentDidUpdate: 1" })
				expect(v2).toMatchRenderedOutput(v.createElement("span", {
					prop = 1
				}))
			end
		end

		function extended.render(p)
			v3.unstable_yieldValue("render: " .. p.state.step)
			v4 = p
			return v.createElement("span", {
				prop = p.state.step
			})
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYield({ "render: 0" })
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 0
		}))
		v2.flushSync(function()
			v4:setState({
				step = 1
			})
		end)
		expect(v3).toHaveYielded({ "render: 2", "componentDidUpdate: 2" })
		expect(v2).toMatchRenderedOutput(v.createElement("span", {
			prop = 2
		}))
	end)
end)