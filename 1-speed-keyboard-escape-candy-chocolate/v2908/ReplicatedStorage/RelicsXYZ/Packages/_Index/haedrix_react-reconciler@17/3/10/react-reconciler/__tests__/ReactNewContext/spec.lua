local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local error2 = LuauPolyfill.Error
local v = nil
local useContext = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local it = JestGlobals.it
local describe = JestGlobals.describe
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local React = require(parent.React)
	v = React
	useContext = v.useContext
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function span(prop)
	return {
		type = "span",
		prop = prop,
		children = {},
		hidden = false
	}
end

local function Text(p)
	v3.unstable_yieldValue(p.text)
	return v.createElement("span", {
		prop = p.text
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readContext(p, p2)
	return v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current.readContext(p, p2)
end

local function LegacyHiddenDiv(p)
	local children = p.children
	local mode = p.mode
	return v.createElement("div", {
		hidden = mode == "hidden"
	}, v.createElement(v.unstable_LegacyHidden, {
		mode = mode == "hidden" and "unstable-defer-without-hiding" or mode
	}, children))
end

local function sharedContextTests(p, fn)
	describe("reading context with " .. p, function()
		it("simple mount and update", function()
			local context = v.createContext(1)
			local v4 = fn(context)
			local fragment = v.Fragment

			local function App(p2)
				return v.createElement(context.Provider, {
					value = p2.value
				}, v.createElement(fragment, nil, v.createElement(fragment, nil, v.createElement(v4, nil, function(p3)
					return v.createElement("span", {
						prop = "Result: " .. tostring(p3)
					})
				end))))
			end

			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 3") })
		end)
		it("propagates through shouldComponentUpdate false", function()
			local context = v.createContext(1)
			local v4 = fn(context)

			local function Provider(p2)
				v3.unstable_yieldValue("Provider")
				return v.createElement(context.Provider, {
					value = p2.value
				}, p2.children)
			end

			local function Consumer(_)
				v3.unstable_yieldValue("Consumer")
				return v.createElement(v4, nil, function(p2)
					v3.unstable_yieldValue("Consumer render prop")
					return v.createElement("span", {
						prop = "Result: " .. tostring(p2)
					})
				end)
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				v3.unstable_yieldValue("Indirection")
				return p2.props.children
			end

			local function App(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(extended, nil, v.createElement(extended, nil, v.createElement(Consumer))))
			end

			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushAndYield({
				"App",
				"Provider",
				"Indirection",
				"Indirection",
				"Consumer",
				"Consumer render prop"
			})
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushAndYield({ "App", "Provider", "Consumer render prop" })
			expect(v2.getChildren()).toEqual({ span("Result: 3") })
		end)
		it("consumers bail out if context value is the same", function()
			local context = v.createContext(1)
			local v4 = fn(context)

			local function Provider(p2)
				v3.unstable_yieldValue("Provider")
				return v.createElement(context.Provider, {
					value = p2.value
				}, p2.children)
			end

			local function Consumer(_)
				v3.unstable_yieldValue("Consumer")
				return v.createElement(v4, nil, function(p2)
					v3.unstable_yieldValue("Consumer render prop")
					return v.createElement("span", {
						prop = "Result: " .. tostring(p2)
					})
				end)
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				v3.unstable_yieldValue("Indirection")
				return p2.props.children
			end

			local function App(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(extended, nil, v.createElement(extended, nil, v.createElement(Consumer))))
			end

			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushAndYield({
				"App",
				"Provider",
				"Indirection",
				"Indirection",
				"Consumer",
				"Consumer render prop"
			})
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushAndYield({ "App", "Provider" })
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
		end)
		it("nested providers", function()
			local context = v.createContext(1)
			local v4 = fn(context)

			local function Provider(p2)
				return v.createElement(v4, nil, function(p3: number)
					return v.createElement(context.Provider, {
						value = p2.value or p3 * 2
					}, p2.children)
				end)
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				return p2.props.children
			end

			local function App(p2)
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(
					extended,
					nil,
					v.createElement(
						Provider,
						nil,
						v.createElement(
							extended,
							nil,
							v.createElement(
								Provider,
								nil,
								v.createElement(extended, nil, v.createElement(v4, nil, function(p3)
									return v.createElement("span", {
										prop = "Result: " .. tostring(p3)
									})
								end))
							)
						)
					)
				))
			end

			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 8") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 12") })
		end)
		it("should provide the correct (default) values to consumers outside of a provider", function()
			local context = v.createContext({
				value = "foo-initial"
			})
			local context2 = v.createContext({
				value = "bar-initial"
			})
			local v4 = fn(context)
			local v5 = fn(context2)

			local function Verify(list)
				local v6 = list[1]
				expect(list[2]).toBe(v6)
				return nil
			end

			v2.render(v.Fragment, nil, v.createElement(context2.Provider, {
				value = {
					value = "bar-updated"
				}
			}, v.createElement(v5, nil, function(actual)
				return v.createElement(Verify, {
					actual = actual,
					expected = "bar-updated"
				})
			end), v.createElement(context.Provider, {
				value = {
					value = "foo-updated"
				}
			}, v.createElement(v4, nil, function(actual)
				return v.createElement(Verify, {
					actual = actual,
					expected = "foo-updated"
				})
			end))), v.createElement(v4, nil, function(actual)
				return v.createElement(Verify, {
					actual = actual,
					expected = "foo-initial"
				})
			end), v.createElement(v5, nil, function(actual)
				return v.createElement(Verify, {
					actual = actual,
					expected = "bar-initial"
				})
			end))
			expect(v3).toFlushWithoutYielding()
		end)
		it("multiple consumers in different branches", function()
			local context = v.createContext(1)
			local v4 = fn(context)

			local function Provider(p2)
				return v.createElement(context.Consumer, nil, function(p3: number)
					return v.createElement(context.Provider, {
						value = p2.value or p3 * 2
					}, p2.children)
				end)
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				return p2.props.children
			end

			local function App(p2)
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(
					extended,
					nil,
					v.createElement(extended, nil, v.createElement(Provider, nil, v.createElement(v4, nil, function(p3)
						return v.createElement("span", {
							prop = "Result: " .. p3
						})
					end))),
					v.createElement(extended, nil, v.createElement(v4, nil, function(p3)
						return v.createElement("span", {
							prop = "Result: " .. p3
						})
					end))
				))
			end

			v2.render(v.createElement(App, {
				value = 2
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 4"), span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 6"), span("Result: 3") })
			v2.render(v.createElement(App, {
				value = 4
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 8"), span("Result: 4") })
		end)
		it("compares context values with Object.is semantics", function()
			local context = v.createContext(1)
			local v4 = fn(context)

			local function Provider(p2)
				v3.unstable_yieldValue("Provider")
				return v.createElement(context.Provider, {
					value = p2.value
				}, p2.children)
			end

			local function Consumer(_)
				v3.unstable_yieldValue("Consumer")
				return v.createElement(v4, nil, function(p2)
					v3.unstable_yieldValue("Consumer render prop")
					return v.createElement("span", {
						prop = "Result: " .. p2
					})
				end)
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				v3.unstable_yieldValue("Indirection")
				return p2.props.children
			end

			local function App(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(extended, nil, v.createElement(extended, nil, v.createElement(Consumer))))
			end

			v2.render(v.createElement(App, {
				value = "NaN"
			}))
			expect(v3).toFlushAndYield({
				"App",
				"Provider",
				"Indirection",
				"Indirection",
				"Consumer",
				"Consumer render prop"
			})
			expect(v2.getChildren()).toEqual({ span("Result: NaN") })
			v2.render(v.createElement(App, {
				value = "NaN"
			}))
			expect(v3).toFlushAndYield({ "App", "Provider" })
			expect(v2.getChildren()).toEqual({ span("Result: NaN") })
		end)
		it("context unwinds when interrupted", function()
			local context = v.createContext("Default")
			local v4 = fn(context)

			local function Consumer(_)
				return v.createElement(v4, nil, function(p2)
					return v.createElement("span", {
						prop = "Result: " .. p2
					})
				end)
			end

			local function BadRender()
				error(error2.new("Bad render"))
			end

			local extended = v.Component:extend("ErrorBoundary")

			function extended:init()
				self.state = {
					error_ = ""
				}
			end

			function extended.componentDidCatch(p2, error_)
				p2.setState({
					error_ = error_
				})
			end

			function extended.render(p2)
				if p2.state.error_ then
					return nil
				end

				return p2.props.children
			end

			local function App(_)
				return v.createElement(v.Fragment, nil, v.createElement(context.Provider, {
					value = "Does not unwind"
				}, v.createElement(extended, nil, v.createElement(context.Provider, {
					value = "Unwinds after BadRender throws"
				}, v.createElement(BadRender, nil))), v.createElement(Consumer, nil)))
			end

			v2.render(v.createElement(App, {
				value = "A"
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: Does not unwind") })
		end)
		it("does not re-render if there's an update in a child", function()
			local context = v.createContext(0)
			local v4 = fn(context)
			local v5 = nil
			local extended = v.Component:extend("Child")

			function extended:init()
				self.state = {
					step = 0
				}
			end

			function extended.render(p2)
				v3.unstable_yieldValue("Child")
				return v.createElement("span", {
					prop = "Context: " .. tostring(p2.props.context) .. ", Step: " .. tostring(p2.state.step)
				})
			end

			local function App(p2)
				return v.createElement(context.Provider, {
					value = p2.value
				}, v.createElement(v4, nil, function(context2)
					v3.unstable_yieldValue("Consumer render prop")
					return v.createElement(extended, {
						ref = function(p4)
							v5 = p4
							return v5
						end,
						context = context2
					})
				end))
			end

			v2.render(v.createElement(App, {
				value = 1
			}))
			expect(v3).toFlushAndYield({ "Consumer render prop", "Child" })
			expect(v2.getChildren()).toEqual({ span("Context: 1, Step: 0") })
			v5:setState({
				step = 1
			})
			expect(v3).toFlushAndYield({ "Child" })
			expect(v2.getChildren()).toEqual({ span("Context: 1, Step: 1") })
		end)
		it("consumer bails out if value is unchanged and something above bailed out", function()
			local context = v.createContext(0)
			local v4 = fn(context)

			local function renderChildValue(prop)
				v3.unstable_yieldValue("Consumer")
				return v.createElement("span", {
					prop = prop
				})
			end

			local function ChildWithInlineRenderCallback()
				v3.unstable_yieldValue("ChildWithInlineRenderCallback")
				return v.createElement(v4, nil, function(prop)
					return renderChildValue(prop)
				end)
			end

			local function ChildWithCachedRenderCallback()
				v3.unstable_yieldValue("ChildWithCachedRenderCallback")
				return v.createElement(v4, nil, renderChildValue)
			end

			local extended = v.PureComponent:extend("PureIndirection")

			function extended.render(_)
				v3.unstable_yieldValue("PureIndirection")
				return v.createElement(
					v.Fragment,
					nil,
					v.createElement(ChildWithInlineRenderCallback),
					v.createElement(ChildWithCachedRenderCallback)
				)
			end

			local extended2 = v.Component:extend("App")

			function extended2.render(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(context.Provider, {
					value = p2.props.value
				}, v.createElement(extended, nil))
			end

			v2.render(v.createElement(extended2, {
				value = 1
			}))
			expect(v3).toFlushAndYield({
				"App",
				"PureIndirection",
				"ChildWithInlineRenderCallback",
				"Consumer",
				"ChildWithCachedRenderCallback",
				"Consumer"
			})
			expect(v2.getChildren()).toEqual({ span(1), span(1) })
			v2.render(v.createElement(extended2, {
				value = 1
			}))
			expect(v3).toFlushAndYield({ "App" })
			expect(v2.getChildren()).toEqual({ span(1), span(1) })
			v2.render(v.createElement(extended2, {
				value = 2
			}))
			expect(v3).toFlushAndYield({ "App", "Consumer", "Consumer" })
			expect(v2.getChildren()).toEqual({ span(2), span(2) })
		end)
		it("context consumer doesn't bail out inside hidden subtree", function()
			local context = v.createContext("dark")
			local v4 = fn(context)

			local function App(p2)
				local theme = p2.theme
				return v.createElement(context.Provider, {
					value = theme
				}, v.createElement(LegacyHiddenDiv, {
					mode = "hidden"
				}, v.createElement(v4, nil, function(text)
					return v.createElement(Text, {
						text = text
					})
				end)))
			end

			v2.render(v.createElement(App, {
				theme = "dark"
			}))
			expect(v3).toFlushAndYield({ "dark" })
			expect(v2.getChildren()[1].children[1]).toEqual(span("dark"))
			v2.render(v.createElement(App, {
				theme = "light"
			}))
			expect(v3).toFlushAndYield({ "light" })
			expect(v2.getChildren()[1].children[1]).toEqual(span("light"))
		end)
		it("does not run into an infinite loop", function()
			local context = v.createContext(nil)
			local v4 = fn(context)
			local extended = v.Component:extend("App")

			function extended:renderItem(p2)
				return v.createElement("span", {
					key = p2
				}, v.createElement(v4, nil, function()
					return v.createElement("span", nil, "inner")
				end), v.createElement("span", nil, "outer"))
			end

			function extended:renderList()
				local mapped = array.map({ 1, 2 }, function(p2)
					return self:renderItem(p2)
				end)

				if self.props.reverse then
					array.reverse(mapped)
				end

				return mapped
			end

			function extended:render()
				return v.createElement(context.Provider, {
					value = {}
				}, self:renderList())
			end

			v2.render(v.createElement(extended, {
				reverse = false
			}))
			expect(v3).toFlushWithoutYielding()
			v2.render(v.createElement(extended, {
				reverse = true
			}))
			expect(v3).toFlushWithoutYielding()
			v2.render(v.createElement(extended, {
				reverse = false
			}))
			expect(v3).toFlushWithoutYielding()
		end)
		it("does not skip some siblings", function()
			local v4 = nil
			local v5 = nil
			local context = v.createContext(0)
			local v6 = fn(context)
			local extended = v.Component:extend("App")

			function extended:init()
				self.state = {
					step = 0
				}
			end

			function extended.render(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(context.Provider, {
					value = p2.state.step
				}, v.createElement(v4), p2.state.step > 0 and v.createElement(v5))
			end

			v4 = v.PureComponent:extend("StaticContent")

			function v4.render(_)
				return v.createElement(v.Fragment, nil, v.createElement(v.Fragment, nil, v.createElement("span", {
					prop = "static 1"
				}), v.createElement("span", {
					prop = "static 2"
				})))
			end

			v5 = v.PureComponent:extend("Indirection")

			function v5.render(_)
				return (v.createElement(v6, nil, function(prop)
					v3.unstable_yieldValue("Consumer")
					return v.createElement("span", {
						prop = prop
					})
				end))
			end

			local v7 = nil
			v2.render(v.createElement(extended, {
				ref = function(p2)
					v7 = p2
				end
			}))
			expect(v3).toFlushAndYield({ "App" })
			expect(v2.getChildren()).toEqual({ span("static 1"), span("static 2") })
			v7:setState({
				step = 1
			})
			expect(v3).toFlushAndYield({ "App", "Consumer" })
			expect(v2.getChildren()).toEqual({ span("static 1"), span("static 2"), span(1) })
			v7:setState({
				step = 2
			})
			expect(v3).toFlushAndYield({ "App", "Consumer" })
			expect(v2.getChildren()).toEqual({ span("static 1"), span("static 2"), span(2) })
		end)
	end)
	describe("Compatibility with old Roact's Context Consumer API", function()
		it("simple mount and update", function()
			local context = v.createContext(1)
			local consumer = context.Consumer
			local fragment = v.Fragment

			local function App(p2)
				return v.createElement(context.Provider, {
					value = p2.value
				}, v.createElement(fragment, nil, v.createElement(fragment, nil, v.createElement(consumer, {
					render = function(p3)
						return v.createElement("span", {
							prop = "Result: " .. tostring(p3)
						})
					end
				}))))
			end

			expect(function()
				v2.render(v.createElement(App, {
					value = 2
				}))
				expect(v3).toFlushWithoutYielding()
			end).toWarnDev({ "Your Context.Consumer component is using legacy Roact syntax" })
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushWithoutYielding()
			expect(v2.getChildren()).toEqual({ span("Result: 3") })
		end)
		it("propagates through shouldComponentUpdate false", function()
			local context = v.createContext(1)
			local consumer = context.Consumer

			local function Provider(p2)
				v3.unstable_yieldValue("Provider")
				return v.createElement(context.Provider, {
					value = p2.value
				}, p2.children)
			end

			local function Consumer(_)
				v3.unstable_yieldValue("Consumer")
				return v.createElement(consumer, {
					render = function(p2)
						v3.unstable_yieldValue("Consumer render prop")
						return v.createElement("span", {
							prop = "Result: " .. tostring(p2)
						})
					end
				})
			end

			local extended = v.Component:extend("Indirection")

			function extended.shouldComponentUpdate(_)
				return false
			end

			function extended.render(p2)
				v3.unstable_yieldValue("Indirection")
				return p2.props.children
			end

			local function App(p2)
				v3.unstable_yieldValue("App")
				return v.createElement(Provider, {
					value = p2.value
				}, v.createElement(extended, nil, v.createElement(extended, nil, v.createElement(Consumer))))
			end

			expect(function()
				v2.render(v.createElement(App, {
					value = 2
				}))
				expect(v3).toFlushAndYield({
					"App",
					"Provider",
					"Indirection",
					"Indirection",
					"Consumer",
					"Consumer render prop"
				})
			end).toWarnDev({ "Your Context.Consumer component is using legacy Roact syntax" })
			expect(v2.getChildren()).toEqual({ span("Result: 2") })
			v2.render(v.createElement(App, {
				value = 3
			}))
			expect(v3).toFlushAndYield({ "App", "Provider", "Consumer render prop" })
			expect(v2.getChildren()).toEqual({ span("Result: 3") })
		end)
	end)
end

sharedContextTests("Context.Consumer", function(p)
	return p.Consumer
end)
sharedContextTests("useContext inside function component", function(p)
	return function(p2)
		local v4 = useContext(p)
		return p2.children(v4)
	end
end)
sharedContextTests("useContext inside forwardRef component", function(p)
	return v.forwardRef(function(p2, _)
		local v4 = useContext(p)
		return p2.children(v4)
	end)
end)
sharedContextTests("useContext inside memoized function component", function(p)
	return v.memo(function(p2)
		local v4 = useContext(p)
		return p2.children(v4)
	end)
end)
sharedContextTests("readContext(Context) inside class component", function(p)
	local extended = v.Component:extend("Consumer")

	function extended.render(p2)
		local context = readContext(p, nil) -- equivalent call inferred; original call site unknown
		return p2.props.children(context)
	end

	return extended
end)
sharedContextTests("readContext(Context) inside pure class component", function(p)
	local extended = v.PureComponent:extend("Consumer")

	function extended.render(p2)
		local context = readContext(p, nil) -- equivalent call inferred; original call site unknown
		return p2.props.children(context)
	end

	return extended
end)
describe("Context.Provider", function()
	it("warns if no value prop provided", function()
		local context = v.createContext()
		v2.render(v.createElement(context.Provider, {
			anyPropNameOtherThanValue = "value could be anything"
		}))
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toErrorDev("The `value` prop is required for the `<Context.Provider>`. Did you misspell it or forget to pass it?", {
			withoutStack = true
		})
	end)
	it("warns if multiple renderers concurrently render the same context", function()
		local context = v.createContext(0)

		local function Foo(_)
			v3.unstable_yieldValue("Foo")
			return nil
		end

		local function App(p)
			return (v.createElement(context.Provider, {
				value = p.value
			}, { v.createElement(Foo, {
					key = 1
				}), v.createElement(Foo, {
					key = 2
				}) }))
		end

		v2.render(v.createElement(App, {
			value = 1
		}))
		expect(v3).toFlushAndYieldThrough({ "Foo" })
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
		v2.render(v.createElement(App, {
			value = 1
		}))
		expect(function()
			expect(v3).toFlushAndYield({ "Foo", "Foo" })
		end).toErrorDev("Detected multiple renderers concurrently rendering the same context provider. This is currently unsupported")
	end)
	it("provider bails out if children and value are unchanged (like sCU)", function()
		local context = v.createContext(0)

		local function Child()
			v3.unstable_yieldValue("Child")
			return v.createElement("span", {
				prop = "Child"
			})
		end

		local element = v.createElement(Child)

		local function App(p)
			v3.unstable_yieldValue("App")
			return v.createElement(context.Provider, {
				value = p.value
			}, element)
		end

		v2.render(v.createElement(App, {
			value = 1
		}))
		expect(v3).toFlushAndYield({ "App", "Child" })
		expect(v2.getChildren()).toEqual({ span("Child") })
		v2.render(v.createElement(App, {
			value = 1
		}))
		expect(v3).toFlushAndYield({ "App" })
		expect(v2.getChildren()).toEqual({ span("Child") })
	end)
	it("provider does not bail out if legacy context changed above", function()
		local context = v.createContext(0)

		local function Child()
			v3.unstable_yieldValue("Child")
			return v.createElement("span", {
				prop = "Child"
			})
		end

		local element = v.createElement(Child)
		local extended = v.Component:extend("LegacyProvider")
		extended.childContextTypes = {
			legacyValue = function()
				return nil
			end
		}

		function extended:init()
			self.state = {
				legacyValue = 1
			}
		end

		function extended.getChildContext(p)
			return {
				legacyValue = p.state.legacyValue
			}
		end

		function extended.render(p)
			v3.unstable_yieldValue("LegacyProvider")
			return p.props.children
		end

		local extended2 = v.Component:extend("App")

		function extended2:init()
			self.state = {
				value = 1
			}
		end

		function extended2.render(p)
			v3.unstable_yieldValue("App")
			return v.createElement(context.Provider, {
				value = p.state.value
			}, p.props.children)
		end

		local ref = v.createRef()
		local ref2 = v.createRef()
		v2.render(v.createElement(extended, {
			ref = ref
		}, v.createElement(extended2, {
			ref = ref2,
			value = 1
		}, element)))
		expect(function()
			expect(v3).toFlushAndYield({ "LegacyProvider", "App", "Child" })
		end).toErrorDev([[
Legacy context API has been detected within a strict-mode tree.

The old API will be supported in all 16.x releases, but applications using it should migrate to the new version.

Please update the following components: LegacyProvider]])
		expect(v2.getChildren()).toEqual({ span("Child") })
		ref2.current:setState({
			value = 1
		})
		expect(v3).toFlushAndYield({ "App" })
		expect(v2.getChildren()).toEqual({ span("Child") })
		ref.current:setState({
			value = 1
		})
		expect(v3).toFlushAndYield({ "LegacyProvider", "App", "Child" })
		expect(v2.getChildren()).toEqual({ span("Child") })
		ref2.current:setState({
			value = 1
		})
		expect(v3).toFlushAndYield({ "App" })
		expect(v2.getChildren()).toEqual({ span("Child") })
	end)
end)
describe("Context.Consumer", function()
	it("warns if child is not a function", function()
		local context = v.createContext(0)
		v2.render(v.createElement(context.Consumer))
		expect(v3).toFlushAndThrow("attempt to call a nil value")
	end)
	it("can read other contexts inside consumer render prop", function()
		local context = v.createContext(0)
		local context2 = v.createContext(0)

		local function FooAndBar()
			return v.createElement(context.Consumer, nil, function(p)
				local context3 = readContext(context2, nil) -- equivalent call inferred; original call site unknown
				return v.createElement(Text, {
					text = "Foo: " .. tostring(p) .. ", Bar: " .. tostring(context3)
				})
			end)
		end

		local extended = v.Component:extend("Indirection")

		function extended.shouldComponentUpdate(_)
			return false
		end

		function extended.render(p)
			return p.props.children
		end

		local function App(p)
			return v.createElement(context.Provider, {
				value = p.foo
			}, v.createElement(context2.Provider, {
				value = p.bar
			}, v.createElement(extended, nil, v.createElement(FooAndBar))))
		end

		v2.render(v.createElement(App, {
			foo = 1,
			bar = 1
		}))
		expect(v3).toFlushAndYield({ "Foo: 1, Bar: 1" })
		expect(v2.getChildren()).toEqual({ span("Foo: 1, Bar: 1") })
		v2.render(v.createElement(App, {
			foo = 2,
			bar = 1
		}))
		expect(v3).toFlushAndYield({ "Foo: 2, Bar: 1" })
		expect(v2.getChildren()).toEqual({ span("Foo: 2, Bar: 1") })
		v2.render(v.createElement(App, {
			foo = 2,
			bar = 2
		}))
		expect(v3).toFlushAndYield({ "Foo: 2, Bar: 2" })
		expect(v2.getChildren()).toEqual({ span("Foo: 2, Bar: 2") })
	end)
	it("consumer does not bail out if there were no bailouts above it", function()
		local context = v.createContext(0)
		local consumer = context.Consumer
		local extended = v.Component:extend("App")

		function extended:init()
			self.state = {
				text = "hello"
			}
		end

		function extended:renderConsumer(_)
			v3.unstable_yieldValue("App#renderConsumer")
			return v.createElement("span", {
				prop = self.state.text
			})
		end

		function extended:render()
			v3.unstable_yieldValue("App")
			return v.createElement(context.Provider, {
				value = self.props.value
			}, v.createElement(consumer, nil, function(p)
				return self:renderConsumer(p)
			end))
		end

		local v4 = nil
		v2.render(v.createElement(extended, {
			value = 1,
			ref = function(p)
				v4 = p
			end
		}))
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("hello") })
		v4:setState({
			text = "goodbye"
		})
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("goodbye") })
	end)
	it("warns once if using legacy Roact render prop", function()
		local context = v.createContext()

		local function renderContext()
			v2.render(v.createElement(context.Provider, {
				value = 1
			}, v.createElement(context.Consumer, {
				render = function(p)
					return v.createElement("span", {
						prop = "Result: " .. tostring(p)
					})
				end
			})))
		end

		renderContext()
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toWarnDev([[
Warning: Your Context.Consumer component is using legacy Roact syntax, which won't be supported in future versions of Roact. 
Please provide no props and supply the 'render' function as a child (the 3rd argument of createElement). For example: 
       createElement(ContextConsumer, {render = function(...) end})
becomes:
       createElement(ContextConsumer, nil, function(...) end)
For more info, reference the React documentation here: 
https://reactjs.org/docs/context.html#contextconsumer]], {
			withoutStack = true
		})
		v2.render(v.createElement(context.Provider, {
			value = 1
		}, v.createElement(context.Consumer, {
			render = function(p)
				return v.createElement("span", {
					prop = "Result: " .. tostring(p)
				})
			end
		})))
		renderContext()
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toWarnDev({})
	end)
end)
describe("readContext", function()
	it.skip("can read the same context multiple times in the same function", function()
		local context = v.createContext({
			foo = 0,
			bar = 0,
			baz = 0
		}, function(data, data2)
			local v4 = 0

			if data.foo ~= data2.foo then
				v4 = bit32.bor(v4, 1)
			end

			if data.bar ~= data2.bar then
				v4 = bit32.bor(v4, 2)
			end

			if data.baz ~= data2.baz then
				return (bit32.bor(v4, 4))
			end

			return v4
		end)

		local function Provider(props)
			return v.createElement(context.Provider, {
				value = {
					foo = props.foo,
					bar = props.bar,
					baz = props.baz
				}
			}, props.children)
		end

		local function FooAndBar()
			local foo = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current.readContext(
				context,
				1
			).foo
			local bar = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current.readContext(
				context,
				2
			).bar
			return v.createElement(Text, {
				text = "Foo: " .. tostring(foo) .. ", Bar: " .. tostring(bar)
			})
		end

		local function Baz()
			local baz = v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current.readContext(
				context,
				1
			).baz
			return v.createElement(Text, {
				text = "Baz: " .. tostring(baz)
			})
		end

		local extended = v.Component:extend("Indirection")

		function extended.shouldComponentUpdate(_)
			return false
		end

		function extended.render(p)
			return p.props.children
		end

		local function App(props)
			return v.createElement(Provider, {
				foo = props.foo,
				bar = props.bar,
				baz = props.baz
			}, v.createElement(
				extended,
				nil,
				v.createElement(extended, nil, v.createElement(FooAndBar)),
				v.createElement(extended, nil, v.createElement(Baz))
			))
		end

		v2.render(v.createElement(App, {
			foo = 1,
			bar = 1,
			baz = 1
		}))
		expect(v3).toFlushAndYield({ "Foo: 1, Bar: 1", "Baz: 1" })
		expect(v2.getChildren()).toEqual({ span("Foo: 1, Bar: 1"), span("Baz: 1") })
		v2.render(v.createElement(App, {
			foo = 2,
			bar = 1,
			baz = 1
		}))
		expect(v3).toFlushAndYield({ "Foo: 2, Bar: 1" })
		expect(v2.getChildren()).toEqual({ span("Foo: 2, Bar: 1"), span("Baz: 1") })
		v2.render(v.createElement(App, {
			foo = 2,
			bar = 2,
			baz = 1
		}))
		expect(v3).toFlushAndYield({ "Foo: 2, Bar: 2" })
		expect(v2.getChildren()).toEqual({ span("Foo: 2, Bar: 2"), span("Baz: 1") })
		v2.render(v.createElement(App, {
			foo = 2,
			bar = 2,
			baz = 2
		}))
		expect(v3).toFlushAndYield({ "Baz: 2" })
		expect(v2.getChildren()).toEqual({ span("Foo: 2, Bar: 2"), span("Baz: 2") })
	end)
	it("does not bail out if there were no bailouts above it", function()
		local context = v.createContext(0)
		local extended = v.Component:extend("Consumer")

		function extended.render(p)
			local context2 = readContext(context, nil) -- equivalent call inferred; original call site unknown
			return p.props.children(context2)
		end

		local extended2 = v.Component:extend("App")

		function extended2:init()
			self.state = {
				text = "hello"
			}
		end

		function extended2:renderConsumer(_)
			v3.unstable_yieldValue("App#renderConsumer")
			return v.createElement("span", {
				prop = self.state.text
			})
		end

		function extended2:render()
			v3.unstable_yieldValue("App")
			return v.createElement(context.Provider, {
				value = self.props.value
			}, v.createElement(extended, nil, function(p)
				return self:renderConsumer(p)
			end))
		end

		local v4 = nil
		v2.render(v.createElement(extended2, {
			value = 1,
			ref = function(p)
				v4 = p
			end
		}))
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("hello") })
		v4:setState({
			text = "goodbye"
		})
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("goodbye") })
	end)
	it("warns when reading context inside render phase class setState updater", function()
		local context = v.createContext("light")
		local extended = v.Component:extend("Cls")

		function extended:init()
			self.state = {}
		end

		function extended.render(object)
			object:setState(function()
				v.__SECRET_INTERNALS_DO_NOT_USE_OR_YOU_WILL_BE_FIRED.ReactCurrentDispatcher.current.readContext(
					context,
					nil
				)
			end)
			return nil
		end

		v2.render(v.createElement(extended))
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toErrorDev({
			"Context can only be read while React is rendering",
			"Context can only be read while React is rendering",
			"Cannot update during an existing state transition"
		})
	end)
end)
describe("useContext", function()
	it("throws when used in a class component", function()
		local context = v.createContext(0)
		local extended = v.Component:extend("Foo")

		function extended.render(_)
			return useContext(context)
		end

		v2.render(v.createElement(extended))
		expect(v3).toFlushAndThrow([[
Invalid hook call. Hooks can only be called inside of the body of a function component. This could happen for one of the following reasons:
1. You might have mismatching versions of React and the renderer (such as React DOM)
2. You might be breaking the Rules of Hooks
3. You might have more than one copy of React in the same app
See https://reactjs.org/link/invalid-hook-call for tips about how to debug and fix this problem.]])
	end)
	it("warns when passed a consumer", function()
		local context = v.createContext(0)

		local function Foo()
			return useContext(context.Consumer)
		end

		v2.render(v.createElement(Foo))
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toErrorDev("Calling useContext(Context.Consumer) is not supported, may cause bugs, and will be removed in a future major release. Did you mean to call useContext(Context) instead?")
	end)
	it("warns when passed a provider", function()
		local context = v.createContext(0)

		local function Foo()
			useContext(context.Provider)
			return nil
		end

		v2.render(v.createElement(Foo))
		expect(function()
			expect(v3).toFlushWithoutYielding()
		end).toErrorDev("Calling useContext(Context.Provider) is not supported. Did you mean to call useContext(Context) instead?")
	end)
	it("does not bail out if there were no bailouts above it", function()
		local context = v.createContext(0)

		local function Consumer(p)
			return p.children((useContext(context)))
		end

		local extended = v.Component:extend("App")

		function extended:init()
			self.state = {
				text = "hello"
			}
		end

		function extended:renderConsumer(_)
			v3.unstable_yieldValue("App#renderConsumer")
			return v.createElement("span", {
				prop = self.state.text
			})
		end

		function extended:render()
			v3.unstable_yieldValue("App")
			return v.createElement(context.Provider, {
				value = self.props.value
			}, v.createElement(Consumer, nil, function(p)
				return self:renderConsumer(p)
			end))
		end

		local v4 = nil
		v2.render(v.createElement(extended, {
			value = 1,
			ref = function(p)
				v4 = p
			end
		}))
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("hello") })
		v4:setState({
			text = "goodbye"
		})
		expect(v3).toFlushAndYield({ "App", "App#renderConsumer" })
		expect(v2.getChildren()).toEqual({ span("goodbye") })
	end)
end)
it("should warn with an error message when using context as a consumer in DEV", function()
	local context = v.createContext({
		value = "bar-initial"
	})

	local function Component()
		return v.createElement(v.Fragment, nil, v.createElement(context.Provider, {
			value = "bar-updated"
		}, v.createElement(context, nil, function(actual)
			return v.createElement("div", {
				actual = actual,
				expected = "bar-updated"
			})
		end)))
	end

	expect(function()
		v2.render(v.createElement(Component))
		expect(v3).toFlushWithoutYielding()
	end).toErrorDev("Warning: Rendering <Context> directly is not supported and will be removed in a future major release. Did you mean to render <Context.Consumer> instead?")
end)