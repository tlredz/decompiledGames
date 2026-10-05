local function AwaitCondition(fn, value)
	local lastTime = os.clock()
	local v = value or 10

	while not fn() do
		if v < os.clock() - lastTime then
			return false
		else
			task.wait()
		end
	end

	return true
end

return function()
	local parentModule = require(script.Parent)
	local v = nil

	local function NumConns(p)
		return #(p or v):GetConnections()
	end

	beforeEach(function()
		v = parentModule.new()
	end)
	afterEach(function()
		v:Destroy()
	end)
	describe("Constructor", function()
		it("should create a new signal and fire it", function()
			expect(parentModule.Is(v)).to.equal(true)
			task.defer(function()
				v:Fire(10, 20)
			end)
			local v2, v3 = v:Wait()
			expect(v2).to.equal(10)
			expect(v3).to.equal(20)
		end)
		it("should create a proxy signal and connect to it", function()
			local wrap = parentModule.Wrap
			local RunService = game:GetService("RunService")
			local wrapped = wrap(RunService.Heartbeat)
			expect(parentModule.Is(wrapped)).to.equal(true)
			local v2 = false
			wrapped:Connect(function()
				v2 = true
			end)
			expect(AwaitCondition(function()
				return v2
			end, 2)).to.equal(true)
			wrapped:Destroy()
		end)
	end)
	describe("FireDeferred", function()
		it("should be able to fire primitive argument", function()
			local v2 = nil
			v:Connect(function(p)
				v2 = p
			end)
			v:FireDeferred(10)
			expect(AwaitCondition(function()
				return v2 == 10
			end, 1)).to.equal(true)
		end)
		it("should be able to fire a reference based argument", function()
			local v2 = { 10, 20 }
			local v3 = nil
			v:Connect(function(p)
				v3 = p
			end)
			v:FireDeferred(v2)
			expect(AwaitCondition(function()
				return v2 == v3
			end, 1)).to.equal(true)
		end)
	end)
	describe("Fire", function()
		it("should be able to fire primitive argument", function()
			local v2 = nil
			v:Connect(function(p)
				v2 = p
			end)
			v:Fire(10)
			expect(v2).to.equal(10)
		end)
		it("should be able to fire a reference based argument", function()
			local v2 = { 10, 20 }
			local v3 = nil
			v:Connect(function(p)
				v3 = p
			end)
			v:Fire(v2)
			expect(v3).to.equal(v2)
		end)
	end)
	describe("ConnectOnce", function()
		it("should only capture first fire", function()
			local v2 = nil
			local v3 = v:ConnectOnce(function(p)
				v2 = p
			end)
			expect(v3.Connected).to.equal(true)
			v:Fire(10)
			expect(v3.Connected).to.equal(false)
			v:Fire(20)
			expect(v2).to.equal(10)
		end)
	end)
	describe("Wait", function()
		it("should be able to wait for a signal to fire", function()
			task.defer(function()
				v:Fire(10, 20, 30)
			end)
			local v2, v3, v4 = v:Wait()
			expect(v2).to.equal(10)
			expect(v3).to.equal(20)
			expect(v4).to.equal(30)
		end)
	end)
	describe("DisconnectAll", function()
		it("should disconnect all connections", function()
			v:Connect(function() end)
			v:Connect(function() end)
			expect(#(nil or v):GetConnections()).to.equal(2)
			v:DisconnectAll()
			expect(#(nil or v):GetConnections()).to.equal(0)
		end)
	end)
	describe("Disconnect", function()
		it("should disconnect connection", function()
			local connection = v:Connect(function() end)
			expect(#(nil or v):GetConnections()).to.equal(1)
			connection:Disconnect()
			expect(#(nil or v):GetConnections()).to.equal(0)
		end)
		it("should still work if connections disconnected while firing", function()
			local count = 0
			local connection = nil
			v:Connect(function()
				count += 1
			end)
			connection = v:Connect(function()
				connection:Disconnect()
				count += 1
			end)
			v:Connect(function()
				count += 1
			end)
			v:Fire()
			expect(count).to.equal(3)
		end)
		it("should still work if connections disconnected while firing deferred", function()
			local count = 0
			local connection = nil
			v:Connect(function()
				count += 1
			end)
			connection = v:Connect(function()
				connection:Disconnect()
				count += 1
			end)
			v:Connect(function()
				count += 1
			end)
			v:FireDeferred()
			expect(AwaitCondition(function()
				return count == 3
			end)).to.equal(true)
		end)
	end)
end