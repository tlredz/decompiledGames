local boolean = require(script.Parent:WaitForChild("boolean"))
local collections = require(script.Parent:WaitForChild("collections"))
local console = require(script.Parent:WaitForChild("console"))
local math = require(script.Parent:WaitForChild("math"))
local number = require(script.Parent:WaitForChild("number"))
local string = require(script.Parent:WaitForChild("string"))
local symbolluau = require(script.Parent:WaitForChild("symbol-luau"))
local timers = require(script.Parent:WaitForChild("timers"))
require(script.Parent:WaitForChild("es7-types"))
local AssertionError = require(script:WaitForChild("AssertionError"))
local Error = require(script:WaitForChild("Error"))
require(script:WaitForChild("Promise"))
local extends = require(script:WaitForChild("extends"))
local instanceof = require(script.Parent:WaitForChild("instance-of"))
return {
	Array = collections.Array,
	AssertionError = AssertionError,
	Boolean = boolean,
	console = console,
	Error = Error,
	extends = extends,
	instanceof = instanceof,
	Math = math,
	Number = number,
	Object = collections.Object,
	Map = collections.Map,
	coerceToMap = collections.coerceToMap,
	coerceToTable = collections.coerceToTable,
	Set = collections.Set,
	WeakMap = collections.WeakMap,
	String = string,
	Symbol = symbolluau,
	setTimeout = timers.setTimeout,
	clearTimeout = timers.clearTimeout,
	setInterval = timers.setInterval,
	clearInterval = timers.clearInterval,
	util = {
		inspect = collections.inspect
	}
}