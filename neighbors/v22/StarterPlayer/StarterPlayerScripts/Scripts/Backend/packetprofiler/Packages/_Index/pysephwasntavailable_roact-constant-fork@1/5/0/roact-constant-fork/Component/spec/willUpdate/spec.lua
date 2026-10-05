return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked when updated via updateVirtualNode", function()
		local extended = Component:extend("MyComponent")
		local spy = createSpy()
		extended.willUpdate = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended, {
			a = 5
		})
		local v = reconciler.mountVirtualNode(element, nil, "Test")
		local v2 = {
			a = 6,
			b = 2
		}
		local element2 = createElement(extended, v2)
		reconciler.updateVirtualNode(v, element2)
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "newProps", "newState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(captureValues.newProps, v2)
		assertDeepEqual(captureValues.newState, {})
	end)
	it("it should be invoked when updated via setState", function()
		local extended = Component:extend("MyComponent")
		local fn
		local spy = createSpy()
		extended.willUpdate = spy.value

		function extended.init(object)
			fn = function(p)
				object:setState(p)
			end

			object:setState({
				foo = 1
			})
		end

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(0)
		fn({
			foo = 2
		})
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "newProps", "newState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(captureValues.newProps, {})
		assertDeepEqual(captureValues.newState, {
			foo = 2
		})
	end)
end