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
		extended.didUpdate = spy.value

		function extended.render(_)
			return nil
		end

		local v = {
			a = 5
		}
		local element = createElement(extended, v)
		local v2 = reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(0)
		local element2 = createElement(extended, {
			a = 6,
			b = 2
		})
		reconciler.updateVirtualNode(v2, element2)
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "oldProps", "oldState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(captureValues.oldProps, v)
		assertDeepEqual(captureValues.oldState, {})
	end)
	it("should be invoked when updated via setState", function()
		local extended = Component:extend("MyComponent")
		local spy = createSpy()
		extended.didUpdate = spy.value
		local v = {
			a = 4
		}
		local fn

		function extended.init(object)
			fn = function(...)
				return object:setState(...)
			end

			object:setState(v)
		end

		function extended.render(_) end

		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(0)
		fn({
			a = 5
		})
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "oldProps", "oldState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(captureValues.oldProps, {})
		assertDeepEqual(captureValues.oldState, v)
	end)
end