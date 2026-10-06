local v = {
	ValidateNumber = function(self, value: number)
		return typeof(value) == "number" and math.isfinite(value)
	end,
	ValidateString = function(self, value: string)
		return typeof(value) == "string" and utf8.len(value) ~= nil and not value:find("[%c\\]")
	end
}

function v:ValidateVector(data)
	if typeof(data) == "Vector2" then
		return v:ValidateNumber(data.X) and v:ValidateNumber(data.Y)
	end

	if typeof(data) == "Vector3" then
		return v:ValidateNumber(data.X) and v:ValidateNumber(data.Y) and v:ValidateNumber(data.Z)
	end

	return true
end

function v:ValidateCFrame(cframe: CFrame)
	if typeof(cframe) ~= "CFrame" then
		return true
	end

	local position = cframe.Position

	if v:ValidateVector(position) and v:ValidateVector(cframe.XVector) and v:ValidateVector(cframe.YVector) and v:ValidateVector(cframe.ZVector) then
		return not (position.Y <= workspace.FallenPartsDestroyHeight * 0.75)
	end

	return false
end

function v:ValidateTable(items, value: number?, p)
	if typeof(items) ~= "table" then
		return true
	end

	local v2 = (value or 0) + 1

	if v2 > 10 then
		return false
	end

	local v3 = p or { 0 }

	for k, item in items do
		v3[1] += 1

		if v3[1] > 4096 or not (v:Validate(k, v2, v3) and v:Validate(item, v2, v3)) then
			return false
		end
	end

	return true
end

function v.CheckType(_, p: string, p2)
	return typeof(p2) == p
end

function v:Validate(value, p: number?, p2)
	if typeof(value) == "string" then
		return v:ValidateString(value)
	end

	if typeof(value) == "number" then
		return v:ValidateNumber(value)
	end

	if typeof(value) == "Vector2" or typeof(value) == "Vector3" then
		return v:ValidateVector(value)
	end

	if typeof(value) == "CFrame" then
		return v:ValidateCFrame(value)
	end

	if typeof(value) == "table" then
		return v:ValidateTable(value, p, p2)
	end

	return true
end

return table.freeze(v)