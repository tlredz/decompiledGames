return function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local t = require(ReplicatedStorage.DevPackages.t)
	local Promise = require(script.Parent.Parent.Promise)
	local builder = require(script.Parent.Parent.builder)
	local mockRemotes = require(script.Parent.Parent.utils.mockRemotes)
	local createAsyncRemote = require(script.Parent.createAsyncRemote)
	local localPlayer = Players.LocalPlayer or {}
	local v = nil
	local v2 = nil
	beforeEach(function()
		v = createAsyncRemote("test", builder.remote(t.string, t.number).returns(t.string))
		v2 = mockRemotes.createMockRemoteFunction("test")
	end)
	afterEach(function()
		v:destroy()
		v2:Destroy()
	end)
	it("should validate incoming argument types", function()
		v:onRequest(function()
			return ""
		end)
		expect(function()
			v2:InvokeServer(1, "")
		end).to.throw()
		expect(function()
			v2:InvokeServer("")
		end).to.throw()
		expect(function()
			v2:InvokeServer("", 1)
		end).to.never.throw()
	end)
	it("should validate incoming return types", function()
		v2.OnClientInvoke = function()
			return 1
		end

		expect(function()
			v:request(localPlayer, "", 1):expect()
		end).to.throw()

		v2.OnClientInvoke = function()
			return ""
		end

		expect(function()
			v:request(localPlayer, "", 1):expect()
		end).to.never.throw()
	end)
	it("should send and receive the correct values", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		v:onRequest(function(...)
			v3, v4, v5 = ...
			return "result"
		end)

		v2.OnClientInvoke = function(...)
			v4, v5 = ...
			return "result"
		end

		expect(v:request(v3, "test2", 2):expect()).to.equal("result")
		expect(v3).to.never.be.ok()
		expect(v4).to.equal("test2")
		expect(v5).to.equal(2)
		expect(v2:InvokeServer("test", 1)).to.equal("result")
		expect(v3).to.be.ok()
		expect(v4).to.equal("test")
		expect(v5).to.equal(1)
	end)
	it("should unwrap promises on invoke", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		v:onRequest(function(...)
			v3, v4, v5 = ...
			return Promise.resolve("result")
		end)
		expect(v2:InvokeServer("test", 1)).to.equal("result")
		expect(v3).to.be.ok()
		expect(v4).to.equal("test")
		expect(v5).to.equal(1)
	end)
	it("should throw when used after destruction", function()
		v:onRequest(function() end)
		v:destroy()
		expect(function()
			v:request(localPlayer, "", 1):expect()
		end).to.throw()
		expect(function()
			v:onRequest(function() end)
		end).to.throw()
	end)
	it("should apply the middleware", function()
		local v3 = nil
		local v4 = nil
		local v5 = nil
		local v6 = nil
		local v7 = nil
		v = createAsyncRemote(
			"test",
			builder.remote(t.string, t.number).returns(t.string).middleware(function(callback, p)
				v3 = p
				return function(p2)
					v7 = callback(p2, "intercepted", 2)
					return v7 .. "!"
				end
			end)
		)
		expect(v3).to.equal(v)
		v:onRequest(function(...)
			v4, v5, v6 = ...
			return "result"
		end)
		expect(v2:InvokeServer("test", 1)).to.equal("result!")
		expect(v4).to.be.ok()
		expect(v5).to.equal("intercepted")
		expect(v6).to.equal(2)
		expect(v7).to.equal("result")
	end)
	it("should support multiple return values", function()
		v = createAsyncRemote("test", builder.remote().returns(t.string, t.string, t.string))
		v:onRequest(function()
			return Promise.resolve("a", "b", "c")
		end)
		local v3, v4, v5 = v2:InvokeServer()
		expect(v3).to.equal("a")
		expect(v4).to.equal("b")
		expect(v5).to.equal("c")

		v2.OnClientInvoke = function()
			return "a", "b", "c"
		end

		local expect2, v6, v7 = v:request():expect()
		expect(expect2).to.equal("a")
		expect(v6).to.equal("b")
		expect(v7).to.equal("c")
	end)
	it("should be callable", function()
		v2.OnClientInvoke = function()
			return "result"
		end

		expect(v(localPlayer, "test", 1):expect()).to.equal("result")
	end)
	it("should invoke the test handler", function()
		local v3 = nil
		local v4 = nil
		v.test:handleRequest(function(...)
			v3, v4 = ...
			return "result"
		end)
		expect(v:request("test", 1):expect()).to.equal("result")
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
		v.test:disconnectAll()
		expect(function()
			v:request("test", 1):expect()
		end).to.throw()
	end)
end