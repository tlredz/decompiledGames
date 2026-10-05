return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local t = require(ReplicatedStorage.DevPackages.t)
	require(script.Parent.types)
	local createRemotes = require(script.Parent.createRemotes)
	local builder = require(script.Parent.builder)
	local mockRemotes = require(script.Parent.utils.mockRemotes)
	local v = nil
	beforeEach(function()
		v = createRemotes({
			event = builder.remote(t.string, t.number),
			callback = builder.remote(t.string, t.number).returns(t.string),
			namespace = builder.namespace({
				event = builder.remote(t.string, t.number),
				callback = builder.remote(t.string, t.number).returns(t.string)
			})
		})
	end)
	afterEach(function()
		v:destroy()
	end)
	it("should create top-level remotes", function()
		expect(v.event).to.be.ok()
		expect(v.callback).to.be.ok()
		expect(mockRemotes.getMockRemoteEvent("event")).to.be.ok()
		expect(mockRemotes.getMockRemoteFunction("callback")).to.be.ok()
	end)
	it("should create namespaced remotes", function()
		expect(v.namespace.event).to.be.ok()
		expect(v.namespace.callback).to.be.ok()
		expect(mockRemotes.getMockRemoteEvent("namespace.event")).to.be.ok()
		expect(mockRemotes.getMockRemoteFunction("namespace.callback")).to.be.ok()
	end)
	it("should fire a top-level event", function()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		v.event:connect(function(...)
			v2, v3, v4 = ...
		end)
		mockRemotes.createMockRemoteEvent("event"):FireServer("test", 1)
		expect(v2).to.be.ok()
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
	end)
	it("should fire a namespaced event", function()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		v.namespace.event:connect(function(...)
			v2, v3, v4 = ...
		end)
		mockRemotes.createMockRemoteEvent("namespace.event"):FireServer("test", 1)
		expect(v2).to.be.ok()
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
	end)
	it("should invoke a top-level callback", function()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		v.callback:onRequest(function(...)
			v2, v3, v4 = ...
			return "test"
		end)
		local v5 = mockRemotes.createMockRemoteFunction("callback"):InvokeServer("test", 1)
		expect(v2).to.be.ok()
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
		expect(v5).to.equal("test")
	end)
	it("should invoke a namespaced callback", function()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		v.namespace.callback:onRequest(function(...)
			v2, v3, v4 = ...
			return "test"
		end)
		local v5 = mockRemotes.createMockRemoteFunction("namespace.callback"):InvokeServer("test", 1)
		expect(v2).to.be.ok()
		expect(v3).to.equal("test")
		expect(v4).to.equal(1)
		expect(v5).to.equal("test")
	end)
	it("should apply middleware to every remote", function()
		v:destroy()
		mockRemotes.destroyAll()
		local v2 = {}
		local v3 = {}
		local v4 = {}

		local function middleware(p: number)
			return function(callback, p2)
				table.insert(v3, p2)
				return function(...)
					table.insert(v4, { ... })
					table.insert(v2, p)
					return callback(...)
				end
			end
		end

		local v5 = 1
		local v6 = 2
		local v7 = 3
		v = createRemotes({
			event = builder.remote(t.string, t.number),
			callback = builder.remote(t.string, t.number).returns(t.string),
			namespace = builder.namespace({
				event = builder.remote(t.string, t.number),
				callback = builder.remote(t.string, t.number).returns(t.string)
			})
		}, function(callback, p)
			table.insert(v3, p)
			return function(...)
				table.insert(v4, { ... })
				table.insert(v2, v5)
				return callback(...)
			end
		end, function(callback, p)
			table.insert(v3, p)
			return function(...)
				table.insert(v4, { ... })
				table.insert(v2, v6)
				return callback(...)
			end
		end, function(callback, p)
			table.insert(v3, p)
			return function(...)
				table.insert(v4, { ... })
				table.insert(v2, v7)
				return callback(...)
			end
		end)

		local function test(p, p2)
			v2 = {}
			v4 = {}
			mockRemotes.createMockRemoteEvent(p):FireServer("test", 1)

			for i = 1, 3 do
				expect(v3[i]).to.be.ok()
				expect(v4[i][1]).to.be.ok()
				expect(v4[i][2]).to.equal("test")
				expect(v4[i][3]).to.equal(1)
				expect(v2[i]).to.equal(i)
			end

			v2 = {}
			v4 = {}
			mockRemotes.createMockRemoteFunction(p2):InvokeServer("test", 1)

			for i = 1, 3 do
				expect(v4[i][1]).to.be.ok()
				expect(v4[i][2]).to.equal("test")
				expect(v4[i][3]).to.equal(1)
				expect(v2[i]).to.equal(i)
			end
		end

		test("event", "callback")
		test("namespace.event", "namespace.callback")
	end)
end