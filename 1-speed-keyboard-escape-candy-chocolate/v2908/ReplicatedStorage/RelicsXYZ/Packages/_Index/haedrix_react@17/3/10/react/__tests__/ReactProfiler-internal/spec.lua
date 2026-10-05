local v = nil
local reactFeatureFlags = nil
local v2 = nil
local v3 = nil
local v4 = nil
local v5 = nil
local unstable_concurrentAct = nil
local tracing = nil
local v6 = nil
local fn
local fn2
local fn3
local v7 = nil
local v8 = nil
local setTimeout = nil
local set = nil
local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local Promise = require(parent.Dev.Promise)

local function loadModules(data)
	local enableProfilerTimer = data.enableProfilerTimer == nil or data.enableProfilerTimer
	local enableProfilerCommitHooks = data.enableProfilerCommitHooks == nil or data.enableProfilerCommitHooks
	local enableSchedulerTracing = data.enableSchedulerTracing == nil or data.enableSchedulerTracing
	local replayFailedUnitOfWorkWithInvokeGuardedCallback

	if data.replayFailedUnitOfWorkWithInvokeGuardedCallback == nil then
		replayFailedUnitOfWorkWithInvokeGuardedCallback = false
	else
		replayFailedUnitOfWorkWithInvokeGuardedCallback = data.replayFailedUnitOfWorkWithInvokeGuardedCallback
	end

	local useNoopRenderer

	if data.useNoopRenderer == nil then
		useNoopRenderer = false
	else
		useNoopRenderer = data.useNoopRenderer
	end

	local Shared = require(parent.Shared)
	reactFeatureFlags = Shared.ReactFeatureFlags
	reactFeatureFlags.enableProfilerTimer = enableProfilerTimer
	reactFeatureFlags.enableProfilerCommitHooks = enableProfilerCommitHooks
	reactFeatureFlags.enableSchedulerTracing = enableSchedulerTracing
	reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = replayFailedUnitOfWorkWithInvokeGuardedCallback
	local LuauPolyfill = require(parent.LuauPolyfill)
	setTimeout = LuauPolyfill.setTimeout
	set = LuauPolyfill.Set
	local parentModule = require(script.Parent.Parent)
	v = parentModule
	local Scheduler = require(parent.Dev.Scheduler)
	v3 = Scheduler
	tracing = v3.tracing
	local ReactCache = require(parent.Dev.ReactCache)
	v4 = ReactCache

	if useNoopRenderer then
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		v5 = nil
		unstable_concurrentAct = nil
	else
		v2 = nil
		local ReactTestRenderer = require(parent.Dev.ReactTestRenderer)
		v5 = ReactTestRenderer
		unstable_concurrentAct = v5.unstable_concurrentAct
	end

	v6 = v.Component:extend("AdvanceTime")
	v6.defaultProps = {
		byAmount = 10,
		shouldComponentUpdate = true
	}

	function v6.shouldComponentUpdate(_, p)
		return p.shouldComponentUpdate
	end

	function v6.render(p)
		v3.unstable_advanceTime(p.props.byAmount)
		return p.props.children or nil
	end

	v8 = nil
	v7 = v4.unstable_createResource(function(list)
		local v12 = list[1]
		local v13 = list[2] or 0
		v8 = Promise.new(function(callback, _)
			setTimeout(function()
				v3.unstable_yieldValue(string.format("Promise resolved [%s]", (tostring(v12))))
				callback(v12)
			end, v13)
		end)
		return v8
	end, function(list)
		return list[1]
	end)

	fn = function(p)
		local ms = p.ms
		local text = p.text
		local success, result = pcall(function()
			v7.read({ text, ms })
			v3.unstable_yieldValue(string.format("AsyncText [%s]", text))
			return text
		end)

		if not success then
			if typeof(result.andThen) == "function" then
				v3.unstable_yieldValue(string.format("Suspend [%s]", text))
			else
				v3.unstable_yieldValue(string.format("Error [%s]", text))
			end

			error(result)
		end
	end

	fn3 = function(p)
		local text = p.text
		v3.unstable_yieldValue(string.format("Text [%s]", text))
		return text
	end

	fn2 = function()
		v.useEffect(function() end)
		return nil
	end
end

describe("Profiler", function()
	describe("works in profiling and non-profiling bundles", function()
		for _, v9 in { true, false } do
			for _, v10 in { true, false } do
				local enableProfilerTimer = v10
				local enableSchedulerTracing = v9
				describe(
					"enableSchedulerTracing:" .. (v9 and "enabled" or "disabled") .. " enableProfilerTimer:" .. (v10 and "enabled" or "disabled") .. "}",
					function()
						if ReactGlobals.__DEV__ and enableProfilerTimer then
							beforeEach(function()
								jest.resetModules()
								loadModules({
									enableSchedulerTracing = enableSchedulerTracing,
									enableProfilerTimer = enableProfilerTimer,
									replayFailedUnitOfWorkWithInvokeGuardedCallback = false
								})
							end)
						end

						if ReactGlobals.__DEV__ and enableProfilerTimer then
							it("should warn if required params are missing", function()
								expect(function()
									v5.create(v.createElement(v.Profiler))
								end).toErrorDev("Profiler must specify an \"id\" as a prop", {
									withoutStack = true
								})
							end)
							it("should support an empty Profiler (with no children)", function()
								expect(function()
									v5.create(v.createElement(v.Profiler, {
										id = "label",
										onRender = jest.fn()
									})):toJSON()
								end).never.toThrow()
							end)
							it("should render children", function()
								local function fn4(p)
									local label = p.label
									return v.createElement("span", nil, label)
								end

								local v13 = v5.create(v.createElement(
									"div",
									nil,
									v.createElement("span", nil, "outside span"),
									v.createElement(v.Profiler, {
										id = "label",
										onRender = jest.fn()
									}, v.createElement("span", nil, "inside span"), v.createElement(fn4, {
										label = "function component"
									}))
								))
								expect(function()
									v13:toJSON()
								end).never.toThrow()
							end)
							it("should support nested Profilers", function()
								local function fn4(p)
									local label = p.label
									return v.createElement("div", nil, label)
								end

								local extended = v.Component:extend("ClassComponent")

								function extended.render(p)
									return v.createElement("block", nil, p.props.label)
								end

								local v13 = v5.create(v.createElement(v.Profiler, {
									id = "outer",
									onRender = jest.fn()
								}, v.createElement(fn4, {
									label = "outer function component"
								}), v.createElement(v.Profiler, {
									id = "inner",
									onRender = jest.fn()
								}, v.createElement(extended, {
									label = "inner class component"
								}), v.createElement("span", nil, "inner span"))))
								expect(function()
									v13:toJSON()
								end).never.toThrow()
							end)
						end
					end
				)
			end
		end
	end)

	for _, v9 in { true, false } do
		local enableSchedulerTracing = v9
		describe("onRender enableSchedulerTracing:" .. (v9 and "enabled" or "disabled"), function()
			beforeEach(function()
				jest.resetModules()
				loadModules({
					enableSchedulerTracing = enableSchedulerTracing,
					replayFailedUnitOfWorkWithInvokeGuardedCallback = false
				})
			end)
			it("should handle errors thrown", function()
				local onRender = jest.fn(function(p)
					if p == "throw" then
						error("expected")
					end
				end)
				local v12 = false
				local extended = v.Component:extend("ClassComponent")

				function extended.componentDidMount(p)
					v12 = true
				end

				function extended.render(p)
					return p.props.children
				end

				expect(function()
					v5.create(v.createElement(extended, nil, v.createElement(v.Profiler, {
						id = "do-not-throw",
						onRender = onRender
					}, v.createElement(v.Profiler, {
						id = "throw",
						onRender = onRender
					}, v.createElement("div")))))
				end).toThrow("expected")
				expect(v12).toBe(true)
				expect(onRender).toHaveBeenCalledTimes(2)
			end)
			it("is not invoked until the commit phase", function()
				local onRender = jest.fn()

				local function fn4(p)
					local value = p.value
					v3.unstable_yieldValue(value)
					return nil
				end

				v5.create(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(fn4, {
					value = "first"
				}), v.createElement(fn4, {
					value = "last"
				})), {
					unstable_isConcurrent = true
				})
				expect(v3).toFlushAndYieldThrough({ "first" })
				expect(onRender).toHaveBeenCalledTimes(0)
				expect(v3).toFlushAndYield({ "last" })
				expect(onRender).toHaveBeenCalledTimes(1)
			end)
			it("does not report work done on a sibling", function()
				local onRender = jest.fn()
				local memo = v.memo(function()
					v3.unstable_advanceTime(10)
					return nil
				end, function()
					return true
				end)
				local fn4

				local function ProfilerSibling()
					local state, setState = v.useState(0)

					fn4 = function()
						setState(state + 1)
					end

					return nil
				end

				local function App()
					return v.createElement(v.Fragment, nil, v.createElement(v.Profiler, {
						id = "test",
						onRender = onRender
					}, v.createElement(memo)), v.createElement(ProfilerSibling))
				end

				local v12 = v5.create(v.createElement(App))
				expect(onRender).toHaveBeenCalledTimes(1)
				local call = onRender.mock.calls[1]
				expect(call).toHaveLength(enableSchedulerTracing and 7 or 6)
				expect(call[1]).toBe("test")
				expect(call[2]).toBe("mount")
				expect(call[3]).toBe(10)
				expect(call[4]).toBe(10)
				expect(call[5]).toBe(0)
				expect(call[6]).toBe(10)
				expect(call[7]).toEqual((function()
					if enableSchedulerTracing then
						return set.new()
					end

					return nil
				end)())
				onRender:mockReset()
				v3.unstable_advanceTime(20)
				v12.update(v.createElement(App))
				expect(onRender).never.toHaveBeenCalled()
				v3.unstable_advanceTime(20)
				unstable_concurrentAct(fn4)
				expect(onRender).never.toHaveBeenCalled()
			end)
			it("logs render times for both mount and update", function()
				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				local v12 = v5.create(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6)))
				expect(onRender).toHaveBeenCalledTimes(1)
				local call = onRender.mock.calls[1]
				expect(call).toHaveLength(enableSchedulerTracing and 7 or 6)
				expect(call[1]).toBe("test")
				expect(call[2]).toBe("mount")
				expect(call[3]).toBe(10)
				expect(call[4]).toBe(10)
				expect(call[5]).toBe(5)
				expect(call[6]).toBe(15)
				expect(call[7]).toEqual((function()
					if enableSchedulerTracing then
						return set.new()
					end

					return nil
				end)())
				onRender.mockReset()
				v3.unstable_advanceTime(20)
				v12.update(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6)))
				expect(onRender).toHaveBeenCalledTimes(1)
				local call2 = onRender.mock.calls[1]
				expect(call2).toHaveLength(enableSchedulerTracing and 7 or 6)
				expect(call2[1]).toBe("test")
				expect(call2[2]).toBe("update")
				expect(call2[3]).toBe(10)
				expect(call2[4]).toBe(10)
				expect(call2[5]).toBe(35)
				expect(call2[6]).toBe(45)
				expect(call2[7]).toEqual((function()
					if enableSchedulerTracing then
						return set.new()
					end

					return nil
				end)())
				onRender.mockReset()
				v3.unstable_advanceTime(20)
				v12.update(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 4
				})))
				expect(onRender).toHaveBeenCalledTimes(1)
				local call3 = onRender.mock.calls[1]
				expect(call3).toHaveLength(enableSchedulerTracing and 7 or 6)
				expect(call3[1]).toBe("test")
				expect(call3[2]).toBe("update")
				expect(call3[3]).toBe(4)
				expect(call3[4]).toBe(4)
				expect(call3[5]).toBe(65)
				expect(call3[6]).toBe(69)
				expect(call3[7]).toEqual((function()
					if enableSchedulerTracing then
						return set.new()
					end

					return nil
				end)())
			end)
			it("includes render times of nested Profilers in their parent times", function()
				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				v5.create(v.createElement(v.Fragment, nil, v.createElement(v.Profiler, {
					id = "parent",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 10
				}, v.createElement(v.Profiler, {
					id = "child",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 20
				}))))))
				expect(onRender).toHaveBeenCalledTimes(2)
				local call = onRender.mock.calls[1]
				local call2 = onRender.mock.calls[2]
				expect(call[1]).toBe("child")
				expect(call2[1]).toBe("parent")
				expect(call[3]).toBe(20)
				expect(call[4]).toBe(20)
				expect(call[5]).toBe(15)
				expect(call[6]).toBe(35)
				expect(call2[3]).toBe(30)
				expect(call2[4]).toBe(30)
				expect(call2[5]).toBe(5)
				expect(call2[6]).toBe(35)
			end)
			it("traces sibling Profilers separately", function()
				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				v5.create(v.createElement(v.Fragment, nil, v.createElement(v.Profiler, {
					id = "first",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 20
				})), v.createElement(v.Profiler, {
					id = "second",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 5
				}))))
				expect(onRender).toHaveBeenCalledTimes(2)
				local call = onRender.mock.calls[1]
				local call2 = onRender.mock.calls[2]
				expect(call[1]).toBe("first")
				expect(call2[1]).toBe("second")
				expect(call[3]).toBe(20)
				expect(call[4]).toBe(20)
				expect(call[5]).toBe(5)
				expect(call[6]).toBe(30)
				expect(call2[3]).toBe(5)
				expect(call2[4]).toBe(5)
				expect(call2[5]).toBe(25)
				expect(call2[6]).toBe(30)
			end)
			it("does not include time spent outside of profile root", function()
				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				v5.create(v.createElement(v.Fragment, nil, v.createElement(v6, {
					byAmount = 20
				}), v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 5
				})), v.createElement(v6, {
					byAmount = 20
				})))
				expect(onRender).toHaveBeenCalledTimes(1)
				local call = onRender.mock.calls[1]
				expect(call[1]).toBe("test")
				expect(call[3]).toBe(5)
				expect(call[4]).toBe(5)
				expect(call[5]).toBe(25)
				expect(call[6]).toBe(50)
			end)
			it("is not called when blocked by sCU false", function()
				local onRender = jest.fn()
				local v12 = nil
				local extended = v.Component:extend("Updater")

				function extended:init()
					self.state = {}
				end

				function extended.render(p)
					v12 = p
					return p.props.children
				end

				local v13 = v5.create(v.createElement(v.Profiler, {
					id = "outer",
					onRender = onRender
				}, v.createElement(extended, nil, v.createElement(v.Profiler, {
					id = "inner",
					onRender = onRender
				}, v.createElement("div")))))
				expect(onRender).toHaveBeenCalledTimes(2)
				onRender:mockReset()
				v13.unstable_flushSync(function()
					v12:setState({
						count = 1
					})
				end)
				expect(onRender).toHaveBeenCalledTimes(1)
				expect(onRender.mock.calls[1][1]).toBe("outer")
			end)
			it("decreases actual time but not base time when sCU prevents an update", function()
				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				local v12 = v5.create(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 10
				}, v.createElement(v6, {
					byAmount = 13,
					shouldComponentUpdate = false
				}))))
				expect(onRender).toHaveBeenCalledTimes(1)
				v3.unstable_advanceTime(30)
				v12.update(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(v6, {
					byAmount = 4
				}, v.createElement(v6, {
					byAmount = 7,
					shouldComponentUpdate = false
				}))))
				expect(onRender).toHaveBeenCalledTimes(2)
				local call = onRender.mock.calls[1]
				local call2 = onRender.mock.calls[2]
				expect(call[2]).toBe("mount")
				expect(call[3]).toBe(23)
				expect(call[4]).toBe(23)
				expect(call[5]).toBe(5)
				expect(call[6]).toBe(28)
				expect(call2[2]).toBe("update")
				expect(call2[3]).toBe(4)
				expect(call2[4]).toBe(17)
				expect(call2[5]).toBe(58)
				expect(call2[6]).toBe(62)
			end)
			it("includes time spent in render phase lifecycles", function()
				local extended = v.Component:extend("WithLifecycles")

				function extended:init()
					self.state = {}
				end

				function extended.getDerivedStateFromProps()
					v3.unstable_advanceTime(3)
					return nil
				end

				function extended.shouldComponentUpdate(p)
					v3.unstable_advanceTime(7)
					return true
				end

				function extended.render(p)
					v3.unstable_advanceTime(5)
					return nil
				end

				local onRender = jest.fn()
				v3.unstable_advanceTime(5)
				local v12 = v5.create(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(extended)))
				v3.unstable_advanceTime(15)
				v12.update(v.createElement(v.Profiler, {
					id = "test",
					onRender = onRender
				}, v.createElement(extended)))
				expect(onRender).toHaveBeenCalledTimes(2)
				local call = onRender.mock.calls[1]
				local call2 = onRender.mock.calls[2]
				expect(call[2]).toBe("mount")
				expect(call[3]).toBe(8)
				expect(call[4]).toBe(8)
				expect(call[5]).toBe(5)
				expect(call[6]).toBe(13)
				expect(call2[2]).toBe("update")
				expect(call2[3]).toBe(15)
				expect(call2[4]).toBe(15)
				expect(call2[5]).toBe(28)
				expect(call2[6]).toBe(43)
			end)
			describe("with regard to interruptions", function()
				for k, v11 in { true, false } do
					local replayFailedUnitOfWorkWithInvokeGuardedCallback = v11
					describe(
						"replayFailedUnitOfWorkWithInvokeGuardedCallback " .. (v11 and "enabled" or "disabled"),
						function()
							beforeEach(function()
								jest.resetModules()
								loadModules({
									replayFailedUnitOfWorkWithInvokeGuardedCallback = replayFailedUnitOfWorkWithInvokeGuardedCallback
								})
							end)
							it("should accumulate actual time after an error handled by componentDidCatch()", function()
								local onRender = jest.fn()

								local function fn4(p)
									local unused = p.unused
									v3.unstable_advanceTime(3)
									error("expected error")
								end

								local extended = v.Component:extend("ErrorBoundary")

								function extended:init()
									self.state = {
										error_ = nil
									}
								end

								function extended.componentDidCatch(object, error_)
									object:setState({
										error_ = error_
									})
								end

								function extended.render(p)
									v3.unstable_advanceTime(2)
									return (function()
										if p.state.error_ == nil then
											return p.props.children
										end

										return v.createElement(v6, {
											byAmount = 20
										})
									end)()
								end

								v3.unstable_advanceTime(5)
								v5.create(v.createElement(v.Profiler, {
									id = "test",
									onRender = onRender
								}, v.createElement(extended, nil, v.createElement(v6, {
									byAmount = 9
								}), v.createElement(fn4))))
								expect(onRender).toHaveBeenCalledTimes(2)
								local call = onRender.mock.calls[1]
								local call2 = onRender.mock.calls[2]
								expect(call[2]).toBe("mount")
								expect(call[3]).toBe(14)
								expect(call[4]).toBe(2)
								expect(call[5]).toBe(5)
								expect(call[6]).toBe(ReactGlobals.__DEV__ and replayFailedUnitOfWorkWithInvokeGuardedCallback and 22 or 19)
								expect(call2[2]).toBe("update")
								expect(call2[3]).toBe(22)
								expect(call2[4]).toBe(22)
								expect(call2[5]).toBe(ReactGlobals.__DEV__ and replayFailedUnitOfWorkWithInvokeGuardedCallback and 22 or 19)
								expect(call2[6]).toBe(ReactGlobals.__DEV__ and replayFailedUnitOfWorkWithInvokeGuardedCallback and 44 or 41)
							end)
							it(
								"should accumulate actual time after an error handled by getDerivedStateFromError()",
								function()
									local onRender = jest.fn()

									local function fn4(p)
										local unused = p.unused
										v3.unstable_advanceTime(10)
										error("expected error")
									end

									local extended = v.Component:extend("ErrorBoundary")

									function extended:init()
										self.state = {
											error_ = nil
										}
									end

									function extended.getDerivedStateFromError(error_)
										return {
											error_ = error_
										}
									end

									function extended.render(p)
										v3.unstable_advanceTime(2)
										return (function()
											if p.state.error_ == nil then
												return p.props.children
											end

											return v.createElement(v6, {
												byAmount = 20
											})
										end)()
									end

									v3.unstable_advanceTime(5)
									v5.create(v.createElement(v.Profiler, {
										id = "test",
										onRender = onRender
									}, v.createElement(extended, nil, v.createElement(v6, {
										byAmount = 5
									}), v.createElement(fn4))))
									expect(onRender).toHaveBeenCalledTimes(1)
									local call = onRender.mock.calls[1]
									expect(call[2]).toBe("mount")
									expect(call[3]).toBe(39)
									expect(call[4]).toBe(22)
									expect(call[5]).toBe(5)
									expect(call[6]).toBe(ReactGlobals.__DEV__ and replayFailedUnitOfWorkWithInvokeGuardedCallback and 54 or 44)
								end
							)
							it("should reset the fiber stack correct after a \"complete\" phase error", function()
								jest.resetModules()
								loadModules({
									useNoopRenderer = true,
									replayFailedUnitOfWorkWithInvokeGuardedCallback = replayFailedUnitOfWorkWithInvokeGuardedCallback
								})
								v2.render(v.createElement(v.Profiler, {
									id = "profiler",
									onRender = jest.fn()
								}, v.createElement("errorInCompletePhase", nil, "hi")))
								expect(v3).toFlushAndThrow("Error in host config.")
								v2.render(v.createElement(v.Profiler, {
									id = "profiler",
									onRender = jest.fn()
								}, v.createElement("errorInCompletePhase", nil, v.createElement("span", nil, "hi"))))
								expect(v3).toFlushAndThrow("Error in host config.")
								v2.render(v.createElement(v.Profiler, {
									id = "profiler",
									onRender = jest.fn()
								}, v.createElement("span", nil, "hi")))
								expect(v3).toFlushWithoutYielding()
							end)
						end
					)
				end
			end)
		end)
	end
end)