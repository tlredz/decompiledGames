return function()
	local assign = require(script.Parent.assign)
	local createElement = require(script.Parent.createElement)
	local createRef = require(script.Parent.createRef)
	local forwardRef = require(script.Parent.forwardRef)
	local createReconciler = require(script.Parent.createReconciler)
	local Component = require(script.Parent.Component)
	local GlobalConfig = require(script.Parent.GlobalConfig)
	local Ref = require(script.Parent.PropMarkers.Ref)
	local RobloxRenderer = require(script.Parent.RobloxRenderer)
	local reconciler = createReconciler(RobloxRenderer)
	it("should update refs when switching between children", function()
		local function FunctionComponent(p)
			local forwardedRef = p.forwardedRef
			local v

			if not p.setRefOnDiv then
				v = forwardedRef
				forwardedRef = nil
			end

			return createElement("Frame", nil, {
				First = createElement("Frame", {
					[Ref] = forwardedRef
				}, {
					Child = createElement("TextLabel", {
						Text = "First"
					})
				}),
				Second = createElement("ScrollingFrame", {
					[Ref] = v
				}, {
					Child = createElement("TextLabel", {
						Text = "Second"
					})
				})
			})
		end

		local v = forwardRef(function(p, forwardedRef)
			return createElement(FunctionComponent, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = createRef()
		local element = createElement(v, {
			[Ref] = ref,
			setRefOnDiv = true
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "switch refs")
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(v2)
		local element2 = createElement(v, {
			[Ref] = ref,
			setRefOnDiv = false
		})
		local v3 = reconciler.mountVirtualTree(element2, nil, "switch refs")
		expect(ref.current.ClassName).to.equal("ScrollingFrame")
		reconciler.unmountVirtualTree(v3)
	end)
	it("should support rendering nil", function()
		local v = forwardRef(function(_, _)
			return nil
		end)
		local ref = createRef()
		local element = createElement(v, {
			[Ref] = ref
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "nil ref")
		expect(ref.current).to.equal(nil)
		reconciler.unmountVirtualTree(v2)
	end)
	it("should support rendering nil for multiple children", function()
		local v = forwardRef(function(_, _)
			return nil
		end)
		local ref = createRef()
		local element = createElement("Frame", nil, {
			NoRef1 = createElement("Frame"),
			WithRef = createElement(v, {
				[Ref] = ref
			}),
			NoRef2 = createElement("Frame")
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "multiple children nil ref")
		expect(ref.current).to.equal(nil)
		reconciler.unmountVirtualTree(v2)
	end)
	itSKIP("should support defaultProps", function()
		local function FunctionComponent(data)
			local forwardedRef = data.forwardedRef
			local optional = data.optional
			local required = data.required
			return createElement("Frame", {
				[Ref] = forwardedRef
			}, {
				OptionalChild = optional,
				RequiredChild = required
			})
		end

		local v = forwardRef(function(p, forwardedRef)
			return createElement(FunctionComponent, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		v.defaultProps = {
			optional = createElement("TextLabel")
		}
		local ref = createRef()
		local element = createElement(v, {
			[Ref] = ref,
			optional = createElement("Frame"),
			required = createElement("ScrollingFrame")
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "with optional")
		expect(ref.current:FindFirstChild("OptionalChild").ClassName).to.equal("Frame")
		expect(ref.current:FindFirstChild("RequiredChild").ClassName).to.equal("ScrollingFrame")
		reconciler.unmountVirtualTree(v2)
		local element2 = createElement(v, {
			[Ref] = ref,
			required = createElement("ScrollingFrame")
		})
		local v3 = reconciler.mountVirtualTree(element2, nil, "with default")
		expect(ref.current:FindFirstChild("OptionalChild").ClassName).to.equal("TextLabel")
		expect(ref.current:FindFirstChild("RequiredChild").ClassName).to.equal("ScrollingFrame")
		reconciler.unmountVirtualTree(v3)
	end)
	it("should error if not provided a callback when type checking is enabled", function()
		GlobalConfig.scoped({
			typeChecks = true
		}, function()
			expect(function()
				forwardRef(nil)
			end).to.throw()
		end)
		GlobalConfig.scoped({
			typeChecks = true
		}, function()
			expect(function()
				forwardRef("foo")
			end).to.throw()
		end)
	end)
	it("should work without a ref to be forwarded", function()
		local function Child()
			return nil
		end

		local function Wrapper(p)
			return createElement(Child, assign({}, p, {
				[Ref] = p.forwardedRef
			}))
		end

		local element = createElement(forwardRef(function(p, forwardedRef)
			return createElement(Wrapper, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end), {
			value = 123
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "nil ref")
		reconciler.unmountVirtualTree(v2)
	end)
	it("should forward a ref for a single child", function()
		local value = nil

		local function Child(p)
			value = p.value
			return createElement("Frame", {
				[Ref] = p[Ref]
			})
		end

		local function Wrapper(p)
			return createElement(Child, assign({}, p, {
				[Ref] = p.forwardedRef
			}))
		end

		local v = forwardRef(function(p, forwardedRef)
			return createElement(Wrapper, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = createRef()
		local element = createElement(v, {
			[Ref] = ref,
			value = 123
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "single child ref")
		expect(value).to.equal(123)
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(v2)
	end)
	it("should forward a ref for multiple children", function()
		local function Child(p)
			return createElement("Frame", {
				[Ref] = p[Ref]
			})
		end

		local function Wrapper(p)
			return createElement(Child, assign({}, p, {
				[Ref] = p.forwardedRef
			}))
		end

		local v = forwardRef(function(p, forwardedRef)
			return createElement(Wrapper, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = createRef()
		local element = createElement("Frame", nil, {
			NoRef1 = createElement("Frame"),
			WithRef = createElement(v, {
				[Ref] = ref
			}),
			NoRef2 = createElement("Frame")
		})
		local v2 = reconciler.mountVirtualTree(element, nil, "multi child ref")
		expect(ref.current.ClassName).to.equal("Frame")
		reconciler.unmountVirtualTree(v2)
	end)
	it("should maintain child instance and ref through updates", function()
		local value = nil

		local function Child(p)
			value = p.value
			return createElement("Frame", {
				[Ref] = p[Ref]
			})
		end

		local function Wrapper(p)
			return createElement(Child, assign({}, p, {
				[Ref] = p.forwardedRef
			}))
		end

		local v = forwardRef(function(p, forwardedRef)
			return createElement(Wrapper, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local count = 0
		local v2 = nil

		local function fn(p)
			count += 1
			v2 = p
		end

		local element = createElement(v, {
			[Ref] = fn,
			value = 123
		})
		local v3 = reconciler.mountVirtualTree(element, nil, "maintains instance")
		expect(value).to.equal(123)
		expect(v2.ClassName).to.equal("Frame")
		expect(count).to.equal(1)
		local element2 = createElement(v, {
			[Ref] = fn,
			value = 456
		})
		local v4 = reconciler.updateVirtualTree(v3, element2)
		expect(value).to.equal(456)
		expect(count).to.equal(1)
		reconciler.unmountVirtualTree(v4)
	end)
	it("should not re-run the render callback on a deep setState", function()
		local v = nil
		local v2 = {}
		local extended = Component:extend("Inner")

		function extended.render(p)
			table.insert(v2, "Inner")
			v = p
			return createElement("Frame", {
				[Ref] = p.props.forwardedRef
			})
		end

		local function Middle(p)
			table.insert(v2, "Middle")
			return createElement(extended, p)
		end

		local v3 = forwardRef(function(p, forwardedRef)
			table.insert(v2, "Forward")
			return createElement(Middle, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)

		local function App()
			table.insert(v2, "App")
			return createElement(v3)
		end

		local v4 = reconciler.mountVirtualTree(createElement(App), nil, "deep setState")
		expect(#v2).to.equal(4)
		expect(v2[1]).to.equal("App")
		expect(v2[2]).to.equal("Forward")
		expect(v2[3]).to.equal("Middle")
		expect(v2[4]).to.equal("Inner")
		v2 = {}
		v:setState({})
		expect(#v2).to.equal(1)
		expect(v2[1]).to.equal("Inner")
		reconciler.unmountVirtualTree(v4)
	end)
	it("should not include the ref in the forwarded props", function()
		local v = nil

		local function CaptureProps(p)
			v = p
			return createElement("Frame", {
				[Ref] = p.forwardedRef
			})
		end

		local v2 = forwardRef(function(p, forwardedRef)
			return createElement(CaptureProps, assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = createRef()
		local element = createElement(v2, {
			[Ref] = ref
		})
		local v3 = reconciler.mountVirtualTree(element, nil, "no ref in props")
		expect(v).to.be.ok()
		expect(v.forwardedRef).to.equal(ref)
		expect(v[Ref]).to.equal(nil)
		reconciler.unmountVirtualTree(v3)
	end)
end