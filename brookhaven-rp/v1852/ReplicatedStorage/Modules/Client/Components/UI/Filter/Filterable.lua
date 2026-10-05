local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Packages.Signal)
local Filterable = {}
Filterable.Name = "Filterable"

function Filterable.HasContract(p)
	if not p.FilterGamepasses then
		return false, "FilterGamepasses is not defined"
	end

	if p.FilterGroup then
		return true
	end

	return false, "FilterGroup is not defined"
end

function Filterable.Cast(p)
	return p
end

return Filterable