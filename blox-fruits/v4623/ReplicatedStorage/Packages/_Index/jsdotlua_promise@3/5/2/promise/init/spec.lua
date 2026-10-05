return function()
	local parentModule = require(script.Parent)
	parentModule.TEST = true
	local bindableEvent = Instance.new("BindableEvent")
	parentModule._timeEvent = bindableEvent.Event

	-- equivalent calls inferred from this helper; original call sites unknown
	local function waitForEvents()
		task.defer(coroutine.running())
		coroutine.yield()
	end

	local total = 0

	function parentModule._getTime()
		return total
	end

	local function advanceTime(value)
		local v = value or 0.016666666666666666
		total += v
		bindableEvent:Fire(v)
		waitForEvents() -- equivalent call inferred; original call site unknown
	end

	local function pack(...)
		return select("#", ...), { ... }
	end

	describe("Promise.Status", function()
		it("should error if indexing nil value", function()
			expect(function()
				local _ = parentModule.Status.wrong
			end).to.throw()
		end)
	end)
	describe("Unhandled rejection signal", function()
		it("should call unhandled rejection callbacks", function()
			local v = parentModule.new(function(_, callback)
				callback(1, 2)
			end)
			local count = 0

			local function callback(p, p2, p3)
				count += 1
				expect(p).to.equal(v)
				expect(p2).to.equal(1)
				expect(p3).to.equal(2)
			end

			local v2 = parentModule.onUnhandledRejection(callback)
			advanceTime()
			expect(count).to.equal(1)
			v2()
			parentModule.new(function(_, callback2)
				callback2(3, 4)
			end)
			advanceTime()
			expect(count).to.equal(1)
		end)
	end)
	describe("Promise.new", function()
		it("should instantiate with a callback", function()
			local v = parentModule.new(function() end)
			expect(v).to.be.ok()
		end)
		it("should invoke the given callback with resolve and reject", function()
			local count = 0
			local v = nil
			local v2 = nil
			local v3 = parentModule.new(function(p, p2)
				count += 1
				v = p
				v2 = p2
			end)
			expect(v3).to.be.ok()
			expect(count).to.equal(1)
			expect(v).to.be.a("function")
			expect(v2).to.be.a("function")
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
		end)
		it("should resolve promises on resolve()", function()
			local count = 0
			local v = parentModule.new(function(callback)
				count += 1
				callback()
			end)
			expect(v).to.be.ok()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
		end)
		it("should reject promises on reject()", function()
			local count = 0
			local v = parentModule.new(function(_, callback)
				count += 1
				callback()
			end)
			expect(v).to.be.ok()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
		end)
		it("should reject on error in callback", function()
			local count = 0
			local v = parentModule.new(function()
				count += 1
				error("hahah")
			end)
			expect(v).to.be.ok()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(tostring(v._values[1]):find("hahah")).to.be.ok()
			expect(tostring(v._values[1]):find("init.spec")).to.be.ok()
			expect(tostring(v._values[1]):find("runExecutor")).to.be.ok()
		end)
		it("should work with C functions", function()
			expect(function()
				parentModule.new(tick):andThen(tick)
			end).to.never.throw()
		end)
		it("should have a nice tostring", function()
			expect(tostring(parentModule.resolve()):gmatch("Promise(Resolved)")).to.be.ok()
		end)
		it("should allow yielding", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.new(function(callback)
				bindableEvent2.Event:Wait()
				callback(5)
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire()
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal(5)
		end)
		it("should preserve stack traces of resolve-chained promises", function()
			local function nestedCall(message)
				error(message)
			end

			local v = parentModule.new(function(callback)
				callback(parentModule.new(function()
					error("sample text")
				end))
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			local v2 = tostring(v._values[1])
			expect(v2:find("sample text")).to.be.ok()
			expect(v2:find("nestedCall")).to.be.ok()
			expect(v2:find("runExecutor")).to.be.ok()
			expect(v2:find("runPlanNode")).to.be.ok()
			expect(v2:find("...Rejected because it was chained to the following Promise, which encountered an error:")).to.be.ok()
		end)
		it("should report errors from Promises with _error (< v2)", function()
			local v = parentModule.reject()
			v._error = "Sample error"
			local v2 = parentModule.resolve():andThenReturn(v)
			expect(v2:getStatus()).to.equal(parentModule.Status.Rejected)
			local v3 = tostring(v2._values[1])
			expect(v3:find("Sample error")).to.be.ok()
			expect(v3:find("...Rejected because it was chained to the following Promise, which encountered an error:")).to.be.ok()
			expect(v3:find("%[No stack trace available")).to.be.ok()
		end)
		it("should allow callable tables", function()
			local v2 = false
			parentModule.new((setmetatable({}, {
				__call = function(_, callback)
					callback(1)
				end
			}))):andThen((setmetatable({}, {
				__call = function(_, p)
					expect(p).to.equal(1)
					v2 = true
				end
			})))
			expect(v2).to.equal(true)
		end)
		it("should close the thread after resolve", function()
			local count = 0
			parentModule.new(function(callback)
				count += 1
				callback()
				parentModule.delay(1):await()
				count += 1
			end)
			task.wait(1)
			expect(count).to.equal(1)
		end)
	end)
	describe("Promise.defer", function()
		it("should execute after the time event", function()
			local count = 0
			local v = parentModule.defer(function(callback, p, p2, p3)
				expect((type(callback))).to.equal("function")
				expect((type(p))).to.equal("function")
				expect((type(p2))).to.equal("function")
				expect((type(p3))).to.equal("nil")
				count += 1
				callback("foo")
			end)
			expect(count).to.equal(0)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			advanceTime()
			expect(count).to.equal(1)
		end)
	end)
	describe("Promise.delay", function()
		it("should schedule promise resolution", function()
			local v = parentModule.delay(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
		end)
		it("should allow for delays to be cancelled", function()
			local v = parentModule.delay(2)
			parentModule.delay(1):andThen(function()
				v:cancel()
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
			advanceTime(1)
		end)
	end)
	describe("Promise.resolve", function()
		it("should immediately resolve with a value", function()
			local resolved = parentModule.resolve(5, 6)
			expect(resolved).to.be.ok()
			expect(resolved:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(resolved._values[1]).to.equal(5)
			expect(resolved._values[2]).to.equal(6)
		end)
		it("should chain onto passed promises", function()
			local resolved = parentModule.resolve(parentModule.new(function(_, callback)
				callback(7)
			end))
			expect(resolved).to.be.ok()
			expect(resolved:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(resolved._values[1]).to.equal(7)
		end)
	end)
	describe("Promise.reject", function()
		it("should immediately reject with a value", function()
			local v = parentModule.reject(6, 7)
			expect(v).to.be.ok()
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v._values[1]).to.equal(6)
			expect(v._values[2]).to.equal(7)
		end)
		it("should pass a promise as-is as an error", function()
			local v = parentModule.new(function(callback)
				callback(6)
			end)
			local v2 = parentModule.reject(v)
			expect(v2).to.be.ok()
			expect(v2:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v2._values[1]).to.equal(v)
		end)
	end)
	describe("Promise:andThen", function()
		it("should allow yielding", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.resolve():andThen(function()
				bindableEvent2.Event:Wait()
				return 5
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire()
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal(5)
		end)
		it("should run andThens on a new thread", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = nil
			local v2 = parentModule.new(function(p)
				v = p
			end)
			local v3 = v2:andThen(function()
				bindableEvent2.Event:Wait()
				return 5
			end)
			local v4 = v2:andThen(function()
				return "foo"
			end)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			v()
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v4._values[1]).to.equal("foo")
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
		end)
		it("should chain onto resolved promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local resolved = parentModule.resolve(5)
			local v3 = resolved:andThen(function(...)
				v2, v = pack(...)
				count += 1
			end, function()
				count2 += 1
			end)
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(5)
			expect(resolved).to.be.ok()
			expect(resolved:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(resolved._values[1]).to.equal(5)
			expect(v3).to.be.ok()
			expect(v3).never.to.equal(resolved)
			expect(v3:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v3._values).to.equal(0)
		end)
		it("should chain onto rejected promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = parentModule.reject(5)
			local v4 = v3:andThen(function(...)
				count2 += 1
			end, function(...)
				v2, v = pack(...)
				count += 1
			end)
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(5)
			expect(v3).to.be.ok()
			expect(v3:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v3._values[1]).to.equal(5)
			expect(v4).to.be.ok()
			expect(v4).never.to.equal(v3)
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v4._values).to.equal(0)
		end)
		it("should reject on error in callback", function()
			local count = 0
			local v = parentModule.resolve(1):andThen(function()
				count += 1
				error("hahah")
			end)
			expect(v).to.be.ok()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(tostring(v._values[1]):find("hahah")).to.be.ok()
			expect(tostring(v._values[1]):find("init.spec")).to.be.ok()
			expect(tostring(v._values[1]):find("runExecutor")).to.be.ok()
		end)
		it("should chain onto asynchronously resolved promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = nil
			local v4 = parentModule.new(function(p)
				v3 = p
			end)
			local v5 = v4:andThen(function(...)
				v = { ... }
				v2 = select("#", ...)
				count += 1
			end, function()
				count2 += 1
			end)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			v3(6)
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(6)
			expect(v4).to.be.ok()
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v4._values[1]).to.equal(6)
			expect(v5).to.be.ok()
			expect(v5).never.to.equal(v4)
			expect(v5:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v5._values).to.equal(0)
		end)
		it("should chain onto asynchronously rejected promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = nil
			local v4 = parentModule.new(function(_, p)
				v3 = p
			end)
			local v5 = v4:andThen(function()
				count2 += 1
			end, function(...)
				v = { ... }
				v2 = select("#", ...)
				count += 1
			end)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			v3(6)
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(6)
			expect(v4).to.be.ok()
			expect(v4:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v4._values[1]).to.equal(6)
			expect(v5).to.be.ok()
			expect(v5).never.to.equal(v4)
			expect(v5:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v5._values).to.equal(0)
		end)
		it("should propagate errors through multiple levels", function()
			local v = nil
			local v2 = nil
			local v3 = nil
			parentModule.new(function(_, callback)
				callback(1, 2, 3)
			end):andThen(function() end):catch(function(p, p2, p3)
				v = p
				v2 = p2
				v3 = p3
			end)
			expect(v).to.equal(1)
			expect(v2).to.equal(2)
			expect(v3).to.equal(3)
		end)
		itSKIP("should not call queued callbacks from a cancelled sub-promise", function()
			local v = nil
			local count = 0
			local v2 = parentModule.new(function(p)
				v = p
			end)
			v2:andThen(function()
				count += 1
			end)
			v2:andThen(function()
				count += 1
			end):cancel()
			v("foo")
			expect(count).to.equal(1)
		end)
	end)
	describe("Promise:cancel", function()
		it("should mark promises as cancelled and not resolve or reject them", function()
			local count = 0
			local count2 = 0
			local v = parentModule.new(function() end):andThen(function()
				count += 1
			end):finally(function()
				count2 += 1
			end)
			v:cancel()
			v:cancel()
			expect(count).to.equal(0)
			expect(count2).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should call the cancellation hook once", function()
			local count = 0
			local v = parentModule.new(function(_, _, callback)
				callback(function()
					count += 1
				end)
			end)
			v:cancel()
			v:cancel()
			expect(count).to.equal(1)
		end)
		it("should propagate cancellations", function()
			local v = parentModule.new(function() end)
			local v2 = v:andThen()
			local v3 = v:andThen()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			v2:cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			v3:cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v3:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should affect downstream promises", function()
			local v = parentModule.new(function() end)
			local v2 = v:andThen()
			v:cancel()
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should track consumers", function()
			local v = parentModule.new(function() end)
			local resolved = parentModule.resolve()
			local v2 = resolved:andThen(function()
				return v
			end)
			local v3 = parentModule.new(function(callback)
				callback(v2)
			end)
			local v4 = v3:andThen(function() end)
			expect(v2._parent).to.never.equal(resolved)
			expect(v3._parent).to.never.equal(v2)
			expect(v3._consumers[v4]).to.be.ok()
			expect(v4._parent).to.equal(v3)
		end)
		it("should cancel resolved pending promises", function()
			local v = parentModule.new(function() end)
			local v2 = parentModule.new(function(callback)
				callback(v)
			end):finally(function() end)
			v2:cancel()
			expect(v._status).to.equal(parentModule.Status.Cancelled)
			expect(v2._status).to.equal(parentModule.Status.Cancelled)
		end)
		it("should close the promise thread", function()
			local count = 0
			parentModule.new(function()
				count += 1
				parentModule.delay(1):await()
				count += 1
			end):cancel()
			advanceTime(2)
			expect(count).to.equal(1)
		end)
	end)
	describe("Promise:finally", function()
		it("should be called upon resolve, reject, or cancel", function()
			local count = 0

			local function finally()
				count += 1
			end

			parentModule.new(function(callback, _)
				callback()
			end):finally(finally)
			parentModule.resolve():andThen(function() end):finally(finally):finally(finally)
			parentModule.reject():finally(finally)
			parentModule.new(function() end):finally(finally):cancel()
			expect(count).to.equal(5)
		end)
		itSKIP("should not forward return values", function()
			local v = nil
			parentModule.resolve(2):finally(function()
				return 1
			end):andThen(function(p)
				v = p
			end)
			expect(v).to.equal(2)
		end)
		itSKIP("should not consume rejections", function()
			local v = false
			local v2 = false
			parentModule.reject(5):finally(function()
				return 42
			end):andThen(function()
				v2 = true
			end):catch(function(p)
				v = true
				expect(p).to.equal(5)
			end)
			expect(v).to.equal(true)
			expect(v2).to.equal(false)
		end)
		itSKIP("should wait for returned promises", function()
			local v = nil
			local v2 = parentModule.reject("foo"):finally(function()
				return parentModule.new(function(p)
					v = p
				end)
			end)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			v()
			expect(v2:getStatus()).to.equal(parentModule.Status.Rejected)
			local _, v3 = v2:_unwrap()
			expect(v3).to.equal("foo")
		end)
		it("should reject with a returned rejected promise's value", function()
			local v = nil
			local v2 = parentModule.reject("foo"):finally(function()
				return parentModule.new(function(_, p)
					v = p
				end)
			end)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			v("bar")
			expect(v2:getStatus()).to.equal(parentModule.Status.Rejected)
			local _, v3 = v2:_unwrap()
			expect(v3).to.equal("bar")
		end)
		it("should reject when handler errors", function()
			local v = {}
			local _unwrap, v2 = parentModule.reject("bar"):finally(function()
				error(v)
			end):_unwrap()
			expect(_unwrap).to.equal(false)
			expect(v2).to.equal(v)
		end)
		itSKIP("should not prevent cancellation", function()
			local v = parentModule.new(function() end)
			local v2 = false
			v:finally(function()
				v2 = true
			end)
			v:andThen(function() end):cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2).to.equal(true)
		end)
		it("should propagate cancellation downwards", function()
			local v = false
			local v2 = parentModule.new(function() end)
			local v3 = v2:finally(function()
				v = true
			end)
			v2:cancel()
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v3:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v).to.equal(true)
			expect(false).to.equal(false)
		end)
		it("should propagate cancellation upwards", function()
			local v = false
			local v2 = parentModule.new(function() end)
			local v3 = v2:finally(function()
				v = true
			end)
			v3:cancel()
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v3:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v).to.equal(true)
			expect(false).to.equal(false)
		end)
		it("should cancel returned promise if cancelled", function()
			local v = parentModule.new(function() end)
			parentModule.resolve():finally(function()
				return v
			end):cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
	end)
	describe("Promise.all", function()
		it("should error if given something other than a table", function()
			expect(function()
				parentModule.all(1)
			end).to.throw()
		end)
		it("should resolve instantly with an empty table if given no promises", function()
			local all = parentModule.all({})
			local _unwrap, v = all:_unwrap()
			expect(_unwrap).to.equal(true)
			expect(all:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v).to.be.a("table")
			expect(next(v)).to.equal(nil)
		end)
		it("should error if given non-promise values", function()
			expect(function()
				parentModule.all({
					{},
					{},
					{}
				})
			end).to.throw()
		end)
		it("should wait for all promises to be resolved and return their values", function()
			local v, v2 = pack(1, "A string", nil, false)
			local v3 = {}
			local v4 = {}

			for i = 1, v do
				local v5 = i
				v4[i] = parentModule.new(function(p)
					v3[v5] = { p, v2[v5] }
				end)
			end

			local all = parentModule.all(v4)

			for _, v5 in ipairs(v3) do
				expect(all:getStatus()).to.equal(parentModule.Status.Started)
				v5[1](v5[2])
			end

			local v5, v6 = pack(all:_unwrap())
			local v7, v8 = unpack(v6, 1, v5)
			expect(v5).to.equal(2)
			expect(v7).to.equal(true)
			expect(v8).to.be.a("table")
			expect(#v8).to.equal(#v4)

			for i = 1, v do
				expect(v8[i]).to.equal(v2[i])
			end
		end)
		it("should reject if any individual promise rejected", function()
			local v = nil
			local v2 = nil
			local v3 = parentModule.new(function(_, p)
				v = p
			end)
			local v4 = parentModule.new(function(p)
				v2 = p
			end)
			local all = parentModule.all({ v3, v4 })
			expect(all:getStatus()).to.equal(parentModule.Status.Started)
			v("baz", "qux")
			v2("foo", "bar")
			local v5, v6 = pack(all:_unwrap())
			local v7, v8, v9 = unpack(v6, 1, v5)
			expect(v5).to.equal(3)
			expect(v7).to.equal(false)
			expect(v8).to.equal("baz")
			expect(v9).to.equal("qux")
			expect(v4:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should not resolve if resolved after rejecting", function()
			local v = nil
			local v2 = nil
			local v3 = { parentModule.new(function(_, p)
					v = p
				end), (parentModule.new(function(p)
					v2 = p
				end)) }
			local all = parentModule.all(v3)
			expect(all:getStatus()).to.equal(parentModule.Status.Started)
			v("baz", "qux")
			v2("foo", "bar")
			local v4, v5 = pack(all:_unwrap())
			local v6, v7, v8 = unpack(v5, 1, v4)
			expect(v4).to.equal(3)
			expect(v6).to.equal(false)
			expect(v7).to.equal("baz")
			expect(v8).to.equal("qux")
		end)
		it("should only reject once", function()
			local v = nil
			local v2 = nil
			local v3 = { parentModule.new(function(_, p)
					v = p
				end), (parentModule.new(function(_, p)
					v2 = p
				end)) }
			local all = parentModule.all(v3)
			expect(all:getStatus()).to.equal(parentModule.Status.Started)
			v("foo", "bar")
			expect(all:getStatus()).to.equal(parentModule.Status.Rejected)
			v2("baz", "qux")
			local v4, v5 = pack(all:_unwrap())
			local v6, v7, v8 = unpack(v5, 1, v4)
			expect(v4).to.equal(3)
			expect(v6).to.equal(false)
			expect(v7).to.equal("foo")
			expect(v8).to.equal("bar")
		end)
		itSKIP("should error if a non-array table is passed in", function()
			local success, result = pcall(function()
				parentModule.all(parentModule.new(function() end))
			end)
			expect(success).to.be.ok()
			expect(result:find("Non%-promise")).to.be.ok()
		end)
		it("should cancel pending promises if one rejects", function()
			local v = parentModule.new(function() end)
			expect(parentModule.all({ parentModule.resolve(), parentModule.reject(), v }):getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should cancel promises if it is cancelled", function()
			local v = parentModule.new(function() end)
			v:andThen(function() end)
			local v2 = { parentModule.new(function() end), parentModule.new(function() end), v }
			parentModule.all(v2):cancel()
			expect(v2[1]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[2]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[3]:getStatus()).to.equal(parentModule.Status.Started)
		end)
	end)
	describe("Promise.fold", function()
		it("should return the initial value in a promise when the list is empty", function()
			local v = {}
			local fold = parentModule.fold({}, function()
				error("should not be called")
			end, v)
			expect(parentModule.is(fold)).to.equal(true)
			expect(fold:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(fold:expect()).to.equal(v)
		end)
		it("should accept promises in the list", function()
			local v = nil
			local fold = parentModule.fold({ parentModule.new(function(p)
					v = p
				end), 2, 3 }, function(p, p2)
				return p + p2
			end, 0)
			v(1)
			expect(parentModule.is(fold)).to.equal(true)
			expect(fold:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(fold:expect()).to.equal(6)
		end)
		it("should always return a promise even if the list or reducer don't use them", function()
			local fold = parentModule.fold({ 1, 2, 3 }, function(p, p2, p3)
				if p3 == 2 then
					return parentModule.delay(1):andThenReturn(p + p2)
				end

				return p + p2
			end, 0)
			expect(parentModule.is(fold)).to.equal(true)
			expect(fold:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime(2)
			expect(fold:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(fold:expect()).to.equal(6)
		end)
		it("should return the first rejected promise", function()
			local fold = parentModule.fold({ 1, 2, 3 }, function(p, p2, p3)
				if p3 == 2 then
					return parentModule.reject("foo")
				end

				return p + p2
			end, 0)
			expect(parentModule.is(fold)).to.equal(true)
			local v, v2 = fold:awaitStatus()
			expect(v).to.equal(parentModule.Status.Rejected)
			expect(v2).to.equal("foo")
		end)
		it("should return the first canceled promise", function()
			local v = nil
			local fold = parentModule.fold({ 1, 2, 3 }, function(p, p2, p3)
				if p3 == 1 then
					return p + p2
				end

				if p3 == 2 then
					v = parentModule.delay(1):andThenReturn(p + p2)
					return v
				else
					error("this should not run if the promise is cancelled")
				end
			end, 0)
			expect(parentModule.is(fold)).to.equal(true)
			expect(fold:getStatus()).to.equal(parentModule.Status.Started)
			v:cancel()
			expect(fold:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
	end)
	describe("Promise.race", function()
		it("should resolve with the first settled value", function()
			local v = parentModule.race({ parentModule.resolve(1), parentModule.resolve(2) }):andThen(function(p)
				expect(p).to.equal(1)
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
		end)
		it("should cancel other promises", function()
			local v = parentModule.new(function() end)
			v:andThen(function() end)
			local v2 = { v, parentModule.new(function() end), parentModule.new(function(callback)
					callback(2)
				end) }
			local race = parentModule.race(v2)
			expect(race:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(race._values[1]).to.equal(2)
			expect(v2[1]:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2[2]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[3]:getStatus()).to.equal(parentModule.Status.Resolved)
			local v3 = parentModule.new(function() end)
			expect(parentModule.race({ parentModule.reject(), parentModule.resolve(), v3 }):getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v3:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should error if a non-array table is passed in", function()
			local success, result = pcall(function()
				parentModule.race(parentModule.new(function() end))
			end)
			expect(success).to.be.ok()
			expect(result:find("Non%-promise")).to.be.ok()
		end)
		it("should cancel promises if it is cancelled", function()
			local v = parentModule.new(function() end)
			v:andThen(function() end)
			local v2 = { parentModule.new(function() end), parentModule.new(function() end), v }
			parentModule.race(v2):cancel()
			expect(v2[1]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[2]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[3]:getStatus()).to.equal(parentModule.Status.Started)
		end)
	end)
	describe("Promise.promisify", function()
		it("should wrap functions", function()
			local function test(p)
				return p + 1
			end

			local v = parentModule.promisify(test)(1)
			local _unwrap, v2 = v:_unwrap()
			expect(_unwrap).to.equal(true)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v2).to.equal(2)
		end)
		it("should catch errors after a yield", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.promisify(function()
				bindableEvent2.Event:Wait()
				error("errortext")
			end)()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire()
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(tostring(v._values[1]):find("errortext")).to.be.ok()
		end)
	end)
	describe("Promise.tap", function()
		it("should thread through values", function()
			local v = nil
			local v2 = nil
			parentModule.resolve(1):andThen(function(p)
				return p + 1
			end):tap(function(p)
				v = p
				return p + 1
			end):andThen(function(p)
				v2 = p
			end)
			expect(v).to.equal(2)
			expect(v2).to.equal(2)
		end)
		it("should chain onto promises", function()
			local v = nil
			local v2 = nil
			local v3 = parentModule.resolve(1):tap(function()
				return parentModule.new(function(p)
					v = p
				end)
			end):andThen(function(p)
				v2 = p
			end)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2).to.never.be.ok()
			v(1)
			expect(v3:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v2).to.equal(1)
		end)
	end)
	describe("Promise.try", function()
		it("should catch synchronous errors", function()
			local v = nil
			parentModule.try(function()
				error("errortext")
			end):catch(function(p)
				v = tostring(p)
			end)
			expect(v:find("errortext")).to.be.ok()
		end)
		it("should reject with error objects", function()
			local v = {}
			local _unwrap, v2 = parentModule.try(function()
				error(v)
			end):_unwrap()
			expect(_unwrap).to.equal(false)
			expect(v2).to.equal(v)
		end)
		it("should catch asynchronous errors", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.try(function()
				bindableEvent2.Event:Wait()
				error("errortext")
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire()
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(tostring(v._values[1]):find("errortext")).to.be.ok()
		end)
	end)
	describe("Promise:andThenReturn", function()
		it("should return the given values", function()
			local v = nil
			local v2 = nil
			parentModule.resolve():andThenReturn(1, 2):andThen(function(p, p2)
				v = p
				v2 = p2
			end)
			expect(v).to.equal(1)
			expect(v2).to.equal(2)
		end)
	end)
	describe("Promise:doneReturn", function()
		it("should return the given values", function()
			local v = nil
			local v2 = nil
			parentModule.resolve():doneReturn(1, 2):andThen(function(p, p2)
				v = p
				v2 = p2
			end)
			expect(v).to.equal(1)
			expect(v2).to.equal(2)
		end)
	end)
	describe("Promise:andThenCall", function()
		it("should call the given function with arguments", function()
			local v = nil
			local v2 = nil
			parentModule.resolve():andThenCall(function(p, p2)
				v = p
				v2 = p2
			end, 3, 4)
			expect(v).to.equal(3)
			expect(v2).to.equal(4)
		end)
	end)
	describe("Promise:andThenAsync", function()
		it("should allow yielding", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.fromEvent(bindableEvent2.Event):andThenAsync(function()
				return 5
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal(5)
		end)
		it("should run andThenAsync on a new thread", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = nil
			local v2 = parentModule.new(function(p)
				v = p
			end)
			local v3 = v2:andThenAsync(function()
				bindableEvent2.Event:Wait()
				return 5
			end)
			local v4 = v2:andThenAsync(function()
				return "foo"
			end)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			v()
			expect(v4:getStatus()).to.equal(parentModule.Status.Started)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v4._values[1]).to.equal("foo")
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
		end)
		it("should chain onto resolved promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local resolved = parentModule.resolve(5)
			local v3 = resolved:andThenAsync(function(...)
				v2, v = pack(...)
				count += 1
			end, function()
				count2 += 1
			end)
			expect(count2).to.equal(0)
			expect(count).to.equal(0)
			expect(v3).to.be.ok()
			expect(v3).never.to.equal(resolved)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			expect(resolved).to.be.ok()
			expect(resolved:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(resolved._values[1]).to.equal(5)
			advanceTime()
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(5)
			expect(v3:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v3._values).to.equal(0)
		end)
		it("should chain onto rejected promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = parentModule.reject(5)
			local v4 = v3:andThenAsync(function(...)
				count2 += 1
			end, function(...)
				v2, v = pack(...)
				count += 1
			end)
			expect(count2).to.equal(0)
			expect(count).to.equal(0)
			expect(v3).to.be.ok()
			expect(v3:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v3._values[1]).to.equal(5)
			expect(v4).to.be.ok()
			expect(v4).never.to.equal(v3)
			expect(v4:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(5)
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v4._values).to.equal(0)
		end)
		it("should reject on error in callback", function()
			local count = 0
			local v = parentModule.resolve(1):andThenAsync(function()
				count += 1
				error("hahah")
			end)
			expect(v).to.be.ok()
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			expect(count).to.equal(0)
			advanceTime()
			expect(count).to.equal(1)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(tostring(v._values[1]):find("hahah")).to.be.ok()
			expect(tostring(v._values[1]):find("init.spec")).to.be.ok()
			expect(tostring(v._values[1]):find("runExecutor")).to.be.ok()
		end)
		it("should chain onto asynchronously resolved promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = nil
			local v4 = parentModule.new(function(p)
				v3 = p
			end)
			local v5 = v4:andThenAsync(function(...)
				v = { ... }
				v2 = select("#", ...)
				count += 1
			end, function()
				count2 += 1
			end)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			v3(6)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			expect(v4).to.be.ok()
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v5).to.be.ok()
			expect(v5).never.to.equal(v4)
			expect(v5:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(6)
			expect(v4:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v4._values[1]).to.equal(6)
			expect(v5:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#v5._values).to.equal(0)
		end)
		it("should chain onto asynchronously rejected promises", function()
			local v = nil
			local v2 = nil
			local count = 0
			local count2 = 0
			local v3 = nil
			local v4 = parentModule.new(function(_, p)
				v3 = p
			end)
			local v5 = v4:andThenAsync(function()
				count2 += 1
			end, function(...)
				v = { ... }
				v2 = select("#", ...)
				count += 1
			end)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			v3(6)
			expect(count).to.equal(0)
			expect(count2).to.equal(0)
			expect(v4).to.be.ok()
			expect(v4:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v5).to.be.ok()
			expect(v5).never.to.equal(v4)
			expect(v5:getStatus()).to.equal(parentModule.Status.Started)
			advanceTime()
			expect(count2).to.equal(0)
			expect(count).to.equal(1)
			expect(v2).to.equal(1)
			expect(v[1]).to.equal(6)
			expect(v5:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v4._values[1]).to.equal(6)
			expect(#v5._values).to.equal(0)
		end)
		it("should propagate errors through multiple levels", function()
			local v = nil
			local v2 = nil
			local v3 = nil
			parentModule.new(function(_, callback)
				callback(1, 2, 3)
			end):andThenAsync(function() end):catch(function(p, p2, p3)
				v = p
				v2 = p2
				v3 = p3
			end)
			expect(v).to.equal(nil)
			expect(v2).to.equal(nil)
			expect(v3).to.equal(nil)
			advanceTime()
			expect(v).to.equal(1)
			expect(v2).to.equal(2)
			expect(v3).to.equal(3)
		end)
		it("should propagate errors asynchronously through multiple levels", function()
			local v = nil
			local v2 = nil
			local v3 = nil

			local function handleErrors(p, p2, p3)
				v = p
				v2 = p2
				v3 = p3
				return parentModule.reject(p * 10, p2 * 10, p3 * 10)
			end

			parentModule.new(function(_, callback)
				callback(1, 2, 3)
			end):andThenAsync(function() end, handleErrors):andThenAsync(function() end, handleErrors):andThenAsync(function() end, handleErrors):catch(function(p, p2, p3)
				local v4 = "caught " .. tostring(p)
				local v5 = "caught " .. tostring(p2)
				local v6 = "caught " .. tostring(p3)
				v = v4
				v2 = v5
				v3 = v6
			end)
			expect(v).to.equal(nil)
			expect(v2).to.equal(nil)
			expect(v3).to.equal(nil)
			advanceTime()
			expect(v).to.equal(1)
			expect(v2).to.equal(2)
			expect(v3).to.equal(3)
			advanceTime()
			expect(v).to.equal(10)
			expect(v2).to.equal(20)
			expect(v3).to.equal(30)
			advanceTime()
			expect(v).to.equal("caught 1000")
			expect(v2).to.equal("caught 2000")
			expect(v3).to.equal("caught 3000")
		end)
		it("should NOT propagate errors if error handler is provided", function()
			local v = nil
			local v2 = nil
			local v3 = nil
			parentModule.new(function(_, callback)
				callback(1, 2, 3)
			end):andThenAsync(function() end, function() end):catch(function(p, p2, p3)
				v = p
				v2 = p2
				v3 = p3
			end)
			expect(v).to.equal(nil)
			expect(v2).to.equal(nil)
			expect(v3).to.equal(nil)
			advanceTime()
			expect(v).to.equal(nil)
			expect(v2).to.equal(nil)
			expect(v3).to.equal(nil)
		end)
	end)
	describe("Promise:doneCall", function()
		it("should call the given function with arguments", function()
			local v = nil
			local v2 = nil
			parentModule.resolve():doneCall(function(p, p2)
				v = p
				v2 = p2
			end, 3, 4)
			expect(v).to.equal(3)
			expect(v2).to.equal(4)
		end)
	end)
	describe("Promise:done", function()
		it("should trigger on resolve or cancel", function()
			local v = parentModule.new(function() end)
			local v2 = nil
			local done = v:done(function()
				v2 = true
			end)
			expect(v2).to.never.be.ok()
			v:cancel()
			expect(done:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2).to.equal(true)
			local v3 = nil
			local v4 = nil
			parentModule.reject():done(function()
				v3 = true
			end):finally(function()
				v4 = true
			end)
			expect(v3).to.never.be.ok()
			expect(v4).to.be.ok()
		end)
	end)
	describe("Promise.some", function()
		it("should resolve once the goal is reached", function()
			local some = parentModule.some(
				{ parentModule.resolve(1), parentModule.reject(), parentModule.resolve(2) },
				2
			)
			expect(some:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(some._values[1][1]).to.equal(1)
			expect(some._values[1][2]).to.equal(2)
		end)
		it("should error if the goal can't be reached", function()
			expect(parentModule.some({ parentModule.resolve(), parentModule.reject() }, 2):getStatus()).to.equal(parentModule.Status.Rejected)
			local v = nil
			local some = parentModule.some({ parentModule.resolve(), parentModule.new(function(_, p)
					v = p
				end) }, 2)
			expect(some:getStatus()).to.equal(parentModule.Status.Started)
			v("foo")
			expect(some:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(some._values[1]).to.equal("foo")
		end)
		it("should cancel pending Promises once the goal is reached", function()
			local v = nil
			local v2 = parentModule.new(function() end)
			local v3 = parentModule.new(function(p)
				v = p
			end)
			local some = parentModule.some({ v2, v3, parentModule.resolve() }, 2)
			expect(some:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2:getStatus()).to.equal(parentModule.Status.Started)
			expect(v3:getStatus()).to.equal(parentModule.Status.Started)
			v()
			expect(some:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v2:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v3:getStatus()).to.equal(parentModule.Status.Resolved)
		end)
		it("should error if passed a non-number", function()
			expect(function()
				parentModule.some({}, "non-number")
			end).to.throw()
		end)
		it("should return an empty array if amount is 0", function()
			local some = parentModule.some({ parentModule.resolve(2) }, 0)
			expect(some:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#some._values[1]).to.equal(0)
		end)
		it("should not return extra values", function()
			local some = parentModule.some({
				parentModule.resolve(1),
				parentModule.resolve(2),
				parentModule.resolve(3),
				parentModule.resolve(4)
			}, 2)
			expect(some:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(#some._values[1]).to.equal(2)
			expect(some._values[1][1]).to.equal(1)
			expect(some._values[1][2]).to.equal(2)
		end)
		it("should cancel promises if it is cancelled", function()
			local v = parentModule.new(function() end)
			v:andThen(function() end)
			local v2 = { parentModule.new(function() end), parentModule.new(function() end), v }
			parentModule.some(v2, 3):cancel()
			expect(v2[1]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[2]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[3]:getStatus()).to.equal(parentModule.Status.Started)
		end)
		describe("Promise.any", function()
			it("should return the value directly", function()
				local any = parentModule.any({ parentModule.reject(), parentModule.reject(), parentModule.resolve(1) })
				expect(any:getStatus()).to.equal(parentModule.Status.Resolved)
				expect(any._values[1]).to.equal(1)
			end)
			it("should error if all are rejected", function()
				expect(parentModule.any({ parentModule.reject(), parentModule.reject(), parentModule.reject() }):getStatus()).to.equal(parentModule.Status.Rejected)
			end)
		end)
	end)
	describe("Promise.allSettled", function()
		it("should resolve with an array of PromiseStatuses", function()
			local v = nil
			local allSettled = parentModule.allSettled({
				parentModule.resolve(),
				parentModule.reject(),
				parentModule.resolve(),
				parentModule.new(function(_, p)
					v = p
				end)
			})
			expect(allSettled:getStatus()).to.equal(parentModule.Status.Started)
			v()
			expect(allSettled:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(allSettled._values[1][1]).to.equal(parentModule.Status.Resolved)
			expect(allSettled._values[1][2]).to.equal(parentModule.Status.Rejected)
			expect(allSettled._values[1][3]).to.equal(parentModule.Status.Resolved)
			expect(allSettled._values[1][4]).to.equal(parentModule.Status.Rejected)
		end)
		it("should cancel promises if it is cancelled", function()
			local v = parentModule.new(function() end)
			v:andThen(function() end)
			local v2 = { parentModule.new(function() end), parentModule.new(function() end), v }
			parentModule.allSettled(v2):cancel()
			expect(v2[1]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[2]:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v2[3]:getStatus()).to.equal(parentModule.Status.Started)
		end)
	end)
	describe("Promise:await", function()
		it("should return the correct values", function()
			local v, v2, v3, v4, v5 = parentModule.resolve(5, 6, nil, 7):await()
			expect(v).to.equal(true)
			expect(v2).to.equal(5)
			expect(v3).to.equal(6)
			expect(v4).to.equal(nil)
			expect(v5).to.equal(7)
		end)
		it("should work if yielding is needed", function()
			local v = false
			task.spawn(function()
				local _, v2 = parentModule.delay(1):await()
				expect((type(v2))).to.equal("number")
				v = true
			end)
			advanceTime(2)
			expect(v).to.equal(true)
		end)
	end)
	describe("Promise:expect", function()
		it("should throw the correct values", function()
			local v = {}
			local v2 = parentModule.reject(v)
			local success, result = pcall(function()
				v2:expect()
			end)
			expect(success).to.equal(false)
			expect(result).to.equal(v)
		end)
	end)
	describe("Promise:now", function()
		it("should resolve if the Promise is resolved", function()
			local _unwrap, v = parentModule.resolve("foo"):now():_unwrap()
			expect(_unwrap).to.equal(true)
			expect(v).to.equal("foo")
		end)
		it("should reject if the Promise is not resolved", function()
			local _unwrap, v = parentModule.new(function() end):now():_unwrap()
			expect(_unwrap).to.equal(false)
			expect(parentModule.Error.isKind(v, "NotResolvedInTime")).to.equal(true)
		end)
		it("should reject with a custom rejection value", function()
			local _unwrap, v = parentModule.new(function() end):now("foo"):_unwrap()
			expect(_unwrap).to.equal(false)
			expect(v).to.equal("foo")
		end)
	end)
	describe("Promise.each", function()
		it("should iterate", function()
			local _unwrap, v = parentModule.each({
				"foo",
				"bar",
				"baz",
				"qux"
			}, function(...)
				return { ... }
			end):_unwrap()
			expect(_unwrap).to.equal(true)
			expect(v[1][1]).to.equal("foo")
			expect(v[1][2]).to.equal(1)
			expect(v[2][1]).to.equal("bar")
			expect(v[2][2]).to.equal(2)
			expect(v[3][1]).to.equal("baz")
			expect(v[3][2]).to.equal(3)
			expect(v[4][1]).to.equal("qux")
			expect(v[4][2]).to.equal(4)
		end)
		it("should iterate serially", function()
			local v = {}
			local v2 = {}
			local each = parentModule.each({ "foo", "bar", "baz" }, function(value, p)
				v2[p] = (v2[p] or 0) + 1
				return parentModule.new(function(callback)
					table.insert(v, function()
						callback(value:upper())
					end)
				end)
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Started)
			expect(#v).to.equal(1)
			expect(v2[1]).to.equal(1)
			expect(v2[2]).to.never.be.ok()
			table.remove(v, 1)()
			expect(each:getStatus()).to.equal(parentModule.Status.Started)
			expect(#v).to.equal(1)
			expect(v2[1]).to.equal(1)
			expect(v2[2]).to.equal(1)
			expect(v2[3]).to.never.be.ok()
			table.remove(v, 1)()
			expect(each:getStatus()).to.equal(parentModule.Status.Started)
			expect(v2[1]).to.equal(1)
			expect(v2[2]).to.equal(1)
			expect(v2[3]).to.equal(1)
			table.remove(v, 1)()
			expect(each:getStatus()).to.equal(parentModule.Status.Resolved)
			expect((type(each._values[1]))).to.equal("table")
			expect((type(each._values[2]))).to.equal("nil")
			local _value = each._values[1]
			expect(_value[1]).to.equal("FOO")
			expect(_value[2]).to.equal("BAR")
			expect(_value[3]).to.equal("BAZ")
		end)
		it("should reject with the value if the predicate promise rejects", function()
			local each = parentModule.each({ 1, 2, 3 }, function()
				return parentModule.reject("foobar")
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(each._values[1]).to.equal("foobar")
		end)
		it("should allow Promises to be in the list and wait when it gets to them", function()
			local v = nil
			local v2 = { (parentModule.new(function(p)
					v = p
				end)) }
			local each = parentModule.each(v2, function(p)
				return p * 2
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Started)
			v(2)
			expect(each:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(each._values[1][1]).to.equal(4)
		end)
		it("should reject with the value if a Promise from the list rejects", function()
			local v = false
			local each = parentModule.each({ 1, 2, parentModule.reject("foobar") }, function(_)
				v = true
				return "never"
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(each._values[1]).to.equal("foobar")
			expect(v).to.equal(false)
		end)
		it("should reject immediately if there's a cancelled Promise in the list initially", function()
			local v = parentModule.new(function() end)
			v:cancel()
			local v2 = false
			local each = parentModule.each({ 1, 2, v }, function()
				v2 = true
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v2).to.equal(false)
			expect(each._values[1].kind).to.equal(parentModule.Error.Kind.AlreadyCancelled)
		end)
		it("should stop iteration if Promise.each is cancelled", function()
			local v = {}
			local each = parentModule.each({ "foo", "bar", "baz" }, function(_, p)
				v[p] = (v[p] or 0) + 1
				return parentModule.new(function() end)
			end)
			expect(each:getStatus()).to.equal(parentModule.Status.Started)
			expect(v[1]).to.equal(1)
			expect(v[2]).to.never.be.ok()
			each:cancel()
			expect(each:getStatus()).to.equal(parentModule.Status.Cancelled)
			expect(v[1]).to.equal(1)
			expect(v[2]).to.never.be.ok()
		end)
		it("should cancel the Promise returned from the predicate if Promise.each is cancelled", function()
			local v = nil
			parentModule.each({ "foo", "bar", "baz" }, function(_, _)
				v = parentModule.new(function() end)
				return v
			end):cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
		it("should cancel Promises in the list if Promise.each is cancelled", function()
			local v = parentModule.new(function() end)
			parentModule.each({ v }, function() end):cancel()
			expect(v:getStatus()).to.equal(parentModule.Status.Cancelled)
		end)
	end)
	describe("Promise.retry", function()
		it("should retry N times", function()
			local count = 0
			local v = parentModule.retry(function(p)
				expect(p).to.equal("foo")
				count += 1

				if count == 5 then
					return parentModule.resolve("ok")
				end

				return parentModule.reject("fail")
			end, 5, "foo")
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal("ok")
		end)
		it("should reject if threshold is exceeded", function()
			local v = parentModule.retry(function()
				return parentModule.reject("fail")
			end, 5)
			expect(v:getStatus()).to.equal(parentModule.Status.Rejected)
			expect(v._values[1]).to.equal("fail")
		end)
	end)
	describe("Promise.retryWithDelay", function()
		it("should retry after a delay", function()
			local count = 0
			local v = parentModule.retryWithDelay(function(p)
				expect(p).to.equal("foo")
				count += 1

				if count == 3 then
					return parentModule.resolve("ok")
				end

				return parentModule.reject("fail")
			end, 3, 10, "foo")
			expect(count).to.equal(1)
			advanceTime(11)
			expect(count).to.equal(2)
			advanceTime(11)
			expect(count).to.equal(3)
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal("ok")
		end)
	end)
	describe("Promise.fromEvent", function()
		it("should convert a Promise into an event", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.fromEvent(bindableEvent2.Event)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire("foo")
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal("foo")
		end)
		it("should convert a Promise into an event with the predicate", function()
			local bindableEvent2 = Instance.new("BindableEvent")
			local v = parentModule.fromEvent(bindableEvent2.Event, function(p)
				return p == "foo"
			end)
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire("bar")
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Started)
			bindableEvent2:Fire("foo")
			waitForEvents() -- equivalent call inferred; original call site unknown
			expect(v:getStatus()).to.equal(parentModule.Status.Resolved)
			expect(v._values[1]).to.equal("foo")
		end)
	end)
	describe("Promise.is", function()
		it("should work with current version", function()
			local resolved = parentModule.resolve(1)
			expect(parentModule.is(resolved)).to.equal(true)
		end)
		it("should work with any object with an andThen", function()
			expect(parentModule.is({
				andThen = function()
					return 1
				end
			})).to.equal(true)
		end)
		it("should work with older promises", function()
			local v = {
				prototype = {}
			}
			v.__index = v.prototype

			function v.prototype:andThen() end

			local object = setmetatable({}, v)
			expect(parentModule.is(object)).to.equal(true)
		end)
	end)
end