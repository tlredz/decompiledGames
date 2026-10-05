local HttpService = game:GetService("HttpService")
local VehicleUtil = {}

function VehicleUtil.GenerateVehicleUuid(p)
	return (("%s-%s"):format(p.Name, HttpService:GenerateGUID(false)))
end

function VehicleUtil.GenerateVehicleName(p, instance)
	local v = p.Name .. "Car"
	instance:SetAttribute("vehicleName", instance.Name)
	return v
end

function VehicleUtil.ParseColorPartNames(value: string)
	local result = {}

	for _, v in string.split(value, ",") do
		local v2 = string.gsub(v, "^%s*(.-)%s*$", "%1")

		if v2 ~= "" then
			table.insert(result, v2)
		end
	end

	return result
end

return VehicleUtil