return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked with props when mounted", function()
		local extended = Component:extend("MyComponent")
		local spy = createSpy()
		extended.init = spy.value

		function extended.render(_)
			return nil
		end

		local v = {
			a = 5
		}
		local element = createElement(extended, v)
		reconciler.mountVirtualNode(element, nil, "Some Component Key")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "props")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		expect((typeof(captureValues.props))).to.equal("table")
		assertDeepEqual(captureValues.props, v)
	end)
end