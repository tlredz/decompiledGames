local ServerScriptService = game:GetService("ServerScriptService")
require(ServerScriptService.TestRunner.Test)
return function(object)
	local parentModule = require(script.Parent)
	object:Describe("Timer", function()
		local v = nil
		object:BeforeEach(function()
			v = parentModule.new(0.1)
			v.TimeFunction = os.clock
		end)
		object:AfterEach(function()
			if v then
				v:Destroy()
				v = nil
			end
		end)
		object:Test("should create a new timer", function()
			object:Expect(parentModule.is(v)):ToBe(true)
		end)
		object:Test("should tick appropriately", function()
			local lastTime = os.clock()
			v:Start()
			v.Tick:Wait()
			local v2 = os.clock() - lastTime
			object:Expect(v2):ToBeNear(v2, 0.02)
		end)
		object:Test("should start immediately", function()
			local now = os.clock()
			local now2 = nil
			v.Tick:Connect(function()
				if not now2 then
					now2 = os.clock()
				end
			end)
			v:StartNow()
			v.Tick:Wait()
			object:Expect(now2):ToBeA("number")
			object:Expect(now2 - now):ToBeNear(0, 0.02)
		end)
		object:Test("should stop", function()
			local count = 0
			v.Tick:Connect(function()
				count += 1
			end)
			v:StartNow()
			v:Stop()
			task.wait(1)
			object:Expect(count):ToBe(1)
		end)
		object:Test("should detect if running", function()
			object:Expect(v:IsRunning()):ToBe(false)
			v:Start()
			object:Expect(v:IsRunning()):ToBe(true)
			v:Stop()
			object:Expect(v:IsRunning()):ToBe(false)
			v:StartNow()
			object:Expect(v:IsRunning()):ToBe(true)
			v:Stop()
			object:Expect(v:IsRunning()):ToBe(false)
		end)
	end)
end