local PropertyOverlayResolve = {
	getPropertyNameCandidates = function(value: string)
		local v = { value }
		local v2 = {
			[value] = true
		}

		local function add(p: string?)
			if p == nil or p == "" or v2[p] == true then
				return
			end

			v2[p] = true
			table.insert(v, p)
		end

		local v3 = string.match(value, "^(%d+)_Mansion$")

		if v3 == nil then
			local v4 = string.match(value, "^(%d+)_House$") or string.match(value, "^(%d+)_Apartment$") or string.match(
				value,
				"^(%d+)_Motel$"
			) or string.match(value, "^(%d+)_MotelAgency$")

			if v4 == nil then
				return v
			end

			if v4 ~= nil and v4 ~= "" and v2[v4] ~= true then
				v2[v4] = true
				table.insert(v, v4)
			end

			local v5 = tonumber(v4)

			if v5 == nil then
				return v
			end

			local v6 = tostring(v5)

			if v6 ~= nil and v6 ~= "" and v2[v6] ~= true then
				v2[v6] = true
				table.insert(v, v6)
			end

			local v7 = string.format("%02d", v5)

			if v7 ~= nil and v7 ~= "" and v2[v7] ~= true then
				v2[v7] = true
				table.insert(v, v7)
			end

			local v8 = string.format("%03d", v5)

			if v8 ~= nil and v8 ~= "" and v2[v8] ~= true then
				v2[v8] = true
				table.insert(v, v8)
			end

			local v9 = string.format("%04d", v5)

			if v9 ~= nil and v9 ~= "" and v2[v9] ~= true then
				v2[v9] = true
				table.insert(v, v9)
			end

			local v10 = string.format("%05d", v5)

			if v10 ~= nil and v10 ~= "" then
				if v2[v10] == true then
					return v
				end

				v2[v10] = true
				table.insert(v, v10)
			end

			return v
		else
			local v4 = tonumber(v3)

			if v4 == nil then
				return v
			end

			local v5 = string.format("%05d", v4)

			if v5 ~= nil and v5 ~= "" and v2[v5] ~= true then
				v2[v5] = true
				table.insert(v, v5)
			end

			local v6 = string.format("%04d", v4)

			if v6 ~= nil and v6 ~= "" and v2[v6] ~= true then
				v2[v6] = true
				table.insert(v, v6)
			end

			local v7 = string.format("%03d", v4)

			if v7 ~= nil and v7 ~= "" and v2[v7] ~= true then
				v2[v7] = true
				table.insert(v, v7)
			end

			if v3 ~= nil and v3 ~= "" and v2[v3] ~= true then
				v2[v3] = true
				table.insert(v, v3)
			end

			local v8 = string.format("%02d", v4)

			if v8 ~= nil and v8 ~= "" and v2[v8] ~= true then
				v2[v8] = true
				table.insert(v, v8)
			end

			local v9 = tostring(v4)

			if not (v9 ~= nil and v9 ~= "") then
				return v
			end

			if v2[v9] == true then
				return v
			end

			v2[v9] = true
			table.insert(v, v9)
			return v
		end
	end
}

function PropertyOverlayResolve.findInFolder(instance, p: string, formatString: string?)
	if instance == nil then
		return nil
	end

	for _, childName in PropertyOverlayResolve.getPropertyNameCandidates(p) do
		if formatString ~= nil then
			childName = string.format(formatString, childName)
		end

		local child = instance:FindFirstChild(childName)

		if child ~= nil then
			return child
		end
	end

	return nil
end

return PropertyOverlayResolve