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
local folder = nil
beforeEach(function()
	jest.resetModules()
	jest.useFakeTimers()
	local Shared = require(parent.Shared)
	Shared.ReactFeatureFlags.debugRenderPhaseSideEffectsForStrictMode = false
	local React = require(parent.React)
	v = React
	local ReactRoblox = require(parent.ReactRoblox)
	v2 = ReactRoblox
	folder = Instance.new("Folder")
	v3 = v2.createRoot(folder)
end)
it("should update a value without re-rendering", function()
	local binding, v4 = v.createBinding("hello")
	local count = 0

	local function Component(_)
		count += 1
		return v.createElement("TextLabel", {
			Name = "Label",
			Text = binding
		})
	end

	v2.act(function()
		v3:render(v.createElement(Component))
	end)
	expect(count).toBe(1)
	expect(folder.Label.Text).toBe("hello")
	v4("world")
	expect(count).toBe(1)
	expect(folder.Label.Text).toBe("world")
end)
it("subscribe to updates when used as a ref", function()
	local ref = v.createRef()
	local ref2 = v.createRef()

	local function Component(_)
		return v.createElement(v.Fragment, nil, {
			Left = v.createElement("TextButton", {
				ref = ref,
				NextSelectionRight = ref2
			}),
			Right = v.createElement("TextButton", {
				ref = ref2,
				NextSelectionRight = ref
			})
		})
	end

	v2.act(function()
		v3:render(v.createElement(Component))
	end)
	expect(ref.current).never.toBeNil()
	expect(ref2.current).never.toBeNil()
	expect(ref.current.NextSelectionRight).toBe(ref2.current)
	expect(ref2.current.NextSelectionRight).toBe(ref.current)
end)
it("should not return the same root twice", function()
	local folder2 = Instance.new("Folder")
	local root = v2.createRoot(folder2)
	expect(v3).never.toBe(root)
end)
it("should unsubscribe from bindings when unmounted", function()
	local binding, v4 = v.createBinding(0)
	local count = 0

	local function Component()
		return v.createElement("TextLabel", {
			Text = binding:map(function(p)
				count += 1
				return (tostring(p))
			end)
		})
	end

	v2.act(function()
		v3:render(v.createElement(Component))
	end)
	expect(count).toBe(1)
	v2.act(function()
		v3:render(v.createElement(Component))
	end)
	expect(count).toBe(2)
	v4(1)
	expect(count).toBe(3)
	v2.act(function()
		v3:unmount()
	end)
	v4(2)
	expect(count).toBe(3)
end)
describe("useBinding hook", function()
	it("returns the same binding object each time", function()
		local v4 = jest.fn()
		local fn

		local function Component(_)
			local text, v6 = v.useBinding("hello")
			local state, setState = v.useState(1)
			v4(text, v6)

			fn = function()
				setState(function(p)
					return p + 1
				end)
			end

			return v.createElement("TextLabel", {
				Name = "Label",
				LayoutOrder = state,
				Text = text
			})
		end

		v2.act(function()
			v3:render(v.createElement(Component))
		end)
		expect(v4).toHaveBeenCalledTimes(1)
		expect(folder.Label.Text).toBe("hello")
		expect(folder.Label.LayoutOrder).toBe(1)
		v2.act(function()
			fn()
		end)
		expect(v4).toHaveBeenCalledTimes(2)
		local calls = v4.mock.calls
		expect(calls[1]).toEqual(calls[2])
		expect(folder.Label.Text).toBe("hello")
		expect(folder.Label.LayoutOrder).toBe(2)
	end)
	it("updates the relevant property without re-rendering", function()
		local v4 = nil
		local count = 0

		local function Component(_)
			local text, v6 = v.useBinding("hello")
			v4 = v6
			count += 1
			return v.createElement("TextLabel", {
				Name = "Label",
				Text = text
			})
		end

		v2.act(function()
			v3:render(v.createElement(Component))
		end)
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("hello")
		v4("world")
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("world")
	end)
	it("can be used with mapped bindings", function()
		local v4 = nil
		local count = 0

		local function Component(_)
			local v5, v6 = v.useBinding("hello")
			v4 = v6
			count += 1
			return v.createElement("TextLabel", {
				Name = "Label",
				Text = v5:map(function(p)
					return string.reverse(p)
				end)
			})
		end

		v2.act(function()
			v3:render(v.createElement(Component))
		end)
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("olleh")
		v4("world")
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("dlrow")
	end)
	it("mapped bindings can be re-mapped", function()
		local function Remap(p)
			return v.createElement("TextLabel", {
				Name = "LabelLength",
				Text = p.length:map(function(p2)
					return "Length: " .. tostring(p2)
				end)
			})
		end

		local v4 = nil
		local count = 0

		local function Component(_)
			local v5, v6 = v.useBinding("hello")
			v4 = v6
			count += 1
			return v.createElement(v.Fragment, nil, v.createElement("TextLabel", {
				Name = "Label",
				Text = v5:map(string.reverse)
			}), v.createElement(Remap, {
				length = v5:map(string.len)
			}))
		end

		v2.act(function()
			v3:render(v.createElement(Component))
		end)
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("olleh")
		expect(folder.LabelLength.Text).toBe("Length: 5")
		v4("friends")
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("sdneirf")
		expect(folder.LabelLength.Text).toBe("Length: 7")
	end)
	it("can be used with joined bindings", function()
		local v4 = nil
		local v5 = nil
		local count = 0

		local function Component(_)
			local v6, v7 = v.useBinding("Greeting:")
			local v8, v9 = v.useBinding("hello")
			v4 = v7
			v5 = v9
			count += 1
			local joinBindings = v.joinBindings({ v6, v8 })
			return v.createElement("TextLabel", {
				Name = "Label",
				Text = joinBindings:map(function(list)
					return table.concat(list, " ")
				end)
			})
		end

		v2.act(function()
			v3:render(v.createElement(Component))
		end)
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("Greeting: hello")
		v4("Salutation:")
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("Salutation: hello")
		v5("sup")
		expect(count).toBe(1)
		expect(folder.Label.Text).toBe("Salutation: sup")
	end)
end)