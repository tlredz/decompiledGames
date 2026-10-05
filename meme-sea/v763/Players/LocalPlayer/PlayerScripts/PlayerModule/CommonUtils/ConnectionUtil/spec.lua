local CorePackages = game:GetService("CorePackages")
local JestGlobals = require(CorePackages.Packages.Dev.JestGlobals)
local describe = JestGlobals.describe
local expect = JestGlobals.expect
local it = JestGlobals.it
local AppCommonLib = require(CorePackages.Workspace.Packages.AppCommonLib)
local signal = AppCommonLib.Signal
local ConnectionUtil = require(script.Parent.ConnectionUtil)
describe("ConnectionUtil", function()
	it("should instantiate", function()
		expect((ConnectionUtil.new())).never.toBeNil()
	end)
	it("should track a connection", function()
		local v = ConnectionUtil.new()
		local v2 = signal.new()
		local v3 = ""
		v:trackConnection("Signal", v2:Connect(function(p)
			v3 = p
		end))
		v2:fire("Testing")
		expect(v3).toBe("Testing")
	end)
	it("should disconnect from signal", function()
		local v = ConnectionUtil.new()
		local v2 = signal.new()
		local v3 = ""
		v:trackConnection("Signal", v2:Connect(function(p)
			v3 = p
		end))
		v:disconnect("Signal")
		v2:fire("Testing")
		expect(v3).toBe("")
	end)
	it("should disconnect from all", function()
		local v = ConnectionUtil.new()
		local v2 = signal.new()
		local v3 = signal.new()
		local v4 = signal.new()
		local v5 = ""
		local v6 = ""
		local v7 = ""
		v:trackConnection("Signal", v2:Connect(function(p)
			v5 = p
		end))
		v:trackConnection("Signal1", v3:Connect(function(p)
			v6 = p
		end))
		v:trackConnection("Signal2", v4:Connect(function(p)
			v7 = p
		end))
		v:disconnectAll()
		v2:fire("TestingPrimary")
		v2:fire("TestingSecondary")
		v2:fire("TestingTertiary")
		expect(v5).toBe("")
		expect(v6).toBe("")
		expect(v7).toBe("")
	end)
	it("should call manual disconnect", function()
		local v = ConnectionUtil.new()
		local v2 = ""
		v:trackBoundFunction("Manual", function()
			v2 = "Disconnected"
		end)
		v:disconnect("Manual")
		expect(v2).toBe("Disconnected")
	end)
end)