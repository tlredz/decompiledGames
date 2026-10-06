local enums = {}
local Enum = {
	enums = enums,
	createEnum = function(value, items)
		assert(typeof(value) == "string", "bad argument #1 - enums must be created using a string name!")
		assert(typeof(items) == "table", "bad argument #2 - enums must be created using a table!")
		assert(not enums[value], ("enum '%s' already exists!"):format(value))
		local v2 = {}
		local v3 = {}
		local v4 = {}
		local v5 = {
			getName = function(p)
				local v6 = tostring(p)
				local v7 = v3[v6] or v4[v6]

				if v7 then
					return items[v7][1]
				end
			end,
			getValue = function(p)
				local v6 = tostring(p)
				local v7 = v2[v6] or v4[v6]

				if v7 then
					return items[v7][2]
				end
			end,
			getProperty = function(p)
				local v6 = tostring(p)
				local v7 = v2[v6] or v3[v6]

				if v7 then
					return items[v7][3]
				end
			end
		}
		local result = {}

		for k, item in pairs(items) do
			assert(
				typeof(item) == "table",
				("bad argument #2.%s - details must only be comprised of tables!"):format(k)
			)
			local v6 = item[1]
			assert(typeof(v6) == "string", ("bad argument #2.%s.1 - detail name must be a string!"):format(k))
			assert(typeof(not v2[v6]), ("bad argument #2.%s.1 - the detail name '%s' already exists!"):format(k, v6))
			assert(typeof(not v5[v6]), ("bad argument #2.%s.1 - that name is reserved."):format(k, v6))
			v2[tostring(v6)] = k
			local v7 = item[2]
			local v8 = tostring(v7)
			assert(typeof(not v3[v8]), ("bad argument #2.%s.2 - the detail value '%s' already exists!"):format(k, v8))
			v3[v8] = k
			local v9 = item[3]

			if v9 then
				assert(
					typeof(not v4[v9]),
					("bad argument #2.%s.3 - the detail property '%s' already exists!"):format(k, (tostring(v9)))
				)
				v4[tostring(v9)] = k
			end

			result[v6] = v7
			setmetatable(result, {
				__index = function(_, p)
					return v5[p]
				end
			})
		end

		enums[value] = result
		return result
	end,
	getEnums = function()
		return enums
	end
}
local createEnum = Enum.createEnum

for _, moduleScript in pairs(script:GetChildren()) do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	createEnum(moduleScript.Name, module)
end

return Enum