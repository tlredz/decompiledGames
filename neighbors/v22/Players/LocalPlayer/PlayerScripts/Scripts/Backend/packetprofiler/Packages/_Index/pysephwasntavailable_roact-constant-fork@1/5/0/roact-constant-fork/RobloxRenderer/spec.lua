return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local assertDeepEqual = require(script.Parent.assertDeepEqual)
	local Binding = require(script.Parent.Binding)
	local Children = require(script.Parent.PropMarkers.Children)
	local Component = require(script.Parent.Component)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createReconciler = require(script.Parent.createReconciler)
	local createRef = require(script.Parent.createRef)
	local createSpy = require(script.Parent.createSpy)
	local GlobalConfig = require(script.Parent.GlobalConfig)
	local Portal = require(script.Parent.Portal)
	local Ref = require(script.Parent.PropMarkers.Ref)
	local Event = require(script.Parent.PropMarkers.Event)
	local RobloxRenderer = require(script.Parent.RobloxRenderer)
	local reconciler = createReconciler(RobloxRenderer)
	describe("mountHostNode", function()
		it("should create instances with correct props", function()
			local folder = Instance.new("Folder")
			local element = createElement("StringValue", {
				Value = "Hello!"
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(v.ClassName).to.equal("StringValue")
			expect(v.Value).to.equal("Hello!")
			expect(v.Name).to.equal("Some Key")
		end)
		it("should create children with correct names and props", function()
			local folder = Instance.new("Folder")
			local element = createElement("StringValue", {
				Value = "Hey there!"
			}, {
				ChildA = createElement("IntValue", {
					Value = 173
				}),
				ChildB = createElement("Folder")
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(v.ClassName).to.equal("StringValue")
			expect(v.Value).to.equal("Hey there!")
			expect(v.Name).to.equal("Some Key")
			expect(#v:GetChildren()).to.equal(2)
			local childA = v.ChildA
			local childB = v.ChildB
			expect(childA).to.be.ok()
			expect(childB).to.be.ok()
			expect(childA.ClassName).to.equal("IntValue")
			expect(childA.Value).to.equal(173)
			expect(childB.ClassName).to.equal("Folder")
		end)
		it("should attach Bindings to Roblox properties", function()
			local folder = Instance.new("Folder")
			local v, v2 = Binding.create(10)
			local element = createElement("IntValue", {
				Value = v
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v3 = folder:GetChildren()[1]
			expect(v3.ClassName).to.equal("IntValue")
			expect(v3.Value).to.equal(10)
			v2(20)
			expect(v3.Value).to.equal(20)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should connect Binding refs", function()
			local folder = Instance.new("Folder")
			local ref = createRef()
			local element = createElement("Frame", {
				[Ref] = ref
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(ref.current).to.be.ok()
			expect(ref.current).to.equal(v)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should call function refs", function()
			local folder = Instance.new("Folder")
			local spy = createSpy()
			local element = createElement("Frame", {
				[Ref] = spy.value
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith(v)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should throw if setting invalid instance properties", function()
			GlobalConfig.scoped({
				elementTracing = true
			}, function()
				local folder = Instance.new("Folder")
				local element = createElement("Frame", {
					Frob = 6
				})
				local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
				local success, result = pcall(RobloxRenderer.mountHostNode, reconciler, virtualNode)
				assert(not success, "Expected call to fail")
				expect(result:find("Frob")).to.be.ok()
				expect(result:find("Frame")).to.be.ok()
				expect(result:find("RobloxRenderer%.spec")).to.be.ok()
			end)
		end)
	end)
	describe("updateHostNode", function()
		it("should update node props and children", function()
			local folder = Instance.new("Folder")
			local value = Instance.new("StringValue").Value
			local element = createElement("StringValue", {
				Value = "foo"
			}, {
				ChildA = createElement("IntValue", {
					Value = 1
				}),
				ChildB = createElement("BoolValue", {
					Value = true
				}),
				ChildC = createElement("StringValue", {
					Value = "test"
				}),
				ChildD = createElement("StringValue", {
					Value = "test"
				})
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "updateHostNodeTest")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			local element2 = createElement("StringValue", {
				Value = "bar"
			}, {
				ChildA = createElement("StringValue", {
					Value = "test"
				}),
				ChildB = createElement("BoolValue", {
					Value = false
				}),
				ChildC = createElement("StringValue", {}),
				ChildE = createElement("Folder", {})
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			local updateHostNodeTest = folder.updateHostNodeTest
			expect(updateHostNodeTest.ClassName).to.equal("StringValue")
			expect(updateHostNodeTest.Value).to.equal("bar")
			expect(#updateHostNodeTest:GetChildren()).to.equal(4)
			local childA = updateHostNodeTest.ChildA
			expect(childA.ClassName).to.equal("StringValue")
			expect(childA.Value).to.equal("test")
			local childB = updateHostNodeTest.ChildB
			expect(childB.ClassName).to.equal("BoolValue")
			expect(childB.Value).to.equal(false)
			local childC = updateHostNodeTest.ChildC
			expect(childC.ClassName).to.equal("StringValue")
			expect(childC.Value).to.equal(value)
			local childE = updateHostNodeTest.ChildE
			expect(childE.ClassName).to.equal("Folder")
		end)
		it("should update Bindings", function()
			local folder = Instance.new("Folder")
			local v, v2 = Binding.create(10)
			local element = createElement("IntValue", {
				Value = v
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			local v3 = folder:GetChildren()[1]
			expect(v3.Value).to.equal(10)
			local v4, v5 = Binding.create(99)
			local element2 = createElement("IntValue", {
				Value = v4
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			expect(v3.Value).to.equal(99)
			v2(123)
			expect(v3.Value).to.equal(99)
			v5(123)
			expect(v3.Value).to.equal(123)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should update Binding refs", function()
			local folder = Instance.new("Folder")
			local ref = createRef()
			local ref2 = createRef()
			local element = createElement("Frame", {
				[Ref] = ref
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(ref.current).to.equal(v)
			expect(ref2.current).never.to.be.ok()
			local element2 = createElement("Frame", {
				[Ref] = ref2
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			expect(ref.current).never.to.be.ok()
			expect(ref2.current).to.equal(v)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should call old function refs with nil and new function refs with a valid rbx", function()
			local folder = Instance.new("Folder")
			local spy = createSpy()
			local spy2 = createSpy()
			local element = createElement("Frame", {
				[Ref] = spy.value
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith(v)
			expect(spy2.callCount).to.equal(0)
			local element2 = createElement("Frame", {
				[Ref] = spy2.value
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWith(nil)
			expect(spy2.callCount).to.equal(1)
			spy2:assertCalledWith(v)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
		end)
		it("should not call function refs again if they didn't change", function()
			local folder = Instance.new("Folder")
			local spy = createSpy()
			local element = createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				[Ref] = spy.value
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith(v)
			local element2 = createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.5, 0),
				[Ref] = spy.value
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			expect(spy.callCount).to.equal(1)
		end)
		it("should throw if setting invalid instance properties", function()
			GlobalConfig.scoped({
				elementTracing = true
			}, function()
				local folder = Instance.new("Folder")
				local element = createElement("Frame")
				local element2 = createElement("Frame", {
					Frob = 6
				})
				local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
				RobloxRenderer.mountHostNode(reconciler, virtualNode)
				local success, result = pcall(RobloxRenderer.updateHostNode, reconciler, virtualNode, element2)
				assert(not success, "Expected call to fail")
				expect(result:find("Frob")).to.be.ok()
				expect(result:find("Frame")).to.be.ok()
				expect(result:find("RobloxRenderer%.spec")).to.be.ok()
			end)
		end)
		it("should delete instances when reconciling to nil children", function()
			local folder = Instance.new("Folder")
			local element = createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0)
			}, {
				child = createElement("Frame")
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(#folder:GetChildren()).to.equal(1)
			local v = folder:GetChildren()[1]
			expect(#v:GetChildren()).to.equal(1)
			local element2 = createElement("Frame", {
				Size = UDim2.new(0.5, 0, 0.5, 0)
			})
			RobloxRenderer.updateHostNode(reconciler, virtualNode, element2)
			expect(#v:GetChildren()).to.equal(0)
		end)
	end)
	describe("unmountHostNode", function()
		it("should delete instances from the inside-out", function()
			local folder = Instance.new("Folder")
			local element = createElement("Folder", nil, {
				Child = createElement("Folder", nil, {
					Grandchild = createElement("Folder")
				})
			})
			local v = reconciler.mountVirtualNode(element, folder, "Root")
			expect(#folder:GetChildren()).to.equal(1)
			local v2 = folder:GetChildren()[1]
			expect(#v2:GetChildren()).to.equal(1)
			local v3 = v2:GetChildren()[1]
			expect(#v3:GetChildren()).to.equal(1)
			local v4 = v3:GetChildren()[1]
			RobloxRenderer.unmountHostNode(reconciler, v)
			expect(v4.Parent).to.equal(nil)
			expect(v3.Parent).to.equal(nil)
			expect(v2.Parent).to.equal(nil)
		end)
		it("should unsubscribe from any Bindings", function()
			local folder = Instance.new("Folder")
			local v, v2 = Binding.create(10)
			local element = createElement("IntValue", {
				Value = v
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			local v3 = folder:GetChildren()[1]
			expect(v3.Value).to.equal(10)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
			v2(56)
			expect(v3.Value).to.equal(10)
		end)
		it("should clear Binding refs", function()
			local folder = Instance.new("Folder")
			local ref = createRef()
			local element = createElement("Frame", {
				[Ref] = ref
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(ref.current).to.be.ok()
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
			expect(ref.current).never.to.be.ok()
		end)
		it("should call function refs with nil", function()
			local folder = Instance.new("Folder")
			local spy = createSpy()
			local element = createElement("Frame", {
				[Ref] = spy.value
			})
			local virtualNode = reconciler.createVirtualNode(element, folder, "Some Key")
			RobloxRenderer.mountHostNode(reconciler, virtualNode)
			expect(spy.callCount).to.equal(1)
			RobloxRenderer.unmountHostNode(reconciler, virtualNode)
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWith(nil)
		end)
	end)
	describe("Portals", function()
		it("should create and destroy instances as children of `target`", function()
			local folder = Instance.new("Folder")

			local function FunctionComponent(p)
				return createElement("IntValue", {
					Value = p.value
				})
			end

			local element = createElement(Portal, {
				target = folder
			}, {
				folderOne = createElement("Folder"),
				folderTwo = createElement("Folder"),
				intValueOne = createElement(FunctionComponent, {
					value = 42
				})
			})
			local v = reconciler.mountVirtualNode(element, nil, "Some Key")
			expect(#folder:GetChildren()).to.equal(3)
			expect(folder:FindFirstChild("folderOne")).to.be.ok()
			expect(folder:FindFirstChild("folderTwo")).to.be.ok()
			expect(folder:FindFirstChild("intValueOne")).to.be.ok()
			expect(folder:FindFirstChild("intValueOne").Value).to.equal(42)
			reconciler.unmountVirtualNode(v)
			expect(#folder:GetChildren()).to.equal(0)
		end)
		it("should pass prop updates through to children", function()
			local folder = Instance.new("Folder")
			local element = createElement(Portal, {
				target = folder
			}, {
				ChildValue = createElement("IntValue", {
					Value = 1
				})
			})
			local element2 = createElement(Portal, {
				target = folder
			}, {
				ChildValue = createElement("IntValue", {
					Value = 2
				})
			})
			local v = reconciler.mountVirtualNode(element, nil, "A Host Key")
			expect(#folder:GetChildren()).to.equal(1)
			local childValue = folder.ChildValue
			expect(childValue.Value).to.equal(1)
			local v2 = reconciler.updateVirtualNode(v, element2)
			expect(#folder:GetChildren()).to.equal(1)
			local childValue2 = folder.ChildValue
			expect(childValue).to.equal(childValue2)
			expect(childValue2.Value).to.equal(2)
			reconciler.unmountVirtualNode(v2)
			expect(#folder:GetChildren()).to.equal(0)
		end)
		it("should throw if `target` is nil", function()
			local element = createElement(Portal)
			expect(function()
				reconciler.mountVirtualNode(element, nil, "Keys for Everyone")
			end).to.throw()
		end)
		it("should throw if `target` is not a Roblox instance", function()
			local element = createElement(Portal, {
				target = {}
			})
			expect(function()
				reconciler.mountVirtualNode(element, nil, "Unleash the keys!")
			end).to.throw()
		end)
		it("should recreate instances if `target` changes in an update", function()
			local folder = Instance.new("Folder")
			local folder2 = Instance.new("Folder")
			local element = createElement(Portal, {
				target = folder
			}, {
				ChildValue = createElement("IntValue", {
					Value = 1
				})
			})
			local element2 = createElement(Portal, {
				target = folder2
			}, {
				ChildValue = createElement("IntValue", {
					Value = 2
				})
			})
			local v = reconciler.mountVirtualNode(element, nil, "Some Key")
			expect(#folder:GetChildren()).to.equal(1)
			expect(#folder2:GetChildren()).to.equal(0)
			local childValue = folder.ChildValue
			expect(childValue.Value).to.equal(1)
			local v2 = reconciler.updateVirtualNode(v, element2)
			expect(#folder:GetChildren()).to.equal(0)
			expect(#folder2:GetChildren()).to.equal(1)
			local childValue2 = folder2.ChildValue
			expect(childValue2.Value).to.equal(2)
			reconciler.unmountVirtualNode(v2)
			expect(#folder:GetChildren()).to.equal(0)
			expect(#folder2:GetChildren()).to.equal(0)
		end)
	end)
	describe("Fragments", function()
		it("should parent the fragment's elements into the fragment's parent", function()
			local folder = Instance.new("Folder")
			local fragment = createFragment({
				key = createElement("IntValue", {
					Value = 1
				}),
				key2 = createElement("IntValue", {
					Value = 2
				})
			})
			local v = reconciler.mountVirtualNode(fragment, folder, "test")
			expect(folder:FindFirstChild("key")).to.be.ok()
			expect(folder.key.ClassName).to.equal("IntValue")
			expect(folder.key.Value).to.equal(1)
			expect(folder:FindFirstChild("key2")).to.be.ok()
			expect(folder.key2.ClassName).to.equal("IntValue")
			expect(folder.key2.Value).to.equal(2)
			reconciler.unmountVirtualNode(v)
			expect(#folder:GetChildren()).to.equal(0)
		end)
		it("should allow sibling fragment to have common keys", function()
			local folder = Instance.new("Folder")

			local function parent(_)
				return createElement("IntValue", {}, {
					fragmentA = createFragment({
						key = createElement("StringValue", {
							Value = "A"
						}),
						key2 = createElement("StringValue", {
							Value = "B"
						})
					}),
					fragmentB = createFragment({
						key = createElement("StringValue", {
							Value = "C"
						}),
						key2 = createElement("StringValue", {
							Value = "D"
						})
					})
				})
			end

			local v = reconciler.mountVirtualNode(createElement(parent), folder, "Test")
			local children = folder.Test:GetChildren()
			expect(#children).to.equal(4)
			local v2 = {}

			for _, v3 in pairs(children) do
				expect(v3.ClassName).to.equal("StringValue")
				v2[v3.Value] = 1 + (v2[v3.Value] or 0)
			end

			expect(v2.A).to.equal(1)
			expect(v2.B).to.equal(1)
			expect(v2.C).to.equal(1)
			expect(v2.D).to.equal(1)
			reconciler.unmountVirtualNode(v)
			expect(#folder:GetChildren()).to.equal(0)
		end)
		it("should render nested fragments", function()
			local folder = Instance.new("Folder")
			local fragment = createFragment({
				key = createFragment({
					TheValue = createElement("IntValue", {
						Value = 1
					}),
					TheOtherValue = createElement("IntValue", {
						Value = 2
					})
				})
			})
			local v = reconciler.mountVirtualNode(fragment, folder, "Test")
			expect(folder:FindFirstChild("TheValue")).to.be.ok()
			expect(folder.TheValue.ClassName).to.equal("IntValue")
			expect(folder.TheValue.Value).to.equal(1)
			expect(folder:FindFirstChild("TheOtherValue")).to.be.ok()
			expect(folder.TheOtherValue.ClassName).to.equal("IntValue")
			expect(folder.TheOtherValue.Value).to.equal(2)
			reconciler.unmountVirtualNode(v)
			expect(#folder:GetChildren()).to.equal(0)
		end)
		it("should not add any instances if the fragment is empty", function()
			local folder = Instance.new("Folder")
			local v = reconciler.mountVirtualNode(createFragment({}), folder, "test")
			expect(#folder:GetChildren()).to.equal(0)
			reconciler.unmountVirtualNode(v)
			expect(#folder:GetChildren()).to.equal(0)
		end)
	end)
	describe("Context", function()
		it("should pass context values through Roblox host nodes", function()
			local extended = Component:extend("Consumer")
			local v = nil

			function extended.init(object)
				v = {
					hello = object:__getContext("hello")
				}
			end

			function extended.render(_) end

			local element = createElement("Folder", nil, {
				Consumer = createElement(extended)
			})
			local v2 = {
				hello = "world"
			}
			local v3 = reconciler.mountVirtualNode(element, nil, "Context Test", v2)
			expect(v).never.to.equal(v2)
			assertDeepEqual(v, v2)
			reconciler.unmountVirtualNode(v3)
		end)
		it("should pass context values through portal nodes", function()
			local folder = Instance.new("Folder")
			local extended = Component:extend("Provider")

			function extended.init(object)
				object:__addContext("foo", "bar")
			end

			function extended.render(p)
				return createElement("Folder", nil, p.props[Children])
			end

			local extended2 = Component:extend("Consumer")
			local v = nil

			function extended2.init(object)
				v = {
					foo = object:__getContext("foo")
				}
			end

			function extended2.render(_)
				return nil
			end

			local element = createElement(extended, nil, {
				Portal = createElement(Portal, {
					target = folder
				}, {
					Consumer = createElement(extended2)
				})
			})
			reconciler.mountVirtualNode(element, nil, "Some Key")
			assertDeepEqual(v, {
				foo = "bar"
			})
		end)
	end)
	describe("Legacy context", function()
		it("should pass context values through Roblox host nodes", function()
			local extended = Component:extend("Consumer")
			local _context = nil

			function extended:init()
				_context = self._context
			end

			function extended.render(_) end

			local element = createElement("Folder", nil, {
				Consumer = createElement(extended)
			})
			local v = {
				hello = "world"
			}
			local v2 = reconciler.mountVirtualNode(element, nil, "Context Test", nil, v)
			expect(_context).never.to.equal(v)
			assertDeepEqual(_context, v)
			reconciler.unmountVirtualNode(v2)
		end)
		it("should pass context values through portal nodes", function()
			local folder = Instance.new("Folder")
			local extended = Component:extend("Provider")

			function extended:init()
				self._context.foo = "bar"
			end

			function extended.render(p)
				return createElement("Folder", nil, p.props[Children])
			end

			local extended2 = Component:extend("Consumer")
			local _context = nil

			function extended2:init()
				_context = self._context
			end

			function extended2.render(_)
				return nil
			end

			local element = createElement(extended, nil, {
				Portal = createElement(Portal, {
					target = folder
				}, {
					Consumer = createElement(extended2)
				})
			})
			reconciler.mountVirtualNode(element, nil, "Some Key")
			assertDeepEqual(_context, {
				foo = "bar"
			})
		end)
	end)
	describe("Integration Tests", function()
		local folder = nil
		beforeEach(function()
			folder = Instance.new("Folder")
			folder.Parent = ReplicatedStorage
		end)
		afterEach(function()
			folder:Destroy()
			folder = nil
		end)
		it("should not allow re-entrancy in updateChildren", function()
			local extended = Component:extend("ChildComponent")

			function extended.init(object)
				object:setState({
					firstTime = true
				})
			end

			local thread = nil

			function extended.render(p)
				if p.state.firstTime then
					return createElement("Frame")
				end

				return createElement("TextLabel")
			end

			function extended.didMount(object)
				thread = coroutine.create(function()
					object:setState({
						firstTime = false
					})
				end)
			end

			local extended2 = Component:extend("ParentComponent")

			function extended2:init()
				self:setState({
					count = 1
				})

				function self.childAdded()
					self:setState({
						count = self.state.count + 1
					})
				end
			end

			function extended2.render(p)
				return createElement("Frame", {
					[Event.ChildAdded] = p.childAdded
				}, {
					ChildComponent = createElement(extended, {
						count = p.state.count
					})
				})
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Parent = folder
			local element = createElement(extended2)
			local v = reconciler.mountVirtualNode(element, screenGui, "Some Key")
			coroutine.resume(thread)
			expect(#screenGui:GetChildren()).to.equal(1)
			local v2 = screenGui:GetChildren()[1]
			expect(#v2:GetChildren()).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
		it("should not allow re-entrancy in updateChildren even with callbacks", function()
			local extended = Component:extend("LowestComponent")

			function extended.render(_)
				return createElement("Frame")
			end

			function extended.didMount(p)
				p.props.onDidMountCallback()
			end

			local extended2 = Component:extend("ChildComponent")

			function extended2.init(object)
				object:setState({
					firstTime = true
				})
			end

			local thread = nil

			function extended2.render(p)
				if p.state.firstTime then
					return createElement("Frame")
				end

				return createElement(extended, {
					onDidMountCallback = p.props.onDidMountCallback
				})
			end

			function extended2.didMount(object)
				thread = coroutine.create(function()
					object:setState({
						firstTime = false
					})
				end)
			end

			local extended3 = Component:extend("ParentComponent")
			local count = 0

			function extended3:init()
				self:setState({
					count = 1
				})

				function self.onDidMountCallback()
					count += 1

					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1
						})
					end
				end
			end

			function extended3.render(p)
				return createElement("Frame", {}, {
					ChildComponent = createElement(extended2, {
						count = p.state.count,
						onDidMountCallback = p.onDidMountCallback
					})
				})
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Parent = folder
			local element = createElement(extended3)
			local v = reconciler.mountVirtualNode(element, screenGui, "Some Key")
			coroutine.resume(thread)
			expect(#screenGui:GetChildren()).to.equal(1)
			local v2 = screenGui:GetChildren()[1]
			expect(#v2:GetChildren()).to.equal(1)
			expect(count <= 2).to.equal(true)
			reconciler.unmountVirtualNode(v)
		end)
		it("should never call unmount twice in the case of update children re-rentrancy", function()
			local v = {}

			local function addUnmount(p)
				v[p] += 1
			end

			local function addInit(p)
				v[p] = 0
			end

			local extended = Component:extend("LowestComponent")

			function extended.init(p)
				local v2 = tostring(p)
				v[v2] = 0
			end

			function extended.render(_)
				return createElement("Frame")
			end

			function extended.didMount(p)
				p.props.onDidMountCallback()
			end

			function extended.willUnmount(p)
				local v2 = tostring(p)
				v[v2] += 1
			end

			local extended2 = Component:extend("FirstComponent")

			function extended2.init(p)
				local v2 = tostring(p)
				v[v2] = 0
			end

			function extended2.render(_)
				return createElement("TextLabel")
			end

			function extended2.willUnmount(p)
				local v2 = tostring(p)
				v[v2] += 1
			end

			local extended3 = Component:extend("ChildComponent")

			function extended3.init(object)
				local v2 = tostring(object)
				v[v2] = 0
				object:setState({
					firstTime = true
				})
			end

			local thread = nil

			function extended3.render(p)
				if p.state.firstTime then
					return createElement(extended2)
				end

				return createElement(extended, {
					onDidMountCallback = p.props.onDidMountCallback
				})
			end

			function extended3.didMount(object)
				thread = coroutine.create(function()
					object:setState({
						firstTime = false
					})
				end)
			end

			function extended3.willUnmount(p)
				local v2 = tostring(p)
				v[v2] += 1
			end

			local extended4 = Component:extend("ParentComponent")
			local count = 0

			function extended4:init()
				self:setState({
					count = 1
				})

				function self.onDidMountCallback()
					count += 1

					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1
						})
					end
				end
			end

			function extended4.render(p)
				return createElement("Frame", {}, {
					ChildComponent = createElement(extended3, {
						count = p.state.count,
						onDidMountCallback = p.onDidMountCallback
					})
				})
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Parent = folder
			local element = createElement(extended4)
			local v2 = reconciler.mountVirtualNode(element, screenGui, "Some Key")
			coroutine.resume(thread)
			expect(#screenGui:GetChildren()).to.equal(1)
			local v3 = screenGui:GetChildren()[1]
			expect(#v3:GetChildren()).to.equal(1)
			expect(count <= 2).to.equal(true)
			reconciler.unmountVirtualNode(v2)

			for _, v4 in pairs(v) do
				expect(v4).to.equal(1)
			end
		end)
		it("should never unmount a node unnecesarily in the case of re-rentry", function()
			local extended = Component:extend("LowestComponent")

			function extended.render(_)
				return createElement("Frame")
			end

			function extended.didUpdate(p, p2, _)
				if p2.firstTime and not p.props.firstTime then
					p.props.onChangedCallback()
				end
			end

			local extended2 = Component:extend("ChildComponent")

			function extended2.init(object)
				object:setState({
					firstTime = true
				})
			end

			local thread = nil

			function extended2.render(p)
				return createElement(extended, {
					firstTime = p.state.firstTime,
					onChangedCallback = p.props.onChangedCallback
				})
			end

			function extended2.didMount(object)
				thread = coroutine.create(function()
					object:setState({
						firstTime = false
					})
				end)
			end

			local extended3 = Component:extend("ParentComponent")
			local count = 0

			function extended3:init()
				self:setState({
					count = 1
				})

				function self.onChangedCallback()
					count += 1

					if self.state.count < 5 then
						self:setState({
							count = self.state.count + 1
						})
					end
				end
			end

			function extended3.render(p)
				return createElement("Frame", {}, {
					ChildComponent = createElement(extended2, {
						count = p.state.count,
						onChangedCallback = p.onChangedCallback
					})
				})
			end

			local screenGui = Instance.new("ScreenGui")
			screenGui.Parent = folder
			local element = createElement(extended3)
			local v = reconciler.mountVirtualNode(element, screenGui, "Some Key")
			coroutine.resume(thread)
			expect(#screenGui:GetChildren()).to.equal(1)
			local v2 = screenGui:GetChildren()[1]
			expect(#v2:GetChildren()).to.equal(1)
			expect(count).to.equal(1)
			reconciler.unmountVirtualNode(v)
		end)
	end)
end