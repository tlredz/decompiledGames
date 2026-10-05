local parent = script.Parent.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local describe = JestGlobals.describe
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local folder = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	folder = Instance.new("Folder")
	v3 = v2.createRoot(folder)
	local Scheduler = require(parent.Scheduler)
	v4 = Scheduler
end)
describe("mounting instances", function()
	it("should create instances with correct props", function()
		local element = v.createElement("StringValue", {
			Name = "Some Key",
			Value = "Hello!"
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder:GetChildren()).toBe(1)
		local v5 = folder:GetChildren()[1]
		expect(v5.ClassName).toBe("StringValue")
		expect(v5.Value).toBe("Hello!")
		expect(v5.Name).toBe("Some Key")
	end)
	it("names instances with their key value using legacy key syntax", function()
		local element = v.createElement("Folder", {}, {
			["Some Key"] = v.createElement("BoolValue")
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder:GetChildren()).toBe(1)
		local v5 = folder:GetChildren()[1]
		expect(v5.ClassName).toBe("Folder")
		local boolValue = v5:FindFirstChildOfClass("BoolValue")
		expect(boolValue).toBeDefined()
		expect(boolValue.Name).toEqual("Some Key")
	end)
	it("names instances with their key value (using props)", function()
		local element = v.createElement("Folder", {}, v.createElement("BoolValue", {
			key = "Some Key"
		}))
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder:GetChildren()).toBe(1)
		local v5 = folder:GetChildren()[1]
		expect(v5.ClassName).toBe("Folder")
		local boolValue = v5:FindFirstChildOfClass("BoolValue")
		expect(boolValue).toBeDefined()
		expect(boolValue.Name).toEqual("Some Key")
	end)
	it("names instances with their key value using legacy key syntax and updates them", function()
		local v5 = jest.fn()

		local function fn(...)
			return v5(...)
		end

		local element = v.createElement("Folder", {}, {
			["Some Key"] = v.createElement("BoolValue", {
				ref = fn
			})
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(v5).toHaveBeenCalledTimes(1)
		expect(v5.mock.calls[1][1].Name).toEqual("Some Key")
		local element2 = v.createElement("Folder", {}, {
			["Some other key"] = v.createElement("BoolValue", {
				ref = fn
			})
		})
		v3:render(element2)
		v4.unstable_flushAllWithoutAsserting()
		expect(v5).toHaveBeenCalledTimes(3)
		expect(v5).toHaveBeenNthCalledWith(2)
		expect(v5.mock.calls[3][1].Name).toEqual("Some other key")
	end)
	it("should create children with correct names and props", function()
		local element = v.createElement("StringValue", {
			key = "Some Key",
			Value = "Hey there!"
		}, {
			ChildA = v.createElement("IntValue", {
				Value = 173
			}),
			ChildB = v.createElement("Folder")
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder:GetChildren()).toEqual(1)
		local v5 = folder:GetChildren()[1]
		expect(v5.ClassName).toEqual("StringValue")
		expect(v5.Value).toEqual("Hey there!")
		expect(v5.Name).toEqual("Some Key")
		expect(#v5:GetChildren()).toEqual(2)
		local childA = v5.ChildA
		local childB = v5.ChildB
		expect(childA).toBeTruthy()
		expect(childB).toBeTruthy()
		expect(childA.ClassName).toEqual("IntValue")
		expect(childA.Value).toEqual(173)
		expect(childB.ClassName).toEqual("Folder")
	end)
	it("names instances with their key value using legacy key syntax through function component", function()
		local function Foo()
			return v.createElement("BoolValue")
		end

		local element = v.createElement("Folder", {}, {
			["Some Key"] = v.createElement(Foo)
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder:GetChildren()).toBe(1)
		local v5 = folder:GetChildren()[1]
		expect(v5.ClassName).toBe("Folder")
		local boolValue = v5:FindFirstChildOfClass("BoolValue")
		expect(boolValue).toBeDefined()
		expect(boolValue.Name).toEqual("Some Key")
	end)
end)
describe("updating instances", function()
	it("should update node props and children", function()
		local value = Instance.new("StringValue").Value
		local element = v.createElement("StringValue", {
			Name = "updateHostNodeTest",
			Value = "foo"
		}, {
			ChildA = v.createElement("IntValue", {
				Name = "ChildA",
				Value = 1
			}),
			ChildB = v.createElement("BoolValue", {
				Name = "ChildB",
				Value = true
			}),
			ChildC = v.createElement("StringValue", {
				Name = "ChildC",
				Value = "test"
			}),
			ChildD = v.createElement("StringValue", {
				Name = "ChildD",
				Value = "test"
			})
		})
		v3:render(element)
		v4.unstable_flushAllWithoutAsserting()
		local element2 = v.createElement("StringValue", {
			Name = "updateHostNodeTest",
			Value = "bar"
		}, {
			ChildA = v.createElement("StringValue", {
				Name = "ChildA",
				Value = "test"
			}),
			ChildB = v.createElement("BoolValue", {
				Name = "ChildB",
				Value = false
			}),
			ChildC = v.createElement("StringValue", {
				Name = "ChildC"
			}),
			ChildE = v.createElement("Folder", {
				Name = "ChildE"
			})
		})
		v3:render(element2)
		v4.unstable_flushAllWithoutAsserting()
		local updateHostNodeTest = folder.updateHostNodeTest
		expect(updateHostNodeTest.ClassName).toBe("StringValue")
		expect(updateHostNodeTest.Value).toBe("bar")
		expect(#updateHostNodeTest:GetChildren()).toBe(4)
		local childA = updateHostNodeTest.ChildA
		expect(childA.ClassName).toBe("StringValue")
		expect(childA.Value).toBe("test")
		local childB = updateHostNodeTest.ChildB
		expect(childB.ClassName).toBe("BoolValue")
		expect(childB.Value).toBe(false)
		local childC = updateHostNodeTest.ChildC
		expect(childC.ClassName).toBe("StringValue")
		expect(childC.Value).toBe(value)
		expect(updateHostNodeTest.ChildE.ClassName).toBe("Folder")
	end)
end)
describe("Portals", function()
	it("should create and destroy instances as children of `target`", function()
		local folder2 = Instance.new("Folder")

		local function FunctionComponent(p)
			return v.createElement("IntValue", {
				Name = "intValueOne",
				Value = p.value
			})
		end

		local portal = v2.createPortal({ v.createElement("Folder", {
				key = "1",
				Name = "folderOne"
			}), v.createElement("Folder", {
				key = "2",
				Name = "folderTwo"
			}), v.createElement(FunctionComponent, {
				key = "3",
				value = 42
			}) }, folder2)
		v3:render(portal)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(3)
		expect(folder2:FindFirstChild("folderOne")).toBeDefined()
		expect(folder2:FindFirstChild("folderTwo")).toBeDefined()
		expect(folder2:FindFirstChild("intValueOne")).toBeDefined()
		expect(folder2:FindFirstChild("intValueOne").Value).toBe(42)
		v3:unmount()
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(0)
	end)
	it("should pass prop updates through to children", function()
		local folder2 = Instance.new("Folder")
		local portal = v2.createPortal({
			ChildValue = v.createElement("IntValue", {
				Value = 1
			})
		}, folder2)
		local portal2 = v2.createPortal({
			ChildValue = v.createElement("IntValue", {
				Value = 2
			})
		}, folder2)
		v3:render(portal)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(1)
		expect(folder2:GetChildren()[1].Value).toBe(1)
		v3:render(portal2)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(1)
		expect(folder2:GetChildren()[1].Value).toBe(2)
		v3:unmount()
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(0)
	end)
	it("should throw if `target` is nil", function()
		expect(function()
			v2.createPortal(v.createElement("IntValue", {
				Value = 1
			}))
		end).toThrow()
	end)
	it("should recreate instances if `target` changes in an update", function()
		local folder2 = Instance.new("Folder")
		local folder3 = Instance.new("Folder")
		local portal = v2.createPortal(v.createElement("IntValue", {
			Value = 1
		}), folder2)
		local portal2 = v2.createPortal(v.createElement("IntValue", {
			Value = 2
		}), folder3)
		v3:render(portal)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(1)
		expect(#folder3:GetChildren()).toBe(0)
		expect(folder2:GetChildren()[1].Value).toBe(1)
		v3:render(portal2)
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(0)
		expect(#folder3:GetChildren()).toBe(1)
		expect(folder3:GetChildren()[1].Value).toBe(2)
		v3:unmount()
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(0)
		expect(#folder3:GetChildren()).toBe(0)
	end)
end)
describe("Context", function()
	it("should pass context values through portal nodes", function()
		local folder2 = Instance.new("Folder")
		local context = v.createContext(1)

		local function App(p)
			return v.createElement(context.Provider, {
				value = p.value
			}, {
				Portal = v2.createPortal({
					Consumer = v.createElement(context.Consumer, nil, function(p2)
						return v.createElement("TextLabel", {
							Text = "Result: " .. tostring(p2)
						})
					end)
				}, folder2)
			})
		end

		v3:render(v.createElement(App, {
			value = 2
		}))
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(1)
		expect(folder2:GetChildren()[1].Text).toBe("Result: 2")
		v3:render(v.createElement(App, {
			value = 3
		}))
		v4.unstable_flushAllWithoutAsserting()
		expect(#folder2:GetChildren()).toBe(1)
		expect(folder2:GetChildren()[1].Text).toBe("Result: 3")
	end)
end)