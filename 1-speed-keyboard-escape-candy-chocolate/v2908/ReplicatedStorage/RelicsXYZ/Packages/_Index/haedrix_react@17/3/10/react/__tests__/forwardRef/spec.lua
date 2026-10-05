local parent = script.Parent.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
local LuauPolyfill = require(parent.LuauPolyfill)
local object = LuauPolyfill.Object
local JestGlobals = require(parent.Dev.JestGlobals)
local expect = JestGlobals.expect
local jest = JestGlobals.jest
local beforeEach = JestGlobals.beforeEach
local describe = JestGlobals.describe
local it = JestGlobals.it
local xit = JestGlobals.xit
local v = nil
local v2 = nil
local v3 = nil
describe("forwardRef", function()
	beforeEach(function()
		jest.resetModules()
		local React = require(parent.React)
		v = React
		local ReactNoopRenderer = require(parent.Dev.ReactNoopRenderer)
		v2 = ReactNoopRenderer
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
	end)
	it("should update refs when switching between children", function()
		local function FunctionComponent(p)
			local forwardedRef = p.forwardedRef
			local ref2

			if not p.setRefOnDiv then
				ref2 = forwardedRef
				forwardedRef = nil
			end

			return v.createElement("section", nil, v.createElement("div", {
				ref = forwardedRef
			}, v.createElement("TextLabel", {
				Text = "First"
			})), v.createElement("span", {
				ref = ref2
			}, v.createElement("TextLabel", {
				Text = "Second"
			})))
		end

		local forwardRef = v.forwardRef(function(p, forwardedRef)
			return v.createElement(FunctionComponent, object.assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = v.createRef()
		v2.render(v.createElement(forwardRef, {
			ref = ref,
			setRefOnDiv = true
		}))
		expect(v3).toFlushWithoutYielding()
		expect(ref.current.type).toBe("div")
		v2.render(v.createElement(forwardRef, {
			ref = ref,
			setRefOnDiv = false
		}))
		expect(v3).toFlushWithoutYielding()
		expect(ref.current.type).toBe("span")
	end)
	it("should support rendering nil", function()
		local forwardRef = v.forwardRef(function(_, _)
			return nil
		end)
		local ref = v.createRef()
		v2.render(v.createElement(forwardRef, {
			ref = ref
		}))
		expect(v3).toFlushWithoutYielding()
		expect(ref.current).toBe(nil)
	end)
	it("should support rendering nil for multiple children", function()
		local forwardRef = v.forwardRef(function(_, _)
			return nil
		end)
		local ref = v.createRef()
		v2.render(v.createElement("div", nil, v.createElement("div"), v.createElement(forwardRef, {
			ref = ref
		}), v.createElement("div")))
		expect(v3).toFlushWithoutYielding()
		expect(ref.current).toBe(nil)
	end)
	xit("should support propTypes and defaultProps", function() end)
	it("should warn if not provided a callback during creation", function()
		expect(function()
			v.forwardRef(nil)
		end).toErrorDev("forwardRef requires a render function but was given nil.", {
			withoutStack = true
		})
		expect(function()
			v.forwardRef("foo")
		end).toErrorDev("forwardRef requires a render function but was given string.", {
			withoutStack = true
		})
	end)
	it("should warn if no render function is provided", function()
		expect(v.forwardRef).toErrorDev("forwardRef requires a render function but was given nil.", {
			withoutStack = true
		})
	end)
	xit("should warn if the render function provided has propTypes or defaultProps attributes", function() end)
	it("should not warn if the render function provided does not use any parameter", function()
		v.forwardRef(function()
			return v.createElement("div", {
				ref = ""
			})
		end)
	end)
	it("should warn if the render function provided does not use the forwarded ref parameter", function()
		local function arityOfOne(p)
			return v.createElement("div", p)
		end

		expect(function()
			v.forwardRef(arityOfOne)
		end).toErrorDev("forwardRef render functions accept exactly two parameters: props and ref. Did you forget to use the ref parameter?", {
			withoutStack = true
		})
	end)
	it("should not warn if the render function provided use exactly two parameters", function()
		local function arityOfTwo(_, ref)
			v.createElement("div", {
				ref = ref
			})
		end

		v.forwardRef(arityOfTwo)
	end)
	it("should warn if the render function provided expects to use more than two parameters", function()
		local function arityOfThree(_, ref, _)
			return v.createElement("div", {
				ref = ref
			})
		end

		expect(function()
			v.forwardRef(arityOfThree)
		end).toErrorDev("forwardRef render functions accept exactly two parameters: props and ref. Any additional parameter will be undefined.", {
			withoutStack = true
		})
	end)
	xit("should honor a displayName if set on the forwardRef wrapper in warnings", function() end)
	xit("should honor a displayName in stacks if set on the inner function", function() end)
	it("should not bailout if forwardRef is not wrapped in memo", function()
		local function fn(p)
			return v.createElement("div", p)
		end

		local count = 0
		local forwardRef = v.forwardRef(function(p, forwardedRef)
			count += 1
			return v.createElement(fn, object.assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end)
		local ref = v.createRef()
		v2.render(v.createElement(forwardRef, {
			ref = ref,
			optional = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		v2.render(v.createElement(forwardRef, {
			ref = ref,
			optional = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 4 or 2)
	end)
	it("should bailout if forwardRef is wrapped in memo", function()
		local function fn(p)
			return v.createElement("div", {
				ref = p.forwardedRef
			})
		end

		local count = 0
		local memo = v.memo(v.forwardRef(function(p, forwardedRef)
			count += 1
			return v.createElement(fn, object.assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end))
		local ref = v.createRef()
		v2.render(v.createElement(memo, {
			ref = ref,
			optional = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		expect(ref.current.type).toBe("div")
		v2.render(v.createElement(memo, {
			ref = ref,
			optional = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		local ref2 = v.createRef()
		v2.render(v.createElement(memo, {
			ref = ref2,
			optional = "foo"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 4 or 2)
		expect(ref.current).toBe(nil)
		expect(ref2.current.type).toBe("div")
		v2.render(v.createElement(memo, {
			ref = ref,
			optional = "bar"
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 6 or 3)
	end)
	it("should custom memo comparisons to compose", function()
		local function fn(p)
			return v.createElement("div", {
				ref = p.forwardedRef
			})
		end

		local count = 0
		local memo = v.memo(v.forwardRef(function(p, forwardedRef)
			count += 1
			return v.createElement(fn, object.assign({}, p, {
				forwardedRef = forwardedRef
			}))
		end), function(p, p2)
			return p.a == p2.a and p.b == p2.b
		end)
		local ref = v.createRef()
		v2.render(v.createElement(memo, {
			ref = ref,
			a = 0,
			b = 0,
			c = 1
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 2 or 1)
		expect(ref.current.type).toBe("div")
		v2.render(v.createElement(memo, {
			ref = ref,
			a = 0,
			b = 1,
			c = 1
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 4 or 2)
		v2.render(v.createElement(memo, {
			ref = ref,
			a = 0,
			b = 1,
			c = 2
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 4 or 2)
		local memo2 = v.memo(memo, function(p, p2)
			return p.a == p2.a and p.c == p2.c
		end)
		v2.render(v.createElement(memo2, {
			ref = ref,
			a = 0,
			b = 0,
			c = 0
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 6 or 3)
		v2.render(v.createElement(memo2, {
			ref = ref,
			a = 0,
			b = 1,
			c = 0
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 6 or 3)
		v2.render(v.createElement(memo2, {
			ref = ref,
			a = 2,
			b = 2,
			c = 2
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 8 or 4)
		v2.render(v.createElement(memo2, {
			ref = ref,
			a = 2,
			b = 2,
			c = 3
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 8 or 4)
		local ref2 = v.createRef()
		v2.render(v.createElement(memo2, {
			ref = ref2,
			a = 2,
			b = 2,
			c = 3
		}))
		expect(v3).toFlushWithoutYielding()
		expect(count).toBe(ReactGlobals.__DEV__ and 10 or 5)
		expect(ref.current).toBe(nil)
		expect(ref2.current.type).toBe("div")
	end)
	it("warns on forwardRef(memo(...))", function()
		expect(function()
			v.forwardRef(v.memo(function(_, _)
				return nil
			end))
		end).toErrorDev({ "Warning: forwardRef requires a render function but received a `memo` component. Instead of forwardRef(memo(...)), use memo(forwardRef(...))." }, {
			withoutStack = true
		})
	end)
	it("allows new fields to be assigned on it", function()
		local forwardRef = v.forwardRef(function(_, _)
			return nil
		end)
		forwardRef.SomeEnum = {
			ValueA = 1,
			ValueB = 2
		}
		expect(forwardRef.SomeEnum).never.toBeNil()
		expect(forwardRef.SomeEnum.ValueA).toBe(1)
		expect(forwardRef.SomeEnum.ValueB).toBe(2)
	end)
end)