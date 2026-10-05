return function()
	local createElement = require(script.Parent.Parent.createElement)
	local createReconciler = require(script.Parent.Parent.createReconciler)
	local createSpy = require(script.Parent.Parent.createSpy)
	local None = require(script.Parent.Parent.None)
	local NoopRenderer = require(script.Parent.Parent.NoopRenderer)
	local Component = require(script.Parent.Parent.Component)
	local reconciler = createReconciler(NoopRenderer)
	describe("setState", function()
		it("should not trigger an extra update when called in init", function()
			local count = 0
			local count2 = 0
			local state = nil
			local extended = Component:extend("InitComponent")

			function extended.init(object)
				object:setState({
					a = 1
				})
			end

			function extended.willUpdate(_)
				count2 += 1
			end

			function extended.render(p)
				count += 1
				state = p.state
				return nil
			end

			local element = createElement(extended)
			reconciler.mountVirtualTree(element)
			expect(count).to.equal(1)
			expect(count2).to.equal(0)
			expect(state.a).to.equal(1)
		end)
		it("should throw when called in render", function()
			local extended = Component:extend("TestComponent")

			function extended.render(object)
				object:setState({
					a = 1
				})
			end

			local element = createElement(extended)
			local success, result = pcall(reconciler.mountVirtualTree, element)
			expect(success).to.equal(false)
			expect(result:match("render")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)
		it("should throw when called in shouldUpdate", function()
			local extended = Component:extend("TestComponent")

			function extended.render(_)
				return nil
			end

			function extended.shouldUpdate(object)
				object:setState({
					a = 1
				})
			end

			local element = createElement(extended)
			local element2 = createElement(extended)
			local v = reconciler.mountVirtualTree(element)
			local success, result = pcall(reconciler.updateVirtualTree, v, element2)
			expect(success).to.equal(false)
			expect(result:match("shouldUpdate")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)
		it("should throw when called in willUpdate", function()
			local extended = Component:extend("TestComponent")

			function extended.render(_)
				return nil
			end

			function extended.willUpdate(object)
				object:setState({
					a = 1
				})
			end

			local element = createElement(extended)
			local element2 = createElement(extended)
			local v = reconciler.mountVirtualTree(element)
			local success, result = pcall(reconciler.updateVirtualTree, v, element2)
			expect(success).to.equal(false)
			expect(result:match("willUpdate")).to.be.ok()
			expect(result:match("TestComponent")).to.be.ok()
		end)
		it("should not throw when called in willUnmount", function()
			local extended = Component:extend("TestComponent")

			function extended.render(_)
				return nil
			end

			function extended.willUnmount(object)
				object:setState({
					a = 1
				})
			end

			local element = createElement(extended)
			local v = reconciler.mountVirtualTree(element)
			local success, _ = pcall(reconciler.unmountVirtualTree, v)
			expect(success).to.equal(true)
		end)
		it("should remove values from state when the value is None", function()
			local extended = Component:extend("TestComponent")
			local fn
			local fn2

			function extended.init(object)
				fn = function(p)
					object:setState(p)
				end

				fn2 = function()
					return object.state
				end

				object:setState({
					value = 0
				})
			end

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(fn2().value).to.equal(0)
			fn({
				value = None
			})
			expect(fn2().value).to.equal(nil)
			reconciler.unmountVirtualNode(v)
		end)
		it("should invoke functions to compute a partial state", function()
			local extended = Component:extend("TestComponent")
			local fn
			local fn2
			local fn3

			function extended.init(object)
				fn = function(fn4)
					object:setState(fn4)
				end

				fn2 = function()
					return object.state
				end

				fn3 = function()
					return object.props
				end

				object:setState({
					value = 0
				})
			end

			function extended.render(_)
				return nil
			end

			local element = createElement(extended)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(fn2().value).to.equal(0)
			fn(function(p, p2)
				expect(p).to.equal(fn2())
				expect(p2).to.equal(fn3())
				return {
					value = p.value + 1
				}
			end)
			expect(fn2().value).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
		it("should cancel rendering if the function returns nil", function()
			local extended = Component:extend("TestComponent")
			local fn
			local count = 0

			function extended.init(object)
				fn = function(fn2)
					object:setState(fn2)
				end

				object:setState({
					value = 0
				})
			end

			function extended.render(_)
				count += 1
				return nil
			end

			local element = createElement(extended)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(count).to.equal(1)
			fn(function(_, _)
				return nil
			end)
			expect(count).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
	end)
	describe("setState suspension", function()
		it("should defer setState triggered while reconciling", function()
			local extended = Component:extend("Child")
			local fn

			function extended.render(_)
				return nil
			end

			function extended.didMount(p)
				p.props.callback()
			end

			local extended2 = Component:extend("Parent")

			function extended2.init(p)
				fn = function()
					return p.state
				end
			end

			function extended2.render(object)
				return createElement(extended, {
					callback = function()
						object:setState({
							foo = "bar"
						})
					end
				})
			end

			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
			expect(fn().foo).to.equal("bar")
		end)
		it("should defer setState triggered while reconciling during an update", function()
			local extended = Component:extend("Child")
			local fn

			function extended.render(_)
				return nil
			end

			function extended.didUpdate(p)
				p.props.callback()
			end

			local extended2 = Component:extend("Parent")

			function extended2.init(p)
				fn = function()
					return p.state
				end
			end

			function extended2.render(object)
				return createElement(extended, {
					callback = function()
						if not object.state.foo then
							object:setState({
								foo = "bar"
							})
						end
					end
				})
			end

			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
			expect(fn().foo).to.equal(nil)
			local v2 = reconciler.updateVirtualNode(v, createElement(extended2))
			expect(v2).to.be.ok()
			expect(fn().foo).to.equal("bar")
			reconciler.unmountVirtualNode(v2)
		end)
		it("should combine pending state changes properly", function()
			local extended = Component:extend("Child")
			local fn

			function extended.render(_)
				return nil
			end

			function extended.didMount(p)
				p.props.callback("foo", 1)
				p.props.callback("bar", 3)
			end

			local extended2 = Component:extend("Parent")

			function extended2.init(p)
				fn = function()
					return p.state
				end
			end

			function extended2.render(object)
				return createElement(extended, {
					callback = function(p, p2)
						object:setState({
							[p] = p2
						})
					end
				})
			end

			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
			expect(fn().foo).to.equal(1)
			expect(fn().bar).to.equal(3)
			reconciler.unmountVirtualNode(v)
		end)
		it("should abort properly when functional setState returns nil while deferred", function()
			local extended = Component:extend("Child")

			function extended.render(_)
				return nil
			end

			function extended.didMount(p)
				p.props.callback()
			end

			local extended2 = Component:extend("Parent")
			local spy = createSpy(function(object)
				return createElement(extended, {
					callback = function()
						object:setState(function()
							return nil
						end)
					end
				})
			end)
			extended2.render = spy.value
			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
			expect(spy.callCount).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
		it("should still apply pending state if a subsequent state update was aborted", function()
			local extended = Component:extend("Child")
			local fn

			function extended.render(_)
				return nil
			end

			function extended.didMount(p)
				p.props.callback(function()
					return {
						foo = 1
					}
				end)
				p.props.callback(function()
					return nil
				end)
			end

			local extended2 = Component:extend("Parent")

			function extended2.init(p)
				fn = function()
					return p.state
				end
			end

			function extended2.render(object)
				return createElement(extended, {
					callback = function(p)
						object:setState(p)
					end
				})
			end

			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
			expect(fn().foo).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
		it("should not re-process new state when pending state is present after update", function()
			local fn
			local fn2
			local extended = Component:extend("MyComponent")

			function extended.init(object)
				object:setState({
					hasUpdatedOnce = false,
					counter = 0
				})

				fn = function(fn3)
					object:setState(fn3)
				end

				fn2 = function()
					return object.state
				end
			end

			function extended.render(_)
				return nil
			end

			function extended.didUpdate(object)
				if object.state.hasUpdatedOnce == false then
					object:setState({
						hasUpdatedOnce = true
					})
				end
			end

			local element = createElement(extended)
			reconciler.mountVirtualNode(element, nil, "Test")
			expect(fn2().hasUpdatedOnce).to.equal(false)
			expect(fn2().counter).to.equal(0)
			fn(function(p)
				return {
					counter = p.counter + 1
				}
			end)
			expect(fn2().hasUpdatedOnce).to.equal(true)
			expect(fn2().counter).to.equal(1)
		end)
		it("should throw when an infinite update is triggered", function()
			local extended = Component:extend("InfiniteUpdater")

			function extended.render(_)
				return nil
			end

			function extended.didMount(object)
				object:setState({})
			end

			function extended.didUpdate(object)
				object:setState({})
			end

			local element = createElement(extended)
			local success, result = pcall(reconciler.mountVirtualNode, element, nil, "Test")
			expect(success).to.equal(false)
			expect(result:find("InfiniteUpdater")).to.be.ok()
			expect(result:find("reached the setState update recursion limit")).to.be.ok()
		end)
		itSKIP("should process single updates with both new and pending state", function() end)
		it("should call trigger update after didMount when setting state in didMount", function()
			local extended = Component:extend("MyComponent")

			function extended:init()
				self:setState({
					status = "initial mount"
				})
				self.isMounted = false
			end

			function extended.render(_)
				return nil
			end

			function extended:didMount()
				self:setState({
					status = "mounted"
				})
				self.isMounted = true
			end

			function extended.didUpdate(p, _, p2)
				expect(p2.status).to.equal("initial mount")
				expect(p.state.status).to.equal("mounted")
				expect(p.isMounted).to.equal(true)
			end

			local element = createElement(extended)
			local v = reconciler.mountVirtualNode(element, nil, "Test")
			expect(v).to.be.ok()
		end)
	end)
end