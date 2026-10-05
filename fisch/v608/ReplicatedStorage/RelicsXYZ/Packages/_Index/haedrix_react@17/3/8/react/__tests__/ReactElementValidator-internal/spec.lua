local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
local v = nil
local v2 = nil
local reactFeatureFlags = nil
local _ = {
	renderIntoDocument = function(p)
		local folder = Instance.new("Folder")
		local legacyRoot = v2.createLegacyRoot(folder)
		legacyRoot:render(p)
		return legacyRoot
	end
}
describe("ReactElementValidator", function()
	local v3 = nil
	beforeEach(function()
		jest.resetModules()
		local Shared = require(parent.Shared)
		reactFeatureFlags = Shared.ReactFeatureFlags
		reactFeatureFlags.replayFailedUnitOfWorkWithInvokeGuardedCallback = false
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactRoblox = require(parent.Dev.ReactRoblox)
		v2 = ReactRoblox
		v3 = v.Component:extend("ComponentClass")

		function v3:render()
			return v.createElement("Frame")
		end
	end)
	it("warns for keys for arrays of elements in rest args", function()
		expect(function()
			v.createElement(v3, nil, { v.createElement(v3), v.createElement(v3) })
		end).toErrorDev("Each child in a list should have a unique \"key\" prop.")
	end)
	it("warns for keys for arrays of elements with owner info", function()
		local extended = v.Component:extend("InnerClass")

		function extended:render()
			return v.createElement(v3, nil, self.props.childSet)
		end

		local extended2 = v.Component:extend("ComponentWrapper")

		function extended2:render()
			return v.createElement(extended, {
				childSet = { v.createElement(v3), v.createElement(v3) }
			})
		end

		expect(function()
			local element = v.createElement(extended2)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Each child in a list should have a unique "key" prop.

Check the render method of `InnerClass`. It was passed a child from ComponentWrapper. ]])
	end)
	it("warns for keys for arrays with no owner or parent info", function()
		local v4 = { v.createElement("Frame"), v.createElement("Frame") }
		expect(function()
			local element = v.createElement(function()
				return v.createElement("Frame")
			end, nil, v4)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Warning: Each child in a list should have a unique "key" prop. See https://reactjs.org/link/warning-keys for more information.
    in Frame (at **)]])
	end)
	it("warns for keys for arrays of elements with no owner info", function()
		local v4 = { v.createElement("Frame"), v.createElement("Frame") }
		expect(function()
			local element = v.createElement("Frame", nil, v4)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Warning: Each child in a list should have a unique "key" prop.

Check the top-level render call using <Frame>. See https://reactjs.org/link/warning-keys for more information.
    in Frame (at **)]])
	end)
	it("warns for keys with component stack info", function()
		local function Component()
			return v.createElement("Frame", nil, { v.createElement("Frame"), v.createElement("Frame") })
		end

		local function Parent(p)
			return v.cloneElement(p.child)
		end

		local function GrandParent()
			return v.createElement(Parent, {
				child = v.createElement(Component)
			})
		end

		expect(function()
			local element = v.createElement(GrandParent)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Warning: Each child in a list should have a unique "key" prop.

Check the render method of `Component`. See https://reactjs.org/link/warning-keys for more information.
    in Frame (at **)
    in Component (at **)
    in Parent (at **)
    in GrandParent (at **)]])
	end)
	it("does not warn for keys when passing children down", function()
		local function Wrapper(p)
			return v.createElement("Frame", nil, p.children, v.createElement("Frame"))
		end

		expect(function()
			local element = v.createElement(Wrapper, nil, v.createElement("Frame"), v.createElement("Frame"))
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev({})
	end)
	it("does not warn for keys when providing keys via children tables", function()
		expect(function()
			local element = v.createElement("Frame", nil, {
				ChildA = v.createElement("Frame"),
				ChildB = v.createElement("Frame")
			})
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev({})
	end)
	xit("warns for keys for iterables of elements in rest args", function()
		local v4 = {
			["@@iterator"] = function()
				local count = 0
				return {
					next = function()
						count += 1
						local done = count > 2
						local v6

						if not done then
							v6 = v.createElement(v3)
						end

						return {
							value = v6,
							done = done
						}
					end
				}
			end
		}
		expect(function()
			return v.createElement(v3, nil, v4)
		end).toErrorDev("Each child in a list should have a unique \"key\" prop.")
	end)
	it("does not warns for arrays of elements with keys", function()
		v.createElement(v3, nil, { v.createElement(v3, {
				key = "#1"
			}), v.createElement(v3, {
				key = "#2"
			}) })
	end)
	xit("does not warns for iterable elements with keys", function()
		local v4 = {
			["@@iterator"] = function()
				local count = 0
				return {
					next = function()
						count += 1
						local done = count > 2
						local v7

						if not done then
							v7 = v.createElement(v3, {
								key = "#" .. count
							}) or nil
						end

						return {
							value = v7,
							done = done
						}
					end
				}
			end
		}
		v.createElement(v3, nil, v4)
	end)
	it("does not warn when the element is directly in rest args", function()
		v.createElement(v3, nil, v.createElement(v3), v.createElement(v3))
	end)
	it("does not warn when the array contains a non-element", function()
		v.createElement(v3, nil, {
			{},
			{}
		})
	end)
	xit("should give context for PropType errors in nested components.", function()
		local extended = v.Component:extend("MyComp")

		function extended:render()
			return v.createElement("Frame", nil, "My color is " .. self.props.color)
		end

		extended.propTypes = {
			color = (nil).string
		}

		local function ParentComp()
			return v.createElement(extended, {
				color = 123
			})
		end

		expect(function()
			local element = v.createElement(ParentComp)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Warning: Failed prop type: Invalid prop `color` of type `number` supplied to `MyComp`, expected `string`.
    in MyComp (at **)
    in ParentComp (at **)]])
	end)
	it("gives a helpful error when passing invalid types", function()
		local function Foo() end

		expect(function()
			v.createElement(nil)
			v.createElement(true)
			v.createElement({
				x = 17
			})
			v.createElement({})
			v.createElement(v.createElement("Frame"))
			v.createElement(v.createElement(Foo))
			v.createElement(v.createElement(v.createContext().Consumer))
			v.createElement({
				["$$typeof"] = "non-react-thing"
			})
		end).toErrorDev({
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: nil.",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: boolean.",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: table.",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: array. You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: <Frame />. Did you accidentally export a JSX literal or Element instead of a component?",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: <Foo />. Did you accidentally export a JSX literal or Element instead of a component?",
			"Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: <Context.Consumer />. Did you accidentally export a JSX literal or Element instead of a component?",
			[[
Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: table.
{]]
		}, {
			withoutStack = true
		})
		v.createElement("Frame")
	end)
	it("includes the owner name when passing null, undefined, boolean, or number", function()
		local function ParentComp()
			return v.createElement(1)
		end

		expect(function()
			expect(function()
				local element = v.createElement(ParentComp)
				local folder = Instance.new("Folder")
				v2.createLegacyRoot(folder):render(element)
			end).toThrowError("Element type is invalid: expected a string (for built-in components) " .. "or a class/function (for composite components) but got: number." .. (ReactGlobals.__DEV__ and [[


Check the render method of `ParentComp`.]] or ""))
		end).toErrorDev("Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: number.")
	end)
	it("includes the owner name of a PureComponent", function()
		local extended = v.PureComponent:extend("ParentPureComp")

		function extended:render()
			return v.createElement(1)
		end

		expect(function()
			expect(function()
				local element = v.createElement(extended)
				local folder = Instance.new("Folder")
				v2.createLegacyRoot(folder):render(element)
			end).toThrowError("Element type is invalid: expected a string (for built-in components) " .. "or a class/function (for composite components) but got: number." .. (ReactGlobals.__DEV__ and [[


Check the render method of `ParentPureComp`.]] or ""))
		end).toErrorDev("Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: number.")
	end)
	it.skip("should check default prop values", function()
		local extended = v.Component:extend("Component")

		function extended:render()
			return v.createElement("Frame", nil, self.props.prop)
		end

		extended.propTypes = {
			prop = (nil).string.isRequired
		}
		extended.defaultProps = {
			prop = nil
		}
		expect(function()
			local element = v.createElement(extended)
			local folder = Instance.new("Folder")
			local legacyRoot = v2.createLegacyRoot(folder)
			legacyRoot:render(element)
			return legacyRoot
		end).toErrorDev([[
Warning: Failed prop type: The prop `prop` is marked as required in `Component`, but its value is `null`.
    in Component]])
	end)
	it.skip("should not check the default for explicit null", function()
		local extended = v.Component:extend("Component")

		function extended:render()
			return v.createElement("Frame", nil, self.props.prop)
		end

		extended.propTypes = {
			prop = (nil).string.isRequired
		}
		extended.defaultProps = {
			prop = "text"
		}
		expect(function()
			local element = v.createElement(extended, {
				prop = nil
			})
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Warning: Failed prop type: The prop `prop` is marked as required in `Component`, but its value is `null`.
    in Component]])
	end)
	it.skip("should check declared prop types", function()
		local extended = v.Component:extend("Component")

		function extended:render()
			return v.createElement("Frame", nil, self.props.prop)
		end

		extended.propTypes = {
			prop = (nil).string.isRequired
		}
		expect(function()
			local element = v.createElement(extended)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
			local element2 = v.createElement(extended, {
				prop = 42
			})
			local folder2 = Instance.new("Folder")
			v2.createLegacyRoot(folder2):render(element2)
		end).toErrorDev({ [[
Warning: Failed prop type: The prop `prop` is marked as required in `Component`, but its value is `undefined`.
    in Component]], [[
Warning: Failed prop type: Invalid prop `prop` of type `number` supplied to `Component`, expected `string`.
    in Component]] })
		local element = v.createElement(extended, {
			prop = "string"
		})
		local folder = Instance.new("Folder")
		v2.createLegacyRoot(folder):render(element)
	end)
	it.skip("should warn if a PropType creator is used as a PropType", function()
		local extended = v.Component:extend("Component")

		function extended:render()
			return v.createElement("Frame", nil, self.props.myProp.value)
		end

		extended.propTypes = {
			myProp = (nil).shape
		}
		expect(function()
			local element = v.createElement(extended, {
				myProp = {
					value = "hi"
				}
			})
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev("Warning: Component: type specification of prop `myProp` is invalid; the type checker function must return `null` or an `Error` but returned a function. You may have forgotten to pass an argument to the type checker creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and shape all require an argument).")
	end)
	it.skip("should warn if component declares PropTypes instead of propTypes", function()
		local extended = v.Component:extend("MisspelledPropTypesComponent")

		function extended:render()
			return v.createElement("Frame", nil, self.props.prop)
		end

		extended.PropTypes = {
			prop = (nil).string
		}
		expect(function()
			local element = v.createElement(extended, {
				prop = "Hi"
			})
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev("Warning: Component MisspelledPropTypesComponent declared `PropTypes` instead of `propTypes`. Did you misspell the property assignment?", {
			withoutStack = true
		})
	end)
	it("warns for fragments with illegal attributes", function()
		local extended = v.Component:extend("Foo")

		function extended:render()
			return v.createElement(v.Fragment, {
				a = 1
			}, v.createElement("Frame"))
		end

		expect(function()
			local element = v.createElement(extended)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev("Invalid prop `a` supplied to `React.Fragment`. React.Fragment can only have `key` and `children` props.")
	end)

	if not ReactGlobals.__EXPERIMENTAL__ then
		it.skip("should warn when accessing .type on an element factory", function()
			local function TestComponent()
				return v.createElement("Frame")
			end

			local v4 = nil
			expect(function()
				v4 = v.createFactory(TestComponent)
			end).toWarnDev("Warning: React.createFactory() is deprecated and will be removed in a future major release. Consider using JSX or use React.createElement() directly instead.", {
				withoutStack = true
			})
			expect(function()
				return v4.type
			end).toWarnDev("Warning: Factory.type is deprecated. Access the class directly before passing it to createFactory.", {
				withoutStack = true
			})
			expect(v4.type).toBe(TestComponent)
		end)
	end

	it.skip("does not warn when using DOM node as children", function() end)
	it.skip("should not enumerate enumerable numbers (#4776)", function() end)
	it("does not blow up with inlined children", function()
		local v4 = {
			{
				["$$typeof"] = v.createElement("Frame")["$$typeof"],
				type = "Frame",
				key = nil,
				ref = nil,
				props = {},
				_owner = nil
			}
		}
		v.createElement("Frame", nil, v4)
	end)
	it("does not blow up on key warning with undefined type", function()
		expect(function()
			v.createElement(nil, {
				__source = {
					fileName = "fileName.lua",
					lineNumber = 100
				}
			}, { v.createElement("Frame") })
		end).toErrorDev([[
Warning: React.createElement: type is invalid -- expected a string (for built-in components) or a class/function (for composite components) but got: nil. You likely forgot to export your component from the file it's defined in, or you might have mixed up default and named imports.

Check your code at **.]], {
			withoutStack = true
		})
	end)
	it("does not call lazy initializers eagerly", function()
		local v4 = false
		local lazy = v.lazy(function()
			v4 = true
			return {
				andThen = function() end
			}
		end)
		v.createElement(lazy)
		expect(v4).toBe(false)
	end)
	it("warns when keys are provided via both the 'key' prop AND table keys", function()
		local extended = v.Component:extend("Component")

		function extended:render()
			return v.createElement("Frame", nil, {
				a1 = v.createElement("Frame", {
					key = "a2"
				}),
				b = v.createElement("Frame", {
					key = "b"
				})
			})
		end

		expect(function()
			local element = v.createElement(extended)
			local folder = Instance.new("Folder")
			v2.createLegacyRoot(folder):render(element)
		end).toErrorDev([[
Child element received a "key" prop ("a2") in addition to a key in the "children" table of its parent ("a1"). Please provide only one key definition. When both are present, the "key" prop will take precedence.

Check the render method of `Component`. See https://reactjs.org/link/warning-keys for more information.
    in Frame (at **)
    in Component (at **)]])
	end)
end)