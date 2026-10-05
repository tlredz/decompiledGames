return function()
	local createElement = require(script.Parent.createElement)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local createReconciler = require(script.Parent.createReconciler)
	local PureComponent = require(script.Parent.PureComponent)
	local reconciler = createReconciler(NoopRenderer)
	it("should be extendable", function()
		local extended = PureComponent:extend("MyComponent")
		expect(extended).to.be.ok()
	end)
	it("should skip updates for shallow-equal props", function()
		local count = 0
		local fn
		local extended = PureComponent:extend("PureChild")

		function extended.willUpdate(_)
			count += 1
		end

		function extended.render(_)
			return nil
		end

		local extended2 = PureComponent:extend("PureContainer")

		function extended2:init()
			self.state = {
				value = 0
			}
		end

		function extended2.didMount(object)
			fn = function(p)
				object:setState({
					value = p
				})
			end
		end

		function extended2.render(p)
			return createElement(extended, {
				value = p.state.value
			})
		end

		local element = createElement(extended2)
		local v = reconciler.mountVirtualTree(element, nil, "PureComponent Tree")
		expect(count).to.equal(0)
		fn(1)
		expect(count).to.equal(1)
		fn(1)
		expect(count).to.equal(1)
		fn(2)
		expect(count).to.equal(2)
		fn(1)
		expect(count).to.equal(3)
		reconciler.unmountVirtualTree(v)
	end)
end