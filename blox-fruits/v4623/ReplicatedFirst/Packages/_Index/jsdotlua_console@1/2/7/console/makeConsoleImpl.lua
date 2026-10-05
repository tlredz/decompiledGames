local collections = require(script.Parent.Parent:WaitForChild("collections"))
local inspect = collections.inspect
return function()
	local v2 = 0

	local function indent()
		return string.rep("  ", v2)
	end

	return {
		log = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			print(string.rep("  ", v2) .. v3)
		end,
		debug = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			print(string.rep("  ", v2) .. v3)
		end,
		info = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			print(string.rep("  ", v2) .. v3)
		end,
		warn = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			warn(string.rep("  ", v2) .. v3)
		end,
		error = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			warn(string.rep("  ", v2) .. v3)
		end,
		group = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			print(string.rep("  ", v2) .. v3)
			v2 += 1
		end,
		groupCollapsed = function(formatString, ...)
			local v3

			if typeof(formatString) == "string" then
				v3 = string.format(formatString, ...)
			else
				v3 = inspect(formatString)
			end

			print(string.rep("  ", v2) .. v3)
			v2 += 1
		end,
		groupEnd = function()
			if v2 > 0 then
				v2 -= 1
			end
		end
	}
end