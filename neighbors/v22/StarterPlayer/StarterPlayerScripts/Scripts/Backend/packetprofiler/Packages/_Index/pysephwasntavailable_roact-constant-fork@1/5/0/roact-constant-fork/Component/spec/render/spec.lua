return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Type = require(script.Parent.Parent.Type)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should throw on mount if not overridden", function()
		local element = createElement((Component:extend("MyComponent")))
		local success, result = pcall(function()
			reconciler.mountVirtualNode(element, nil, "Test")
		end)
		expect(success).to.equal(false)
		expect(result:match("MyComponent")).to.be.ok()
		expect(result:match("render")).to.be.ok()
	end)
	it("should be invoked when a component is mounted", function()
		local extended = Component:extend("Foo")
		local props = nil
		local state = nil
		local spy = createSpy(function(p)
			props = p.props
			state = p.state
		end)
		extended.render = spy.value
		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Foo Test")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self")
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(props, {})
		assertDeepEqual(state, {})
	end)
	it("should be invoked when a component is updated via props", function()
		local extended = Component:extend("Foo")
		local props = nil
		local state = nil
		local spy = createSpy(function(p)
			props = p.props
			state = p.state
		end)
		extended.render = spy.value
		local v = {
			a = 2
		}
		local element = createElement(extended, v)
		local v2 = reconciler.mountVirtualNode(element, nil, "Foo Test")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self")
		local v3 = props
		local v4 = state
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		assertDeepEqual(v3, v)
		assertDeepEqual(v4, {})
		local v5 = {
			a = 3
		}
		local element2 = createElement(extended, v5)
		reconciler.updateVirtualNode(v2, element2)
		expect(spy.callCount).to.equal(2)
		local captureValues2 = spy:captureValues("self")
		local v6 = props
		local v7 = state
		expect(Type.of(captureValues2.self)).to.equal(Type.StatefulComponentInstance)
		expect(v6).never.to.equal(v3)
		assertDeepEqual(v6, v5)
		expect(v7).to.equal(v4)
	end)
	it("should be invoked when a component is updated via state", function()
		local extended = Component:extend("Foo")
		local fn

		function extended.init(object)
			fn = function(...)
				return object:setState(...)
			end
		end

		local props = nil
		local state = nil
		local spy = createSpy(function(p)
			props = p.props
			state = p.state
		end)
		extended.render = spy.value
		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "Foo Test")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("self")
		local v = props
		local v2 = state
		expect(Type.of(captureValues.self)).to.equal(Type.StatefulComponentInstance)
		fn({})
		expect(spy.callCount).to.equal(2)
		local captureValues2 = spy:captureValues("self")
		expect(Type.of(captureValues2.self)).to.equal(Type.StatefulComponentInstance)
		expect(props).to.equal(v)
		expect(state).never.to.equal(v2)
	end)
	itSKIP("Test defaultProps on initial render", function() end)
	itSKIP("Test defaultProps on prop update", function() end)
	itSKIP("Test defaultProps on state update", function() end)
end