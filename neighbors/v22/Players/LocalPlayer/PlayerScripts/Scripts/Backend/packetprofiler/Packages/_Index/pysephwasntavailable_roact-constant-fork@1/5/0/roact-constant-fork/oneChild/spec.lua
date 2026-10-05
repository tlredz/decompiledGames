return function()
	local createElement = require(script.Parent.createElement)
	local oneChild = require(script.Parent.oneChild)
	it("should get zero children from a table", function()
		expect(oneChild({})).to.equal(nil)
	end)
	it("should get exactly one child", function()
		local element = createElement("Frame")
		expect(oneChild({
			foo = element
		})).to.equal(element)
	end)
	it("should error with more than one child", function()
		local v = {
			a = createElement("Frame"),
			b = createElement("Frame")
		}
		expect(function()
			oneChild(v)
		end).to.throw()
	end)
	it("should handle being passed nil", function()
		expect(oneChild(nil)).to.equal(nil)
	end)
end