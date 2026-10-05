return function()
	local Config = require(script.Parent.Config)
	it("should accept valid configuration", function()
		local v = Config.new()
		local v2 = v.get()
		expect(v2.elementTracing).to.equal(false)
		v.set({
			elementTracing = true
		})
		expect(v2.elementTracing).to.equal(true)
	end)
	it("should reject invalid configuration keys", function()
		local v = Config.new()
		local success, result = pcall(function()
			v.set({
				garblegoop = true
			})
		end)
		expect(success).to.equal(false)
		expect(result:find("garblegoop")).to.be.ok()
	end)
	it("should reject invalid configuration values", function()
		local v = Config.new()
		local success, result = pcall(function()
			v.set({
				elementTracing = "Hello there!"
			})
		end)
		expect(success).to.equal(false)
		expect(result:find("elementTracing")).to.be.ok()
		expect(result:find("Hello there!")).to.be.ok()
	end)
end