local parent = script.Parent.Parent.Parent
local JestGlobals = require(parent.Dev.JestGlobals)
local beforeEach = JestGlobals.beforeEach
local expect = JestGlobals.expect
local it = JestGlobals.it
local jest = JestGlobals.jest
local v = nil
beforeEach(function()
	jest.resetModules()
	local formatProdErrorMessage = require(script.Parent.Parent.formatProdErrorMessage)
	v = formatProdErrorMessage
end)
it("should throw with the correct number of `%s`s in the URL", function()
	expect(v(124, "foo", "bar")).toEqual("Minified React error #124; visit https://reactjs.org/docs/error-decoder.html?invariant=124&args[]=foo&args[]=bar for the full message or use the non-minified dev environment for full errors and additional helpful warnings.")
	expect(v(20)).toEqual("Minified React error #20; visit https://reactjs.org/docs/error-decoder.html?invariant=20 for the full message or use the non-minified dev environment for full errors and additional helpful warnings.")
	expect(v(77, "<div>", "&?bar")).toEqual("Minified React error #77; visit https://reactjs.org/docs/error-decoder.html?invariant=77&args[]=%3Cdiv%3E&args[]=%26%3Fbar for the full message or use the non-minified dev environment for full errors and additional helpful warnings.")
end)