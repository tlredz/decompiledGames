require(script.Parent.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Parent.Utilities.Output)
local v = {
	kind = "all",
	value = nil
}
table.freeze(v)
return function(...)
	Output.warnAssert(select("#", ...) == 0, "incorrect number of arguments passed to player container")
	return v
end