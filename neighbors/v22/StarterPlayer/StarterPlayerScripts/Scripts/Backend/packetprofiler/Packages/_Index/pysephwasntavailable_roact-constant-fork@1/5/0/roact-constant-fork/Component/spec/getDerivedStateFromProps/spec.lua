return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createSpy = require(script.Parent.Parent.createSpy)
	local createElement = require(script.Parent.Parent.createElement)
	local createFragment = require(script.Parent.Parent.createFragment)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked on initial mount", function()
		local spy = createSpy()
		local extended = Component:extend("WithDerivedState")
		extended.getDerivedStateFromProps = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended, {
			someProp = 1
		})
		reconciler.mountVirtualNode(element, nil, "WithDerivedState")
		expect(spy.callCount).to.equal(1)
		local captureValues = spy:captureValues("props", "state")
		assertDeepEqual(captureValues.props, {
			someProp = 1
		})
		assertDeepEqual(captureValues.state, {})
	end)
	it("should be invoked when updated via props", function()
		local spy = createSpy()
		local extended = Component:extend("WithDerivedState")
		extended.getDerivedStateFromProps = spy.value

		function extended.render(_)
			return nil
		end

		local v = reconciler.mountVirtualNode(createElement(extended, {
			someProp = 1
		}), nil, "WithDerivedState")
		reconciler.updateVirtualNode(v, createElement(extended, {
			someProp = 2
		}))
		expect(spy.callCount).to.equal(2)
		local captureValues = spy:captureValues("props", "state")
		assertDeepEqual(captureValues.props, {
			someProp = 2
		})
		assertDeepEqual(captureValues.state, {})
	end)
	it("should be invoked when updated via state", function()
		local spy = createSpy()
		local extended = Component:extend("WithDerivedState")
		extended.getDerivedStateFromProps = spy.value

		function extended.init(object)
			object:setState({
				someState = 1
			})
		end

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		local v = reconciler.mountVirtualNode(element, nil, "WithDerivedState")
		reconciler.updateVirtualNode(v, element, {
			someState = 2
		})
		expect(spy.callCount).to.equal(4)
		local captureValues = spy:captureValues("props", "state")
		assertDeepEqual(captureValues.props, {})
		assertDeepEqual(captureValues.state, {
			someState = 2
		})
	end)
	it("should be invoked when updating via state in init (which skips reconciliation)", function()
		local spy = createSpy()
		local extended = Component:extend("WithDerivedState")
		extended.getDerivedStateFromProps = spy.value

		function extended.init(object)
			object:setState({
				stateFromInit = 1
			})
		end

		function extended.render(_)
			return nil
		end

		local element = createElement(extended, {
			someProp = 1
		})
		reconciler.mountVirtualNode(element, nil, "WithDerivedState")
		expect(spy.callCount).to.equal(3)
		local captureValues = spy:captureValues("props", "state")
		assertDeepEqual(captureValues.props, {
			someProp = 1
		})
		assertDeepEqual(captureValues.state, {
			stateFromInit = 1
		})
	end)
	it("should receive defaultProps", function()
		local spy = createSpy()
		local extended = Component:extend("WithDerivedState")
		extended.defaultProps = {
			someDefaultProp = "foo"
		}
		extended.getDerivedStateFromProps = spy.value

		function extended.render(_)
			return nil
		end

		local element = createElement(extended, {
			someProp = 1
		})
		local v = reconciler.mountVirtualNode(element, nil, "WithDerivedState")
		expect(spy.callCount).to.equal(1)
		assertDeepEqual(spy:captureValues("props", "state").props, {
			someDefaultProp = "foo",
			someProp = 1
		})
		local element2 = createElement(extended, {
			someProp = 2
		})
		reconciler.updateVirtualNode(v, element2)
		expect(spy.callCount).to.equal(2)
		assertDeepEqual(spy:captureValues("props", "state").props, {
			someDefaultProp = "foo",
			someProp = 2
		})
	end)
	it("should derive state for all setState updates, even when deferred", function()
		local extended = Component:extend("Child")
		local spy = createSpy(function()
			return {}
		end)
		local spy2 = createSpy()

		function extended.render(_)
			return nil
		end

		function extended.didMount(p)
			p.props.callback()
		end

		local extended2 = Component:extend("Parent")
		extended2.getDerivedStateFromProps = spy2.value

		function extended2.render(object)
			local function fn()
				object:setState(spy.value)
			end

			return createFragment({
				ChildA = createElement(extended, {
					callback = fn
				}),
				ChildB = createElement(extended, {
					callback = fn
				})
			})
		end

		local element = createElement(extended2)
		reconciler.mountVirtualNode(element, nil, "Test")
		expect(spy.callCount).to.equal(2)
		expect(spy2.callCount).to.equal(3)
	end)
	it("should have derived state after assigning to state in init", function()
		local fn
		local spy = createSpy(function()
			return {
				derived = true
			}
		end)
		local extended = Component:extend("WithDerivedState")
		extended.getDerivedStateFromProps = spy.value

		function extended:init()
			self.state = {
				init = true
			}

			fn = function()
				return self.state
			end
		end

		function extended.render(_)
			return nil
		end

		local element = createElement(extended)
		reconciler.mountVirtualNode(element, nil, "WithDerivedState")
		expect(spy.callCount).to.equal(2)
		assertDeepEqual(fn(), {
			init = true,
			derived = true
		})
	end)
end