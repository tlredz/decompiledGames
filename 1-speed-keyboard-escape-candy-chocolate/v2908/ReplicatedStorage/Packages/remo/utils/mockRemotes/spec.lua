return function()
	local mockRemotes = require(script.Parent.mockRemotes)
	afterEach(function()
		mockRemotes.destroyAll()
	end)
	describe("createMockRemoteEvent", function()
		it("should return a RemoteEvent-like object", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			expect(mockRemoteEvent).to.be.ok()
			expect(mockRemoteEvent.Name).to.equal("test")
			expect(mockRemoteEvent.OnClientEvent).to.be.ok()
			expect(mockRemoteEvent.OnServerEvent).to.be.ok()
			expect(mockRemoteEvent.FireClient).to.be.ok()
			expect(mockRemoteEvent.FireAllClients).to.be.ok()
			expect(mockRemoteEvent.FireServer).to.be.ok()
			expect(mockRemoteEvent.Destroy).to.be.ok()
		end)
		it("should return the same object for the same name", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			local mockRemoteEvent2 = mockRemotes.createMockRemoteEvent("test")
			expect(mockRemoteEvent).to.equal(mockRemoteEvent2)
		end)
		it("should fire OnClientEvent listeners", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			local v = nil
			local v2 = nil
			mockRemoteEvent.OnClientEvent:Connect(function(...)
				v = { ... }
			end)
			mockRemoteEvent.OnClientEvent:Connect(function(...)
				v2 = { ... }
			end)
			mockRemoteEvent:FireClient({}, "test", 1)
			expect(v).to.be.ok()
			expect(v[1]).to.equal("test")
			expect(v[2]).to.equal(1)
			expect(v2).to.be.ok()
			expect(v2[1]).to.equal("test")
			expect(v2[2]).to.equal(1)
		end)
		it("should fire OnServerEvent listeners", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			local v = nil
			local v2 = nil
			mockRemoteEvent.OnServerEvent:Connect(function(p, ...)
				v = { p, ... }
			end)
			mockRemoteEvent.OnServerEvent:Connect(function(p, ...)
				v2 = { p, ... }
			end)
			mockRemoteEvent:FireServer("test", 1)
			expect(v).to.be.ok()
			expect(v[1]).to.be.ok()
			expect(v[2]).to.equal("test")
			expect(v[3]).to.equal(1)
			expect(v2).to.be.ok()
			expect(v[1]).to.be.ok()
			expect(v2[2]).to.equal("test")
			expect(v2[3]).to.equal(1)
		end)
		it("should not fire disconnected listeners", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			local v = nil
			local v2 = nil
			local onServerEventConnection = mockRemoteEvent.OnServerEvent:Connect(function(p, ...)
				v = { p, ... }
			end)
			mockRemoteEvent.OnServerEvent:Connect(function(p, ...)
				v2 = { p, ... }
			end)
			onServerEventConnection:Disconnect()
			mockRemoteEvent:FireServer("test", 1)
			expect(v).to.never.be.ok()
			expect(v2).to.be.ok()
			expect(v2[1]).to.be.ok()
			expect(v2[2]).to.equal("test")
			expect(v2[3]).to.equal(1)
		end)
		it("should not fire after being destroyed", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("test")
			local v = nil
			mockRemoteEvent.OnServerEvent:Connect(function(p, ...)
				v = { p, ... }
			end)
			mockRemoteEvent:Destroy()
			mockRemoteEvent:FireServer("test", 1)
			expect(v).to.never.be.ok()
		end)
		it("should not fire the wrong listeners", function()
			local mockRemoteEvent = mockRemotes.createMockRemoteEvent("client")
			local mockRemoteEvent2 = mockRemotes.createMockRemoteEvent("server")
			local v = false
			mockRemoteEvent2.OnServerEvent:Connect(function()
				v = true
			end)
			mockRemoteEvent.OnClientEvent:Connect(function()
				v = true
			end)
			mockRemoteEvent:FireServer()
			mockRemoteEvent2:FireClient({})
			expect(v).to.equal(false)
		end)
	end)
	describe("createMockRemoteFunction", function()
		it("should return a RemoteFunction-like object", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("test")
			expect(mockRemoteFunction).to.be.ok()
			expect(mockRemoteFunction.Name).to.equal("test")
			expect(mockRemoteFunction.OnClientInvoke).to.be.ok()
			expect(mockRemoteFunction.OnServerInvoke).to.be.ok()
			expect(mockRemoteFunction.InvokeClient).to.be.ok()
			expect(mockRemoteFunction.InvokeServer).to.be.ok()
			expect(mockRemoteFunction.Destroy).to.be.ok()
		end)
		it("should return the same object for the same name", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("test")
			local mockRemoteFunction2 = mockRemotes.createMockRemoteFunction("test")
			expect(mockRemoteFunction).to.equal(mockRemoteFunction2)
		end)
		it("should invoke the OnClientInvoke callback", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("test")
			local v = nil

			mockRemoteFunction.OnClientInvoke = function(...)
				v = { ... }
				return "test"
			end

			local v2 = mockRemoteFunction:InvokeClient({}, 1)
			expect(v).to.be.ok()
			expect(v[1]).to.equal(1)
			expect(v2).to.equal("test")
		end)
		it("should invoke the OnServerInvoke callback", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("test")
			local v = nil

			mockRemoteFunction.OnServerInvoke = function(p, ...)
				v = { p, ... }
				return "test"
			end

			local v2 = mockRemoteFunction:InvokeServer(1)
			expect(v).to.be.ok()
			expect(v[1]).to.be.ok()
			expect(v[2]).to.equal(1)
			expect(v2).to.equal("test")
		end)
		it("should not invoke after being destroyed", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("test")
			local v = nil

			mockRemoteFunction.OnServerInvoke = function(p, ...)
				v = { p, ... }
				return "test"
			end

			mockRemoteFunction:Destroy()
			local v2 = mockRemoteFunction:InvokeServer(1)
			expect(v).to.never.be.ok()
			expect(v2).to.never.be.ok()
		end)
		it("should not invoke the wrong callback", function()
			local mockRemoteFunction = mockRemotes.createMockRemoteFunction("client")
			local mockRemoteFunction2 = mockRemotes.createMockRemoteFunction("server")
			local v = false

			mockRemoteFunction2.OnServerInvoke = function()
				v = true
			end

			mockRemoteFunction.OnClientInvoke = function()
				v = true
			end

			mockRemoteFunction:InvokeServer()
			mockRemoteFunction2:InvokeClient({})
			expect(v).to.equal(false)
		end)
	end)
end