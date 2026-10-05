return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local GlobalConfig = require(script.Parent.Parent.GlobalConfig)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should return stack traces in initial renders", function()
		local extended = Component:extend("TestComponent")
		local v = nil

		function extended.init(object)
			v = object:getElementTraceback()
		end

		function extended.render(_)
			return nil
		end

		GlobalConfig.scoped({
			elementTracing = true
		}, function()
			local element = createElement(extended)
			reconciler.mountVirtualNode(element, nil, "Some key")
		end)
		expect(v).to.be.a("string")
	end)
	itSKIP("it should return an updated stack trace after an update", function() end)
	it("should return nil when elementTracing is off", function()
		local v = nil
		local extended = Component:extend("TestComponent")

		function extended.init(object)
			v = object:getElementTraceback()
		end

		function extended.render(_)
			return nil
		end

		GlobalConfig.scoped({
			elementTracing = false
		}, function()
			local element = createElement(extended)
			reconciler.mountVirtualNode(element, nil, "Some key")
		end)
		expect(v).to.equal(nil)
	end)
end