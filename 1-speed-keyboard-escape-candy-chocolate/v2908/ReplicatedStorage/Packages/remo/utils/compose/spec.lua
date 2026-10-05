return function()
	require(script.Parent.Parent.types)
	local compose = require(script.Parent.compose)
	it("should combine the given middleware", function()
		local v = nil
		local v2 = nil
		local v3 = nil

		local function fn(callback)
			return function(...)
				return callback(...) + 1
			end
		end

		local v4 = compose({ fn, fn, fn })(function(...)
			v, v2, v3 = ...
			return 0
		end, {})
		expect(v4("foo", "bar", "baz")).to.equal(3)
		expect(v).to.equal("foo")
		expect(v2).to.equal("bar")
		expect(v3).to.equal("baz")
	end)
	it("should work with no middleware", function()
		local v = nil
		local v2 = nil
		local v3 = nil
		local v4 = compose({})(function(...)
			v, v2, v3 = ...
			return 123
		end, {})
		expect(v4("foo", "bar", "baz")).to.equal(123)
		expect(v).to.equal("foo")
		expect(v2).to.equal("bar")
		expect(v3).to.equal("baz")
	end)
	it("should be cancellable", function()
		local count = 0
		local v = compose({ function(callback)
				return function(p)
					if p then
						return nil
					end

					return (callback())
				end
			end })(function()
			count += 1
		end, {})
		v(false)
		v(true)
		v(false)
		expect(count).to.equal(2)
	end)
	it("should allow multiple return values", function()
		local function fn(callback)
			return function(...)
				return callback(...)
			end
		end

		local v, v2, v3 = compose({ fn, fn, fn })(function()
			return "foo", "bar", "baz"
		end, {})("foo", "bar", "baz")
		expect(v).to.equal("foo")
		expect(v2).to.equal("bar")
		expect(v3).to.equal("baz")
	end)
	it("should pass the correct arguments", function()
		local v = {}
		local v2 = {}
		local v3 = {}
		compose({ function(callback)
				return function(...)
					v = { ... }
					return callback(...)
				end
			end, function(callback)
				return function(...)
					v2 = { ... }
					return callback(...)
				end
			end, function(callback)
				return function(...)
					v3 = { ... }
					return callback(...)
				end
			end })(function(...)
			return ...
		end, {})("foo", "bar", "baz")

		for _, v4 in { v, v2, v3 } do
			expect(v4[1]).to.equal("foo")
			expect(v4[2]).to.equal("bar")
			expect(v4[3]).to.equal("baz")
		end
	end)
end