return function()
	local assertDeepEqual = require(script.Parent.assertDeepEqual)
	it("should fail with a message when args are not equal", function()
		local success, result = pcall(assertDeepEqual, 1, 2)
		expect(success).to.equal(false)
		expect(result:find("first ~= second")).to.be.ok()
		local success2, result2 = pcall(assertDeepEqual, {
			foo = 1
		}, {
			foo = 2
		})
		expect(success2).to.equal(false)
		expect(result2:find("first%[foo%] ~= second%[foo%]")).to.be.ok()
	end)
	it("should compare non-table values using standard '==' equality", function()
		assertDeepEqual(1, 1)
		assertDeepEqual("hello", "hello")
		assertDeepEqual(nil, nil)

		local function fn() end

		assertDeepEqual(fn, fn)
		assertDeepEqual({
			foo = fn
		}, {
			foo = fn
		})
	end)
	it("should fail when types differ", function()
		local success, result = pcall(assertDeepEqual, 1, "1")
		expect(success).to.equal(false)
		expect(result:find("first is of type number, but second is of type string")).to.be.ok()
	end)
	it("should compare (and report about) nested tables", function()
		local v = {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2
			}
		}
		assertDeepEqual(v, {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 2
			}
		})
		local success, result = pcall(assertDeepEqual, v, {
			foo = "bar",
			nested = {
				foo = 1,
				bar = 3
			}
		})
		expect(success).to.equal(false)
		expect(result:find("first%[nested%]%[bar%] ~= second%[nested%]%[bar%]")).to.be.ok()
	end)
	it("should be commutative", function()
		local v = {
			foo = "bar",
			hello = "world"
		}
		local v2 = {
			foo = "bar",
			hello = "world"
		}
		assertDeepEqual(v, v2)
		assertDeepEqual(v2, v)
		local v3 = {
			foo = "bar"
		}
		expect(function()
			assertDeepEqual(v, v3)
		end).to.throw()
		expect(function()
			assertDeepEqual(v3, v)
		end).to.throw()
	end)
end