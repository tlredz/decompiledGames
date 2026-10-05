local maybeFreeze = require(script.Parent.Parent.utils.maybeFreeze)

local function removeValue(items, p)
	local v = {}
	local flag = false

	for k, item in items do
		if item == p then
			flag = true
		else
			v[k] = item
		end
	end

	if flag then
		return (maybeFreeze(v))
	end

	return items
end

return removeValue