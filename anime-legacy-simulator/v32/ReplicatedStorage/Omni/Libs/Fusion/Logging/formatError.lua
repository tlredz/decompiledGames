local parent = script.Parent.Parent
require(parent.Types)
local messages = require(parent.Logging.messages)

local function formatError(p, p2: string, trace, ...)
	local v

	if typeof(trace) == "table" then
		v = trace
	end

	if typeof(trace) == "table" then
		trace = trace.trace
	end

	local message = messages[p2]
	local v2

	if message == nil then
		v2 = "unknownMessage"
		message = messages[v2]
	else
		v2 = p2
	end

	local formatted = message:format(...)
	local v3

	if v == nil then
		v3 = formatted:gsub("ERROR_MESSAGE", p2)
	else
		v3 = formatted:gsub("ERROR_MESSAGE", v.message)

		if v.context ~= nil then
			v3 ..= ` ({v.context})`
		end
	end

	local formatted2 = `[Fusion] {v3} \nID: {v2}`

	if p ~= nil and p.policies.allowWebLinks then
		formatted2 ..= `\nLearn more: https://elttob.uk/Fusion/0.3/api-reference/general/errors/#{v2:lower()}`
	end

	if trace ~= nil then
		formatted2 ..= ` \n---- Stack trace ----\n{trace}`
	end

	return formatted2:gsub("\n", "\n    ")
end

return formatError