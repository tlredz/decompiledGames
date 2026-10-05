local v = nil
v = {
	ts = tostring,
	tr = table.remove,
	tf = table.find,
	tins = table.insert,
	tsort = table.sort,
	tc = table.clear,
	tof = typeof,
	tabletxt = "table",
	sortFunction = function(p: string, p2: string)
		return #v.extractValue(p) < #v.extractValue(p2)
	end,
	splitString = function(value)
		local flag = false
		local v2 = nil
		local result = {}
		local v3 = ""

		for i = 1, #value do
			local v4 = value:sub(i, i)

			if v4 == "\"" or v4 == "'" then
				if flag and v4 == v2 then
					table.insert(result, v3)
					flag = false
					v2 = nil
					v3 = ""
				elseif flag then
					v3 ..= v4
				else
					if v3 ~= "" then
						table.insert(result, v3)
						v3 = ""
					end

					v2 = v4
					flag = true
				end
			elseif v4 == " " and not flag then
				if v3 ~= "" then
					table.insert(result, v3)
					v3 = ""
				end
			else
				v3 ..= v4
			end
		end

		if v3 ~= "" then
			table.insert(result, v3)
		end

		return result
	end,
	extractValue = function(data)
		if data == nil then
			return
		end

		if v.tof(data) == v.tabletxt then
			return data.Name or data.Text or data.Image or ""
		end

		return data
	end
}
return v