local v = {
	"yes",
	"y",
	"true",
	"t",
	"✅"
}
local EquipmentSearch = {
	extractNumber = function(value: string)
		local match = value:match("[%-]?[%d%.]+")
		return match and tonumber(match)
	end,
	parseComparison = function(value: string)
		local match, v2 = value:match("^([><=!]+)%s*([%-]?[%d%.]+)")

		if not (match and v2) then
			return nil
		end

		local v3 = tonumber(v2)

		if not v3 then
			return nil
		end

		if match == ">" then
			return function(p)
				return v3 < p
			end
		elseif match == ">=" then
			return function(p)
				return v3 <= p
			end
		elseif match == "<" then
			return function(p)
				return p < v3
			end
		elseif match == "<=" then
			return function(p)
				return p <= v3
			end
		end

		if match == "=" or match == "==" then
			return function(p)
				return p == v3
			end
		end

		if match == "!=" or match == "~=" then
			return function(p)
				return p ~= v3
			end
		end

		return nil
	end,
	parseBoolean = function(p: string)
		return table.find(v, p) ~= nil
	end
}

function EquipmentSearch.buildQueries(value: string, callback)
	local lower = (value or ""):match("^%s*(.-)%s*$"):lower()

	if lower == "" then
		return nil
	end

	local result = {}

	for k in lower:gmatch("[^,]+") do
		local match = k:match("^%s*(.-)%s*$")

		if not (match and match ~= "") then
			continue
		end

		local match2, v2 = match:match("^(%w+):%s*(.+)$")

		if match2 then
			if callback then
				match2 = callback(match2)
			end

			table.insert(result, {
				key = match2,
				val = v2,
				compare = EquipmentSearch.parseComparison(v2),
				raw = match
			})
		else
			table.insert(result, {
				raw = match
			})
		end
	end

	if #result == 0 then
		return nil
	end

	return result
end

return EquipmentSearch