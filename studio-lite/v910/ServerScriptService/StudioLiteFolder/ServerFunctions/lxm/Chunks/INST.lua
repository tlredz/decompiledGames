require(script.Parent.Parent.Types)
local BasicTypes = require(script.Parent.Parent.BasicTypes)

local function VirtualInstance(classId: number, className: string, ref: number)
	return {
		ClassId = classId,
		ClassName = className,
		Ref = ref,
		Properties = {},
		Children = {}
	}
end

local function INST(p, p2)
	local data = p.Data
	local number = data:readNumber("<I4")
	local string = BasicTypes.String(data)
	local _ = data:read() == "\1"
	local number2 = data:readNumber("<I4")
	local refArray = BasicTypes.RefArray(data, number2)
	p2.ClassRefs[number] = {
		Name = string,
		Sizeof = number2,
		Refs = refArray
	}

	for _, v in refArray do
		p2.InstanceRefs[v] = VirtualInstance(number, string, v)
	end
end

return INST