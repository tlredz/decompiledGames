require(script.Parent.Types)
local v = {}
local Sources = {}

function Sources.set(p: string, vector: Vector3?, priority: number)
	local v2 = v[p]

	if vector == nil then
		v[p] = nil
		return
	end

	if v2 == nil then
		v[p] = {
			up = vector.Unit,
			priority = priority
		}
		return
	end

	v2.up = vector.Unit
	v2.priority = priority
end

function Sources.resolve()
	local v2 = nil
	local v3 = nil

	for k, v4 in v do
		if not (v2 == nil or v4.priority > v2.priority) then
			continue
		end

		v3 = k
		v2 = v4
	end

	if v2 then
		return v3, v2.up
	end

	return v3, nil
end

function Sources.clear()
	table.clear(v)
end

return Sources