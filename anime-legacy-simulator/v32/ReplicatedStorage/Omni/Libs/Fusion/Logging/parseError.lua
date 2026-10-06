local parent = script.Parent.Parent
require(parent.Types)

local function parseError(raw: string)
	return {
		type = "Error",
		raw = raw,
		message = raw:gsub("^.+:%d+:%s*", ""),
		trace = debug.traceback(nil, 2)
	}
end

return parseError