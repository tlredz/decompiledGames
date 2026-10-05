local parent = script.Parent.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local v4 = nil
local folder = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
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
it("should render one portal", function()
	local frame = Instance.new("Frame")
	v3:render(v.createElement("Frame", {}, v2.createPortal(v.createElement("TextLabel", {
		Text = "portal"
	}), frame)))
	v4.unstable_flushAllWithoutAsserting()
	local children = frame:GetChildren()
	expect(#children).toBe(1)
	expect(children[1].ClassName).toBe("TextLabel")
	expect(children[1].Text).toBe("portal")
	v3:unmount()
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(0)
end)
it("should render many portals", function()
	local frame = Instance.new("Frame")
	local frame2 = Instance.new("Frame")
	local v5 = {}
	local extended = v.Component:extend("Child")

	function extended.componentDidMount(p)
		v5[#v5 + 1] = p.props.name .. " componentDidMount"
	end

	function extended.componentDidUpdate(p)
		v5[#v5 + 1] = p.props.name .. " componentDidUpdate"
	end

	function extended.componentWillUnmount(p)
		v5[#v5 + 1] = p.props.name .. " componentWillUnmount"
	end

	function extended:render()
		return v.createElement("TextLabel", {
			Text = self.props.name
		})
	end

	local extended2 = v.Component:extend("Parent")

	function extended2.componentDidMount(p)
		v5[#v5 + 1] = "Parent:" .. p.props.step .. " componentDidMount"
	end

	function extended2.componentDidUpdate(p)
		v5[#v5 + 1] = "Parent:" .. p.props.step .. " componentDidUpdate"
	end

	function extended2.componentWillUnmount(p)
		v5[#v5 + 1] = "Parent:" .. p.props.step .. " componentWillUnmount"
	end

	function extended2:render()
		local step = self.props.step
		return {
			v.createElement(extended, {
				key = "a",
				name = "normal[0]:" .. step
			}),
			v2.createPortal(v.createElement(extended, {
				key = "b",
				name = "portal1[0]:" .. step
			}), frame),
			v.createElement(extended, {
				key = "c",
				name = "normal[1]:" .. step
			}),
			v2.createPortal({ v.createElement(extended, {
					key = "d",
					name = "portal2[0]:" .. step
				}), v.createElement(extended, {
					key = "e",
					name = "portal2[1]:" .. step
				}) }, frame2)
		}
	end

	v3:render(v.createElement(extended2, {
		step = "a"
	}))
	v4.unstable_flushAllWithoutAsserting()
	local children = frame:GetChildren()
	expect(#children).toBe(1)
	expect(children[1].ClassName).toBe("TextLabel")
	expect(children[1].Text).toBe("portal1[0]:a")
	local children2 = frame2:GetChildren()
	expect(#children2).toBe(2)
	expect(children2[1].ClassName).toBe("TextLabel")
	expect(children2[1].Text).toBe("portal2[0]:a")
	expect(children2[2].ClassName).toBe("TextLabel")
	expect(children2[2].Text).toBe("portal2[1]:a")
	local children3 = folder:GetChildren()
	expect(#children3).toBe(2)
	expect(children3[1].ClassName).toBe("TextLabel")
	expect(children3[1].Text).toBe("normal[0]:a")
	expect(children3[2].ClassName).toBe("TextLabel")
	expect(children3[2].Text).toBe("normal[1]:a")
	expect(v5).toEqual({
		"normal[0]:a componentDidMount",
		"portal1[0]:a componentDidMount",
		"normal[1]:a componentDidMount",
		"portal2[0]:a componentDidMount",
		"portal2[1]:a componentDidMount",
		"Parent:a componentDidMount"
	})
	v5 = {}
	v3:render(v.createElement(extended2, {
		step = "b"
	}))
	v4.unstable_flushAllWithoutAsserting()
	local children4 = frame:GetChildren()
	expect(#children4).toBe(1)
	expect(children4[1].ClassName).toBe("TextLabel")
	expect(children4[1].Text).toBe("portal1[0]:b")
	local children5 = frame2:GetChildren()
	expect(#children5).toBe(2)
	expect(children5[1].ClassName).toBe("TextLabel")
	expect(children5[1].Text).toBe("portal2[0]:b")
	expect(children5[2].ClassName).toBe("TextLabel")
	expect(children5[2].Text).toBe("portal2[1]:b")
	local children6 = folder:GetChildren()
	expect(#children6).toBe(2)
	expect(children6[1].ClassName).toBe("TextLabel")
	expect(children6[1].Text).toBe("normal[0]:b")
	expect(children6[2].ClassName).toBe("TextLabel")
	expect(children6[2].Text).toBe("normal[1]:b")
	expect(v5).toEqual({
		"normal[0]:b componentDidUpdate",
		"portal1[0]:b componentDidUpdate",
		"normal[1]:b componentDidUpdate",
		"portal2[0]:b componentDidUpdate",
		"portal2[1]:b componentDidUpdate",
		"Parent:b componentDidUpdate"
	})
	v5 = {}
	v3:unmount()
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(0)
	expect(#frame2:GetChildren()).toBe(0)
	expect(#folder:GetChildren()).toBe(0)
	expect(v5).toEqual({
		"Parent:b componentWillUnmount",
		"normal[0]:b componentWillUnmount",
		"portal1[0]:b componentWillUnmount",
		"normal[1]:b componentWillUnmount",
		"portal2[0]:b componentWillUnmount",
		"portal2[1]:b componentWillUnmount"
	})
end)
it("should render nested portals", function()
	local frame = Instance.new("Frame")
	local frame2 = Instance.new("Frame")
	local frame3 = Instance.new("Frame")
	v3:render({ v.createElement("TextLabel", {
			key = "a",
			Text = "normal[0]"
		}), v2.createPortal({
			v.createElement("TextLabel", {
				key = "b",
				Text = "portal1[0]"
			}),
			v2.createPortal(v.createElement("TextLabel", {
				key = "c",
				Text = "portal2[0]"
			}), frame2),
			v2.createPortal(v.createElement("TextLabel", {
				key = "d",
				Text = "portal3[0]"
			}), frame3),
			v.createElement("TextLabel", {
				key = "e",
				Text = "portal1[1]"
			})
		}, frame), v.createElement("TextLabel", {
			key = "f",
			Text = "normal[1]"
		}) })
	v4.unstable_flushAllWithoutAsserting()
	local children = frame:GetChildren()
	expect(#children).toBe(2)
	expect(children[1].Text).toBe("portal1[0]")
	expect(children[2].Text).toBe("portal1[1]")
	local children2 = frame2:GetChildren()
	expect(#children2).toBe(1)
	expect(children2[1].Text).toBe("portal2[0]")
	local children3 = frame3:GetChildren()
	expect(#children3).toBe(1)
	expect(children3[1].Text).toBe("portal3[0]")
	local children4 = folder:GetChildren()
	expect(#children4).toBe(2)
	expect(children4[1].Text).toBe("normal[0]")
	expect(children4[2].Text).toBe("normal[1]")
	v3:unmount()
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(0)
	expect(#frame2:GetChildren()).toBe(0)
	expect(#frame3:GetChildren()).toBe(0)
	expect(#folder:GetChildren()).toBe(0)
end)
it("should reconcile portal children", function()
	local frame = Instance.new("Frame")
	v3:render(v.createElement("Frame", {}, { v2.createPortal(v.createElement("TextLabel", {
			Text = "portal:1"
		}), frame) }))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(1)
	expect(frame:GetChildren()[1].Text).toBe("portal:1")
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
	v3:render(v.createElement("Frame", {}, { v2.createPortal(v.createElement("TextLabel", {
			Text = "portal:2"
		}), frame) }))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(1)
	expect(frame:GetChildren()[1].Text).toBe("portal:2")
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
	v3:render(v.createElement("Frame", {}, { v2.createPortal(v.createElement("TextLabel", {
			Text = "portal:3"
		}), frame) }))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(1)
	expect(frame:GetChildren()[1].Text).toBe("portal:3")
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
	v3:render(v.createElement("Frame", {}, v2.createPortal({ v.createElement("TextLabel", {
			key = "1",
			Text = "Hi"
		}), v.createElement("TextLabel", {
			key = "2",
			Text = "Bye"
		}) }, frame)))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(2)
	expect(frame:GetChildren()[1].Text).toBe("Hi")
	expect(frame:GetChildren()[2].Text).toBe("Bye")
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
	v3:render(v.createElement("Frame", {}, v2.createPortal({ v.createElement("TextLabel", {
			key = "1",
			Text = "Bye"
		}), v.createElement("TextLabel", {
			key = "2",
			Text = "Hi"
		}) }, frame)))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(2)
	expect(frame:GetChildren()[1].Text).toBe("Bye")
	expect(frame:GetChildren()[2].Text).toBe("Hi")
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
	v3:render(v.createElement("Frame", {}, v2.createPortal(nil, frame)))
	v4.unstable_flushAllWithoutAsserting()
	expect(#frame:GetChildren()).toBe(0)
	expect(#folder:GetChildren()).toBe(1)
	expect(#folder:GetChildren()[1]:GetChildren()).toBe(0)
end)
it("should unmount empty portal component wherever it appears", function()
	local frame = Instance.new("Frame")
	local state = nil
	local fn
	local extended = v.Component:extend("Wrapper")

	function extended.init(object)
		object:setState({
			show = true
		})
	end

	function extended:render()
		state = self.state

		fn = function(...)
			self:setState(...)
		end

		return v.createElement(
			"Frame",
			{},
			self.state.show and v.createElement(
				v.Fragment,
				nil,
				v2.createPortal(nil, frame),
				v.createElement("TextLabel", {
					Text = "child"
				})
			),
			v.createElement("TextLabel", {
				Text = "parent"
			})
		)
	end

	v3:render(v.createElement(extended))
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(1)
	local children = folder:GetChildren()[1]:GetChildren()
	expect(#children).toBe(2)
	expect(children[1].Text).toBe("child")
	expect(children[2].Text).toBe("parent")
	fn({
		show = false
	})
	v4.unstable_flushAllWithoutAsserting()
	expect(state.show).toBe(false)
	expect(#folder:GetChildren()).toBe(1)
	local children2 = folder:GetChildren()[1]:GetChildren()
	expect(#children2).toBe(1)
	expect(children2[1].Text).toBe("parent")
end)
it("should pass portal context when rendering subtree elsewhere", function()
	local folder2 = Instance.new("Folder")
	local context = v.createContext(1)

	local function Consumer()
		return v.createElement(context.Consumer, nil, function(p)
			return v.createElement("TextLabel", {
				Text = tostring(p)
			})
		end)
	end

	local function Parent(p)
		return v.createElement(context.Provider, {
			value = p.value
		}, {
			Portal = v2.createPortal({
				Consumer = v.createElement(Consumer)
			}, folder2)
		})
	end

	v3:render(v.createElement(Parent, {
		value = "bar"
	}))
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(0)
	expect(#folder2:GetChildren()).toBe(1)
	expect(folder2:GetChildren()[1].Text).toBe("bar")
end)
it("should update portal context if it changes due to setState", function()
	local folder2 = Instance.new("Folder")
	local context = v.createContext(1)

	local function Consumer()
		return v.createElement(context.Consumer, nil, function(p)
			return v.createElement("TextLabel", {
				Text = tostring(p)
			})
		end)
	end

	local fn
	local extended = v.Component:extend("Parent")

	function extended.init(object)
		object:setState({
			value = "initial"
		})
	end

	function extended:render()
		fn = function(...)
			self:setState(...)
		end

		return v.createElement(context.Provider, {
			value = self.state.value
		}, {
			Portal = v2.createPortal({
				Consumer = v.createElement(Consumer)
			}, folder2)
		})
	end

	v3:render(v.createElement(extended))
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(0)
	expect(#folder2:GetChildren()).toBe(1)
	expect(folder2:GetChildren()[1].Text).toBe("initial")
	fn({
		value = "changed"
	})
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(0)
	expect(#folder2:GetChildren()).toBe(1)
	expect(folder2:GetChildren()[1].Text).toBe("changed")
end)
it("should update portal context if it changes due to re-render", function()
	local folder2 = Instance.new("Folder")
	local context = v.createContext(1)

	local function Consumer()
		return v.createElement(context.Consumer, nil, function(p)
			return v.createElement("TextLabel", {
				Text = tostring(p)
			})
		end)
	end

	local function Parent(p)
		return v.createElement(context.Provider, {
			value = p.value
		}, {
			Portal = v2.createPortal({
				Consumer = v.createElement(Consumer)
			}, folder2)
		})
	end

	v3:render(v.createElement(Parent, {
		value = "initial"
	}))
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(0)
	expect(#folder2:GetChildren()).toBe(1)
	expect(folder2:GetChildren()[1].Text).toBe("initial")
	v3:render(v.createElement(Parent, {
		value = "changed"
	}))
	v4.unstable_flushAllWithoutAsserting()
	expect(#folder:GetChildren()).toBe(0)
	expect(#folder2:GetChildren()).toBe(1)
	expect(folder2:GetChildren()[1].Text).toBe("changed")
end)
xit("should bubble events from the portal to the parent", function() end)
xit("should not onMouseLeave when staying in the portal", function() end)
it("should throw on bad createPortal argument", function()
	expect(function()
		v2.createPortal(v.createElement("Frame"))
	end).toThrow("Target container is not a Roblox Instance.")
	expect(function()
		v2.createPortal(v.createElement("Frame"), "hi")
	end).toThrow("Target container is not a Roblox Instance.")
end)