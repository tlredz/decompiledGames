local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local Shared = require(parent.Shared)
local reactFeatureFlags = Shared.ReactFeatureFlags
local v = nil
local v2 = nil
local v3 = nil
local HttpService = game:GetService("HttpService")
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest

local function propTypes(p, p2)
	if not (p ~= nil and type(p) ~= p2) then
		return nil
	end

	return error2("expected " .. p2)
end

local v4 = {
	number = function(p, p2)
		return propTypes(p[p2], "number")
	end,
	string = function(p, p2)
		return propTypes(p[p2], "string")
	end
}
describe("ReactIncremental", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)

	local function LegacyHiddenDiv(p)
		local children = p.children
		local mode = p.mode
		return v.createElement("div", {
			hidden = mode == "hidden"
		}, v.createElement(v.unstable_LegacyHidden, {
			mode = mode == "hidden" and "unstable-defer-without-hiding" or mode
		}, children))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function JSONStringify(p)
		local jSONEncode = HttpService:JSONEncode(p)
		return jSONEncode == "[]" and "{}" or jSONEncode
	end

	it("should render a simple component", function()
		local function Bar()
			return v.createElement("div", nil, "Hello World")
		end

		local function Foo()
			return v.createElement(Bar, {
				isBar = true
			})
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushWithoutYielding()
	end)
	it("should render a simple component, in steps if needed", function()
		local function Bar()
			v3.unstable_yieldValue("Bar")
			return v.createElement("span", nil, v.createElement("div", nil, "Hello World"))
		end

		local function Foo()
			v3.unstable_yieldValue("Foo")
			return { v.createElement(Bar, {
					key = "a",
					isBar = true
				}), v.createElement(Bar, {
					key = "b",
					isBar = true
				}) }
		end

		v2.render(v.createElement(Foo), function()
			v3.unstable_yieldValue("callback")
		end)
		expect(v2.flushNextYield()).toEqual({ "Foo" })
		expect(v3).toFlushAndYield({ "Bar", "Bar", "callback" })
	end)
	it("updates a previous render", function()
		local function Header()
			v3.unstable_yieldValue("Header")
			return v.createElement("h1", nil, "Hi")
		end

		local function Content(p)
			v3.unstable_yieldValue("Content")
			return v.createElement("div", nil, p.children)
		end

		local function Footer()
			v3.unstable_yieldValue("Footer")
			return v.createElement("footer", nil, "Bye")
		end

		local element = v.createElement(Header)
		local element2 = v.createElement(Footer)

		local function Foo(p)
			v3.unstable_yieldValue("Foo")
			return v.createElement("div", nil, element, v.createElement(Content, nil, p.text), element2)
		end

		v2.render(v.createElement(Foo, {
			text = "foo"
		}), function()
			return v3.unstable_yieldValue("renderCallbackCalled")
		end)
		expect(v3).toFlushAndYield({
			"Foo",
			"Header",
			"Content",
			"Footer",
			"renderCallbackCalled"
		})
		v2.render(v.createElement(Foo, {
			text = "bar"
		}), function()
			return v3.unstable_yieldValue("firstRenderCallbackCalled")
		end)
		v2.render(v.createElement(Foo, {
			text = "bar"
		}), function()
			return v3.unstable_yieldValue("secondRenderCallbackCalled")
		end)
		expect(v3).toFlushAndYield({
			"Foo",
			"Content",
			"firstRenderCallbackCalled",
			"secondRenderCallbackCalled"
		})
	end)
	it("can cancel partially rendered work and restart", function()
		local function Bar(p)
			v3.unstable_yieldValue("Bar")
			return v.createElement("div", nil, p.children)
		end

		local function Foo(p)
			v3.unstable_yieldValue("Foo")
			return v.createElement("div", nil, v.createElement(Bar, nil, p.text), v.createElement(Bar, nil, p.text))
		end

		v2.render(v.createElement(Foo, {
			text = "foo"
		}))
		expect(v3).toFlushAndYield({ "Foo", "Bar", "Bar" })
		v2.render(v.createElement(Foo, {
			text = "bar"
		}))
		expect(v3).toFlushAndYieldThrough({ "Foo", "Bar" })
		v2.flushSync(function()
			return v2.render(nil)
		end)
		v2.render(v.createElement(Foo, {
			text = "baz"
		}))
		expect(v3).toFlushAndYieldThrough({ "Foo", "Bar" })
		expect(v3).toFlushAndYield({ "Bar" })
	end)
	it("should call callbacks even if updates are aborted", function()
		local v5 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				text = "foo",
				text2 = "foo"
			}
			v5 = self
		end

		function extended.render(p)
			return v.createElement(
				"div",
				nil,
				v.createElement("div", nil, p.state.text),
				v.createElement("div", nil, p.state.text2)
			)
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()
		v5:setState(function()
			v3.unstable_yieldValue("setState1")
			return {
				text = "bar"
			}
		end, function()
			return v3.unstable_yieldValue("callback1")
		end)
		expect(v3).toFlushAndYieldThrough({ "setState1" })
		v2.flushSync(function()
			return v2.render(v.createElement(extended))
		end)
		v5:setState(function()
			v3.unstable_yieldValue("setState2")
			return {
				text2 = "baz"
			}
		end, function()
			return v3.unstable_yieldValue("callback2")
		end)
		expect(v3).toFlushAndYield({
			"setState1",
			"setState2",
			"callback1",
			"callback2"
		})
		expect(v5.state).toEqual({
			text = "bar",
			text2 = "baz"
		})
	end)
	it("can deprioritize unfinished work and resume it later", function()
		local function Bar(p)
			v3.unstable_yieldValue("Bar")
			return v.createElement("div", nil, p.children)
		end

		local function Middle(p)
			v3.unstable_yieldValue("Middle")
			return v.createElement("span", nil, p.children)
		end

		local function Foo(p)
			v3.unstable_yieldValue("Foo")
			return v.createElement("div", nil, v.createElement(Bar, nil, p.text), v.createElement(LegacyHiddenDiv, {
				mode = "hidden"
			}, v.createElement(Middle, nil, p.text)), v.createElement(Bar, nil, p.text), v.createElement(
				LegacyHiddenDiv,
				{
					mode = "hidden"
				},
				v.createElement(Middle, nil, "Footer")
			))
		end

		v2.render(v.createElement(Foo, {
			text = "foo"
		}))
		expect(v3).toFlushAndYield({
			"Foo",
			"Bar",
			"Bar",
			"Middle",
			"Middle"
		})
		v2.render(v.createElement(Foo, {
			text = "bar"
		}))
		expect(v3).toFlushAndYieldThrough({ "Foo", "Bar", "Bar" })
		expect(v3).toFlushAndYield({ "Middle", "Middle" })
	end)
	it("can deprioritize a tree from without dropping work", function()
		local function Bar(p)
			v3.unstable_yieldValue("Bar")
			return v.createElement("div", nil, p.children)
		end

		local function Middle(p)
			v3.unstable_yieldValue("Middle")
			return v.createElement("span", nil, p.children)
		end

		local function Foo(p)
			v3.unstable_yieldValue("Foo")
			return v.createElement("div", nil, v.createElement(Bar, nil, p.text), v.createElement(LegacyHiddenDiv, {
				mode = "hidden"
			}, v.createElement(Middle, nil, p.text)), v.createElement(Bar, nil, p.text), v.createElement(
				LegacyHiddenDiv,
				{
					mode = "hidden"
				},
				v.createElement(Middle, nil, "Footer")
			))
		end

		v2.flushSync(function()
			v2.render(v.createElement(Foo, {
				text = "foo"
			}))
		end)
		expect(v3).toHaveYielded({ "Foo", "Bar", "Bar" })
		expect(v3).toFlushAndYield({ "Middle", "Middle" })
		v2.flushSync(function()
			v2.render(v.createElement(Foo, {
				text = "foo"
			}))
		end)
		expect(v3).toHaveYielded({ "Foo", "Bar", "Bar" })
		expect(v3).toFlushAndYield({ "Middle", "Middle" })
	end)
	it("memoizes work even if shouldComponentUpdate returns false", function()
		local extended = v.Component:extend("Foo")

		function extended.shouldComponentUpdate(p, _)
			local selected = p.props.step ~= 1
			v3.unstable_yieldValue("shouldComponentUpdate: " .. tostring(selected))
			return selected
		end

		function extended.render(_)
			v3.unstable_yieldValue("render")
			return v.createElement("div")
		end

		v2.render(v.createElement(extended, {
			step = 1
		}))
		expect(v3).toFlushAndYield({ "render" })
		v2.render(v.createElement(extended, {
			step = 2
		}))
		expect(v3).toFlushAndYield({ "shouldComponentUpdate: false" })
		v2.render(v.createElement(extended, {
			step = 3
		}))
		expect(v3).toFlushAndYield({ "shouldComponentUpdate: true", "render" })
	end)
	it("can update in the middle of a tree using setState", function()
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended:init()
			self.state = {
				a = "a"
			}
			v5 = self
		end

		function extended.render(p)
			return v.createElement("div", nil, p.props.children)
		end

		local function Foo()
			return v.createElement("div", nil, v.createElement(extended))
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushWithoutYielding()
		expect(v5.state).toEqual({
			a = "a"
		})
		v5:setState({
			b = "b"
		})
		expect(v3).toFlushWithoutYielding()
		expect(v5.state).toEqual({
			a = "a",
			b = "b"
		})
	end)
	it("can queue multiple state updates", function()
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended:init()
			self.state = {
				a = "a"
			}
			v5 = self
		end

		function extended.render(p)
			return v.createElement("div", nil, p.props.children)
		end

		local function Foo()
			return v.createElement("div", nil, v.createElement(extended))
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushWithoutYielding()
		v5:setState({
			b = "b"
		})
		v5:setState({
			c = "c"
		})
		v5:setState({
			d = "d"
		})
		expect(v3).toFlushWithoutYielding()
		expect(v5.state).toEqual({
			a = "a",
			b = "b",
			c = "c",
			d = "d"
		})
	end)
	it("can use updater form of setState", function()
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended:init()
			self.state = {
				num = 1
			}
			v5 = self
		end

		function extended.render(p)
			return v.createElement("div", nil, p.props.children)
		end

		local function Foo(p)
			return v.createElement("div", nil, v.createElement(extended, {
				multiplier = p.multiplier
			}))
		end

		local function updater(p, p2)
			return {
				num = p.num * p2.multiplier
			}
		end

		v2.render(v.createElement(Foo, {
			multiplier = 2
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v5.state.num).toEqual(1)
		v5:setState(updater)
		expect(v3).toFlushWithoutYielding()
		expect(v5.state.num).toEqual(2)
		v5:setState(updater)
		v2.render(v.createElement(Foo, {
			multiplier = 3
		}))
		expect(v3).toFlushWithoutYielding()
		expect(v5.state.num).toEqual(6)
	end)
	it("can call setState inside update callback", function()
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended:init()
			self.state = {
				num = 1
			}
			v5 = self
		end

		function extended.render(p)
			return v.createElement("div", nil, p.props.children)
		end

		local function Foo(p)
			local multiplier = p.multiplier
			return v.createElement("div", nil, v.createElement(extended, {
				multiplier = multiplier
			}))
		end

		local function updater(p, p2)
			return {
				num = p.num * p2.multiplier
			}
		end

		local function callback()
			v5:setState({
				called = true
			})
		end

		v2.render(v.createElement(Foo, {
			multiplier = 2
		}))
		expect(v3).toFlushWithoutYielding()
		v5:setState(updater)
		v5:setState(updater, callback)
		expect(v3).toFlushWithoutYielding()
		expect(v5.state.num).toEqual(4)
		expect(v5.state.called).toEqual(true)
	end)
	it("can replaceState", function()
		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended.render(p)
			v5 = p
			return v.createElement("div", nil, p.props.children)
		end

		local function Foo()
			return v.createElement("div", nil, v.createElement(extended))
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushWithoutYielding()
		v5:setState({
			b = "b"
		})
		v5:setState({
			c = "c"
		})
		v5.__updater.enqueueReplaceState(v5, {
			d = "d"
		})
		expect(v3).toFlushWithoutYielding()
		expect(v5.state).toEqual({
			d = "d"
		})
	end)
	it("can forceUpdate", function()
		local function Baz()
			v3.unstable_yieldValue("Baz")
			return v.createElement("div")
		end

		local v5 = nil
		local extended = v.Component:extend("Bar")

		function extended.init(p)
			v5 = p
		end

		function extended.shouldComponentUpdate(_)
			return false
		end

		function extended.render(_)
			v3.unstable_yieldValue("Bar")
			return v.createElement(Baz)
		end

		local function Foo()
			v3.unstable_yieldValue("Foo")
			return v.createElement("div", nil, v.createElement(extended))
		end

		v2.render(v.createElement(Foo))
		expect(v3).toFlushAndYield({ "Foo", "Bar", "Baz" })
		v5:forceUpdate()
		expect(v3).toFlushAndYield({ "Bar", "Baz" })
	end)
	it("should clear forceUpdate after update is flushed", function()
		local v5 = 0
		local extended = v.PureComponent:extend("Foo")

		function extended.render(p)
			local v6 = string.format("A: %s, B: %s", tostring(v5), p.props.b)
			v3.unstable_yieldValue(v6)
			return v6
		end

		local ref = v.createRef()
		v2.render(v.createElement(extended, {
			ref = ref,
			b = 0
		}))
		expect(v3).toFlushAndYield({ "A: 0, B: 0" })
		v5 = 1
		ref.current:forceUpdate()
		expect(v3).toFlushAndYield({ "A: 1, B: 0" })
		v2.render(v.createElement(extended, {
			ref = ref,
			b = 0
		}))
		expect(v3).toFlushAndYield({})
	end)
	it("calls getDerivedStateFromProps even for state-only updates", function()
		local v5 = nil
		local extended = v.Component:extend("LifeCycle")

		function extended.init(object)
			object:setState({})
		end

		function extended.getDerivedStateFromProps(_, _)
			v3.unstable_yieldValue("getDerivedStateFromProps")
			return {
				foo = "foo"
			}
		end

		function extended:changeState()
			self:setState({
				foo = "bar"
			})
		end

		function extended.componentDidUpdate(_)
			v3.unstable_yieldValue("componentDidUpdate")
		end

		function extended.render(p)
			v3.unstable_yieldValue("render")
			v5 = p
			return nil
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndYield({ "getDerivedStateFromProps", "render" })
		expect(v5.state).toEqual({
			foo = "foo"
		})
		v5:changeState()
		expect(v3).toFlushAndYield({ "getDerivedStateFromProps", "render", "componentDidUpdate" })
		expect(v5.state).toEqual({
			foo = "foo"
		})
	end)
	it("does not call getDerivedStateFromProps if neither state nor props have changed", function()
		local extended = v.Component:extend("Child")

		function extended.render(p)
			v3.unstable_yieldValue("Child")
			return p.props.parentRenders
		end

		local ref = v.createRef()
		local extended2 = v.Component:extend("Parent")

		function extended2:init()
			self.state = {
				parentRenders = 0
			}
		end

		function extended2.getDerivedStateFromProps(_, p)
			v3.unstable_yieldValue("getDerivedStateFromProps")
			return {
				parentRenders = p.parentRenders .. 1
			}
		end

		function extended2.render(p)
			v3.unstable_yieldValue("Parent")
			return v.createElement(extended, {
				parentRenders = p.state.parentRenders,
				ref = ref
			})
		end

		v2.render(v.createElement(extended2))
		expect(v3).toFlushAndYield({ "getDerivedStateFromProps", "Parent", "Child" })
		ref.current:setState({})
		expect(v3).toFlushAndYield({ "Child" })
	end)
	it("can nest batchedUpdates", function()
		local v5 = nil
		local extended = v.Component:extend("Foo")

		function extended.render(p)
			v5 = p
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()
		v2.flushSync(function()
			v2.batchedUpdates(function()
				v5:setState({
					n = 1
				}, function()
					return v3.unstable_yieldValue("setState 1")
				end)
				v5:setState({
					n = 2
				}, function()
					return v3.unstable_yieldValue("setState 2")
				end)
				v2.batchedUpdates(function()
					v5:setState({
						n = 3
					}, function()
						return v3.unstable_yieldValue("setState 3")
					end)
					v5:setState({
						n = 4
					}, function()
						return v3.unstable_yieldValue("setState 4")
					end)
					v3.unstable_yieldValue("end inner batchedUpdates")
				end)
				v3.unstable_yieldValue("end outer batchedUpdates")
			end)
		end)
		expect(v3).toHaveYielded({
			"end inner batchedUpdates",
			"end outer batchedUpdates",
			"setState 1",
			"setState 2",
			"setState 3",
			"setState 4"
		})
		expect(v5.state.n).toEqual(4)
	end)
	it("can handle if setState callback throws", function()
		local v5 = nil
		local extended = v.Component:extend("Foo")

		function extended:init()
			self.state = {
				n = 0
			}
		end

		function extended.render(p)
			v5 = p
			return v.createElement("div")
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushWithoutYielding()

		local function updater(p)
			return {
				n = p.n + 1
			}
		end

		v5:setState(updater, function()
			return v3.unstable_yieldValue("first callback")
		end)
		v5:setState(updater, function()
			v3.unstable_yieldValue("second callback")
			error("callback error")
		end)
		v5:setState(updater, function()
			return v3.unstable_yieldValue("third callback")
		end)
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toThrow("callback error")
		expect(v3).toHaveYielded({ "first callback", "second callback" })
		expect(v5.state.n).toEqual(3)
	end)
	it.skip("merges and masks context", function()
		local extended = v.Component:extend("Intl")

		function extended.getChildContext(p)
			return {
				locale = p.props.locale
			}
		end

		function extended.render(p)
			v3.unstable_yieldValue("Intl " .. JSONStringify(p.context))
			return p.props.children
		end

		extended.childContextTypes = {
			locale = ""
		}
		local extended2 = v.Component:extend("Router")

		function extended2.getChildContext(p)
			return {
				route = p.props.route
			}
		end

		function extended2.render(p)
			v3.unstable_yieldValue("Router " .. JSONStringify(p.context))
			return p.props.children
		end

		extended2.childContextTypes = {
			route = ""
		}
		local extended3 = v.Component:extend("ShowLocale")

		function extended3.render(p)
			v3.unstable_yieldValue("ShowLocale " .. JSONStringify(p.context))
			return p.context.locale
		end

		extended3.contextTypes = {
			locale = ""
		}
		local extended4 = v.Component:extend("ShowRoute")

		function extended4.render(p)
			v3.unstable_yieldValue("ShowRoute " .. JSONStringify(p.context))
			return p.context.route
		end

		extended4.contextTypes = {
			route = ""
		}

		local function ShowBoth(_, state)
			v3.unstable_yieldValue("ShowBoth " .. JSONStringify(state))
			state.locale = state.locale or ""
			state.route = state.route or ""
			return string.format("%s in %s", state.route, state.locale)
		end

		local extended5 = v.Component:extend("ShowNeither")

		function extended5.render(p)
			v3.unstable_yieldValue("ShowNeither " .. JSONStringify(p.context))
			return nil
		end

		local extended6 = v.Component:extend("Indirection")

		function extended6.render(p)
			v3.unstable_yieldValue("Indirection " .. JSONStringify(p.context))
			return {
				v.createElement(extended3, {
					key = "a"
				}),
				v.createElement(extended4, {
					key = "b"
				}),
				v.createElement(extended5, {
					key = "c"
				}),
				v.createElement(extended, {
					key = "d",
					locale = "ru"
				}, v.createElement(ShowBoth, nil)),
				v.createElement(ShowBoth, {
					key = "e"
				})
			}
		end

		v2.render(v.createElement(extended, {
			locale = "fr"
		}, v.createElement(extended3), v.createElement("div", nil, v.createElement(ShowBoth))))
		expect(function()
			return expect(v3).toFlushAndYield({
				"Intl {}",
				"ShowLocale {\"locale\":\"fr\"}",
				"ShowBoth {\"locale\":\"fr\"}"
			})
		end).toErrorDev([[
Warning: Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Intl, ShowLocale]])
		v2.render(v.createElement(extended, {
			locale = "de"
		}, v.createElement(extended3), v.createElement("div", nil, v.createElement(ShowBoth))))
		expect(v3).toFlushAndYield({ "Intl {}", "ShowLocale {\"locale\":\"de\"}", "ShowBoth {\"locale\":\"de\"}" })
		v2.render(v.createElement(extended, {
			locale = "sv"
		}, v.createElement(extended3), v.createElement("div", nil, v.createElement(ShowBoth))))
		expect(v3).toFlushAndYieldThrough({ "Intl {}" })
		v2.render(v.createElement(extended, {
			locale = "en"
		}, v.createElement(extended3), v.createElement(extended2, {
			route = "/about"
		}, v.createElement(extended6)), v.createElement(ShowBoth)))
		expect(function()
			return expect(v3).toFlushAndYield({
				"ShowLocale {\"locale\":\"sv\"}",
				"ShowBoth {\"locale\":\"sv\"}",
				"Intl {}",
				"ShowLocale {\"locale\":\"en\"}",
				"Router {}",
				"Indirection {}",
				"ShowLocale {\"locale\":\"en\"}",
				"ShowRoute {\"route\":\"/about\"}",
				"ShowNeither {}",
				"Intl {}",
				"ShowBoth {\"route\":\"/about\",\"locale\":\"ru\"}",
				"ShowBoth {\"route\":\"/about\",\"locale\":\"en\"}",
				"ShowBoth {\"locale\":\"en\"}"
			})
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Router, ShowRoute]])
	end)
	it("does not leak own context into context provider", function()
		local extended = v.Component:extend("Recurse")

		function extended.getChildContext(p)
			return {
				n = (p.context.n or 3) - 1
			}
		end

		function extended.render(p)
			v3.unstable_yieldValue("Recurse " .. JSONStringify(p.context))

			if p.context.n == 0 then
				return nil
			end

			return v.createElement(extended)
		end

		extended.contextTypes = {
			n = v4.number
		}
		extended.childContextTypes = {
			n = v4.number
		}
		v2.render(v.createElement(extended))
		expect(function()
			return expect(v3).toFlushAndYield({
				"Recurse {}",
				"Recurse {\"n\":2}",
				"Recurse {\"n\":1}",
				"Recurse {\"n\":0}"
			})
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Recurse]])
	end)

	if not reactFeatureFlags.disableModulePatternComponents then
		xit("does not leak own context into context provider (factory components)", function()
			local Recurse

			Recurse = function(_, p)
				return {
					getChildContext = function()
						return {
							n = (p.n or 3) - 1
						}
					end,
					render = function()
						v3.unstable_yieldValue("Recurse " .. JSONStringify(p))

						if p.n == 0 then
							return nil
						end

						return v.createElement(Recurse)
					end
				}
			end

			v2.render(v.createElement(Recurse))
			expect(function()
				return expect(v3).toFlushAndYield({
					"Recurse {}",
					"Recurse {\"n\":2}",
					"Recurse {\"n\":1}",
					"Recurse {\"n\":0}"
				})
			end).toErrorDev({
				"Warning: The <Recurse /> component appears to be a function component that returns a class instance. Change Recurse to a class that extends React.Component instead. If you can't use a class try assigning the prototype on the function as a workaround. `Recurse.prototype = React.Component.prototype`. Don't use an arrow function since it cannot be called with `new` by React.",
				[[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Recurse]]
			})
		end)
	end

	it("provides context when reusing work", function()
		local extended = v.Component:extend("Intl")

		function extended.getChildContext(p)
			return {
				locale = p.props.locale
			}
		end

		function extended.render(p)
			v3.unstable_yieldValue("Intl " .. JSONStringify(p.context))
			return p.props.children
		end

		extended.childContextTypes = {
			locale = v4.string
		}
		local extended2 = v.Component:extend("ShowLocale")

		function extended2.render(p)
			v3.unstable_yieldValue("ShowLocale " .. JSONStringify(p.context))
			return p.context.locale
		end

		extended2.contextTypes = {
			locale = v4.string
		}
		v2.render(v.createElement(extended, {
			locale = "fr"
		}, v.createElement(extended2), v.createElement(LegacyHiddenDiv, {
			mode = "hidden"
		}, v.createElement(extended2), v.createElement(extended, {
			locale = "ru"
		}, v.createElement(extended2))), v.createElement(extended2)))
		expect(v3).toFlushAndYieldThrough({
			"Intl {}",
			"ShowLocale {\"locale\":\"fr\"}",
			"ShowLocale {\"locale\":\"fr\"}"
		})
		expect(function()
			return expect(v3).toFlushAndYield({
				"ShowLocale {\"locale\":\"fr\"}",
				"Intl {}",
				"ShowLocale {\"locale\":\"ru\"}"
			})
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Intl, ShowLocale]])
	end)
	xit("reads context when setState is below the provider", function()
		local v5 = nil
		local extended = v.Component:extend("Intl")

		function extended.getChildContext(p)
			local v6 = {
				locale = p.props.locale
			}
			v3.unstable_yieldValue("Intl:provide " .. JSONStringify(v6))
			return v6
		end

		function extended.render(p)
			v3.unstable_yieldValue("Intl:read " .. JSONStringify(p.context))
			return p.props.children
		end

		extended.childContextTypes = {
			locale = ""
		}
		local extended2 = v.Component:extend("ShowLocaleClass")

		function extended2.render(p)
			v3.unstable_yieldValue("ShowLocaleClass:read " .. JSONStringify(p.context))
			return p.context.locale
		end

		extended2.contextTypes = {
			locale = ""
		}

		local function ShowLocaleFn(_, p)
			p.locale = p.locale or ""
			v3.unstable_yieldValue("ShowLocaleFn:read " .. JSONStringify(p))
			return p.locale
		end

		local extended3 = v.Component:extend("Stateful")

		function extended3.render(p)
			v5 = p
			return p.props.children
		end

		local function IndirectionFn(p, p2)
			v3.unstable_yieldValue("IndirectionFn " .. JSONStringify(p2))
			return p.children
		end

		local extended4 = v.Component:extend("IndirectionClass")

		function extended4.render(p)
			v3.unstable_yieldValue("IndirectionClass " .. JSONStringify(p.context))
			return p.props.children
		end

		v2.render(v.createElement(extended, {
			locale = "fr"
		}, v.createElement(
			IndirectionFn,
			nil,
			v.createElement(
				extended4,
				nil,
				v.createElement(extended3, nil, v.createElement(extended2), v.createElement(ShowLocaleFn))
			)
		)))
		expect(function()
			return expect(v3).toFlushAndYield({
				"Intl:read {}",
				"Intl:provide {\"locale\":\"fr\"}",
				"IndirectionFn {}",
				"IndirectionClass {}",
				"ShowLocaleClass:read {\"locale\":\"fr\"}",
				"ShowLocaleFn:read {\"locale\":\"fr\"}"
			})
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Intl, ShowLocaleClass, ShowLocaleFn]])
		v5:setState({
			x = 1
		})
		expect(v3).toFlushWithoutYielding()
		expect(v3).toHaveYielded({})
	end)
	xit("reads context when setState is above the provider", function()
		local v5 = nil
		local extended = v.Component:extend("Intl")

		function extended.getChildContext(p)
			local v6 = {
				locale = p.props.locale
			}
			v3.unstable_yieldValue("Intl:provide " .. JSONStringify(v6))
			return v6
		end

		function extended.render(p)
			v3.unstable_yieldValue("Intl:read " .. JSONStringify(p.context))
			return p.props.children
		end

		extended.childContextTypes = {
			locale = ""
		}
		local extended2 = v.Component:extend("ShowLocaleClass")

		function extended2.render(p)
			v3.unstable_yieldValue("ShowLocaleClass:read " .. JSONStringify(p.context))
			return p.context.locale
		end

		extended2.contextTypes = {
			locale = ""
		}

		local function ShowLocaleFn(_, p)
			p.locale = p.locale or ""
			v3.unstable_yieldValue("ShowLocaleFn:read " .. JSONStringify(p))
			return p.locale
		end

		local function IndirectionFn(p, p2)
			v3.unstable_yieldValue("IndirectionFn " .. JSONStringify(p2))
			return p.children
		end

		local extended3 = v.Component:extend("IndirectionClass")

		function extended3.render(p)
			v3.unstable_yieldValue("IndirectionClass " .. JSONStringify(p.context))
			return p.props.children
		end

		local extended4 = v.Component:extend("Stateful")

		function extended4:init()
			self.state = {
				locale = "fr"
			}
		end

		function extended4.render(p)
			v5 = p
			return v.createElement(extended, {
				locale = p.state.locale
			}, p.props.children)
		end

		v2.render(v.createElement(
			extended4,
			nil,
			v.createElement(
				IndirectionFn,
				nil,
				v.createElement(extended3, nil, v.createElement(extended2), v.createElement(ShowLocaleFn))
			)
		))
		expect(function()
			return expect(v3).toFlushAndYield({
				"Intl:read {}",
				"Intl:provide {\"locale\":\"fr\"}",
				"IndirectionFn {}",
				"IndirectionClass {}",
				"ShowLocaleClass:read {\"locale\":\"fr\"}",
				"ShowLocaleFn:read {\"locale\":\"fr\"}"
			})
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Intl, ShowLocaleClass, ShowLocaleFn]])
		v5:setState({
			locale = "gr"
		})
		expect(v3).toFlushAndYield({
			"Intl:read {}",
			"Intl:provide {\"locale\":\"gr\"}",
			"IndirectionFn {}",
			"IndirectionClass {}",
			"ShowLocaleClass:read {\"locale\":\"gr\"}",
			"ShowLocaleFn:read {\"locale\":\"gr\"}"
		})
	end)
	it("maintains the correct context when providers bail out due to low priority", function()
		local extended = v.Component:extend("Child")

		function extended.getChildContext(_)
			return {}
		end

		function extended.render(_)
			return v.createElement("div")
		end

		local v5 = nil
		local extended2 = v.Component:extend("Middle")

		function extended2.init(p, _, _)
			v5 = p
		end

		function extended2.shouldComponentUpdate(_)
			return false
		end

		function extended2.render(_)
			return v.createElement(extended)
		end

		local extended3 = v.Component:extend("Root")

		function extended3.render(p)
			return v.createElement(extended2, p.props)
		end

		extended.childContextTypes = {}
		v2.render(v.createElement(extended3))
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Child]])
		v5:setState({})
		expect(v3).toFlushWithoutYielding()
	end)
	it("maintains the correct context when unwinding due to an error in render", function()
		local extended = v.Component:extend("ContextProvider")
		local extended2 = v.Component:extend("Root")

		function extended2.componentDidCatch(_, _) end

		function extended2.render(_)
			return v.createElement(extended, {
				depth = 1
			})
		end

		local v5 = nil

		function extended:init(p2, _)
			self.state = {}

			if p2.depth == 1 then
				v5 = self
			end
		end

		extended.childContextTypes = {}

		function extended.getChildContext(_)
			return {}
		end

		function extended.render(p)
			if p.state.throwError then
				error(error2.new())
			end

			return (function()
				if p.props.depth < 4 then
					return v.createElement(extended, {
						depth = p.props.depth + 1
					})
				end

				return v.createElement(function()
					return nil
				end)
			end)()
		end

		v2.render(v.createElement(extended2))
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: ContextProvider]])
		v5:setState({
			throwError = true
		})
		expect(function()
			return expect(v3).toFlushWithoutYielding()
		end).toErrorDev("Error boundaries should implement getDerivedStateFromError()")
	end)
	it("should not recreate masked context unless inputs have changed", function()
		local count = 0
		local extended = v.Component:extend("MyComponent")
		extended.contextTypes = {}

		function extended.componentDidMount(object)
			v3.unstable_yieldValue("componentDidMount")
			object:setState({
				setStateInCDU = true
			})
		end

		function extended.componentDidUpdate(object, _, _)
			v3.unstable_yieldValue("componentDidUpdate")

			if object.state.setStateInCDU then
				object:setState({
					setStateInCDU = false
				})
			end
		end

		function extended.UNSAFE_componentWillReceiveProps(object, _)
			v3.unstable_yieldValue("componentWillReceiveProps")
			object:setState({
				setStateInCDU = true
			})
		end

		function extended.render(_)
			v3.unstable_yieldValue("render")
			return nil
		end

		function extended.shouldComponentUpdate(_, _, _)
			v3.unstable_yieldValue("shouldComponentUpdate")
			local v5 = count < 5
			count += 1
			return v5
		end

		v2.render(v.createElement(extended))
		expect(function()
			return expect(v3).toFlushAndYield({
				"render",
				"componentDidMount",
				"shouldComponentUpdate",
				"render",
				"componentDidUpdate",
				"shouldComponentUpdate",
				"render",
				"componentDidUpdate"
			})
		end).toErrorDev({ "Using UNSAFE_componentWillReceiveProps in strict mode is not recommended", [[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: MyComponent]] }, {
			withoutStack = 1
		})
	end)
	xit("updates descendants with new context values", function()
		local v5 = nil
		local extended = v.Component:extend("TopContextProvider")

		function extended:init()
			function self.getChildContext()
				return {
					count = self.state.count
				}
			end

			function self.render()
				return self.props.children
			end

			function self.updateCount()
				return self:setState(function(p)
					return {
						count = p.count + 1
					}
				end)
			end

			self.state = {
				count = 0
			}
			v5 = self
		end

		extended.childContextTypes = {
			count = v4.number
		}
		local extended2 = v.Component:extend("Middle")
		local extended3 = v.Component:extend("Child")
		extended3.contextTypes = {
			count = v4.number
		}
		v2.render(v.createElement(extended, nil, v.createElement(extended2, nil, v.createElement(extended3))))
		expect(function()
			return expect(v3).toFlushAndYield({ "count:0" })
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Child, TopContextProvider]])
		v5.updateCount()
		expect(v3).toFlushAndYield({ "count:1" })
	end)
	xit("updates descendants with multiple context-providing ancestors with new context values", function()
		local v5 = nil
		local extended = v.Component:extend("TopContextProvider")

		function extended:init()
			function self.getChildContext()
				return {
					count = self.state.count
				}
			end

			function self.render()
				return self.props.children
			end

			function self.updateCount()
				return self:setState(function(p)
					return {
						count = p.count + 1
					}
				end)
			end

			self.state = {
				count = 0
			}
			v5 = self
		end

		extended.childContextTypes = {
			count = v4.number
		}
		local extended2 = v.Component:extend("MiddleContextProvider")
		extended2.childContextTypes = {
			name = v4.string
		}
		local extended3 = v.Component:extend("Child")
		extended3.contextTypes = {
			count = v4.number
		}
		v2.render(v.createElement(extended, nil, v.createElement(extended2, nil, v.createElement(extended3))))
		expect(function()
			return expect(v3).toFlushAndYield({ "count:0" })
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Child, MiddleContextProvider, TopContextProvider]])
		v5.updateCount()
		expect(v3).toFlushAndYield({ "count:1" })
	end)
	xit("should not update descendants with new context values if shouldComponentUpdate returns false", function()
		local v5 = nil
		local extended = v.Component:extend("TopContextProvider")

		function extended:init()
			function self.getChildContext()
				return {
					count = self.state.count
				}
			end

			function self.render()
				return self.props.children
			end

			function self.updateCount()
				return self:setState(function(p)
					return {
						count = p.count + 1
					}
				end)
			end

			self.state = {
				count = 0
			}
			v5 = self
		end

		extended.childContextTypes = {
			count = v4.number
		}
		local extended2 = v.Component:extend("MiddleScu")

		function extended2.shouldComponentUpdate(_)
			return false
		end

		local extended3 = v.Component:extend("MiddleContextProvider")
		extended3.childContextTypes = {
			name = v4.string
		}
		local extended4 = v.Component:extend("Child")
		extended4.contextTypes = {
			count = v4.number
		}
		v2.render(v.createElement(
			extended,
			nil,
			v.createElement(extended2, nil, v.createElement(extended3, nil, v.createElement(extended4)))
		))
		expect(function()
			return expect(v3).toFlushAndYield({ "count:0" })
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Child, MiddleContextProvider, TopContextProvider]])
		v5.updateCount()
		expect(v3).toFlushWithoutYielding()
	end)
	xit(
		"should update descendants with new context values if setState() is called in the middle of the tree",
		function()
			local v5 = nil
			local v6 = nil
			local extended = v.Component:extend("TopContextProvider")

			function extended:init()
				function self.getChildContext()
					return {
						count = self.state.count
					}
				end

				function self.render()
					return self.props.children
				end

				function self.updateCount()
					return self:setState(function(p)
						return {
							count = p.count + 1
						}
					end)
				end

				self.state = {
					count = 0
				}
				v6 = self
			end

			extended.childContextTypes = {
				count = v4.number
			}
			local extended2 = v.Component:extend("MiddleScu")

			function extended2.shouldComponentUpdate(_)
				return false
			end

			local extended3 = v.Component:extend("MiddleContextProvider")

			function extended3:init()
				function self.getChildContext()
					return {
						name = self.state.name
					}
				end

				function self.updateName(name)
					self:setState({
						name = name
					})
				end

				function self.render()
					return self.props.children
				end

				self.state = {
					name = "brian"
				}
				v5 = self
			end

			extended3.childContextTypes = {
				name = v4.string
			}
			local extended4 = v.Component:extend("Child")
			extended4.contextTypes = {
				count = v4.number,
				name = v4.string
			}
			v2.render(v.createElement(
				extended,
				nil,
				v.createElement(extended2, nil, v.createElement(extended3, nil, v.createElement(extended4)))
			))
			expect(function()
				return expect(v3).toFlushAndYield({ "count:0, name:brian" })
			end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: Child, MiddleContextProvider, TopContextProvider]])
			v6.updateCount()
			expect(v3).toFlushWithoutYielding()
			v5.updateName("not brian")
			expect(v3).toFlushAndYield({ "count:1, name:not brian" })
		end
	)
	it("does not interrupt for update at same priority", function()
		local function Child(p)
			v3.unstable_yieldValue("Child: " .. tostring(p.step))
			return nil
		end

		local function Parent(p)
			v3.unstable_yieldValue("Parent: " .. tostring(p.step))
			return v.createElement(Child, {
				step = p.step
			})
		end

		v2.render(v.createElement(Parent, {
			step = 1
		}))
		expect(v3).toFlushAndYieldThrough({ "Parent: 1" })
		v2.render(v.createElement(Parent, {
			step = 2
		}))
		expect(v3).toFlushAndYield({ "Child: 1", "Parent: 2", "Child: 2" })
	end)
	it("does not interrupt for update at lower priority", function()
		local function Child(p)
			v3.unstable_yieldValue("Child: " .. tostring(p.step))
			return nil
		end

		local function Parent(p)
			v3.unstable_yieldValue("Parent: " .. tostring(p.step))
			return v.createElement(Child, {
				step = p.step
			})
		end

		v2.render(v.createElement(Parent, {
			step = 1
		}))
		expect(v3).toFlushAndYieldThrough({ "Parent: 1" })
		v2.expire(2000)
		v2.render(v.createElement(Parent, {
			step = 2
		}))
		expect(v3).toFlushAndYield({ "Child: 1", "Parent: 2", "Child: 2" })
	end)
	it("does interrupt for update at higher priority", function()
		local function Child(p)
			v3.unstable_yieldValue("Child: " .. tostring(p.step))
			return nil
		end

		local function Parent(p)
			v3.unstable_yieldValue("Parent: " .. tostring(p.step))
			return v.createElement(Child, {
				step = p.step
			})
		end

		v2.render(v.createElement(Parent, {
			step = 1
		}))
		expect(v3).toFlushAndYieldThrough({ "Parent: 1" })
		v2.flushSync(function()
			return v2.render(v.createElement(Parent, {
				step = 2
			}))
		end)
		expect(v3).toHaveYielded({ "Parent: 2", "Child: 2" })
		expect(v3).toFlushAndYield({})
	end)
end)