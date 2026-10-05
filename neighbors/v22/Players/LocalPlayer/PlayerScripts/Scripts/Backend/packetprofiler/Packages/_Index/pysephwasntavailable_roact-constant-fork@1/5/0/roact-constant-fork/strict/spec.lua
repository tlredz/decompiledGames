return function()
	local strict = require(script.Parent.strict)
	it("should error when getting a nonexistent key", function()
		local v = strict({
			a = 1,
			b = 2
		})
		expect(function()
			return v.c
		end).to.throw()
	end)
	it("should error when setting a nonexistent key", function()
		local v = strict({
			a = 1,
			b = 2
		})
		expect(function()
			v.c = 3
		end).to.throw()
	end)
end