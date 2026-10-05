return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked when unmounted", function()
		local extended = Component:extend("MyComponent")
		local spy = createSpy()
		extended.willUnmount = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		local v = reconciler.mountVirtualNode(element, nil, "Test")
		reconciler.unmountVirtualNode(v)
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
	end)
end