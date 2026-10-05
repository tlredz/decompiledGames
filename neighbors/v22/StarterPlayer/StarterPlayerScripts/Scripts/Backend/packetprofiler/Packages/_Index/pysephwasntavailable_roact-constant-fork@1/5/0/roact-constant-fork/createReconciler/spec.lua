return function()
	local assign = require(script.Parent.assign)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createSpy = require(script.Parent.createSpy)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local Type = require(script.Parent.Type)
	local ElementKind = require(script.Parent.ElementKind)
	local createReconciler = require(script.Parent.createReconciler)
	local reconciler = createReconciler(NoopRenderer)
	describe("tree operations", function()
		it("should mount and unmount", function()
			local v = reconciler.mountVirtualTree(createElement("StringValue"))
			expect(v).to.be.ok()
			reconciler.unmountVirtualTree(v)
		end)
		it("should mount, update, and unmount", function()
			local v = reconciler.mountVirtualTree(createElement("StringValue"))
			expect(v).to.be.ok()
			reconciler.updateVirtualTree(v, createElement("StringValue"))
			reconciler.unmountVirtualTree(v)
		end)
	end)
	describe("booleans", function()
		it("should mount booleans as nil", function()
			local v = reconciler.mountVirtualNode(false, nil, "test")
			expect(v).to.equal(nil)
		end)
		it("should unmount nodes if they are updated to a boolean value", function()
			local v = reconciler.mountVirtualNode(createElement("StringValue"), nil, "test")
			expect(v).to.be.ok()
			local v2 = reconciler.updateVirtualNode(v, true)
			expect(v2).to.equal(nil)
		end)
	end)
	describe("invalid elements", function()
		it("should throw errors when attempting to mount invalid elements", function()
			local function fn()
				return "Hello"
			end

			local function fn2()
				return 1
			end

			local function fn3()
				return function() end
			end

			local function fn4()
				return {}
			end

			expect(function()
				reconciler.mountVirtualNode(createElement(fn), nil, "Some Key")
			end).to.throw()
			expect(function()
				reconciler.mountVirtualNode(createElement(fn2), nil, "Some Key")
			end).to.throw()
			expect(function()
				reconciler.mountVirtualNode(createElement(fn3), nil, "Some Key")
			end).to.throw()
			expect(function()
				reconciler.mountVirtualNode(createElement(fn4), nil, "Some Key")
			end).to.throw()
		end)
	end)
	describe("Host components", function()
		it("should invoke the renderer to mount host nodes", function()
			local spy = createSpy(NoopRenderer.mountHostNode)
			local reconciler2 = createReconciler((assign({}, NoopRenderer, {
				mountHostNode = spy.value
			})))
			local element = createElement("StringValue")
			local v2 = reconciler2.mountVirtualNode(element, nil, "Some Key")
			expect(Type.of(v2)).to.equal(Type.VirtualNode)
			expect(spy.callCount).to.equal(1)
			local captureValues = spy:captureValues("reconciler", "node")
			expect(captureValues.reconciler).to.equal(reconciler2)
			expect(captureValues.node).to.equal(v2)
		end)
		it("should invoke the renderer to update host nodes", function()
			local spy = createSpy(NoopRenderer.updateHostNode)
			local reconciler2 = createReconciler((assign({}, NoopRenderer, {
				mountHostNode = NoopRenderer.mountHostNode,
				updateHostNode = spy.value
			})))
			local element = createElement("StringValue")
			local v2 = reconciler2.mountVirtualNode(element, nil, "Key")
			expect(Type.of(v2)).to.equal(Type.VirtualNode)
			local element2 = createElement("StringValue")
			local v3 = reconciler2.updateVirtualNode(v2, element2)
			expect(v3).to.equal(v2)
			expect(spy.callCount).to.equal(1)
			local captureValues = spy:captureValues("reconciler", "node", "newElement")
			expect(captureValues.reconciler).to.equal(reconciler2)
			expect(captureValues.node).to.equal(v2)
			expect(captureValues.newElement).to.equal(element2)
		end)
		it("should invoke the renderer to unmount host nodes", function()
			local spy = createSpy(NoopRenderer.unmountHostNode)
			local reconciler2 = createReconciler((assign({}, NoopRenderer, {
				mountHostNode = NoopRenderer.mountHostNode,
				unmountHostNode = spy.value
			})))
			local element = createElement("StringValue")
			local v2 = reconciler2.mountVirtualNode(element, nil, "Key")
			expect(Type.of(v2)).to.equal(Type.VirtualNode)
			reconciler2.unmountVirtualNode(v2)
			expect(spy.callCount).to.equal(1)
			local captureValues = spy:captureValues("reconciler", "node")
			expect(captureValues.reconciler).to.equal(reconciler2)
			expect(captureValues.node).to.equal(v2)
		end)
	end)
	describe("Function components", function()
		it("should mount and unmount function components", function()
			local spy = createSpy(function(_)
				return nil
			end)
			local element = createElement(spy.value, {
				someValue = 5
			})
			local v = reconciler.mountVirtualNode(element, nil, "A Key")
			expect(Type.of(v)).to.equal(Type.VirtualNode)
			expect(spy.callCount).to.equal(1)
			local captureValues = spy:captureValues("props")
			expect(captureValues.props).to.be.a("table")
			expect(captureValues.props.someValue).to.equal(5)
			reconciler.unmountVirtualNode(v)
			expect(spy.callCount).to.equal(1)
		end)
		it("should mount single children of function components", function()
			local spy = createSpy(function(_)
				return nil
			end)
			local spy2 = createSpy(function(p)
				return createElement(spy.value, {
					value = p.value + 1
				})
			end)
			local element = createElement(spy2.value, {
				value = 13
			})
			local v = reconciler.mountVirtualNode(element, nil, "A Key")
			expect(Type.of(v)).to.equal(Type.VirtualNode)
			expect(spy2.callCount).to.equal(1)
			expect(spy.callCount).to.equal(1)
			local captureValues = spy2:captureValues("props")
			local captureValues2 = spy:captureValues("props")
			expect(captureValues.props).to.be.a("table")
			expect(captureValues.props.value).to.equal(13)
			expect(captureValues2.props).to.be.a("table")
			expect(captureValues2.props.value).to.equal(14)
			reconciler.unmountVirtualNode(v)
			expect(spy2.callCount).to.equal(1)
			expect(spy.callCount).to.equal(1)
		end)
		it("should mount fragments returned by function components", function()
			local spy = createSpy(function(_)
				return nil
			end)
			local spy2 = createSpy(function(_)
				return nil
			end)
			local spy3 = createSpy(function(p)
				return createFragment({
					A = createElement(spy.value, {
						value = p.value + 1
					}),
					B = createElement(spy2.value, {
						value = p.value + 5
					})
				})
			end)
			local element = createElement(spy3.value, {
				value = 17
			})
			local v = reconciler.mountVirtualNode(element, nil, "A Key")
			expect(Type.of(v)).to.equal(Type.VirtualNode)
			expect(spy3.callCount).to.equal(1)
			expect(spy.callCount).to.equal(1)
			expect(spy2.callCount).to.equal(1)
			local captureValues = spy3:captureValues("props")
			local captureValues2 = spy:captureValues("props")
			local captureValues3 = spy2:captureValues("props")
			expect(captureValues.props).to.be.a("table")
			expect(captureValues.props.value).to.equal(17)
			expect(captureValues2.props).to.be.a("table")
			expect(captureValues2.props.value).to.equal(18)
			expect(captureValues3.props).to.be.a("table")
			expect(captureValues3.props.value).to.equal(22)
			reconciler.unmountVirtualNode(v)
			expect(spy3.callCount).to.equal(1)
			expect(spy.callCount).to.equal(1)
			expect(spy2.callCount).to.equal(1)
		end)
	end)
	describe("Fragments", function()
		it("should mount fragments", function()
			local fragment = createFragment({})
			local v = reconciler.mountVirtualNode(fragment, nil, "test")
			expect(v).to.be.ok()
			expect(ElementKind.of(v.currentElement)).to.equal(ElementKind.Fragment)
		end)
		it("should mount an empty fragment", function()
			local fragment = createFragment({})
			local v = reconciler.mountVirtualNode(fragment, nil, "test")
			expect(v).to.be.ok()
			local v2 = next(v.children)
			expect(v2).to.never.be.ok()
		end)
		it("should mount all fragment's children", function()
			local spy = createSpy(function(_)
				return nil
			end)
			local v = {}

			for i = 1, 5 do
				v["key" .. tostring(i)] = createElement(spy.value, {})
			end

			local fragment = createFragment(v)
			local v2 = reconciler.mountVirtualNode(fragment, nil, "test")
			expect(v2).to.be.ok()
			expect(spy.callCount).to.equal(5)
		end)
	end)
end