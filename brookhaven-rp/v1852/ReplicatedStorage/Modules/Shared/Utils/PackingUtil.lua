local PackingUtil = {}

function PackingUtil.PackRaceRecordedData(list)
	local v = {}

	for i = 1, #list do
		local position = list[i].CFrame.Position
		local eulerAnglesXYZ, v2, v3 = list[i].CFrame:ToEulerAnglesXYZ()
		local dt = list[i].dt
		table.insert(
			v,
			(string.format(
				"%f,%f,%f,%d,%d,%d,%f",
				position.X,
				position.Y,
				position.Z,
				math.round(eulerAnglesXYZ * 100),
				math.round(v2 * 100),
				math.round(v3 * 100),
				dt
			))
		)
	end

	return (table.concat(v, ";"))
end

function PackingUtil.UnpackRaceRecordedData(value: string, p: number?, p2: number?)
	local v = string.split(value, ";")
	local total = 0
	local result = {}

	for i, v2 in ipairs(v) do
		if v2 == "" then
			continue
		end

		local v3 = string.split(v2, ",")

		if p then
			v3[2] = tonumber(v3[2]) + p
		end

		local vector = Vector3.new(tonumber(v3[1]), tonumber(v3[2]), (tonumber(v3[3])))
		local cframe = CFrame.Angles(tonumber(v3[4]) / 100, tonumber(v3[5]) / 100, tonumber(v3[6]) / 100)
		local dt = tonumber(v3[7])

		if p2 and i <= p2 then
			total += dt
		end

		table.insert(result, {
			CFrame = CFrame.new(vector) * cframe,
			dt = dt
		})
	end

	return result, total
end

function PackingUtil.PackCFrame(list)
	local v = {}

	for i = 1, #list do
		local position = list[i].CFrame.Position
		local eulerAnglesXYZ, v2, v3 = list[i].CFrame:ToEulerAnglesXYZ()
		table.insert(
			v,
			(string.format(
				"%f,%f,%f,%d,%d,%d",
				position.X,
				position.Y,
				position.Z,
				math.round(eulerAnglesXYZ * 100),
				math.round(v2 * 100),
				(math.round(v3 * 100))
			))
		)
	end

	return (table.concat(v, ";"))
end

function PackingUtil.UnpackCFrame(value: string, p: number?)
	local v = string.split(value, ";")
	local result = {}

	for i, v2 in ipairs(v) do
		if v2 == "" then
			continue
		end

		local v3 = string.split(v2, ",")
		local vector = Vector3.new(tonumber(v3[1]), tonumber(v3[2]), (tonumber(v3[3])))
		local cframe = CFrame.Angles(tonumber(v3[4]) / 100, tonumber(v3[5]) / 100, tonumber(v3[6]) / 100)

		if not (p and i < p) then
			table.insert(result, {
				CFrame = CFrame.new(vector, vector + cframe.LookVector)
			})
		end
	end

	return result
end

return PackingUtil