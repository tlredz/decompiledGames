return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked when mounted", function()
		local extended = Component:extend("MyComponent")
		local spy = createSpy()
		extended.didMount = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
	end)
end