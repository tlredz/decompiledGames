local ReplicatedStorage = game:GetService("ReplicatedStorage")
local JestGlobals = require(ReplicatedStorage.DevPackages.JestGlobals)
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local beforeEach = JestGlobals.beforeEach
local jest = JestGlobals.jest
local v = nil
beforeEach(function()
	jest.resetModules()
	local ClientReplion = require(script.Parent.ClientReplion)
	v = ClientReplion
end)
describe("ClientReplion.new", function()
	it("should return a Replion", function()
		local v2 = v.new({
			nil,
			"new",
			{
				Coins = 20
			}
		})
		expect((type(v2))).toBe("table")
	end)
end)
describe("ClientReplion:BeforeDestroy", function()
	it("should be called when the replion is destroyed", function()
		local v2 = v.new({
			Data = {
				Coins = 20
			},
			Channel = "BeforeDestroy",
			Id = ""
		})
		local v3 = jest.fn()
		v2:BeforeDestroy(v3)
		v2:Destroy()
		expect(v3).toHaveBeenCalledTimes(1)
		expect(v2.Destroyed).toBe(true)
	end)
end)
describe("ClientReplion:Get", function()
	it("should return the value of the given key", function()
		local v2 = v.new({
			nil,
			"Get",
			{
				Foo = true,
				A = {
					B = { "Bar" }
				}
			}
		})
		expect(v2:Get("Foo")).toBe(true)
		expect(v2:Get({ "A", "B", 1 })).toBe("Bar")
	end)
end)
describe("ServerReplion:GetExpect", function()
	it("should get the value of the Replion", function()
		local v2 = v.new({
			nil,
			"Get",
			{
				Foo = true,
				A = {
					B = { "Bar" }
				}
			}
		})
		expect(v2:GetExpect("Foo")).toBe(true)
		expect(v2:GetExpect({ "A", "B", 1 })).toBe("Bar")
	end)
	it("should error when the value does not exist", function()
		local v2 = v.new({
			nil,
			"Get",
			{}
		})
		expect(function()
			v2:GetExpect("Foo")
		end).toThrow()
	end)
	it("should error with a custom message", function()
		local v2 = v.new({
			nil,
			"Get",
			{}
		})
		expect(function()
			v2:GetExpect("Foo", "Custom message")
		end).toThrow("Custom message")
	end)
end)
describe("ClientReplion:_set", function()
	it("should set the value of the given key", function()
		local v2 = v.new({
			nil,
			"Set",
			{}
		})
		v2:_set("Foo", true)
		expect(v2:Get("Foo")).toBe(true)
	end)
	it("should call the OnChange signal", function()
		local v2 = v.new({
			nil,
			"Set",
			{}
		})
		local v3 = jest.fn()
		v2:OnChange("Foo", v3)
		v2:_set("Foo", true)
		expect(v3).toHaveBeenCalledWith(true, nil)
	end)
	it("should call the OnDescendantChange signal", function()
		local v2 = v.new({
			nil,
			"Set",
			{
				A = {
					B = { "Bar" }
				}
			}
		})
		local v3 = jest.fn()
		v2:OnDescendantChange("A", v3)
		v2:_set({ "A", "B", 1 }, "Foo")
		expect(v3).toHaveBeenCalledWith({ "A", "B" }, { "Foo" }, { "Bar" })
	end)
end)
describe("ClientReplion:_clear", function()
	it("should clear the array", function()
		local v2 = v.new({
			nil,
			"Clear",
			{
				Array = { 1, 2, 3 }
			}
		})
		v2:_clear("Array")
		expect(v2:Get("Array")).toEqual({})
	end)
	it("should call the OnChange signal", function()
		local v2 = v.new({
			nil,
			"Clear",
			{
				Array = { 1, 2, 3 }
			}
		})
		local v3 = jest.fn()
		v2:OnChange("Array", v3)
		v2:_clear("Array")
		expect(v3).toHaveBeenCalledWith({}, { 1, 2, 3 })
	end)
end)
describe("ClientReplion:_increase", function()
	it("should increase the value of the given key", function()
		local v2 = v.new({
			nil,
			"Increase",
			{
				Foo = 1
			}
		})
		v2:_increase("Foo", 2)
		expect(v2:Get("Foo")).toBe(3)
	end)
end)
describe("ClientReplion:_insert", function()
	it("should insert the value into the array", function()
		local v2 = v.new({
			nil,
			"Insert",
			{
				Array = { 1, 3 }
			}
		})
		v2:_insert("Array", 2, 2)
		expect(v2:Get("Array")).toEqual({ 1, 2, 3 })
	end)
end)
describe("ClientReplion:_remove", function()
	it("should remove the value from the array", function()
		local v2 = v.new({
			nil,
			"Remove",
			{
				Array = { 1, 2, 3 }
			}
		})
		v2:_remove("Array", 2)
		expect(v2:Get("Array")).toEqual({ 1, 3 })
	end)
end)
describe("ClientReplion:OnChange", function()
	it("should connect the OnChange signal", function()
		local v2 = v.new({
			nil,
			"OnChange",
			{}
		})
		local v3 = jest.fn()
		v2:OnChange("Foo", v3)
		v2:_set("Foo", true)
		expect(v3).toHaveBeenCalledWith(true, nil)
	end)
	it("should call the callback if an value inside a table changes", function()
		local v2 = v.new({
			nil,
			"OnChange",
			{
				A = {
					B = {
						C = true
					}
				}
			}
		})
		local v3 = jest.fn()
		v2:OnChange("A", v3)
		v2:_set("A.B.C", false)
		v2:_set("A.B", {
			D = true
		})
		v2:_set("A.B.D", false)
		expect(v3).toHaveBeenCalledWith({
			B = {
				C = false
			}
		}, {
			B = {
				C = true
			}
		})
		expect(v3).toHaveBeenCalledWith({
			B = {
				D = true
			}
		}, {
			B = {
				C = false
			}
		})
		expect(v3).toHaveBeenCalledWith({
			B = {
				D = false
			}
		}, {
			B = {
				D = true
			}
		})
	end)
end)
describe("ClientReplion:OnArrayInsert", function()
	it("should call the callback when a value is inserted", function()
		local v2 = v.new({
			nil,
			"OnArrayInsert",
			{
				Array = { 1, 2, 3 }
			}
		})
		local v3 = jest.fn()
		v2:OnArrayInsert("Array", v3)
		v2:_insert("Array", 2, 4)
		expect(v3).toHaveBeenCalledWith(4, 2)
	end)
end)
describe("ClientReplion:OnArrayRemove", function()
	it("should call the callback when a value is removed", function()
		local v2 = v.new({
			nil,
			"OnArrayRemove",
			{
				Array = { 1, 2, 3 }
			}
		})
		local v3 = jest.fn()
		v2:OnArrayRemove("Array", v3)
		v2:_remove("Array", 2)
		expect(v3).toHaveBeenCalledWith(2, 2)
	end)
end)
describe("ClientReplion:Destroy", function()
	it("should destroy the replion", function()
		local v2 = v.new({
			nil,
			"Destroy",
			{
				Coins = 20
			}
		})
		v2:Destroy()
		expect(v2.Destroyed).toBe(true)
	end)
end)