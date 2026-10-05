local parent = script.Parent.Parent.Parent
local LuauPolyfill = require(parent.LuauPolyfill)
local array = LuauPolyfill.Array
local v = nil
local v2 = nil
local v3 = nil
local JestGlobals = require(parent.Dev.JestGlobals)
local jest = JestGlobals.jest
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local beforeEach = JestGlobals.beforeEach
local it = JestGlobals.it
local xit = JestGlobals.xit
describe("ReactChildren", function()
	beforeEach(function()
		jest.resetModules()
		local parentModule = require(script.Parent.Parent)
		v = parentModule
		local ReactRoblox = require(parent.Dev.ReactRoblox)
		v3 = ReactRoblox
		v2 = {
			renderIntoDocument = function(p)
				local folder = Instance.new("Folder")
				local legacyRoot = v3.createLegacyRoot(folder)
				legacyRoot:render(p)
				return legacyRoot
			end
		}
	end)
	it("should support identity for simple", function()
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p, _)
			return p
		end)
		local element = v.createElement("span", {
			key = "simple"
		})
		local element2 = v.createElement("span", nil, element)
		v.Children.forEach(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mapped[1]).toEqual(v.createElement("span", {
			key = ".$simple"
		}))
	end)
	it("should support Portal components", function()
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p, _)
			return p
		end)
		local folder = Instance.new("Folder")
		local element = v.createElement("Frame", {
			key = "simple"
		})
		local portal = v3.createPortal(element, folder)
		local element2 = v.createElement("Frame", nil, portal)
		v.Children.forEach(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(portal, 1)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(portal, 1)
		expect(mapped[1]).toEqual(portal)
	end)
	it("should treat single arrayless child as being in array", function()
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p, _)
			return p
		end)
		local element = v.createElement("span", nil)
		local element2 = v.createElement("div", nil, element)
		v.Children.forEach(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mapped[1]).toEqual(v.createElement("span", {
			key = ".1"
		}))
	end)
	it("should treat single child in array as expected", function()
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p, _)
			return p
		end)
		local element = v.createElement("span", {
			key = "simple"
		})
		local element2 = v.createElement("div", nil, { element })
		v.Children.forEach(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element2.props.children, mockImplementation, v4)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mapped[1]).toEqual(v.createElement("span", {
			key = ".$simple"
		}))
	end)
	it("should be called for each child", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local element4 = v.createElement("div", nil, element, none, element2, none2, element3)

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(5)
			expect(mockImplementation).toHaveBeenCalledWith(element, 1)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
			expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
			expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element4.props.children, mockImplementation, v4)
		assertCalls()
		local mapped = v.Children.map(element4.props.children, mockImplementation, v4)
		assertCalls()
		expect(mapped).toEqual({ v.createElement("div", {
				key = ".$keyZero"
			}), v.createElement("div", {
				key = ".$keyTwo"
			}), v.createElement("div", {
				key = ".$keyFour"
			}) })
	end)
	it("should traverse children of different kinds", function()
		local element = v.createElement("div", {
			key = "divNode"
		})
		local element2 = v.createElement("span", {
			key = "spanNode"
		})
		local element3 = v.createElement("a", {
			key = "aNode"
		})
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local element4 = v.createElement("div", nil, element, {
			{ element2 }
		}, { element3 }, "string", 1234, true, false, v.None, v.None)

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(9)
			expect(mockImplementation).toHaveBeenCalledWith(element, 1)
			expect(mockImplementation).toHaveBeenCalledWith(element2, 2)
			expect(mockImplementation).toHaveBeenCalledWith(element3, 3)
			expect(mockImplementation).toHaveBeenCalledWith("string", 4)
			expect(mockImplementation).toHaveBeenCalledWith(1234, 5)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 6)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 7)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 8)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 9)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element4.props.children, mockImplementation, v4)
		assertCalls()
		local mapped = v.Children.map(element4.props.children, mockImplementation, v4)
		assertCalls()
		expect(mapped).toEqual({
			v.createElement("div", {
				key = ".$divNode"
			}),
			v.createElement("span", {
				key = ".2:1:$spanNode"
			}),
			v.createElement("a", {
				key = ".3:$aNode"
			}),
			"string",
			1234
		})
	end)
	it("should be called for each child in nested structure", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local element4 = v.createElement("div", {
			key = "keyFive"
		})
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local element5 = v.createElement("div", nil, {
			{ element, none, element2 },
			{ none2, element3 },
			element4
		})

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(6)
			expect(mockImplementation).toHaveBeenCalledWith(element, 1)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
			expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
			expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
			expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
			expect(mockImplementation).toHaveBeenCalledWith(element4, 6)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element5.props.children, mockImplementation, v4)
		assertCalls()
		local mapped = v.Children.map(element5.props.children, mockImplementation, v4)
		assertCalls()
		expect(mapped).toEqual({
			v.createElement("div", {
				key = ".1:$keyZero"
			}),
			v.createElement("div", {
				key = ".1:$keyTwo"
			}),
			v.createElement("div", {
				key = ".2:$keyFour"
			}),
			v.createElement("div", {
				key = ".$keyFive"
			})
		})
	end)
	it("should retain key across two mappings", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local element2 = v.createElement("div", {
			key = "keyOne"
		})
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local element3 = v.createElement("div", nil, element, element2)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledWith(element, 1)
			expect(mockImplementation).toHaveBeenCalledWith(element2, 2)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element3.props.children, mockImplementation, v4)
		assertCalls() -- equivalent call inferred; original call site unknown
		local mapped = v.Children.map(element3.props.children, mockImplementation, v4)
		assertCalls() -- equivalent call inferred; original call site unknown
		expect(mapped).toEqual({ v.createElement("div", {
				key = ".$keyZero"
			}), v.createElement("div", {
				key = ".$keyOne"
			}) })
	end)
	xit("should be called for each child in an iterable without keys", function()
		local v4 = {
			["@@iterator"] = function(_)
				local count = 0
				return {
					next = function(_)
						local v5 = count
						count += 1

						if v5 < 3 then
							return {
								value = v.createElement("div", nil),
								done = false
							}
						end

						return {
							value = nil,
							done = true
						}
					end
				}
			end
		}
		local v5 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local v6 = nil
		expect(function()
			v6 = v.createElement("div", nil, v4)
			return v6
		end).toErrorDev("Warning: Each child in a list should have a unique \"key\" prop.")

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(3)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", nil), 0)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", nil), 1)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", nil), 2)
			mockImplementation.mockClear()
		end

		v.Children.forEach(v6.props.children, mockImplementation, v5)
		assertCalls()
		local mapped = v.Children.map(v6.props.children, mockImplementation, v5)
		assertCalls()
		expect(mapped).toEqual({ v.createElement("div", {
				key = ".0"
			}), v.createElement("div", {
				key = ".1"
			}), v.createElement("div", {
				key = ".2"
			}) })
	end)
	xit("should be called for each child in an iterable with keys", function()
		local v4 = {
			["@@iterator"] = function(_)
				local count = 0
				return {
					next = function(_)
						local v5 = count
						count += 1

						if v5 < 3 then
							return {
								value = v.createElement("div", {
									key = "#" .. tostring(count)
								}),
								done = false
							}
						end

						return {
							value = nil,
							done = true
						}
					end
				}
			end
		}
		local v5 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)
		local element = v.createElement("div", nil, v4)

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(3)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", {
				key = "#1"
			}), 0)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", {
				key = "#2"
			}), 1)
			expect(mockImplementation).toHaveBeenCalledWith(v.createElement("div", {
				key = "#3"
			}), 2)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element.props.children, mockImplementation, v5)
		assertCalls()
		local mapped = v.Children.map(element.props.children, mockImplementation, v5)
		assertCalls()
		expect(mapped).toEqual({ v.createElement("div", {
				key = ".$#1"
			}), v.createElement("div", {
				key = ".$#2"
			}), v.createElement("div", {
				key = ".$#3"
			}) })
	end)
	it("should allow extension of native prototypes", function()
		local element = v.createElement("div", nil, "a", 13)
		local v4 = {}
		local mockImplementation = jest.fn().mockImplementation(function(p)
			return p
		end)

		local function assertCalls()
			expect(mockImplementation).toHaveBeenCalledTimes(2, 0)
			expect(mockImplementation).toHaveBeenCalledWith("a", 1)
			expect(mockImplementation).toHaveBeenCalledWith(13, 2)
			mockImplementation.mockClear()
		end

		v.Children.forEach(element.props.children, mockImplementation, v4)
		assertCalls()
		local mapped = v.Children.map(element.props.children, mockImplementation, v4)
		assertCalls()
		expect(mapped).toEqual({ "a", 13 })
	end)
	it("should pass key to returned component", function()
		-- equivalent calls inferred from this helper; original call sites unknown
		local function mapFn(element, _)
			return v.createElement("div", nil, element)
		end

		local element = v.createElement("span", {
			key = "simple"
		})
		local v4 = mapFn(element) -- equivalent call inferred; original call site unknown
		local mapped = v.Children.map(v4.props.children, mapFn)
		expect(v.Children.count(mapped)).toBe(1)
		expect(mapped[1]).never.toBe(element)
		expect(mapped[1].props.children).toBe(element)
		expect(mapped[1].key).toBe(".$simple")
	end)
	it("should be called for each child 2", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local v4 = {
			v.createElement("div", {
				key = "giraffe"
			}),
			nil,
			v.createElement("div", nil),
			v.createElement("span", nil),
			v.createElement("div", {
				key = "keyFour"
			})
		}
		local mockImplementation = jest.fn().mockImplementation(function(_, p)
			return v4[p]
		end)
		local element4 = v.createElement("div", nil, element, none, element2, none2, element3)
		v.Children.forEach(element4.props.children, mockImplementation)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
		expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
		expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element4.props.children, mockImplementation)
		expect(mockImplementation).toHaveBeenCalledTimes(5)
		expect(v.Children.count(mapped)).toBe(4)
		expect({
			mapped[1].key,
			mapped[2].key,
			mapped[3].key,
			mapped[4].key
		}).toEqual({
			"giraffe/.$keyZero",
			".$keyTwo",
			".4",
			".$keyFour"
		})
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
		expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
		expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
		expect(mapped[1]).toEqual(v.createElement("div", {
			key = "giraffe/.$keyZero"
		}))
		expect(mapped[2]).toEqual(v.createElement("div", {
			key = ".$keyTwo"
		}))
		expect(mapped[3]).toEqual(v.createElement("span", {
			key = ".4"
		}))
		expect(mapped[4]).toEqual(v.createElement("div", {
			key = ".$keyFour"
		}))
	end)
	it("should be called for each child in nested structure 2", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local element4 = v.createElement("div", {
			key = "keyFive"
		})
		local element5 = v.createElement("div", {
			key = "giraffe"
		})
		local element6 = v.createElement("div", nil)
		local element7 = v.createElement("div", {
			key = "keyFour"
		})
		local element8 = v.createElement("div", nil)
		local mockImplementation = jest.fn().mockImplementation(function(p)
			local v4 = false

			for _, v5 in {
				element,
				element2,
				element3,
				element4
			} do
				if p ~= v5 then
					continue
				end

				if v5 == element then
					return element5
				end

				if v5 == element2 or v4 then
					return element6
				end

				if v5 == element3 or v4 then
					return element7
				end

				if v5 == element4 or v4 then
					return element8
				end
			end

			return p
		end)
		local element9 = v.createElement("div", nil, {
			{
				{ element, none, element2 },
				{ none2, element3 },
				element4
			}
		})
		v.Children.forEach(element9.props.children, mockImplementation)
		expect(mockImplementation).toHaveBeenCalledTimes(6)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
		expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
		expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
		expect(mockImplementation).toHaveBeenCalledWith(element4, 6)
		mockImplementation.mockClear()
		local mapped = v.Children.map(element9.props.children, mockImplementation)
		expect(mockImplementation).toHaveBeenCalledTimes(6)
		expect(mockImplementation).toHaveBeenCalledWith(element, 1)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 2)
		expect(mockImplementation).toHaveBeenCalledWith(element2, 3)
		expect(mockImplementation).toHaveBeenCalledWith(nil, 4)
		expect(mockImplementation).toHaveBeenCalledWith(element3, 5)
		expect(mockImplementation).toHaveBeenCalledWith(element4, 6)
		expect(v.Children.count(mapped)).toBe(4)
		expect({
			mapped[1].key,
			mapped[2].key,
			mapped[3].key,
			mapped[4].key
		}).toEqual({
			"giraffe/.1:1:$keyZero",
			".1:1:$keyTwo",
			".1:2:$keyFour",
			".1:$keyFive"
		})
		expect(mapped[1]).toEqual(v.createElement("div", {
			key = "giraffe/.1:1:$keyZero"
		}))
		expect(mapped[2]).toEqual(v.createElement("div", {
			key = ".1:1:$keyTwo"
		}))
		expect(mapped[3]).toEqual(v.createElement("div", {
			key = ".1:2:$keyFour"
		}))
		expect(mapped[4]).toEqual(v.createElement("div", {
			key = ".1:$keyFive"
		}))
	end)
	it("should retain key across two mappings 2", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local element2 = v.createElement("div", {
			key = "keyOne"
		})
		local element3 = v.createElement("div", {
			key = "giraffe"
		})
		local element4 = v.createElement("div", nil)

		local function mapFn(_, p)
			if p == 1 then
				return element3
			end

			return element4
		end

		local element5 = v.createElement("div", nil, element, element2)
		local mapped = v.Children.map(element5.props.children, mapFn)
		expect((array.map(mapped, function(p)
			return p.key
		end))).toEqual({ "giraffe/.$keyZero", ".$keyOne" })
		local mapped3 = v.Children.map(mapped, mapFn)
		expect(array.map(mapped3, function(p)
			return p.key
		end)).toEqual({ "giraffe/.$giraffe/.$keyZero", ".$.$keyOne" })
	end)
	it("should not throw if key provided is a dupe with array key", function()
		local element = v.createElement("div", nil)
		local element2 = v.createElement("div", {
			key = "0"
		})

		local function mapFn()
			return nil
		end

		local element3 = v.createElement("div", nil, element, element2)
		expect(function()
			v.Children.map(element3.props.children, mapFn)
		end).never.toThrow()
	end)
	it("should use the same key for a cloned element", function()
		local element = v.createElement("div", nil, v.createElement("div", nil))
		local mapped = v.Children.map(element.props.children, function(p)
			return p
		end)
		local mapped2 = v.Children.map(element.props.children, function(p)
			return v.cloneElement(p)
		end)
		expect(mapped[1].key).toBe(mapped2[1].key)
	end)
	it("should use the same key for a cloned element with key", function()
		local element = v.createElement("div", nil, v.createElement("div", {
			key = "unique"
		}))
		local mapped = v.Children.map(element.props.children, function(p)
			return p
		end)
		local mapped2 = v.Children.map(element.props.children, function(p)
			return v.cloneElement(p, {
				key = "unique"
			})
		end)
		expect(mapped[1].key).toBe(mapped2[1].key)
	end)
	it("should return 0 for null children", function()
		expect((v.Children.count(nil))).toBe(0)
	end)
	it("should return 1 for single child", function()
		local element = v.createElement("span", {
			key = "simple"
		})
		local element2 = v.createElement("div", nil, element)
		expect((v.Children.count(element2.props.children))).toBe(1)
	end)
	it("should count the number of children in flat structure", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local element4 = v.createElement("div", nil, element, none, element2, none2, element3)
		expect((v.Children.count(element4.props.children))).toBe(5)
	end)
	it("should count the number of children in nested structure", function()
		local element = v.createElement("div", {
			key = "keyZero"
		})
		local none = v.None
		local element2 = v.createElement("div", {
			key = "keyTwo"
		})
		local none2 = v.None
		local element3 = v.createElement("div", {
			key = "keyFour"
		})
		local element4 = v.createElement("div", {
			key = "keyFive"
		})
		local element5 = v.createElement("div", nil, {
			{
				{ element, none, element2 },
				{ none2, element3 },
				element4
			},
			v.None
		})
		expect((v.Children.count(element5.props.children))).toBe(7)
	end)
	it("should flatten children to an array", function()
		expect(v.Children.toArray(nil)).toEqual({})
		expect(v.Children.toArray(v.None)).toEqual({})
		expect(#v.Children.toArray(v.createElement("div", nil))).toBe(1)
		expect(#v.Children.toArray({ v.createElement("div", nil) })).toBe(1)
		expect(v.Children.toArray(v.createElement("div", nil))[1].key).toBe(v.Children.toArray({ v.createElement(
				"div",
				nil
			) })[1].key)
		local array2 = v.Children.toArray({
			{ v.createElement("div", {
					key = "apple"
				}), v.createElement("div", {
					key = "banana"
				}), v.createElement("div", {
					key = "camel"
				}) },
			{ v.createElement("div", {
					key = "banana"
				}), v.createElement("div", {
					key = "camel"
				}), v.createElement("div", {
					key = "deli"
				}) }
		})
		expect(#array2).toBe(6)
		expect(array2[2].key).toContain("banana")
		expect(array2[4].key).toContain("banana")
		expect(array2[2].key).never.toBe(array2[4].key)
		local array3 = v.Children.toArray({
			{ v.createElement("div", {
					key = "camel"
				}), v.createElement("div", {
					key = "banana"
				}), v.createElement("div", {
					key = "apple"
				}) },
			{ v.createElement("div", {
					key = "deli"
				}), v.createElement("div", {
					key = "camel"
				}), v.createElement("div", {
					key = "banana"
				}) }
		})
		expect(array2[1].key).toBe(array3[3].key)
		expect(array2[2].key).toBe(array3[2].key)
		expect(array2[3].key).toBe(array3[1].key)
		expect(array2[4].key).toBe(array3[6].key)
		expect(array2[5].key).toBe(array3[5].key)
		expect(array2[6].key).toBe(array3[4].key)
		expect(v.Children.toArray({
			1,
			"two",
			nil,
			v.None,
			true
		})).toEqual({ 1, "two" })
	end)
	it("should escape keys", function()
		local element = v.createElement("div", {
			key = "1"
		})
		local element2 = v.createElement("div", {
			key = "1=::=2"
		})
		local element3 = v.createElement("div", nil, element, element2)
		expect((v.Children.map(element3.props.children, function(p)
			return p
		end))).toEqual({ v.createElement("div", {
				key = ".$1"
			}), v.createElement("div", {
				key = ".$1=0=2=2=02"
			}) })
	end)
	it("should combine keys when map returns an array", function()
		local element = v.createElement("div", nil, v.createElement("div", {
			key = "a"
		}), false, v.createElement("div", {
			key = "b"
		}), v.createElement("p", nil))
		local mapped = v.Children.map(element.props.children, function(p)
			local element2 = v.createElement("span", {
				key = "x"
			})
			local none = v.None
			local element3 = v.createElement("span", {
				key = "y"
			})
			local v5 = p or v.None
			local v6

			if p and p ~= v.None then
				v6 = v.cloneElement(p, {
					key = "z"
				})
			else
				v6 = v.None
			end

			return {
				element2,
				none,
				element3,
				v5,
				v6,
				v.createElement("hr", nil)
			}
		end)
		expect(#mapped).toBe(18)
		expect(mapped[1].type).toBe("span")
		expect(mapped[1].key).toBe(".$a/.$x")
		expect(mapped[2].type).toBe("span")
		expect(mapped[2].key).toBe(".$a/.$y")
		expect(mapped[3].type).toBe("div")
		expect(mapped[3].key).toBe(".$a/.$a")
		expect(mapped[4].type).toBe("div")
		expect(mapped[4].key).toBe(".$a/.$z")
		expect(mapped[5].type).toBe("hr")
		expect(mapped[5].key).toBe(".$a/.6")
		expect(mapped[6].type).toBe("span")
		expect(mapped[6].key).toBe(".2/.$x")
		expect(mapped[7].type).toBe("span")
		expect(mapped[7].key).toBe(".2/.$y")
		expect(mapped[8].type).toBe("hr")
		expect(mapped[8].key).toBe(".2/.6")
		expect(mapped[9].type).toBe("span")
		expect(mapped[9].key).toBe(".$b/.$x")
		expect(mapped[10].type).toBe("span")
		expect(mapped[10].key).toBe(".$b/.$y")
		expect(mapped[11].type).toBe("div")
		expect(mapped[11].key).toBe(".$b/.$b")
		expect(mapped[12].type).toBe("div")
		expect(mapped[12].key).toBe(".$b/.$z")
		expect(mapped[13].type).toBe("hr")
		expect(mapped[13].key).toBe(".$b/.6")
		expect(mapped[14].type).toBe("span")
		expect(mapped[14].key).toBe(".4/.$x")
		expect(mapped[15].type).toBe("span")
		expect(mapped[15].key).toBe(".4/.$y")
		expect(mapped[16].type).toBe("p")
		expect(mapped[16].key).toBe(".4/.4")
		expect(mapped[17].type).toBe("p")
		expect(mapped[17].key).toBe(".4/.$z")
		expect(mapped[18].type).toBe("hr")
		expect(mapped[18].key).toBe(".4/.6")
	end)
	describe("with children as a keyed table", function()
		it("should flatten to an array", function()
			expect(v.Children.toArray({
				a = v.createElement("div", nil),
				b = v.createElement("div", nil)
			})).toEqual({ v.createElement("div", {
					key = ".1"
				}), v.createElement("div", {
					key = ".2"
				}) })
			expect(v.Children.toArray({
				a = v.createElement("div", nil),
				b = {
					c = v.createElement("div", nil),
					d = v.createElement("div", nil)
				}
			})).toEqual({ v.createElement("div", {
					key = ".1"
				}), v.createElement("div", {
					key = ".2:1"
				}), v.createElement("div", {
					key = ".2:2"
				}) })
		end)
		it("should count children correctly", function()
			expect(v.Children.count({
				a = v.createElement("div", nil),
				b = v.createElement("div", nil),
				c = v.createElement("div", nil)
			})).toBe(3)
			expect(v.Children.count({
				a = v.createElement("div", nil),
				b = {
					c = v.createElement("div", nil),
					d = v.createElement("div", nil)
				},
				e = { v.createElement("div", nil), v.createElement("div", nil) }
			})).toEqual(5)
		end)
		it("should apply function to each child with forEach", function()
			local mockImplementation = jest.fn().mockImplementation(function(p, _)
				return p
			end)
			local element = v.createElement("div")
			local element2 = v.createElement("span")
			local element3 = v.createElement("p")
			local element4 = v.createElement("div", nil, {
				a = element,
				b = element2,
				c = element3
			})
			v.Children.forEach(element4.props.children, mockImplementation, {})

			-- equivalent calls inferred from this helper; original call sites unknown
			local function assertCalls()
				expect(mockImplementation).toHaveBeenCalledTimes(3)
				mockImplementation.mockClear()
			end

			assertCalls() -- equivalent call inferred; original call site unknown
		end)
		it("should map each child with map", function()
			local mockImplementation = jest.fn().mockImplementation(function(p, _)
				return p.type
			end)
			local element = v.createElement("div")
			local element2 = v.createElement("span")
			local element3 = v.createElement("p")
			local element4 = v.createElement("div", nil, {
				a = element,
				b = element2,
				c = element3
			})
			local mapped = v.Children.map(element4.props.children, mockImplementation, {})

			local function assertCalls()
				expect(mockImplementation).toHaveBeenCalledTimes(3)
				expect(#mapped).toEqual(3)
				expect(table.find(mapped, "div")).toBeDefined()
				expect(table.find(mapped, "span")).toBeDefined()
				expect(table.find(mapped, "p")).toBeDefined()
				mockImplementation.mockClear()
			end

			assertCalls()
		end)
	end)
	describe("with fragments enabled", function()
		it("warns for keys for arrays of elements in a fragment", function()
			local extended = v.Component:extend("ComponentReturningArray")

			function extended:render()
				return { v.createElement("Frame", nil), v.createElement("Frame", nil) }
			end

			expect(function()
				return v2.renderIntoDocument(v.createElement(extended, nil))
			end).toErrorDev([[
Warning: Each child in a list should have a unique "key" prop. See https://reactjs.org/link/warning-keys for more information.
    in ComponentReturningArray (at **)]])
		end)
		it("does not warn when there are keys on  elements in a fragment", function()
			local extended = v.Component:extend("ComponentReturningArray")

			function extended:render()
				return { v.createElement("Frame", {
						key = "foo"
					}), v.createElement("Frame", {
						key = "bar"
					}) }
			end

			v2.renderIntoDocument(v.createElement(extended, nil))
		end)
		it("warns for keys for arrays at the top level", function()
			expect(function()
				return v2.renderIntoDocument({ v.createElement("Frame", nil), v.createElement("Frame", nil) })
			end).toErrorDev("Warning: Each child in a list should have a unique \"key\" prop. See https://reactjs.org/link/warning-keys for more information.", {
				withoutStack = true
			})
		end)
	end)
end)