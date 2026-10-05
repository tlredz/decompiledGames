local v = {}
local v2 = {}
local warn2 = warn or print
local DamageInterceptors = {}

function DamageInterceptors.register(callback)
	table.insert(v, callback)
	return function()
		local index = table.find(v, callback)

		if index then
			table.remove(v, index)
		end
	end
end

function DamageInterceptors.run(p, p2)
	for _, callback in ipairs(v) do
		local success, result = pcall(callback, p, p2)

		if success then
			if type(result) == "table" and result.blocked == true then
				return result
			end
		elseif not v2[callback] then
			v2[callback] = true
			warn2("[DamageInterceptors] interceptor errored (skipped):", result)
		end
	end

	return nil
end

function DamageInterceptors.count()
	return #v
end

function DamageInterceptors._reset()
	table.clear(v)
	table.clear(v2)
end

return DamageInterceptors