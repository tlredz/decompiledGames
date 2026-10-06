local Utils = {}
require(script.Parent.Types)

function Utils:ListenControl(callback)
	local __old = self.__old
	local __new = self.__new

	if __old ~= __new then
		callback(__new)
	end
end

function Utils.CreateControlStates(items, p, callback)
	local result = {}

	for k, item in pairs(items) do
		local v = p[k]

		if item.EntryType == "ControlGroup" then
			result[k] = Utils.CreateControlStates(item.Controls, v, callback)
		else
			result[k] = callback(v)
		end
	end

	return result
end

function Utils.UpdateControlStates(p, items, p2, callback)
	for k, item in pairs(items) do
		local v = p2[k]

		if item.EntryType == "ControlGroup" then
			Utils.UpdateControlStates(p[k], item.Controls, v, callback)
		else
			callback(p[k], v)
		end
	end
end

return Utils