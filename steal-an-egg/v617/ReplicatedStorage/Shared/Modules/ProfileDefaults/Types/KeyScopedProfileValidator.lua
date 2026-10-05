local SchemaFields = require(script.Parent.SchemaFields)
return function(p, p2)
	if typeof(p) ~= "table" then
		return false, "a profile update has to be a table"
	end

	local v = typeof(p2) ~= "table"

	for k in SchemaFields do
		local schemaField = SchemaFields[k]
		local v2 = p[k]

		if not (schemaField ~= nil and (v or v2 ~= p2[k])) then
			continue
		end

		local v3, v4 = schemaField(v2)

		if not v3 then
			return false, (`profile field {k} was refused: {v4 or "shape does not match"}`)
		end
	end

	return true
end