local ReplicatedStorage = game:GetService("ReplicatedStorage")
local clone = nil
local v = nil

local function parseTracks(value: string)
	local v2 = string.split(value, ", ")
	local v3, v4 = string.match(v2[#v2], "^(.*) and (.+)$")

	if v3 ~= nil then
		v2[#v2] = v3
		table.insert(v2, v4)
	end

	local v5, name = string.match(v2[1], "^%+(%d+) (.+)$")

	if v5 == nil then
		return nil
	end

	local v7

	if #v2 > 1 then
		v7 = string.match(v2[2], "^%+%d+ ") ~= nil
	else
		v7 = false
	end

	local result = {
		{
			name = name,
			amount = tonumber(v5)
		}
	}

	for i = 2, #v2 do
		if v7 then
			local v8, name2 = string.match(v2[i], "^%+(%d+) (.+)$")

			if v8 == nil then
				return nil
			else
				table.insert(result, {
					name = name2,
					amount = tonumber(v8)
				})
			end
		else
			table.insert(result, {
				name = v2[i],
				amount = result[1].amount
			})
		end
	end

	return result
end

local function formatTracks(list)
	local v2 = true

	for _, v4 in list do
		if v4.amount == list[1].amount then
			continue
		end

		v2 = false
		break
	end

	local v4 = {}

	for k, v5 in list do
		local v6

		if v2 and k > 1 then
			v6 = v5.name
		else
			v6 = `+{v5.amount} {v5.name}`
		end

		v4[k] = v6
	end

	if #v4 == 1 then
		return v4[1]
	end

	local v5 = table.remove(v4)
	return table.concat(v4, ", ") .. " and " .. v5
end

local function combine(list)
	local result = {}
	local clones = {}
	local v2 = {}

	for _, v3 in ipairs(list) do
		local v4

		if typeof(v3) == "table" and v3.Add == "Mastery" and type(v3.Value) == "string" then
			v4 = parseTracks(v3.Value)
		end

		if v4 == nil then
			if typeof(v3) == "table" and type(v3.Value) == "number" then
				local formatted = `{v3.Icon}|{v3.Add}|{v3.Tag}`
				local v5 = clones[formatted]

				if v5 == nil then
					local clone2 = table.clone(v3)
					clones[formatted] = clone2
					table.insert(result, clone2)
				else
					v5.Value += v3.Value
					v5.Sound = v5.Sound or v3.Sound

					if type(v3.Level) == "table" then
						if type(v5.Level) == "table" then
							v5.Level = {
								From = math.min(v5.Level.From, v3.Level.From),
								To = math.max(v5.Level.To, v3.Level.To)
							}
						else
							v5.Level = v3.Level
						end
					end
				end
			else
				table.insert(result, v3)
			end
		else
			local formatted = `tracks|{v3.Icon}|{v3.Add}|{v3.Tag}`
			local clone2 = clones[formatted]

			if clone2 == nil then
				clone2 = table.clone(v3)
				clones[formatted] = clone2
				v2[clone2] = {}
				table.insert(result, clone2)
			end

			local v5 = v2[clone2]

			for _, v6 in v4 do
				local v7 = false

				for _, v9 in v5 do
					if v9.name ~= v6.name then
						continue
					end

					v9.amount += v6.amount
					v7 = true
					break
				end

				if not v7 then
					table.insert(v5, {
						name = v6.name,
						amount = v6.amount
					})
				end
			end

			clone2.Value = formatTracks(v5)
		end
	end

	return result
end

return function(p)
	if typeof(p) ~= "table" or typeof(p.Content) ~= "table" then
		return
	end

	if clone == nil then
		clone = table.clone(p.Content)
		local v2

		if typeof(p.Time) == "number" then
			v2 = p.Time
		end

		v = v2
		task.delay(0.15, function()
			local v3 = clone
			local time = v
			clone = nil
			v = nil
			ReplicatedStorage.Communication.CnC.Notifications.Notification:Fire("Currency", {
				Time = time,
				Content = combine(v3)
			})
		end)
	else
		for _, v2 in ipairs(p.Content) do
			table.insert(clone, v2)
		end

		if typeof(p.Time) == "number" then
			v = math.max(v or 0, p.Time)
		end
	end
end