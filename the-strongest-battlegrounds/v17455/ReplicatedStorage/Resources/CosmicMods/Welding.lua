local Debris = game:GetService("Debris")
local v = { "Weld", "WeldConstraint", "Motor6D" }

local function CreateWeld(className, p, part, C0, name, p2)
	if table.find(v, className) == nil then
		error("WELD TYPE", className, "IS NOT FOUND")
	end

	local instance = Instance.new(className)
	instance.Parent = p
	instance.Part0 = p
	instance.Part1 = part
	instance.Name = name

	if className ~= "WeldConstraint" and C0 ~= nil then
		instance.C0 = C0
	end

	if p2 ~= nil then
		Debris:AddItem(instance, p2)
	end

	return instance
end

local Welding = {}

function Welding.NormalWeld(p, part, cframe: CFrame, name: string, p4: number)
	return (CreateWeld("Weld", p, part, cframe, name, p4))
end

function Welding.WeldConstraint(p, part, name: string, p4: number)
	return (CreateWeld("WeldConstraint", p, part, nil, name, p4))
end

function Welding.Motor6D(p, part, cframe: CFrame, name: string, p4: number)
	return (CreateWeld("Motor6D", p, part, cframe, name, p4))
end

return Welding