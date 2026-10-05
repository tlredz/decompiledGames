return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local t = require(ReplicatedStorage.DevPackages.t)
	local builder = require(script.Parent.Parent.builder)
	local mockRemotes = require(script.Parent.Parent.utils.mockRemotes)
	local createRemote = require(script.Parent.createRemote)
	local v = nil
	local v2 = nil
	beforeEach(function()
		v = createRemote("test", builder.remote(t.string, t.number))
		v2 = mockRemotes.createMockRemoteEvent("test")
	end)
	afterEach(function()
		v:destroy()
		v2:Destroy()
	end)
	it("should validate incoming argument types", function()
		expect(function()
			v2:FireServer(1, "")
		end).to.throw()
		expect(function()
			v2:FireServer("")
		end).to.throw()
		expect(function()
			v2:FireServer("", 1)
		end).to.never.throw()
	end)
	it("should receive incoming events", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		v:connect(function(...)
			v3, v4, v5 = ...
		end)
		v2:FireServer("test", 1)
		expect(v3).to.be.ok()
		expect(v4).to.equal("test")
		expect(v5).to.equal(1)
	end)
	it("should fire outgoing events", function()
		local v3 = nil
		local v4 = nil
		v2.OnClientEvent:Connect(function(...)
			v3, v4 = ...
		end)
		v:fireAll("test", 1)
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
		v:fireAll("test2", 2)
		expect(v3).to.equal("test2")
		expect(v4).to.equal(2)
	end)
	it("should throw when used after destruction", function()
		v:destroy()
		expect(function()
			v:fireAll("test", 1)
		end).to.throw()
		expect(function()
			v:connect(function() end)
		end).to.throw()
	end)
	it("should not fire disconnected events", function()
		local v3 = false
		v:connect(function()
			v3 = true
		end)()
		v:fireAll("test", 1)
		expect(v3).to.equal(false)
	end)
	it("should apply the middleware", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = nil
		v = createRemote("test", builder.remote(t.string, t.number).middleware(function(callback, p)
			v3 = p
			return function(p2)
				return callback(p2, "intercepted", 2)
			end
		end))
		expect(v3).to.equal(v)
		v:connect(function(...)
			v4, v5, v6 = ...
		end)
		v2:FireServer("test", 1)
		expect(v4).to.be.ok()
		expect(v5).to.equal("intercepted")
		expect(v6).to.equal(2)
	end)
	it("should fire the test listeners", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = nil
		v.test:onFire(function(...)
			v3, v4 = ...
		end)
		v2.OnClientEvent:Connect(function(...)
			v5, v6 = ...
		end)
		v:fireAll("test", 1)
		expect(v3).to.equal(v5)
		expect(v4).to.equal(v6)
		v3 = nil
		v4 = nil
		v5 = nil
		v6 = nil
		v.test:disconnectAll()
		v:fireAll("test", 1)
		expect(v3).to.never.be.ok()
		expect(v4).to.never.be.ok()
		expect(v5).to.equal("test")
		expect(v6).to.equal(1)
	end)
	it("should be callable", function()
		local v3 = nil
		local v4 = nil
		v2.OnClientEvent:Connect(function(...)
			v3, v4 = ...
		end)
		v({}, "test", 1)
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
	end)
	it("should promise an event", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		v:promise():andThen(function(...)
			v3, v4, v5 = ...
		end)
		v2:FireServer("test", 1)
		expect(v3).to.be.ok()
		expect(v4).to.equal("test")
		expect(v5).to.equal(1)
	end)
	it("should promise a predicated event", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		v:promise(function(_, p)
			return p == "true"
		end):andThen(function(...)
			v3, v4, v5 = ...
		end)
		v2:FireServer("false", 2)
		expect(v3).to.never.be.ok()
		expect(v4).to.never.be.ok()
		expect(v5).to.never.be.ok()
		v2:FireServer("true", 1)
		expect(v3).to.be.ok()
		expect(v4).to.equal("true")
		expect(v5).to.equal(1)
	end)
end