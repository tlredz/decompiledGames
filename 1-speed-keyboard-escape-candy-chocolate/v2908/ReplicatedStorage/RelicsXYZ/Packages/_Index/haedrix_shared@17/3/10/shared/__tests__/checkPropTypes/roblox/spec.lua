local parent = script.Parent.Parent.Parent
local v = nil
local v2 = nil
local v3 = nil
local ReactGlobals = require(parent.ReactGlobals)
local JestGlobals = require(parent.Dev.JestGlobals)
local afterEach = JestGlobals.afterEach
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local describe = JestGlobals.describe
local it = JestGlobals.it
local jest = JestGlobals.jest
local LuauPolyfill = require(parent.LuauPolyfill)
local error2 = LuauPolyfill.Error
describe("tests propTypes and validateProps behavior", function()
	beforeEach(function()
		jest.resetModules()
		local ReactNoop = require(parent.Dev.ReactNoop)
		v2 = ReactNoop
		local Scheduler = require(parent.Dev.Scheduler)
		v3 = Scheduler
		local React = require(parent.Dev.React)
		v = React
	end)
	it("propTypes defined, returns error", function()
		local extended = v.Component:extend("div")
		extended.propTypes = {
			myProp = function(_, _, _)
				return error2("no no no no no")
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
				expect(v3).toFlushWithoutYielding()
			end)
		end).toWarnDev("no no no no no")
	end)
	it("propTypes defined, returns nil", function()
		local extended = v.Component:extend("Foo")
		extended.propTypes = {
			myProp = function(_, _, _)
				return nil
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		v2.render(v.createElement(extended, {
			myProp = "hello"
		}))
		expect(v3).toFlushWithoutYielding()
	end)
	it("validateProps defined, returns false", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return false, "no no no no no"
		end

		function extended.render(_)
			return v.createElement("div")
		end

		local function testValidation()
			v2.render(v.createElement(extended, {
				myProp = "hello"
			}))
			expect(v3).toFlushWithoutYielding()
		end

		if ReactGlobals.__DEV__ then
			expect(testValidation).toThrow("no no no no no")
		else
			expect(testValidation).never.toThrow()
		end
	end)
	it("validateProps defined, returns true", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return true
		end

		function extended.render(_)
			return v.createElement("div")
		end

		v2.render(v.createElement(extended, {
			myProp = "hello"
		}))
		expect(v3).toFlushWithoutYielding()
	end)
	it("warning when both methods are defined", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return true
		end

		extended.propTypes = {
			myProp = function(_, _, _)
				return nil
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
				expect(v3).toFlushWithoutYielding()
			end)
		end).toWarnDev("You've defined both propTypes and validateProps on Foo", {
			withoutStack = true
		})
	end)
	it("validateProps fails, propTypes fails", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return false, "no no no no no"
		end

		extended.propTypes = {
			myProp = function(_, _, _)
				error(error2("no no no no no"))
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		local function testValidation()
			expect(function()
				v2.act(function()
					v2.render(v.createElement(extended, {
						myProp = "hello"
					}))
					expect(v3).toFlushWithoutYielding()
				end)
			end).toWarnDev("You've defined both propTypes and validateProps on Foo", {
				withoutStack = 2
			})
		end

		if ReactGlobals.__DEV__ then
			expect(testValidation).toThrow("no no no no no")
		else
			expect(testValidation).never.toThrow()
		end
	end)
	it("validateProps succeeds, propTypes fails", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return true
		end

		extended.propTypes = {
			myProp = function(_, _, _)
				error(error2("no no no no no"))
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
				expect(v3).toFlushWithoutYielding()
			end)
		end).toWarnDev({ "You've defined both propTypes and validateProps on Foo", "no no no no no" }, {
			withoutStack = 1
		})
	end)
	it("validateProps fails, propTypes succeeds", function()
		local extended = v.Component:extend("Foo")

		function extended.validateProps(_)
			return false, "no no no no no"
		end

		extended.propTypes = {
			myProp = function(_, _, _)
				return nil
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		local function testValidation()
			expect(function()
				v2.act(function()
					v2.render(v.createElement(extended, {
						myProp = "hello"
					}))
					expect(v3).toFlushWithoutYielding()
				end)
			end).toWarnDev("You've defined both propTypes and validateProps on Foo", {
				withoutStack = 2
			})
		end

		if ReactGlobals.__DEV__ then
			expect(testValidation).toThrow("no no no no no")
		else
			expect(testValidation).never.toThrow()
		end
	end)
	it("bad propTypes method", function()
		local extended = v.Component:extend("Foo")
		extended.propTypes = {
			myProp = function(_, _, _)
				return "nil"
			end
		}

		function extended.render(_)
			return v.createElement("div")
		end

		expect(function()
			v2.act(function()
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
				expect(v3).toFlushWithoutYielding()
			end)
		end).toErrorDev({ "Foo: type specification of prop `myProp` is invalid; the type checker function must return `nil` or an `Error` but returned a string. You may have forgotten to pass an argument to the type checker creator (arrayOf, instanceOf, objectOf, oneOf, oneOfType, and shape all require an argument)." })
	end)
	it("bad validateProps method", function()
		local extended = v.Component:extend("Foo")

		function extended.render(_)
			return v.createElement("div")
		end

		expect(v3).toFlushWithoutYielding()
		expect(function()
			v2.act(function()
				extended.validateProps = "this is a string"
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
			end)
		end).toErrorDev({ [[
validateProps must be a function, but it is a string.
Check the definition of the component "Foo".]] }, {
			withoutStack = 1
		})
	end)
	describe("__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__", function()
		beforeEach(function(p)
			p.oldValidate = ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__
			ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ = true
		end)
		afterEach(function(p)
			ReactGlobals.__DISABLE_ALL_WARNINGS_EXCEPT_PROP_VALIDATION__ = p.oldValidate
		end)
		it("validateProps defined, returns false", function()
			local extended = v.Component:extend("Foo")

			function extended.validateProps(_)
				return false, "no no no no no"
			end

			function extended.render(_)
				return v.createElement("div")
			end

			local function testValidation()
				v2.render(v.createElement(extended, {
					myProp = "hello"
				}))
				expect(v3).toFlushWithoutYielding()
			end

			if ReactGlobals.__DEV__ then
				expect(testValidation).toThrow("no no no no no")
			else
				expect(testValidation).never.toThrow()
			end
		end)
	end)
end)