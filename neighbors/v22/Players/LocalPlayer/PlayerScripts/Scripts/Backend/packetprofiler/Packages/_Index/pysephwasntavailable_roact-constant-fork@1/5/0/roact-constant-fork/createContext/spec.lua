return function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Component = require(script.Parent.Component)
	local NoopRenderer = require(script.Parent.NoopRenderer)
	local Children = require(script.Parent.PropMarkers.Children)
	local createContext = require(script.Parent.createContext)
	local createElement = require(script.Parent.createElement)
	local createFragment = require(script.Parent.createFragment)
	local createReconciler = require(script.Parent.createReconciler)
	local createSpy = require(script.Parent.createSpy)
	local reconciler = createReconciler(NoopRenderer)
	local RobloxRenderer = require(script.Parent.RobloxRenderer)
	local reconciler2 = createReconciler(RobloxRenderer)
	it("should return a table", function()
		local context = createContext("Test")
		expect(context).to.be.ok()
		expect((type(context))).to.equal("table")
	end)
	it("should contain a Provider and a Consumer", function()
		local context = createContext("Test")
		expect(context.Provider).to.be.ok()
		expect(context.Consumer).to.be.ok()
	end)
	describe("Provider", function()
		it("should render its children", function()
			local context = createContext("Test")
			local spy = createSpy(function()
				return nil
			end)
			local element = createElement(context.Provider, {
				value = "Test"
			}, {
				Listener = createElement(spy.value)
			})
			local v = reconciler.mountVirtualTree(element, nil, "Provide Tree")
			reconciler.unmountVirtualTree(v)
			expect(spy.callCount).to.equal(1)
		end)
	end)
	describe("Consumer", function()
		it("should expect a render function", function()
			local element = createElement(createContext("Test").Consumer)
			expect(function()
				reconciler.mountVirtualTree(element, nil, "Provide Tree")
			end).to.throw()
		end)
		it("should return the default value if there is no Provider", function()
			local spy = createSpy()
			local element = createElement(createContext("Test").Consumer, {
				render = spy.value
			})
			local v = reconciler.mountVirtualTree(element, nil, "Provide Tree")
			reconciler.unmountVirtualTree(v)
			spy:assertCalledWith("Test")
		end)
		it("should pass the value to the render function", function()
			local spy = createSpy()
			local context = createContext("Test")

			local function Listener()
				return createElement(context.Consumer, {
					render = spy.value
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest"
			}, {
				Listener = createElement(Listener)
			})
			local v = reconciler.mountVirtualTree(element, nil, "Provide Tree")
			reconciler.unmountVirtualTree(v)
			spy:assertCalledWith("NewTest")
		end)
		it("should update when the value updates", function()
			local spy = createSpy()
			local context = createContext("Test")

			local function Listener()
				return createElement(context.Consumer, {
					render = spy.value
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest"
			}, {
				Listener = createElement(Listener)
			})
			local v = reconciler.mountVirtualTree(element, nil, "Provide Tree")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith("NewTest")
			reconciler.updateVirtualTree(v, createElement(context.Provider, {
				value = "ThirdTest"
			}, {
				Listener = createElement(Listener)
			}))
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWith("ThirdTest")
			reconciler.unmountVirtualTree(v)
		end)
		it("should update when the value updates through an update blocking component", function()
			local spy = createSpy()
			local context = createContext("Test")
			local extended = Component:extend("UpdateBlocker")

			function extended.render(p)
				return createFragment(p.props[Children])
			end

			function extended.shouldUpdate(_)
				return false
			end

			local function Listener()
				return createElement(context.Consumer, {
					render = spy.value
				})
			end

			local element = createElement(context.Provider, {
				value = "NewTest"
			}, {
				Blocker = createElement(extended, nil, {
					Listener = createElement(Listener)
				})
			})
			local v = reconciler.mountVirtualTree(element, nil, "Provide Tree")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith("NewTest")
			reconciler.updateVirtualTree(v, createElement(context.Provider, {
				value = "ThirdTest"
			}, {
				Blocker = createElement(extended, nil, {
					Listener = createElement(Listener)
				})
			}))
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWith("ThirdTest")
			reconciler.unmountVirtualTree(v)
		end)
		it("should behave correctly when the default value is nil", function()
			local context = createContext(nil)
			local spy = createSpy()

			local function Listener()
				return createElement(context.Consumer, {
					render = spy.value
				})
			end

			local v = reconciler.mountVirtualTree(createElement(Listener), nil, "Provide Tree")
			expect(spy.callCount).to.equal(1)
			spy:assertCalledWith(nil)
			local v2 = reconciler.updateVirtualTree(v, createElement(Listener))
			reconciler.unmountVirtualTree(v2)
			expect(spy.callCount).to.equal(2)
			spy:assertCalledWith(nil)
		end)
	end)
	describe("Update order", function()
		it("should update context at the same time as props", function()
			local v = false
			local v2 = false
			local count = 0
			local context = createContext("default")

			local function Listener(p)
				return createElement(context.Consumer, {
					render = function(p2)
						count += 1

						if p2 == "context_1" then
							expect(p.someProp).to.equal("prop_1")
							v = true
						else
							if p2 ~= "context_2" then
								error("Unexpected context value")
								return
							end

							expect(p.someProp).to.equal("prop_2")
							v2 = true
						end
					end
				})
			end

			local element = createElement(context.Provider, {
				value = "context_1"
			}, {
				Child = createElement(Listener, {
					someProp = "prop_1"
				})
			})
			local element2 = createElement(context.Provider, {
				value = "context_2"
			}, {
				Child = createElement(Listener, {
					someProp = "prop_2"
				})
			})
			local v3 = reconciler.mountVirtualTree(element, nil, "UpdateObservationIsFun")
			reconciler.updateVirtualTree(v3, element2)
			expect(count).to.equal(2)
			expect(v).to.equal(true)
			expect(v2).to.equal(true)
		end)
	end)
	it("does not throw if willUnmount is called twice on a context consumer", function()
		local context = createContext({})
		local extended = Component:extend("LowestComponent")

		function extended.init(_) end

		function extended.render(_)
			return createElement("Frame")
		end

		function extended.didMount(p)
			p.props.onDidMountCallback()
		end

		local extended2 = Component:extend("FirstComponent")

		function extended2.init(_) end

		function extended2.render(_)
			return createElement(context.Consumer, {
				render = function()
					return createElement("TextLabel")
				end
			})
		end

		local extended3 = Component:extend("ChildComponent")

		function extended3.init(object)
			object:setState({
				firstTime = true
			})
		end

		local fn

		function extended3.render(p)
			if p.state.firstTime then
				return createElement(extended2)
			end

			return createElement(extended, {
				onDidMountCallback = p.props.onDidMountCallback
			})
		end

		function extended3.didMount(object)
			fn = function()
				object:setState({
					firstTime = false
				})
			end
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
				Provider = createElement(context.Provider, {
					value = {}
				}, {
					ChildComponent = createElement(extended3, {
						count = p.state.count,
						onDidMountCallback = p.onDidMountCallback
					})
				})
			})
		end

		local screenGui = Instance.new("ScreenGui")
		screenGui.Parent = ReplicatedStorage
		reconciler2.mountVirtualNode(createElement(extended4), screenGui, "Some Key")
		expect(function()
			fn()
		end).never.to.throw()
	end)
end