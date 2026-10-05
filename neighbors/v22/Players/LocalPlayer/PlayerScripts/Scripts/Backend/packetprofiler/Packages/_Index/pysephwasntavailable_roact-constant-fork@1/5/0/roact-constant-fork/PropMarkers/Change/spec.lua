return function()
	local Type = require(script.Parent.Parent.Type)
	local Change = require(script.Parent.Change)
	it("should yield change listener objects when indexed", function()
		expect(Type.of(Change.Text)).to.equal(Type.HostChangeEvent)
		expect(Type.of(Change.Selected)).to.equal(Type.HostChangeEvent)
	end)
	it("should yield the same object when indexed again", function()
		local text = Change.Text
		local text2 = Change.Text
		local selected = Change.Selected
		expect(text).to.equal(text2)
		expect(text).never.to.equal(selected)
	end)
end