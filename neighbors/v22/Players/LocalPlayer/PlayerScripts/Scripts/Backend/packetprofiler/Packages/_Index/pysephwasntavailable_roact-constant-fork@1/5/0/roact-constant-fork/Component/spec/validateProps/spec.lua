return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local GlobalConfig = require(script.Parent.Parent.GlobalConfig)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be invoked when mounted", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")
			local spy = createSpy(function()
				return true
			end)
			extended.validateProps = spy.value

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			reconciler.mountVirtualNode(element, nil, "Test")
			expect(spy.callCount).to.equal(1)
		end)
	end)
	it("should be invoked when props change", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")
			local spy = createSpy(function()
				return true
			end)
			extended.validateProps = spy.value

			function extended.render(_)
				return nil
			end

			local element = createElement(extended, {
				a = 1
			})
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWithDeepEqual({
				a = 1
			})
			local element2 = createElement(extended, {
				a = 2
			})
			reconciler.updateVirtualNode(v, element2)
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWithDeepEqual({
				a = 2
			})
		end)
	end)
	it("should not be invoked when state changes", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")
			local fn
			local spy = createSpy(function()
				return true
			end)
			extended.validateProps = spy.value

			function extended.init(object)
				fn = function(p)
					object:setState(p)
				end
			end

			function extended.render(_)
				return nil
			end

			local element = createElement(extended, {
				a = 1
			})
			reconciler.mountVirtualNode(element, nil, "Test")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWithDeepEqual({
				a = 1
			})
			fn({
				b = 1
			})
			expect(spy.callCount).to.equal(1)
		end)
	end)
	it("should throw if validateProps is not a function", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")
			extended.validateProps = 1

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			expect(function()
				reconciler.mountVirtualNode(element, nil, "Test")
			end).to.throw()
		end)
	end)
	it("should throw if validateProps returns false", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")

			function extended.validateProps()
				return false
			end

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			expect(function()
				reconciler.mountVirtualNode(element, nil, "Test")
			end).to.throw()
		end)
	end)
	it("should include the component name in the error message", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")

			function extended.validateProps()
				return false
			end

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			local success, result = pcall(function()
				reconciler.mountVirtualNode(element, nil, "Test")
			end)
			expect(success).to.equal(false)
			local v = result:find("MyComponent")
			expect(v).to.be.ok()
		end)
	end)
	it("should be invoked after defaultProps are applied", function()
		GlobalConfig.scoped({
			propValidation = true
		}, function()
			local extended = Component:extend("MyComponent")
			local spy = createSpy(function()
				return true
			end)
			extended.validateProps = spy.value

			function extended.render(_)
				return nil
			end

			extended.defaultProps = {
				b = 2
			}
			local element = createElement(extended, {
				a = 1
			})
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWithDeepEqual({
				a = 1,
				b = 2
			})
			local element2 = createElement(extended, {
				a = 2
			})
			reconciler.updateVirtualNode(v, element2)
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWithDeepEqual({
				a = 2,
				b = 2
			})
		end)
	end)
	it("should not be invoked if the flag is off", function()
		GlobalConfig.scoped({
			propValidation = false
		}, function()
			local extended = Component:extend("MyComponent")
			local spy = createSpy(function()
				return true
			end)
			extended.validateProps = spy.value

			function extended.render(_)
				return nil
			end

			local element = createElement(extended, {
				a = 1
			})
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(spy.callCount).to.equal(0)
			local element2 = createElement(extended, {
				a = 2
			})
			reconciler.updateVirtualNode(v, element2)
			expect(spy.callCount).to.equal(0)
		end)
	end)
end