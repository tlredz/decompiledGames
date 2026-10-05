local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local jest = JestGlobals.jest
local useRef = nil
JestGlobals.describe("useRef", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactRoblox = require(parent.Dev.ReactRoblox)
		v2 = ReactRoblox
		local Scheduler = require(parent.Scheduler)
		v3 = Scheduler
		useRef = v.useRef
	end)
	it("should assign initial value to the ref", function()
		local v4 = nil
		local v5 = nil

		local function component()
			v4 = useRef(123)
			v5 = useRef("HelloRef")
			return nil
		end

		local folder = Instance.new("Folder")
		local root = v2.createRoot(folder)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		expect(v4).toBeDefined()
		expect(v4.current).toBe(123)
		expect(v5).toBeDefined()
		expect(v5.current).toBe("HelloRef")
		root:unmount()
	end)
	it("should allow current value to be updated", function()
		local v4 = nil

		local function component()
			v4 = useRef(123)
			v.useEffect(function()
				v4.current = 456
			end, {})
			return nil
		end

		local folder = Instance.new("Folder")
		v2.createRoot(folder):render(v.createElement(component))
		v3.unstable_flushAll()
		expect(v4).toBeDefined()
		expect(v4.current).toBe(456)
	end)
	it("should remember current value between renders", function()
		local v4 = nil

		local function component()
			v4 = useRef(0)
			v4.current += 1
			return nil
		end

		local folder = Instance.new("Folder")
		local root = v2.createRoot(folder)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		expect(v4).toBeDefined()
		local current = v4.current
		expect(current).toBeGreaterThan(0)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		local current2 = v4.current
		expect(current2).toBeGreaterThan(current)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		expect(v4.current).toBeGreaterThan(current2)
		root:unmount()
	end)
	it("should bind to NextSelection props without error", function()
		local v4 = nil

		local function component()
			v4 = useRef(nil)
			return v.createElement(v.Fragment, {}, {
				Top = v.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.5),
					NextSelectionUp = v4,
					NextSelectionDown = v4,
					NextSelectionLeft = v4,
					NextSelectionRight = v4
				}),
				Bottom = v.createElement("Frame", {
					Size = UDim2.fromScale(1, 0.5),
					Position = UDim2.fromScale(0, 0.5),
					ref = v4
				})
			})
		end

		local folder = Instance.new("Folder")
		local root = v2.createRoot(folder)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		expect(v4).toBeDefined()
		expect(v4.current).toMatchInstance({
			Name = "Bottom"
		})
		root:unmount()
	end)
	it("should stringify refs correctly", function()
		local ref = nil

		local function component()
			ref = useRef(nil)
			return v.createElement("Frame", {
				Size = UDim2.new(1, 0, 1, 0),
				ref = ref
			})
		end

		local folder = Instance.new("Folder")
		local root = v2.createRoot(folder)
		root:render(v.createElement(component))
		v3.unstable_flushAll()
		expect(ref).toBeDefined()
		expect((tostring(ref))).toEqual("Ref(Frame)")
		root:unmount()
	end)
end)