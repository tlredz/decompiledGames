return function()
	local assertDeepEqual = require(script.Parent.Parent.assertDeepEqual)
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local oneChild = require(script.Parent.Parent.oneChild)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	it("should be provided as an internal api on Component", function()
		local extended = Component:extend("Provider")

		function extended.init(object)
			object:__addContext("foo", "bar")
		end

		function extended.render(_) end

		local element = createElement(extended)
		assertDeepEqual(reconciler.mountVirtualNode(element, nil, "Provider").context, {
			foo = "bar"
		})
	end)
	it("should be inherited from parent stateful nodes", function()
		local extended = Component:extend("Consumer")
		local v = nil

		function extended.init(object)
			v = {
				hello = object:__getContext("hello"),
				value = object:__getContext("value")
			}
		end

		function extended.render(_) end

		local extended2 = Component:extend("Parent")

		function extended2.render(_)
			return createElement(extended)
		end

		local element = createElement(extended2)
		local v2 = {
			hello = "world",
			value = 6
		}
		local v3 = reconciler.mountVirtualNode(element, nil, "Parent", v2)
		expect(v).never.to.equal(v2)
		expect(v).never.to.equal(v3.context)
		assertDeepEqual(v3.context, v2)
		assertDeepEqual(v, v2)
	end)
	it("should be inherited from parent function nodes", function()
		local extended = Component:extend("Consumer")
		local v = nil

		function extended.init(object)
			v = {
				hello = object:__getContext("hello"),
				value = object:__getContext("value")
			}
		end

		function extended.render(_) end

		local function Parent()
			return createElement(extended)
		end

		local element = createElement(Parent)
		local v2 = {
			hello = "world",
			value = 6
		}
		local v3 = reconciler.mountVirtualNode(element, nil, "Parent", v2)
		expect(v).never.to.equal(v2)
		expect(v).never.to.equal(v3.context)
		assertDeepEqual(v3.context, v2)
		assertDeepEqual(v, v2)
	end)
	it("should not copy the context table if it doesn't need to", function()
		local extended = Component:extend("Parent")

		function extended.init(object)
			object:__addContext("parent", "I'm here!")
		end

		function extended.render(_)
			return createElement(function() end)
		end

		local element = createElement(extended)
		local v = reconciler.mountVirtualNode(element, nil, "Parent")
		assertDeepEqual(v.context, {
			parent = "I'm here!"
		})
		local v2 = oneChild(v.children)
		expect(v.context).to.equal(v2.context)
	end)
	it("should not allow context to move up the tree", function()
		local extended = Component:extend("ChildProvider")

		function extended.init(object)
			object:__addContext("child", "I'm here too!")
		end

		function extended.render(_) end

		local extended2 = Component:extend("ParentProvider")

		function extended2.init(object)
			object:__addContext("parent", "I'm here!")
		end

		function extended2.render(_)
			return createElement(extended)
		end

		local element = createElement(extended2)
		local v = reconciler.mountVirtualNode(element, nil, "Parent")
		local v2 = oneChild(v.children)
		assertDeepEqual(v.context, {
			parent = "I'm here!"
		})
		assertDeepEqual(v2.context, {
			parent = "I'm here!",
			child = "I'm here too!"
		})
	end)
	it("should contain values put into the tree by parent nodes", function()
		local extended = Component:extend("Consumer")
		local v = nil

		function extended.init(object)
			v = {
				dont = object:__getContext("dont"),
				frob = object:__getContext("frob")
			}
		end

		function extended.render(_) end

		local extended2 = Component:extend("Provider")

		function extended2.init(object)
			object:__addContext("frob", "ulator")
		end

		function extended2.render(_)
			return createElement(extended)
		end

		local element = createElement(extended2)
		local v2 = {
			dont = "try it"
		}
		local v3 = reconciler.mountVirtualNode(element, nil, "Consumer", v2)
		local v4 = {
			dont = "try it",
			frob = "ulator"
		}
		expect(v3.context).never.to.equal(v2)
		expect(v).never.to.equal(v2)
		expect(v).never.to.equal(v3.context)
		assertDeepEqual(v2, {
			dont = "try it"
		})
		assertDeepEqual(v3.context, v4)
		assertDeepEqual(v, v4)
	end)
	it("should transfer context to children that are replaced", function()
		local extended = Component:extend("ConsumerA")

		local function captureAllContext(object)
			return {
				A = object:__getContext("A"),
				B = object:__getContext("B"),
				frob = object:__getContext("frob")
			}
		end

		local v = nil

		function extended.init(object)
			object:__addContext("A", "hello")
			v = captureAllContext(object)
		end

		function extended.render(_) end

		local extended2 = Component:extend("ConsumerB")
		local v2 = nil

		function extended2.init(object)
			object:__addContext("B", "hello")
			v2 = captureAllContext(object)
		end

		function extended2.render(_) end

		local extended3 = Component:extend("Provider")

		function extended3.init(object)
			object:__addContext("frob", "ulator")
		end

		function extended3.render(p)
			if p.props.useConsumerB then
				return createElement(extended2)
			end

			return createElement(extended)
		end

		local element = createElement(extended3)
		local v3 = reconciler.mountVirtualNode(element, nil, "Consumer")
		assertDeepEqual(v, {
			frob = "ulator",
			A = "hello"
		})
		local element2 = createElement(extended3, {
			useConsumerB = true
		})
		reconciler.updateVirtualNode(v3, element2)
		assertDeepEqual(v2, {
			frob = "ulator",
			B = "hello"
		})
	end)
end