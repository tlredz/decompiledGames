require(script.Parent.types)
local createAsyncRemote = require(script.createAsyncRemote)
local createRemote = require(script.createRemote)
local createRemotes

createRemotes = function(remotes, p: string?)
	local v = not p and "" or `{p}.`
	local result = {}

	for k, item in remotes do
		local v2

		if item.type == "namespace" then
			v2 = createRemotes(item.remotes, v .. k)
		elseif item.type == "event" then
			v2 = createRemote(v .. k, item)
		elseif item.type == "function" then
			v2 = createAsyncRemote(v .. k, item)
		else
			v2 = error((`Invalid remote type "{item.type}"`))
		end

		result[k] = v2
	end

	return result
end

return {
	createRemotes = createRemotes
}