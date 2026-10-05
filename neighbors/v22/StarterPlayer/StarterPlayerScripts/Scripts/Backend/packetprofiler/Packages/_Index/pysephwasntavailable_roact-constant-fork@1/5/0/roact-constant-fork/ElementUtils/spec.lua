return function()
	local ElementUtils = require(script.Parent.ElementUtils)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local Type = require(script.Parent.Type)
	describe("iterateElements", function()
		it("should iterate once for a single child", function()
			local element = createElement("TextLabel")
			local v = ElementUtils.iterateElements(element)
			local v2, v3 = v()
			expect(v2).to.equal(ElementUtils.UseParentKey)
			expect(v3).to.equal(element)
			local v4 = v()
			expect(v4).to.equal(nil)
		end)
		it("should iterate over tables", function()
			local v = {
				a = createElement("TextLabel"),
				b = createElement("TextLabel")
			}
			local v2 = {}
			local count = 0

			for k, v3 in ElementUtils.iterateElements(v) do
				expect((typeof(k))).to.equal("string")
				expect(Type.of(v3)).to.equal(Type.Element)
				v2[v3] = k
				count += 1
			end

			expect(count).to.equal(2)
			expect(v2[v.a]).to.equal("a")
			expect(v2[v.b]).to.equal("b")
		end)
		it("should return a zero-element iterator for booleans", function()
			local v = ElementUtils.iterateElements(false)
			expect(v()).to.equal(nil)
		end)
		it("should return a zero-element iterator for nil", function()
			local v = ElementUtils.iterateElements(nil)
			expect(v()).to.equal(nil)
		end)
		it("should throw if given an illegal value", function()
			expect(function()
				ElementUtils.iterateElements(1)
			end).to.throw()
		end)
	end)
	describe("getElementByKey", function()
		it("should return nil for booleans", function()
			expect(ElementUtils.getElementByKey(true, "test")).to.equal(nil)
		end)
		it("should return nil for nil", function()
			expect(ElementUtils.getElementByKey(nil, "test")).to.equal(nil)
		end)
		describe("single elements", function()
			local element = createElement("TextLabel")
			it("should return the element if the key is UseParentKey", function()
				expect(ElementUtils.getElementByKey(element, ElementUtils.UseParentKey)).to.equal(element)
			end)
			it("should return nil if the key is not UseParentKey", function()
				expect(ElementUtils.getElementByKey(element, "test")).to.equal(nil)
			end)
		end)
		it("should return the corresponding element from a table", function()
			local v = {
				a = createElement("TextLabel"),
				b = createElement("TextLabel")
			}
			expect(ElementUtils.getElementByKey(v, "a")).to.equal(v.a)
			expect(ElementUtils.getElementByKey(v, "b")).to.equal(v.b)
		end)
		it("should return nil if the key does not exist", function()
			local fragment = createFragment({})
			expect(ElementUtils.getElementByKey(fragment, "a")).to.equal(nil)
		end)
	end)
end