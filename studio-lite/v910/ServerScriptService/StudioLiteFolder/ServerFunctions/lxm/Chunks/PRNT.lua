require(script.Parent.Parent.Types)
local BasicTypes = require(script.Parent.Parent.BasicTypes)

local function PRNT(object, p)
	local data = object.Data

	if data:read() ~= "\0" then
		object:Error("Invalid PRNT version")
	end

	local number = data:readNumber("<I4")
	local refArray = BasicTypes.RefArray(data, number)
	local refArray2 = BasicTypes.RefArray(data, number)

	for i = 1, number do
		local v = refArray[i]
		local v2 = refArray2[i]
		local instanceRef = p.InstanceRefs[v]
		local v3

		if v2 >= 0 then
			v3 = p.InstanceRefs[v2]
		end

		if not instanceRef then
			object:Error((`Could not parent {v} to {v2} because child {v} was nil`))
		end

		if v2 >= 0 and not v3 then
			print((`Could not parent {instanceRef} to {v2} because parent {v2} was nil`))
		end

		local v4

		if v3 then
			v4 = v3.Children
		else
			v4 = p.Tree
		end

		table.insert(v4, instanceRef)
	end
end

return PRNT