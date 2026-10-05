return function()
	local parentModule = require(script.Parent)
	describe("Timer", function()
		local v = nil
		beforeEach(function()
			v = parentModule.new(0.1)
			v.TimeFunction = os.clock
		end)
		afterEach(function()
			if v then
				v:Destroy()
				v = nil
			end
		end)
		it("should create a new timer", function()
			expect(parentModule.Is(v)).to.equal(true)
		end)
		it("should tick appropriately", function()
			local lastTime = os.clock()
			v:Start()
			v.Tick:Wait()
			local v2 = os.clock() - lastTime
			expect(v2).to.be.near(v2, 0.02)
		end)
		it("should start immediately", function()
			local now = os.clock()
			local now2 = nil
			v.Tick:Connect(function()
				if not now2 then
					now2 = os.clock()
				end
			end)
			v:StartNow()
			v.Tick:Wait()
			expect(now2).to.be.a("number")
			local v2 = now2 - now
			expect(v2).to.be.near(0, 0.02)
		end)
		it("should stop", function()
			local count = 0
			v.Tick:Connect(function()
				count += 1
			end)
			v:StartNow()
			v:Stop()
			task.wait(1)
			expect(count).to.equal(1)
		end)
		it("should detect if running", function()
			expect(v:IsRunning()).to.equal(false)
			v:Start()
			expect(v:IsRunning()).to.equal(true)
			v:Stop()
			expect(v:IsRunning()).to.equal(false)
			v:StartNow()
			expect(v:IsRunning()).to.equal(true)
			v:Stop()
			expect(v:IsRunning()).to.equal(false)
		end)
	end)
end