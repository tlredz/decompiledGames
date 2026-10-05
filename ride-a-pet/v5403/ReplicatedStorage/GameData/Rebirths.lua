local Rebirths = {
	Cap = 6,
	InitialCost = 1000000,
	CostMultiplier = 50,
	MultiplierPerRebirth = 1,
	BasePetCapacity = 5,
	PetCapacityPerRebirth = 1,
	RiggedCost = {
		1000000,
		500000000,
		2500000000,
		125000000000,
		6250000000000,
		1000000000000000
	}
}

function Rebirths.GetMultiplier(p)
	return 1 + math.max(math.floor(tonumber(p) or 0), 0) * Rebirths.MultiplierPerRebirth
end

function Rebirths.GetCost(p)
	local v = math.max(math.floor(tonumber(p) or 0), 0)
	local riggedCost = Rebirths.RiggedCost

	if typeof(riggedCost) == "table" then
		local v2 = tonumber(riggedCost[v + 1])

		if v2 then
			return (math.floor(v2))
		end

		local v3 = 0

		for k, v4 in pairs(riggedCost) do
			if not (typeof(k) == "number" and tonumber(v4) and v3 < k) then
				continue
			end

			v3 = k
		end

		if v3 > 0 and v3 < v + 1 then
			return (math.floor(tonumber(riggedCost[v3]) * Rebirths.CostMultiplier ^ (v + 1 - v3)))
		end
	end

	return (math.floor(Rebirths.InitialCost * Rebirths.CostMultiplier ^ v))
end

function Rebirths.GetPetCapacity(p)
	return Rebirths.BasePetCapacity + math.max(math.floor(tonumber(p) or 0), 0) * Rebirths.PetCapacityPerRebirth
end

return Rebirths