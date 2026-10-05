local option = require(script.Parent:WaitForChild("option"))
local v = {
	__tostring = function(items)
		local v2 = {}
		local flag = true

		for k, _ in items do
			if type(k) == "number" then
				continue
			end

			flag = false
			break
		end

		for k, item in items do
			if flag then
				item:inspect(function(p)
					table.insert(v2, (tostring(p)))
				end)
			else
				local v4 = k
				item:inspect(function(p)
					table.insert(v2, tostring(v4) .. ": " .. tostring(p))
				end)
			end
		end

		return "{" .. table.concat(v2, ", ") .. "}"
	end,
	__index = function(p, p2)
		local v2 = rawget(p, p2)

		if v2 == nil then
			return option.none()
		end

		return v2
	end,
	__newindex = function(p, p2, object)
		if object == nil then
			object = option.none()
		end

		assert(object and option.isOption(object), "value must be an Option, received:" .. tostring(object))

		if object:isNone() then
			rawset(p, p2, nil)
		else
			rawset(p, p2, object)
		end
	end
}
local OptionTable = {}

function OptionTable.empty()
	return (setmetatable({}, v))
end

function OptionTable.from(list)
	local self = setmetatable({}, v)

	for k, v2 in list do
		self[k] = option.from(v2)
	end

	if table.isfrozen(list) then
		table.freeze(self)
	end

	return self
end

return OptionTable