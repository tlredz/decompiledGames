return function()
	local Type = require(script.Parent.Parent.Type)
	local Event = require(script.Parent.Event)
	it("should yield event objects when indexed", function()
		expect(Type.of(Event.MouseButton1Click)).to.equal(Type.HostEvent)
		expect(Type.of(Event.Touched)).to.equal(Type.HostEvent)
	end)
	it("should yield the same object when indexed again", function()
		local mouseButton1Click = Event.MouseButton1Click
		local mouseButton1Click2 = Event.MouseButton1Click
		local touched = Event.Touched
		expect(mouseButton1Click).to.equal(mouseButton1Click2)
		expect(mouseButton1Click).never.to.equal(touched)
	end)
end