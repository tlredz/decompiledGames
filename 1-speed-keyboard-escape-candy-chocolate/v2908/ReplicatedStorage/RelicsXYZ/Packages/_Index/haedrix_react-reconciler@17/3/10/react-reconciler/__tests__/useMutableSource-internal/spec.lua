local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local act = nil
local createMutableSource = nil
local useMutableSource = nil
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local Promise = require(parent.Promise)
local array = LuauPolyfill.Array
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local describe = JestGlobals.describe

local function loadModules()
	jest.resetModules()
	jest.useFakeTimers()
	local Shared = require(parent.Shared)
	local reactFeatureFlags = Shared.ReactFeatureFlags
	reactFeatureFlags.enableSchedulerTracing = true
	reactFeatureFlags.enableProfilerTimer = true
	local React = require(parent.React)
	v = React
	local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
	v2 = ReactNoopRenderer
	local Scheduler = require(parent.Scheduler)
	v3 = Scheduler
	act = v2.act
	createMutableSource = v.createMutableSource
	useMutableSource = v.useMutableSource
end

describe("useMutableSource", function()
	local function fn(p)
		return p.value
	end

	local function fn2(p, p2)
		if p2 == nil then
			return p.subscribe(function() end)
		end

		return p.subscribe(p2)
	end

	local function createComplexSource(p, p2)
		local v4 = {}
		local v5 = {}
		local v6 = 1
		local v7 = p
		local v8 = p2
		return (setmetatable({
			subscribeA = function(p3)
				local v9 = v4

				if array.indexOf(v9, p3) < 1 then
					table.insert(v9, p3)
				end

				return function()
					local index = array.indexOf(v9, p3)

					if index >= 1 then
						array.splice(v9, index, 1)
					end
				end
			end,
			subscribeB = function(p3)
				local v9 = v5

				if array.indexOf(v9, p3) < 1 then
					table.insert(v9, p3)
				end

				return function()
					local index = array.indexOf(v9, p3)

					if index >= 1 then
						array.splice(v9, index, 1)
					end
				end
			end
		}, {
			__index = function(_, p3)
				if p3 == "listenerCountA" then
					return #v4
				elseif p3 == "listenerCountB" then
					return #v5
				elseif p3 == "valueA" then
					return v7
				elseif p3 == "valueB" then
					return v8
				elseif p3 == "version" then
					return v6
				end
			end,
			__newindex = function(_, p3, p4)
				if p3 == "valueA" then
					v6 += 1
					v7 = p4
					array.map(v4, function(callback)
						return callback()
					end)
				elseif p3 == "valueB" then
					v6 += 1
					v8 = p4
					array.map(v5, function(callback)
						return callback()
					end)
				end
			end
		}))
	end

	local function createSource(p)
		local v4 = {}
		local v5 = 1
		local v6 = p
		return (setmetatable({
			subscribe = function(p2)
				if array.indexOf(v4, p2) < 1 then
					table.insert(v4, p2)
				end

				return function()
					local index = array.indexOf(v4, p2)

					if index >= 1 then
						array.splice(v4, index, 1)
					end
				end
			end
		}, {
			__index = function(_, p2)
				if p2 == "value" then
					return v6
				elseif p2 == "version" then
					return v5
				elseif p2 == "listenerCount" then
					return #v4
				end
			end,
			__newindex = function(_, p2, p3)
				if p2 == "value" then
					v5 += 1
					v6 = p3
					array.map(v4, function(callback)
						return callback()
					end)
				end
			end
		}))
	end

	local function Component(props)
		local getSnapshot = props.getSnapshot
		local label = props.label
		local mutableSource = props.mutableSource
		local subscribe = props.subscribe
		local v4 = useMutableSource(mutableSource, getSnapshot, subscribe)
		v3.unstable_yieldValue(string.format("%s:%s", label, v4))
		return v.createElement("div", nil, string.format("%s:%s", label, v4))
	end

	beforeEach(function()
		loadModules()
	end)
	it("should subscribe to a source and schedule updates when it changes", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.renderToRootWithID(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), "root", function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "a:one", "b:one", "Sync effect" })
			expect(source.listenerCount).toEqual(0)
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(2)
			source.value = "two"
			expect(v3).toFlushAndYieldThrough({ "a:two", "b:two" })
			v2.renderToRootWithID(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), "root", function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:two", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(1)
			v2.unmountRootWithID("root")
			expect(v3).toFlushAndYield({})
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(0)
			source.value = "three"
			expect(v3).toFlushAndYield({})
		end)
	end)
	it("should restart work if a new source is mutated during render", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "a:one" })
			source.value = "two"
			expect(v3).toFlushAndYield({ "a:two", "b:two", "Sync effect" })
		end)
	end)
	it("should schedule an update if a new source is mutated between render and commit (subscription)", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "a:one", "b:one", "Sync effect" })
			expect(source.listenerCount).toEqual(0)
			source.value = "two"
			expect(v3).toFlushAndYield({ "a:two", "b:two" })
		end)
	end)
	it("should unsubscribe and resubscribe if a new source is used", function()
		local source = createSource("a-one")
		local mutableSource = createMutableSource(source, function(p)
			return p.versionA
		end)
		local source2 = createSource("b-one")
		local mutableSource2 = createMutableSource(source2, function(p)
			return p.versionB
		end)
		act(function()
			v2.render(v.createElement(Component, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:a-one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(1)
			source.value = "a-two"
			expect(v3).toFlushAndYield({ "only:a-two" })
			v2.render(v.createElement(Component, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource2,
				subscribe = fn2
			}), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:b-one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(0)
			expect(source2.listenerCount).toEqual(1)
			source.value = "a-three"
			expect(v3).toFlushAndYield({})
			source2.value = "b-two"
			expect(v3).toFlushAndYield({ "only:b-two" })
		end)
	end)
	it("should unsubscribe and resubscribe if a new subscribe function is provided", function()
		local source = createSource("a-one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		local v4 = jest.fn()
		local subscribe = jest.fn(function(p)
			local v6 = p.subscribe(function() end)
			return function()
				v6()
				v4()
			end
		end)
		local v6 = jest.fn()
		local subscribe2 = jest.fn(function(p)
			local v8 = p.subscribe(function() end)
			return function()
				v8()
				v6()
			end
		end)
		act(function()
			v2.renderToRootWithID(v.createElement(Component, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = subscribe
			}), "root", function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:a-one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(1)
			expect(subscribe).toHaveBeenCalledTimes(1)
			v2.renderToRootWithID(v.createElement(Component, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = subscribe2
			}), "root", function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:a-one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(1)
			expect(v4).toHaveBeenCalledTimes(1)
			expect(subscribe2).toHaveBeenCalledTimes(1)
			v2.unmountRootWithID("root")
			expect(v3).toFlushAndYield({})
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(0)
			expect(v6).toHaveBeenCalledTimes(1)
		end)
	end)
	it("should re-use previously read snapshot value when reading is unsafe", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "b:one", "Sync effect" })
			source.value = "two"
			expect(v3).toFlushAndYieldThrough({ "a:two" })
			v2.flushSync(function()
				v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
					label = "a",
					getSnapshot = fn,
					mutableSource = mutableSource,
					subscribe = fn2
				}), v.createElement(Component, {
					label = "b",
					getSnapshot = fn,
					mutableSource = mutableSource,
					subscribe = fn2
				})), function()
					return v3.unstable_yieldValue("Sync effect")
				end)
			end)
			expect(v3).toHaveYielded({ "a:one", "b:one", "Sync effect" })
			expect(v3).toFlushAndYield({ "a:two", "b:two" })
		end)
	end)
	it("should read from source on newly mounted subtree if no pending updates are scheduled for source", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "Sync effect" })
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "b:one", "Sync effect" })
		end)
	end)
	it("should throw and restart render if source and snapshot are unavailable during an update", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "b:one", "Sync effect" })
			v2.flushPassiveEffects()
			v3.unstable_runWithPriority(v3.unstable_LowPriority, function()
				source.value = "two"
				expect(v3).toFlushAndYieldThrough({ "a:two" })
			end)

			local function fn3(p)
				return "new:" .. p.value
			end

			v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
				v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
					label = "a",
					getSnapshot = fn3,
					mutableSource = mutableSource,
					subscribe = fn2
				}), v.createElement(Component, {
					label = "b",
					getSnapshot = fn3,
					mutableSource = mutableSource,
					subscribe = fn2
				})), function()
					return v3.unstable_yieldValue("Sync effect")
				end)
			end)
			expect(v3).toFlushAndYieldThrough({ "a:new:two", "b:new:two", "Sync effect" })
		end)
	end)
	it("should throw and restart render if source and snapshot are unavailable during a sync update", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "b:one", "Sync effect" })
			v2.flushPassiveEffects()
			v3.unstable_runWithPriority(v3.unstable_LowPriority, function()
				source.value = "two"
				expect(v3).toFlushAndYieldThrough({ "a:two" })
			end)

			local function fn3(p)
				return "new:" .. p.value
			end

			v2.flushSync(function()
				v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
					label = "a",
					getSnapshot = fn3,
					mutableSource = mutableSource,
					subscribe = fn2
				}), v.createElement(Component, {
					label = "b",
					getSnapshot = fn3,
					mutableSource = mutableSource,
					subscribe = fn2
				})), function()
					return v3.unstable_yieldValue("Sync effect")
				end)
			end)
			expect(v3).toHaveYielded({ "a:new:two", "b:new:two", "Sync effect" })
		end)
	end)
	it("should only update components whose subscriptions fire", function()
		local complexSource = createComplexSource("a:one", "b:one")
		local mutableSource = createMutableSource(complexSource, function(p)
			return p.version
		end)

		local function fn3(p)
			return p.valueA
		end

		local function fn4(p, p2)
			return p.subscribeA(p2)
		end

		local function fn5(p)
			return p.valueB
		end

		local function fn6(p, p2)
			return p.subscribeB(p2)
		end

		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn3,
				mutableSource = mutableSource,
				subscribe = fn4
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn5,
				mutableSource = mutableSource,
				subscribe = fn6
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:a:one", "b:b:one", "Sync effect" })
			complexSource.valueA = "a:two"
			expect(v3).toFlushAndYield({ "a:a:two" })
			complexSource.valueB = "b:two"
			expect(v3).toFlushAndYield({ "b:b:two" })
		end)
	end)
	it("should detect tearing in part of the store not yet subscribed to", function()
		local complexSource = createComplexSource("a:one", "b:one")
		local mutableSource = createMutableSource(complexSource, function(p)
			return p.version
		end)

		local function fn3(p)
			return p.valueA
		end

		local function fn4(p, p2)
			return p.subscribeA(p2)
		end

		local function fn5(p)
			return p.valueB
		end

		local function fn6(p, p2)
			return p.subscribeB(p2)
		end

		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn3,
				mutableSource = mutableSource,
				subscribe = fn4
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:a:one", "Sync effect" })
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn3,
				mutableSource = mutableSource,
				subscribe = fn4
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn5,
				mutableSource = mutableSource,
				subscribe = fn6
			}), v.createElement(Component, {
				label = "c",
				getSnapshot = fn5,
				mutableSource = mutableSource,
				subscribe = fn6
			})), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "a:a:one", "b:b:one" })
			complexSource.valueB = "b:two"
			expect(v3).toFlushAndYield({
				"a:a:one",
				"b:b:two",
				"c:b:two",
				"Sync effect"
			})
		end)
	end)
	it("does not schedule an update for subscriptions that fire with an unchanged snapshot", function()
		local v4 = Component
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v4, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "only:one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(source.listenerCount).toEqual(1)
			source.value = "one"
			expect(v3).toFlushWithoutYielding()
		end)
	end)
	it("should throw and restart if getSnapshot changes between scheduled update and re-render", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3(p)
			return "new:" .. p.value
		end

		local state = nil
		local setState = nil

		local function WrapperWithState()
			state, setState = v.useState(function()
				return fn
			end)
			return v.createElement(Component, {
				label = "only",
				getSnapshot = state,
				mutableSource = mutableSource,
				subscribe = fn2
			})
		end

		act(function()
			v2.render(v.createElement(WrapperWithState), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:one", "Sync effect" })
			v2.flushPassiveEffects()
			v3.unstable_runWithPriority(v3.unstable_LowPriority, function()
				source.value = "two"
			end)
			v3.unstable_runWithPriority(v3.unstable_UserBlockingPriority, function()
				setState(function()
					return fn3
				end)
			end)
			expect(v3).toFlushAndYield({ "only:new:two" })
		end)
	end)
	it("should recover from a mutation during yield when other work is scheduled", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			}), v.createElement(Component, {
				label = "b",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})))
			expect(v3).toFlushAndYieldThrough({ "a:one" })
			source.value = "two"
			v2.render(v.createElement("div"))
			expect(v3).toFlushAndYield({})
		end)
	end)
	it("should not throw if the new getSnapshot returns the same snapshot value", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		local onRender = jest.fn()
		local onRender2 = jest.fn()
		local state = nil
		local setState = nil

		local function WrapperWithState()
			state, setState = v.useState(function()
				return fn
			end)
			return v.createElement(Component, {
				label = "b",
				getSnapshot = state,
				mutableSource = mutableSource,
				subscribe = fn2
			})
		end

		act(function()
			v2.render(v.createElement(v.Fragment, nil, v.createElement(v.Profiler, {
				id = "a",
				onRender = onRender
			}, v.createElement(Component, {
				label = "a",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})), v.createElement(v.Profiler, {
				id = "b",
				onRender = onRender2
			}, v.createElement(WrapperWithState))), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "a:one", "b:one", "Sync effect" })
			v2.flushPassiveEffects()
			expect(onRender).toHaveBeenCalledTimes(1)
			expect(onRender2).toHaveBeenCalledTimes(1)
			setState(function()
				return function(p)
					return p.value
				end
			end)
			expect(v3).toFlushAndYield({ "b:one" })
			v2.flushPassiveEffects()
			expect(onRender).toHaveBeenCalledTimes(1)
			expect(onRender2).toHaveBeenCalledTimes(2)
		end)
	end)
	it("should not throw if getSnapshot changes but the source can be safely read from anyway", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3(p)
			return "new:" .. p.value
		end

		local state = nil
		local setState = nil

		local function WrapperWithState()
			state, setState = v.useState(function()
				return fn
			end)
			return v.createElement(Component, {
				label = "only",
				getSnapshot = state,
				mutableSource = mutableSource,
				subscribe = fn2
			})
		end

		act(function()
			v2.render(v.createElement(WrapperWithState), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:one", "Sync effect" })
			v2.flushPassiveEffects()
			v2.batchedUpdates(function()
				source.value = "two"
				setState(function()
					return fn3
				end)
			end)
			expect(v3).toFlushAndYield({ "only:new:two" })
		end)
	end)
	xit("should still schedule an update if an eager selector throws after a mutation", function()
		local source = createSource({
			friends = {
				{
					id = 1,
					name = "Foo"
				},
				{
					id = 2,
					name = "Bar"
				}
			}
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function Friend(p)
			local id = p.id
			local v4 = v.useCallback(function(p2)
				local value = p2.value
				return array.find(value.friends, function(p3)
					return p3.id == id
				end).name
			end, { id })
			local v5 = useMutableSource(mutableSource, v4, fn2)
			v3.unstable_yieldValue(string.format("%s:%s", id, v5))
			return v.createElement("li", nil, v5)
		end

		local function FriendsList()
			local v4 = v.useCallback(function(p)
				local value = p.value
				return array.from(value.friends)
			end, {})
			local v5 = useMutableSource(mutableSource, v4, fn2)
			return v.createElement("ul", nil, array.map(v5, function(p)
				return v.createElement(Friend, {
					key = p.id,
					id = p.id
				})
			end))
		end

		act(function()
			v2.render(v.createElement(FriendsList), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "1:Foo", "2:Bar", "Sync effect" })
			source.value = {
				friends = {
					{
						id = 1,
						name = "Foo"
					},
					{
						id = 3,
						name = "Baz"
					}
				}
			}
			expect(v3).toFlushAndYield({ "1:Foo", "3:Baz" })
		end)
	end)
	it("should not warn about updates that fire between unmount and passive unsubscribe", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function Wrapper()
			v.useLayoutEffect(function()
				return function()
					v3.unstable_yieldValue("layout unmount")
				end
			end)
			return v.createElement(Component, {
				label = "only",
				getSnapshot = fn,
				mutableSource = mutableSource,
				subscribe = fn2
			})
		end

		act(function()
			v2.renderToRootWithID(v.createElement(Wrapper), "root", function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYield({ "only:one", "Sync effect" })
			v2.flushPassiveEffects()
			v2.unmountRootWithID("root")
			expect(v3).toFlushAndYieldThrough({ "layout unmount" })
			source.value = "two"
			expect(v3).toFlushAndYield({})
		end)
	end)
	it("should support inline selectors and updates that are processed after selector change", function()
		local source = createSource({
			a = "initial",
			b = "initial"
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3()
			return source.value.a
		end

		local function fn4()
			return source.value.b
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateB(p)
			local entries = LuauPolyfill.Object.entries(source.value)
			entries.b = p
			source.value = entries
		end

		local function App(p)
			local getSnapshot = p.getSnapshot
			return (useMutableSource(mutableSource, getSnapshot, fn2))
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				getSnapshot = fn3
			}))
		end)
		expect(root).toMatchRenderedOutput("initial")
		act(function()
			mutateB("Updated B") -- equivalent call inferred; original call site unknown
			root.render(v.createElement(App, {
				getSnapshot = fn4
			}))
		end)
		expect(root).toMatchRenderedOutput("Updated B")
		act(function()
			mutateB("Another update") -- equivalent call inferred; original call site unknown
		end)
		expect(root).toMatchRenderedOutput("Another update")
	end)
	it("should clear the update queue when getSnapshot changes with pending lower priority updates", function()
		local source = createSource({
			a = "initial",
			b = "initial"
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3()
			return source.value.a
		end

		local function fn4()
			return source.value.b
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateA(p)
			local v4 = LuauPolyfill.Object.assign({}, source.value)
			v4.a = p
			source.value = v4
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateB(p)
			local v4 = LuauPolyfill.Object.assign({}, source.value)
			v4.b = p
			source.value = v4
		end

		local function App(p)
			local toggle = p.toggle
			local v4 = useMutableSource
			local v6

			if toggle then
				v6 = fn4
			else
				v6 = fn3
			end

			return (toggle and "B: " or "A: ") .. v4(mutableSource, v6, fn2)
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				toggle = false
			}))
		end)
		expect(root).toMatchRenderedOutput("A: initial")
		act(function()
			v2.discreteUpdates(function()
				mutateA("Update") -- equivalent call inferred; original call site unknown
				mutateB("Update") -- equivalent call inferred; original call site unknown
				root.render(v.createElement(App, {
					toggle = true
				}))
			end)
			mutateA("OOPS! This mutation should be ignored") -- equivalent call inferred; original call site unknown
		end)
		expect(root).toMatchRenderedOutput("B: Update")
	end)
	it("should clear the update queue when source changes with pending lower priority updates", function()
		local source = createSource("initial")
		local source2 = createSource("initial")
		local mutableSource = createMutableSource(source, function(p)
			return p.versionA
		end)
		local mutableSource2 = createMutableSource(source2, function(p)
			return p.versionB
		end)

		local function App(p)
			local toggle = p.toggle
			local v4 = useMutableSource
			local v5

			if toggle then
				v5 = mutableSource2
			else
				v5 = mutableSource
			end

			return (toggle and "B: " or "A: ") .. v4(v5, fn, fn2)
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				toggle = false
			}))
		end)
		expect(root).toMatchRenderedOutput("A: initial")
		act(function()
			v2.discreteUpdates(function()
				source.value = "Update"
				source2.value = "Update"
				root.render(v.createElement(App, {
					toggle = true
				}))
			end)
			source.value = "OOPS! This mutation should be ignored"
		end)
		expect(root).toMatchRenderedOutput("B: Update")
	end)
	it("should always treat reading as potentially unsafe when getSnapshot changes between renders", function()
		local source = createSource({
			a = "foo",
			b = "bar"
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3()
			return source.value.a
		end

		local function fn4()
			return source.value.b
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateA(p)
			local v4 = LuauPolyfill.Object.assign({}, source.value)
			v4.a = p
			source.value = v4
		end

		local function App(p)
			local getSnapshotFirst = p.getSnapshotFirst
			local getSnapshotSecond = p.getSnapshotSecond
			local v4 = useMutableSource(mutableSource, getSnapshotFirst, fn2)
			local v5 = useMutableSource(mutableSource, getSnapshotSecond, fn2)
			local v6 = string.format("x: %s, y: %s", v4, v5)
			local v7 = getSnapshotFirst == getSnapshotSecond and v4 ~= v5 and "Oops, tearing!" or v6
			v.useEffect(function()
				v3.unstable_yieldValue(v7)
			end, { v7 })
			return v7
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				getSnapshotFirst = fn3,
				getSnapshotSecond = fn4
			}))
		end)
		expect(v3).toHaveYielded({ "x: foo, y: bar" })
		act(function()
			v2.discreteUpdates(function()
				mutateA("baz") -- equivalent call inferred; original call site unknown
				root.render(v.createElement(App, {
					getSnapshotFirst = fn3,
					getSnapshotSecond = fn3
				}))
			end)
			mutateA("bar") -- equivalent call inferred; original call site unknown
		end)
		expect(v3).toHaveYielded({ "x: bar, y: bar" })
	end)
	xit("getSnapshot changes and then source is mutated in between paint and passive effect phase", function()
		local source = createSource({
			a = "foo",
			b = "bar"
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateB(p)
			local entries = LuauPolyfill.Object.entries(source.value)
			entries.b = p
			source.value = entries
		end

		local function fn3()
			return source.value.a
		end

		local function fn4()
			return source.value.b
		end

		local function App(p)
			local getSnapshot = p.getSnapshot
			local v4 = useMutableSource(mutableSource, getSnapshot, fn2)
			v3.unstable_yieldValue("Render: " .. v4)
			v.useEffect(function()
				v3.unstable_yieldValue("Commit: " .. v4)
			end, { v4 })
			return v4
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				getSnapshot = fn3
			}))
		end)
		expect(v3).toHaveYielded({ "Render: foo", "Commit: foo" })
		act(function()
			root.render(v.createElement(App, {
				getSnapshot = fn4
			}))
			expect(v3).toFlushUntilNextPaint({ "Render: bar" })
			mutateB("baz") -- equivalent call inferred; original call site unknown
		end)
		expect(v3).toHaveYielded({
			"Render: bar",
			"Commit: bar",
			"Render: baz",
			"Commit: baz"
		})
		expect(root).toMatchRenderedOutput("baz")
	end)
	xit("getSnapshot changes and then source is mutated in between paint and passive effect phase, case 2", function()
		local source = createSource({
			a = "a0",
			b = "b0"
		})
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3()
			return source.value.a
		end

		local function fn4()
			return source.value.b
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function mutateA(p)
			local entries = LuauPolyfill.Object.entries(source.value)
			entries.A = p
			source.value = entries
		end

		local function App(p)
			local getSnapshotFirst = p.getSnapshotFirst
			local getSnapshotSecond = p.getSnapshotSecond
			local v4 = useMutableSource(mutableSource, getSnapshotFirst, fn2)
			local v5 = useMutableSource(mutableSource, getSnapshotSecond, fn2)
			return string.format("first: %s, second: %s", v4, v5)
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(App, {
				getSnapshotFirst = fn3,
				getSnapshotSecond = fn4
			}))
		end)
		expect(root.getChildrenAsJSX()).toEqual("first: a0, second: b0")
		act(function()
			root.render(v.createElement(App, {
				getSnapshotFirst = fn3,
				getSnapshotSecond = fn4
			}))
			expect(v3).toFlushUntilNextPaint({})
			v2.discreteUpdates(function()
				mutateA("a1") -- equivalent call inferred; original call site unknown
			end)
			expect(v3).toFlushUntilNextPaint({})
			expect(root.getChildrenAsJSX()).toEqual("first: a1, second: a1")
		end)
		expect(root.getChildrenAsJSX()).toEqual("first: a1, second: a1")
	end)
	xit(
		"if source is mutated after initial read but before subscription is set up, should still entangle all pending mutations even if snapshot of new subscription happens to match",
		function()
			local source = createSource({
				a = "a0",
				b = "b0"
			})
			local mutableSource = createMutableSource(source, function(p)
				return p.version
			end)

			local function fn3()
				return source.value.a
			end

			local function fn4()
				return source.value.b
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function mutateA(p)
				local v4 = LuauPolyfill.Object.assign({}, source.value)
				v4.a = p
				source.value = v4
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function mutateB(p)
				local v4 = LuauPolyfill.Object.assign({}, source.value)
				v4.b = p
				source.value = v4
			end

			local function Read(p)
				local getSnapshot = p.getSnapshot
				local v4 = useMutableSource(mutableSource, getSnapshot, fn2)
				v3.unstable_yieldValue(v4)
				return v4
			end

			local function Text(p)
				local text = p.text
				v3.unstable_yieldValue(text)
				return text
			end

			local root = v2.createRoot()
			act(function()
				root.render(v.createElement(Read, {
					getSnapshot = fn3
				}))
			end)
			expect(v3).toHaveYielded({ "a0" })
			expect(root).toMatchRenderedOutput("a0")
			act(function()
				root.render(v.createElement(v.Fragment, nil, v.createElement(Read, {
					getSnapshotFirst = fn3
				}), v.createElement(Read, {
					getSnapshotFirst = fn4
				}), v.createElement(Text, {
					text = "c"
				})))
				expect(v3).toFlushAndYieldThrough({ "a0", "b0" })
				mutateA("a1") -- equivalent call inferred; original call site unknown
				mutateB("b1") -- equivalent call inferred; original call site unknown
				v3.unstable_runWithPriority(v3.unstable_IdlePriority, function()
					mutateA("a0") -- equivalent call inferred; original call site unknown
					mutateB("b0") -- equivalent call inferred; original call site unknown
				end)
				expect(v3).toFlushUntilNextPaint({ "c" })
				expect(v3).toFlushUntilNextPaint({ "a0" })
				expect(root).toMatchRenderedOutput("a0b0c")
				expect(v3).toFlushAndYield({})
				expect(root).toMatchRenderedOutput("a0b0c")
			end)
		end
	)
	it("warns about functions being used as snapshot values", function()
		local source = createSource(function()
			return "a"
		end)
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)

		local function fn3()
			return source.value
		end

		local function Read()
			local v4 = useMutableSource(mutableSource, fn3, fn2)()
			v3.unstable_yieldValue(v4)
			return v4
		end

		local root = v2.createRoot()
		act(function()
			root.render(v.createElement(v.Fragment, nil, v.createElement(Read)))
			expect(function()
				expect(v3).toFlushAndYield({ "a" })
			end).toErrorDev("Mutable source should not return a function as the snapshot value.")
		end)
		expect(root).toMatchRenderedOutput("a")
	end)
	it("getSnapshot changes and then source is mutated during interleaved event", function()
		local useEffect = v.useEffect
		local complexSource = createComplexSource("1", "2")
		local mutableSource = createMutableSource(complexSource, function(p)
			return p.version
		end)
		local parentConfig2 = { function(p)
				return p.valueA
			end, function(p, p2)
				return p.subscribeA(p2)
			end }
		local v5 = { function(p)
				return p.valueB
			end, function(p, p2)
				return p.subscribeB(p2)
			end }

		local function Child(data)
			local parentConfig = data.parentConfig
			local childConfig = data.childConfig
			local parentValue = data.parentValue
			local v6 = childConfig[1]
			local v7 = childConfig[2]
			local v8 = useMutableSource(mutableSource, v6, v7)
			v3.unstable_yieldValue("Child: " .. v8)
			local v9 = string.format("%s, %s", parentValue, v8)
			local v10 = parentConfig == childConfig and parentValue ~= v8 and "Oops, tearing!" or v9
			useEffect(function()
				v3.unstable_yieldValue("Commit: " .. v10)
			end, { v10 })
			return v10
		end

		local function App(p)
			local parentConfig = p.parentConfig
			local childConfig = p.childConfig
			local v6 = parentConfig[1]
			local v7 = parentConfig[2]
			local parentValue = useMutableSource(mutableSource, v6, v7)
			v3.unstable_yieldValue("Parent: " .. parentValue)
			return v.createElement(Child, {
				parentConfig = parentConfig,
				childConfig = childConfig,
				parentValue = parentValue
			})
		end

		local root = v2.createRoot()
		Promise.try(function()
			act(function()
				root.render(v.createElement(App, {
					parentConfig = parentConfig2,
					childConfig = v5
				}))
			end)
		end):await()
		expect(v3).toHaveYielded({ "Parent: 1", "Child: 2", "Commit: 1, 2" })
		act(function()
			root.render(v.createElement(App, {
				parentConfig = v5,
				childConfig = v5
			}))
			expect(v3).toFlushAndYieldThrough({ "Parent: 2" })
			v3.unstable_runWithPriority(v3.unstable_IdlePriority, function()
				complexSource.valueB = "3"
			end)
			expect(v3).toFlushAndYieldThrough({ "Child: 2", "Commit: 2, 2" })
			expect(v3).toFlushAndYieldThrough({ "Parent: 3" })
			expect(v3).toFlushAndYield({ "Child: 3", "Commit: 3, 3" })
		end)
	end)
	it("should not tear with newly mounted component when updates were scheduled at a lower priority", function()
		local source = createSource("one")
		local mutableSource = createMutableSource(source, function(p)
			return p.version
		end)
		local v4 = nil
		local v5 = nil

		local function onRender()
			if v5 ~= nil then
				expect(v4).toEqual(v5)
			end
		end

		local function ComponentA()
			local v6 = useMutableSource(mutableSource, fn, fn2)
			v3.unstable_yieldValue(string.format("a:%s", v6))
			v.useEffect(function()
				v4 = v6
			end, { v6 })
			return v.createElement("div", nil, string.format("a:%s", v6))
		end

		local function ComponentB()
			local v6 = useMutableSource(mutableSource, fn, fn2)
			v3.unstable_yieldValue(string.format("b:%s", v6))
			v.useEffect(function()
				v5 = v6
			end, { v6 })
			return v.createElement("div", nil, string.format("b:%s", v6))
		end

		act(function()
			v2.render(v.createElement(v.Profiler, {
				id = "root",
				onRender = onRender
			}, v.createElement(ComponentA)), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
		end)
		expect(v3).toHaveYielded({ "a:one", "Sync effect" })
		expect(source.listenerCount).toEqual(1)
		act(function()
			v2.render(v.createElement(v.Profiler, {
				id = "root",
				onRender = onRender
			}, v.createElement(ComponentA), v.createElement(ComponentB)), function()
				return v3.unstable_yieldValue("Sync effect")
			end)
			expect(v3).toFlushAndYieldThrough({ "a:one", "b:one", "Sync effect" })
			expect(source.listenerCount).toEqual(1)
			v3.unstable_runWithPriority(v3.unstable_IdlePriority, function()
				source.value = "two"
			end)
			expect(v3).toFlushAndYield({ "a:two", "b:two" })
			expect(source.listenerCount).toEqual(2)
		end)
	end)

	if ReactGlobals.__DEV__ then
		describe("dev warnings", function()
			it("should warn if the subscribe function does not return an unsubscribe function", function()
				local source = createSource("one")
				local mutableSource = createMutableSource(source, function(p)
					return p.version
				end)

				local function fn3() end

				expect(function()
					act(function()
						v2.render(v.createElement(Component, {
							label = "only",
							getSnapshot = fn,
							mutableSource = mutableSource,
							subscribe = fn3
						}))
					end)
				end).toErrorDev("Mutable source subscribe function must return an unsubscribe function.")
			end)
		end)
	end
end)