return function()
	local RunService = game:GetService("RunService")
	require(script.Parent.Parent.types)
	local createRemotes = require(script.Parent.Parent.createRemotes)
	local builder = require(script.Parent.Parent.builder)
	local instances = require(script.Parent.Parent.utils.instances)
	local throttleMiddleware = require(script.Parent.throttleMiddleware)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function pause(value: number?)
		local v = value or 1
		local thread = coroutine.running()
		local heartbeatConnection = nil
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			v -= 1

			if v <= 0 then
				heartbeatConnection:Disconnect()
				task.defer(thread)
			end
		end)
		coroutine.yield()
	end

	describe("event throttle", function()
		local v = nil
		local remote = nil
		local v2 = nil

		local function create(p)
			v = createRemotes({
				remote = builder.remote()
			}, throttleMiddleware(p))
			remote = v.remote
			v2 = instances.createRemoteEvent("remote", false)
		end

		afterEach(function()
			v:destroy()
		end)
		it("should throttle subsequent calls", function()
			local count = 0
			create({
				throttle = 0,
				trailing = false
			})
			remote:connect(function()
				count += 1
			end)
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(1)
			pause() -- equivalent call inferred; original call site unknown
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(2)
		end)
		it("should emit trailing calls", function()
			local count = 0
			create({
				throttle = 0,
				trailing = true
			})
			remote:connect(function()
				count += 1
			end)
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(1)
			pause() -- equivalent call inferred; original call site unknown
			expect(count).to.equal(2)
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(3)
			pause() -- equivalent call inferred; original call site unknown
			expect(count).to.equal(4)
		end)
		it("should pass the latest arguments to the trailing call", function()
			local count = 0
			local v3 = nil
			local v4 = nil
			create({
				throttle = 0,
				trailing = true
			})
			remote:connect(function(_, p, p2)
				count += 1
				v3 = p
				v4 = p2
			end)
			v2:FireServer(1, 2)
			v2:FireServer(2, 3)
			v2:FireServer(3, 4)
			v2:FireServer(4, 5)
			v2:FireServer(5, 6)
			v2:FireServer("a", "b")
			expect(count).to.equal(1)
			expect(v3).to.be.a("number")
			expect(v4).to.be.a("number")
			pause() -- equivalent call inferred; original call site unknown
			expect(count).to.equal(2)
			expect(v3).to.equal("a")
			expect(v4).to.equal("b")
			v2:FireServer("c", "d")
			expect(count).to.equal(3)
			expect(v3).to.equal("c")
			expect(v4).to.equal("d")
			pause() -- equivalent call inferred; original call site unknown
			expect(count).to.equal(4)
			expect(v3).to.equal("c")
			expect(v4).to.equal("d")
		end)
		it("should receive a throttle time as options", function()
			local count = 0
			create(0)
			remote:connect(function()
				count += 1
			end)
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(1)
			pause() -- equivalent call inferred; original call site unknown
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			v2:FireServer()
			expect(count).to.equal(2)
		end)
	end)
	describe("async throttle", function()
		local v = nil
		local remote = nil
		local v2 = nil

		local function create(p)
			v = createRemotes({
				remote = builder.remote().returns()
			}, throttleMiddleware(p))
			remote = v.remote
			v2 = instances.createRemoteFunction("remote")
		end

		local function didYield(callback)
			local v3 = true
			local success = nil
			local result = nil
			task.spawn(function()
				success, result = pcall(callback)
				v3 = false
			end)
			assert(success or success == nil, result)
			return v3
		end

		afterEach(function()
			v:destroy()
		end)
		it("should throttle subsequent calls", function()
			local count = 0
			create({
				throttle = 0
			})
			remote:onRequest(function()
				count += 1
			end)
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			expect(count).to.equal(1)
			pause() -- equivalent call inferred; original call site unknown
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			v2:InvokeServer()
			expect(count).to.equal(2)
		end)
		it("should return the cached value when throttled", function()
			local count = 0
			create({
				throttle = 0
			})
			remote:onRequest(function()
				count += 1
				return count
			end)
			expect(v2:InvokeServer()).to.equal(1)

			for _ = 1, 5 do
				expect(v2:InvokeServer()).to.equal(1)
			end

			pause() -- equivalent call inferred; original call site unknown
			expect(v2:InvokeServer()).to.equal(2)

			for _ = 1, 5 do
				expect(v2:InvokeServer()).to.equal(2)
			end
		end)
		it("should throw if the initial cache is not ready", function()
			create({
				throttle = 0
			})
			remote:onRequest(function()
				pause() -- equivalent call inferred; original call site unknown
			end)
			task.spawn(function()
				v2:InvokeServer()
			end)
			expect(function()
				v2:InvokeServer()
			end).to.throw()
		end)
		it("should return the cached value if a request is still pending", function()
			local count = 0
			create({
				throttle = 0
			})
			remote:onRequest(function()
				if count > 0 then
					pause() -- equivalent call inferred; original call site unknown
				end

				count += 1
				return count
			end)
			local expect2 = expect

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fn()
				expect(v2:InvokeServer()).to.equal(1)
			end

			local v3 = true
			local success = nil
			local result = nil
			task.spawn(function()
				success, result = pcall(fn)
				v3 = false
			end)
			assert(success or success == nil, result)
			expect2(v3).to.equal(false)
			local expect3 = expect

			-- equivalent calls inferred from this helper; original call sites unknown
			local function fn2()
				fn() -- equivalent call inferred; original call site unknown
				fn() -- equivalent call inferred; original call site unknown
			end

			local v4 = true
			local success2 = nil
			local result2 = nil
			task.spawn(function()
				success2, result2 = pcall(fn2)
				v4 = false
			end)
			assert(success2 or success2 == nil, result2)
			expect3(v4).to.equal(false)
			pause() -- equivalent call inferred; original call site unknown
			local expect4 = expect

			local function fn3()
				expect(v2:InvokeServer()).to.equal(2)
			end

			local v5 = true
			local success3 = nil
			local result3 = nil
			task.spawn(function()
				success3, result3 = pcall(fn3)
				v5 = false
			end)
			assert(success3 or success3 == nil, result3)
			expect4(v5).to.equal(true)
			local expect5 = expect

			local function fn4()
				fn2() -- equivalent call inferred; original call site unknown
			end

			local v6 = true
			local success4 = nil
			local result4 = nil
			task.spawn(function()
				success4, result4 = pcall(fn4)
				v6 = false
			end)
			assert(success4 or success4 == nil, result4)
			expect5(v6).to.equal(false)
		end)
		it("should throttle if the handler throws an error", function()
			local count = 0
			create({
				throttle = 0
			})
			remote:onRequest(function()
				count += 1
				assert(count ~= 1, "error")
				return count
			end)
			expect(function()
				v2:InvokeServer()
			end).to.throw()
			expect(function()
				v2:InvokeServer()
			end).to.throw()
			pause() -- equivalent call inferred; original call site unknown
			expect(v2:InvokeServer()).to.equal(2)

			for _ = 1, 5 do
				expect(v2:InvokeServer()).to.equal(2)
			end

			pause() -- equivalent call inferred; original call site unknown
			expect(v2:InvokeServer()).to.equal(3)

			for _ = 1, 5 do
				expect(v2:InvokeServer()).to.equal(3)
			end
		end)
	end)
end