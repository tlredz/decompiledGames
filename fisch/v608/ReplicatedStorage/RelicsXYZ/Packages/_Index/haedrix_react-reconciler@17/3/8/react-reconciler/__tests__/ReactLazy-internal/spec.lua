local v = nil
local v2 = nil
local v3 = nil
local reactFeatureFlags = nil
local suspense = nil
local lazy = nil
local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
local setTimeout = LuauPolyfill.setTimeout
local Promise = require(parent.Promise)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local jest = JestGlobals.jest

local function normalizeCodeLocInfo(value)
	if typeof(value) ~= "string" then
		return value
	end

	local v4 = string.gsub(value, "Check your code at .*:%d+", "Check your code at **")
	return (string.gsub(v4, [[

    in ([%w%-%._]+)[^
]*]], "\n    in %1 (at **)"))
end

describe("ReactLazy", function()
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = false
		local React = require(parent.React)
		v = React
		suspense = v.Suspense
		lazy = v.lazy
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
	end)

	local function fn(default)
		return Promise.delay(0):andThen(function()
			return {
				default = default
			}
		end)
	end

	local function Text(p)
		v3.unstable_yieldValue(p.text)
		return p.text
	end

	it("suspends until module has loaded", function()
		local v4 = lazy(function()
			return fn(Text)
		end)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			text = "Hi"
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v5).never.toMatchRenderedOutput("Hi")
		Promise.delay(0):await()
		expect(v3).toFlushAndYield({ "Hi" })
		expect(v5).toMatchRenderedOutput("Hi")
		v5.update(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			text = "Hi again"
		})))
		expect(v3).toFlushAndYield({ "Hi again" })
		expect(v5).toMatchRenderedOutput("Hi again")
	end)
	it("can resolve synchronously without suspending", function()
		local v4 = lazy(function()
			return {
				andThen = function(self, callback)
					callback({
						default = Text
					})
				end
			}
		end)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			text = "Hi"
		})))
		expect(v3).toHaveYielded({ "Hi" })
		expect(v5).toMatchRenderedOutput("Hi")
	end)
	it("can reject synchronously without suspending", function()
		local v4 = lazy(function()
			return {
				andThen = function(self, p2, callback)
					callback(error2("oh no"))
				end
			}
		end)
		local extended = v.Component:extend("ErrorBoundary")

		function extended:init()
			self.state = {}
		end

		function extended.getDerivedStateFromError(p)
			return {
				message = p.message
			}
		end

		function extended.render(p)
			if p.state.message then
				return string.format("Error: %s", p.state.message)
			end

			return p.props.children
		end

		local v5 = v2.create(v.createElement(extended, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			text = "Hi"
		}))))
		expect(v3).toHaveYielded({})
		expect(v5).toMatchRenderedOutput("Error: oh no")
	end)
	it("multiple lazy components", function()
		local function Foo()
			return v.createElement(Text, {
				text = "Foo"
			})
		end

		local function Bar()
			return v.createElement(Text, {
				text = "Bar"
			})
		end

		local v4 = 100
		local v5 = Promise.new(function(callback)
			return setTimeout(function()
				return callback()
			end, v4)
		end):andThen(function()
			return fn(Foo)
		end)
		local v6 = 500
		local v7 = Promise.new(function(callback)
			return setTimeout(function()
				return callback()
			end, v6)
		end):andThen(function()
			return fn(Bar)
		end)
		local v8 = lazy(function()
			return v5
		end)
		local v9 = lazy(function()
			return v7
		end)
		local v10 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v8), v.createElement(v9)), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v10).never.toMatchRenderedOutput("FooBar")
		v5:await()
		expect(v3).toFlushAndYield({ "Foo" })
		expect(v10).never.toMatchRenderedOutput("FooBar")
		v7:await()
		expect(v3).toFlushAndYield({ "Foo", "Bar" })
		expect(v10).toMatchRenderedOutput("FooBar")
	end)
	it("throws if promise rejects", function()
		local v4 = lazy(function()
			return Promise.delay(0):andThen(function()
				error(error2("Bad network"))
			end)
		end)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			text = "Hi"
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v5).never.toMatchRenderedOutput("Hi")
		local success, result = pcall(function()
			Promise.delay(0):await()
		end)
		expect(v3).toFlushAndThrow("Bad network")
	end)
	it("mount and reorder", function()
		local extended = v.Component:extend("Child")

		function extended.componentDidMount(p)
			v3.unstable_yieldValue("Did mount: " .. p.props.label)
		end

		function extended.componentDidUpdate(p)
			v3.unstable_yieldValue("Did update: " .. p.props.label)
		end

		function extended.render(p)
			return v.createElement(Text, {
				text = p.props.label
			})
		end

		local v4 = lazy(function()
			return fn(extended)
		end)
		local v5 = lazy(function()
			return fn(extended)
		end)

		local function Parent(p)
			local v6

			if p.swap then
				v6 = { v.createElement(v5, {
						key = "B",
						label = "B"
					}), v.createElement(v4, {
						key = "A",
						label = "A"
					}) }
			else
				v6 = { v.createElement(v4, {
						key = "A",
						label = "A"
					}), v.createElement(v5, {
						key = "B",
						label = "B"
					}) }
			end

			return v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v6)
		end

		local v6 = v2.create(v.createElement(Parent, {
			swap = false
		}), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v6).never.toMatchRenderedOutput("AB")
		Promise.delay(0):await()
		Promise.delay(0):await()
		expect(v3).toFlushAndYield({
			"A",
			"B",
			"Did mount: A",
			"Did mount: B"
		})
		expect(v6).toMatchRenderedOutput("AB")
		v6.update(v.createElement(Parent, {
			swap = true
		}))
		expect(v3).toFlushAndYield({
			"B",
			"A",
			"Did update: B",
			"Did update: A"
		})
		expect(v6).toMatchRenderedOutput("BA")
	end)
	it("throws with a useful error when wrapping invalid type with lazy()", function()
		local v4 = lazy(function()
			return fn(42)
		end)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4)), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		Promise.delay(0):await()
		v5.update(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4)))
		expect(v3).toFlushAndThrow("Element type is invalid. Received a promise that resolves to: 42. Lazy element type must resolve to a class or function.")
	end)
	it("throws with a useful error when wrapping lazy() multiple times", function()
		local default = lazy(function()
			return fn(Text)
		end)
		local v5 = lazy(function()
			return fn(default)
		end)
		local v6 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v5, {
			text = "Hello"
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v6).never.toMatchRenderedOutput("Hello")
		Promise.delay(0):await()
		v6.update(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v5, {
			text = "Hello"
		})))
		local v7 = ReactGlobals.__DEV__ and " Did you wrap a component in React.lazy() more than once?" or ""
		expect(v3).toFlushAndThrow("Lazy element type must resolve to a class or function." .. v7)
	end)
	it("warns about defining propTypes on the outer wrapper", function()
		local v4 = lazy(function()
			return fn(Text)
		end)
		expect(function()
			v4.propTypes = {
				hello = function() end
			}
		end).toErrorDev("React.lazy(...): It is not supported to assign `propTypes` to a lazy component import. Either specify them where the component is defined, or create a wrapping component around it.", {
			withoutStack = true
		})
	end)
	xit("includes lazy-loaded component in warning stack", function()
		local v4 = lazy(function()
			v3.unstable_yieldValue("Started loading")
			return fn(function(p)
				return v.createElement("div", nil, { v.createElement(Text, {
						text = "A"
					}), v.createElement(Text, {
						text = "B"
					}) })
			end)
		end)
		local v5 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4)), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Started loading", "Loading..." })
		expect(v5).never.toMatchRenderedOutput(v.createElement("div", nil, "AB"))
		Promise.delay(0):await()
		expect(function()
			expect(v3).toFlushAndYield({ "A", "B" })
		end).toErrorDev("    in Text (at **)\n    in Foo (at **)")
		expect(v5).toMatchRenderedOutput(v.createElement("div", nil, "AB"))
	end)
	it("supports class and forwardRef components", function()
		local v4 = lazy(function()
			local extended = v.Component:extend("Foo")

			function extended.render(p)
				return v.createElement(Text, {
					text = "Foo"
				})
			end

			return fn(extended)
		end)
		local v5 = lazy(function()
			local extended = v.Component:extend("Bar")

			function extended.render(p)
				return v.createElement(Text, {
					text = "Bar"
				})
			end

			return fn(v.forwardRef(function(p, ref2)
				v3.unstable_yieldValue("forwardRef")
				return v.createElement(extended, {
					ref = ref2
				})
			end))
		end)
		local ref = v.createRef()
		local v6 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4), v.createElement(v5, {
			ref = ref
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		expect(v6).never.toMatchRenderedOutput("FooBar")
		expect(ref.current).toBe(nil)
		Promise.delay(0):await()
		expect(v3).toFlushAndYield({ "Foo", "forwardRef", "Bar" })
		expect(v6).toMatchRenderedOutput("FooBar")
		expect(ref.current).never.toBe(nil)
	end)
	it("warns about ref on functions for lazy-loaded components", function()
		local v4 = lazy(function()
			return fn(function(p)
				return v.createElement("div")
			end)
		end)
		local ref = v.createRef()
		v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v4, {
			ref = ref
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		Promise.delay(0):await()
		expect(function()
			expect(v3).toFlushAndYield({})
		end).toErrorDev("Function components cannot be given refs")
	end)
	xit("should error with a component stack naming the resolved component", function()
		local v4 = nil
		local v5 = lazy(function()
			return fn(function()
				error(error2("oh no"))
			end)
		end)
		local extended = v.Component:extend("ErrorBoundary")

		function extended:init()
			self.state = {
				error = nil
			}
		end

		function extended.componentDidCatch(object, error3, p2)
			local componentStack = p2.componentStack

			if typeof(componentStack) == "string" then
				local v6 = string.gsub(componentStack, "Check your code at .*:%d+", "Check your code at **")
				componentStack = string.gsub(v6, [[

    in ([%w%-%._]+)[^
]*]], "\n    in %1 (at **)")
			end

			v4 = componentStack
			object:setState({
				error = error3
			})
		end

		function extended.render(p)
			if p.state.error then
				return nil
			end

			return p.props.children
		end

		v2.create(v.createElement(extended, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v5, {
			text = "Hi"
		}))), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Loading..." })
		_ = pcall(function()
			Promise.delay(0):await()
		end)
		expect(v3).toFlushAndYield({})
		expect(v4).toContain("in ResolvedText")
	end)
	xit("should error with a component stack containing Lazy if unresolved", function()
		local v4 = nil
		local v5 = lazy(function()
			return {
				andThen = function(self, callback)
					callback(error2("oh no"))
				end
			}
		end)
		local extended = v.Component:extend("ErrorBoundary")

		function extended:init()
			self.state = {
				error_ = nil
			}
		end

		function extended.componentDidCatch(object, error_, p2)
			local componentStack = p2.componentStack

			if typeof(componentStack) == "string" then
				local v6 = string.gsub(componentStack, "Check your code at .*:%d+", "Check your code at **")
				componentStack = string.gsub(v6, [[

    in ([%w%-%._]+)[^
]*]], "\n    in %1 (at **)")
			end

			v4 = componentStack
			object:setState({
				error_ = error_
			})
		end

		function extended.render(p)
			if p.state.error_ then
				return nil
			end

			return p.props.children
		end

		v2.create(v.createElement(extended, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(v5, {
			text = "Hi"
		}))))
		expect(v3).toHaveYielded({})
		expect(v4).toContain("in Lazy")
	end)
end)