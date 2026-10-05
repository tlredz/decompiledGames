local ServerScriptService = game:GetService("ServerScriptService")
require(ServerScriptService.TestRunner.Test)
return function(object)
	local parentModule = require(script.Parent)
	object:Describe("Trove", function()
		local maid = nil
		object:BeforeEach(function()
			maid = parentModule.new()
		end)
		object:AfterEach(function()
			if maid then
				maid:Destroy()
				maid = nil
			end
		end)
		object:Test("should add and clean up roblox instance", function()
			local part = Instance.new("Part")
			part.Parent = workspace
			maid:Add(part)
			maid:Destroy()
			object:Expect(part.Parent):ToBeNil()
		end)
		object:Test("should add and clean up roblox connection", function()
			local changedConnection = workspace.Changed:Connect(function() end)
			maid:Add(changedConnection)
			maid:Destroy()
			object:Expect(changedConnection.Connected):ToBe(false)
		end)
		object:Test("should add and clean up a table with a destroy method", function()
			local v = {
				Destroyed = false,
				Destroy = function(self)
					self.Destroyed = true
				end
			}
			maid:Add(v)
			maid:Destroy()
			object:Expect(v.Destroyed):ToBe(true)
		end)
		object:Test("should add and clean up a table with a disconnect method", function()
			local v = {
				Connected = true,
				Disconnect = function(self)
					self.Connected = false
				end
			}
			maid:Add(v)
			maid:Destroy()
			object:Expect(v.Connected):ToBe(false)
		end)
		object:Test("should add and clean up a function", function()
			local v = false
			maid:Add(function()
				v = true
			end)
			maid:Destroy()
			object:Expect(v):ToBe(true)
		end)
		object:Test("should allow a custom cleanup method", function()
			local v = {
				Cleaned = false,
				Cleanup = function(p)
					p.Cleaned = true
				end
			}
			maid:Add(v, "Cleanup")
			maid:Destroy()
			object:Expect(v.Cleaned):ToBe(true)
		end)
		object:Test("should return the object passed to add", function()
			local part = Instance.new("Part")
			local v = maid:Add(part)
			object:Expect(part):ToBe(v)
			maid:Destroy()
		end)
		object:Test("should fail to add object without proper cleanup method", function()
			local v = {}
			object:Expect(function()
				maid:Add(v)
			end):ToThrow()
		end)
		object:Test("should construct an object and add it", function()
			local class = {}
			class.__index = class

			function class.new(msg)
				local self = setmetatable({}, class)
				self._msg = msg
				self._destroyed = false
				return self
			end

			function class:Destroy()
				self._destroyed = true
			end

			local v = maid:Construct(class, "abc")
			object:Expect((typeof(v))):ToBe("table")
			object:Expect((getmetatable(v))):ToBe(class)
			object:Expect(v._msg):ToBe("abc")
			object:Expect(v._destroyed):ToBe(false)
			maid:Destroy()
			object:Expect(v._destroyed):ToBe(true)
		end)
		object:Test("should connect to a signal", function()
			local connection = maid:Connect(workspace.Changed, function() end)
			object:Expect((typeof(connection))):ToBe("RBXScriptConnection")
			object:Expect(connection.Connected):ToBe(true)
			maid:Destroy()
			object:Expect(connection.Connected):ToBe(false)
		end)
		object:Test("should remove an object", function()
			local connection = maid:Connect(workspace.Changed, function() end)
			object:Expect(maid:Remove(connection)):ToBe(true)
			object:Expect(connection.Connected):ToBe(false)
		end)
		object:Test("should not remove an object not in the trove", function()
			local changedConnection = workspace.Changed:Connect(function() end)
			object:Expect(maid:Remove(changedConnection)):ToBe(false)
			object:Expect(changedConnection.Connected):ToBe(true)
			changedConnection:Disconnect()
		end)
		object:Test("should attach to instance", function()
			local part = Instance.new("Part")
			part.Parent = workspace
			local v = maid:AttachToInstance(part)
			object:Expect(v.Connected):ToBe(true)
			part:Destroy()
			object:Expect(v.Connected):ToBe(false)
		end)
		object:Test("should fail to attach to instance not in hierarchy", function()
			local part = Instance.new("Part")
			object:Expect(function()
				maid:AttachToInstance(part)
			end):ToThrow()
		end)
		object:Test("should extend itself", function()
			local maid2 = maid:Extend()
			local v = false
			maid2:Add(function()
				v = true
			end)
			object:Expect((typeof(maid2))):ToBe("table")
			object:Expect((getmetatable(maid2))):ToBe((getmetatable(maid)))
			maid:Clean()
			object:Expect(v):ToBe(true)
		end)
		object:Test("should clone an instance", function()
			local v = maid:Construct(Instance.new, "Part")
			v.Name = "TroveCloneTest"
			local clone = maid:Clone(v)
			object:Expect((typeof(clone))):ToBe("Instance")
			object:Expect(clone):Not():ToBe(v)
			object:Expect(clone.Name):ToBe("TroveCloneTest")
			object:Expect(v.Name):ToBe(clone.Name)
		end)
		object:Test("should clean up a thread", function()
			local thread = coroutine.create(function() end)
			maid:Add(thread)
			object:Expect(coroutine.status(thread)):ToBe("suspended")
			maid:Clean()
			object:Expect(coroutine.status(thread)):ToBe("dead")
		end)
		object:Test("should not allow objects added during cleanup", function()
			local v = false
			maid:Add(function()
				maid:Add(function() end)
				v = true
			end)
			maid:Clean()
			object:Expect(v):ToBe(false)
		end)
		object:Test("should not allow objects to be removed during cleanup", function()
			local function fn() end

			local v = false
			maid:Add(fn)
			maid:Add(function()
				maid:Remove(fn)
				v = true
			end)
			object:Expect(v):ToBe(false)
		end)
	end)
end