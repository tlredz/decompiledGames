local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RandomModeler = require(ReplicatedStorage.CAM.Global.RandomModeler)
local Spinners = {
	NOTHING = "$Nothing"
}

function Spinners.new(data)
	local v = math.clamp(data.Nothing or 0, 0, 1)
	local total = 0

	for _, v2 in pairs(data.Pool) do
		total += v2
	end

	local weights2 = {}

	if v > 0 then
		weights2[Spinners.NOTHING] = v
	end

	if total > 0 then
		local v3 = 1 - v

		for k, v4 in pairs(data.Pool) do
			weights2[k] = v3 * (v4 / total)
		end
	end

	local v3 = {}

	for k in pairs(data.Pool) do
		table.insert(v3, k)
	end

	table.sort(v3)
	return {
		Cost = math.max(math.floor(data.Cost or 1), 1),
		Weights = weights2,
		Pool = function()
			return table.clone(v3)
		end,
		Odds = function()
			local weights = RandomModeler.NormalizeWeights(weights2)

			if weights[Spinners.NOTHING] ~= nil then
				weights.Nothing = weights[Spinners.NOTHING]
				weights[Spinners.NOTHING] = nil
			end

			return weights
		end,
		Roll = function()
			return RandomModeler.WeightedChoose(weights2) or Spinners.NOTHING
		end
	}
end

setmetatable(Spinners, {
	__index = function(p, childName: string)
		local child = script:FindFirstChild(childName)

		if child == nil then
			return nil
		end

		local module = require(child)
		rawset(p, childName, module)
		return module
	end
})
return Spinners