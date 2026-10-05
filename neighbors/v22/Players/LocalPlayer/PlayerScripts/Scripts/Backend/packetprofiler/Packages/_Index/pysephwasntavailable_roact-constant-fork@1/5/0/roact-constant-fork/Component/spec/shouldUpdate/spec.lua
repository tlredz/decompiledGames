return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked when props update", function()
		local extended = Component:extend("MyComponent")
		local props = nil
		local state = nil
		local spy = createSpy(function(p)
			props = p.props
			state = p.state
			return true
		end)
		extended.shouldUpdate = spy.value

		function extended.render(_)
			return nil
		end

		local v = {
			a = 5
		}
		local element = createElement(extended, v)
		local v2 = reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(0)
		local v3 = {
			a = 6,
			b = 2
		}
		local element2 = createElement(extended, v3)
		reconciler.updateVirtualNode(v2, element2)
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "newProps", "newState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(captureValues.newProps, v3)
		assertDeepEqual(props, v)
		expect(captureValues.newState).to.equal(state)
		assertDeepEqual(state, {})
	end)
	it("should be invoked when state is updated", function()
		local extended = Component:extend("MyComponent")
		local v = {
			a = 1
		}
		local fn
		local state = nil

		function extended.init(object)
			fn = function(...)
				return object:setState(...)
			end

			object:setState(v)
			state = object.state
		end

		local props = nil
		local state2 = nil
		local spy = createSpy(function(p)
			props = p.props
			state2 = p.state
			return true
		end)
		extended.shouldUpdate = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(0)
		local v2 = {
			a = 2,
			b = 3
		}
		fn(v2)
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self", "newProps", "newState")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		expect(captureValues.newProps).to.equal(props)
		assertDeepEqual(props, {})
		assertDeepEqual(state2, v)
		expect(state2).to.equal(state)
		assertDeepEqual(captureValues.newState, v2)
	end)
	it("should not abort an update when returning true", function()
		local extended = Component:extend("MyComponent")

		function extended.shouldUpdate(_)
			return true
		end

		local spy = createSpy()
		extended.render = spy.value
		local element = createElement(extended)
		local v = reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(1)
		local element2 = createElement(extended)
		reconciler.updateVirtualNode(v, element2)
		expect(spy.callCount).to.equal(2)
	end)
	it("should abort an update when retuning false", function()
		local extended = Component:extend("MyComponent")

		function extended.shouldUpdate(_)
			return false
		end

		local spy = createSpy()
		extended.render = spy.value
		local element = createElement(extended)
		local v = reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(1)
		local element2 = createElement(extended)
		reconciler.updateVirtualNode(v, element2)
		expect(spy.callCount).to.equal(1)
	end)
end