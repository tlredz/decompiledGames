local v = {
	List = {}
}

function v.GetNextMapName(p: string)
	local v2 = v.List[p]

	if not v2 then
		return
	end

	local index = v2.Index

	if not index then
		return
	end

	for k, v3 in v.List do
		if v3.Index == index + 1 then
			return k
		end
	end

	return nil
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local list = v.List
	local name = moduleScript.Name
	local module = require(moduleScript)
	list[name] = module
end

for k, v2 in v.List do
	v2.Name = k
end

return table.freeze(v)