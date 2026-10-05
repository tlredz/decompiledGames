local v = nil
local v2 = nil
local reactFeatureFlags = nil
local v3 = nil
local tracing = nil
local v4 = nil
local suspense = nil
local unstable_concurrentAct = nil
local v5 = nil
local flag = nil
local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local afterEach = JestGlobals.afterEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local describe = JestGlobals.describe
local jest = JestGlobals.jest
local JestGlobals2 = require(parent.Dev.JestGlobals)
local jest2 = JestGlobals2.jest
local Promise = require(parent.Promise)
local LuauPolyfill = require(parent.LuauPolyfill)
local setTimeout = LuauPolyfill.setTimeout
local error2 = LuauPolyfill.Error
describe("ReactSuspense", function()
	afterEach(function()
		jest.useRealTimers()
	end)
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = false
		reactFeatureFlags.enableSchedulerTracing = true
		local React = require(parent.React)
		v = React
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v2 = ReactTestRenderer
		unstable_concurrentAct = v2.unstable_concurrentAct
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
		tracing = v3.tracing
		local ReactCache = require(parent.Dev.ReactCache)
		v4 = ReactCache
		suspense = v.Suspense
		v5 = v4.unstable_createResource(function(list)
			local v6 = list[1]
			local v7 = list[2] or 0
			local v8 = nil
			local v9 = "pending"
			local v10 = nil
			return {
				andThen = function(self, resolve, callback2)
					if v9 == "pending" then
						if v8 ~= nil then
							table.insert(v8, {
								resolve = resolve,
								reject = callback2
							})
							return
						end

						v8 = {
							{
								resolve = resolve,
								reject = callback2
							}
						}
						setTimeout(function()
							if flag then
								v3.unstable_yieldValue(string.format("Promise rejected [%s]", v6))
								v9 = "rejected"
								v10 = error2.new("Failed to load: " .. v6)

								for _, v11 in v8 do
									v11.reject(v10)
								end
							else
								v3.unstable_yieldValue(string.format("Promise resolved [%s]", v6))
								v9 = "resolved"
								v10 = v6

								for _, v11 in v8 do
									v11.resolve(v10)
								end
							end
						end, v7)
					elseif v9 == "resolved" then
						resolve(v10)
					elseif v9 == "rejected" then
						callback2(v10)
					end
				end
			}
		end, function(list)
			return list[1]
		end)
		flag = false
	end)

	local function Text(p)
		v3.unstable_yieldValue(p.text)
		return p.text
	end

	local function AsyncText(p)
		local text = p.text
		local success, result = pcall(function()
			v5.read({ p.text, p.ms })
			v3.unstable_yieldValue(text)
			return text
		end)

		if success then
			return result
		end

		if typeof(result.andThen) == "function" then
			v3.unstable_yieldValue(string.format("Suspend! [%s]", text))
		else
			v3.unstable_yieldValue(string.format("Error! [%s]", text))
		end

		error(result)
		return result
	end

	it("suspends rendering and continues later", function()
		jest.useFakeTimers()

		local function Bar(p)
			v3.unstable_yieldValue("Bar")
			return p.children
		end

		local function Foo(p)
			local renderBar = p.renderBar
			v3.unstable_yieldValue("Foo")
			local createElement = v.createElement
			local v6 = suspense
			local v7 = {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}
			local v8

			if renderBar then
				v8 = v.createElement(Bar, nil, v.createElement(AsyncText, {
					text = "A",
					ms = 100
				}), v.createElement(Text, {
					text = "B"
				}))
			end

			return createElement(v6, v7, v8)
		end

		local v6 = v2.create(v.createElement(Foo), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Foo" })
		expect(v6).toMatchRenderedOutput(nil)
		v6.update(v.createElement(Foo, {
			renderBar = true
		}))
		expect(v3).toFlushAndYield({
			"Foo",
			"Bar",
			"Suspend! [A]",
			"B",
			"Loading..."
		})
		expect(v6).toMatchRenderedOutput(nil)
		jest.advanceTimersByTime(50)
		expect(v3).toFlushWithoutYielding()
		expect(v6).toMatchRenderedOutput(nil)
		jest.advanceTimersByTime(50)
		expect(v3).toHaveYielded({ "Promise resolved [A]" })
		expect(v3).toFlushAndYield({
			"Foo",
			"Bar",
			"A",
			"B"
		})
		expect(v6).toMatchRenderedOutput("AB")
	end)
	it("suspends siblings and later recovers each independently", function()
		jest.useFakeTimers()
		local v6 = v2.create(v.createElement(v.Fragment, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading A..."
			})
		}, v.createElement(AsyncText, {
			text = "A",
			ms = 5000
		})), v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading B..."
			})
		}, v.createElement(AsyncText, {
			text = "B",
			ms = 6000
		}))), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({
			"Suspend! [A]",
			"Loading A...",
			"Suspend! [B]",
			"Loading B..."
		})
		v3.unstable_flushAll()
		expect(v6).toMatchRenderedOutput("Loading A...Loading B...")
		jest.advanceTimersByTime(5000)
		expect(v3).toHaveYielded({ "Promise resolved [A]" })
		expect(v3).toFlushAndYield({ "A" })
		expect(v6).toMatchRenderedOutput("ALoading B...")
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [B]" })
		expect(v3).toFlushAndYield({ "B" })
		expect(v6).toMatchRenderedOutput("AB")
	end)
	it("interrupts current render if promise resolves before current render phase", function()
		local flag2 = false
		local callbacks = {}
		local v6 = {
			andThen = function(self, callback)
				if flag2 then
					callback()
				else
					table.insert(callbacks, callback)
				end
			end
		}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveThenable()
			flag2 = true

			for _, v7 in callbacks do
				v7()
			end
		end

		local function Async()
			if not flag2 then
				v3.unstable_yieldValue("Suspend!")
				error(v6)
			end

			v3.unstable_yieldValue("Async")
			return "Async"
		end

		local v7 = v2.create(v.createElement(v.Fragment, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}), v.createElement(Text, {
			text = "Initial"
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Initial" })
		expect(v7).toMatchRenderedOutput("Initial")
		v7.update(v.createElement(v.Fragment, nil, v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(Async)), v.createElement(Text, {
			text = "After Suspense"
		}), v.createElement(Text, {
			text = "Sibling"
		})))
		expect(v3).toFlushAndYieldThrough({ "Suspend!", "Loading...", "After Suspense" })
		resolveThenable() -- equivalent call inferred; original call site unknown
		expect(v3).toHaveYielded({})
		expect(v7).toMatchRenderedOutput("Initial")
		expect(v3).toFlushAndYield({ "Async", "After Suspense", "Sibling" })
		expect(v7).toMatchRenderedOutput("AsyncAfter SuspenseSibling")
	end)
	it(
		"interrupts current render if something already suspended with a delay, and then subsequently there's a lower priority update",
		function()
			local v6 = v2.create(v.createElement(v.Fragment, nil, v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}), v.createElement(Text, {
				text = "Initial"
			})), {
				unstable_isConcurrent = true
			})
			expect(v3).toFlushAndYield({ "Initial" })
			expect(v6).toMatchRenderedOutput("Initial")
			v6.update(v.createElement(v.Fragment, nil, v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(AsyncText, {
				text = "Async",
				ms = 2000
			})), v.createElement(Text, {
				text = "After Suspense"
			}), v.createElement(Text, {
				text = "Sibling"
			})))
			expect(v3).toFlushAndYieldThrough({ "Suspend! [Async]", "Loading...", "After Suspense" })
			v3.unstable_advanceTime(1000)
			v6.update(v.createElement(v.Fragment, nil, v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}), v.createElement(Text, {
				text = "Updated"
			})))
			expect(v3).toHaveYielded({})
			expect(v6).toMatchRenderedOutput("Initial")
			expect(v3).toFlushAndYield({ "Updated" })
			expect(v6).toMatchRenderedOutput("Updated")
		end
	)
	xit(
		"interrupts current render when something suspends with a delay, and a parent received an update after it completed",
		function()
			local function App(p)
				local shouldSuspend = p.shouldSuspend
				local step = p.step
				return v.createElement(v.Fragment, nil, {
					v.createElement(Text, {
						text = string.format("A%s", step)
					}),
					v.createElement(suspense, {
						fallback = v.createElement(Text, {
							text = "Loading..."
						})
					}, (function()
						if shouldSuspend then
							return v.createElement(AsyncText, {
								text = "Async",
								ms = 2000
							})
						end

						return nil
					end)()),
					v.createElement(Text, {
						text = string.format("B%s", step)
					}),
					v.createElement(Text, {
						text = string.format("C%s", step)
					})
				})
			end

			local v6 = v2.create(nil, {
				unstable_isConcurrent = true
			})
			v6.update(v.createElement(App, {
				shouldSuspend = false,
				step = 0
			}))
			expect(v3).toFlushAndYield({ "A0", "B0", "C0" })
			expect(v6).toMatchRenderedOutput("A0B0C0")
			v6.update(v.createElement(App, {
				shouldSuspend = true,
				step = 1
			}))
			expect(v3).toFlushAndYieldThrough({ "A1" })
			v6.update(v.createElement(App, {
				shouldSuspend = false,
				step = 2
			}))
			expect(v3).toFlushAndYieldThrough({ "Suspend! [Async]", "Loading...", "B1" })
			expect(v6).toMatchRenderedOutput("A0B0C0")
			expect(v3).toFlushAndYield({ "A2", "B2", "C2" })
			expect(v6).toMatchRenderedOutput("A2B2C2")
		end
	)
	it("mounts a lazy class component in non-concurrent mode", function()
		jest.useRealTimers()

		local function fn(extended)
			return Promise.delay(0):andThen(function()
				return {
					default = extended
				}
			end)
		end

		local extended = v.Component:extend("Class")

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

		local lazy = v.lazy(function()
			return fn(extended)
		end)
		local v6 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(lazy, {
			label = "Hi"
		})))
		expect(v3).toHaveYielded({ "Loading..." })
		expect(v6).toMatchRenderedOutput("Loading...")
		Promise.delay(0):await()
		expect(v3).toFlushExpired({ "Hi", "Did mount: Hi" })
		expect(v6).toMatchRenderedOutput("Hi")
	end)
	it("only captures if `fallback` is defined", function()
		jest.useFakeTimers()
		local v6 = v2.create(v.createElement(suspense, {
			fallback = v.createElement(Text, {
				text = "Loading..."
			})
		}, v.createElement(suspense, nil, v.createElement(AsyncText, {
			text = "Hi",
			ms = 5000
		}))), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Suspend! [Hi]", "Loading..." })
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({})
		expect(v3).toFlushAndYield({})
		expect(v6).toMatchRenderedOutput("Loading...")
		jest.advanceTimersByTime(5000)
		expect(v3).toHaveYielded({ "Promise resolved [Hi]" })
		expect(v3).toFlushAndYield({ "Hi" })
		expect(v6).toMatchRenderedOutput("Hi")
	end)
	it("throws if tree suspends and none of the Suspense ancestors have a fallback", function()
		v2.create(v.createElement(suspense, nil, v.createElement(AsyncText, {
			text = "Hi",
			ms = 1000
		})), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndThrow("AsyncText suspended while rendering, but no fallback UI was specified.")
		expect(v3).toHaveYielded({ "Suspend! [Hi]", "Suspend! [Hi]" })
	end)
	it("updates memoized child of suspense component when context updates (simple memo)", function()
		jest.useFakeTimers()
		local useContext = v.useContext
		local createContext = v.createContext
		local useState = v.useState
		local memo = v.memo
		local context = createContext(nil)
		local v6 = memo(function()
			local v7 = useContext(context)
			local success, result = pcall(function()
				v5.read({ v7, 1000 })
				v3.unstable_yieldValue(v7)
			end)

			if success then
				return v7
			end

			if typeof(result.andThen) == "function" then
				v3.unstable_yieldValue(string.format("Suspend! [%s]", v7))
			else
				v3.unstable_yieldValue(string.format("Error! [%s]", v7))
			end

			error(result)
			return v7
		end)
		local state = nil
		local setState = nil

		local function App()
			state, setState = useState("default")
			return v.createElement(context.Provider, {
				value = state
			}, v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(v6)))
		end

		local v7 = v2.create(v.createElement(App), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Suspend! [default]", "Loading..." })
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [default]" })
		expect(v3).toFlushAndYield({ "default" })
		expect(v7).toMatchRenderedOutput("default")
		v2.act(function()
			return setState("new value")
		end)
		expect(v3).toHaveYielded({ "Suspend! [new value]", "Loading..." })
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [new value]" })
		expect(v3).toFlushAndYield({ "new value" })
		expect(v7).toMatchRenderedOutput("new value")
	end)
	it("when updating a timed-out tree, always retries the suspended component", function()
		jest.useFakeTimers()
		local v6 = nil
		local extended = v.Component:extend("Stateful")

		function extended:init()
			self.state = {
				step = 1
			}
		end

		function extended.render(p)
			v6 = p
			return v.createElement(Text, {
				text = string.format("Stateful: %s", p.state.step)
			})
		end

		local fragment = v.Fragment

		local function App(p)
			return v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(extended), v.createElement(
				fragment,
				nil,
				v.createElement(fragment, nil, v.createElement(fragment, nil, v.createElement(AsyncText, {
					ms = 1000,
					text = p.text
				})))
			))
		end

		local v7 = v2.create(v.createElement(App, {
			text = "A"
		}))
		expect(v3).toHaveYielded({ "Stateful: 1", "Suspend! [A]", "Loading..." })
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [A]" })
		expect(v3).toFlushExpired({ "A" })
		expect(v7).toMatchRenderedOutput("Stateful: 1A")
		v7.update(v.createElement(App, {
			text = "B"
		}))
		expect(v3).toHaveYielded({ "Stateful: 1", "Suspend! [B]", "Loading..." })
		expect(v7).toMatchRenderedOutput("Loading...")
		v6:setState({
			step = 2
		})
		expect(v3).toHaveYielded({ "Stateful: 2", "Suspend! [B]" })
		expect(v7).toMatchRenderedOutput("Loading...")
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [B]" })
		expect(v3).toFlushExpired({ "B" })
		expect(v7).toMatchRenderedOutput("Stateful: 2B")
	end)
	it("suspends in a class that has componentWillUnmount and is then deleted", function()
		local extended = v.Component:extend("AsyncTextWithUnmount")

		function extended.componentWillUnmount(_)
			v3.unstable_yieldValue("will unmount")
		end

		function extended.render(p)
			local text = p.props.text
			local ms = p.props.ms
			local success, result = pcall(function()
				v5.read({ text, ms })
				v3.unstable_yieldValue(text)
				return text
			end)

			if success then
				return result
			end

			if typeof(result.andThen) == "function" then
				v3.unstable_yieldValue(string.format("Suspend! [%s]", text))
			else
				v3.unstable_yieldValue(string.format("Error! [%s]", text))
			end

			error(result)
			return result
		end

		local function App(p)
			local text = p.text
			return v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(extended, {
				text = text,
				ms = 100
			}))
		end

		local v6 = v2.create(v.createElement(App, {
			text = "A"
		}))
		expect(v3).toHaveYielded({ "Suspend! [A]", "Loading..." })
		v6.update(v.createElement(Text, {
			text = "B"
		}))
		expect(v3).toHaveYielded({ "B" })
		expect(v6).toMatchRenderedOutput("B")
	end)
	it("suspends in a component that also contains useEffect", function()
		jest.useFakeTimers()
		local useLayoutEffect = v.useLayoutEffect

		local function AsyncTextWithEffect(p)
			local text = p.text
			useLayoutEffect(function()
				v3.unstable_yieldValue("Did commit: " .. text)
			end, { text })
			local success, result = pcall(function()
				v5.read({ p.text, p.ms })
				v3.unstable_yieldValue(text)
				return text
			end)

			if success then
				return result
			end

			if typeof(result.andThen) == "function" then
				v3.unstable_yieldValue(string.format("Suspend! [%s]", text))
			else
				v3.unstable_yieldValue(string.format("Error! [%s]", text))
			end

			error(result)
			return result
		end

		local function App(p)
			local text = p.text
			return v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(AsyncTextWithEffect, {
				text = text,
				ms = 100
			}))
		end

		v2.create(v.createElement(App, {
			text = "A"
		}))
		expect(v3).toHaveYielded({ "Suspend! [A]", "Loading..." })
		jest.advanceTimersByTime(500)
		expect(v3).toHaveYielded({ "Promise resolved [A]" })
		expect(v3).toFlushExpired({ "A", "Did commit: A" })
	end)
	it("retries when an update is scheduled on a timed out tree", function()
		jest.useFakeTimers()
		local v6 = nil
		local extended = v.Component:extend("Stateful")

		function extended:init()
			self.state = {
				step = 1
			}
		end

		function extended.render(p)
			v6 = p
			return v.createElement(AsyncText, {
				ms = 1000,
				text = string.format("Step: %s", p.state.step)
			})
		end

		local function App(_)
			return v.createElement(suspense, {
				fallback = v.createElement(Text, {
					text = "Loading..."
				})
			}, v.createElement(extended))
		end

		local v7 = v2.create(v.createElement(App), {
			unstable_isConcurrent = true
		})
		expect(v3).toFlushAndYield({ "Suspend! [Step: 1]", "Loading..." })
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [Step: 1]" })
		expect(v3).toFlushAndYield({ "Step: 1" })
		expect(v7).toMatchRenderedOutput("Step: 1")
		v6:setState({
			step = 2
		})
		expect(v3).toFlushAndYield({ "Suspend! [Step: 2]", "Loading..." })
		jest.advanceTimersByTime(500)
		expect(v7).toMatchRenderedOutput("Loading...")
		v6:setState({
			step = 3
		})
		expect(v3).toFlushAndYield({ "Suspend! [Step: 3]" })
		expect(v7).toMatchRenderedOutput("Loading...")
		jest.advanceTimersByTime(1000)
		expect(v3).toHaveYielded({ "Promise resolved [Step: 2]", "Promise resolved [Step: 3]" })
		expect(v3).toFlushAndYield({ "Step: 3" })
		expect(v7).toMatchRenderedOutput("Step: 3")
	end)
	it("should call onInteractionScheduledWorkCompleted after suspending", function()
		jest.useFakeTimers()
		local count = 0
		_G.performance = {
			now = function()
				count += 1
				return count
			end,
			mark = function() end
		}
		local v6 = {
			onInteractionScheduledWorkCompleted = jest2.fn(),
			onInteractionTraced = jest2.fn(),
			onWorkCanceled = jest2.fn(),
			onWorkScheduled = jest2.fn(),
			onWorkStarted = jest2.fn(),
			onWorkStopped = jest2.fn()
		}
		tracing.unstable_subscribe(v6)
		tracing.unstable_trace("test", _G.performance.now(), function()
			local function App()
				return v.createElement(v.Suspense, {
					fallback = v.createElement(Text, {
						text = "Loading..."
					})
				}, v.createElement(AsyncText, {
					text = "A",
					ms = 1000
				}), v.createElement(AsyncText, {
					text = "B",
					ms = 2000
				}), v.createElement(AsyncText, {
					text = "C",
					ms = 3000
				}))
			end

			v2.create().update(v.createElement(App))
			expect(v3).toHaveYielded({
				"Suspend! [A]",
				"Suspend! [B]",
				"Suspend! [C]",
				"Loading..."
			})
			jest.advanceTimersByTime(1000)
			expect(v3).toHaveYielded({ "Promise resolved [A]" })
			expect(v3).toFlushExpired({ "A", "Suspend! [B]", "Suspend! [C]" })
			jest.advanceTimersByTime(1000)
			expect(v3).toHaveYielded({ "Promise resolved [B]" })
			expect(v3).toFlushExpired({ "B", "Suspend! [C]" })
			jest.advanceTimersByTime(1000)
			expect(v3).toHaveYielded({ "Promise resolved [C]" })
			expect(v3).toFlushAndYield({ "C" })
		end)
		expect(v6.onInteractionScheduledWorkCompleted).toHaveBeenCalledTimes(1)
	end)
end)