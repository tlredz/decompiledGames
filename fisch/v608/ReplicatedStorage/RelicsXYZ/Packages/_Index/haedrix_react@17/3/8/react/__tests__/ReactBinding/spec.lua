local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local describe = JestGlobals.describe
local it = JestGlobals.it
require(parent.Shared)
local ReactBindingroblox = require(script.Parent.Parent["ReactBinding.roblox"])
local ReactCreateRef = require(script.Parent.Parent.ReactCreateRef)
describe("Binding.create", function()
	it("should return a Binding object and an update function", function()
		local v, v2 = ReactBindingroblox.create(1)
		expect((typeof(v))).toBe("table")
		expect(v2).toEqual(expect.any("function"))
	end)
	it("should support tostring on bindings", function()
		local v, v2 = ReactBindingroblox.create(1)
		expect((tostring(v))).toBe("RoactBinding(1)")
		v2("foo")
		expect((tostring(v))).toBe("RoactBinding(foo)")
	end)
	it("should allow mapping a mapped binding", function()
		local v, v2 = ReactBindingroblox.create(1)
		local mapped = v:map(function(p: number)
			return p * 100
		end):map(function(p)
			return tostring(p) .. "%"
		end)
		expect(mapped:getValue()).toEqual("100%")
		v2(0.3)
		expect(mapped:getValue()).toEqual("30%")
	end)

	if ReactGlobals.__DEV__ then
		it("should include a stack in DEV mode", function()
			local function createBinding(...)
				return ReactBindingroblox.create(...)
			end

			local binding, _ = createBinding(1)
			expect(binding._source).toContain(script.Name)
			expect(binding._source).toContain("Binding created")
		end)
	end
end)
describe("Binding object", function()
	it("should provide a getter and setter", function()
		local v, v2 = ReactBindingroblox.create(1)
		expect(v:getValue()).toBe(1)
		v2(3)
		expect(v:getValue()).toBe(3)
	end)
	it("should let users subscribe and unsubscribe to its updates", function()
		local v, v2 = ReactBindingroblox.create(1)
		local v3 = jest.fn()
		local v4 = ReactBindingroblox.subscribe(v, function(...)
			v3(...)
		end)
		expect(v3).never.toBeCalled()
		v2(2)
		expect(v3).toHaveBeenCalledTimes(1)
		expect(v3).toHaveBeenCalledWith(2)
		v4()
		v2(3)
		expect(v3).toHaveBeenCalledTimes(1)
	end)
end)
describe("Mapped bindings", function()
	it("should be composable", function()
		local v, v2 = ReactBindingroblox.create("hi")
		local mapped = v:map(string.len)
		local mapped2 = mapped:map(function(p: number)
			return p % 2 == 0
		end)
		expect(v:getValue()).toBe("hi")
		expect(mapped:getValue()).toBe(2)
		expect(mapped2:getValue()).toBe(true)
		v2("sup")
		expect(v:getValue()).toBe("sup")
		expect(mapped:getValue()).toBe(3)
		expect(mapped2:getValue()).toBe(false)
	end)
	it("should cascade updates when subscribed", function()
		local v, v2 = ReactBindingroblox.create("hi")
		local v3 = jest.fn()
		local v4 = ReactBindingroblox.subscribe(v, function(...)
			v3(...)
		end)
		local mapped = v:map(string.len)
		local v5 = jest.fn()
		local v6 = ReactBindingroblox.subscribe(mapped, function(...)
			v5(...)
		end)
		local mapped2 = mapped:map(function(p: number)
			return p % 2 == 0
		end)
		local v7 = jest.fn()
		local v8 = ReactBindingroblox.subscribe(mapped2, function(...)
			v7(...)
		end)
		expect(v3).never.toBeCalled()
		expect(v5).never.toBeCalled()
		expect(v7).never.toBeCalled()
		v2("nice")
		expect(v3).toBeCalledTimes(1)
		expect(v3).toBeCalledWith("nice")
		expect(v5).toBeCalledTimes(1)
		expect(v5).toBeCalledWith(4)
		expect(v7).toBeCalledTimes(1)
		expect(v7).toBeCalledWith(true)
		v4()
		v6()
		v8()
		v2("goodbye")
		expect(v3).toBeCalledTimes(1)
		expect(v7).toBeCalledTimes(1)
		expect(v5).toBeCalledTimes(1)
	end)
	it("should throw when updated directly", function()
		local mapped = ReactBindingroblox.create(1):map(function(p)
			return p
		end)
		expect(function()
			ReactBindingroblox.update(mapped, 5)
		end).toThrow()
	end)

	if ReactGlobals.__DEV__ then
		it("should include a stack in DEV mode", function()
			local v, _ = ReactBindingroblox.create(1)
			local mapped = v:map(function(p)
				return p
			end)
			expect(mapped._source).toContain(script.Name)
			expect(mapped._source).toContain("Mapped binding created")
		end)
	end
end)
describe("Binding.join", function()
	it("should have getValue", function()
		local v = ReactBindingroblox.create(1)
		local v2 = ReactBindingroblox.create(2)
		local foo = ReactBindingroblox.create(3)
		expect((ReactBindingroblox.join({
			v,
			v2,
			foo = foo
		}):getValue())).toEqual({
			[1] = 1,
			[2] = 2,
			foo = 3
		})
	end)
	it("should update when any one of the subscribed bindings updates", function()
		local v, v2 = ReactBindingroblox.create(1)
		local v3, v4 = ReactBindingroblox.create(2)
		local foo, v6 = ReactBindingroblox.create(3)
		local joined = ReactBindingroblox.join({
			v,
			v3,
			foo = foo
		})
		local v7 = jest.fn()
		ReactBindingroblox.subscribe(joined, function(...)
			v7(...)
		end)
		expect(v7).never.toBeCalled()
		v2(3)
		expect(v7).toBeCalledTimes(1)
		expect(v7).toBeCalledWith({
			[1] = 3,
			[2] = 2,
			foo = 3
		})
		v4(4)
		expect(v7).toBeCalledTimes(2)
		expect(v7).toBeCalledWith({
			[1] = 3,
			[2] = 4,
			foo = 3
		})
		v6(8)
		expect(v7).toBeCalledTimes(3)
		expect(v7).toBeCalledWith({
			[1] = 3,
			[2] = 4,
			foo = 8
		})
	end)
	it("should disconnect from all upstream bindings", function()
		local v, v2 = ReactBindingroblox.create(1)
		local v3, v4 = ReactBindingroblox.create(2)
		local joined = ReactBindingroblox.join({ v, v3 })
		local v5 = jest.fn()
		local v6 = ReactBindingroblox.subscribe(joined, function(...)
			v5(...)
		end)
		expect(v5).never.toBeCalled()
		v2(3)
		expect(v5).toBeCalledTimes(1)
		v4(3)
		expect(v5).toBeCalledTimes(2)
		v6()
		v2(4)
		expect(v5).toBeCalledTimes(2)
		v4(2)
		expect(v5).toBeCalledTimes(2)
		expect(joined:getValue()).toEqual({ 4, 2 })
	end)
	it("should be okay with calling disconnect multiple times", function()
		local joined = ReactBindingroblox.join({})
		local v = ReactBindingroblox.subscribe(joined, function() end)
		v()
		v()
	end)
	it("should throw if updated directly", function()
		local joined = ReactBindingroblox.join({})
		expect(function()
			ReactBindingroblox.update(joined, 0)
		end)
	end)

	if ReactGlobals.__DEV__ then
		it("should throw when a non-table value is passed", function()
			expect(function()
				ReactBindingroblox.join("hi")
			end).toThrow()
		end)
		it("should throw when a non-binding value is passed via table", function()
			expect(function()
				local v = { ReactBindingroblox.create(123), "abcde" }
				ReactBindingroblox.join(v)
			end).toThrow()
		end)
		it("should include a stack in DEV mode", function()
			local v, _ = ReactBindingroblox.create(1)
			local v2, _ = ReactBindingroblox.create(2)
			local joined = ReactBindingroblox.join({ v, v2 })
			expect(joined._source).toContain(script.Name)
			expect(joined._source).toContain("Joined binding created")
		end)
	end
end)
describe("createRef", function()
	it("should print the contained value when coerced to a string", function()
		local ref = ReactCreateRef.createRef()
		expect((tostring(ref))).toBe("Ref(nil)")
		ref.current = "hello"
		expect((tostring(ref))).toBe("Ref(hello)")
		ref.current = 123
		expect((tostring(ref))).toBe("Ref(123)")
		ref.current = Instance.new("Folder")
		expect((tostring(ref))).toBe("Ref(Folder)")
	end)

	if ReactGlobals.__DEV__ then
		it("should include a stack in DEV mode", function()
			local ref = ReactCreateRef.createRef()
			expect(ref._source).toContain(script.Name)
			expect(ref._source).toContain("Ref created")
		end)
	end
end)