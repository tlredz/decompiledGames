return function()
	local None = require(script.Parent.None)
	local assign = require(script.Parent.assign)
	it("should accept zero additional tables", function()
		local v = {}
		local v2 = assign(v)
		expect(v).to.equal(v2)
	end)
	it("should merge multiple tables onto the given target table", function()
		local v = {
			a = 5,
			b = 6
		}
		local v2 = {
			b = 7,
			c = 8
		}
		local v3 = {
			b = 8
		}
		assign(v, v2, v3)
		expect(v.a).to.equal(5)
		expect(v.b).to.equal(v3.b)
		expect(v.c).to.equal(v2.c)
	end)
	it("should remove keys if specified as None", function()
		local v = {
			foo = 2,
			bar = 3
		}
		assign(v, {
			foo = None
		})
		expect(v.foo).to.equal(nil)
		expect(v.bar).to.equal(3)
	end)
	it("should re-add keys if specified after None", function()
		local v = {
			foo = 2
		}
		local v2 = {
			foo = 3
		}
		assign(v, {
			foo = None
		}, v2)
		expect(v.foo).to.equal(v2.foo)
	end)
end