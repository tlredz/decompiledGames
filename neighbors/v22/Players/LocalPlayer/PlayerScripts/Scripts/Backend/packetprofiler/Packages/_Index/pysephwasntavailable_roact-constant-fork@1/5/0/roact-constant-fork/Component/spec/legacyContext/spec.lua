return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be provided as a mutable self._context in Component:init", function()
		local extended = Component:extend("Provider")

		function extended:init()
			self._context.foo = "bar"
		end

		function extended.render(_) end

		local element = createElement(extended)
		assertDeepEqual(reconciler.mountVirtualNode(element, nil, "Provider").legacyContext, {
			foo = "bar"
		})
	end)
	it("should be inherited from parent stateful nodes", function()
		local extended = Component:extend("Consumer")
		local _context = nil

		function extended:init()
			_context = self._context
		end

		function extended.render(_) end

		local extended2 = Component:extend("Parent")

		function extended2.render(_)
			return createElement(extended)
		end

		local element = createElement(extended2)
		local v = {
			hello = "world",
			value = 6
		}
		local v2 = reconciler.mountVirtualNode(element, nil, "Parent", nil, v)
		expect(_context).never.to.equal(v)
		expect(_context).never.to.equal(v2.legacyContext)
		assertDeepEqual(v2.legacyContext, v)
		assertDeepEqual(_context, v)
	end)
	it("should be inherited from parent function nodes", function()
		local extended = Component:extend("Consumer")
		local _context = nil

		function extended:init()
			_context = self._context
		end

		function extended.render(_) end

		local function Parent()
			return createElement(extended)
		end

		local element = createElement(Parent)
		local v = {
			hello = "world",
			value = 6
		}
		local v2 = reconciler.mountVirtualNode(element, nil, "Parent", nil, v)
		expect(_context).never.to.equal(v)
		expect(_context).never.to.equal(v2.legacyContext)
		assertDeepEqual(v2.legacyContext, v)
		assertDeepEqual(_context, v)
	end)
	it("should contain values put into the tree by parent nodes", function()
		local extended = Component:extend("Consumer")
		local _context = nil

		function extended:init()
			_context = self._context
		end

		function extended.render(_) end

		local extended2 = Component:extend("Provider")

		function extended2:init()
			self._context.frob = "ulator"
		end

		function extended2.render(_)
			return createElement(extended)
		end

		local element = createElement(extended2)
		local v = {
			dont = "try it"
		}
		local v2 = reconciler.mountVirtualNode(element, nil, "Consumer", nil, v)
		local v3 = {
			dont = "try it",
			frob = "ulator"
		}
		expect(v2.legacyContext).never.to.equal(v)
		expect(_context).never.to.equal(v)
		expect(_context).never.to.equal(v2.legacyContext)
		assertDeepEqual(v, {
			dont = "try it"
		})
		assertDeepEqual(v2.legacyContext, v3)
		assertDeepEqual(_context, v3)
	end)
	it("should transfer context to children that are replaced", function()
		local extended = Component:extend("ConsumerA")
		local _context = nil

		function extended:init()
			self._context.A = "hello"
			_context = self._context
		end

		function extended.render(_) end

		local extended2 = Component:extend("ConsumerB")
		local _context2 = nil

		function extended2:init()
			self._context.B = "hello"
			_context2 = self._context
		end

		function extended2.render(_) end

		local extended3 = Component:extend("Provider")

		function extended3:init()
			self._context.frob = "ulator"
		end

		function extended3.render(p)
			if p.props.useConsumerB then
				return createElement(extended2)
			end

			return createElement(extended)
		end

		local element = createElement(extended3)
		local v = reconciler.mountVirtualNode(element, nil, "Consumer")
		assertDeepEqual(_context, {
			frob = "ulator",
			A = "hello"
		})
		local element2 = createElement(extended3, {
			useConsumerB = true
		})
		reconciler.updateVirtualNode(v, element2)
		assertDeepEqual(_context2, {
			frob = "ulator",
			B = "hello"
		})
	end)
end